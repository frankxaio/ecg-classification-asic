module rom_controller #(
    parameter DATA_WIDTH = 16,  //! 每一個數據的寬度
    parameter DATA_DEPTH = 16,  //! ROM 的深度
    parameter ROM_FILE = "rom_data.mem",  //! ROM 文件名
    localparam ADDR_WIDTH = $clog2(DATA_DEPTH)  //! 地址寬度
) (
    input logic clk,
    input logic rst,
    input logic start,
    output logic [DATA_WIDTH-1:0] data,
    output logic done
);

    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] rom_data;

    rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH),
        .ROM_FILE  (ROM_FILE)
    ) rom_inst (
        .addr(addr),
        .data(rom_data)
    );

    typedef enum {
        IDLE,
        READ
    } state_t;
    state_t state, next_state;

    logic [ADDR_WIDTH-1:0] addr_cnt;

    // state 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    // next state
    always_comb begin
        case (state)
            IDLE: next_state = start ? READ : IDLE;
            READ: next_state = (addr_cnt == DATA_DEPTH - 1) ? IDLE : READ;
            default: next_state = IDLE;
        endcase
    end

    // addr counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst) addr_cnt <= '0;
        else if (state == READ) addr_cnt <= addr_cnt + 1;
    end

    // output 
    assign addr = addr_cnt;
    assign data = rom_data;
    assign done = (state == READ) && (addr_cnt == DATA_DEPTH - 1);

endmodule