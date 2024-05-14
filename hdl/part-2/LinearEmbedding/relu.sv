module relu (
    input signed [7:0] data_in[0:14][0:15],
    output logic signed [7:0] data_out[0:14][0:15]
);

    genvar i, j;
    generate
        for (i = 0; i < 15; i++) begin : relu_loop_i
            for (j = 0; j < 16; j++) begin : relu_loop_j
                always_comb begin
                    if (data_in[i][j] > 0) data_out[i][j] = data_in[i][j][7:0];
                    else data_out[i][j] = 0;
                end
            end
        end
    endgenerate

endmodule
