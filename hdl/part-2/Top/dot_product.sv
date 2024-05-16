module dot_product (
    input clk,
    input rst,
    input signed [7:0] ecg_input[0:14],  //! Q4.4 format
    input signed [7:0] wt[0:15],  //! Q4.4 format
    input signed [7:0] bias[0:15],  //! Q4.4 format
    input signed [7:0] ps_wt[0:255],
    input signed [7:0] cls_token[0:15],  //! Q4.4 format
    output logic signed [7:0] result[0:15][0:15],  //! Q4.4 format
    output logic done
);

    // State enum
    typedef enum {
        IDLE,
        CALC,
        CONCA,
        PS,
        DONE_PULSE
    } state_t;

    state_t state, next_state;
    logic [4:0] i, j;
    logic signed [15:0] mul_result;
    logic signed [7:0] temp_result;
    logic signed [7:0] result_reg[0:14][0:15];
    logic signed [7:0] result_relu_in[0:14][0:15];
    logic signed [7:0] result_relu_out[0:14][0:15];

    assign result_relu_in = result_reg;

    relu_embed relu_inst (
        .data_in (result_relu_in),
        .data_out(result_relu_out)
    );

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: next_state = (i == 14 && j == 15) ? DONE_PULSE : CALC;
            CALC: next_state = (i == 14 && j == 15) ? CONCA : CALC;
            CONCA: next_state = PS;
            PS: next_state = DONE_PULSE;
            DONE_PULSE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    assign done = (state == DONE_PULSE);

    // Counters
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 4'b0;
            j <= 4'b0;
        end else begin
            case (state)
                CALC: begin
                    if (j < 15) begin
                        i <= i;
                        j <= j + 1;
                    end else if (i < 14) begin
                        i <= i + 1;
                        j <= 4'b0;
                    end
                end
                DONE_PULSE: begin
                    i <= 0;
                    j <= 0;
                end
            endcase
        end
    end

    // Multiplication result
    always_comb begin
        mul_result = $signed(ecg_input[i]) * $signed(wt[j]);  // Q8.8 format
    end

    // Temporary result
    always_ff @(posedge clk or posedge rst) begin
        if (rst) temp_result <= 0;
        else begin
            case (state)
                CALC: temp_result <= mul_result[11:4] + $signed(bias[j]);
                default: temp_result <= temp_result;
            endcase
        end
    end

    // Result register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) result_reg <= '{default: 0};
        else begin
            case (state)
                CALC: result_reg[i][j] <= temp_result;
                default: result_reg <= result_reg;
            endcase
        end
    end

    // Result concatenation
    integer k, m;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) result <= '{default: 0};
        else begin
            case (state)
                CONCA: begin
                    for (k = 0; k < 15; k++) begin
                        for (m = 0; m < 16; m++) begin
                            result[k][m] <= result_relu_out[k][m];
                        end
                    end
                    for (k = 0; k < 16; k++) result[15][k] <= cls_token[k];
                end
                default: result <= result;
                PS: begin
                    for (k = 0; k < 16; k++) begin
                        for (m = 0; m < 16; m++) begin
                            result[k][m] <= result[k][m] + ps_wt[k*16+m];
                        end
                    end
                end
            endcase
        end
    end

endmodule
