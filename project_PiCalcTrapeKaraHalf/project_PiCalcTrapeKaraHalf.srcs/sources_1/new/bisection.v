`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/20 23:25:06
// Design Name: 
// Module Name: bisection
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


module bisection #(
    parameter division_ratio = 4
    )(
    clk,
    rst,
    set, 
    high_init, 
    low_init, 
    x_in,
    y_ans,
    complete    
    );
    // compute y_ans satisfying f(y)=R^2-x^2-y^2=0 by bisection method with initial interval of [low, high]
    
    parameter Nh = 64;
    
    input clk, rst, set;
    input [(Nh-1):0] high_init, low_init;
    input [(Nh-1):0] x_in;
    output reg [(Nh-1):0] y_ans;
    output reg complete;
    
    (* mark_debug = "true" *) reg [(Nh-1):0] high;
    (* mark_debug = "true" *) reg [(Nh-1):0] low;
    (* mark_debug = "true" *) wire [(Nh-1):0] mid;
    assign mid = (high >> 1) + (low >> 1) + (high[0] | low[0]); // round((high + low)/2)
    (* mark_debug = "true" *) reg [(2*Nh-1):0] r2subx2_reg;
    //wire [(2*Nh-1):0] high_square, low_square;
    //(* mark_debug = "true" *) wire [(2*Nh-1):0] mid_square; 
    wire [(2*Nh-1):0] r_square;
    assign r_square = 'd1 << (2*Nh-2);
    (* mark_debug = "true" *) reg [(Nh-1):0] util;
    (* mark_debug = "true" *) wire [(2*Nh-1):0] util_square;
    
    square_karatsuba_64bit square_util(util, util_square);
    
    //parameter division_ratio = 4;
    parameter bit_slow = $clog2(division_ratio+1);
    reg [(bit_slow+1):0] clk_slow;
    reg [1:0] state;
    
    always @(posedge clk or negedge rst) begin
        if ((~rst) || set) begin
            high <= high_init; // initilize large side of interval
            low <= low_init; // initialize small side of interval
            r2subx2_reg <= r_square;
            y_ans <= 'd0;
            complete <= 1'b0;
            clk_slow <= 'd0;
            util <= x_in;
            state <= 2'd1;
        end else begin
            clk_slow <= clk_slow + 1;
            if (state == 2'd1) begin
                r2subx2_reg <= r_square - util_square;
            end else begin
                util <= mid;
            end
            if (&clk_slow[(bit_slow-1):0]) begin
                if (state == 2'd1) begin
                    state <= 2'd2;
                end else if ((high <= (low + 'd1)) || (r2subx2_reg == util_square)) begin
                    complete <= 1'b1;
                    y_ans <= mid;
                end else if (r2subx2_reg < util_square) begin // ?( R^2 - X^2 - Y^2 = 0 )
                    high <= mid;
                end else begin
                    low <= mid;
                end
            end
        end
    end
        
endmodule




module bisection_mode #(
    parameter division_ratio = 32
    )(
    clk,
    rst,
    mode, 
    right_edge,
    right_edge_complete, 
    set, 
    high_init, 
    low_init, 
    x_in,
    y_ans,
    complete    
    );
    // compute y_ans satisfying f(y)=R^2-x^2-y^2=0 by bisection method with initial interval of [low, high]
    
    parameter Nh = 128;
    
    input clk, rst, mode, set;
    input [(Nh-1):0] high_init, low_init;
    input [(Nh-1):0] x_in;
    output reg [(Nh-1):0] right_edge;
    output reg right_edge_complete;
    output reg [(Nh-1):0] y_ans;
    output reg complete;
    
    (* mark_debug = "true" *) reg [(Nh-1):0] high;
    (* mark_debug = "true" *) reg [(Nh-1):0] low;
    (* mark_debug = "true" *) wire [(Nh-1):0] mid;
    assign mid = (high >> 1) + (low >> 1) + (high[0] | low[0]); // round((high + low)/2)
    (* mark_debug = "true" *) reg [(2*Nh-1):0] r2subx2_reg;
    //wire [(2*Nh-1):0] high_square, low_square;
    //(* mark_debug = "true" *) wire [(2*Nh-1):0] mid_square; 
    wire [(2*Nh-1):0] r_square;
    assign r_square = 'd1 << (2*Nh-2);
    (* mark_debug = "true" *) reg [(Nh-1):0] util;
    (* mark_debug = "true" *) wire [(2*Nh-1):0] util_square;
    
    square_karatsuba_128bit square_util(util, util_square);
    
    //parameter division_ratio = 32;
    parameter bit_slow = $clog2(division_ratio+1);
    reg [(bit_slow+1):0] clk_slow;
    reg [1:0] state;
    
    always @(posedge clk or negedge rst) begin
        if (mode != 1'b1) begin
            if (~rst || set) begin
                high <= 'd1 << (Nh-1); // initial value R
                low <= 'd1 << (Nh-2); // R/2
                right_edge <= 'd0;
                right_edge_complete <= 1'b0;
                clk_slow <= 'd0;
                util <= mid;
                state <= 2'd0;
            end else begin
                clk_slow <= clk_slow + 1;
                util <= mid;
                if (&clk_slow[(bit_slow-1):0]) begin
                    if ((high <= (low + 'd1)) || (r_square == (util_square << 1))) begin
                        right_edge_complete <= 1'b1;
                        right_edge <= mid;
                    end else if (r_square < (util_square << 1)) begin // ?( R^2 - 2Y^2 = 0 )
                        high <= mid;
                    end else begin
                        low <= mid;
                    end
                end
            end
        end else if (mode == 1'b1) begin 
            if ((~rst) || set) begin
                high <= high_init; // initilize large side of interval
                low <= low_init; // initialize small side of interval
                r2subx2_reg <= r_square;
                y_ans <= 'd0;
                complete <= 1'b0;
                clk_slow <= 'd0;
                util <= x_in;
                state <= 2'd1;
            end else begin
                clk_slow <= clk_slow + 1;
                if (state == 2'd1) begin
                    r2subx2_reg <= r_square - util_square;
                end else begin
                    util <= mid;
                end
                if (&clk_slow[(bit_slow-1):0]) begin
                    if (state == 2'd1) begin
                        state <= 2'd2;
                    end else if ((high <= (low + 'd1)) || (r2subx2_reg == util_square)) begin
                        complete <= 1'b1;
                        y_ans <= mid;
                    end else if (r2subx2_reg < util_square) begin // ?( R^2 - X^2 - Y^2 = 0 )
                        high <= mid;
                    end else begin
                        low <= mid;
                    end
                end
            end
        end
    end
        
endmodule



module bisection_64bit #(
    parameter division_ratio = 32
    )(
    clk,
    rst,
    set, 
    high_init, 
    low_init, 
    x_in,
    y_ans,
    complete    
    );
    // compute y_ans satisfying f(y)=R^2-x^2-y^2=0 by bisection method with initial interval of [low, high]
    
    parameter Nh = 64;
    
    input clk, rst, set;
    input [(Nh-1):0] high_init, low_init;
    input [(Nh-1):0] x_in;
    output reg [(Nh-1):0] y_ans;
    output reg complete;
    
    (* mark_debug = "true" *) reg [(Nh-1):0] high;
    (* mark_debug = "true" *) reg [(Nh-1):0] low;
    (* mark_debug = "true" *) wire [(Nh-1):0] mid;
    assign mid = (high >> 1) + (low >> 1) + (high[0] | low[0]); // round((high + low)/2)
    (* mark_debug = "true" *) reg [(2*Nh-1):0] r2subx2_reg;
    wire [(2*Nh-1):0] high_square, low_square;
    (* mark_debug = "true" *) wire [(2*Nh-1):0] mid_square; 
    wire [(2*Nh-1):0] r_square, x_square;
    assign r_square = 'd1 << (2*Nh-2);
    square_karatsuba_64bit square_x(x_in, x_square);
    
    square_karatsuba_64bit square_high(high, high_square);
    square_karatsuba_64bit square_low(low, low_square);
    square_karatsuba_64bit square_mid(mid, mid_square);
    
    reg [15:0] clk_slow;
    //parameter division_ratio = 32;
    parameter bit_slow = $clog2(division_ratio+1);
    
    always @(posedge clk or negedge rst) begin
        if ((!rst) || set) begin
            high <= high_init; // initilize large side of interval
            low <= low_init; // initialize small side of interval
            r2subx2_reg <= r_square - x_square; // hold x_ when initializing
            y_ans <= 'd0;
            complete <= 1'b0;
            clk_slow <= 'd0;
        end else begin
            clk_slow <= clk_slow + 1;
            if (&clk_slow[(bit_slow-1):0]) begin
                if ((high <= (low + 'd1)) || (r2subx2_reg == mid_square)) begin
                    complete <= 1'b1;
                    y_ans <= mid;
                end else if (r2subx2_reg < mid_square) begin // ?( R^2 - X^2 - Y^2 = 0 )
                    high <= mid;
                end else begin
                    low <= mid;
                end
            end
        end
    end
        
endmodule



module bisection_1overSqrt2_64bit #(
    parameter division_ratio = 32
    )(
    clk,
    rst,
    ans,
    complete    
    );
    // compute R/sqrt(2) by bisection method with initial interval of [R/2, R]
    
    parameter Nh = 64;
    
    input clk, rst;
    output reg [(Nh-1):0] ans;
    output reg complete;
    
    (* mark_debug = "true" *) reg [(Nh-1):0] high;
    (* mark_debug = "true" *) reg [(Nh-1):0] low;
    (* mark_debug = "true" *) wire [(Nh-1):0] mid;
    assign mid = ((high + low) >> 1) + (high[0] ^ low[0]); // round((high + low)/2)
    //assign mid = (high >> 1) + (low >> 1) + (high[0] | low[0]); // round((high + low)/2)
    wire [(2*Nh-1):0] high_square, low_square; 
    (* mark_debug = "true" *) wire [(2*Nh-1):0] mid_square;
    wire [(2*Nh-1):0] r_square = 'd1 << (2*Nh-2);
    //assign r_square = 'd1 << (2*Nh-2);
    square_karatsuba_64bit square_high(high, high_square);
    square_karatsuba_64bit square_low(low, low_square);
    square_karatsuba_64bit square_mid(mid, mid_square);
    
    reg [15:0] clk_slow;
    //parameter division_ratio = 32;
    parameter bit_slow = $clog2(division_ratio+1);
    
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            clk_slow <= 'd0;
        end else begin
            clk_slow <= clk_slow + 1;
        end
    end
    
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            high <= 'd1 << (Nh-1); // initial value R
            low <= 'd1 << (Nh-2); // R/2
            ans <= 'd0;
            complete <= 1'b0;
        end else if (&clk_slow[(bit_slow-1):0]) begin
            if ((high <= (low + 'd1)) || (r_square == (mid_square << 1))) begin
                complete <= 1'b1;
                ans <= mid;
            end else if (r_square < (mid_square << 1)) begin // ?( R^2 - 2Y^2 = 0 )
                high <= mid;
            end else begin
                low <= mid;
            end
        end
    end
        
endmodule



module bisection_32bit #(
    parameter division_ratio = 32
    )(
    clk,
    rst,
    set, 
    high_init, 
    low_init, 
    x_in,
    y_ans,
    complete    
    );
    // compute y_ans satisfying f(y)=R^2-x^2-y^2=0 by bisection method with initial interval of [low, high]
    
    parameter Nh = 32;
    
    input clk, rst, set;
    input [(Nh-1):0] high_init, low_init;
    input [(Nh-1):0] x_in;
    output reg [(Nh-1):0] y_ans;
    output reg complete;
    
    (* mark_debug = "true" *) reg [(Nh-1):0] high;
    (* mark_debug = "true" *) reg [(Nh-1):0] low;
    (* mark_debug = "true" *) wire [(Nh-1):0] mid;
    assign mid = (high >> 1) + (low >> 1) + (high[0] ^ low[0]); // round((high + low)/2)
    reg [(2*Nh-1):0] r2subx2_reg;
    wire [(2*Nh-1):0] high_square, low_square;
    (* mark_debug = "true" *) wire [(2*Nh-1):0] mid_square; 
    wire [(2*Nh-1):0] r_square, x_square;
    assign r_square = 'd1 << (2*Nh-2);
    square_karatsuba_32bit square_x(x_in, x_square);
    
    square_karatsuba_32bit square_high(high, high_square);
    square_karatsuba_32bit square_low(low, low_square);
    square_karatsuba_32bit square_mid(mid, mid_square);
    
    reg [15:0] clk_slow;
    //parameter division_ratio = 32;
    parameter bit_slow = $clog2(division_ratio+1);
    
    always @(posedge clk or negedge rst) begin
        if ((!rst) || set) begin
            high <= high_init; // initilize large side of interval
            low <= low_init; // initialize small side of interval
            r2subx2_reg <= r_square - x_square; // hold x_ when initializing
            y_ans <= 'd0;
            complete <= 1'b0;
            clk_slow <= 'd0;
        end else begin
            clk_slow <= clk_slow + 1;
            if (&clk_slow[(bit_slow-1):0]) begin
                if (((high-low) <= 'd1) || (r2subx2_reg == mid_square)) begin
                    complete <= 1'b1;
                    y_ans <= mid;
                end else if (r2subx2_reg < mid_square) begin // ?( R^2 - X^2 - Y^2 = 0 )
                    high <= mid;
                end else begin
                    low <= mid;
                end
            end
        end
    end
        
endmodule


module bisection_1overSqrt2_32bit #(
    parameter division_ratio = 32
    )(
    clk,
    rst,
    ans,
    complete    
    );
    // compute R/sqrt(2) by bisection method with initial interval of [R/2, R]
    
    parameter Nh = 32;
    
    input clk, rst;
    output reg [(Nh-1):0] ans;
    output reg complete;
    
    (* mark_debug = "true" *) reg [(Nh-1):0] high;
    (* mark_debug = "true" *) reg [(Nh-1):0] low;
    (* mark_debug = "true" *) wire [(Nh-1):0] mid;
    //assign mid = ((high + low) >> 1) + (high[0] ^ low[0]); // round((high + low)/2)
    assign mid = (high >> 1) + (low >> 1) + (high[0] ^ low[0]); // round((high + low)/2)
    wire [(2*Nh-1):0] high_square, low_square; 
    (* mark_debug = "true" *) wire [(2*Nh-1):0] mid_square;
    wire [(2*Nh-1):0] r_square = 'd1 << (2*Nh-2);
    //assign r_square = 'd1 << (2*Nh-2);
    square_karatsuba_32bit square_high(high, high_square);
    square_karatsuba_32bit square_low(low, low_square);
    square_karatsuba_32bit square_mid(mid, mid_square);
    
    reg [15:0] clk_slow;
    //parameter division_ratio = 32;
    parameter bit_slow = $clog2(division_ratio+1);
    
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            clk_slow <= 'd0;
        end else begin
            clk_slow <= clk_slow + 1;
        end
    end
    
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            high <= 'd1 << (Nh-1); // initial value R
            low <= 'd1 << (Nh-2); // R/2
            ans <= 'd0;
            complete <= 1'b0;
        end else if (&clk_slow[(bit_slow-1):0]) begin
            if (((high-low) <= 'd1) || (r_square == (mid_square << 1))) begin
                complete <= 1'b1;
                ans <= mid;
            end else if (r_square < (mid_square << 1)) begin // ?( R^2 - 2Y^2 = 0 )
                high <= mid;
            end else begin
                low <= mid;
            end
        end
    end
        
endmodule


module bisection_16bit(
    clk,
    rst,
    set, 
    high_init, 
    low_init, 
    x_in,
    y_ans,
    complete    
    );
    // compute y_ans satisfying f(y)=R^2-x^2-y^2=0 by bisection method with initial interval of [low, high]
    
    parameter Nh = 16;
    
    input clk, rst, set;
    input [(Nh-1):0] high_init, low_init;
    input [(Nh-1):0] x_in;
    output reg [(Nh-1):0] y_ans;
    output reg complete;
    
    reg [(Nh-1):0] high, low;
    wire [(Nh-1):0] mid;
    assign mid = (high >> 1) + (low >> 1) + (high[0] ^ low[0]); // round((high + low)/2)
    reg [(2*Nh-1):0] r2subx2_reg;
    wire [(2*Nh-1):0] high_square, low_square, mid_square;
    wire [(2*Nh-1):0] r_square, x_square;
    assign r_square = 'd1 << (2*Nh-2);
    square_karatsuba_16bit square_x(x_in, x_square);
    
    square_karatsuba_16bit square_high(high, high_square);
    square_karatsuba_16bit square_low(low, low_square);
    square_karatsuba_16bit square_mid(mid, mid_square);
    
    always @(posedge clk or negedge rst) begin
        if ((!rst) || set) begin
            high <= high_init; // initilize large side of interval
            low <= low_init; // initialize small side of interval
            r2subx2_reg <= r_square - x_square; // hold x_ when initializing
            y_ans <= 'd0;
            complete <= 1'b0;
        end else begin
            if (((high-low) <= 'd1) || (r2subx2_reg == mid_square)) begin
                complete <= 1'b1;
                y_ans <= mid;
            end else if (r2subx2_reg < mid_square) begin // ?( R^2 - X^2 - Y^2 = 0 )
                high <= mid;
            end else begin
                low <= mid;
            end
        end
    end
        
endmodule


module bisection_1overSqrt2_16bit(
    clk,
    rst,
    ans,
    complete    
    );
    // compute R/sqrt(2) by bisection method with initial interval of [R/2, R]
    
    parameter Nh = 16;
    
    input clk, rst;
    output reg [(Nh-1):0] ans;
    output reg complete;
    
    reg [(Nh-1):0] high, low;
    wire [(Nh-1):0] mid;
    assign mid = ((high + low) >> 1) + (high[0] ^ low[0]); // round((high + low)/2)
    wire [(2*Nh-1):0] high_square, low_square, mid_square;
    wire [(2*Nh-1):0] r_square;
    assign r_square = 'd1 << (2*Nh-2);
    square_karatsuba_16bit square_high(high, high_square);
    square_karatsuba_16bit square_low(low, low_square);
    square_karatsuba_16bit square_mid(mid, mid_square);
    
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            high <= 'd1 << (Nh-1); // initial value R
            low <= 'd1 << (Nh-2); // R/2
            ans <= 'd0;
            complete <= 1'b0;
        end else begin
            if (((high-low) <= 'd1) || (r_square == (mid_square << 1))) begin
                complete <= 1'b1;
                ans <= mid;
            end else if (r_square < (mid_square << 1)) begin // ?( R^2 - 2Y^2 = 0 )
                high <= mid;
            end else begin
                low <= mid;
            end
        end
    end
        
endmodule
