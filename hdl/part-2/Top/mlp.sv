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
        L1,
        L2,
        DONE
    } state_t;


    matrix_arr
        mat_a, mat_a_reg, out_matrix_temp, out_matrix_relu, in_matrix_relu_reg, in_matrix_relu;
    wt_arr wt, wt_reg;
    bias_arr bias, bias_reg;
    logic rst_loc, start_loc, done_loc, start_loc_reg, start_in;


    state_t state, next_state;

    assign mat_a = mat_a_reg;
    assign wt = wt_reg;
    assign bias = bias_reg;
    assign start_in = (start_loc == 1);
    linear linear_inst (
        .clk(clk),
        .reset(rst_loc),
        .start(start_loc),
        .done(done_loc),
        .mat_a(mat_a),
        .wt(wt),
        .bias(bias),
        .out_matrix(out_matrix_temp)
    );

    assign in_matrix_relu = in_matrix_relu_reg;
    relu relu_inst (
        .data_in (in_matrix_relu),
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
        else if (state != next_state) rst_loc <= 1'b1;
        else rst_loc <= 1'b0;
    end

    // matrix internal logic
    always_ff @(posedge clk, posedge rst) begin
        if (rst) out_matrix_temp <= '{default: 0};
        else if (done_loc && next_state == L2) in_matrix_relu_reg <= out_matrix_temp;
        else out_matrix_temp <= out_matrix_temp;
    end

    // done 
    always_ff @(posedge clk, posedge rst) begin
        if (rst) done <= 0;
        else if (next_state == DONE) done <= 1;
        else done <= 0;
    end


    integer i, j;
    always_comb begin
        case (state)
            IDLE: start_loc_reg = 1'b0;
            L1: begin
                start_loc_reg = 1'b1;
                mat_a_reg = mat_in;
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = mlp0_wt[i*MATRIX_SIZE+j];
                    end
                end
                bias_reg = mlp0_bs;
            end
            L2: begin
                mat_a_reg = out_matrix_relu;
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        wt_reg[i][j] = mlp1_wt[i*MATRIX_SIZE+j];
                    end
                end
                bias_reg = mlp1_bs;
            end
            DONE: begin
                // residual add
                for (i = 0; i < 16; i++) begin
                    for (j = 0; j < 16; j++) begin
                        mat_out[i][j] = out_matrix_temp[i][j] + mat_in[i][j];
                    end
                end
            end
            default: begin
                start_loc_reg = 1'b0;
                mat_a_reg = mat_a_reg;
                wt_reg = wt_reg;
                bias_reg = bias_reg;
                mat_out = mat_out;
            end
        endcase
    end


    // state logic
    always_comb begin
        case (state)
            IDLE: next_state = start ? L1 : IDLE;
            L1:   next_state = done_loc ? L2 : L1;
            L2:   next_state = done_loc ? DONE : L2;
            DONE: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

endmodule
