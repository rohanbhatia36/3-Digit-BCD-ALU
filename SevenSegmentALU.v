`timescale 1ns / 1ps

module SevenSegmentALU(
    input clk, 
    input reset,
    input onesBtn, 
    input tensBtn, 
    input hundredsBtn, 
    input sign, 
    input enter, 
    output [6:0] seg,
    output [3:0] anode 
);
    
    //button pulses with debouncing
    wire resetPulse;
    systemResetHandler resetHandlerInstance (
        .clk(clk),
        .reset(reset),
        .resetPulse(resetPulse)
    );

    wire onesBtnPulse;
    buttonSyncPulse onesBtnGen (
        .clk(clk),
        .resetPulse(resetPulse), 
        .button(onesBtn),
        .buttonPulse(onesBtnPulse)
    );

    wire tensBtnPulse;
    buttonSyncPulse tensBtnGen (
        .clk(clk),
        .resetPulse(resetPulse), 
        .button(tensBtn),
        .buttonPulse(tensBtnPulse)
    );

    wire hundredsBtnPulse;
    buttonSyncPulse hundredsBtnGen (
        .clk(clk),
        .resetPulse(resetPulse), 
        .button(hundredsBtn),
        .buttonPulse(hundredsBtnPulse)
    );

    wire signPulse;
    buttonSyncPulse signBtnGen (
        .clk(clk),
        .resetPulse(resetPulse), 
        .button(sign),
        .buttonPulse(signPulse)
    );

    wire enterPulse;
    buttonSyncPulse enterBtnGen (
        .clk(clk),
        .resetPulse(resetPulse), 
        .button(enter),
        .buttonPulse(enterPulse)
    );

    //internal registers and wires
    reg [3:0] bcdOnes;
    reg [3:0] bcdTens;
    reg [3:0] bcdHundreds;
    reg [3:0] bcdThousands;
    
    wire numberOn; 
    wire finished; 
    
    reg [15:0] firstNumber;
    reg [15:0] secondNumber;
    reg [15:0] sum;
    reg [16:0] carry;

    //state machine definition
    reg [2:0] state;
    localparam STATE_INPUT_1        = 3'd0;
    localparam STATE_WAIT_1         = 3'd1;
    localparam STATE_INPUT_2        = 3'd2;
    localparam STATE_WAIT_2         = 3'd3;
    localparam STATE_CALC           = 3'd4;
    localparam STATE_UPDATE_DISPLAY = 3'd5;
    localparam STATE_DONE           = 3'd6;
    
    assign numberOn = (state == STATE_INPUT_2);
    assign finished = (state == STATE_DONE);
    
    //assignments for number parts
    wire [3:0] firstNumberThousandsVal  = firstNumber[15:12];
    wire [3:0] firstNumberHundredsVal = firstNumber[11:8];
    wire [3:0] firstNumberTensVal     = firstNumber[7:4];
    wire [3:0] firstNumberOnesVal     = firstNumber[3:0];
    
    wire [3:0] secondNumberThousandsVal = secondNumber[15:12];
    wire [3:0] secondNumberHundredsVal  = secondNumber[11:8];
    wire [3:0] secondNumberTensVal      = secondNumber[7:4];
    wire [3:0] secondNumberOnesVal      = secondNumber[3:0];

    //combinatorial bcd addition logic
    reg [3:0] addResultOnes;
    reg [3:0] addResultTens;
    reg [3:0] addResultHundreds;
    reg carryOneAdd;
    reg carryTenAdd;
    reg carryHundredAdd;
    wire [15:0] sameSignCalculatedSum = {firstNumberThousandsVal, addResultHundreds, addResultTens, addResultOnes};

    always @(*) begin 
        if ((firstNumberOnesVal + secondNumberOnesVal) > 9) begin
            addResultOnes = firstNumberOnesVal + secondNumberOnesVal + 6;
            carryOneAdd = 1;
        end else begin
            addResultOnes = firstNumberOnesVal + secondNumberOnesVal;
            carryOneAdd = 0;
        end
        
        if ((firstNumberTensVal + secondNumberTensVal + carryOneAdd) > 9) begin
            addResultTens = firstNumberTensVal + secondNumberTensVal + carryOneAdd + 6;
            carryTenAdd = 1;
        end else begin
            addResultTens = firstNumberTensVal + secondNumberTensVal + carryOneAdd;
            carryTenAdd = 0;
        end
        
        if ((firstNumberHundredsVal + secondNumberHundredsVal + carryTenAdd) > 9) begin
            addResultHundreds = firstNumberHundredsVal + secondNumberHundredsVal + carryTenAdd + 6;
            carryHundredAdd = 1;
        end else begin
            addResultHundreds = firstNumberHundredsVal + secondNumberHundredsVal + carryTenAdd;
            carryHundredAdd = 0;
        end
    end

    //combinatorial bcd subtraction logic
    wire isFirstMagnitudeGreater = (firstNumber[11:0] > secondNumber[11:0]);
    wire areMagnitudesEqual      = (firstNumber[11:0] == secondNumber[11:0]);
    wire [3:0] largerMagnitudeHundreds  = isFirstMagnitudeGreater ? firstNumberHundredsVal : secondNumberHundredsVal;
    wire [3:0] largerMagnitudeTens      = isFirstMagnitudeGreater ? firstNumberTensVal     : secondNumberTensVal;
    wire [3:0] largerMagnitudeOnes      = isFirstMagnitudeGreater ? firstNumberOnesVal     : secondNumberOnesVal;
    wire [3:0] smallerMagnitudeHundreds = isFirstMagnitudeGreater ? secondNumberHundredsVal : firstNumberHundredsVal;
    wire [3:0] smallerMagnitudeTens     = isFirstMagnitudeGreater ? secondNumberTensVal     : firstNumberTensVal;
    wire [3:0] smallerMagnitudeOnes     = isFirstMagnitudeGreater ? secondNumberOnesVal     : firstNumberOnesVal;
    wire [3:0] resultMagnitudeHundreds, resultMagnitudeTens, resultMagnitudeOnes;
    wire borrowOutOnes, borrowOutTens, borrowOutHundreds;
    
    bcdSubDigit subOnesInstance (
        .a(largerMagnitudeOnes),
        .b(smallerMagnitudeOnes),
        .borrowIn(1'b0),
        .result(resultMagnitudeOnes),
        .borrowOut(borrowOutOnes)
    );
    
    bcdSubDigit subTensInstance (
        .a(largerMagnitudeTens),
        .b(smallerMagnitudeTens),
        .borrowIn(borrowOutOnes),
        .result(resultMagnitudeTens),
        .borrowOut(borrowOutTens)
    );
    
    bcdSubDigit subHundredsInstance (
        .a(largerMagnitudeHundreds),
        .b(smallerMagnitudeHundreds),
        .borrowIn(borrowOutTens),
        .result(resultMagnitudeHundreds),
        .borrowOut(borrowOutHundreds)
    );
    
    wire [3:0] finalSumSign = areMagnitudesEqual ? 15 : (isFirstMagnitudeGreater ? firstNumberThousandsVal : secondNumberThousandsVal);
    wire [15:0] differentSignCalculatedSum = {finalSumSign, resultMagnitudeHundreds, resultMagnitudeTens, resultMagnitudeOnes};

    //main state machine and logic block
    always @(posedge clk) begin
        if (~resetPulse) begin
            bcdOnes <= 0;
            bcdTens <= 0;
            bcdHundreds <= 0;
            bcdThousands <= 15;
            firstNumber <= 0;
            secondNumber <= 0;
            sum <= 0;
            carry <= 0;
            state <= STATE_INPUT_1;
        end else begin
            case (state)
                STATE_INPUT_1: begin
                    if (enterPulse) begin
                        firstNumber <= {bcdThousands, bcdHundreds, bcdTens, bcdOnes};
                        state <= STATE_WAIT_1;
                    end else begin
                        if (onesBtnPulse) begin
                            if (bcdOnes == 9) begin
                                bcdOnes <= 0;
                            end else begin
                                bcdOnes <= bcdOnes + 1;
                            end
                        end
                        if (tensBtnPulse) begin
                            if (bcdTens == 9) begin
                                bcdTens <= 0;
                            end else begin
                                bcdTens <= bcdTens + 1;
                            end
                        end
                        if (hundredsBtnPulse) begin
                            if (bcdHundreds == 9) begin
                                bcdHundreds <= 0;
                            end else begin
                                bcdHundreds <= bcdHundreds + 1;
                            end
                        end
                        if (signPulse) begin
                            case(bcdThousands)
                                15: bcdThousands <= 14;
                                14: bcdThousands <= 15;
                                default: bcdThousands <= 15;
                            endcase
                        end
                    end
                end
                
                STATE_WAIT_1: begin
                    //waits for enter release
                    if (~enter) begin
                        bcdOnes <= 0;
                        bcdTens <= 0;
                        bcdHundreds <= 0;
                        bcdThousands <= 15;
                        state <= STATE_INPUT_2;
                    end
                end
                
                STATE_INPUT_2: begin
                    if (enterPulse) begin
                        secondNumber <= {bcdThousands, bcdHundreds, bcdTens, bcdOnes};
                        state <= STATE_WAIT_2;
                    end else begin
                        if (onesBtnPulse) begin
                            if (bcdOnes == 9) begin
                                bcdOnes <= 0;
                            end else begin
                                bcdOnes <= bcdOnes + 1;
                            end
                        end
                        if (tensBtnPulse) begin
                            if (bcdTens == 9) begin
                                bcdTens <= 0;
                            end else begin
                                bcdTens <= bcdTens + 1;
                            end
                        end
                        if (hundredsBtnPulse) begin
                            if (bcdHundreds == 9) begin
                                bcdHundreds <= 0;
                            end else begin
                                bcdHundreds <= bcdHundreds + 1;
                            end
                        end
                        if (signPulse) begin
                            case(bcdThousands)
                                15: bcdThousands <= 14;
                                14: bcdThousands <= 15;
                                default: bcdThousands <= 15;
                            endcase
                        end
                    end
                end

                STATE_WAIT_2: begin
                    //waits for enter release
                    if (~enter) begin
                        state <= STATE_CALC;
                    end
                end

                STATE_CALC: begin
                    //calculates sum
                    if (firstNumberThousandsVal == secondNumberThousandsVal) begin
                        sum <= sameSignCalculatedSum;
                        carry[16] <= carryHundredAdd;
                    end else begin 
                        sum <= differentSignCalculatedSum;
                        carry <= 0;
                    end
                    state <= STATE_UPDATE_DISPLAY;
                end
                
                STATE_UPDATE_DISPLAY: begin
                    //updates display registers
                    bcdOnes <= sum[3:0];
                    bcdTens <= sum[7:4];
                    bcdHundreds <= sum[11:8];
                    bcdThousands <= sum[15:12];
                    state <= STATE_DONE;
                end
                
                STATE_DONE: begin
                    //locks until reset
                end
            endcase
        end
    end

    //display multiplexing and decoder logic
    parameter MUX_COUNT_MAX = 3000;
    reg [11:0] muxClkCounter;
    reg muxPulse;
    reg [1:0] digitSelector;
    reg [3:0] currentDisplayBcd;
    reg [3:0] anodeOutputReg;
    assign anode = anodeOutputReg;
    
    always @(posedge clk) begin
        if (~resetPulse) begin
            muxClkCounter <= 0;
            muxPulse <= 0;
            digitSelector <= 0;
            anodeOutputReg <= 4'b1111;
            currentDisplayBcd <= 0;
        end else begin
            if (muxClkCounter == MUX_COUNT_MAX - 1) begin
                muxClkCounter <= 0;
                muxPulse <= 1;
                digitSelector <= digitSelector + 1;
            end else begin
                muxClkCounter <= muxClkCounter + 1;
                muxPulse <= 0;
            end
            
            if (muxPulse) begin
                case (digitSelector)
                    2'd0: begin
                        anodeOutputReg <= 4'b1110;
                        currentDisplayBcd <= bcdOnes;
                    end
                    2'd1: begin
                        anodeOutputReg <= 4'b1101;
                        currentDisplayBcd <= bcdTens;
                    end
                    2'd2: begin
                        anodeOutputReg <= 4'b1011;
                        currentDisplayBcd <= bcdHundreds;
                    end
                    2'd3: begin
                        anodeOutputReg <= 4'b0111;
                        currentDisplayBcd <= bcdThousands;
                    end
                endcase
            end
        end
    end
    
    reg [6:0] segOutReg;
    assign seg = segOutReg;
    
    always @(*) begin
        case(currentDisplayBcd)
            4'b0000: segOutReg = 7'b0111111;
            4'b0001: segOutReg = 7'b0000110;
            4'b0010: segOutReg = 7'b1011011;
            4'b0011: segOutReg = 7'b1001111;
            4'b0100: segOutReg = 7'b1100110;
            4'b0101: segOutReg = 7'b1101101;
            4'b0110: segOutReg = 7'b1111101;
            4'b0111: segOutReg = 7'b0000111;
            4'b1000: segOutReg = 7'b1111111;
            4'b1001: segOutReg = 7'b1101111;
            4'b1110: segOutReg = 7'b1000000;
            4'b1111: segOutReg = 7'b0000000;
            default: segOutReg = 7'b0000000;
        endcase
    end
    
endmodule