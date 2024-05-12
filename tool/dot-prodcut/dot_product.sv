module dot_product (
    input clk,
    input rst,
    input signed [7:0] mat_a[0:14],
    input signed [7:0] mat_b[0:15],
    output logic signed [7:0] result[0:14][0:15],
    output logic done
);

localparam IDLE = 2'b00, CALC = 2'b01, DONE_PULSE = 2'b10;

logic [1:0] state, next_state;
logic [4:0] i, j, i_next, j_next;
logic signed [7:0] mul_result;

// State register
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        i <= 4'b0;
        j <= 4'b0;
    end else begin
        state <= next_state;
        i <= i_next;
        j <= j_next;
    end
end

// Next state logic
always_comb begin
    case (state)
        IDLE: begin
            if (i == 15 && j == 16) begin
                next_state = DONE_PULSE;
            end else begin
                next_state = CALC;
            end
        end
        CALC: begin
            if (i == 15 && j == 16) begin
                next_state = DONE_PULSE;
            end else begin
                next_state = CALC;
            end
        end
        DONE_PULSE: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

// Output logic
always_comb begin
    done = (state == DONE_PULSE);
end

// Calculation logic
always_comb begin
    case (state)
        IDLE: begin
            i_next = 4'b0;
            j_next = 4'b0;
        end
        CALC: begin
            if (j < 16) begin
                mul_result = mat_a[i] * mat_b[j];
                result[i][j] = mul_result;
                i_next = i;
                j_next = j + 1;
            end else begin
                i_next = i + 1;
                j_next = 4'b0;
            end
        end
        DONE_PULSE: begin
            i_next = i;
            j_next = j;
        end
        default: begin
            i_next = i;
            j_next = j;
        end
    endcase
end

endmodule