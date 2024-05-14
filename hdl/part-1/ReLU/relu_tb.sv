module relu_tb;

    // 宣告訊號
    logic signed [7:0] data_in[15:0];
    logic [7:0] data_out[15:0];

    // 例化 ReLU module
    relu dut (
        .data_in (data_in),
        .data_out(data_out)
    );

    // 測試 pattern
    initial begin
        // Pattern 1: 15 組 16 個 8-bit 資料
        $display("Pattern 1:");
        for (int i = 0; i < 15; i++) begin
            for (int j = 0; j < 16; j++) begin
                data_in[j] = $random % 256 - 128;  // 產生 -128 到 127 之間的隨機數
            end
            #10;
            $display("Input:  %p", data_in);
            $display("Output: %p", data_out);
        end

        // Pattern 2: 16 組 16 個 8-bit 資料
        $display("Pattern 2:");
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                data_in[j] = $random % 256 - 128;  // 產生 -128 到 127 之間的隨機數
            end
            #10;
            $display("Input:  %p", data_in);
            $display("Output: %p", data_out);
        end

        $finish;
    end

endmodule
