module rom_tb;
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 4;
    parameter DATA_DEPTH = 16;
    parameter ROM_FILE = "quantized_bias.mem";

    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] data;

    rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .ROM_FILE  (ROM_FILE)
    ) rom_inst (
        .addr(addr),
        .data(data)
    );

    initial begin
        // 测试有效地址范围内的读取
        for (int i = 0; i < DATA_DEPTH; i++) begin
            addr = i;
            #10;
            $display("Address: %0d, Data: %0h", addr, data);
        end

        // 测试超出地址范围的读取
        // for (int i = DATA_DEPTH; i < 2**ADDR_WIDTH; i++) begin
        //     addr = i;
        //     #10;
        //     $display("Address: %0d, Data: %0h", addr, data);
        // end

        // 结束仿真
        #10;
        // $finish;
    end

endmodule
