`timescale 1us/1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/20 17:05:36
// Design Name: 
// Module Name: square_karatsuba_test
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


module square_karatsuba_test;

parameter Nh = 64;

reg clk, rst;
reg [(2*Nh-1):0] x_;
wire [(4*Nh-1):0] x_square;

square_karatsuba_128bit square_128b(x_, x_square);
//square_karatsuba_1024bit square_1024b(x_, x_square);

parameter STEP = 2;

always begin
    clk = 0; #(STEP/2);
    clk = 1; #(STEP/2);
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        x_ <= 'd0;
    end else begin
        //x_ <= x_ + 'd1;
        x_ <= (x_ << 1) + 'd1;
    end
end

initial begin
    #STEP; rst = 0;
    #STEP; rst = 1;
    //#(STEP*((1 << Nh) << Nh)); 
    #(STEP*Nh*2);
    $finish;
end

endmodule
