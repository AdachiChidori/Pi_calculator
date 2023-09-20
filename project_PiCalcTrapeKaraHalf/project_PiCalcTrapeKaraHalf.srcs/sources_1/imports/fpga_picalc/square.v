// module square(
//     x_,
//     x_square,
//     x_inc,
//     x_inc_square
// );
//     input [3:0] x_;
//     input [7:0] x_square;
//     output [3:0] x_inc;
//     output [7:0] x_inc_square;

//     assign x_inc = x_ + 1;

//     assign x_inc_square = x_square + (x_ << 1) + 1;

// endmodule

module square_x #(
    parameter Nbr = 4
)(
    clk,
    rst,
    enable,
    x_,
    x_square
);
    input clk, rst;
    input enable;

    output [(Nbr-1):0] x_;
    output [(2*Nbr-1):0] x_square;

    reg [(Nbr-1):0] x_;
    reg [(2*Nbr-1):0] x_square;
    //reg s_end;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            x_ <= 'h0;
            x_square <= 'h0;
        end else begin
            if (enable) begin
                x_ <= x_ + 1;
                x_square <= x_square + (x_ << 1) + 1;
            end
        end
    end

endmodule


module square_y #(
    parameter Nbr = 4
)(
    clk,
    rst,
    enable,
    y_,
    y_square
);
    input clk, rst;
    input enable;

    output [(Nbr-1):0] y_;
    output [(2*Nbr-1):0] y_square;

    reg [(Nbr-1):0] y_;
    reg [(2*Nbr-1):0] y_square;
    //reg s_end;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            y_ <= 1 << (Nbr - 1); // honto ha radius
            y_square <= 1 << (2* (Nbr-1));
        end else begin
            if (enable) begin
                y_ <= y_ - 1;
                y_square <= y_square - (y_ << 1) + 1;
            end
        end
    end

endmodule



module square_x_errorDetect #(
    parameter Nbr = 4
)(
    clk,
    rst,
    enable,
    y_, 
    x_,
    x_square, 
    valid, 
    accum_enable, 
    y_out
);
    input clk, rst;
    input enable;
    
    input [(Nbr-1):0] y_;

    output [(Nbr-1):0] x_;
    output [(2*Nbr-1):0] x_square;
    
    output wire valid;
    output reg accum_enable;
    output reg [(Nbr-1):0] y_out;

    reg [(Nbr-1):0] x_;
    reg [(2*Nbr-1):0] x_square;
    
    reg [(Nbr-1):0] x_old;
    reg [(2*Nbr-1):0] x_square_old;
    
    wire parity_error;
    wire x_update_valid, x_square_update_valid, update_valid;
    
    assign parity_error = (x_square[0] ^ x_[0]); // x and x*x must be same parity
    assign x_update_valid = (x_old[0] ^ x_[0]); // Is x updated?
    assign x_square_update_valid = (x_square_old[0] ^ x_square[0]); // Is x*x updated?
    assign update_valid = (x_update_valid && x_square_update_valid); // Are both updated?
    assign valid = update_valid && !parity_error; // valid state
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            x_ <= 'h0;
            x_square <= 'h0;
            x_old <= 'h0;
            x_square_old <= 'h0;
        end else begin
            accum_enable <= enable; // delay 1 clock 
            y_out <= y_; // delay 1 clock
            if (enable && !parity_error && update_valid) begin
                x_old <= x_;
                x_square_old <= x_square;
                x_ <= x_ + 1;
                x_square <= x_square + (x_ << 1) + 1;
            end else if (enable && !parity_error) begin // when parity error
                x_ <= x_old + 1;
                x_square <= x_square_old + (x_ << 1) + 1;
            end else if (parity_error) begin
                if (x_update_valid) begin // when x_square is NOT updated
                    x_square <= x_square + (x_old << 1) + 1;
                end
                if (x_square_update_valid) begin // when x is NOT updated
                    x_ <= x_ + 1;
                end
            end
        end
    end

endmodule


module square_x_errorDetect_yRound #(
    parameter Nbr = 4
)(
    clk,
    rst,
    enable,
    y_, 
    y_square, 
    x_,
    x_square, 
    r2_sub_x2, 
    valid, 
    accum_enable, 
    y_out
);
    input clk, rst;
    input enable;
    
    input [(Nbr-1):0] y_;
    input [(2*Nbr-1):0] y_square;
    input [(2*Nbr-1):0] r2_sub_x2;

    output [(Nbr-1):0] x_;
    output [(2*Nbr-1):0] x_square;
    
    output wire valid;
    output reg accum_enable;
    output reg [(Nbr-1):0] y_out;

    reg [(Nbr-1):0] x_;
    reg [(2*Nbr-1):0] x_square;
    
    reg [(Nbr-1):0] x_old;
    reg [(2*Nbr-1):0] x_square_old;
    reg [(2*Nbr-1):0] y_square_old;
    
    wire parity_error;
    wire x_update_valid, x_square_update_valid, update_valid;
    
    assign parity_error = (x_square[0] ^ x_[0]); // x and x*x must be same parity
    assign x_update_valid = (x_old[0] ^ x_[0]); // Is x updated?
    assign x_square_update_valid = (x_square_old[0] ^ x_square[0]); // Is x*x updated?
    assign update_valid = (x_update_valid && x_square_update_valid); // Are both updated?
    assign valid = update_valid && !parity_error; // valid state
    wire [(2*Nbr-1):0] square_diff_old, square_diff;
    assign square_diff_old = y_square_old - r2_sub_x2;
    assign square_diff = r2_sub_x2 - y_square;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            x_ <= 'h0;
            x_square <= 'h0;
            x_old <= 'h0;
            x_square_old <= 'h0;
            y_square_old <= 1 << (2* (Nbr-1)); //'h0; //y_square;
            y_out <= y_;
        end else begin
            accum_enable <= enable; // delay 1 clock 
            //if ((r2_sub_x2 - y_square) < (y_square_old - r2_sub_x2)) begin
            if (((r2_sub_x2 - y_square) < (y_square_old - r2_sub_x2)) || (((r2_sub_x2 - y_square) > (y_square_old - r2_sub_x2)) && (y_square > r2_sub_x2))) begin 
            // if ((square_diff) < (square_diff_old)) begin 
                y_out <= y_; // rounded
                y_square_old <= y_square;
            end
            
            if (enable && !parity_error && update_valid) begin
                x_old <= x_;
                x_square_old <= x_square;
                x_ <= x_ + 1;
                x_square <= x_square + (x_ << 1) + 1;
            end else if (enable && !parity_error) begin // when parity error
                x_ <= x_old + 1;
                x_square <= x_square_old + (x_ << 1) + 1;
            end else if (parity_error) begin
                if (x_update_valid) begin // when x_square is NOT updated
                    x_square <= x_square + (x_old << 1) + 1;
                end
                if (x_square_update_valid) begin // when x is NOT updated
                    x_ <= x_ + 1;
                end
            end
        end
    end

endmodule
