module linear_embedding_tb;

    logic clk, rst;
    logic signed [7:0] result[0:14][0:15];
    logic done;

    // Instantiate the linear_embedding module
    linear_embedding dut (
        .clk(clk),
        .rst(rst),
        .result(result),
        .done(done)
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    // Stimulus and checking
    initial begin
        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;

        wait (done);
        @(posedge clk);

        // Print the result
        $display("Result:");
        for (int i = 0; i < 15; i++) begin
            for (int j = 0; j < 16; j++) begin
                $write("%d ", result[i][j]);
            end
            $display();
        end

        $finish;
    end

endmodule
