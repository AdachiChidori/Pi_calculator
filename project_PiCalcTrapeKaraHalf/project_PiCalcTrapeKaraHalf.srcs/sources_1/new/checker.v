// not used
module checker(
    clk,
    rst,
    accum_enable,
    x_LSB,
    x_square_LSB, 
    check
    );
    
    input clk, rst, accum_enable, x_LSB, x_square_LSB;
    output reg check;
    reg accum_enable_old, x_LSB_old, x_square_LSB_old;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            accum_enable_old <= accum_enable;
            x_LSB_old <= x_LSB;
            x_square_LSB_old <= x_square_LSB;
            check <= 1'b1;
        end else begin
            if (accum_enable || !check) begin
                check <= (x_LSB_old != x_LSB) && (x_square_LSB_old != x_square_LSB);
            end else begin
                check <= 1'b1;
                x_LSB_old <= x_LSB;
                x_square_LSB_old <= x_square_LSB;
                accum_enable_old <= accum_enable;
            end
        end
    end
    
endmodule
