// bin2dec simulation
`timescale 1ns/1ns

module bin2dec_test;

parameter Nbr = 30; //16;

reg clk, rst;
reg [(2*Nbr-1):0] pi_bin = 60'h3243F6A88854742; // 32'h3243F5B8;
reg pi_enable, dec_enable;
wire [3:0] dec_1digit;
wire busy;

bin2dec #(Nbr) bin2dec0(clk, rst, pi_enable, pi_bin, dec_enable, dec_1digit, busy);

parameter STEP = 2;

always begin
    clk = 0; #(STEP/2);
    clk = 1; #(STEP/2);
end


initial begin
    #STEP; rst = 0;
    #STEP; pi_enable = 0; dec_enable = 0;
    #STEP; rst = 1;
    #STEP;
    #STEP; pi_enable = 1; dec_enable = 1;
    #STEP;
    #(STEP* (2 * Nbr)); 
    #STEP; pi_enable = 0;
    #(STEP* (2 * Nbr)); 
    //#STEP; rst = 0;
    //#STEP; rst = 1;
    //#(STEP* (1 << (Nbr))); 
    $finish;
end

initial begin
    $monitor($stime, " dec_1digit=%d", dec_1digit);
    $dumpfile("bin2dec_test.vcd");
    $dumpvars(0, bin2dec_test);
end

endmodule

