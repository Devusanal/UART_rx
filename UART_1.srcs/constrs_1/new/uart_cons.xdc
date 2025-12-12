## Clock Signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Reset Button (Red button labelled RESET on board, Active Low)
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports rst_n]

## USB-UART Interface
## The pin named "uart_txd_in" on the FPGA receives data from the USB-UART bridge
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports uart_txd_in]

## Green LEDs (Lower 4 bits)
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

## RGB LEDs (Blue Component - Upper 4 bits)
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports led0_b]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports led1_b]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports led2_b]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports led3_b]
# Note: Check pin E1 vs K1 depending on board revision.
# Usually led3_b is on pin K1 or similar, but verify schematics if led3 doesn't light up.
# Correction for Arty A7 100T Standard master:
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports led3_b]

