## Generated SDC file "hello_led.out.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 216 11/23/2011 Service Pack 1 SJ Web Edition"

## DATE    "Fri Jul 06 23:05:47 2012"

##
## DEVICE  "EP3C25Q240C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

# create_clock -name clk_27 -period 37.037 [get_ports {CLOCK_27}]
# create_clock -name {SPI_SCK}  -period 41.666 -waveform { 20.8 41.666 } [get_ports {SPI_SCK}]

set sdram_clk "${topmodule}atari800core_mist|pll_switcher|generic_pll2|altpll_component|auto_generated|pll1|clk[2]"
set mem_clk   "${topmodule}atari800core_mist|pll_switcher|generic_pll2|altpll_component|auto_generated|pll1|clk[0]"
set sys_clk   "${topmodule}atari800core_mist|pll_switcher|generic_pll2|altpll_component|auto_generated|pll1|clk[1]"

#**************************************************************
# Create Generated Clock
#**************************************************************

# derive_pll_clocks

#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************

# derive_clock_uncertainty;

#**************************************************************
# Set Input Delay
#**************************************************************

# SDRAM is clocked from sd1clk_pin, but the SDRAM controller uses memclk
set_input_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -max 6.4 [get_ports ${RAM_IN}]
set_input_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -min 3.2 [get_ports ${RAM_IN}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -max 1.5 [get_ports ${RAM_OUT}]
set_output_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -min -0.8 [get_ports ${RAM_OUT}]

set_output_delay -clock [get_clocks $sys_clk] -max 0 [get_ports ${VGA_OUT}]
set_output_delay -clock [get_clocks $sys_clk] -min -5 [get_ports ${VGA_OUT}]

#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks spiclk] -group [get_clocks {${topmodule}atari800core_mist|pll_switcher|*}]
set_clock_groups -asynchronous -group [get_clocks clock50] -group [get_clocks {${topmodule}atari800core_mist|pll_switcher|*}]
set_clock_groups -asynchronous -group [get_clocks {${topmodule}atari800core_mist|reconfig_pll|*}] -group [get_clocks {${topmodule}atari800core_mist|pll_switcher|*}]

#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_ports {UART_TX}]
set_false_path -to [get_ports {AUDIO_L}]
set_false_path -to [get_ports {AUDIO_R}]
set_false_path -to [get_ports {LED}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -to {VGA_*[*]} -setup 2
set_multicycle_path -to {VGA_*[*]} -hold 1

set_multicycle_path -from [get_clocks $sdram_clk] -to [get_clocks $mem_clk] -setup 2

#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
