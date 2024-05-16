module linear #(
    parameter MATRIX_SIZE = 16,
    DATA_SIZE = 8
) (
    input logic clk,
    input logic reset,
    input logic start,
    output logic done,
    input signed [DATA_SIZE-1:0] mat_a[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
    input signed [DATA_SIZE-1:0] wt[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
    input signed [DATA_SIZE-1:0] bias[0:MATRIX_SIZE-1],
    output logic signed [DATA_SIZE-1:0] out_matrix[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1]
    // output logic signed [DATA_SIZE-1:0] out_matrix[MATRIX_SIZE-1:0][MATRIX_SIZE-1:0]
);

    logic signed [DATA_SIZE-1:0] temp_out_matrix[MATRIX_SIZE*MATRIX_SIZE-1:0];

    matrix_multiply_controller mmu_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .in_store_a(mat_a),
        .in_store_b(wt),
        .out_matrix(temp_out_matrix)
    );

    integer i, j;
    always_comb begin
    for (i = 0; i < MATRIX_SIZE; i++) begin
            for (j = 0; j < MATRIX_SIZE; j++) begin
                out_matrix[15-i][15-j] = temp_out_matrix[i*MATRIX_SIZE+j] + bias[j];
            end
        end
    end

endmodule
