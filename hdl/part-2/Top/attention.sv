module attention #(
    parameter MATRIX_SIZE = 16,
    DATA_WIDTH = 8,
    FINAL_BS_CNT = 16,
    FINAL_WT_CNT = 256,
    KEYS_BS_CNT = 16,
    KEYS_WT_CNT = 256,
    QUERIES_BS_CNT = 16,
    QUERIES_WT_CNT = 256,
    VALUES_BS_CNT = 16,
    VALUES_WT_CNT = 256
) (
    input clk,
    input rst,
    input start,
    input signed [DATA_WIDTH-1:0] final_bs[0:FINAL_BS_CNT-1],
    input signed [DATA_WIDTH-1:0] final_wt[0:FINAL_WT_CNT-1],
    input signed [DATA_WIDTH-1:0] keys_bs[0:KEYS_BS_CNT-1],
    input signed [DATA_WIDTH-1:0] keys_wt[0:KEYS_WT_CNT-1],
    input signed [DATA_WIDTH-1:0] queries_bs[0:QUERIES_BS_CNT-1],
    input signed [DATA_WIDTH-1:0] queries_wt[0:QUERIES_WT_CNT-1],
    input signed [DATA_WIDTH-1:0] values_bs[0:VALUES_BS_CNT-1],
    input signed [DATA_WIDTH-1:0] values_wt[0:VALUES_WT_CNT-1],
    input signed [DATA_WIDTH-1:0] mat_in[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
    output logic signed [DATA_WIDTH-1:0] out_matrix[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
    output logic done
);

    typedef logic signed [DATA_WIDTH-1:0] matrix_arr[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];
    typedef logic signed [DATA_WIDTH-1:0] bias_arr[0:FINAL_BS_CNT-1];
    typedef logic signed [DATA_WIDTH-1:0] wt_arr[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];

    matrix_arr
        mat_a, mat_a_reg, out_matrix_temp, q_matrix, k_matrix, v_matrix, qk_matrix, qkv_matrix;
    wt_arr wt, wt_reg;
    bias_arr bias, bias_reg;



    logic start_controller, start_controller_reg, start_in;
    logic done_cal, rst_local;

    typedef enum {
        IDLE,
        QUE,
        KEY,
        VAL,
        QK,
        QKV,
        FIN,
        DONE
    } state_t;

    state_t state, next_state;


    assign mat_a = mat_a_reg;
    assign wt = wt_reg;
    assign bias = bias_reg;
    assign start_in = (start_controller == 1);

    linear linear_inst (
        .clk(clk),
        .reset(rst_local),
        .start(start_in),
        .done(done_cal),
        .mat_a(mat_a),
        .wt(wt),
        .bias(bias),
        .out_matrix(out_matrix_temp)
    );

    always_ff @(posedge clk, posedge rst) begin
        if (rst) start_controller <= 1'b0;
        else start_controller <= start_controller_reg;
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) rst_local <= 1'b0;
        else if (state != next_state) rst_local <= 1'b1;
        else rst_local <= 1'b0;
    end


    always_ff @(posedge clk, posedge rst) begin
        if (rst) out_matrix_temp <= '{default: 0};
        else if (done_cal && (next_state == KEY)) q_matrix <= out_matrix_temp;
        else if (done_cal && (next_state == VAL)) k_matrix <= out_matrix_temp;
        else if (done_cal && (next_state == QK)) v_matrix <= out_matrix_temp;
        else if (done_cal && (next_state == QKV)) qk_matrix <= out_matrix_temp;
        else if (done_cal && (next_state == FIN)) qkv_matrix <= out_matrix_temp;
        else begin
            out_matrix_temp <= out_matrix_temp;
            q_matrix <= q_matrix;
            k_matrix <= k_matrix;
            v_matrix <= v_matrix;
            qk_matrix <= qk_matrix;
            qkv_matrix <= qkv_matrix;
        end
    end

    integer i, j;
    // wt, bias, out_matrix
    always_comb begin
        case (state)
            IDLE: begin
                start_controller_reg = 1'b0;
            end
            QUE: begin
                start_controller_reg = 1'b1;
                mat_a_reg = mat_in;
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = queries_wt[i*MATRIX_SIZE+j];
                    end
                end
                bias_reg = queries_bs;
            end
            KEY: begin
                mat_a_reg = mat_in;
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = keys_wt[i*MATRIX_SIZE+j];
                    end
                end
                bias_reg = queries_bs;
            end
            VAL: begin
                mat_a_reg = mat_in;
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = values_wt[i*MATRIX_SIZE+j];
                    end
                end
                bias_reg = values_bs;
            end
            QK: begin
                mat_a_reg = q_matrix;
                wt_reg = k_matrix;
                bias_reg = '{default: 0};
            end
            QKV: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        mat_a_reg[i][j] = qk_matrix[i][j] / 4;
                    end
                end
                wt_reg   = v_matrix;
                bias_reg = '{default: 0};
            end
            FIN: begin
                mat_a_reg = qkv_matrix;
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = final_wt[i*MATRIX_SIZE+j];
                    end
                end
                bias_reg = final_bs;
            end
            DONE: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        out_matrix[i][j] = out_matrix_temp[i][j] + mat_in[i][j];
                    end
                end
            end
            default: begin
                start_controller_reg = 1'b0;
                mat_a_reg = mat_a_reg;
                wt_reg = wt_reg;
                bias_reg = bias_reg;
            end
        endcase
    end


    // done
    always_ff @(posedge clk, posedge rst) begin
        if (next_state == DONE) done <= 1;
        else done <= 0;
    end


    // FSM comb
    always_comb begin
        case (state)
            IDLE: next_state = start ? QUE : IDLE;
            QUE: next_state = done_cal ? KEY : QUE;
            KEY: next_state = done_cal ? VAL : KEY;
            VAL: next_state = done_cal ? QK : VAL;
            QK: next_state = done_cal ? QKV : QK;
            QKV: next_state = done_cal ? FIN : QKV;
            FIN: next_state = done_cal ? DONE : FIN;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // FSM FF 
    always_ff @(posedge clk, posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end


endmodule
