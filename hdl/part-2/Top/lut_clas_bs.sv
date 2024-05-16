module lut_clas_bs #(
    parameter ADDR_WIDTH = 8,
    DATA_WIDTH = 8
) (
    input               [ADDR_WIDTH-1:0] addr,
    output logic signed [DATA_WIDTH-1:0] data_o[0:5]
);
    localparam CLASSIFIER_BS_CNT = 6;
    logic signed [DATA_WIDTH-1:0] classifier_bs[0:CLASSIFIER_BS_CNT-1];

    assign classifier_bs = '{
            8'b00000100,
            8'b11111111,
            8'b00000000,
            8'b11111001,
            8'b00000000,
            8'b11111010
        };

    always_comb begin
        case (addr)
            8'h01:   data_o = classifier_bs;
            default: data_o = '{default: '0};
        endcase
    end
endmodule
