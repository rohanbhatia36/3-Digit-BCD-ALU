`timescale 1ns / 1ps

module systemResetHandler(
    input  clk,
    input  reset,
    output resetPulse
);

    parameter DEBOUNCE_CLKS = 240000;

    reg [17:0] debounceCounter;
    reg debouncedReset;
    
    initial begin
        debounceCounter <= 0;
        debouncedReset <= 1; 
    end

    always @(posedge clk) begin 
        if (reset != debouncedReset) begin
            if (debounceCounter == (DEBOUNCE_CLKS - 1)) begin
                debouncedReset <= reset;
                debounceCounter <= 0;
            end else begin
                debounceCounter <= debounceCounter + 1;
            end
        end else begin
            debounceCounter <= 0;
        end
    end

    //outputs debounced signal
    assign resetPulse = ~debouncedReset; 

endmodule
