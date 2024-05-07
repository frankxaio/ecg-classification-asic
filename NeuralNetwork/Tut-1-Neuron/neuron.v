`timescale 1ns / 1ps

//`define DEBUG
`include "include.v"

module neuron #(parameter layerNo = 0,
                    neuronNo = 0,
                    numWeight = 784,
                    dataWidth = 16,     //! 每個 neuron 的輸入和輸出的寬度。
                    sigmoidSize = 5,
                    weightIntWidth = 1, //! 權重的整數部分的寬度。
                    actType = "relu",
                    biasFile = "",
                    weightFile = "")
    (input clk,
     input rst,
     input [dataWidth-1:0] myinput,  //! 我的輸入。
     input myinputValid,             //! 我的輸入是否有效。
     input weightValid,              //! 權重是否有效。
     input biasValid,                //! 偏置是否有效。
     input [31:0] weightValue,       //! 權重值。
     input [31:0] biasValue,         //! bias 值。
     input [31:0] config_layer_num,  //! 當前的層數
     input [31:0] config_neuron_num, //! 當前層的第幾號neuron
     output[dataWidth-1:0] out,      //! 輸出
     output reg outvalid);           //! 輸出是否有效

    parameter addressWidth = $clog2(numWeight);

    reg         wen;                    //! write enable
    wire        ren;                    //! read enable
    reg [addressWidth-1:0] w_addr;
    reg [addressWidth:0]   r_addr;      //! read address has to reach until numWeight hence width is 1 bit more
    reg [dataWidth-1:0]  w_in;          //! input to the memory
    wire [dataWidth-1:0] w_out;         //! output from the memory
    reg [2*dataWidth-1:0]  mul;         //! multiplication result
    reg [2*dataWidth-1:0]  sum;         //! sum of multiplication result and bias
    reg [2*dataWidth-1:0]  bias;        //! bias value
    reg [31:0]    biasReg[0:0];         //! bias value, 32-bit float value
    reg         weight_valid;           //! weight value valid
    reg         mult_valid;             //! multiplication valid
    wire        mux_valid;              //! mux valid
    reg         sigValid;               //! sigmoid valid
    wire [2*dataWidth:0] comboAdd;      //! sum of multiplication and bias
    wire [2*dataWidth:0] BiasAdd;       //! sum of bias and sum
    reg  [dataWidth-1:0] myinputd;      //! input to the neuron
    reg muxValid_d;                     //! mux valid delayed
    reg muxValid_f;                     //! mux valid flip flop
    reg addr = 0;                       //! address for bias

    //* Loading weight values into the memory
    always @(posedge clk) begin:loadWeight
        if (rst) begin
            w_addr <= {addressWidth{1'b1}};
            wen    <= 0;
        end
        else if (weightValid & (config_layer_num == layerNo) & (config_neuron_num == neuronNo)) begin
            w_in   <= weightValue;
            w_addr <= w_addr + 1;
            wen    <= 1;
        end
        else
            wen <= 0;
    end

    assign mux_valid = mult_valid;
    assign comboAdd  = mul + sum;
    assign BiasAdd   = bias + sum;
    assign ren       = myinputValid;

`ifdef pretrained

    initial begin
        // Read bias values from file, 以 binary 的格式
        $readmemb(biasFile,biasReg);
    end
    always @(posedge clk) begin
        bias <= {biasReg[addr][dataWidth-1:0],{dataWidth{1'b0}}};
    end
`else
    always @(posedge clk) begin
        if (biasValid & (config_layer_num == layerNo) & (config_neuron_num == neuronNo)) begin
            bias <= {biasValue[dataWidth-1:0],{dataWidth{1'b0}}};
        end
    end
`endif


    //* Read address for bias
    always @(posedge clk) begin : biasAddr
        if (rst|outvalid)
            r_addr <= 0;
        else if (myinputValid)
            r_addr <= r_addr + 1;
    end

    //* Multiplication of input and weight
    always @(posedge clk) begin : mulBlock
        // 兩個數字相乘寬度會變成兩個數字的寬度相加
        // 所以 mul 的寬度是 dataWidth * 2
        mul <= $signed(myinputd) * $signed(w_out);
    end

    //* Addition of bias and multiplication result
    always @(posedge clk) begin : addBlock
        if (rst|outvalid)
            sum <= 0;
        else if ((r_addr == numWeight) & muxValid_f) begin
            // Overflow 的情況
            // If bias and sum are positive and after adding bias to sum, if sign bit becomes 1, saturate
            if (!bias[2*dataWidth-1] &!sum[2*dataWidth-1] & BiasAdd[2*dataWidth-1]) begin
                sum[2*dataWidth-1]   <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            // Underflow 的情況
            //If bias and sum are negative and after addition if sign bit is 0, saturate
            else if (bias[2*dataWidth-1] & sum[2*dataWidth-1] &  !BiasAdd[2*dataWidth-1]) begin
                sum[2*dataWidth-1]   <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            // neither overflow nor underflow
            else
                sum <= BiasAdd;
        end
        else if (mux_valid) begin
            if (!mul[2*dataWidth-1] & !sum[2*dataWidth-1] & comboAdd[2*dataWidth-1]) begin
                sum[2*dataWidth-1]   <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            else if (mul[2*dataWidth-1] & sum[2*dataWidth-1] & !comboAdd[2*dataWidth-1]) begin
                sum[2*dataWidth-1]   <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            else
                sum <= comboAdd;
        end
    end

    // Valid signal generation
    always @(posedge clk) begin : validBlock
        myinputd     <= myinput;
        weight_valid <= myinputValid;
        mult_valid   <= weight_valid;
        sigValid     <= ((r_addr == numWeight) & muxValid_f) ? 1'b1 : 1'b0;
        outvalid   <= sigValid;
        muxValid_d <= mux_valid;
        muxValid_f <= !mux_valid & muxValid_d;
    end


    //Instantiation of Memory for Weights
    Weight_Memory #(.numWeight(numWeight),
                    .neuronNo(neuronNo),
                    .layerNo(layerNo),
                    .addressWidth(addressWidth),
                    .dataWidth(dataWidth),
                    .weightFile(weightFile)) WM(
                      .clk(clk),
                      .wen(wen),
                      .ren(ren),
                      .wadd(w_addr),
                      .radd(r_addr),
                      .win(w_in),
                      .wout(w_out)
                  );

    //* Activation function instantiation
    generate
        if (actType == "sigmoid") begin:siginst
            //Instantiation of ROM for sigmoid
            Sig_ROM #(.inWidth(sigmoidSize),.dataWidth(dataWidth)) s1(
                        .clk(clk),
                        .x(sum[2*dataWidth-1-:sigmoidSize]),
                        .out(out)
                    );
        end
        else begin:ReLUinst
            ReLU #(.dataWidth(dataWidth),.weightIntWidth(weightIntWidth)) s1 (
                     .clk(clk),
                     .x(sum),
                     .out(out)
                 );
        end
    endgenerate

`ifdef DEBUG

    always @(posedge clk) begin
        if (outvalid)
            $display(neuronNo,,,,"%b",out);
    end
`endif
endmodule
