`timescale 1ns/1ps

module lut_controller_tb;

    localparam CLK_PERIOD = 10;
    localparam DATA_WIDTH = 8;

    logic                  clk;
    logic                  rst;
    logic                  start;
    logic [DATA_WIDTH-1:0] classifier_bs[0:5];
    logic [DATA_WIDTH-1:0] classifier_wt[0:95];
    logic [DATA_WIDTH-1:0] embedding_bs[0:15];
    logic [DATA_WIDTH-1:0] embedding_wt[0:15];
    logic [DATA_WIDTH-1:0] cls_token_wt[0:15];
    logic [DATA_WIDTH-1:0] final_bs[0:15];
    logic [DATA_WIDTH-1:0] final_wt[0:255];
    logic [DATA_WIDTH-1:0] keys_bs[0:15];
    logic [DATA_WIDTH-1:0] keys_wt[0:255];
    logic [DATA_WIDTH-1:0] queries_bs[0:15];
    logic [DATA_WIDTH-1:0] queries_wt[0:255];
    logic [DATA_WIDTH-1:0] values_bs[0:15];
    logic [DATA_WIDTH-1:0] values_wt[0:255];
    logic [DATA_WIDTH-1:0] mlp0_bs[0:15];
    logic [DATA_WIDTH-1:0] mlp0_wt[0:255];
    logic [DATA_WIDTH-1:0] mlp1_bs[0:15];
    logic [DATA_WIDTH-1:0] mlp1_wt[0:255];
    logic [DATA_WIDTH-1:0] ps_wt[0:255];
    logic                  done;

    // Instantiate the top module
    lut_controller dut (
        .clk           (clk),
        .rst           (rst),
        .start         (start),
        .classifier_bs (classifier_bs),
        .classifier_wt (classifier_wt),
        .embedding_bs  (embedding_bs),
        .embedding_wt  (embedding_wt),
        .cls_token_wt  (cls_token_wt),
        .final_bs      (final_bs),
        .final_wt      (final_wt),
        .keys_bs       (keys_bs),
        .keys_wt       (keys_wt),
        .queries_bs    (queries_bs),
        .queries_wt    (queries_wt),
        .values_bs     (values_bs),
        .values_wt     (values_wt),
        .mlp0_bs       (mlp0_bs),
        .mlp0_wt       (mlp0_wt),
        .mlp1_bs       (mlp1_bs),
        .mlp1_wt       (mlp1_wt),
        .ps_wt         (ps_wt),
        .done          (done)
    );

    // Clock generation
    always begin
        clk = 1'b1;
        #(CLK_PERIOD/2);
        clk = 1'b0;
        #(CLK_PERIOD/2);
    end

    // Reset generation
    initial begin
        rst = 1'b1;
        #(CLK_PERIOD*2);
        rst = 1'b0;
    end

    // Stimulus
    initial begin
        start = 1'b0;
        #(CLK_PERIOD*4);
        start = 1'b1;
        #(CLK_PERIOD);
        start = 1'b0;
        wait(done);
        #(CLK_PERIOD);
        $finish;
    end

    // Verify the output
    initial begin
        wait(done);
        $display("Classifier Bias:");
        for (int i = 0; i < 6; i++) begin
            $display("classifier_bs[%0d] = %0d", i, classifier_bs[i]);
        end
        $display("Classifier Weight:");
        for (int i = 0; i < 96; i++) begin
            $display("classifier_wt[%0d] = %0d", i, classifier_wt[i]);
        end
        // Add similar display statements for other memory arrays
        // ...
    end

endmodule