`timescale 1ns / 1ps

module systemResetHandler_tb;

    //inputs and outputs
    reg clk;
    reg reset;
    wire resetPulse;

    //clock generation
    always #4.1667 clk = ~clk;

    //instantiate the design under test
    systemResetHandler dut (
        .clk(clk),
        .reset(reset),
        .resetPulse(resetPulse)
    );
    
    //simulation parameters
    parameter DEBOUNCE_TIME = 2400000; // Must match DUT parameter
    
    //main test sequence
    initial begin
        clk = 0;
        reset = 0; //initial state is not pressed (low)
        
        $display("\n--- systemResetHandler Testbench ---");
        
        #(DEBOUNCE_TIME*3/2);
        
        //test 1: initial state check
        $display("\n--- Test 1: Initial State ---");
        if (resetPulse == 1) begin
            $display("--> PASSED: resetPulse is initially inactive (high).");
        end else begin
            $display("--> FAILED: resetPulse should be high at start.");
        end
        
        //test 2: noise rejection
        $display("\n--- Test 2: Noise Rejection ---");
        $display("Simulating a short glitch...");
        reset = 1;
        #(DEBOUNCE_TIME / 2); //press for less than debounce time
        reset = 0;
        #(DEBOUNCE_TIME * 2);
        if (resetPulse == 1) begin
            $display("--> PASSED: Short glitch was correctly ignored.");
        end else begin
            $display("--> FAILED: resetPulse went low on a short glitch.");
        end
        
        //test 3: valid reset press
        $display("\n--- Test 3: Valid Reset Press and Release ---");
        $display("Simulating a valid button press...");
        reset = 1; //press button
        #(DEBOUNCE_TIME * 2);
        if (resetPulse == 0) begin
            $display("--> PASSED: resetPulse went active (low) after valid press.");
        end else begin
            $display("--> FAILED: resetPulse did not go low after valid press.");
        end
        
        $display("Simulating button release...");
        reset = 0; //release button
        #(DEBOUNCE_TIME * 2);
        if (resetPulse == 1) begin
            $display("--> PASSED: resetPulse went inactive (high) after release.");
        end else begin
            $display("--> FAILED: resetPulse did not go high after release.");
        end

        $display("\n--- All Tests Completed ---");
        $finish;
    end

endmodule
