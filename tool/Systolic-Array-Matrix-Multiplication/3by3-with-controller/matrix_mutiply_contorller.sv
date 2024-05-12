module matrix_multiply_controller #(
    parameter MATRIX_SIZE = 3,
    DATA_SIZE = 8,
    INPUT_COUNT = MATRIX_SIZE * MATRIX_SIZE
) (
    input logic clk,
    input logic reset,
    input logic start,
    output logic done,
    input logic [DATA_SIZE-1:0] in_store_a[MATRIX_SIZE-1:0][MATRIX_SIZE-1:0],
    input logic [DATA_SIZE-1:0] in_store_b[MATRIX_SIZE-1:0][MATRIX_SIZE-1:0],
    output logic [DATA_SIZE-1:0] out_matrix[MATRIX_SIZE*MATRIX_SIZE-1:0]
);

    logic [DATA_SIZE-1:0] in_a[MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] in_b[MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] in_a_reg[MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] in_b_reg[MATRIX_SIZE-1:0];
    logic [$clog2(INPUT_COUNT):0] input_count;
    logic computation_done;
    logic [DATA_SIZE-1:0] out_matrix_reversed[MATRIX_SIZE*MATRIX_SIZE-1:0];

    // Instantiate the matrix multiply module
    matrix_multiply #(
        .MATRIX_SIZE(MATRIX_SIZE),
        .DATA_SIZE(DATA_SIZE)
    ) mm (
        .in_a(in_a),
        .in_b(in_b),
        .reset(reset),
        .clk(clk),
        .out_matrix(out_matrix_reversed),
        .done(computation_done)
    );

    // Reverse the output matrix
    generate
        for (genvar i = 0; i < MATRIX_SIZE * MATRIX_SIZE; i++) begin
            assign out_matrix[i] = out_matrix_reversed[MATRIX_SIZE * MATRIX_SIZE - 1 - i];
        end
    endgenerate

    // Control FSM
    enum { IDLE, INPUT, COMPUTE, DONE } cs, ns;

    // Current state register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) cs <= IDLE;
        else cs <= ns;
    end

    // Next state logic
    always_comb begin
        case (cs)
            IDLE: begin
                if (start) ns = INPUT;
                else ns = IDLE;
            end
            INPUT: begin
                if (input_count < INPUT_COUNT) ns = INPUT;
                else ns = COMPUTE;
            end
            COMPUTE: begin
                if (computation_done) ns = DONE;
                else ns = COMPUTE;
            end
            DONE: begin
                if (!start) ns = IDLE;
                else ns = DONE;
            end
            default: ns = IDLE;
        endcase
    end

    // Input logic
    always_ff @(negedge clk or posedge reset) begin
        if (reset) begin
            in_a_reg <= '{default: '0};
            in_b_reg <= '{default: '0};
        end else if (cs == INPUT) begin
            case (input_count)
                0: begin
                    in_a_reg <= {0, 0, in_store_a[0][0]};
                    in_b_reg <= {0, 0, in_store_b[0][0]};
                end
                1: begin
                    in_a_reg <= {0, in_store_a[1][0], in_store_a[0][1]};
                    in_b_reg <= {0, in_store_b[1][0], in_store_b[0][1]};
                end
                2: begin
                    in_a_reg <= {in_store_a[2][0], in_store_a[1][1], in_store_a[0][2]};
                    in_b_reg <= {in_store_b[2][0], in_store_b[1][1], in_store_b[0][2]};
                end
                3: begin
                    in_a_reg <= {in_store_a[2][1], in_store_a[1][2], 0};
                    in_b_reg <= {in_store_b[2][1], in_store_b[1][2], 0};
                end
                4: begin
                    in_a_reg <= {in_store_a[2][2], 0, 0};
                    in_b_reg <= {in_store_b[2][2], 0, 0};
                end
                default: begin
                    in_a_reg <= '{default: '0};
                    in_b_reg <= '{default: '0};
                end
            endcase
        end
    end

    // Assign in_a and in_b from in_a_reg and in_b_reg
    assign in_a = in_a_reg;
    assign in_b = in_b_reg;

    // Output logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 0;
            input_count <= 0;
        end else begin
            case (cs)
                IDLE: begin
                    done <= 0;
                    input_count <= 0;
                end
                INPUT: begin
                    input_count <= input_count + 1;
                end
                DONE: begin
                    done <= 1;
                end
            endcase
        end
    end

endmodule