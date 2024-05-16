module lut_clas_wt #(
    parameter ADDR_WIDTH = 8,
    DATA_WIDTH = 8
) (
    input               [ADDR_WIDTH-1:0] addr,
    output logic signed [DATA_WIDTH-1:0] data_o[0:95]
);
    localparam CLASSIFIER_WT_CNT = 96;
    logic signed [DATA_WIDTH-1:0] classifier_wt[0:CLASSIFIER_WT_CNT-1];

    assign classifier_wt = '{
            8'b00000100,
            8'b11111011,
            8'b11111001,
            8'b11111010,
            8'b00000011,
            8'b11111000,
            8'b00001000,
            8'b00000111,
            8'b00000110,
            8'b00001000,
            8'b11111010,
            8'b00000000,
            8'b11111001,
            8'b00001000,
            8'b00000001,
            8'b00000000,
            8'b00001001,
            8'b00010010,
            8'b00001110,
            8'b11110101,
            8'b00001100,
            8'b00000100,
            8'b11101100,
            8'b00000010,
            8'b00000000,
            8'b00000011,
            8'b11110111,
            8'b00010110,
            8'b11111100,
            8'b11111111,
            8'b00001111,
            8'b11101101,
            8'b00001010,
            8'b11101101,
            8'b11111111,
            8'b00001110,
            8'b00000001,
            8'b00000001,
            8'b11111011,
            8'b11111011,
            8'b11110101,
            8'b11111010,
            8'b00001010,
            8'b00001110,
            8'b00000111,
            8'b11111000,
            8'b11111001,
            8'b00001011,
            8'b11111111,
            8'b11011000,
            8'b00001101,
            8'b00001101,
            8'b00001110,
            8'b00000100,
            8'b00000010,
            8'b11111110,
            8'b11111110,
            8'b11111010,
            8'b00000001,
            8'b11111101,
            8'b11111001,
            8'b00000010,
            8'b00000100,
            8'b00000010,
            8'b11110110,
            8'b00010010,
            8'b11101111,
            8'b00010100,
            8'b11101111,
            8'b00001111,
            8'b00000111,
            8'b11110011,
            8'b11110110,
            8'b11111001,
            8'b00001101,
            8'b11110001,
            8'b00001100,
            8'b11110001,
            8'b11110010,
            8'b11111010,
            8'b11111100,
            8'b00000111,
            8'b00001111,
            8'b11110110,
            8'b00000101,
            8'b00000110,
            8'b11111011,
            8'b00000110,
            8'b00000110,
            8'b00000011,
            8'b00000010,
            8'b11101101,
            8'b11111001,
            8'b00000011,
            8'b00000000,
            8'b00000101
        };


    always_comb begin
        case (addr)
            8'h01:   data_o = classifier_wt;
            default: data_o = '{default: '0};
        endcase
    end
endmodule