`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/02 22:10:52
// Design Name: 
// Module Name: decoder_7seg
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


module decoder_7seg(
    input [3:0] bcd_4bit,
    output [7:0] seg_out
    );

    function [7:0] deco7;
        input [3:0] bcd_4bit;
        case (bcd_4bit)
            // D.P, a, b, c, d, e, f, g
            4'h0:    deco7 = 8'b01111110;
            4'h1:    deco7 = 8'b00110000;
            4'h2:    deco7 = 8'b01101101;
            4'h3:    deco7 = 8'b01111001;
            4'h4:    deco7 = 8'b00110011;
            4'h5:    deco7 = 8'b01011011;
            4'h6:    deco7 = 8'b01011111;
            4'h7:    deco7 = 8'b01110010;
            4'h8:    deco7 = 8'b01111111;
            4'h9:    deco7 = 8'b01111011;
            4'ha:    deco7 = 8'b01110111;
            4'hb:    deco7 = 8'b00011111;
            4'hc:    deco7 = 8'b01001110;
            4'hd:    deco7 = 8'b00111101;
            4'he:    deco7 = 8'b01001111;
            4'hf:    deco7 = 8'b01000111;
            default: deco7 = 8'b10000000;
        endcase
    endfunction

    assign seg_out = deco7(bcd_4bit);

endmodule
