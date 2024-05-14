module relu (
    input  signed [7:0] data_in [15:0],
    output logic  [7:0] data_out[15:0]
);

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin : relu_loop
            always_comb begin
                if (data_in[i] > 0) data_out[i] = data_in[i];
                else data_out[i] = 0;
            end
        end
    endgenerate

endmodule
