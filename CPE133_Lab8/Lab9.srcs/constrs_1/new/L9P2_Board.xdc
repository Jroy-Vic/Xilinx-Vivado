set_property PACKAGE_PIN V17 [get_ports {EIN}]       
set_property IOSTANDARD LVCMOS33 [get_ports {EIN}]

set_property PACKAGE_PIN V16 [get_ports {RST}]       
set_property IOSTANDARD LVCMOS33 [get_ports {RST}]


set_property PACKAGE_PIN W4 [get_ports {AN[3]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]

set_property PACKAGE_PIN V4 [get_ports {AN[2]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]

set_property PACKAGE_PIN U4 [get_ports {AN[1]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]

set_property PACKAGE_PIN U2 [get_ports {AN[0]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]


set_property PACKAGE_PIN W7 [get_ports {SQNCE[7]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[7]}]

set_property PACKAGE_PIN W6 [get_ports {SQNCE[6]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[6]}]

set_property PACKAGE_PIN U8 [get_ports {SQNCE[5]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[5]}]

set_property PACKAGE_PIN V8 [get_ports {SQNCE[4]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[4]}]

set_property PACKAGE_PIN U5 [get_ports {SQNCE[3]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[3]}]

set_property PACKAGE_PIN V5 [get_ports {SQNCE[2]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[2]}]

set_property PACKAGE_PIN U7 [get_ports {SQNCE[1]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[1]}]

set_property PACKAGE_PIN V7 [get_ports {SQNCE[0]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {SQNCE[0]}]


set_property PACKAGE_PIN W5 [get_ports {Clk}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Clk}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {Clk}]
