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
        mat_a,
        mat_a_reg,
        out_matrix_temp,
        q_matrix,
        k_matrix,
        v_matrix,
        qk_matrix,
        qkv_matrix,
        mat_in_mem;
    wt_arr wt, wt_reg;
    bias_arr bias, bias_reg;



    logic start_in;
    // logic start_controller, start_controller_reg, start_in;
    logic done_cal, rst_local;

    typedef enum {
        IDLE,
        INPUT,
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
    assign start_in = (state != IDLE) ? 1 : 0;

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



    // mat_in_mem
    always_ff @(posedge clk, posedge rst) begin
        if (rst) mat_in_mem <= '{default: 0};
        else begin
            case (state)
                INPUT:   mat_in_mem <= mat_in;
                default: mat_in_mem <= mat_in_mem;
            endcase
        end
    end


    // rst local logic
    always_ff @(posedge clk, posedge rst) begin
        if (rst) rst_local <= 1'b0;
        else rst_local <= (state != next_state);
    end

    // always_ff @(posedge clk, posedge rst) begin
    //     if (rst) out_matrix_temp <= '{default: 0};
    //     else if (done_cal && (next_state == KEY)) q_matrix <= out_matrix_temp;
    //     else if (done_cal && (next_state == VAL)) k_matrix <= out_matrix_temp;
    //     else if (done_cal && (next_state == QK)) v_matrix <= out_matrix_temp;
    //     else if (done_cal && (next_state == QKV)) qk_matrix <= out_matrix_temp;
    //     else if (done_cal && (next_state == FIN)) qkv_matrix <= out_matrix_temp;
    //     else begin
    //         out_matrix_temp <= out_matrix_temp;
    //         q_matrix <= q_matrix;
    //         k_matrix <= k_matrix;
    //         v_matrix <= v_matrix;
    //         qk_matrix <= qk_matrix;
    //         qkv_matrix <= qkv_matrix;
    //     end
    // end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            q_matrix <= '{default: 0};
            k_matrix <= '{default: 0};
            v_matrix <= '{default: 0};
            qk_matrix <= '{default: 0};
            qkv_matrix <= '{default: 0};
            out_matrix_temp <= '{default: 0};
        end else begin
            case (next_state)
                KEY: q_matrix <= done_cal ? out_matrix_temp : q_matrix;
                VAL: k_matrix <= done_cal ? out_matrix_temp : k_matrix;
                QK:  v_matrix <= done_cal ? out_matrix_temp : v_matrix;
                QKV: qk_matrix <= done_cal ? out_matrix_temp : qk_matrix;
                FIN: qkv_matrix <= done_cal ? out_matrix_temp : qkv_matrix;
                default: begin
                    out_matrix_temp <= '{default: 0};
                    q_matrix <= q_matrix;
                    k_matrix <= k_matrix;
                    v_matrix <= v_matrix;
                    qk_matrix <= qk_matrix;
                    qkv_matrix <= qkv_matrix;
                end
            endcase
        end
    end



    // mat_a_reg logic
    integer i, j;
    always_comb begin
        case (state)
            QUE: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        mat_a_reg[i][j] = mat_in_mem[i][j];
                    end
                end
            end
            KEY: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        mat_a_reg[i][j] = mat_in_mem[i][j];
                    end
                end
            end
            VAL: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        mat_a_reg[i][j] = mat_in_mem[i][j];
                    end
                end
            end
            QK: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        mat_a_reg[i][j] = mat_in_mem[i][j];
                    end
                end
            end

            QKV: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        mat_a_reg[i][j] = (qk_matrix[i][j] / 4);
                    end
                end
            end
            FIN: begin
                for (i = 0; i < MATRIX_SIZE; i++) begin
                    for (j = 0; j < MATRIX_SIZE; j++) begin
                        mat_a_reg[i][j] = qkv_matrix[i][j];
                    end
                end
            end
            default: mat_a_reg = '{default: 0};
        endcase
    end

    // wt_reg logic
    integer m, k;
    always_comb begin
        case (state)
            QUE: begin
                for (m = 0; m < 16; m++) begin
                    for (k = 0; k < 16; k++) begin
                        wt_reg[m][k] = queries_wt[m*MATRIX_SIZE+k];
                    end
                end
            end
            KEY: begin
                for (m = 0; m < 16; m++) begin
                    for (k = 0; k < 16; k++) begin
                        wt_reg[m][k] = keys_wt[m*MATRIX_SIZE+k];
                    end
                end
            end
            VAL: begin
                for (m = 0; m < 16; m++) begin
                    for (k = 0; k < 16; k++) begin
                        wt_reg[m][k] = values_wt[m*MATRIX_SIZE+k];
                    end
                end
            end
            QK: begin
                for (m = 0; m < 16; m++) begin
                    for (k = 0; k < 16; k++) begin
                        wt_reg[m][k] = k_matrix[m][k];
                    end
                end
            end
            QKV: begin
                for (m = 0; m < 16; m++) begin
                    for (k = 0; k < 16; k++) begin
                        wt_reg[m][k] = v_matrix[m][k];
                    end
                end
            end
            FIN: begin
                for (m = 0; m < 16; m++) begin
                    for (k = 0; k < 16; k++) begin
                        wt_reg[m][k] = final_wt[m*MATRIX_SIZE+k];
                    end
                end
            end
            default: wt_reg = '{default: 0};
        endcase
    end

    // bias_reg logic
    always_comb begin
        case (state)
            QUE: bias_reg = queries_bs;
            KEY: bias_reg = keys_bs;
            VAL: bias_reg = values_bs;
            QK: bias_reg = '{default: 0};
            QKV: bias_reg = '{default: 0};
            FIN: bias_reg = final_bs;
            default: bias_reg = '{default: 0};
        endcase
    end

    // out_matrix logic
    integer n, v;
    always_comb begin
        case (state)
            DONE: begin
                for (n = 0; n < MATRIX_SIZE; n++) begin
                    for (v = 0; v < MATRIX_SIZE; v++) begin
                        out_matrix[n][v] = out_matrix_temp[n][v] + mat_in_mem[n][v];
                    end
                end
            end
            default: out_matrix = '{default: 0};
        endcase
    end

    // done
    assign done = (next_state == DONE);

    // FSM comb
    always_comb begin
        case (state)
            IDLE: next_state = start ? INPUT : IDLE;
            INPUT: next_state = QUE;
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
