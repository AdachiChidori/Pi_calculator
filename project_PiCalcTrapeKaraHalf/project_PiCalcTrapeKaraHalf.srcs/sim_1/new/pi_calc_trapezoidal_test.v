`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/23 20:14:10
// Design Name: 
// Module Name: pi_calc_trapezoidal_test
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


module pi_calc_trapezoidal_test;

//parameter Nbr = 4;
parameter Nh = 64;

wire [7:0] nbr_sw = 8'd8;
parameter division_ratio = 4;

reg clk, rst;
wire [(2*Nh-1):0] pi_out;
wire complete;
//wire [(2*Nh-1):0] pi_bin; 
//assign pi_bin = pi_out;
//reg dec_enable;
wire [3:0] dec_1digit;
wire busy;
wire [3:0] led;
wire [7:0] led_7seg;

//pi_calc_trapezoidal #(Nbr) pi_calc_trapezoidal0(clk, rst, pi_out, complete);
//bin2dec #(Nh) bin2dec0(clk, rst, complete, pi_out, clk, dec_1digit, busy);

reg [29:0] count = 0;
always @(posedge(clk)) begin
    count <= count + 1;
end
//pi_calc_trapezoidal_IP #(Nbr) pi_calc_trapezoidal_IP0(clk, 1'b0, rst, count[3], complete, dec_1digit, led, led_7seg);
pi_calc_trapezoidal_sw_IP #(.division_ratio(division_ratio)) pi_calc_trapezoidal_sw_IP0(clk, 1'b0, rst, &count[3:0]&complete, nbr_sw, complete, dec_1digit, led, led_7seg);

parameter STEP = 2;

always begin
    clk = 0; #(STEP/2);
    clk = 1; #(STEP/2);
end


initial begin
    #STEP; rst = 0;
    #STEP; rst = 1;
    #STEP;
    #STEP;
    #(STEP * (Nh * ('d1 << (nbr_sw + division_ratio + 1)))); 
    $finish;
end

endmodule

