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
  
*///////////////////////////////////////////////////////////////////////
// wishBoneBus_h.v                                              
//////////////////////////////////////////////////////////////////////

`ifdef wishBoneBus_h_vdefined
`else
`define wishBoneBus_h_vdefined
 
//memoryMap
`define HCREG_BASE 8'h00
`define HCREG_BASE_PLUS_0X10 8'h10
`define HOST_RX_FIFO_BASE 8'h20
`define HOST_TX_FIFO_BASE 8'h30
`define SCREG_BASE 8'h40
`define SCREG_BASE_PLUS_0X10 8'h50
`define EP0_RX_FIFO_BASE 8'h60
`define EP0_TX_FIFO_BASE 8'h70
`define EP1_RX_FIFO_BASE 8'h80
`define EP1_TX_FIFO_BASE 8'h90
`define EP2_RX_FIFO_BASE 8'ha0
`define EP2_TX_FIFO_BASE 8'hb0
`define EP3_RX_FIFO_BASE 8'hc0
`define EP3_TX_FIFO_BASE 8'hd0
`define HOST_SLAVE_CONTROL_BASE 8'he0
`define ADDRESS_DECODE_MASK 8'hf0

//FifoAddresses
`define FIFO_DATA_REG 3'b000
`define FIFO_STATUS_REG 3'b001
`define FIFO_DATA_COUNT_MSB 3'b010
`define FIFO_DATA_COUNT_LSB 3'b011
`define FIFO_CONTROL_REG 3'b100

`endif //wishBoneBus_h_vdefined

