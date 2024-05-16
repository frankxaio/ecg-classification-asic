module relu_embed #(
    parameter DATA_WIDTH = 8,
    MATRIX_SIZE_1 = 15,
    MATRIX_SIZE_2 = 16
) (
    input  signed [DATA_WIDTH-1:0] data_in [0:MATRIX_SIZE_1-1][0:MATRIX_SIZE_2-1],
    output logic signed  [DATA_WIDTH-1:0] data_out[0:MATRIX_SIZE_1-1][0:MATRIX_SIZE_2-1]
);

    genvar i, j;
    generate
        for (i = 0; i < MATRIX_SIZE_1; i++) begin : relu_loop
            for (j = 0; j < MATRIX_SIZE_2; j++) begin
                always_comb begin
                    if (data_in[i][j] > 0) data_out[i][j] = data_in[i][j];
                    else data_out[i][j] = 0;
                end
            end
        end
    endgenerate

endmodule
