set_property PACKAGE_PIN Y21 [get_ports {blue[0]}];
set_property PACKAGE_PIN Y20 [get_ports {blue[1]}];
set_property PACKAGE_PIN AB20 [get_ports {blue[2]}];
set_property PACKAGE_PIN AB19 [get_ports {blue[3]}];
set_property PACKAGE_PIN AB22 [get_ports {green[0]}];
set_property PACKAGE_PIN AA22 [get_ports {green[1]}];
set_property PACKAGE_PIN AB21 [get_ports {green[2]}];
set_property PACKAGE_PIN AA21 [get_ports {green[3]}];
set_property PACKAGE_PIN V20 [get_ports {red[0]}];
set_property PACKAGE_PIN U20 [get_ports {red[1]}];
set_property PACKAGE_PIN V19 [get_ports {red[2]}];
set_property PACKAGE_PIN V18 [get_ports {red[3]}];
set_property PACKAGE_PIN AA19 [get_ports {hsync}];
set_property PACKAGE_PIN Y19 [get_ports {vsync}];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

set_property PACKAGE_PIN Y9 [get_ports clk];
set_property IOSTANDARD LVCMOS33 [get_ports clk];
create_clock -period 10 [get_ports clk];


# On-board
set_property PACKAGE_PIN P16 [get_ports {btnc}];
set_property PACKAGE_PIN T18 [get_ports {btnu}];
set_property PACKAGE_PIN R16 [get_ports {btnd}];
set_property PACKAGE_PIN N15 [get_ports {btnl}];
set_property PACKAGE_PIN R18 [get_ports {btnr}];
set_property IOSTANDARD LVCMOS25 [get_ports btnc];
set_property IOSTANDARD LVCMOS25 [get_ports btnl];
set_property IOSTANDARD LVCMOS25 [get_ports btnr];
set_property IOSTANDARD LVCMOS25 [get_ports btnu];
set_property IOSTANDARD LVCMOS25 [get_ports btnd];
set_property PACKAGE_PIN F22 [get_ports {switch[0]}];
set_property PACKAGE_PIN G22 [get_ports {switch[1]}];
set_property PACKAGE_PIN H22 [get_ports {switch[2]}];
set_property PACKAGE_PIN F21 [get_ports {switch[3]}];
set_property PACKAGE_PIN H19 [get_ports {switch[4]}];
set_property PACKAGE_PIN H18 [get_ports {switch[5]}];
set_property PACKAGE_PIN H17 [get_ports {switch[6]}];
set_property PACKAGE_PIN M15 [get_ports {switch[7]}];
set_property IOSTANDARD LVCMOS25 [get_ports switch];
set_property PACKAGE_PIN T22 [get_ports {led[0]}];
set_property PACKAGE_PIN T21 [get_ports {led[1]}];
set_property PACKAGE_PIN U22 [get_ports {led[2]}];
set_property PACKAGE_PIN U21 [get_ports {led[3]}];
set_property IOSTANDARD LVCMOS33 [get_ports led];

# Amp
#set_property PACKAGE_PIN V4 [get_ports data_out];
#set_property PACKAGE_PIN V5 [get_ports sck];
#set_property PACKAGE_PIN W7 [get_ports lrck];
#set_property PACKAGE_PIN V7 [get_ports mck];
#set_property IOSTANDARD LVCMOS33 [get_ports data_out];
#set_property IOSTANDARD LVCMOS33 [get_ports mck];                                                  
#set_property IOSTANDARD LVCMOS33 [get_ports lrck];
#set_property IOSTANDARD LVCMOS33 [get_ports sck];


# Vibrator
set_property PACKAGE_PIN W12 [get_ports vib_1];
set_property IOSTANDARD LVCMOS33 [get_ports vib_1];
set_property PACKAGE_PIN W8 [get_ports vib_2];
set_property IOSTANDARD LVCMOS33 [get_ports vib_2];

# Joystick
# P1
set_property PACKAGE_PIN AA4 [get_ports sclk];
set_property PACKAGE_PIN Y4 [get_ports miso];
set_property PACKAGE_PIN AB6 [get_ports mosi];
set_property PACKAGE_PIN AB7 [get_ports cs_n];
set_property IOSTANDARD LVCMOS33 [get_ports mosi];
set_property IOSTANDARD LVCMOS33 [get_ports cs_n];                                                  
set_property IOSTANDARD LVCMOS33 [get_ports sclk];
set_property IOSTANDARD LVCMOS33 [get_ports miso];
# P2
set_property PACKAGE_PIN AA9 [get_ports sclk2];
set_property PACKAGE_PIN Y10 [get_ports miso2];
set_property PACKAGE_PIN AA11 [get_ports mosi2];
set_property PACKAGE_PIN Y11 [get_ports cs_n2];
set_property IOSTANDARD LVCMOS33 [get_ports mosi2];
set_property IOSTANDARD LVCMOS33 [get_ports cs_n2];                                                  
set_property IOSTANDARD LVCMOS33 [get_ports sclk2];
set_property IOSTANDARD LVCMOS33 [get_ports miso2];