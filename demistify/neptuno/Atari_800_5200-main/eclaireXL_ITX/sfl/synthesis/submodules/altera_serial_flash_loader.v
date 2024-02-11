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
  
*/// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps

module altera_serial_flash_loader (
	dclk_in,
	ncso_in,
	asmi_access_granted,
	asmi_access_request,
	data_in,
	data_oe,
	data_out,
	noe_in);

	parameter
		ENABLE_QUAD_SPI_SUPPORT = 1,
		ENABLE_SHARED_ACCESS = "ON",
		ENHANCED_MODE = 1,
		INTENDED_DEVICE_FAMILY = "Arria 10",
		NCSO_WIDTH = 3;
		
	input	dclk_in;
	input	[NCSO_WIDTH-1:0]  ncso_in;
	input	asmi_access_granted;
	output	asmi_access_request;
	input	[3:0]  data_in;
	input	[3:0]  data_oe;
	output	[3:0]  data_out;
	input	noe_in;

	altserial_flash_loader	altserial_flash_loader_component (
				.dclkin (dclk_in),
				.scein (ncso_in),
				.asmi_access_granted (asmi_access_granted),
				.asmi_access_request (asmi_access_request),
				.sdoin (),
				.data0out (),
				.data_in (data_in),
				.data_oe (data_oe),
				.data_out (data_out),
				.noe (noe_in));
	defparam
		altserial_flash_loader_component.enable_quad_spi_support = ENABLE_QUAD_SPI_SUPPORT,
		altserial_flash_loader_component.enable_shared_access = ENABLE_SHARED_ACCESS,
		altserial_flash_loader_component.enhanced_mode = ENHANCED_MODE,
		altserial_flash_loader_component.intended_device_family = INTENDED_DEVICE_FAMILY,
		altserial_flash_loader_component.ncso_width = NCSO_WIDTH;


endmodule


