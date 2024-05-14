module rom_controller_tb;
    parameter DATA_WIDTH = 16;
    parameter DATA_DEPTH = 6;
    parameter ROM_FILE = "quantized_bias.mem";
    localparam ADDR_WIDTH = $clog2(DATA_DEPTH);

    logic clk;
    logic rst;
    logic start;
    logic [DATA_WIDTH-1:0] data;
    logic done;

    // 實例化 ROM 控制器
    rom_controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .ROM_FILE  (ROM_FILE)
    ) dut (
        .clk  (clk),
        .rst  (rst),
        .start(start),
        .data (data),
        .done (done)
    );

    // 時鐘生成
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    // 重置任務
    task reset();
        rst   = 1'b1;
        start = 1'b0;
        #10;
        rst = 1'b0;
    endtask

    // 測試任務
    task test();
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        wait (done);
    endtask

    // 測試場景
    initial begin
        // 重置
        reset();

        // 測試讀取操作
        $display("開始 ROM 讀取操作...");
        test();
        $display("ROM 讀取操作完成。");

        // 再次測試讀取操作
        #10;
        $display("開始另一次 ROM 讀取操作...");
        test();
        $display("第二次 ROM 讀取操作完成。");

        // 結束仿真
        #10;
        $finish;
    end

    // 監控 ROM 資料輸出
    always @(posedge clk) begin
        if (done) begin
            $display("ROM 資料輸出:");
            for (int i = 0; i < DATA_DEPTH; i++) begin
                $display("data[%0d] = %0h", i, dut.rom_inst.memory[i]);
            end
        end
    end

endmodule
