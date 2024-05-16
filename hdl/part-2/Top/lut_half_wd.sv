module lut_half_wd #(
    parameter ADDR_WIDTH = 8,
    DATA_WIDTH = 8
) (
    input               [ADDR_WIDTH-1:0] addr,
    output logic signed [DATA_WIDTH-1:0] data_o[0:15]
);
    localparam EMBEDDING_BS_CNT = 16;
    localparam EMBEDDING_WT_CNT = 16;
    localparam CLS_TOKEN_WT_CNT = 16;
    localparam FINAL_BS_CNT = 16;
    localparam KEYS_BS_CNT = 16;
    localparam QUERIES_BS_CNT = 16;
    localparam VALUES_BS_CNT = 16;
    localparam MLP0_BS_CNT = 16;
    localparam MLP1_BS_CNT = 16;


    logic signed [DATA_WIDTH-1:0] embedding_bs[0:EMBEDDING_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] embedding_wt[0:EMBEDDING_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] cls_token_wt[0:CLS_TOKEN_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] final_bs[0:FINAL_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] keys_bs[0:KEYS_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] queries_bs[0:QUERIES_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] values_bs[0:VALUES_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] mlp0_bs[0:MLP0_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] mlp1_bs[0:MLP1_BS_CNT-1];

    assign embedding_bs = '{
            8'b11111010,
            8'b00010000,
            8'b11110010,
            8'b00001011,
            8'b11111101,
            8'b00000010,
            8'b11110101,
            8'b00001111,
            8'b00010001,
            8'b11111010,
            8'b00000000,
            8'b11110001,
            8'b00000111,
            8'b00001010,
            8'b00010001,
            8'b00000100
        };

    assign embedding_wt = '{
            8'b00001100,
            8'b11110001,
            8'b00001101,
            8'b11100100,
            8'b00000001,
            8'b00000101,
            8'b00000100,
            8'b00010110,
            8'b11101110,
            8'b11111101,
            8'b11111010,
            8'b11111101,
            8'b00010011,
            8'b11101000,
            8'b11011111,
            8'b00011011
        };

    assign cls_token_wt = '{
            8'b00000111,
            8'b00001111,
            8'b00000101,
            8'b11101001,
            8'b00001101,
            8'b00000100,
            8'b11111110,
            8'b00000011,
            8'b11111111,
            8'b11101101,
            8'b00010100,
            8'b00000011,
            8'b00000001,
            8'b00000110,
            8'b00001100,
            8'b00000110
        };

    assign keys_bs = '{
            8'b00000100,
            8'b11110111,
            8'b11111111,
            8'b11110011,
            8'b00000001,
            8'b11111111,
            8'b00000001,
            8'b00000001,
            8'b11111100,
            8'b00001001,
            8'b00000010,
            8'b11111011,
            8'b11111010,
            8'b11111111,
            8'b00000011,
            8'b00000011
        };
    assign queries_bs = '{
            8'b11111110,
            8'b11111101,
            8'b00000100,
            8'b00000000,
            8'b00000001,
            8'b00000011,
            8'b00000001,
            8'b00000111,
            8'b00000011,
            8'b00000101,
            8'b00000010,
            8'b11111100,
            8'b11111101,
            8'b00000100,
            8'b11111011,
            8'b00000101
        };
    assign final_bs = '{
            8'b00000011,
            8'b00000011,
            8'b11111100,
            8'b11111110,
            8'b11111101,
            8'b00000000,
            8'b11111110,
            8'b00000010,
            8'b00000110,
            8'b00000100,
            8'b00000010,
            8'b00000010,
            8'b11111111,
            8'b00000101,
            8'b00000010,
            8'b00000000
        };
    assign values_bs = '{
            8'b11111111,
            8'b11111100,
            8'b00000010,
            8'b11111110,
            8'b00000001,
            8'b11111100,
            8'b11111111,
            8'b00000010,
            8'b11111110,
            8'b11111110,
            8'b00000011,
            8'b00000001,
            8'b11111110,
            8'b00000100,
            8'b00000001,
            8'b11111110
        };
    assign mlp0_bs = '{
            8'b11111110,
            8'b00000111,
            8'b00000001,
            8'b00000000,
            8'b00000100,
            8'b11111010,
            8'b11111111,
            8'b11111110,
            8'b00000100,
            8'b00000001,
            8'b11111111,
            8'b00000000,
            8'b00000010,
            8'b00000001,
            8'b00000010,
            8'b00000100
        };
    assign mlp1_bs = '{
            8'b11111110,
            8'b11111111,
            8'b00000001,
            8'b11111111,
            8'b11111010,
            8'b00000001,
            8'b00000011,
            8'b00000010,
            8'b00000000,
            8'b11111111,
            8'b00000000,
            8'b11111111,
            8'b00000000,
            8'b11111111,
            8'b11111101,
            8'b11111111
        };

    always_comb begin
        case (addr)
            8'h03:   data_o = embedding_bs;
            8'h04:   data_o = embedding_wt;
            8'h05:   data_o = cls_token_wt;
            8'h06:   data_o = final_bs;
            8'h08:   data_o = keys_bs;
            8'h0A:   data_o = queries_bs;
            8'h0C:   data_o = values_bs;
            8'h0E:   data_o = mlp0_bs;
            8'h10:   data_o = mlp1_bs;
            default: data_o = '{default: '0};
        endcase
    end
endmodule
