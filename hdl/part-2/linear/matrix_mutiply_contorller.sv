module matrix_multiply_controller #(
    parameter MATRIX_SIZE = 16,
    DATA_SIZE = 8
) (
    input logic clk,
    input logic reset,
    input logic start,
    output logic done,
    input logic [DATA_SIZE-1:0] in_store_a[MATRIX_SIZE-1:0][MATRIX_SIZE-1:0],
    input logic [DATA_SIZE-1:0] in_store_b[MATRIX_SIZE-1:0][MATRIX_SIZE-1:0],
    output logic [DATA_SIZE-1:0] out_matrix[MATRIX_SIZE*MATRIX_SIZE-1:0]
);
    localparam INPUT_COUNT = MATRIX_SIZE * 2;

    logic [DATA_SIZE-1:0] in_a[MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] in_b[MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] in_a_reg[MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] in_b_reg[MATRIX_SIZE-1:0];
    logic [6:0] input_count;
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

    // Input logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            in_a_reg <= '{default: '0};
            in_b_reg <= '{default: '0};
        end else if (cs == INPUT) begin
            case (input_count)
                0: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,in_store_a[0][0]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,in_store_b[0][0]};
                end
                1: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,in_store_a[1][0],in_store_a[0][1]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,in_store_b[1][0],in_store_b[0][1]};
                end
                2: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,0,in_store_a[2][0],in_store_a[1][1],in_store_a[0][2]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,0,in_store_b[2][0],in_store_b[1][1],in_store_b[0][2]};
                end
                3: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,in_store_a[3][0],in_store_a[2][1],in_store_a[1][2],in_store_a[0][3]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,0,0,0,0,in_store_b[3][0],in_store_b[2][1],in_store_b[1][2],in_store_b[0][3]};
                end
                4: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,0,0,0,in_store_a[4][0],in_store_a[3][1],in_store_a[2][2],in_store_a[1][3],in_store_a[0][4]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,0,0,0,in_store_b[4][0],in_store_b[3][1],in_store_b[2][2],in_store_b[1][3],in_store_b[0][4]};
                end
                5: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,0,0,in_store_a[5][0],in_store_a[4][1],in_store_a[3][2],in_store_a[2][3],in_store_a[1][4],in_store_a[0][5]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,0,0,in_store_b[5][0],in_store_b[4][1],in_store_b[3][2],in_store_b[2][3],in_store_b[1][4],in_store_b[0][5]};
                end
                6: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,0,in_store_a[6][0],in_store_a[5][1],in_store_a[4][2],in_store_a[3][3],in_store_a[2][4],in_store_a[1][5],in_store_a[0][6]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,0,in_store_b[6][0],in_store_b[5][1],in_store_b[4][2],in_store_b[3][3],in_store_b[2][4],in_store_b[1][5],in_store_b[0][6]};
                end
                7: begin
                    in_a_reg <= {0,0,0,0,0,0,0,0,in_store_a[7][0],in_store_a[6][1],in_store_a[5][2],in_store_a[4][3],in_store_a[3][4],in_store_a[2][5],in_store_a[1][6],in_store_a[0][7]};
                    in_b_reg <= {0,0,0,0,0,0,0,0,in_store_b[7][0],in_store_b[6][1],in_store_b[5][2],in_store_b[4][3],in_store_b[3][4],in_store_b[2][5],in_store_b[1][6],in_store_b[0][7]};
                end
                8: begin
                    in_a_reg <= {0,0,0,0,0,0,0,in_store_a[8][0],in_store_a[7][1],in_store_a[6][2],in_store_a[5][3],in_store_a[4][4],in_store_a[3][5],in_store_a[2][6],in_store_a[1][7],in_store_a[0][8]};
                    in_b_reg <= {0,0,0,0,0,0,0,in_store_b[8][0],in_store_b[7][1],in_store_b[6][2],in_store_b[5][3],in_store_b[4][4],in_store_b[3][5],in_store_b[2][6],in_store_b[1][7],in_store_b[0][8]};
                end
                9: begin
                    in_a_reg <= {0,0,0,0,0,0,in_store_a[9][0],in_store_a[8][1],in_store_a[7][2],in_store_a[6][3],in_store_a[5][4],in_store_a[4][5],in_store_a[3][6],in_store_a[2][7],in_store_a[1][8],in_store_a[0][9]};
                    in_b_reg <= {0,0,0,0,0,0,in_store_b[9][0],in_store_b[8][1],in_store_b[7][2],in_store_b[6][3],in_store_b[5][4],in_store_b[4][5],in_store_b[3][6],in_store_b[2][7],in_store_b[1][8],in_store_b[0][9]};
                end
                10: begin
                    in_a_reg <= {0,0,0,0,0,in_store_a[10][0],in_store_a[9][1],in_store_a[8][2],in_store_a[7][3],in_store_a[6][4],in_store_a[5][5],in_store_a[4][6],in_store_a[3][7],in_store_a[2][8],in_store_a[1][9],in_store_a[0][10]};
                    in_b_reg <= {0,0,0,0,0,in_store_b[10][0],in_store_b[9][1],in_store_b[8][2],in_store_b[7][3],in_store_b[6][4],in_store_b[5][5],in_store_b[4][6],in_store_b[3][7],in_store_b[2][8],in_store_b[1][9],in_store_b[0][10]};
                end
                11: begin
                    in_a_reg <= {0,0,0,0,in_store_a[11][0],in_store_a[10][1],in_store_a[9][2],in_store_a[8][3],in_store_a[7][4],in_store_a[6][5],in_store_a[5][6],in_store_a[4][7],in_store_a[3][8],in_store_a[2][9],in_store_a[1][10],in_store_a[0][11]};
                    in_b_reg <= {0,0,0,0,in_store_b[11][0],in_store_b[10][1],in_store_b[9][2],in_store_b[8][3],in_store_b[7][4],in_store_b[6][5],in_store_b[5][6],in_store_b[4][7],in_store_b[3][8],in_store_b[2][9],in_store_b[1][10],in_store_b[0][11]};
                end
                12: begin
                    in_a_reg <= {0,0,0,in_store_a[12][0],in_store_a[11][1],in_store_a[10][2],in_store_a[9][3],in_store_a[8][4],in_store_a[7][5],in_store_a[6][6],in_store_a[5][7],in_store_a[4][8],in_store_a[3][9],in_store_a[2][10],in_store_a[1][11],in_store_a[0][12]};
                    in_b_reg <= {0,0,0,in_store_b[12][0],in_store_b[11][1],in_store_b[10][2],in_store_b[9][3],in_store_b[8][4],in_store_b[7][5],in_store_b[6][6],in_store_b[5][7],in_store_b[4][8],in_store_b[3][9],in_store_b[2][10],in_store_b[1][11],in_store_b[0][12]};
                end
                13: begin
                    in_a_reg <= {0,0,in_store_a[13][0],in_store_a[12][1],in_store_a[11][2],in_store_a[10][3],in_store_a[9][4],in_store_a[8][5],in_store_a[7][6],in_store_a[6][7],in_store_a[5][8],in_store_a[4][9],in_store_a[3][10],in_store_a[2][11],in_store_a[1][12],in_store_a[0][13]};
                    in_b_reg <= {0,0,in_store_b[13][0],in_store_b[12][1],in_store_b[11][2],in_store_b[10][3],in_store_b[9][4],in_store_b[8][5],in_store_b[7][6],in_store_b[6][7],in_store_b[5][8],in_store_b[4][9],in_store_b[3][10],in_store_b[2][11],in_store_b[1][12],in_store_b[0][13]};
                end
                14: begin
                    in_a_reg <= {0,in_store_a[14][0],in_store_a[13][1],in_store_a[12][2],in_store_a[11][3],in_store_a[10][4],in_store_a[9][5],in_store_a[8][6],in_store_a[7][7],in_store_a[6][8],in_store_a[5][9],in_store_a[4][10],in_store_a[3][11],in_store_a[2][12],in_store_a[1][13],in_store_a[0][14]};
                    in_b_reg <= {0,in_store_b[14][0],in_store_b[13][1],in_store_b[12][2],in_store_b[11][3],in_store_b[10][4],in_store_b[9][5],in_store_b[8][6],in_store_b[7][7],in_store_b[6][8],in_store_b[5][9],in_store_b[4][10],in_store_b[3][11],in_store_b[2][12],in_store_b[1][13],in_store_b[0][14]};
                end
                15: begin
                    in_a_reg <= {in_store_a[15][0],in_store_a[14][1],in_store_a[13][2],in_store_a[12][3],in_store_a[11][4],in_store_a[10][5],in_store_a[9][6],in_store_a[8][7],in_store_a[7][8],in_store_a[6][9],in_store_a[5][10],in_store_a[4][11],in_store_a[3][12],in_store_a[2][13],in_store_a[1][14],in_store_a[0][15]};
                    in_b_reg <= {in_store_b[15][0],in_store_b[14][1],in_store_b[13][2],in_store_b[12][3],in_store_b[11][4],in_store_b[10][5],in_store_b[9][6],in_store_b[8][7],in_store_b[7][8],in_store_b[6][9],in_store_b[5][10],in_store_b[4][11],in_store_b[3][12],in_store_b[2][13],in_store_b[1][14],in_store_b[0][15]};
                end
                16: begin
                    in_a_reg <= {in_store_a[15][1],in_store_a[14][2],in_store_a[13][3],in_store_a[12][4],in_store_a[11][5],in_store_a[10][6],in_store_a[9][7],in_store_a[8][8],in_store_a[7][9],in_store_a[6][10],in_store_a[5][11],in_store_a[4][12],in_store_a[3][13],in_store_a[2][14],in_store_a[1][15],0};
                    in_b_reg <= {in_store_b[15][1],in_store_b[14][2],in_store_b[13][3],in_store_b[12][4],in_store_b[11][5],in_store_b[10][6],in_store_b[9][7],in_store_b[8][8],in_store_b[7][9],in_store_b[6][10],in_store_b[5][11],in_store_b[4][12],in_store_b[3][13],in_store_b[2][14],in_store_b[1][15],0};
                end
                17: begin
                    in_a_reg <= {in_store_a[15][2],in_store_a[14][3],in_store_a[13][4],in_store_a[12][5],in_store_a[11][6],in_store_a[10][7],in_store_a[9][8],in_store_a[8][9],in_store_a[7][10],in_store_a[6][11],in_store_a[5][12],in_store_a[4][13],in_store_a[3][14],in_store_a[2][15],0,0};
                    in_b_reg <= {in_store_b[15][2],in_store_b[14][3],in_store_b[13][4],in_store_b[12][5],in_store_b[11][6],in_store_b[10][7],in_store_b[9][8],in_store_b[8][9],in_store_b[7][10],in_store_b[6][11],in_store_b[5][12],in_store_b[4][13],in_store_b[3][14],in_store_b[2][15],0,0};
                end
                18: begin
                    in_a_reg <= {in_store_a[15][3],in_store_a[14][4],in_store_a[13][5],in_store_a[12][6],in_store_a[11][7],in_store_a[10][8],in_store_a[9][9],in_store_a[8][10],in_store_a[7][11],in_store_a[6][12],in_store_a[5][13],in_store_a[4][14],in_store_a[3][15],0,0,0};
                    in_b_reg <= {in_store_b[15][3],in_store_b[14][4],in_store_b[13][5],in_store_b[12][6],in_store_b[11][7],in_store_b[10][8],in_store_b[9][9],in_store_b[8][10],in_store_b[7][11],in_store_b[6][12],in_store_b[5][13],in_store_b[4][14],in_store_b[3][15],0,0,0};
                end
                19: begin
                    in_a_reg <= {in_store_a[15][4],in_store_a[14][5],in_store_a[13][6],in_store_a[12][7],in_store_a[11][8],in_store_a[10][9],in_store_a[9][10],in_store_a[8][11],in_store_a[7][12],in_store_a[6][13],in_store_a[5][14],in_store_a[4][15],0,0,0,0};
                    in_b_reg <= {in_store_b[15][4],in_store_b[14][5],in_store_b[13][6],in_store_b[12][7],in_store_b[11][8],in_store_b[10][9],in_store_b[9][10],in_store_b[8][11],in_store_b[7][12],in_store_b[6][13],in_store_b[5][14],in_store_b[4][15],0,0,0,0};
                end
                20: begin
                    in_a_reg <= {in_store_a[15][5],in_store_a[14][6],in_store_a[13][7],in_store_a[12][8],in_store_a[11][9],in_store_a[10][10],in_store_a[9][11],in_store_a[8][12],in_store_a[7][13],in_store_a[6][14],in_store_a[5][15],0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][5],in_store_b[14][6],in_store_b[13][7],in_store_b[12][8],in_store_b[11][9],in_store_b[10][10],in_store_b[9][11],in_store_b[8][12],in_store_b[7][13],in_store_b[6][14],in_store_b[5][15],0,0,0,0,0};
                end
                21: begin
                    in_a_reg <= {in_store_a[15][6],in_store_a[14][7],in_store_a[13][8],in_store_a[12][9],in_store_a[11][10],in_store_a[10][11],in_store_a[9][12],in_store_a[8][13],in_store_a[7][14],in_store_a[6][15],0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][6],in_store_b[14][7],in_store_b[13][8],in_store_b[12][9],in_store_b[11][10],in_store_b[10][11],in_store_b[9][12],in_store_b[8][13],in_store_b[7][14],in_store_b[6][15],0,0,0,0,0,0};
                end
                22: begin
                    in_a_reg <= {in_store_a[15][7],in_store_a[14][8],in_store_a[13][9],in_store_a[12][10],in_store_a[11][11],in_store_a[10][12],in_store_a[9][13],in_store_a[8][14],in_store_a[7][15],0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][7],in_store_b[14][8],in_store_b[13][9],in_store_b[12][10],in_store_b[11][11],in_store_b[10][12],in_store_b[9][13],in_store_b[8][14],in_store_b[7][15],0,0,0,0,0,0,0};
                end
                23: begin
                    in_a_reg <= {in_store_a[15][8],in_store_a[14][9],in_store_a[13][10],in_store_a[12][11],in_store_a[11][12],in_store_a[10][13],in_store_a[9][14],in_store_a[8][15],0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][8],in_store_b[14][9],in_store_b[13][10],in_store_b[12][11],in_store_b[11][12],in_store_b[10][13],in_store_b[9][14],in_store_b[8][15],0,0,0,0,0,0,0,0};
                end
                24: begin
                    in_a_reg <= {in_store_a[15][9],in_store_a[14][10],in_store_a[13][11],in_store_a[12][12],in_store_a[11][13],in_store_a[10][14],in_store_a[9][15],0,0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][9],in_store_b[14][10],in_store_b[13][11],in_store_b[12][12],in_store_b[11][13],in_store_b[10][14],in_store_b[9][15],0,0,0,0,0,0,0,0,0};
                end
                25: begin
                    in_a_reg <= {in_store_a[15][10],in_store_a[14][11],in_store_a[13][12],in_store_a[12][13],in_store_a[11][14],in_store_a[10][15],0,0,0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][10],in_store_b[14][11],in_store_b[13][12],in_store_b[12][13],in_store_b[11][14],in_store_b[10][15],0,0,0,0,0,0,0,0,0,0};
                end
                26: begin
                    in_a_reg <= {in_store_a[15][11],in_store_a[14][12],in_store_a[13][13],in_store_a[12][14],in_store_a[11][15],0,0,0,0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][11],in_store_b[14][12],in_store_b[13][13],in_store_b[12][14],in_store_b[11][15],0,0,0,0,0,0,0,0,0,0,0};
                end
                27: begin
                    in_a_reg <= {in_store_a[15][12],in_store_a[14][13],in_store_a[13][14],in_store_a[12][15],0,0,0,0,0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][12],in_store_b[14][13],in_store_b[13][14],in_store_b[12][15],0,0,0,0,0,0,0,0,0,0,0,0};
                end
                28: begin
                    in_a_reg <= {in_store_a[15][13],in_store_a[14][14],in_store_a[13][15],0,0,0,0,0,0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][13],in_store_b[14][14],in_store_b[13][15],0,0,0,0,0,0,0,0,0,0,0,0,0};
                end
                29: begin
                    in_a_reg <= {in_store_a[15][14],in_store_a[14][15],0,0,0,0,0,0,0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][14],in_store_b[14][15],0,0,0,0,0,0,0,0,0,0,0,0,0,0};
                end
                30: begin
                    in_a_reg <= {in_store_a[15][15],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
                    in_b_reg <= {in_store_b[15][15],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
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
                    input_count <= 0;
                    done <= 1;
                end
                default: begin
                    done <= 0;
                    input_count <= input_count;
                end
            endcase
        end
    end

endmodule