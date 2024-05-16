module top (
    input clk,
    input rst,
    input start,
    input signed [7:0] ecg_input,
    output logic [3:0] classifier
);


    // DATA DEPTH
    localparam CLASSIFIER_BS_CNT = 6;
    localparam CLASSIFIER_WT_CNT = 96;
    localparam EMBEDDING_BS_CNT = 16;
    localparam EMBEDDING_WT_CNT = 16;
    localparam CLS_TOKEN_WT_CNT = 16;
    localparam FINAL_BS_CNT = 16;
    localparam FINAL_WT_CNT = 256;
    localparam KEYS_BS_CNT = 16;
    localparam KEYS_WT_CNT = 256;
    localparam QUERIES_BS_CNT = 16;
    localparam QUERIES_WT_CNT = 256;
    localparam VALUES_BS_CNT = 16;
    localparam VALUES_WT_CNT = 256;
    localparam MLP0_BS_CNT = 16;
    localparam MLP0_WT_CNT = 256;
    localparam MLP1_BS_CNT = 16;
    localparam MLP1_WT_CNT = 256;
    localparam PS_WT_CNT = 256;
    // DATA WIDTH
    localparam DATA_WIDTH = 8;
    localparam LUT_DEPTH = 256;

    // staert signal 
    logic start_lut, start_att_reg, start_att;
    logic start_mlp_reg, start_mlp;
    logic start_red_reg, start_red;

    // done siganl 
    logic embed_done, att_done, mlp_done, reduce_done, done_lut;
    // addr signal 
    logic [DATA_WIDTH-1:0] addr, addr_ns;

    // temp reg
    logic signed [DATA_WIDTH-1:0] result[0:15][0:15];
    logic signed [DATA_WIDTH-1:0] result_att[0:15][0:15];
    logic signed [DATA_WIDTH-1:0] mlp_out[0:15][0:15];

    // input storage
    logic signed [7:0] ecg_mem[0:14];
    logic [4:0] cnt_input;

    // Neural network param
    logic signed [DATA_WIDTH-1:0] classifier_bs[0:CLASSIFIER_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] classifier_wt[0:CLASSIFIER_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] embedding_bs[0:EMBEDDING_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] embedding_wt[0:EMBEDDING_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] cls_token_wt[0:CLS_TOKEN_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] final_bs[0:FINAL_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] final_wt[0:FINAL_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] keys_bs[0:KEYS_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] keys_wt[0:KEYS_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] queries_bs[0:QUERIES_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] queries_wt[0:QUERIES_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] values_bs[0:VALUES_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] values_wt[0:VALUES_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] mlp0_bs[0:MLP0_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] mlp0_wt[0:MLP0_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] mlp1_bs[0:MLP1_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] mlp1_wt[0:MLP1_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] ps_wt[0:PS_WT_CNT-1];

    // typedef logic signed [DATA_WIDTH-1:0] embed_param[0:LUT_DEPTH-1];
    // embed_param lut_data_o, embed_wt, embed_bs, embed_cls, embed_wt_ns, embed_bs_ns, embed_cls_ns;

    typedef enum {
        IDLE,
        START,
        EMBED_CAL,
        ATTENTION_CAL,
        MLP,
        REDUCE,
        DONE
    } state_t;
    state_t state, next_state;


    dot_product embed_inst (
        .clk(clk),
        .rst(rst),
        .ecg_input(ecg_mem),
        .wt(embedding_wt),
        .bias(embedding_bs),
        .cls_token(cls_token_wt),
        .result(result),
        .done(embed_done)
    );

    assign start_att = start_att_reg;
    attention attention_inst (
        .clk(clk),
        .rst(rst),
        .start(start_att),
        .final_bs(final_bs),
        .final_wt(final_wt),
        .keys_bs(keys_bs),
        .keys_wt(keys_wt),
        .queries_bs(queries_bs),
        .queries_wt(queries_wt),
        .values_bs(values_bs),
        .values_wt(values_wt),
        .mat_in(result),
        .out_matrix(result_att),
        .done(att_done)
    );

    assign start_mlp = start_mlp_reg;
    mlp mlp_inst (
        .clk(clk),
        .rst(rst),
        .start(start_mlp),
        .mlp0_bs(mlp0_bs),
        .mlp0_wt(mlp0_wt),
        .mlp1_bs(mlp1_bs),
        .mlp1_wt(mlp1_wt),
        .mat_in(result_att),
        .done(mlp_done),
        .mat_out(mlp_out)
    );

    assign start_red = start_red_reg;
    dot_product_16by6 reduce_inst (
        .clk(clk),
        .rst(rst),
        .start(start_red),
        .mat_in(mlp_out),
        .wt(classifier_wt),
        .bias(classifier_bs),
        .max(classifier),
        .done(reduce_done)
    );


    always_ff @(posedge clk, posedge rst)begin
        if(rst) cnt_input <= 0;
        else if (state==START) cnt_input <= cnt_input + 1;
        else cnt_input <= 0;
    end

    integer i;
    always_ff @(posedge clk, posedge rst)begin
        if(rst) ecg_mem <= '{default:0};
        else if(state==START)
            ecg_mem[cnt_input] <= ecg_input;
        else begin
            for (i=0;i<16;i++) 
            ecg_mem[i] <= ecg_mem[i];
        end 
    end


    assign done = (state == DONE);
    // state transition
    always_comb begin
        case (state)
            IDLE: next_state = start ? START : IDLE;
            START: next_state = (cnt_input == 15) ? EMBED_CAL : START;
            EMBED_CAL: next_state = embed_done ? ATTENTION_CAL : EMBED_CAL;
            ATTENTION_CAL: next_state = att_done ? MLP : ATTENTION_CAL;
            MLP: next_state = mlp_done ? REDUCE : MLP;
            REDUCE: next_state = reduce_done ? DONE : REDUCE;
            DONE: next_state = IDLE;
            default: ;
        endcase
    end

    // start reduce 
    always_ff @(posedge clk, posedge rst) begin
        if (next_state == REDUCE) start_red_reg <= 1;
        else if (next_state != REDUCE) start_red_reg <= 0;
        else start_red_reg <= 0;
    end

    // start mlp signal 
    always_ff @(posedge clk, posedge rst) begin
        if (next_state == MLP) start_mlp_reg <= 1;
        else if (next_state != MLP) start_mlp_reg <= 0;
        else start_mlp_reg <= 0;
    end


    // start_att signal
    always_ff @(posedge clk, posedge rst) begin
        if (next_state == ATTENTION_CAL) start_att_reg <= 1;
        else if (next_state != ATTENTION_CAL) start_att_reg <= 0;
        else start_att_reg <= 0;
    end


    // state register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    /*==================================LOAD WEIGHT, BIAS=====================================*/
    lut_module #(
        .DATA_LEN(CLASSIFIER_BS_CNT)
    ) lut_inst_clas_bs (
        .addr  (8'h01),
        .data_o(classifier_bs)
    );

    lut_module #(
        .DATA_LEN(CLASSIFIER_WT_CNT)
    ) lut_inst_clas_wt (
        .addr  (8'h02),
        .data_o(classifier_wt)
    );

    lut_module #(
        .DATA_LEN(EMBEDDING_BS_CNT)
    ) lut_inst_embed_bs (
        .addr  (8'h03),
        .data_o(embedding_bs)
    );

    lut_module #(
        .DATA_LEN(EMBEDDING_WT_CNT)
    ) lut_inst_embed_wt (
        .addr  (8'h04),
        .data_o(embedding_wt)
    );

    lut_module #(
        .DATA_LEN(CLS_TOKEN_WT_CNT)
    ) lut_inst_cls (
        .addr  (8'h05),
        .data_o(cls_token_wt)
    );

    lut_module #(
        .DATA_LEN(FINAL_BS_CNT)
    ) lut_inst_fina_bs (
        .addr  (8'h06),
        .data_o(final_bs)
    );

    lut_module #(
        .DATA_LEN(FINAL_WT_CNT)
    ) lut_inst_fina_wt (
        .addr  (8'h07),
        .data_o(final_wt)
    );

    lut_module #(
        .DATA_LEN(KEYS_BS_CNT)
    ) lut_inst_keys_bs (
        .addr  (8'h08),
        .data_o(keys_bs)
    );

    lut_module #(
        .DATA_LEN(KEYS_WT_CNT)
    ) lut_inst_keys_wt (
        .addr  (8'h09),
        .data_o(keys_wt)
    );

    lut_module #(
        .DATA_LEN(QUERIES_BS_CNT)
    ) lut_inst_quer_bs (
        .addr  (8'h0A),
        .data_o(queries_bs)
    );

    lut_module #(
        .DATA_LEN(QUERIES_WT_CNT)
    ) lut_inst_quer_wt (
        .addr  (8'h0B),
        .data_o(queries_wt)
    );

    lut_module #(
        .DATA_LEN(VALUES_BS_CNT)
    ) lut_inst_valu_bs (
        .addr  (8'h0C),
        .data_o(values_bs)
    );

    lut_module #(
        .DATA_LEN(VALUES_WT_CNT)
    ) lut_inst_valu_wt (
        .addr  (8'h0D),
        .data_o(values_wt)
    );

    lut_module #(
        .DATA_LEN(MLP0_BS_CNT)
    ) lut_inst_mlp0_bs (
        .addr  (8'h0E),
        .data_o(mlp0_bs)
    );

    lut_module #(
        .DATA_LEN(MLP0_WT_CNT)
    ) lut_inst_mlp0_wt (
        .addr  (8'h0F),
        .data_o(mlp0_wt)
    );

    lut_module #(
        .DATA_LEN(MLP1_BS_CNT)
    ) lut_inst_mlp1_bs (
        .addr  (8'h10),
        .data_o(mlp1_bs)
    );

    lut_module #(
        .DATA_LEN(MLP1_WT_CNT)
    ) lut_inst_mlp1_wt (
        .addr  (8'h11),
        .data_o(mlp1_wt)
    );

    lut_module #(
        .DATA_LEN(PS_WT_CNT)
    ) lut_inst_ps_wt (
        .addr  (8'h12),
        .data_o(ps_wt)
    );
endmodule
