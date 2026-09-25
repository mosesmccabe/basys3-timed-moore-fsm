## FPGA configuration voltage (as used in Day 11)
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## Basys 3 100 MHz clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clk]

## Active-high, synchronous reset on center pushbutton
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports rst]

## Basys 3 LEDs: labels are logical states; physical onboard LEDs have same color
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports red_led]    ;# LD0
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports green_led]  ;# LD1
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports yellow_led] ;# LD2
