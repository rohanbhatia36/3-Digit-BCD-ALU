`timescale 1ns / 1ps

module buttonSyncPulse(
    input  clk,
    input  resetPulse,
    input  button,
    output buttonPulse
);
    
    parameter DEBOUNCE_CLKS = 240000;

    reg [17:0] debounceCounter; 
    reg debouncedButton; 

    //debounces the button press
    always @(posedge clk) begin
        if (~resetPulse) begin 
            debounceCounter <= 0;
            debouncedButton <= 1; 
        end else begin
            if (button != debouncedButton) begin
                if (debounceCounter == (DEBOUNCE_CLKS - 1)) begin
                    debouncedButton <= button; 
                    debounceCounter <= 0; 
                end else begin
                    debounceCounter <= debounceCounter + 1;
                end
            end else begin
                debounceCounter <= 0;
            end
        end
    end

    //synchronizes the signal
    reg debouncedButtonSync1;
    reg debouncedButtonSync2; 

    always @(posedge clk) begin
        if (~resetPulse) begin 
            debouncedButtonSync1 <= 1;
            debouncedButtonSync2 <= 1;
        end else begin
            debouncedButtonSync1 <= debouncedButton;       
            debouncedButtonSync2 <= debouncedButtonSync1; 
        end
    end

    //detects the edge for a single pulse
    reg debouncedButtonSync2Delayed; 

    always @(posedge clk) begin
        if (~resetPulse) begin 
            debouncedButtonSync2Delayed <= 1;
        end else begin
            debouncedButtonSync2Delayed <= debouncedButtonSync2; 
        end
    end

    assign buttonPulse = !debouncedButtonSync2 && debouncedButtonSync2Delayed;
    
    initial begin
        debounceCounter <= 0;
        debouncedButton <= 1;
        debouncedButtonSync1 <= 1;
        debouncedButtonSync2 <= 1;
        debouncedButtonSync2Delayed <= 1;
    end


endmodule