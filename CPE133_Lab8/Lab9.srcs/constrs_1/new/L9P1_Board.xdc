set_property PACKAGE_PIN V17 [get_ports {Exams}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Exams}]

set_property PACKAGE_PIN V16 [get_ports {Coffee}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Coffee}]

set_property PACKAGE_PIN U18 [get_ports {Reset}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Reset}]


set_property PACKAGE_PIN W5 [get_ports {Clk}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Clk}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {Clk}]


set_property PACKAGE_PIN U16 [get_ports {Grades}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Grades}]

set_property PACKAGE_PIN L1 [get_ports {Housework}]       
set_property IOSTANDARD LVCMOS33 [get_ports {Housework}]


set_property PACKAGE_PIN W4 [get_ports {AN[3]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]

set_property PACKAGE_PIN V4 [get_ports {AN[2]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]

set_property PACKAGE_PIN U4 [get_ports {AN[1]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]

set_property PACKAGE_PIN U2 [get_ports {AN[0]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]


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

