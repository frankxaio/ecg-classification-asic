module lut_controller #(
    parameter ADDR_WIDTH = 8,
    DATA_WIDTH = 8
) (
    input                         clk,
    input                         rst,
    input                         start,
    output logic [DATA_WIDTH-1:0] classifier_bs[  0:5],
    output logic [DATA_WIDTH-1:0] classifier_wt[ 0:95],
    output logic [DATA_WIDTH-1:0] embedding_bs [ 0:15],
    output logic [DATA_WIDTH-1:0] embedding_wt [ 0:15],
    output logic [DATA_WIDTH-1:0] cls_token_wt [ 0:15],
    output logic [DATA_WIDTH-1:0] final_bs     [ 0:15],
    output logic [DATA_WIDTH-1:0] final_wt     [0:255],
    output logic [DATA_WIDTH-1:0] keys_bs      [ 0:15],
    output logic [DATA_WIDTH-1:0] keys_wt      [0:255],
    output logic [DATA_WIDTH-1:0] queries_bs   [ 0:15],
    output logic [DATA_WIDTH-1:0] queries_wt   [0:255],
    output logic [DATA_WIDTH-1:0] values_bs    [ 0:15],
    output logic [DATA_WIDTH-1:0] values_wt    [0:255],
    output logic [DATA_WIDTH-1:0] mlp0_bs      [ 0:15],
    output logic [DATA_WIDTH-1:0] mlp0_wt      [0:255],
    output logic [DATA_WIDTH-1:0] mlp1_bs      [ 0:15],
    output logic [DATA_WIDTH-1:0] mlp1_wt      [0:255],
    output logic [DATA_WIDTH-1:0] ps_wt        [0:255],
    output logic                  done
);

    logic [DATA_WIDTH-1:0] data_o;
    logic                  lut_done;
    logic [ADDR_WIDTH-1:0] addr;
    logic                  lut_start;

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

    // Instantiate the lut_module
    lut_module #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) lut_inst (
        .clk   (clk),
        .rst   (rst),
        .start (lut_start),
        .addr  (addr),
        .data_o(data_o),
        .done  (lut_done)
    );

    // Internal signals
    logic [$clog2(256)-1:0] array_index;

    // Enumeration for state machine
    typedef enum {
        IDLE,
        READ_CLASSIFIER_BS,
        READ_CLASSIFIER_WT,
        READ_EMBEDDING_BS,
        READ_EMBEDDING_WT,
        READ_CLS_TOKEN_WT,
        READ_FINAL_BS,
        READ_FINAL_WT,
        READ_KEYS_BS,
        READ_KEYS_WT,
        READ_QUERIES_BS,
        READ_QUERIES_WT,
        READ_VALUES_BS,
        READ_VALUES_WT,
        READ_MLP0_BS,
        READ_MLP0_WT,
        READ_MLP1_BS,
        READ_MLP1_WT,
        READ_PS_WT,
        DONE
    } state_t;

    state_t state, next_state;

    // State register
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = READ_CLASSIFIER_BS;
                end else begin
                    next_state = IDLE;
                end
            end
            READ_CLASSIFIER_BS: begin
                if (lut_done && (array_index == CLASSIFIER_BS_CNT-1)) begin
                    next_state = READ_CLASSIFIER_WT;
                end else begin
                    next_state = READ_CLASSIFIER_BS;
                end
            end
            READ_CLASSIFIER_WT: begin
                if (lut_done && (array_index == CLASSIFIER_WT_CNT-1)) begin
                    next_state = READ_EMBEDDING_BS;
                end else begin
                    next_state = READ_CLASSIFIER_WT;
                end
            end
            READ_EMBEDDING_BS: begin
                if (lut_done && (array_index == EMBEDDING_BS_CNT-1)) begin
                    next_state = READ_EMBEDDING_WT;
                end else begin
                    next_state = READ_EMBEDDING_BS;
                end
            end
            READ_EMBEDDING_WT: begin
                if (lut_done && (array_index == EMBEDDING_WT_CNT-1)) begin
                    next_state = READ_CLS_TOKEN_WT;
                end else begin
                    next_state = READ_EMBEDDING_WT;
                end
            end
            READ_CLS_TOKEN_WT: begin
                if (lut_done && (array_index == CLS_TOKEN_WT_CNT-1)) begin
                    next_state = READ_FINAL_BS;
                end else begin
                    next_state = READ_CLS_TOKEN_WT;
                end
            end
            READ_FINAL_BS: begin
                if (lut_done && (array_index == FINAL_BS_CNT-1)) begin
                    next_state = READ_FINAL_WT;
                end else begin
                    next_state = READ_FINAL_BS;
                end
            end
            READ_FINAL_WT: begin
                if (lut_done && (array_index == FINAL_WT_CNT-1)) begin
                    next_state = READ_KEYS_BS;
                end else begin
                    next_state = READ_FINAL_WT;
                end
            end
            READ_KEYS_BS: begin
                if (lut_done && (array_index == KEYS_BS_CNT-1)) begin
                    next_state = READ_KEYS_WT;
                end else begin
                    next_state = READ_KEYS_BS;
                end
            end
            READ_KEYS_WT: begin
                if (lut_done && (array_index == KEYS_WT_CNT-1)) begin
                    next_state = READ_QUERIES_BS;
                end else begin
                    next_state = READ_KEYS_WT;
                end
            end
            READ_QUERIES_BS: begin
                if (lut_done && (array_index == QUERIES_BS_CNT-1)) begin
                    next_state = READ_QUERIES_WT;
                end else begin
                    next_state = READ_QUERIES_BS;
                end
            end
            READ_QUERIES_WT: begin
                if (lut_done && (array_index == QUERIES_WT_CNT-1)) begin
                    next_state = READ_VALUES_BS;
                end else begin
                    next_state = READ_QUERIES_WT;
                end
            end
            READ_VALUES_BS: begin
                if (lut_done && (array_index == VALUES_BS_CNT-1)) begin
                    next_state = READ_VALUES_WT;
                end else begin
                    next_state = READ_VALUES_BS;
                end
            end
            READ_VALUES_WT: begin
                if (lut_done && (array_index == VALUES_WT_CNT-1)) begin
                    next_state = READ_MLP0_BS;
                end else begin
                    next_state = READ_VALUES_WT;
                end
            end
            READ_MLP0_BS: begin
                if (lut_done && (array_index == MLP0_BS_CNT-1)) begin
                    next_state = READ_MLP0_WT;
                end else begin
                    next_state = READ_MLP0_BS;
                end
            end
            READ_MLP0_WT: begin
                if (lut_done && (array_index == MLP0_WT_CNT-1)) begin
                    next_state = READ_MLP1_BS;
                end else begin
                    next_state = READ_MLP0_WT;
                end
            end
            READ_MLP1_BS: begin
                if (lut_done && (array_index == MLP1_BS_CNT-1)) begin
                    next_state = READ_MLP1_WT;
                end else begin
                    next_state = READ_MLP1_BS;
                end
            end
            READ_MLP1_WT: begin
                if (lut_done && (array_index == MLP1_WT_CNT-1)) begin
                    next_state = READ_PS_WT;
                end else begin
                    next_state = READ_MLP1_WT;
                end
            end
            READ_PS_WT: begin
                if (lut_done && (array_index == PS_WT_CNT-1)) begin
                    next_state = DONE;
                end else begin
                    next_state = READ_PS_WT;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Array index register
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            array_index <= 0;
        end else if (state != next_state) begin
            array_index <= 0;
        end else if (lut_done) begin
            array_index <= array_index + 1;
        end
    end

    // Address logic
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            addr <= 0;
        end else begin
            case (next_state)
                READ_CLASSIFIER_BS: addr <= 8'h01;
                READ_CLASSIFIER_WT: addr <= 8'h02;
                READ_EMBEDDING_BS:  addr <= 8'h03;
                READ_EMBEDDING_WT:  addr <= 8'h04;
                READ_CLS_TOKEN_WT:  addr <= 8'h05;
                READ_FINAL_BS:      addr <= 8'h06;
                READ_FINAL_WT:      addr <= 8'h07;
                READ_KEYS_BS:       addr <= 8'h08;
                READ_KEYS_WT:       addr <= 8'h09;
                READ_QUERIES_BS:    addr <= 8'h0A;
                READ_QUERIES_WT:    addr <= 8'h0B;
                READ_VALUES_BS:     addr <= 8'h0C;
                READ_VALUES_WT:     addr <= 8'h0D;
                READ_MLP0_BS:       addr <= 8'h0E;
                READ_MLP0_WT:       addr <= 8'h0F;
                READ_MLP1_BS:       addr <= 8'h10;
                READ_MLP1_WT:       addr <= 8'h11;
                READ_PS_WT:         addr <= 8'h12;
                default:            addr <= 8'h00;
            endcase
        end
    end

    // Internal start signal for lut_module
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            lut_start <= 0;
        end else if (state != next_state) begin
            lut_start <= 1;
        end else begin
            lut_start <= 0;
        end
    end

    // Store data in memory arrays
    always_ff @(posedge clk) begin
        if (lut_done) begin
            case (state)
                READ_CLASSIFIER_BS: classifier_bs[array_index] <= data_o;
                READ_CLASSIFIER_WT: classifier_wt[array_index] <= data_o;
                READ_EMBEDDING_BS:  embedding_bs[array_index] <= data_o;
                READ_EMBEDDING_WT:  embedding_wt[array_index] <= data_o;
                READ_CLS_TOKEN_WT:  cls_token_wt[array_index] <= data_o;
                READ_FINAL_BS:      final_bs[array_index] <= data_o;
                READ_FINAL_WT:      final_wt[array_index] <= data_o;
                READ_KEYS_BS:       keys_bs[array_index] <= data_o;
                READ_KEYS_WT:       keys_wt[array_index] <= data_o;
                READ_QUERIES_BS:    queries_bs[array_index] <= data_o;
                READ_QUERIES_WT:    queries_wt[array_index] <= data_o;
                READ_VALUES_BS:     values_bs[array_index] <= data_o;
                READ_VALUES_WT:     values_wt[array_index] <= data_o;
                READ_MLP0_BS:       mlp0_bs[array_index] <= data_o;
                READ_MLP0_WT:       mlp0_wt[array_index] <= data_o;
                READ_MLP1_BS:       mlp1_bs[array_index] <= data_o;
                READ_MLP1_WT:       mlp1_wt[array_index] <= data_o;
                READ_PS_WT:         ps_wt[array_index] <= data_o;
                default:            ;
            endcase
        end
    end

    // Done signal
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            done <= 1'b0;
        end else if (state == DONE) begin
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end

endmodule