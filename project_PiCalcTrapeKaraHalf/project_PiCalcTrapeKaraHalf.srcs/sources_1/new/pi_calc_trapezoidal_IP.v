`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/23 00:08:22
// Design Name: 
// Module Name: pi_calc_trapezoidal_IP
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


module pi_calc_trapezoidal_sw_IP#(
    //parameter Nbr = 4,
    parameter division_ratio = 4
)(
    input sysclk,
    input [0:0] btn, 
    input [0:0] rst_soft,
    input [0:0] update_digit,
    input [7:0] nbr_sw,
    output [0:0] complete,
    output [3:0] dec_1digit,
    output [3:0] led, 
    output [7:0] led_7seg
    );    
    parameter Nh = 64;
    
    (* mark_debug = "true" *) wire [(2*Nh-1):0] pi_out;
    //wire [(2*Nh-1):0] pi_bin;
    wire complete;
    wire pi_enable, dec_enable;
    assign pi_enable = complete;
    //assign pi_bin = pi_out;
    wire [3:0] dec_1digit;
    wire busy;  
    
    assign clk = sysclk;
    assign rst = (~btn) && rst_soft;
    assign led[3:0] = dec_1digit[3:0];
    
    pulse_single pulse0(clk, update_digit, dec_enable);
    
    pi_calc_trapezoidal_sw #(.division_ratio(division_ratio)) pi_calc_trapezoidal_sw_0(clk, rst, nbr_sw, pi_out, complete);
    bin2dec #(Nh) bin2dec0(clk, rst, complete, pi_out, dec_enable, dec_1digit, busy);
    
    decoder_7seg decoder_7seg0(dec_1digit[3:0], led_7seg[7:0]);
    
endmodule




module pi_calc_trapezoidal_IP#(
    parameter Nbr = 4,
    parameter division_ratio = 4
)(
    input sysclk,
    input [0:0] btn, 
    input [0:0] rst_soft,
    input [0:0] update_digit,
    output [0:0] complete,
    output [3:0] dec_1digit,
    output [3:0] led, 
    output [7:0] led_7seg
    );    
    parameter Nh = 64;
    
    (* mark_debug = "true" *) wire [(2*Nh-1):0] pi_out;
    //wire [(2*Nh-1):0] pi_bin;
    wire complete;
    wire pi_enable, dec_enable;
    assign pi_enable = complete;
    //assign pi_bin = pi_out;
    wire [3:0] dec_1digit;
    wire busy;
    //reg busy_old;
    /*
    (* mark_debug = "true" *) reg [29:0] count = 0;
    always @(posedge(sysclk)) begin
        count <= count + 1;
    end
    */
    
    
    assign clk = sysclk;
    assign rst = (~btn) && rst_soft;
    assign led[3:0] = dec_1digit[3:0];
    
    pulse_single pulse0(clk, update_digit, dec_enable);
    
    pi_calc_trapezoidal #(.Nbr(Nbr), .division_ratio(division_ratio)) pi_calc_trapezoidal0(clk, rst, pi_out, complete);
    bin2dec #(Nh) bin2dec0(clk, rst, complete, pi_out, dec_enable, dec_1digit, busy);
    
    decoder_7seg decoder_7seg0(dec_1digit[3:0], led_7seg[7:0]);
    
endmodule


module pulse_single (
    input    clk,
    input    pulse_en,
    output    pulse_out
);
    reg [1:0]    diff;
    always @(posedge clk) begin
        diff    <=    {diff[0], pulse_en};
    end
    assign pulse_out =  (diff == 2'b01);
endmodule
