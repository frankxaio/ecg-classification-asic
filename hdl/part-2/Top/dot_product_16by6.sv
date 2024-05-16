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

    typedef enum {
        IDLE,
        REDUCE,
        CAL,
        MAX,
        DONE_PULSE
    } state_t;

    state_t state, next_state;
    logic [4:0] i, j;
    logic signed [15:0] mul_result;
    logic signed [DATA_WIDTH-1:0] temp_result;
    logic start_loc;
    logic done_reduce;
    logic signed [DATA_WIDTH-1:0] mat_out_reduce[0:MATRIX_SIZE-1];
    logic signed [DATA_WIDTH-1:0] mat_out_cal[0:CLASSIFIER_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] max_val;
    logic [3:0] max_index;

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
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: next_state = start ? REDUCE : IDLE;
            REDUCE: next_state = done_reduce ? CAL : REDUCE;
            CAL: next_state = (j == 5) ? MAX : CAL;
            MAX: next_state = (i == 5) ? DONE_PULSE : MAX;
            DONE_PULSE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) done <= 1'b0;
        else begin
            case (state)
                DONE_PULSE: done <= 1'b1;
                default: done <= 1'b0;
            endcase
        end
    end

    // Start signal for reduction
    always_ff @(posedge clk or posedge rst) begin
        if (rst) start_loc <= 1'b0;
        else begin
            case (state)
                REDUCE:  start_loc <= 1'b1;
                default: start_loc <= 1'b0;
            endcase
        end
    end

    // Counters
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 4'b0;
            j <= 4'b0;
        end else begin
            case (state)
                CAL: begin
                    j <= (j < 5) ? j + 1 : j;
                    i <= i;
                end
                MAX: begin
                    i <= (i < 5) ? i + 1 : i;
                    j <= j;
                end
                DONE_PULSE: begin
                    i <= 0;
                    j <= 0;
                end
                default: begin
                    i <= i;
                    j <= j;
                end
            endcase
        end
    end

    // Calculation logic
    integer k;

    // Multiplication result
    always_comb begin
        mul_result = 16'b0;
        for (k = 0; k < 16; k++) mul_result += $signed(mat_out_reduce[k]) * $signed(wt[k+j*16]);
    end

    // Temporary result
    always_ff @(posedge clk or posedge rst) begin
        if (rst) temp_result <= 0;
        else begin
            case (state)
                CAL: temp_result <= mul_result[11:4] + $signed(bias[j]);
                default: temp_result <= temp_result;
            endcase
        end
    end

    // Output of calculation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) mat_out_cal <= '{default: 0};
        else begin
            case (state)
                CAL: mat_out_cal[j] <= temp_result;
                default: mat_out_cal <= mat_out_cal;
            endcase
        end
    end

    // Max value and index
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            max_val   <= 0;
            max_index <= 0;
        end else begin
            case (state)
                CAL: begin
                    max_val   <= mat_out_cal[0];
                    max_index <= 0;
                end
                MAX: begin
                    if (mat_out_cal[i] > max_val) begin
                        max_val   <= mat_out_cal[i];
                        max_index <= i;
                    end else begin
                        max_val   <= max_val;
                        max_index <= max_index;
                    end
                end
                default: begin
                    max_val   <= max_val;
                    max_index <= max_index;
                end
            endcase
        end
    end

    // Output max index
    always_ff @(posedge clk or posedge rst) begin
        if (rst) max <= 0;
        else begin
            case (state)
                DONE_PULSE: max <= max_index;
                default: max <= max;
            endcase
        end
    end

endmodule
