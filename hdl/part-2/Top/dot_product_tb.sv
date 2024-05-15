`timescale 1ns / 1ps

module dot_product_tb;
    logic clk;
    logic rst;
    logic signed [7:0] ecg_input[0:14];
    logic signed [7:0] wt[0:15];
    logic signed [7:0] bias[0:15];
    logic signed [7:0] cls_token[0:15];
    logic signed [7:0] result[0:15][0:15];
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
        ecg_input = '{default: 0};
        wt = '{default: 0};
        bias = '{default: 0};

        // Reset the module
        #10;
        rst = 1'b0;

        // Provide test input values
        for (int i = 0; i < 15; i++) begin
            ecg_input[i] = i + 1;
        end

        for (int i = 0; i < 16; i++) begin
            wt[i] = 16 - i;
        end

        for (int i = 0; i < 16; i++) begin
            bias[i] = 10 - i;
        end

        cls_token = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};

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
