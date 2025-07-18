`timescale 10ns / 10ps

module SevenSegmentALU_tb;

    reg clk;
    reg reset;
    reg onesBtn;
    reg tensBtn;
    reg hundredsBtn;
    reg sign;
    reg enter;
    
    wire [6:0] seg;
    wire [3:0] anode;
    
    always #4.1667 clk = ~clk;

    //internal signals
    wire [15:0] firstNumber_tb;
    wire [15:0] secondNumber_tb;
    wire [15:0] sum_tb;
    wire [16:0] carry_tb;
    wire finished_tb;
    wire numberOn_tb;
    wire [3:0] bcdOnes_tb;
    wire [3:0] bcdTens_tb;
    wire [3:0] bcdHundreds_tb;
    wire [3:0] bcdThousands_tb;

    //common delays as parameters
    parameter CLK_PERIOD = 8.3334; 
    parameter SIM_WAIT = 2_400_000; 

    SevenSegmentALU dut (
        .clk(clk),
        .reset(reset),
        .onesBtn(onesBtn),
        .tensBtn(tensBtn),
        .hundredsBtn(hundredsBtn),
        .sign(sign),
        .enter(enter),
        .seg(seg),
        .anode(anode)
    );

    //connecting internal signals from DUT for monitoring
    assign firstNumber_tb   = dut.firstNumber;
    assign secondNumber_tb  = dut.secondNumber;
    assign sum_tb           = dut.sum;
    assign carry_tb         = dut.carry;
    assign finished_tb      = dut.finished;
    assign numberOn_tb      = dut.numberOn;
    assign bcdOnes_tb       = dut.bcdOnes;
    assign bcdTens_tb       = dut.bcdTens;
    assign bcdHundreds_tb   = dut.bcdHundreds; 
    assign bcdThousands_tb  = dut.bcdThousands;
    assign resetPulse_tb = dut.resetPulse;

    task press_button;
        input [63:0] button_name;
        begin
            case (button_name)
                "ones":     begin 
                                onesBtn = 0; 
                                #SIM_WAIT; 
                                onesBtn = 1; 
                                #SIM_WAIT; 
                            end
                "tens":     begin 
                                tensBtn = 0; 
                                #SIM_WAIT; 
                                tensBtn = 1; 
                                #SIM_WAIT; 
                            end
                "hundreds": begin 
                                hundredsBtn = 0; 
                                #SIM_WAIT; 
                                hundredsBtn = 1; 
                                #SIM_WAIT; 
                            end
                "sign":     begin 
                                sign = 0; 
                                #SIM_WAIT; 
                                sign = 1; 
                                #SIM_WAIT; 
                            end
                "enter":    begin 
                                enter = 0; 
                                #SIM_WAIT; 
                                enter = 1; 
                                #SIM_WAIT; 
                            end
            endcase
        end
    endtask
    
    task apply_reset;
        begin
            reset = 1;
            #SIM_WAIT;
            reset = 0;
            #SIM_WAIT;
        end
    endtask

    initial begin
        clk = 0;
        reset = 0;
        onesBtn = 1;
        tensBtn = 1;
        hundredsBtn = 1;
        sign = 1;
        enter = 1;

        $display("\n--- Test 1: System Reset ---");
        apply_reset();
        @(posedge clk);
        if (bcdOnes_tb == 0 && bcdTens_tb == 0 && bcdHundreds_tb == 0 && bcdThousands_tb == 15 && finished_tb == 0) begin
            $display("--> PASSED: System correctly reset to initial state (positive).");
        end else begin
            $display("--> FAILED: System did not reset correctly.");
        end

        $display("\n--- Test 2: Same-Sign Addition (+123 + +456 = +579) ---");
        apply_reset();
        repeat(1) press_button("hundreds");
        repeat(2) press_button("tens");
        repeat(3) press_button("ones");
        press_button("enter");
        repeat(4) press_button("hundreds");
        repeat(5) press_button("tens");
        repeat(6) press_button("ones");
        press_button("enter");
        #(CLK_PERIOD * 20);
        if (firstNumber_tb == 16'hF123 && secondNumber_tb == 16'hF456 && sum_tb == 16'hF579) begin
             $display("--> PASSED: Sum (+579) correct.");
        end else begin
             $display("--> FAILED: First: %h, Second: %h, Sum: %h", firstNumber_tb, secondNumber_tb, sum_tb);
        end
        
        $display("\n--- Test 3: Different-Sign Subtraction (+700 + -200 = +500) ---");
        apply_reset();
        repeat(7) press_button("hundreds");
        press_button("enter");
        press_button("sign"); 
        repeat(2) press_button("hundreds");
        press_button("enter");
        #(CLK_PERIOD * 20);
        if (firstNumber_tb == 16'hF700 && secondNumber_tb == 16'hE200 && sum_tb == 16'hF500) begin
             $display("--> PASSED: Sum (+500) correct.");
        end else begin
             $display("--> FAILED: First: %h, Second: %h, Sum: %h", firstNumber_tb, secondNumber_tb, sum_tb);
        end

        $display("\n--- Test 4: Different-Sign Subtraction, Negative Result (+100 + -500 = -400) ---");
        apply_reset();
        repeat(1) press_button("hundreds");
        press_button("enter");
        press_button("sign"); 
        repeat(5) press_button("hundreds");
        press_button("enter");
        #(CLK_PERIOD * 20);
        if (sum_tb == 16'hE400) begin
            $display("--> PASSED: Sum (-400) correct.");
        end else begin
            $display("--> FAILED: Sum was %h", sum_tb);
        end

        $display("\n--- Test 5: Negative Addition (-123 + -456 = -579) ---");
        apply_reset();
        press_button("sign");
        repeat(1) press_button("hundreds");
        repeat(2) press_button("tens");
        repeat(3) press_button("ones");
        press_button("enter");
        press_button("sign");
        repeat(4) press_button("hundreds");
        repeat(5) press_button("tens");
        repeat(6) press_button("ones");
        press_button("enter");
        #(CLK_PERIOD * 20);
        if (sum_tb == 16'hE579) begin
            $display("--> PASSED: Sum (-579) correct.");
        end else begin
            $display("--> FAILED: Sum was %h", sum_tb);
        end
        
        $display("\n--- Test 6 (Edge Case): Overflow Test (999 + 1) ---");
        apply_reset();
        repeat(9) press_button("hundreds");
        repeat(9) press_button("tens");
        repeat(9) press_button("ones");
        press_button("enter");
        repeat(1) press_button("ones");
        press_button("enter");
        #(CLK_PERIOD * 20);
        if (sum_tb == 16'hF000 && carry_tb[16] == 1) begin
            $display("--> PASSED: Overflow detected correctly (Sum: %h, Carry: %b).", sum_tb, carry_tb[16]);
        end else begin
            $display("--> FAILED: Overflow test failed (Sum: %h, Carry: %b).", sum_tb, carry_tb[16]);
        end
        
        $display("\n--- Test 7 (Edge Case): Complex Borrow Test (503 - 124) ---");
        apply_reset();
        repeat(5) press_button("hundreds");
        repeat(3) press_button("ones");
        press_button("enter");
        press_button("sign");
        repeat(1) press_button("hundreds");
        repeat(2) press_button("tens");
        repeat(4) press_button("ones");
        press_button("enter");
        #(CLK_PERIOD * 20);
        if (sum_tb == 16'hF379) begin
            $display("--> PASSED: Complex borrow result (+379) is correct.");
        end else begin
            $display("--> FAILED: Complex borrow test failed, sum was %h.", sum_tb);
        end
        
        $display("\n--- Test 8 (Edge Case): Input Rollover (Press ones button 10 times) ---");
        apply_reset();
        repeat(10) press_button("ones");
        @(posedge clk);
        if(bcdOnes_tb == 0) begin
            $display("--> PASSED: BCD ones digit correctly rolled over to 0.");
        end else begin
            $display("--> FAILED: BCD ones digit is %d, expected 0.", bcdOnes_tb);
        end
        
        $display("\n--- Test 9 (Edge Case): Buttons are ignored after 'finished' ---");
        apply_reset();
        press_button("ones");
        press_button("enter");
        press_button("ones");
        press_button("enter");
        #(CLK_PERIOD * 20);
        if (finished_tb == 1) begin
            $display("...Calculation finished, now pressing extra buttons...");
            press_button("ones");
            press_button("sign");
            #(CLK_PERIOD * 20);
            if (sum_tb == 16'hF002 && bcdOnes_tb == 2) begin
                $display("--> PASSED: Buttons correctly ignored after calculation finished.");
            end else begin
                $display("--> FAILED: State changed after finished. Sum: %h, BCD Ones: %d", sum_tb, bcdOnes_tb);
            end
        end else begin
            $display("--> FAILED: Could not run test because 'finished' flag was not set.");
        end

        $display("\n--- All Tests Completed ---");
        $finish;
    end

endmodule
