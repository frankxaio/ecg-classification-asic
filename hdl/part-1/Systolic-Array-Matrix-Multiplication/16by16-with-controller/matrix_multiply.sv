module matrix_multiply #(
    parameter MATRIX_SIZE = 16,
    DATA_SIZE = 8,
    AVOID = 20
) (
    input logic [DATA_SIZE-1:0] in_a[MATRIX_SIZE-1:0],
    input logic [DATA_SIZE-1:0] in_b[MATRIX_SIZE-1:0],
    input logic reset,
    clk,
    output logic [DATA_SIZE-1:0] out_matrix[MATRIX_SIZE*MATRIX_SIZE-1:0],
    output logic done
);

    logic [DATA_SIZE-1:0] row_wire[MATRIX_SIZE*MATRIX_SIZE-1+AVOID:0];
    logic [DATA_SIZE-1:0] col_wire[MATRIX_SIZE*MATRIX_SIZE-1+AVOID:0];
    logic [$clog2(MATRIX_SIZE*MATRIX_SIZE):0] count;
    logic [5:0] prev_out_matrix_bits;  // Store the last 6 bits of prev_out_matrix

    // add all the blocks which are not connected directly to the inputs
    genvar i, j;
    generate
        // iterate over rows
        for (i = 1; i < MATRIX_SIZE; i++) begin
            //iterate over columns
            for (j = 1; j < MATRIX_SIZE; j++) begin
                // MATRIX_SIZE = 3, in_wire_count = 2*2+2 = 6, out_wire_count = 2*3+2 = 8
                localparam in_wire_count = MATRIX_SIZE * i + j;
                localparam out_wire_count = MATRIX_SIZE * (i + 1) + j;
                    mac_unit #(
                        .DATA_SIZE(DATA_SIZE)
                    ) mu (
                        .in_a(row_wire[in_wire_count]),
                        .in_b(col_wire[in_wire_count]),
                        .out_a(row_wire[in_wire_count+1]),
                        .out_b(col_wire[out_wire_count]),
                        .out_sum(out_matrix[in_wire_count]),
                        .reset(reset),
                        .clk(clk)
                    );
            end
        end

        // now generate 1st row of each col except top right block
        for (i = 1; i < MATRIX_SIZE; i++) begin
            localparam in_wire_count = MATRIX_SIZE * i;
            localparam out_wire_count = MATRIX_SIZE * (i + 1);
            mac_unit #(
                .DATA_SIZE(DATA_SIZE)
            ) mu_row (
                .in_a(row_wire[i]),
                .in_b(in_b[i]),
                .out_a(row_wire[i+1]),
                .out_b(col_wire[i+MATRIX_SIZE]),
                .out_sum(out_matrix[i]),
                .reset(reset),
                .clk(clk)
            );
        end

        // now generate 1st col of each row except top right block
        for (j = 1; j < MATRIX_SIZE; j++) begin
            localparam in_wire_count = MATRIX_SIZE * j;
            mac_unit #(
                .DATA_SIZE(DATA_SIZE)
            ) mu_col (
                .in_a(in_a[j]),
                .in_b(col_wire[in_wire_count]),
                .out_a(row_wire[in_wire_count+1]),
                .out_b(col_wire[in_wire_count+MATRIX_SIZE]),
                .out_sum(out_matrix[in_wire_count]),
                .reset(reset),
                .clk(clk)
            );
        end

        // now add the top left block
        mac_unit #(
            .DATA_SIZE(DATA_SIZE)
        ) mu_top (
            .in_a(in_a[0]),
            .in_b(in_b[0]),
            .out_a(row_wire[1]),
            .out_b(col_wire[MATRIX_SIZE]),
            .out_sum(out_matrix[0]),
            .reset(reset),
            .clk(clk)
        );
    endgenerate

    // Counter for tracking computation progress
    always_ff @(posedge clk or posedge reset) begin
        if (reset) count <= 0;
        else if (count < MATRIX_SIZE * MATRIX_SIZE) count <= count + 1;
    end

    // Store the last 6 bits of prev_out_matrix
    always_ff @(posedge clk or posedge reset) begin
        if (reset) prev_out_matrix_bits <= 6'b0;
        else prev_out_matrix_bits <= out_matrix[MATRIX_SIZE*MATRIX_SIZE-1][5:0];
    end

    // Assert done signal when the last 6 bits of out_matrix doesn't change
    always_ff @(posedge clk or posedge reset) begin
        if (reset) done <= 0;
        else done <= (out_matrix[MATRIX_SIZE*MATRIX_SIZE-1][5:0] == prev_out_matrix_bits);
    end

endmodule
