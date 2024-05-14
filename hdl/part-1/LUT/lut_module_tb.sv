`timescale 1ns / 1ps

module lut_module_tb ();

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 8;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [ADDR_WIDTH-1:0] addr;

    // Outputs
    wire [DATA_WIDTH-1:0] data_o;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    lut_module #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk  (clk),
        .rst  (rst),
        .start(start),
        .addr (addr),
        .data_o (data_o),
        .done (done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test vectors
    initial begin
        // Initialize inputs
        clk   = 0;
        rst   = 1;
        start = 0;
        addr  = 0;

        // Reset the UUT
        #10 rst = 0;

        // Test case 1: Read classifier_bs[0]
        #10 start = 1;
        addr = 32'h0000_0001;
        #10 start = 0;

        @(posedge done) begin
            $display("Test case 1: classifier_bs[0] = %b", data_o);
        end

        // Test case 2: Read classifier_wt[10]
        #10 start = 1;
        addr = 32'h0000_0002;
        #10 start = 0;
        @(posedge done) $display("Test case 2: classifier_wt[10] = %b", data_o);

        // Test case 3: Read embedding_bs[5]
        #10 start = 1;
        addr = 32'h0000_0003;
        #10 start = 0;
        @(posedge done) $display("Test case 3: embedding_bs[5] = %b", data_o);

        // Test case 4: Read embedding_wt[5]
        #10 start = 1;
        addr = 32'h0000_0004;
        #10 start = 0;
        @(posedge done) $display("Test case 4: embedding_wt[5] = %b", data_o);

        // Test case 5: Read cls_token_wt[5]
        #10 start = 1;
        addr = 32'h0000_0005;
        #10 start = 0;
        @(posedge done) $display("Test case 5: cls_token_wt[5] = %b", data_o);

        // Test case 6: Read final_bs[5]
        #10 start = 1;
        addr = 32'h0000_0006;
        #10 start = 0;
        @(posedge done) $display("Test case 6: final_bs[5] = %b", data_o);

        // Test case 7: Read final_wt[100]
        #10 start = 1;
        addr = 32'h0000_0007;
        #10 start = 0;
        @(posedge done) $display("Test case 7: final_wt[100] = %b", data_o);

        // Test case 8: Read keys_bs[5]
        #10 start = 1;
        addr = 32'h0000_0008;
        #10 start = 0;
        @(posedge done) $display("Test case 8: keys_bs[5] = %b", data_o);

        // Test case 9: Read keys_wt[100]
        #10 start = 1;
        addr = 32'h0000_0009;
        #10 start = 0;
        @(posedge done) $display("Test case 9: keys_wt[100] = %b", data_o);

        // Test case 10: Read queries_bs[5]
        #10 start = 1;
        addr = 32'h0000_000A;
        #10 start = 0;
        @(posedge done) $display("Test case 10: queries_bs[5] = %b", data_o);

        // Test case 11: Read queries_wt[100]
        #10 start = 1;
        addr = 32'h0000_000B;
        #10 start = 0;
        @(posedge done) $display("Test case 11: queries_wt[100] = %b", data_o);

        // Test case 12: Read values_bs[5]
        #10 start = 1;
        addr = 32'h0000_000C;
        #10 start = 0;
        @(posedge done) $display("Test case 12: values_bs[5] = %b", data_o);

        // Test case 13: Read values_wt[100]
        #10 start = 1;
        addr = 32'h0000_000D;
        #10 start = 0;
        @(posedge done) $display("Test case 13: values_wt[100] = %b", data_o);

        // Test case 14: Read mlp0_bs[5]
        #10 start = 1;
        addr = 32'h0000_000E;
        #10 start = 0;
        @(posedge done) $display("Test case 14: mlp0_bs[5] = %b", data_o);

        // Test case 15: Read mlp0_wt[100]
        #10 start = 1;
        addr = 32'h0000_000F;
        #10 start = 0;
        @(posedge done) $display("Test case 15: mlp0_wt[100] = %b", data_o);

        // Test case 16: Read mlp1_bs[5]
        #10 start = 1;
        addr = 32'h0000_0010;
        #10 start = 0;
        @(posedge done) $display("Test case 16: mlp1_bs[5] = %b", data_o);

        // Test case 17: Read mlp1_wt[100]
        #10 start = 1;
        addr = 32'h0000_0011;
        #10 start = 0;
        @(posedge done) $display("Test case 17: mlp1_wt[100] = %b", data_o);

        #10 start = 1;
        addr = 32'h0000_0012;
        #10 start = 0;
        @(posedge done) $display("Test case 17: ps_wt[100] = %b", data_o);



        // Finish simulation
        #100 $finish;
    end

endmodule
