`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/21 00:35:43
// Design Name: 
// Module Name: bisection_test
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


module bisection_test;

//parameter Nbr = 30;
parameter Nh = 64;

reg clk, rst, set;
wire complete;
wire [(Nh-1):0] r_ = 'd1 << (Nh-1);

wire [(Nh-1):0] high_init = r_;
wire [(Nh-1):0] low_init = (r_ >> 1);
reg [(Nh-1):0] x_in;
wire [(Nh-1):0] y_ans;

//wire [(Nh-1):0] right_edge;
//bisection_1overSqrt2_64bit #(Nbr) bisection_right_edge(clk, rst, right_edge, complete);
bisection_64bit bisection(clk, rst, set, high_init, low_init, x_in, y_ans, complete);

parameter STEP = 2;

always begin
    clk = 0; #(STEP/2);
    clk = 1; #(STEP/2);
end

initial begin
    #STEP; rst = 0;
    #STEP; rst = 1;
    #STEP; x_in <= (r_ >> 1);
    #STEP; set <= 1'b1;
    #STEP; set <= 1'b0;
    //#(STEP*((1 << Nh) << Nh)); 
    #(STEP*Nh*3);
    $finish;
end

endmodule
