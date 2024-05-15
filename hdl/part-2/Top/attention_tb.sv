module attention_tb;

    parameter MATRIX_SIZE = 16;
    parameter DATA_WIDTH = 8;
    parameter FINAL_BS_CNT = 16;
    parameter FINAL_WT_CNT = 256;
    parameter KEYS_BS_CNT = 16;
    parameter KEYS_WT_CNT = 256;
    parameter QUERIES_BS_CNT = 16;
    parameter QUERIES_WT_CNT = 256;
    parameter VALUES_BS_CNT = 16;
    parameter VALUES_WT_CNT = 256;

    logic clk;
    logic rst;
    logic signed [DATA_WIDTH-1:0] final_bs[0:FINAL_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] final_wt[0:FINAL_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] keys_bs[0:KEYS_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] keys_wt[0:KEYS_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] queries_bs[0:QUERIES_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] queries_wt[0:QUERIES_WT_CNT-1];
    logic signed [DATA_WIDTH-1:0] values_bs[0:VALUES_BS_CNT-1];
    logic signed [DATA_WIDTH-1:0] values_wt[0:VALUES_WT_CNT-1];
    logic signed [7:0] mat_in[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];
    logic signed [7:0] out_matrix[0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];
    logic done;

    attention #(
        .MATRIX_SIZE(MATRIX_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .FINAL_BS_CNT(FINAL_BS_CNT),
        .FINAL_WT_CNT(FINAL_WT_CNT),
        .KEYS_BS_CNT(KEYS_BS_CNT),
        .KEYS_WT_CNT(KEYS_WT_CNT),
        .QUERIES_BS_CNT(QUERIES_BS_CNT),
        .QUERIES_WT_CNT(QUERIES_WT_CNT),
        .VALUES_BS_CNT(VALUES_BS_CNT),
        .VALUES_WT_CNT(VALUES_WT_CNT)
    ) dut (
        .clk(clk),
        .rst(rst),
        .final_bs(final_bs),
        .final_wt(final_wt),
        .keys_bs(keys_bs),
        .keys_wt(keys_wt),
        .queries_bs(queries_bs),
        .queries_wt(queries_wt),
        .values_bs(values_bs),
        .values_wt(values_wt),
        .mat_in(mat_in),
        .out_matrix(out_matrix),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus 
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;

        // Load test data 
        $readmemb("test/final_bs.txt", final_bs);
        $readmemb("test/final_wt.txt", final_wt);
        $readmemb("test/keys_bs.txt", keys_bs);
        $readmemb("test/keys_wt.txt", keys_wt);
        $readmemb("test/queries_bs.txt", queries_bs);
        $readmemb("test/queries_wt.txt", queries_wt);
        $readmemb("test/values_bs.txt", values_bs);
        $readmemb("test/values_wt.txt", values_wt);
        $readmemb("test/mat_in.txt", mat_in);

        // Release reset after 10ns
        #10 rst = 0;

        // Wait for done signal
        wait (done);

        // Check results
        $writememh("out_matrix.txt", out_matrix);

        // End simulation
        #10 $finish;
    end

endmodule
