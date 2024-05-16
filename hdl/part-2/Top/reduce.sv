module reduce (
    input logic clk,
    input logic rst,
    input logic enable,  //! enable 要一直保持 1 才進行計算
    input logic signed [7:0] matrix_in[15:0][15:0],
    output logic signed [7:0] matrix_out[15:0],
    output logic done
);

    typedef enum {
        IDLE,
        SUM,
        AVG,
        DONE
    } state_t;
    state_t state, next_state;

    logic signed [11:0] sum;
    logic signed [ 7:0] avg;
    logic [3:0] row_cnt, col_cnt;

    // 狀態轉移
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    // 下一個狀態邏輯
    always_comb begin
        case (state)
            IDLE: next_state = enable ? SUM : IDLE;
            SUM: next_state = (row_cnt == 15) ? AVG : SUM;
            AVG: next_state = (col_cnt == 15) ? DONE : SUM;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // 輸出邏輯
    assign done = (state == DONE);

    // 計數器邏輯
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            row_cnt <= 0;
            col_cnt <= 0;
        end else if (state == AVG) begin
            if (col_cnt == 15) begin
                col_cnt <= 0;
            end else begin
                col_cnt <= col_cnt + 1;
            end
            row_cnt <= 0;
        end else if (state == SUM) begin
            if (row_cnt == 15) row_cnt <= 0;
            else row_cnt <= row_cnt + 1;
        end
    end

    // 求和邏輯
    always_ff @(posedge clk or posedge rst) begin
        if (rst) sum <= 0;
        else if (state == SUM) begin
            if (row_cnt == 0) sum <= matrix_in[row_cnt][col_cnt];
            else sum <= sum + matrix_in[row_cnt][col_cnt];
        end else if (state == IDLE) sum <= 0;
    end

    // 平均值計算邏輯
    always_comb begin
        if (state == AVG) avg = sum >> 4;
        else avg = 0;
    end

    // 輸出邏輯
    always_ff @(posedge clk or posedge rst) begin
        if (rst) matrix_out <= '{default: 0};
        else if (state == AVG) matrix_out[col_cnt] <= avg;
    end

endmodule
