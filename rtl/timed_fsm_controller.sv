`timescale 1ns / 1ps
//Three-phase Moore FSM. Tick is a PORT because the timer
// is instantiated in a separate module by timed_fsm_top.
module timed_fsm_controller (
    input  logic clk,
    input  logic rst,
    input  logic tick,
    output logic red_led,
    output logic green_led,
    output logic yellow_led
);
    typedef enum logic [1:0] {
        RED,
        GREEN,
        YELLOW
    } state_t;

    state_t state, next_state;
    logic [1:0] elapsed;

    // State and elapsed-second registers; synchronous active-high reset.
    always_ff @(posedge clk) begin
        if (rst) begin
            state   <= RED;
            elapsed <= '0;
        end
        else begin
            state <= next_state;
            if (next_state != state)
                elapsed <= '0;
            else if (tick)
                elapsed <= elapsed + 1'b1;
        end
    end

    // Timed next-state decoder. The comparisons use the OLD elapsed
    // value, so the fourth GREEN tick occurs when elapsed == 3.
    always_comb begin
        next_state = state;
        case (state)
            RED: begin
                if (tick && elapsed == 2'b10)
                    next_state = GREEN;
            end
            GREEN: begin
                if (tick && elapsed == 2'b11)
                    next_state = YELLOW;
            end
            YELLOW: begin
                if (tick && elapsed == 2'b01)
                    next_state = RED;
            end
            default: next_state = RED;
        endcase
    end

    // Moore outputs: only the CURRENT registered state drives LEDs.
    always_comb begin
        red_led    = 1'b0;
        green_led  = 1'b0;
        yellow_led = 1'b0;
        case (state)
            RED:    red_led    = 1'b1;
            GREEN:  green_led  = 1'b1;
            YELLOW: yellow_led = 1'b1;
            default: begin
                red_led    = 1'b0;
                green_led  = 1'b0;
                yellow_led = 1'b0;
            end
        endcase
    end
endmodule
