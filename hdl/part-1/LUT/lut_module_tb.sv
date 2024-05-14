`timescale 1ns/1ps

module lut_module_tb();

// Parameters
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 8;

// Inputs
reg clk;
reg rst;
reg start;
reg [ADDR_WIDTH-1:0] addr;

// Outputs
wire [DATA_WIDTH-1:0] data;
wire done;

// Instantiate the Unit Under Test (UUT)
lut_module #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .addr(addr),
    .data(data),
    .done(done)
);

// Clock generation
always #5 clk = ~clk;

// Test vectors
initial begin
    // Initialize inputs
    clk = 0;
    rst = 1;
    start = 0;
    addr = 0;

    // Reset the UUT
    #10 rst = 0;

    // Test case 1: Read classifier_bs[0]
    #10 start = 1;
    addr = 32'h0000_0001;
    #10 start = 0;
    @(posedge done) $display("Test case 1: classifier_bs[0] = %h", data);

    // Test case 2: Read classifier_wt[10]
    #10 start = 1;
    addr = 32'h0000_000A;
    #10 start = 0;
    @(posedge done) $display("Test case 2: classifier_wt[10] = %h", data);

    // Test case 3: Read embedding_wt[5]
    #10 start = 1;
    addr = 32'h0001_0005;
    #10 start = 0;
    @(posedge done) $display("Test case 3: embedding_wt[5] = %h", data);

    // Test case 4: Read final_wt[100]
    #10 start = 1;
    addr = 32'h0002_0064;
    #10 start = 0;
    @(posedge done) $display("Test case 4: final_wt[100] = %h", data);

    // Finish simulation
    #100 $finish;
end

endmodule