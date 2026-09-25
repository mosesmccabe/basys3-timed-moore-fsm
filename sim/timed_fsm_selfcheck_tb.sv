`timescale 1ns / 1ps
// Optional extension: automatic edge-by-edge checks.
// This is supplementary learning material; the screenshots in docs/evidence
// are from the previously completed waveform-based Vivado simulation.
module timed_fsm_selfcheck_tb;
    logic clk = 1'b0;
    logic rst = 1'b1;
    logic red_led, green_led, yellow_led;
    int checks = 0;

    always #5 clk = ~clk;

    timed_fsm_top #(.CLK_FREQ_HZ(4)) DUT (
        .clk(clk), .rst(rst),
        .red_led(red_led), .green_led(green_led), .yellow_led(yellow_led)
    );

    task automatic check_leds(input logic [2:0] expected, input string context);
        logic [2:0] actual;
        begin
            actual = {red_led, green_led, yellow_led};
            checks++;
            if (actual !== expected)
                $fatal(1, "%s: expected %b, got %b at t=%0t",
                       context, expected, actual, $time);
        end
    endtask

    task automatic run_cycles(input int cycles,
                              input logic [2:0] expected_until_last,
                              input logic [2:0] expected_last,
                              input string label_text);
        begin
            for (int i = 1; i <= cycles; i++) begin
                @(posedge clk);
                #1; // sample after nonblocking assignments settle
                if (i < cycles)
                    check_leds(expected_until_last, label_text);
                else
                    check_leds(expected_last, label_text);
            end
        end
    endtask

    initial begin
        // Reset spans two rising edges. Release on the falling edge.
        repeat (2) @(posedge clk);
        #1;
        check_leds(3'b100, "synchronous reset -> RED");
        @(negedge clk);
        rst = 1'b0;

        // From reset release: the 3rd registered tick is sampled on
        // the 13th active edge. Steady phases last 16 and 8 edges.
        run_cycles(13, 3'b100, 3'b010, "RED -> GREEN");
        run_cycles(16, 3'b010, 3'b001, "GREEN -> YELLOW");
        run_cycles(8,  3'b001, 3'b100, "YELLOW -> RED");
        run_cycles(12, 3'b100, 3'b010, "second RED -> GREEN");

        // Synchronous reset from GREEN (sample it on a rising edge).
        @(negedge clk);
        rst = 1'b1;
        @(posedge clk);
        #1;
        check_leds(3'b100, "reset during GREEN -> RED");
        if (DUT.FSM.elapsed !== 2'b00 || DUT.tick !== 1'b0)
            $fatal(1, "reset did not clear elapsed and tick");

        $display("PASS: %0d edge-aligned LED assertions", checks);
        $finish;
    end
endmodule
