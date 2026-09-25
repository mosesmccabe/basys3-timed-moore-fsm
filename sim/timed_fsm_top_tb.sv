`timescale 1ns / 1ps
// Waveform demonstration testbench used for the Day 11 learning exercise.
// DUT outputs are OBSERVED here, never driven by the testbench.
module timed_fsm_top_tb;
    logic clk;
    logic rst;
    logic red_led, green_led, yellow_led;

    timed_fsm_top #(
        .CLK_FREQ_HZ(4)
    ) DUT (
        .clk        (clk),
        .rst        (rst),
        .red_led    (red_led),
        .green_led  (green_led),
        .yellow_led (yellow_led)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;  // 10 ns clock period

    initial begin
        rst = 1'b1;
        #20;
        rst = 1'b0;
        #420;
        $finish;
    end

    initial begin
        $monitor("t=%0t tick=%b state=%0d elapsed=%0d RED=%b GREEN=%b YELLOW=%b",
                 $time, DUT.tick, DUT.FSM.state, DUT.FSM.elapsed,
                 red_led, green_led, yellow_led);
    end
endmodule
