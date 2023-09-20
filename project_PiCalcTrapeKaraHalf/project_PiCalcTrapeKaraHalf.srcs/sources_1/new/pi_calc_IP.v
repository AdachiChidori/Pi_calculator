`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/20 22:10:16
// Design Name: 
// Module Name: pi_calc_IP
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



module pi_calc_IP#(
    parameter Nbr = 4
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
    
    //parameter Nbr = 17; 
    
    // reg clk, rst;
    wire [(2*Nbr-1):0] pi_out;
    wire [(2*Nbr-1):0] pi_bin;
    wire complete;
    wire pi_enable, dec_enable;
    assign pi_enable = complete;
    //assign dec_enable = complete;
    assign pi_bin = pi_out;
    wire [3:0] dec_1digit;
    wire busy;
    reg busy_old;
    
    (* mark_debug = "true" *) reg [29:0] count = 0;
    always @(posedge(sysclk)) begin
        count <= count + 1;
    end
    
    //wire w1, w2, w3, w4;
    //(* dont_touch = "true" *) LUT1 #( .INIT(2'b10) ) buf_inst1(.O(w1), .I0(count[27]));
    //(* dont_touch = "true" *) LUT1 #( .INIT(2'b10) ) buf_inst2(.O(w2), .I0(w1));
    //(* dont_touch = "true" *) LUT1 #( .INIT(2'b10) ) buf_inst3(.O(w3), .I0(w2));
    //(* dont_touch = "true" *) LUT1 #( .INIT(2'b10) ) buf_inst4(.O(w4), .I0(w3));
    //assign dec_enable = &count[26:0]; //1'b1; //count[1]
    
    assign clk = sysclk; //count[1]; //
    assign rst = (~btn) && rst_soft;
    assign led[3:0] = dec_1digit[3:0];
    
    pulse pulse0(clk, update_digit, dec_enable);
    
    pi_calc #(Nbr) pi_calc0(clk, rst, pi_out, complete);
    bin2dec #(Nbr) bin2dec0(clk, rst, complete, pi_bin, dec_enable, dec_1digit, busy);
    //bin2dec #(Nbr) bin2dec0(count[27], rst, complete, pi_bin, dec_enable, dec_1digit, busy);
    //bin2dec #(Nbr) bin2dec0(w4, rst, complete, pi_bin, dec_enable, dec_1digit, busy);
    
    decoder_7seg decoder_7seg0(dec_1digit[3:0], led_7seg[7:0]);
    
endmodule


module pulse (
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
