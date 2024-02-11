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
  
*/// ----------------------------- usbDevice_define ---------------------------

`define ZERO_ZERO_STAT_INDEX 8'h6c
`define ONE_ZERO_STAT_INDEX 8'h6e
`define VENDOR_DATA_STAT_INDEX 8'h70
`define DEV_DESC_INDEX 8'h00
`define DEV_DESC_SIZE 8'h12
//config descriptor is bundled with interface desc, HID desc, and EP1 desc
`define CFG_DESC_INDEX 8'h12
`define CFG_DESC_SIZE 8'h22
`define REP_DESC_INDEX 8'h3a
`define REP_DESC_SIZE 8'h32
`define LANGID_DESC_INDEX 8'h80
`define LANGID_DESC_SIZE 8'h04
`define STRING1_DESC_INDEX 8'h90
`define STRING1_DESC_SIZE 8'd26
`define STRING2_DESC_INDEX 8'hb0
`define STRING2_DESC_SIZE 8'd20
`define STRING3_DESC_INDEX 8'hd0
`define STRING3_DESC_SIZE 8'd30

`define DEV_DESC 8'h01
`define CFG_DESC 8'h02
`define REP_DESC 8'h22
`define STRING_DESC 8'h03

//delays at 48MHz
`ifdef SIM_COMPILE
`define ONE_MSEC_DEL 16'h0300
`else
`define ONE_MSEC_DEL 16'hbb80
`endif
`define ONE_USEC_DEL 8'h30

`define GET_STATUS 8'h00
`define CLEAR_FEATURE 8'h01
`define SET_FEATURE 8'h03
`define SET_ADDRESS 8'h05
`define GET_DESCRIPTOR 8'h06
`define SET_DESCRIPTOR 8'h07
`define GET_CONFIG 8'h08
`define SET_CONFIG 8'h09
`define GET_INTERFACE 8'h0a
`define SET_INTERFACE 8'h0b
`define SYNCH_FRAME 8'h0c

`define MAX_RESP_SIZE 8'h40

