`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/26 11:44:05
// Design Name: 
// Module Name: bin2dec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Nbr = 16, Pi = h'3243F5B8 
// = b'0011 0010 0100 0011 1111 0101 1011 1000 
// Nbr = 30, Pi = h'3243F6A88854742
// = b'1100100100001111110110101010001000100001010100011101000010

module bin2dec #(
    parameter Nbr = 4
)(
    clk,
    rst,
    pi_enable, 
    pi_bin, // pi/4
    dec_enable,
    dec_1digit,
    busy
);

input clk, rst;
input pi_enable;
input [(2*Nbr-1):0] pi_bin;
(* mark_debug = "true" *) input dec_enable;
(* mark_debug = "true" *) output reg [3:0] dec_1digit;
(* mark_debug = "true" *) output reg busy;

(* mark_debug = "true" *) reg [(2*Nbr-1):0] pi_residual;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        pi_residual <= 0;
        busy <= 1'b0;
        dec_1digit <= 4'h0;
    end else begin
        if (pi_enable && !busy) begin
            pi_residual <= pi_bin;
            busy <= 1'b1;
            dec_1digit <= 4'h0;
        end else if (~|pi_residual) begin
            busy <= 1'b0;
        end else if (dec_enable) begin 
            dec_1digit <= pi_residual[(2*Nbr-1):(2*Nbr-4)];
            pi_residual <= (pi_residual[(2*Nbr-5):0] << 3) + (pi_residual[(2*Nbr-5):0] << 1);
        end
    end
end

endmodule