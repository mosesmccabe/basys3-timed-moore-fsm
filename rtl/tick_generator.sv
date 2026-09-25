`timescale 1ns / 1ps
// Day 11: Parameterized, synchronous tick generator.
// CLK_FREQ_HZ clock cycles occur between registered tick pulses.
// Supported parameter setting: CLK_FREQ_HZ >= 2.
module tick_generator #(
    parameter integer CLK_FREQ_HZ = 100_000_000
)(
    input  logic clk,
    input  logic rst,
    output logic tick
);
    localparam integer COUNT_WIDTH = $clog2(CLK_FREQ_HZ);
    logic [COUNT_WIDTH-1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= '0;
            tick  <= 1'b0;
        end
        else if (count == CLK_FREQ_HZ - 1) begin
            count <= '0;
            tick  <= 1'b1;
        end
        else begin
            count <= count + 1'b1;
            tick  <= 1'b0;
        end
    end
endmodule
