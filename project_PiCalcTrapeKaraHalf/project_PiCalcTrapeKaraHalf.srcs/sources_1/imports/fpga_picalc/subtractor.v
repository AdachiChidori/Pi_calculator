module subtractor #(
    parameter Nbr = 4
) (
    a,
    b,
    a_sub_b
);
    input [(2*Nbr-1):0] a;
    input [(2*Nbr-1):0] b;
    output [(2*Nbr-1):0] a_sub_b;

    assign a_sub_b = a - b;
    
endmodule