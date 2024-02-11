/*
  
   Multicore 2 / Multicore 2+
  
   Copyright (c) 2017-2020 - Victor Trucco

  
   All rights reserved
  
   Redistribution and use in source and synthezised forms, with or without
   modification, are permitted provided that the following conditions are met:
  
   Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
  
   Redistributions in synthesized form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
  
   Neither the name of the author nor the names of other contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.
  
   THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
  
   You are responsible for any legal issues arising from your use of this code.
  
*/// (C) 2001-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


//Copyright (C) 1991-2014 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.

module altera_serial_flash_loader (
	asmi_access_granted,
	asdo_in,
	data_in,
	data_oe,
	dclk_in,
	ncso_in,
	noe_in,
	asmi_access_request,
	data0_out,
	data_out);

	parameter
		ENABLE_QUAD_SPI_SUPPORT = 1,
		ENABLE_SHARED_ACCESS = "ON",
		ENHANCED_MODE = 1,
		INTENDED_DEVICE_FAMILY = "Arria 10",
		NCSO_WIDTH = 3;
		
	input	asmi_access_granted;
	input	asdo_in;
	input	[3:0]  data_in;
	input	[3:0]  data_oe;
	input	dclk_in;
	input	[NCSO_WIDTH-1:0]  ncso_in;
	input	noe_in;
	output	asmi_access_request;
	output	data0_out;
	output	[3:0]  data_out;

	wire	sub_wire0;
	wire	sub_wire1;
	wire	[3:0] sub_wire2;
	wire	asmi_access_request = sub_wire0;
	wire	data0_out = sub_wire1;
	wire	[3:0] data_out = sub_wire2[3:0];

	altserial_flash_loader	altserial_flash_loader_component (
				.asmi_access_granted (asmi_access_granted),
				.data_in (data_in),
				.data_oe (data_oe),
				.dclkin (dclk_in),
				.noe (noe_in),
				.scein (ncso_in),
				.asmi_access_request (sub_wire0),
				.data_out (sub_wire2),
				.data0out (sub_wire1),
				.sdoin (asdo_in)
				);
	defparam
		altserial_flash_loader_component.enable_quad_spi_support = ENABLE_QUAD_SPI_SUPPORT,
		altserial_flash_loader_component.enable_shared_access = ENABLE_SHARED_ACCESS,
		altserial_flash_loader_component.enhanced_mode = ENHANCED_MODE,
		altserial_flash_loader_component.intended_device_family = INTENDED_DEVICE_FAMILY,
		altserial_flash_loader_component.ncso_width = NCSO_WIDTH;


endmodule
