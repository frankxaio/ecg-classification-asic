// Code your design here
`timescale 1ns / 1ps


// Systolic Array top level module. 

module mmu #(
    parameter depth = 4,
    bit_width = 8,
    acc_width = 32,
    size = 4
) (
    clk,
    control,
    data_arr,
    wt_arr,
    acc_out
);
    input clk;
    input control;
    input [(bit_width*depth)-1:0] data_arr;
    input [(bit_width*depth)-1:0] wt_arr;
    output reg [acc_width*size-1:0] acc_out;

    // Implement your logic below based on the MAC unit design in MAC.v

    wire [bit_width-1:0] wt_out11;
    wire [bit_width-1:0] wt_out21;
    wire [bit_width-1:0] wt_out31;
    wire [bit_width-1:0] wt_out41;

    wire [bit_width-1:0] wt_out12;
    wire [bit_width-1:0] wt_out22;
    wire [bit_width-1:0] wt_out32;
    wire [bit_width-1:0] wt_out42;

    wire [bit_width-1:0] wt_out13;
    wire [bit_width-1:0] wt_out23;
    wire [bit_width-1:0] wt_out33;
    wire [bit_width-1:0] wt_out43;

    //----------------------------------
    wire [bit_width-1:0] data_out11;
    wire [bit_width-1:0] data_out21;
    wire [bit_width-1:0] data_out31;
    wire [bit_width-1:0] data_out41;

    wire [bit_width-1:0] data_out12;
    wire [bit_width-1:0] data_out22;
    wire [bit_width-1:0] data_out32;
    wire [bit_width-1:0] data_out42;

    wire [bit_width-1:0] data_out13;
    wire [bit_width-1:0] data_out23;
    wire [bit_width-1:0] data_out33;
    wire [bit_width-1:0] data_out43;

    wire [bit_width-1:0] data_out14;
    wire [bit_width-1:0] data_out24;
    wire [bit_width-1:0] data_out34;
    wire [bit_width-1:0] data_out44;
    //-----------------------------------------
    wire [acc_width-1:0] acc_out11;
    wire [acc_width-1:0] acc_out21;
    wire [acc_width-1:0] acc_out31;
    wire [acc_width-1:0] acc_out41;

    wire [acc_width-1:0] acc_out12;
    wire [acc_width-1:0] acc_out22;
    wire [acc_width-1:0] acc_out32;
    wire [acc_width-1:0] acc_out42;

    wire [acc_width-1:0] acc_out13;
    wire [acc_width-1:0] acc_out23;
    wire [acc_width-1:0] acc_out33;
    wire [acc_width-1:0] acc_out43;

    wire [acc_width-1:0] acc_out14;
    wire [acc_width-1:0] acc_out24;
    wire [acc_width-1:0] acc_out34;
    wire [acc_width-1:0] acc_out44;


    always @(posedge clk) begin
        acc_out <= {acc_out14, acc_out24, acc_out34, acc_out44};
    end





    MAC m11 (
        .clk(clk),
        .control(control),
        .data_in(data_arr[31:24]),
        .acc_in(0),
        .wt_path_in(wt_arr[31:24]),
        .acc_out(acc_out11),
        .data_out(data_out11),
        .wt_path_out(wt_out11)
    );
    MAC m21 (
        .clk(clk),
        .control(control),
        .data_in(data_out11),
        .acc_in(0),
        .wt_path_in(wt_arr[23:16]),
        .acc_out(acc_out21),
        .data_out(data_out21),
        .wt_path_out(wt_out21)
    );
    MAC m31 (
        .clk(clk),
        .control(control),
        .data_in(data_out21),
        .acc_in(0),
        .wt_path_in(wt_arr[15:8]),
        .acc_out(acc_out31),
        .data_out(data_out31),
        .wt_path_out(wt_out31)
    );
    MAC m41 (
        .clk(clk),
        .control(control),
        .data_in(data_out31),
        .acc_in(0),
        .wt_path_in(wt_arr[7:0]),
        .acc_out(acc_out41),
        .wt_path_out(wt_out41)
    );


    MAC m12 (
        .clk(clk),
        .control(control),
        .data_in(data_arr[23:16]),
        .acc_in(acc_out11),
        .wt_path_in(wt_out11),
        .acc_out(acc_out12),
        .data_out(data_out12),
        .wt_path_out(wt_out12)
    );
    MAC m22 (
        .clk(clk),
        .control(control),
        .data_in(data_out12),
        .acc_in(acc_out21),
        .wt_path_in(wt_out21),
        .acc_out(acc_out22),
        .data_out(data_out22),
        .wt_path_out(wt_out22)
    );
    MAC m32 (
        .clk(clk),
        .control(control),
        .data_in(data_out22),
        .acc_in(acc_out31),
        .wt_path_in(wt_out31),
        .acc_out(acc_out32),
        .data_out(data_out32),
        .wt_path_out(wt_out32)
    );
    MAC m42 (
        .clk(clk),
        .control(control),
        .data_in(data_out32),
        .acc_in(acc_out41),
        .wt_path_in(wt_out41),
        .acc_out(acc_out42),
        .wt_path_out(wt_out42)
    );

    MAC m13 (
        .clk(clk),
        .control(control),
        .data_in(data_arr[15:8]),
        .acc_in(acc_out12),
        .wt_path_in(wt_out12),
        .acc_out(acc_out13),
        .data_out(data_out13),
        .wt_path_out(wt_out13)
    );
    MAC m23 (
        .clk(clk),
        .control(control),
        .data_in(data_out13),
        .acc_in(acc_out22),
        .wt_path_in(wt_out22),
        .acc_out(acc_out23),
        .data_out(data_out23),
        .wt_path_out(wt_out23)
    );
    MAC m33 (
        .clk(clk),
        .control(control),
        .data_in(data_out23),
        .acc_in(acc_out32),
        .wt_path_in(wt_out32),
        .acc_out(acc_out33),
        .data_out(data_out33),
        .wt_path_out(wt_out33)
    );
    MAC m43 (
        .clk(clk),
        .control(control),
        .data_in(data_out33),
        .acc_in(acc_out42),
        .wt_path_in(wt_out42),
        .acc_out(acc_out43),
        .wt_path_out(wt_out43)
    );

    MAC m14 (
        .clk(clk),
        .control(control),
        .data_in(data_arr[7:0]),
        .acc_in(acc_out13),
        .wt_path_in(wt_out13),
        .acc_out(acc_out14),
        .data_out(data_out14)
    );
    MAC m24 (
        .clk(clk),
        .control(control),
        .data_in(data_out14),
        .acc_in(acc_out23),
        .wt_path_in(wt_out23),
        .acc_out(acc_out24),
        .data_out(data_out24)
    );
    MAC m34 (
        .clk(clk),
        .control(control),
        .data_in(data_out24),
        .acc_in(acc_out33),
        .wt_path_in(wt_out33),
        .acc_out(acc_out34),
        .data_out(data_out34)
    );
    MAC m44 (
        .clk(clk),
        .control(control),
        .data_in(data_out34),
        .acc_in(acc_out43),
        .wt_path_in(wt_out43),
        .acc_out(acc_out44)
    );






endmodule
