module mlp #(
    parameter MATRIX_SIZE = 16,
    DATA_WIDTH = 8,
    MLP0_BS_CNT = 16,
    MLP0_WT_CNT = 256,
    MLP1_BS_CNT = 16,
    MLP1_WT_CNT = 256
) (
    input clk,
    input rst,
    input start,
    input signed [DATA_WIDTH-1:0] mlp0_bs[0:MLP0_BS_CNT-1],
    input signed [DATA_WIDTH-1:0] mlp0_wt[0:MLP0_WT_CNT-1],
    input signed [DATA_WIDTH-1:0] mlp1_bs[0:MLP1_BS_CNT-1],
    input signed [DATA_WIDTH-1:0] mlp1_wt[0:MLP1_WT_CNT-1],
    input signed [DATA_WIDTH-1:0] mat_in[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
    output logic done,
    output logic signed [DATA_WIDTH-1:0] mat_out[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1]
);

    typedef logic signed [DATA_WIDTH-1:0] matrix_arr[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];
    typedef logic signed [DATA_WIDTH-1:0] bias_arr[0:MLP0_BS_CNT-1];
    typedef logic signed [DATA_WIDTH-1:0] wt_arr[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];

    typedef enum {
        IDLE,
        INPUT,
        L1,
        L2,
        DONE
    } state_t;

    matrix_arr mat_a_reg, out_matrix_temp, out_matrix_relu, in_matrix_relu_reg;
    wt_arr   wt_reg;
    bias_arr bias_reg;
    logic rst_loc, start_loc, done_loc, start_loc_reg;

    state_t state, next_state;

    assign start_in = start_loc;

    linear linear_inst (
        .clk(clk),
        .reset(rst_loc),
        .start(start_loc),
        .done(done_loc),
        .mat_a(mat_a_reg),
        .wt(wt_reg),
        .bias(bias_reg),
        .out_matrix(out_matrix_temp)
    );

    relu relu_inst (
        .data_in (in_matrix_relu_reg),
        .data_out(out_matrix_relu)
    );


    // start local
    always_ff @(posedge clk, posedge rst) begin
        if (rst) start_loc <= 1'b0;
        else start_loc <= start_loc_reg;
    end

    // rst local logic
    always_ff @(posedge clk, posedge rst) begin
        if (rst) rst_loc <= 1'b0;
        else rst_loc <= state != next_state;
    end

    // in_matrix_relu_reg logic
    always_ff @(posedge clk, posedge rst) begin
        if (rst) in_matrix_relu_reg <= '{default: 0};
        else
            in_matrix_relu_reg <= (done_loc && next_state == L2) ? out_matrix_temp : in_matrix_relu_reg;
    end

    // done 
    assign done = (next_state == DONE);

    // mat_a_reg logic
    always_comb begin
        case (state)
            IDLE: mat_a_reg = mat_in;
            L1:   mat_a_reg = out_matrix_relu;
            default: mat_a_reg = '{default: 0};
        endcase
    end


    // wt_reg logic
    integer i, j;
    always_comb begin
        case (state)
            IDLE: begin
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = start ? mlp0_wt[i*MATRIX_SIZE+j] : wt_reg[i][j];
                    end
                end
            end
            L1: begin
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = done_loc ? mlp1_wt[i*MATRIX_SIZE+j] : wt_reg[i][j];
                    end
                end
            end
            default: wt_reg = '{default: 0};
        endcase
    end


    // bias_reg logic
    always_ff @(posedge clk, posedge rst) begin
        if (rst) bias_reg <= '{default: 0};
        else if (state == IDLE && next_state == L1) bias_reg <= mlp0_bs;
        else if (state == L1 && next_state == L2) bias_reg <= mlp1_bs;
        else bias_reg <= bias_reg;
    end

    // start_loc_reg logic
    always_ff @(posedge clk, posedge rst) begin
        if (rst) start_loc_reg <= 1'b0;
        else begin
            case (state)
                IDLE: start_loc_reg <= start;
                L1: start_loc_reg <= done_loc;
                default: start_loc_reg <= 1'b0;
            endcase
        end
    end


    // mat_out logic
    integer k, m;
    always_comb begin
        case (state)
            DONE: begin
                for (k = 0; k < 16; k++) begin
                    for (m = 0; m < 16; m++) begin
                        mat_out[k][m] = out_matrix_temp[k][m] + mat_in[k][m];
                    end
                end
            end
            default: mat_out = '{default: 0};
        endcase
    end


    // state logic
    always_comb begin
        case (state)
            IDLE: next_state = start ? L1 : IDLE;
            L1:   next_state = done_loc ? L2 : L1;
            L2:   next_state = done_loc ? DONE : L2;
            DONE: next_state = IDLE;
            default: next_state = IDLE; // 添加 default 情況
        endcase
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

endmodule
