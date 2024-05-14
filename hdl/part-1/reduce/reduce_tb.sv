module reduce_tb;

    logic clk;
    logic rst;
    logic enable;
    logic [7:0] matrix_in[15:0][15:0];
    logic [7:0] matrix_out[15:0];
    logic done;

    reduce dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .matrix_in(matrix_in),
        .matrix_out(matrix_out),
        .done(done)
    );

    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    initial begin
        rst = 1;
        enable = 0;
        matrix_in = '{default: 0};
        #10;
        rst = 0;
        #10;

        $display("Test Case 1:");
        enable = 1;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                matrix_in[i][j] = i + j;
            end
        end
        wait (done);
        enable = 0;
        $display("Input Matrix:");
        print_matrix_in(matrix_in);
        $display("Output Matrix:");
        print_matrix_out(matrix_out);
        #10;

        $display("Test Case 2:");
        enable = 1;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                matrix_in[i][j] = $random;
            end
        end
        wait (done);
        enable = 0;
        $display("Input Matrix:");
        print_matrix_in(matrix_in);
        $display("Output Matrix:");
        print_matrix_out(matrix_out);
        #10;

        $finish;
    end

    task print_matrix_in(logic [7:0] matrix[15:0][15:0]);
        for (int i = 0; i < 16; i++) begin
            $write("Row %2d: ", i);
            for (int j = 0; j < 16; j++) begin
                $write("%3d ", matrix[i][j]);
            end
            $display;
        end
    endtask

    task print_matrix_out(logic [7:0] matrix[15:0]);
        $write("Output: ");
        for (int i = 0; i < 16; i++) begin
            $write("%3d ", matrix[i]);
        end
        $display;
    endtask

endmodule
