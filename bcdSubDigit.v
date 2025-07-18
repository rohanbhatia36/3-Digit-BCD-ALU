`timescale 1ns / 1ps

module bcdSubDigit(
    input  [3:0] a,
    input  [3:0] b,
    input  borrowIn,
    output reg [3:0] result,
    output reg     borrowOut
);

    wire [4:0] tempSubBinary = a - b - (borrowIn ? 1'b1 : 1'b0); 

    //performs bcd subtraction
    always @(*) begin
        if (tempSubBinary[4] == 1) begin
            borrowOut = 1;
            result = tempSubBinary + 10; 
        end else begin
            borrowOut = 0;
            result = tempSubBinary[3:0];
        end
    end
endmodule