module rom #(
    parameter  DATA_WIDTH = 8,
    parameter  DATA_DEPTH = 16,
    parameter  ROM_FILE   = "rom_data.mem",
    localparam ADDR_WIDTH = $clog2(DATA_DEPTH)
) (
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
);

    logic [DATA_WIDTH-1:0] memory[0:DATA_DEPTH-1];

    initial begin
        if (ROM_FILE != 0) $readmemb(ROM_FILE, memory);
    end

    always_comb data = memory[addr];

endmodule

