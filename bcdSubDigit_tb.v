`timescale 1ns / 1ps

module bcdSubDigit_tb;

    //inputs and outputs
    reg  [3:0] a;
    reg  [3:0] b;
    reg  borrowIn;
    wire [3:0] result;
    wire       borrowOut;

    //instantiate the design under test
    bcdSubDigit dut (
        .a(a),
        .b(b),
        .borrowIn(borrowIn),
        .result(result),
        .borrowOut(borrowOut)
    );
    
    //task to run a single test case
    task run_test;
        input [3:0] test_a;
        input [3:0] test_b;
        input test_borrowIn;
        input [3:0] expected_result;
        input expected_borrowOut;
        input [8*32-1:0] test_name;
        
        begin
            a = test_a;
            b = test_b;
            borrowIn = test_borrowIn;
            #10; //allow combinatorial logic to settle
            
            if (result == expected_result && borrowOut == expected_borrowOut) begin
                $display("--> PASSED: %s (a=%d, b=%d, bin=%b) -> (res=%d, bout=%b)", test_name, a, b, borrowIn, result, borrowOut);
            end else begin
                $display("--> FAILED: %s (a=%d, b=%d, bin=%b) -> GOT (res=%d, bout=%b), EXPECTED (res=%d, bout=%b)", test_name, a, b, borrowIn, result, borrowOut, expected_result, expected_borrowOut);
            end
        end
    endtask

    //main test sequence
    initial begin
        $display("\n--- bcdSubDigit Testbench ---");
        
        //initialize inputs
        a = 0;
        b = 0;
        borrowIn = 0;
        #10;

        //run all test cases
        run_test(5, 2, 0, 3, 0, "Simple subtraction, no borrow");
        run_test(8, 8, 0, 0, 0, "Subtraction to zero");
        run_test(3, 7, 0, 6, 1, "Simple subtraction with borrow");
        run_test(9, 0, 0, 9, 0, "Boundary case: 9 - 0");
        run_test(0, 9, 0, 1, 1, "Boundary case: 0 - 9");
        run_test(5, 2, 1, 2, 0, "Subtraction with borrowIn, no borrowOut");
        run_test(2, 5, 1, 6, 1, "Subtraction with borrowIn, with borrowOut");
        run_test(0, 0, 1, 9, 1, "Edge case: 0 - 0 with borrowIn");
        run_test(9, 9, 1, 9, 1, "Edge case: 9 - 9 with borrowIn");

        $display("\n--- All Tests Completed ---");
        $finish;
    end

endmodule
