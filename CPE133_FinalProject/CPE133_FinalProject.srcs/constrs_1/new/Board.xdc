set_property PACKAGE_PIN T17 [get_ports {jump}]       
set_property IOSTANDARD LVCMOS33 [get_ports {jump}]

set_property PACKAGE_PIN U18 [get_ports {RST}]       
set_property IOSTANDARD LVCMOS33 [get_ports {RST}]

set_property PACKAGE_PIN T18 [get_ports {start}]       
set_property IOSTANDARD LVCMOS33 [get_ports {start}]


set_property PACKAGE_PIN U16 [get_ports {LED[0]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]

set_property PACKAGE_PIN E19 [get_ports {LED[1]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]

set_property PACKAGE_PIN U19 [get_ports {LED[2]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]

set_property PACKAGE_PIN V19 [get_ports {LED[3]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]

set_property PACKAGE_PIN W18 [get_ports {LED[4]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]

set_property PACKAGE_PIN U15 [get_ports {LED[5]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]

set_property PACKAGE_PIN U14 [get_ports {LED[6]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]

set_property PACKAGE_PIN V14 [get_ports {LED[7]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]

set_property PACKAGE_PIN V13 [get_ports {LED[8]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]

set_property PACKAGE_PIN V3 [get_ports {LED[9]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]

set_property PACKAGE_PIN W3 [get_ports {LED[10]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]

set_property PACKAGE_PIN U3 [get_ports {LED[11]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]

set_property PACKAGE_PIN P3 [get_ports {LED[12]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]

set_property PACKAGE_PIN N3 [get_ports {LED[13]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]

set_property PACKAGE_PIN P1 [get_ports {LED[14]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]

set_property PACKAGE_PIN L1 [get_ports {LED[15]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]


set_property PACKAGE_PIN U2 [get_ports {AN[0]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]

set_property PACKAGE_PIN U4 [get_ports {AN[1]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]

set_property PACKAGE_PIN V4 [get_ports {AN[2]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]

set_property PACKAGE_PIN W4 [get_ports {AN[3]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]


set_property PACKAGE_PIN W7 [get_ports {CAT[7]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[7]}]

set_property PACKAGE_PIN W6 [get_ports {CAT[6]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[6]}]

set_property PACKAGE_PIN U8 [get_ports {CAT[5]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[5]}]

set_property PACKAGE_PIN V8 [get_ports {CAT[4]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[4]}]

set_property PACKAGE_PIN U5 [get_ports {CAT[3]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[3]}]

set_property PACKAGE_PIN V5 [get_ports {CAT[2]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[2]}]

set_property PACKAGE_PIN U7 [get_ports {CAT[1]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[1]}]

set_property PACKAGE_PIN V7 [get_ports {CAT[0]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {CAT[0]}]


set_property PACKAGE_PIN W5 [get_ports {Clk}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Clk}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {Clk}]