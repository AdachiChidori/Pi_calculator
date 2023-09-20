module comparator #(
    parameter Nbr = 4
)(
    a,
    b,
    a_le_b
);
    input [(2*Nbr-1):0] a;
    input [(2*Nbr-1):0] b;
    output a_le_b;

    assign a_le_b = (a <= b);

endmodule

/*
module comparator_sync #(
    parameter Nbr = 4
)(
    clk, 
    rst,
    a,
    b,
    a_le_b
);
    input clk, rst;
    input [(2*Nbr-1):0] a;
    input [(2*Nbr-1):0] b;
    output a_le_b;

    reg a_le_b;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            a_le_b <= 1'b0;
        end else begin
            a_le_b <= (a <= b);
        end
    end

endmodule
*/