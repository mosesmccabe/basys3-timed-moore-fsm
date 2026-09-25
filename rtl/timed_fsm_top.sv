`timescale 1ns / 1ps
// Basys 3 top level: one 100 MHz clock domain; tick is a clock enable,
// not another clock. Two independent modules are connected here.

module timed_fsm_top #(
    parameter integer CLK_FREQ_HZ = 100_000_000
)(
    input  logic clk,
    input  logic rst,
    output logic red_led,
    output logic green_led,
    output logic yellow_led
);
    logic tick;

    tick_generator #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    ) GENERATE_TICK (
        .clk  (clk),
        .rst  (rst),
        .tick (tick)
    );

    timed_fsm_controller FSM (
        .clk        (clk),
        .rst        (rst),
        .tick       (tick),
        .red_led    (red_led),
        .green_led  (green_led),
        .yellow_led (yellow_led)
    );
endmodule
