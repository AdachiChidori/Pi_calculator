// Pi-calculator

module pi_calc #(
    parameter Nbr = 4
)(
    clk,
    rst,
    pi_out,
    complete
);


input clk, rst;
output [(2*Nbr-1):0] pi_out;
output  complete;

(* mark_debug = "true" *) wire reset;
assign reset = rst; 
(* mark_debug = "true" *) wire [(Nbr-1):0] x_, y_;
(* mark_debug = "true" *) wire [(2*Nbr-1):0] x_square, y_square;
reg [(Nbr-1):0] r_ = 1 << (Nbr-1);
reg [(2*Nbr-1):0] r_square = 1 << (2 * (Nbr-1));
(* mark_debug = "true" *) wire [(2*Nbr-1):0] r2_sub_x2;
(* mark_debug = "true" *) wire accum_enable;
(* mark_debug = "true" *) wire [(2*Nbr-1):0] sum;
wire complete;
(* mark_debug = "true" *) reg [(2*Nbr-1):0] pi_out;

reg comp_state;

wire w_comp;

/*
sum = 8'd49 = 8'b00110001
4 * sum = 00110001 00
(4*sum)/(2^6) = 0011.000100 = 3 + 1/16
*/

// Components:
//  square_x_0    :- (if     accum_enable) x_sq <- (x_+1)^2
//  square_y_0    :- (if not accum_enable) y_sq <- (y_-1)^2
//  subtractor_0  :- (if     accum_enable) r2_sub_x2 <- r_sq - x_sq
//  comparator_0  :- accum_enable <- y^2 > r2_subx2
//  accumulator_0 :- (if     accum_enable) sum <- sum + y


subtractor #(Nbr) subtractor_0(r_square, x_square, r2_sub_x2);
comparator #(Nbr) comparator_0(y_square, r2_sub_x2, accum_enable);

(* mark_debug = "true" *) wire check;
wire accum_enable_delayed;
wire [(Nbr-1):0] y_out;
square_x_errorDetect #(Nbr) square_x_errorDetect0(clk, rst, accum_enable, y_, x_, x_square, check, accum_enable_delayed, y_out);
//square_x_errorDetect_yRound #(Nbr) square_x_errorDetect_yRound0(clk, rst, accum_enable, y_, y_square, x_, x_square, r2_sub_x2, check, accum_enable_delayed, y_out);
accumulator #(Nbr) accumulator_check(clk, rst, accum_enable_delayed && check, y_out, sum);
square_y #(Nbr) square_y_0(clk, rst, !accum_enable && check, y_, y_square);

assign w_comp = (x_ > y_out); //(x_ > r_); //(x_ == r_);
assign complete = comp_state;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        comp_state <= 1'b0;
        pi_out  <= 'h0;
    end else begin
        if (w_comp && !comp_state) begin
            comp_state <= 1'b1;
            pi_out <= sum;
        end
    end
end

endmodule

