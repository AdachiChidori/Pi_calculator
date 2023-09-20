// Pi-calculator simulation
`timescale 1ns/1ns

module pi_calc_test;

parameter Nbr = 16;

reg clk, rst;
wire [(2*Nbr-1):0] pi_out;
wire complete;

pi_calc #(Nbr) pi_calc0(clk, rst, pi_out, complete);

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
    #(STEP* (1 << (Nbr))); 
    //#STEP; rst = 0;
    //#STEP; rst = 1;
    //#(STEP* (1 << (Nbr))); 
    $finish;
end

//initial begin
    //$monitor($stime, " complete=%b, pi_out=%d", complete, pi_out);
    //$dumpfile("pi_calc_test.vcd");
    //$dumpvars(0, pi_calc_test);
//end

endmodule

