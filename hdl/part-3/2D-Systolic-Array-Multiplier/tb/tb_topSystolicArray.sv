`timescale 1ns/1ps

module tb_topSystolicArray ();
    // Parameters
    parameter int unsigned N = 4;

    // Signals
    logic clk;
    logic arst;
    logic [N-1:0][N-1:0][7:0] a;
    logic [N-1:0][N-1:0][7:0] b;
    logic validInput;
    logic [N-1:0][N-1:0][7:0] c;
    logic validResult;

    // Q4.4 representation
    typedef logic signed [7:0] q4_4_t;

    // Expected result matrix
    logic [N-1:0][N-1:0][7:0] expected_c;

    // Instantiate the Unit Under Test (UUT)
    topSystolicArray uut (
        .i_clk(clk),
        .i_arst(arst),
        .i_a(a),
        .i_b(b),
        .i_validInput(validInput),
        .o_c(c),
        .o_validResult(validResult)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // FSDB dumping
    initial begin
        // RTL 
        // $fsdbDumpfile("tb_topSystolicArray.fsdb");
        // $fsdbDumpvars(0, tb_topSystolicArray);
        // $fsdbDumpMDA();

        // Gate-level 
        $sdf_annotate("topSystolicArray.sdf", uut);
        $fsdbDumpfile("tb_topSystolicArray.fsdb");
        $fsdbDumpvars();
        $fsdbDumpMDA();
    end

    // VCD dumping
    // initial begin
    //     $dumpfile("tb_topSystolicArray.vcd");
    //     $dumpvars(0, tb_topSystolicArray);
    // end

    // Test stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        arst = 1;
        a = '0;
        b = '0;
        validInput = 0;

        // Reset
        #10 arst = 0;

        // Test case 1
        #10;
        a = '{
            '{8'b00001000, 8'b11111000, 8'b00001100, 8'b00010000},  // 0.5, -0.5, 0.75, 1.0
            '{8'b00010000, 8'b00001100, 8'b11110000, 8'b00010100},  // 1.0, 0.75, -1.0, 1.25
            '{8'b00001100, 8'b00010000, 8'b00010100, 8'b11101100},  // 0.75, 1.0, 1.25, -1.25
            '{8'b00010000, 8'b00011000, 8'b00001000, 8'b00001100}  // 1.0, 1.5, 0.5, 0.75
        };
        b = '{
            '{8'b00010100, 8'b11110000, 8'b00001100, 8'b00010000},  // 1.25, -1.0, 0.75, 1.0
            '{8'b00010000, 8'b00001100, 8'b00001000, 8'b11110100},  // 1.0, 0.75, 0.5, -0.75
            '{8'b00001100, 8'b00010000, 8'b00001000, 8'b00010100},  // 0.75, 1.0, 0.5, 1.25
            '{8'b00001000, 8'b00000100, 8'b00010100, 8'b00010000}  // 0.5, 0.25, 1.25, 1.0
        };
        validInput = 1;

        #10 validInput = 0;

        // Wait for result
        @(negedge validResult);

        $display("\nActual result matrix c:");

        foreach (c[i, j]) $display("\tValue of c[%0d][%0d]=%0h", i, j, c[i][j]);

        // foreach (c[i]) foreach (c[j]) $display("\tValue of c[%0d][%0d]=%0h", i, j, c[i][j]);

        // Add more test cases here if needed

        // Finish simulation
        #100 $finish;
    end

    // Optional: Add assertions here

endmodule
