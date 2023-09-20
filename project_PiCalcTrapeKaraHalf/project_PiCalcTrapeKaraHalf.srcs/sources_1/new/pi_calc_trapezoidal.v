`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/23 00:13:50
// Design Name: 
// Module Name: pi_calc_trapezoidal
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

module pi_calc_trapezoidal_sw#(
    //parameter Nbr = 4,
    parameter division_ratio = 4
)(
    input clk, 
    input rst,
    input [7:0] nbr_sw,
    output reg [(2*Nh-1):0] pi_out,
    output reg complete
);

parameter Nh = 64;
parameter W_Nh = $clog2(Nh+1);
//parameter division_ratio = 4;

reg set;
reg [7:0] nbr_reg;
wire [(Nh-1):0] r_ = 'd1 << (Nh-1);
(* mark_debug = "true" *) reg [(Nh-1):0] high_init;
(* mark_debug = "true" *) reg [(Nh-1):0] low_init; // = (r_ >> 1);
(* mark_debug = "true" *) reg [(Nh-1):0] x_in;
(* mark_debug = "true" *) wire [(Nh-1):0] y_ans;
wire complete_y;
reg [(Nh-1):0] h_; // = 'd1 << (Nh-1-Nbr); // width of small interval, R/(2^Nbr)

//bisection_64bit #(division_ratio) bisection(clk, rst, set, high_init, low_init, x_in, y_ans, complete_y);
bisection #(division_ratio) bisection_0(clk, rst, set, high_init, low_init, x_in, y_ans, complete_y);

wire complete_x;
assign complete_x = (x_in > (r_ >> 1));
(* mark_debug = "true" *) reg [3:0] state;
parameter set_width = 'h4;
reg [7:0] set_counter;

parameter S_BEGIN = 4'd0;
parameter S_PIINIT = 4'd1;
parameter S_XINCR = 4'd2;
parameter S_SET = 4'd3;
parameter S_CALCY = 4'd4;
parameter S_UPDATEBOUND = 4'd5;
parameter S_ACCUM = 4'd6;
parameter S_LASTSUM = 4'd7;
parameter S_PIOVER3 = 4'd8;
parameter S_COMPLETE = 4'd9;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        complete <= 1'b0;
        pi_out  <= 'd0;
        nbr_reg <= nbr_sw;
        x_in <= 'd0;
        set <= 1'b0;
        state <= S_BEGIN;
        high_init <= r_;
        low_init <= (r_ >> 1);
        h_ <= 'd1 << (Nh-1- nbr_sw);
        set_counter <= 'd0;
    end else begin         
        if (set_counter <= set_width) begin
            set_counter <= set_counter + 'd1;
        end else begin
            set_counter <= 'd0;
            if (state == S_BEGIN) begin 
                state <= S_PIINIT;
                x_in <= 'd0;
                pi_out <= (r_ >> 1) << (Nh-1- nbr_reg); // h*f(0)/2
            end else if ((state == S_PIINIT) || (state == S_UPDATEBOUND) || ((state == S_ACCUM) && (~complete_x))) begin
                state <= S_XINCR;
                x_in <= x_in + h_;
            end else if ((state == S_XINCR) && (~complete_x)) begin
                state <= S_SET;
                set <= 1'b1; // rise up SET to sample x_in and start to compute y_
            end else if ((state == S_SET) || ((state == S_CALCY) && (complete_y != 1'b1))) begin
                state <= S_CALCY;
                set <= 1'b0;
            end else if (state == S_CALCY) begin
                state <= S_UPDATEBOUND;
                high_init <= y_ans; // upper bound of y is y_ans@right_edge_coarse in fine integration
                low_init <= y_ans - h_;
                pi_out <= pi_out + (y_ans << (Nh-1- nbr_reg));
            end else if ((state == S_XINCR) && (complete_x)) begin
                state <= S_LASTSUM;
                pi_out <= pi_out - (y_ans << (Nh-1- nbr_reg - 1)); // +f(right_edge_coarse)/2
            end else if (state == S_LASTSUM) begin
                state <= S_PIOVER3;
                // sum = int_0^{1/2} \sqrt{1-x^2} dx = (1/4)*(\pi/3 + sqrt{3}/2)
                // y(1/2) = \sqrt{3}/2
                // sum - y(1/2)/4 = \pi/12
                pi_out <= pi_out - (y_ans << (Nh-1-2));
            end else if (state == S_PIOVER3) begin
                state <= S_COMPLETE;
                pi_out <= (pi_out << 1) + pi_out; // 3*pi_out = \pi/4
                // note: bin2dec converts \pi/4 to 3.141592... 
                // because of decimal point location between pi_out[2*Nh-2] and pi_out[2*Nh-3]
                complete <= 1'b1;
            end
        end
    end
end

endmodule





module pi_calc_trapezoidal#(
    parameter Nbr = 4,
    parameter division_ratio = 4
)(
    clk,
    rst,
    pi_out,
    complete
);

parameter Nh = 64;
parameter W_Nh = $clog2(Nh+1);
//parameter division_ratio = 32;

input clk, rst;
output reg [(2*Nh-1):0] pi_out;
output reg complete;

reg set;
wire [(Nh-1):0] r_ = 'd1 << (Nh-1);
(* mark_debug = "true" *) reg [(Nh-1):0] high_init;
(* mark_debug = "true" *) reg [(Nh-1):0] low_init; // = (r_ >> 1);
(* mark_debug = "true" *) reg [(Nh-1):0] x_in;
(* mark_debug = "true" *) wire [(Nh-1):0] y_ans;
(* mark_debug = "true" *) wire [(Nh-1):0] right_edge;
wire complete_1overSqrt2, complete_y;
//wire [(Nh-1):0] h_ = (right_edge >> Nbr) + right_edge[Nbr-1]; // width of small interval
reg [(Nh-1):0] h_; // = 'd1 << (Nh-1-Nbr); // width of small interval, R/(2^Nbr)
wire [(Nh-1):0] n_coarse; assign n_coarse = right_edge >> (Nh-1-Nbr); // number of trapezoidals of coarse integral 
wire [(Nh-1):0] right_edge_coarse; assign right_edge_coarse = n_coarse << (Nh-1-Nbr); // right edge of  of coarse integral, i.e., left edge of fine integral

wire [(2*Nh-1):0] const_one; // = 1'b1 << (2*Nbr - 4);
assign const_one = 1'b1 << (2*Nh - 4); // 1 (constant)

bisection_1overSqrt2_64bit #(division_ratio) bisection_right_edge(clk, rst, right_edge, complete_1overSqrt2);
bisection_64bit #(division_ratio) bisection(clk, rst, set, high_init, low_init, x_in, y_ans, complete_y);

//reg comp_state;
wire complete_x;
assign complete_x = (x_in >= right_edge);
//assign complete = comp_state;
(* mark_debug = "true" *) reg [3:0] state;
(* mark_debug = "true" *) reg [(W_Nh-1):0] shift_of_h;
parameter set_width = 'h4;
reg [7:0] set_counter;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        complete <= 1'b0;
        pi_out  <= 'd0;
        x_in <= 'd0;
        set <= 1'b0;
        state <= 'h0;
        high_init <= r_;
        low_init <= (r_ >> 1);
        h_ <= 'd1 << (Nh-1-Nbr);
        shift_of_h <= 'd0;
        set_counter <= 'd0;
    end else begin 
        
        if (set_counter <= set_width) begin
            set_counter <= set_counter + 'd1;
        end else begin
            set_counter <= 'd0;
        if (state == 'h0) begin 
            state <= 'h1;
        end else if (complete_1overSqrt2 != 1'b1) begin
            state <= 'h2;
            pi_out <= (r_ >> 1) << (Nh-1-Nbr - shift_of_h); // h*f(0)/2
        end else if ((state == 'h2) || (state == 'h6) || ((state == 'h8) && (x_in < right_edge))) begin
            state <= 'h3;
            x_in <= x_in + (h_ >> shift_of_h); // width of small interval is "1" (minimum) in fine integration
        end else if ((state == 'h3) && (x_in <= right_edge)) begin
            state <= 'h4;
            set <= 1'b1; // rise up SET to sample x_in and start to compute y_
            /*set_counter <= 'd0;
        end else if (state == 'h4) begin // this state makes delay to set values into bisection-machine 
            if (set_counter >= set_width) begin
                state <= 'h5;
                set <= 1'b0;
            end else begin
                set_counter <= set_counter + 'd1;
            end*/
        end else if ((state == 'h4) || ((state == 'h5) && (complete_y != 1'b1))) begin
            state <= 'h5;
            set <= 1'b0;
        end else if (state == 'h5) begin
            state <= 'h6;
            high_init <= y_ans; // upper bound of y is y_ans@right_edge_coarse in fine integration
            if ((y_ans - (h_ >> shift_of_h)) < right_edge) begin 
                low_init <= y_ans - (h_ >> shift_of_h); // lower bound till right_edge
            end else begin
                low_init <= right_edge;
            end
            pi_out <= pi_out + (y_ans << ((Nh-1-Nbr - shift_of_h)));
        end else if ((state == 'h3) && !(x_in == right_edge)) begin
            state <= 'h7;
            pi_out <= pi_out - (y_ans << (Nh-1-Nbr - shift_of_h - 1)); // -f(right_edge_coarse)/2
            x_in <= x_in - (h_ >> shift_of_h); // roll back
            shift_of_h <= shift_of_h + 'd1;
        end else if (state == 'h7) begin
            state <= 'h8;
            pi_out <= pi_out + (y_ans << (Nh-1-Nbr - shift_of_h - 1)); // +f(right_edge_coarse)/2
        end else if (state == 'h8) begin
            state <= 'h9;
            pi_out <= (pi_out << 1) - (const_one << 1);
            complete <= 1'b1;
        end
        end
    end
end


endmodule




module pi_calc_trapezoidal_old#(
    parameter Nbr = 4
)(
    clk,
    rst,
    pi_out,
    complete
);

parameter Nh = 32;
parameter W_Nh = $clog2(Nh+1);

input clk, rst;
output reg [(2*Nh-1):0] pi_out;
output reg complete;

reg set;
wire [(Nh-1):0] r_ = 'd1 << (Nh-1);
reg [(Nh-1):0] high_init;
wire [(Nh-1):0] low_init = (r_ >> 1);
reg [(Nh-1):0] x_in;
wire [(Nh-1):0] y_ans;
wire [(Nh-1):0] right_edge;
wire complete_1overSqrt2, complete_y;
//wire [(Nh-1):0] h_ = (right_edge >> Nbr) + right_edge[Nbr-1]; // width of small interval
reg [(Nh-1):0] h_; // = 'd1 << (Nh-1-Nbr); // width of small interval, R/(2^Nbr)
wire [(Nh-1):0] n_coarse = right_edge >> (Nh-1-Nbr); // number of trapezoidals of coarse integral 
wire [(Nh-1):0] right_edge_coarse = n_coarse << (Nh-1-Nbr); // right edge of  of coarse integral, i.e., left edge of fine integral

wire [(2*Nh-1):0] const_one; // = 1'b1 << (2*Nbr - 4);
assign const_one = 1'b1 << (2*Nh - 4); // 1 (constant)

bisection_1overSqrt2_32bit bisection_right_edge(clk, rst, right_edge, complete_1overSqrt2);
bisection_32bit bisection(clk, rst, set, high_init, low_init, x_in, y_ans, complete_y);

//reg comp_state;
wire complete_x;
assign complete_x = (x_in >= right_edge);
//assign complete = comp_state;
reg [3:0] state;
reg [(W_Nh-1):0] shift_of_h;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        complete <= 1'b0;
        pi_out  <= 'd0;
        x_in <= 'd0;
        set <= 1'b0;
        state <= 'h0;
        high_init <= r_;
        h_ <= 'd1 << (Nh-1-Nbr);
        shift_of_h <= 'd0;
    end else begin
        if (state == 'h0) begin 
            state <= 'h1;
        end else if (complete_1overSqrt2 != 1'b1) begin
            state <= 'h2;
            //pi_out <= (r_ >> 1) + (right_edge >> 1) + (r_ ^ right_edge); // f(0)/2 + f(R/sqrt(2))/2
            //pi_out <= (r_ >> 1) - (right_edge >> 1); // f(0)/2 - f(R/sqrt(2))/2
            pi_out <= (r_ >> 1); // f(0)/2
        end else if ((state == 'h2) || (state == 'h6)) begin
            state <= 'h3;
            x_in <= x_in + h_; // horizontal step
        end else if ((state == 'h3) && (x_in <= right_edge_coarse)) begin
            state <= 'h4;
            set <= 1'b1; // rise up SET to sample x_in and start to compute y_
        end else if ((state == 'h4) || ((state == 'h5) && (complete_y != 1'b1))) begin
            state <= 'h5;
            set <= 1'b0;
        end else if (state == 'h5) begin
            state <= 'h6;
            pi_out <= pi_out + y_ans;
        end else if (state == 'h3) begin
            state <= 'h7;
            pi_out <= pi_out - (y_ans >> 1); // + f(right_edge_coarse)/2
            x_in <= right_edge_coarse;  // roll back
            high_init <= y_ans; // upper bound of y is y_ans@right_edge_coarse in fine integration
        end else if (state == 'h7) begin
            //state <= 'h8;
            state <= 'hB; // for next operation
            pi_out <= (pi_out << (Nh-1-Nbr)); // + (y_ans >> 1); // sum * h + f(right_edge_coarse)/2
            shift_of_h <= shift_of_h + 'd1;
        end else if ((state == 'h8) || (state == 'hC)) begin
            state <= 'h9;
            x_in <= x_in + (h_ >> shift_of_h); // width of small interval is "1" (minimum) in fine integration
            high_init <= y_ans; // this update is not so effective?
        end else if ((state == 'h9) && (x_in < right_edge)) begin
            state <= 'hA;
            set <= 1'b1; // rise up SET to sample x_in and start to compute y_
        end else if ((state == 'hA) || ((state == 'hB) && (complete_y != 1'b1))) begin
            state <= 'hB;
            set <= 1'b0;
        end else if (state == 'hB) begin
            state <= 'hC;
            pi_out <= pi_out + (y_ans << ((Nh-1-Nbr - shift_of_h - 1)));
        end else if ((state == 'h9) && !(x_in == right_edge)) begin
            //state <= 'hD;
            state <= 'hB; // for next operation
            x_in <= x_in - (h_ >> shift_of_h); // roll back
            shift_of_h <= shift_of_h + 'd1;
        end else if (state == 'h9) begin
            state <= 'hE;
            //pi_out <= pi_out + (y_ans >> 1); // + f(right_edge)/2
        end else if (state == 'hE) begin
            state <= 'hF;
            pi_out <= (pi_out << 1) - (const_one << 1);
            complete <= 1'b1;
        end
    end
end


endmodule

