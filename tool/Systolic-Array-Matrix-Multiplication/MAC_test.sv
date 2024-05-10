// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

// sample testbench for a 4X4 Systolic Array

module MAC_tb;

    // Inputs
    reg clk;
    reg control;
    reg [7:0] data_in;
    reg [31:0] acc_in;
    reg [7:0] wt_path_in;


    // Outputs
    wire [31:0] acc_out;
    wire [7:0] data_out;
    wire [7:0] wt_path_out;


    // Instantiate the Unit Under Test (UUT)
    MAC uut (
        .clk(clk),
        .control(control),
        .data_in(data_in),
        .acc_in(acc_in),
        .wt_path_in(wt_path_in),
        .acc_out(acc_out),
        .data_out(data_out),
        .wt_path_out(wt_path_out)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end


    initial begin
        // Initialize Inputs
        clk = 0;
        control = 0;
        data_in = 0;
        acc_in = 0;
        wt_path_in = 0;

        // Wait 100 ns for global reset to finish
        #5;
    end
    // Add stimulus here
    always #5 clk = !clk;


    initial begin
        @(posedge clk);
        control = 1;
        wt_path_in = 8'd2;
        #20 @(posedge clk);
        control = 0;
        wt_path_in = 8'd3;
        acc_in = 8'd2;
        data_in = 8'd1;
        @(posedge clk);
        wt_path_in = 8'd4;
        acc_in = 8'd3;
        data_in = 8'd4;
        @(posedge clk);
        wt_path_in = 8'd6;
        acc_in = 8'd3;
        data_in = 8'd4;
        #40 $finish;

    end

endmodule
