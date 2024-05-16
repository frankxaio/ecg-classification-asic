module dot_product (
    input                     clk,
    input                     rst,
    input  signed       [7:0] ecg_input[0:14],        //! Q4.4 format
    input  signed       [7:0] wt       [0:15],        //! Q4.4 format
    input  signed       [7:0] bias     [0:15],        //! Q4.4 format
    input  signed       [7:0] cls_token[0:15],        //! Q4.4 format
    output logic signed [7:0] result   [0:15][0:15],  //! Q4.4 format
    output logic              done
);

    // State enum
    typedef enum {
        IDLE,
        CALC,
        CONCA,
        DONE_PULSE
    } state_t;

    state_t state, next_state;
    logic [4:0] i, j, i_next, j_next;
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
        if (rst) begin
            state <= IDLE;
            i <= 4'b0;
            j <= 4'b0;
        end else begin
            state <= next_state;
            i <= i_next;
            j <= j_next;
        end
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: begin
                if (i == 14 && j == 15) begin
                    next_state = DONE_PULSE;
                end else begin
                    next_state = CALC;
                end
            end
            CALC: begin
                if (i == 14 && j == 15) begin
                    next_state = CONCA;
                end else begin
                    next_state = CALC;
                end
            end
            CONCA: begin
                next_state = DONE_PULSE;
            end
            DONE_PULSE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        done = (state == DONE_PULSE);
    end

    // Calculation logic
    always_comb begin
        case (state)
            IDLE: begin
                i_next = 4'b0;
                j_next = 4'b0;
            end
            CALC: begin
                mul_result = $signed(ecg_input[i]) * $signed(wt[j]);  // Q8.8 format
                temp_result = mul_result[11:4] + $signed(bias[j]);
                result_reg[i][j] = temp_result;  // Take the middle 8 bits for Q4.4 format

                if (j < 15) begin
                    i_next = i;
                    j_next = j + 1;
                end else if (i < 14) begin
                    i_next = i + 1;
                    j_next = 4'b0;
                end else begin
                    i_next = i;
                    j_next = j;
                end
            end
            CONCA: begin
                integer k, m;
                for (k = 0; k < 15; k++) begin
                    for (m = 0; m < 16; m++) begin
                        result[k][m] = result_relu_out[k][m];
                    end
                end
                for (k = 0; k < 16; k++) result[15][k] = cls_token[k];
            end
            DONE_PULSE: begin
                i_next = 0;
                j_next = 0;
            end
            default: begin
                i_next = i;
                j_next = j;
            end
        endcase
    end

endmodule
