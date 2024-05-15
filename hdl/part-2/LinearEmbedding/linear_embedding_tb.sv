`timescale 1ns/1ps

module linear_embedding_tb();
    localparam CLK_PERIOD = 10; // 100 MHz clock

    logic clk, rst;
    logic signed [7:0] ecg_input [0:14];
    logic signed [7:0] result [0:14][0:15];
    logic done;

    // Instantiate the module under test
    linear_embedding dut (
        .clk(clk),
        .rst(rst),
        .ecg_input(ecg_input),
        .result(result),
        .done(done)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test vectors
    localparam NUM_TESTS = 2;
    logic signed [7:0] input_data [0:NUM_TESTS-1][0:14];
    logic signed [7:0] expected_result [0:NUM_TESTS-1][0:15];

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        ecg_input = '{default:0};

        // Reset the design
        #(CLK_PERIOD*2) rst = 0;

        // Apply test vectors
        for (int i = 0; i < NUM_TESTS; i++) begin
            // Set input data
            ecg_input = input_data[i];

            // Wait for the done signal
            @(posedge done);

            // Check the result
            // if (result !== expected_result[i]) begin
            //     $error("Test %0d failed: Expected %0p, got %0p", i, expected_result[i], result);
            // end else begin
            //     $info("Test %0d passed", i);
            // end
        end

        // Finish the simulation
        $finish;
    end

    // Define test vectors here
    initial begin
        // Test vector 1
        input_data[0] = '{8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15};
        // expected_result[0] = '{8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};

        // Test vector 2
        input_data[1] = '{8'd15, 8'd14, 8'd13, 8'd12, 8'd11, 8'd10, 8'd9, 8'd8, 8'd7, 8'd6, 8'd5, 8'd4, 8'd3, 8'd2, 8'd1};
        // expected_result[1] = '{8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    end

endmodule