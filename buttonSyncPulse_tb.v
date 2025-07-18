`timescale 1ns / 1ps

module buttonSyncPulse_tb;

    //inputs and outputs
    reg clk;
    reg resetPulse;
    reg button;
    wire buttonPulse;
    
    //internal testbench variables
    reg [31:0] pulse_counter;

    //clock generation
    always #4.1667 clk = ~clk;

    //instantiate the design under test
    buttonSyncPulse dut (
        .clk(clk),
        .resetPulse(resetPulse),
        .button(button),
        .buttonPulse(buttonPulse)
    );

    //simulation parameters
    parameter DEBOUNCE_TIME = 2400000;

    //pulse counter
    always @(posedge buttonPulse) begin
        pulse_counter <= pulse_counter + 1;
    end
    
    //main test sequence
    initial begin
        clk = 0;
        resetPulse = 1; //inactive
        button = 1;     //not pressed
        pulse_counter = 0;
        
        $display("\n--- buttonSyncPulse Testbench ---");
        
        #100;

        //test 1: normal press
        $display("\n--- Test 1: Normal Press ---");
        $display("Simulating a normal button press and hold...");
        button = 0; //press
        #(DEBOUNCE_TIME * 5); //hold
        button = 1; //release
        #(DEBOUNCE_TIME * 2);
        if (pulse_counter == 1) begin
            $display("--> PASSED: Exactly one pulse was generated.");
        end else begin
            $display("--> FAILED: Expected 1 pulse, but got %d.", pulse_counter);
        end
        pulse_counter = 0; //reset for next test

        //test 2: reset functionality
        $display("\n--- Test 2: Reset Test ---");
        $display("Simulating a press during reset...");
        resetPulse = 0; //assert reset
        #(DEBOUNCE_TIME);
        button = 0; //press button while reset is active
        #(DEBOUNCE_TIME * 2);
        button = 1; //release
        #(DEBOUNCE_TIME);
        resetPulse = 1; //de-assert reset
        #(DEBOUNCE_TIME * 2);
        if (pulse_counter == 0) begin
            $display("--> PASSED: No pulse was generated while reset was active.");
        end else begin
            $display("--> FAILED: A pulse was generated during reset.");
        end
        pulse_counter = 0;

        $display("\n--- All Tests Completed ---");
        $finish;
    end

endmodule
