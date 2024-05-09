module fixedpoint#(
    parameter WIDTH = 8
)
(
    input clk,
    input rst, 
    input signed [WIDTH-1:0] a,
    input signed [WIDTH-1:0] b,
    output logic signed [WIDTH:0] sum_ab,
    output logic signed [WIDTH:0] diff_ab,
    output logic signed [WIDTH*2-1:0] prod_ab,
    output logic signed [WIDTH*2-1:0] quot_ab,
    output [WIDTH-1:0] prob_ab_slc
);
    always_ff @( posedge clk ) begin : blockName
        if(rst)begin
            sum_ab <= 0;
            diff_ab <= 0;
            prod_ab <= 0;
            quot_ab <= 0;
        end
        else begin
            sum_ab <= a + b;
            diff_ab <= a - b;
            prod_ab <= a * b;
            quot_ab <= a / b;
        end
    end

    // 取 prob_ab_slc 為中間的八個位元
    //* fixed-point: 8-bit = 2-bit integer + 6-bit fraction
    assign prob_ab_slc = {prod_ab[(WIDTH*2-1)-2:(WIDTH*2-1)-9]};


endmodule