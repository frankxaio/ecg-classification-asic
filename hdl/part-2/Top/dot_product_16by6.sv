module dot_product_16by6 #(
    parameter MATRIX_SIZE = 16,
    DATA_WIDTH = 8,
    CLASSIFIER_BS_CNT = 6,
    CLASSIFIER_WT_CNT = 96
) (
    input clk,
    input rst,
    input start,
    input signed [DATA_WIDTH-1:0] mat_in[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],  //! Q4.4 format
    input signed [DATA_WIDTH-1:0] wt[0:CLASSIFIER_WT_CNT-1],  //! Q4.4 format
    input signed [DATA_WIDTH-1:0] bias[0:CLASSIFIER_BS_CNT-1],  //! Q4.4 format
    output logic [3:0] max,
    output logic done
);

    // REDUCE: [16*16] => [1,16]
    // cAL: [1*16]*[16*6] => [1,6]
    // MAX: [1,6] => [1,1]
    // State enum

    typedef enum {
        IDLE,
        REDUCE,
        CAL,
        MAX,
        DONE_PULSE
    } state_t;

    state_t state, next_state;
    logic [4:0] i, j, i_next, j_next;
    logic signed [15:0] mul_result;
    logic signed [DATA_WIDTH-1:0] temp_result;
    logic start_loc, start_loc_reg;
    logic done_reduce;
    logic signed [DATA_WIDTH-1:0] mat_out_reduce[0:MATRIX_SIZE-1];
    logic signed [DATA_WIDTH-1:0] mat_out_cal[0:CLASSIFIER_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] max_val;
    logic [3:0] max_index;


    assign start_loc = start_loc_reg;

    reduce reduce_inst (
        .clk(clk),
        .rst(rst),
        .enable(start_loc),
        .matrix_in(mat_in),
        .matrix_out(mat_out_reduce),
        .done(done_reduce)
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
                if (start) begin
                    next_state = REDUCE;
                end else begin
                    next_state = IDLE;
                end
            end
            REDUCE: begin
                start_loc_reg = 1;
                if (done_reduce) begin
                    next_state = CAL;
                end else begin
                    next_state = REDUCE;
                end
            end
            CAL: begin
                start_loc_reg = 0;
                if (j == 5) next_state = MAX;
                else next_state = CAL;
            end
            MAX: begin
                if (i == 5) next_state = DONE_PULSE;
                else next_state = MAX;
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
    integer k;
    always_comb begin
        case (state)
            IDLE: begin
                i_next = 4'b0;
                j_next = 4'b0;
            end
            CAL: begin
                // per column 
                for (k = 0; k < 16; k++)
                    mul_result = $signed(mat_out_reduce[k]) * $signed(wt[k][j]);  // Q8.8 format
                temp_result = mul_result[11:4] + $signed(bias[j]);
                mat_out_cal[j] = temp_result;  // Take the middle 8 bits for Q4.4 format
                if (j < 6) j_next = j + 1;
                else j_next = j;
                max_val   = mat_out_cal[0];
                max_index = 0;
            end
            MAX: begin
                if (mat_out_cal[i] > max_val) begin
                    max_index = i;
                    max_val   = mat_out_cal[i];
                end else begin
                    max_index = max_index;
                    max_val   = max_val;
                end

                if (i < 6) i_next = i + 1;
                else i_next = i;
            end
            DONE_PULSE: begin
                max = max_index;
                i_next = 0;
                j_next = 0;
            end
            default: begin
                max = max;
                i_next = i;
                j_next = j;
                mul_result = mul_result;
                mat_out_cal = mat_out_cal;
            end
        endcase
    end

endmodule
