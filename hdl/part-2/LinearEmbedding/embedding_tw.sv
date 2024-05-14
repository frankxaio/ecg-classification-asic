module embedding_wt (
    input  [3:0] addr,
    output [7:0] data_out
);

    logic [7:0] data[0:15];

    assign data = {
        8'b00011011,
        8'b11011111,
        8'b11101000,
        8'b00010011,
        8'b11111101,
        8'b11111010,
        8'b11111101,
        8'b11101110,
        8'b00010110,
        8'b00000100,
        8'b00000101,
        8'b00000001,
        8'b11100100,
        8'b00001101,
        8'b11110001,
        8'b00001100
    };

    assign data_out = data[addr];

endmodule
