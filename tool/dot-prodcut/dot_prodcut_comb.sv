module dot_product_comb (
    input clk,
    input rst,
    input signed [7:0] mat_a[0:14],
    input signed [7:0] mat_b[0:15],
    output signed [7:0] result[0:14][0:15]
);

    // 矩陣乘法 size[15,1] * size[1,16] = size[15,16]
    generate
        for (genvar i = 0; i < 15; i = i + 1) begin
            for (genvar j = 0; j<16; j = j +1) begin
                assign result[i][j] = mat_a[i] * mat_b[i];
            end
        end
    endgenerate


endmodule
