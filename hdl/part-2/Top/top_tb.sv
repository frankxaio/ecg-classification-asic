`timescale 1ns / 1ps

module top_tb;

    logic clk;
    logic rst;
    logic start;
    logic [7:0] ecg_input;
    logic [3:0] classifier;

    top dut (
        .start(start),
        .clk(clk),
        .rst(rst),
        .ecg_input(ecg_input),
        .classifier(classifier)
    );

    // Clock generation
    always begin
        clk = 1'b1;
        #5;
        clk = 1'b0;
        #5;
    end

    // Reset generation
    initial begin
        rst   = 1'b1;
        start = 1'b1;
        #20;
        start = 1'b0;
        rst   = 1'b0;
    end

    // ECG input data
    initial begin
        #20;
        @(posedge clk) ecg_input = 8'b00010000;
        @(posedge clk) ecg_input = 8'b00001111;
        @(posedge clk) ecg_input = 8'b00000111;
        @(posedge clk) ecg_input = 8'b00000011;
        @(posedge clk) ecg_input = 8'b00000000;
        @(posedge clk) ecg_input = 8'b00000011;
        @(posedge clk) ecg_input = 8'b00000101;
        @(posedge clk) ecg_input = 8'b00000110;
        @(posedge clk) ecg_input = 8'b00000110;
        @(posedge clk) ecg_input = 8'b00000111;
        @(posedge clk) ecg_input = 8'b00000111;
        @(posedge clk) ecg_input = 8'b00000111;
        @(posedge clk) ecg_input = 8'b00000111;
        @(posedge clk) ecg_input = 8'b00000111;
        @(posedge clk) ecg_input = 8'b00000111;
    end

    // Simulate for a certain duration
    initial begin
        #200;
        $finish;
    end

    // Monitor the state and classifier output
    always @(posedge clk) begin
        $display("Time: %0t, State: %s, Classifier: %b", $time, dut.state.name(), classifier);
    end

endmodule
