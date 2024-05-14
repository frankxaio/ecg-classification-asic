module dot_product_tb;

    logic clk, rst;
    logic signed [7:0] mat_a[0:14];
    logic signed [7:0] mat_b[0:15];
    logic signed [7:0] bias[0:15];
    logic signed [7:0] result[0:14][0:15];
    logic done;

    // Instantiate the dot_product module
    linear_embedding dut (
        .clk(clk),
        .rst(rst),
        .mat_a(mat_a),
        .mat_b(mat_b),
        .bias(bias),
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

    // Read data from files
    initial begin
        $readmemb("fixed_point_data_1.txt", mat_a);
        $readmemb("embedding_wt.txt", mat_b);
        $readmemb("embedding_bs.txt", bias);
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
