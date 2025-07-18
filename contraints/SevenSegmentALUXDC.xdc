## Cmod A7-35T Master XDC File for 3-Digit ALU Project

# --- FPGA Configuration Settings ---
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
# -------------------------------------------------------------------


## 12 MHz Clock Signal
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 83.333 [get_ports { clk }];


## On-Board Button (Reset Only)
# BTN1 is used for system reset. A pull-up is enabled.
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { reset }];


## External Inputs for Buttons (Mapped to your specified GPIO pins with Pull-ups)
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { enter }];
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports { onesBtn }];
set_property -dict { PACKAGE_PIN W7    IOSTANDARD LVCMOS33 } [get_ports { tensBtn }];
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports { hundredsBtn }];
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports { sign }];


## 7-Segment Display Segments (Using your stopwatch project's Pmod pins)
# seg[0]=a, seg[1]=b, seg[2]=c, seg[3]=d, seg[4]=e, seg[5]=f, seg[6]=g
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { seg[0] }]; # Sch=ja[1]
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports { seg[1] }]; # Sch=ja[2]
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { seg[2] }]; # Sch=ja[3]
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { seg[3] }]; # Sch=ja[4]
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { seg[4] }]; # Sch=ja[7]
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [get_ports { seg[5] }]; # Sch=ja[8]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports { seg[6] }]; # Sch=ja[9]


## 7-Segment Display Anodes (Using your stopwatch project's GPIO pins)
set_property -dict { PACKAGE_PIN M3    IOSTANDARD LVCMOS33 } [get_ports { anode[0] }];
set_property -dict { PACKAGE_PIN L3    IOSTANDARD LVCMOS33 } [get_ports { anode[1] }];
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports { anode[2] }];
set_property -dict { PACKAGE_PIN K3    IOSTANDARD LVCMOS33 } [get_ports { anode[3] }];
