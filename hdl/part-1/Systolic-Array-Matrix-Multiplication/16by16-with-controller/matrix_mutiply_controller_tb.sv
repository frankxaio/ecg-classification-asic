`timescale 1ns/1ps

module matrix_multiply_controller_tb;

    parameter MATRIX_SIZE = 16;
    parameter DATA_SIZE = 8;

    logic clk;
    logic reset;
    logic start;
    logic done;
    logic [DATA_SIZE-1:0] in_store_a[MATRIX_SIZE-1:0][MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] in_store_b[MATRIX_SIZE-1:0][MATRIX_SIZE-1:0];
    logic [DATA_SIZE-1:0] out_matrix[MATRIX_SIZE*MATRIX_SIZE-1:0];

    matrix_multiply_controller #(
        .MATRIX_SIZE(MATRIX_SIZE),
        .DATA_SIZE(DATA_SIZE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .in_store_a(in_store_a),
        .in_store_b(in_store_b),
        .out_matrix(out_matrix)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        start = 0;
        in_store_a = '{ '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1}};
        
        in_store_b = '{ '{2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3},
                       '{1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2},
                       '{2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2},
                       '{2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2}};

        #10;
        reset = 0;
        #10;
        start = 1;
        #10;
        start = 0;
        wait(done);
        #10;
        $display("Matrix A:");
        for (int i = 0; i < MATRIX_SIZE; i++) begin
            for (int j = 0; j < MATRIX_SIZE; j++) begin
                $write("%d ", in_store_a[i][j]);
            end
            $display();
        end
        $display("Matrix B:");
        for (int i = 0; i < MATRIX_SIZE; i++) begin
            for (int j = 0; j < MATRIX_SIZE; j++) begin
                $write("%d ", in_store_b[i][j]);
            end
            $display();
        end
        $display("Output Matrix:");
        for (int i = 0; i < MATRIX_SIZE; i++) begin
            for (int j = 0; j < MATRIX_SIZE; j++) begin
                $write("%d ", out_matrix[i*MATRIX_SIZE+j]);
            end
            $display();
        end
        $finish;
    end

endmodule