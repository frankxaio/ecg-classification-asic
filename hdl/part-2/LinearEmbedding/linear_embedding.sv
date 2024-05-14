module linear_embedding (
    input clk,
    input rst,
    output logic signed [7:0] result[0:14][0:15], //! Q4.4 format
    output logic done
);

    localparam BS_DEPTH = 16;
    localparam WT_DEPTH = 16;
    localparam FP_DATA_DEPTH = 15;

    logic signed [7:0] mat_a[0:14];    //! Q4.4 format
    logic signed [7:0] mat_b[0:15];    //! Q4.4 format
    logic signed [7:0] bias[0:15];     //! Q4.4 format
    logic signed [7:0] dot_product_result[0:14][0:15];  //! Q4.4 format

    logic start_bs, start_wt, start_fp;
    logic done_bs, done_wt, done_fp;
    logic [7:0] data_bs, data_wt, data_fp;

    rom_controller #(
        .DATA_WIDTH(8),
        .DATA_DEPTH(BS_DEPTH),
        .ROM_FILE("embedding_bs.txt")
    ) bs_rom_inst (
        .clk(clk),
        .rst(rst),
        .start(start_bs),
        .data(data_bs),
        .done(done_bs)
    );

    rom_controller #(
        .DATA_WIDTH(8),
        .DATA_DEPTH(WT_DEPTH),
        .ROM_FILE("embedding_wt.txt")
    ) wt_rom_inst (
        .clk(clk),
        .rst(rst),
        .start(start_wt),
        .data(data_wt),
        .done(done_wt)
    );

    rom_controller #(
        .DATA_WIDTH(8),
        .DATA_DEPTH(FP_DATA_DEPTH),
        .ROM_FILE("fixed_point_data_1.txt")
    ) fp_rom_inst (
        .clk(clk),
        .rst(rst),
        .start(start_fp),
        .data(data_fp),
        .done(done_fp)
    );

    dot_product dot_product_inst (
        .clk(clk),
        .rst(rst),
        .mat_a(mat_a),
        .mat_b(mat_b),
        .bias(bias),
        .result(dot_product_result),
        .done(done)
    );

    relu relu_inst (
        .data_in (dot_product_result),
        .data_out(result)
    );

    // Control logic
    typedef enum {
        IDLE,
        READ_BS,
        READ_WT,
        READ_FP,
        DOT_PRODUCT
    } state_t;
    state_t state, next_state;

    logic [3:0] bs_cnt, wt_cnt, fp_cnt;

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: next_state = READ_BS;
            READ_BS: next_state = done_bs ? READ_WT : READ_BS;
            READ_WT: next_state = done_wt ? READ_FP : READ_WT;
            READ_FP: next_state = done_fp ? DOT_PRODUCT : READ_FP;
            DOT_PRODUCT: next_state = done ? IDLE : DOT_PRODUCT;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        start_bs = (state == IDLE);
        start_wt = (state == READ_BS) && done_bs;
        start_fp = (state == READ_WT) && done_wt;
    end

    // Bias counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst) bs_cnt <= '0;
        else if (state == READ_BS && !done_bs) bs_cnt <= bs_cnt + 1;
    end

    // Weight counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst) wt_cnt <= '0;
        else if (state == READ_WT && !done_wt) wt_cnt <= wt_cnt + 1;
    end

    // Fixed point data counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst) fp_cnt <= '0;
        else if (state == READ_FP && !done_fp) fp_cnt <= fp_cnt + 1;
    end

    // Loading data into arrays
    always_ff @(posedge clk) begin
        if (state == READ_BS) bias[bs_cnt] <= data_bs;
        if (state == READ_WT) mat_b[wt_cnt] <= data_wt;
        if (state == READ_FP) mat_a[fp_cnt] <= data_fp;
    end

endmodule