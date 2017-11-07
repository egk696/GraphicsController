## Generated SDC file "GraphicsController.sdc"

## Copyright (C) 2016  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"

## DATE    "Wed May 31 20:09:45 2017"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {SYS_CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks

#create_generated_clock -name {pll_logic_clk_40} -source [get_pins {vga_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 4 -divide_by 5 -master_clock {SYS_CLK} [get_pins {vga_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]
#create_generated_clock -name {pll_logic_clk_65} -source [get_pins {vga_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 13 -divide_by 10 -master_clock {SYS_CLK} [get_pins {vga_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] 

create_generated_clock -name {pll_vga_clk_40} -source [get_pins {vga_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] [get_ports {VGA_CLK}]
create_generated_clock -name {pll_vga_clk_65} -source [get_pins {vga_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] [get_ports {VGA_CLK}] -add 
create_generated_clock -name {pll_vga_clk_108} -source [get_pins {vga_pll_inst|altpll_component|auto_generated|pll2|clk[0]}] [get_ports {VGA_CLK}] -add 

# Set the two clocks as exclusive clocks
set_clock_groups -exclusive -group {pll_vga_clk_40} -group {pll_vga_clk_65} -group {pll_vga_clk_108}

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty;


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock {pll_vga_clk_108} -max 0.68 [get_ports VGA_*]
set_output_delay -clock {pll_vga_clk_108} -min -2.9 [get_ports VGA_*]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_ports {RST EN SEL}] -to *


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

