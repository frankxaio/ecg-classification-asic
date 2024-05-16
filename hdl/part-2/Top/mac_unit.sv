module mac_unit #(
    parameter DATA_SIZE = 8
) (
    input logic signed [DATA_SIZE-1:0] in_a,
    input logic signed [DATA_SIZE-1:0] in_b,
    input logic clk,
    reset,
    output reg signed [DATA_SIZE-1:0] out_a,
    output reg signed [DATA_SIZE-1:0] out_b,
    output reg signed [DATA_SIZE-1:0] out_sum
);  // appropriate sizing ensured in the top module

    always_ff @(posedge clk) begin
        if (reset) begin
            out_a   <= 0;
            out_b   <= 0;
            out_sum <= 0;
        end else begin
            out_a   <= in_a;
            out_b   <= in_b;
            out_sum <= (in_a * in_b) + out_sum;
        end
    end
endmodule
