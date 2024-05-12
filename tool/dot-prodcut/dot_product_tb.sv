`timescale 1ns / 1ps

module dot_product_tb;
    logic clk;
    logic rst;
    logic signed [7:0] mat_a[0:14];
    logic signed [7:0] mat_b[0:15];
    logic signed [7:0] result[0:14][0:15];
    logic done;

    // Instantiate the dot_product module
    dot_product dut (.*);

    // Clock generation
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    // Stimulus
    initial begin
        // Initialize signals
        rst   = 1'b1;
        clk   = 1'b0;
        mat_a = '{default: 0};
        mat_b = '{default: 0};

        // Reset the module
        #10;
        rst = 1'b0;

        // Provide test input values
        for (int i = 0; i < 15; i++) begin
            mat_a[i] = i + 1;
        end

        for (int i = 0; i < 16; i++) begin
            mat_b[i] = 16 - i;
        end

        // Wait for a few clock cycles
        #100;

        // Check the results
        for (int i = 0; i < 15; i++) begin
            for (int j = 0; j < 16; j++) begin
                $display("result[%0d][%0d] = %0d", i, j, result[i][j]);
            end
        end

        // End the simulation
        // #5000;
        // $finish;
    end
endmodule
