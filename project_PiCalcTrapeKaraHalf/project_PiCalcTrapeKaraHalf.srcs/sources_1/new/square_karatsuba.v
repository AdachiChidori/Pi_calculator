`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/20 16:36:51
// Design Name: 
// Module Name: square_karatsuba
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

module square_karatsuba_1024bit(
    x_,
    x_square,
);
    parameter Nh = 512; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_512bit square_q1(q1, v);
    square_karatsuba_512bit square_q0(q0, w);
    square_karatsuba_512bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_512bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_512bit(
    x_,
    x_square,
);
    parameter Nh = 256; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_256bit square_q1(q1, v);
    square_karatsuba_256bit square_q0(q0, w);
    square_karatsuba_256bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_256bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_256bit(
    x_,
    x_square,
);
    parameter Nh = 128; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_128bit square_q1(q1, v);
    square_karatsuba_128bit square_q0(q0, w);
    square_karatsuba_128bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_128bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_128bit(
    x_,
    x_square,
);
    parameter Nh = 64; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_64bit square_q1(q1, v);
    square_karatsuba_64bit square_q0(q0, w);
    square_karatsuba_64bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_64bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_64bit(
    x_,
    x_square,
);
    parameter Nh = 32; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_32bit square_q1(q1, v);
    square_karatsuba_32bit square_q0(q0, w);
    square_karatsuba_32bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_32bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_32bit(
    x_,
    x_square,
);
    parameter Nh = 16; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_16bit square_q1(q1, v);
    square_karatsuba_16bit square_q0(q0, w);
    square_karatsuba_16bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_16bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_16bit(
    x_,
    x_square,
);
    parameter Nh = 8; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_8bit square_q1(q1, v);
    square_karatsuba_8bit square_q0(q0, w);
    square_karatsuba_8bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_8bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_8bit(
    x_,
    x_square,
);
    parameter Nh = 4; // number of bit of half-size
    input [(2*Nh-1):0] x_;
    output [(4*Nh-1):0] x_square;
    
    wire [(Nh-1):0] q1, q0;
    assign q1 = x_[(2*Nh-1):Nh];
    assign q0 = x_[(Nh-1):0];
    
    wire [(2*Nh-1):0] v, w, u, u1, u0;
    square_karatsuba_4bit square_q1(q1, v);
    square_karatsuba_4bit square_q0(q0, w);
    square_karatsuba_4bit square_q1Sq0(q1-q0, u1);
    square_karatsuba_4bit square_q0Sq1(q0-q1, u0);
    assign u = (q1 >= q0)? u1 : u0;
    assign x_square = ((v << Nh) << Nh) + ((v+w-u) << Nh) + w;
endmodule


module square_karatsuba_4bit(
    x_,
    x_square,
);
    input [3:0] x_;
    output [7:0] x_square;

    function [7:0] square;
        input [3:0] invar;
        case (invar)
            4'h0:    square = 8'd0;
            4'h1:    square = 8'd1;
            4'h2:    square = 8'd4;
            4'h3:    square = 8'd9;
            4'h4:    square = 8'd16;
            4'h5:    square = 8'd25;
            4'h6:    square = 8'd36;
            4'h7:    square = 8'd49;
            4'h8:    square = 8'd64;
            4'h9:    square = 8'd81;
            4'ha:    square = 8'd100;
            4'hb:    square = 8'd121;
            4'hc:    square = 8'd144;
            4'hd:    square = 8'd169;
            4'he:    square = 8'd196;
            4'hf:    square = 8'd225;
            default: square = 8'h0;
        endcase
    endfunction

    assign x_square = square(x_);
endmodule