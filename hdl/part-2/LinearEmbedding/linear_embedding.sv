module linear_embedding (
    input clk,
    input rst,
    input signed [7:0] ecg_input[0:14],  //! Q4.4 format
    output signed [7:0] result[0:14][0:15],  //! Q4.4 format
    output logic done
);

    localparam BS_DEPTH = 16;
    localparam WT_DEPTH = 16;

    logic signed [7:0] embed_wt[0:15];  //! Q4.4 format
    logic signed [7:0] bias[0:15];  //! Q4.4 format
    logic signed [7:0] dot_product_result[0:14][0:15];  //! Q4.4 format

    logic start;
    logic [7:0] addr;
    logic [7:0] data;
    logic lut_done;

    lut_module #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8)
    ) lut_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .addr(addr),
        .data_o(data),
        .done(lut_done)
    );

    dot_product dot_product_inst (
        .clk(clk),
        .rst(rst),
        .mat_a(ecg_input),
        .mat_b(embed_wt),
        .bias(bias),
        .result(dot_product_result),
        .done(dot_product_done)
    );

    relu_embed #(
        .DATA_WIDTH(8),
        .DATA_DEPTH(16)
    ) relu_inst (
        .data_in (dot_product_result),
        .data_out(result)
    );

    // Control logic
    typedef enum {
        IDLE,
        READ_EMBEDDING_BS,
        READ_EMBEDDING_WT,
        DOT_PRODUCT
    } state_t;
    state_t state, next_state;

    logic [15:0] cnt;

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: begin
                if (start) begin
                    case (state)
                        8'h03:   next_state = READ_EMBEDDING_BS;
                        8'h04:   next_state = READ_EMBEDDING_WT;
                        default: next_state = IDLE;
                    endcase
                end else begin
                    next_state = IDLE;
                end
            end
            READ_EMBEDDING_BS:
            next_state = (cnt == BS_DEPTH - 1) && lut_done ? READ_EMBEDDING_WT : READ_EMBEDDING_BS;
            READ_EMBEDDING_WT:
            next_state = (cnt == WT_DEPTH - 1) && lut_done ? DOT_PRODUCT : READ_EMBEDDING_WT;
            DOT_PRODUCT: next_state = dot_product_done ? IDLE : DOT_PRODUCT;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    assign done = (state == IDLE);
    always_comb begin
        start = (state == IDLE);
    end

    // Counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst) cnt <= '0;
        else if (lut_done) cnt <= 0;
        else cnt <= cnt + 1;
    end

    // Loading data into arrays
    always_ff @(posedge clk) begin
        case (state)
            READ_EMBEDDING_BS: bias[cnt] <= data;
            READ_EMBEDDING_WT: embed_wt[cnt] <= data;
        endcase
    end


endmodule
