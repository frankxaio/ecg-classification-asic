`timescale 1ns / 10ps

module fixedpoint_tb ();

    localparam CLK_PERIOD = 10;

    parameter WIDTH = 8;

    logic clk = 1'b0;
    logic rst = 1'b0;
    logic signed [WIDTH-1:0] a, b;
    logic signed [WIDTH:0] sum_ab;
    logic signed [WIDTH:0] diff_ab;
    logic signed [WIDTH*2-1:0] prod_ab;
    logic signed [WIDTH*2-1:0] quot_ab;

    fixedpoint uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .sum_ab(sum_ab),
        .diff_ab(diff_ab),
        .prod_ab(prod_ab),
        .quot_ab(quot_ab)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        //* fixed-point: 8-bit = 2-bit integer + 6-bit fraction
        a   = 8'b1110_1100;  // -0.3125
        b   = 8'b0001_0110;  // 0.34375

        rst = #(CLK_PERIOD * 10) 1'b0;

        repeat (10) begin
            @(posedge clk);
        end

        $display("prod_ab = %b", prod_ab);

        #1000;
        $finish;

    end


    always begin
        clk = #(CLK_PERIOD/2) ~clk;
    end

    initial begin
        $dumpfile("fixedpoint_tb.vcd");
        $dumpvars;
    end

endmodule
