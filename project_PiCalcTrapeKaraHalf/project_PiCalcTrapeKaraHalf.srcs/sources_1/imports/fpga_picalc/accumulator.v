module accumulator #(
    parameter Nbr = 4
)(
    clk,
    rst,
    enable,
    y_,
    sum
);
    input clk, rst;
    input enable;

    input [(Nbr-1):0] y_;
    output [(2*Nbr-1):0] sum;

    reg [(2*Nbr-1):0] sum;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sum <= 'd0;
        end else begin
            if (enable) begin
                sum <= sum + y_;
            end
        end
    end

endmodule

/*
module accumulator_x2sync #(
    parameter Nbr = 4
)(
    clk,
    rst,
    enable,
    x_square,
    y_,
    sum
);
    input clk, rst;
    input enable;

    input [(2*Nbr-1):0] x_square;
    input [(Nbr-1):0] y_;
    output [(2*Nbr-1):0] sum;
    
    reg [(2*Nbr-1):0] x_square_old;
    reg [(2*Nbr-1):0] y_old;
    reg [(2*Nbr-1):0] sum;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            x_square_old <= x_square;
            y_old <= y_;
            sum <= 'd0;
        end else begin
            //if (enable && (x_square_old != x_square)) begin
            if (x_square_old != x_square) begin
                x_square_old <= x_square;
                //sum <= sum + y_;
                sum <= sum + y_old;
                y_old <= y_;
            end
        end
    end

endmodule
*/
