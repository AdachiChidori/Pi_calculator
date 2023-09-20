`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/26 22:21:51
// Design Name: 
// Module Name: top_for_debug
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


module top_for_debug(
    input sysclk,
    input btn, 
    input [3:0] sw, 
    output [3:0] led, 
    output [7:0] led_7seg
    );

//parameter Nbr = 17;
wire [7:0] nbr_sw; assign nbr_sw = 8'd4 + sw[3:0];
parameter division_ratio = 4;

wire clk, rst;
assign clk = sysclk;
assign rst = ~btn;

(* mark_debug = "true" *) wire complete;
wire [3:0] dec_1digit;
wire busy;
wire [3:0] led;
wire [7:0] led_7seg;


reg [7:0] count = 0;
always @(posedge(clk)) begin
    count <= count + 1;
end
//pi_calc_trapezoidal_IP #(.Nbr(Nbr), .division_ratio(division_ratio)) pi_calc_trapezoidal_IP0(clk, 1'b0, rst, &count[3:0]&complete, complete, dec_1digit, led, led_7seg);
pi_calc_trapezoidal_sw_IP #(.division_ratio(division_ratio)) pi_calc_trapezoidal_sw_IP0(clk, 1'b0, rst, &count[3:0]&complete, nbr_sw, complete, dec_1digit, led, led_7seg);

endmodule