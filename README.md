# 3-Digit Signed BCD ALU on a Cmod A7 FPGA

## Summary

This project is a complete hardware implementation of a 3-digit signed number calculator, designed and verified in Verilog and deployed on a Digilent Cmod A7-35T FPGA. The Arithmetic Logic Unit (ALU) performs signed addition and subtraction on numbers in the range of -999 to +999. User input is handled by debounced external pushbuttons, and the final output is displayed on a multiplexed 4-digit 7-segment display.

[![Demonstration of the ALU in action](https://img.youtube.com/vi/eYz83JoBjYc/0.jpg)](https://www.youtube.com/watch?v=eYz83JoBjYc)

## Features

* **Signed BCD Arithmetic:** The core of the design is an [ALU](https://en.wikipedia.org/wiki/Arithmetic_logic_unit) that performs 3-digit [Binary-Coded Decimal](https://en.wikipedia.org/wiki/Binary-coded_decimal) (BCD) addition and subtraction.
* **Finite State Machine (FSM) Control:** A multi-state [FSM](https://en.wikipedia.org/wiki/Finite-state_machine) manages the calculator's operational flow, ensuring reliable sequencing of user input, calculation, and result display stages.
* **Hardware-Ready Peripheral Drivers:** All peripherals are driven by custom Verilog modules, including:
    * Debouncers with clock-domain synchronization for all button inputs.
    * A multiplexed 4-digit 7-segment display driver.
* **Robust Hardware Design:** The state machine includes "wait states" to synchronize with slow human input, preventing hardware race conditions that can occur when buttons are held down.

## Theory of Operation

The design is centered around a main Finite State Machine (FSM) that controls the calculator's behavior. The project is modular, with dedicated modules for handling button presses and performing BCD subtraction.

#### Block Diagram

![Block Diagram of the ALU Design](media/blockDiagram.png)

#### Finite State Machine (FSM)

The system operates based on the following sequence of states:

1.  **`STATE_INPUT_1`**: The default state after reset. The system waits for the user to input the first number using the digit and sign buttons.
2.  **`STATE_WAIT_1`**: After the `enter` button is pressed, the FSM enters this state and waits for the user to *release* the button. This prevents the FSM from racing ahead.
3.  **`STATE_INPUT_2`**: The system waits for the user to input the second number.
4.  **`STATE_WAIT_2`**: After the second `enter` press, the FSM waits for the button to be released.
5.  **`STATE_CALC`**: In this single-cycle state, the `sum` register is loaded with the result of the addition or subtraction.
6.  **`STATE_UPDATE_DISPLAY`**: On the next clock cycle, the stable value from the `sum` register is used to update the BCD display registers. This two-step process (Calculate, then Update) prevents timing errors.
7.  **`STATE_DONE`**: The final state. The result is held on the display, and all button inputs (except reset) are ignored.

## Interface Description

The following table describes the top-level ports of the `SevenSegmentALU` module.

| Port          | Direction | Width | Description                               |
| ------------- | --------- | ----- | ----------------------------------------- |
| `clk`         | Input     | 1-bit | Main system clock (12 MHz on Cmod A7).    |
| `reset`       | Input     | 1-bit | Asynchronous, active-low system reset.    |
| `onesBtn`     | Input     | 1-bit | Increment the ones digit.                 |
| `tensBtn`     | Input     | 1-bit | Increment the tens digit.                 |
| `hundredsBtn` | Input     | 1-bit | Increment the hundreds digit.             |
| `sign`        | Input     | 1-bit | Toggle the sign between `+` and `-`.      |
| `enter`       | Input     | 1-bit | Store a number or execute the calculation.|
| `seg`         | Output    | 7-bit | 7-segment display segment driver outputs. |
| `anode`       | Output    | 4-bit | 7-segment display digit-select anodes.    |

## Project Files

This repository contains all the necessary files to simulate and implement the project.

* **Design Sources (`/designs`)**:
    * `SevenSegmentALU.v`: The top-level module containing the main FSM and ALU logic.
    * `systemResetHandler.v`: Debounces the main reset button.
    * `buttonSyncPulse.v`: A reusable module to debounce and generate single-cycle pulses from button presses.
    * `bcdSubDigit.v`: A combinatorial module for single-digit BCD subtraction.
* **Simulation Sources (`/simulations/testbenches`)**:
    * `SevenSegmentALU_tb.v`: A comprehensive testbench for the top-level ALU.
    * `systemResetHandler_tb.v`: A testbench to verify the reset debouncer.
    * `buttonSyncPulse_tb.v`: A testbench to verify the button pulse generator.
    * `bcdSubDigit_tb.v`: A testbench to verify the subtraction module.
* **Constraints (`/constraints`)**:
    * `cmod_a7.xdc`: The XDC file that maps the Verilog ports to the physical pins of the Cmod A7-35T FPGA.
* **Verification Waveforms (`/simulations/waveforms`)**:
    * This directory contains screenshots of the simulation waveforms, visually confirming the results of each testbench.

## Hardware Setup & Wiring

The external buttons should be wired with one terminal connected to the assigned GPIO pin and the other terminal connected to a common Ground (GND) pin. The 7-segment display used is a **5641AS Common Cathode** model.

| Verilog Port  | Cmod A7 Pin | External Component Pin |
| ------------- | ----------- | ---------------------- |
| `reset`       | B18         | On-board Button 1      |
| `enter`       | V8          | External Button        |
| `onesBtn`     | U8          | External Button        |
| `tensBtn`     | W7          | External Button        |
| `hundredsBtn` | U7          | External Button        |
| `sign`        | U3          | External Button        |
| `seg[0]` (a)  | G17         | 5641AS Pin 11          |
| `seg[1]` (b)  | G19         | 5641AS Pin 7           |
| `seg[2]` (c)  | N18         | 5641AS Pin 4           |
| `seg[3]` (d)  | L18         | 5641AS Pin 2           |
| `seg[4]` (e)  | H17         | 5641AS Pin 1           |
| `seg[5]` (f)  | H19         | 5641AS Pin 10          |
| `seg[6]` (g)  | J19         | 5641AS Pin 5           |
| `anode[0]`    | M3          | 5641AS Pin 12 (DIG1)   |
| `anode[1]`    | L3          | 5641AS Pin 9 (DIG2)    |
| `anode[2]`    | A16         | 5641AS Pin 8 (DIG3)    |
| `anode[3]`    | K3          | 5641AS Pin 6 (DIG4)    |

## Verification Plan

The design was verified using a modular, bottom-up approach. Each helper module was tested individually with its own dedicated, self-checking testbench (unit testing) before the full system was integrated and tested.

* **`bcdSubDigit_tb.v`**: Verifies all single-digit BCD subtraction cases, including various borrow-in and borrow-out conditions.
* **`systemResetHandler_tb.v`**: Verifies that the active-low reset signal is correctly debounced and that short noise pulses are rejected.
* **`buttonSyncPulse_tb.v`**: Verifies that a clean, single-cycle pulse is generated on a button press (falling edge) and that no pulses are generated when the system is held in reset.
* **`SevenSegmentALU_tb.v`**: Performs a full system-level check covering all arithmetic operations, edge cases (overflow, complex borrows), and state transitions.

## Synthesis & Implementation Results

The project was synthesized and implemented using Vivado for the Xilinx Artix-7 FPGA (xc7a35t-CPG236-1) on the Cmod A7-35T board.

* **LUTs:** 145
* **Flip-Flops (FF):** 219
* **Max Frequency (Fmax):** ~103 MHz
* **Estimated Total Power:** 0.069 W

## How to Reproduce the Project

#### 1. Running the Simulation

1.  Create a new project in Vivado.
2.  Add all Verilog source files from the `/designs` and `/simulations/testbenches` directories.
3.  In the "Sources" panel, ensure the desired testbench (e.g., `SevenSegmentALU_tb.v`) is the top simulation module.
4.  Run the Behavioral Simulation. The TCL console will print the pass/fail results.

#### 2. Implementing on Hardware

1.  Create a new project in Vivado.
2.  Add the four **design source files** from the `/designs` directory.
3.  Add the `cmod_a7.xdc` constraints file from the `/constraints` directory.
4.  In the Flow Navigator, run Synthesis, then run Implementation, and finally Generate Bitstream.
5.  Using the Hardware Manager, program the Cmod A7 with the generated bitstream file.

## Key Challenges & Learning

This project provided extensive hands-on experience with the full digital design flow, from initial concept to a fully functional hardware implementation.

* **Challenge:** The most significant challenge was figuring out how to perform subtraction when the two input numbers have different signs (e.g., `+5` and `-43`). This was much more complex than simple addition, as it required comparing the magnitudes of the numbers to determine the correct operation and the sign of the final result.
* **Debugging Process:** The initial subtraction logic produced incorrect results in the simulation. The debugging process involved creating a dedicated testbench for the `bcdSubDigit` module to isolate and verify its behavior. For the top-level design, the simulation waveform was used to trace the `firstNumber` and `secondNumber` values and step through the combinatorial logic that determined which number had the larger magnitude.
* **Solution:** The final implementation uses a modular approach. It first compares the absolute values of the two numbers. It then uses a chain of `bcdSubDigit` modules to subtract the smaller magnitude from the larger one. The sign of the final result is determined by the sign of the number that had the larger magnitude.
* **Learning Outcome:** This project provided a deep understanding of BCD arithmetic, modular design, and the importance of handling real-world hardware signals. A key learning outcome was the necessity of **debouncing** physical button inputs to filter out electrical noise and creating a single-cycle pulse generator to ensure the state machine only registered one action per press. This was fundamental to making the calculator reliable.
