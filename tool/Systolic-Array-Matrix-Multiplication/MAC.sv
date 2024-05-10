// Code your design here
`timescale 1ns / 1ps

module MAC #(
    parameter bit_width = 8,
    acc_width = 32
) (
    clk,
    control,
    acc_in,  //a
    acc_out,  //a+b*c
    data_in,  //b
    wt_path_in,  //c
    data_out,
    wt_path_out
);



    input clk;
    input control;  // control signal used to indidate if it is weight loading or not

    input [acc_width-1:0] acc_in;  // accumulation in
    input [bit_width-1:0] data_in;  // data input or activation in
    input [bit_width-1:0] wt_path_in;  // weight data in
    output reg [acc_width-1:0] acc_out;  // accumulation out
    output reg [bit_width-1:0] data_out;  // activation out
    output reg [bit_width-1:0] wt_path_out;  // weight data out

    reg  [bit_width-1:0] wt_load_d;
    reg  [bit_width-1:0] wt_load_q;
    wire [acc_width-1:0] acc_out_d;
    wire [acc_width-1:0] mult_out;

    // implement your MAC Unit below

    always @(posedge clk) begin
        wt_path_out <= wt_path_in;
        data_out <= data_in;
        acc_out <= acc_out_d;
    end



    assign mult_out  = data_in * wt_load_q;
    assign acc_out_d = acc_in + mult_out;

    //  $display(mult_out);

    always_ff @(posedge clk) begin
        wt_load_d <= control ? wt_path_in : wt_load_q;
        wt_load_q <= wt_load_d;

    end

endmodule

