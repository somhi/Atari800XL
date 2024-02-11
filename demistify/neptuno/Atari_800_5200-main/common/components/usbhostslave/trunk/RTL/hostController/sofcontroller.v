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
  
*/
// File        : ../RTL/hostController/sofcontroller.v
// Generated   : 11/10/06 05:37:21
// From        : ../RTL/hostController/sofcontroller.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// sofcontroller
////                                                              ////
//// This file is part of the usbhostslave opencores effort.
//// http://www.opencores.org/cores/usbhostslave/                 ////
////                                                              ////
//// Module Description:                                          ////
//// 
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "timescale.v"
`include "usbSerialInterfaceEngine_h.v"

module SOFController (HCTxPortCntl, HCTxPortData, HCTxPortGnt, HCTxPortRdy, HCTxPortReq, HCTxPortWEn, SOFEnable, SOFTimerClr, SOFTimer, clk, rst);
input   HCTxPortGnt;
input   HCTxPortRdy;
input   SOFEnable;
input   SOFTimerClr;
input   clk;
input   rst;
output  [7:0] HCTxPortCntl;
output  [7:0] HCTxPortData;
output  HCTxPortReq;
output  HCTxPortWEn;
output  [15:0] SOFTimer;

reg     [7:0] HCTxPortCntl, next_HCTxPortCntl;
reg     [7:0] HCTxPortData, next_HCTxPortData;
wire    HCTxPortGnt;
wire    HCTxPortRdy;
reg     HCTxPortReq, next_HCTxPortReq;
reg     HCTxPortWEn, next_HCTxPortWEn;
wire    SOFEnable;
wire    SOFTimerClr;
reg     [15:0] SOFTimer, next_SOFTimer;
wire    clk;
wire    rst;

// BINARY ENCODED state machine: sofCntl
// State codes definitions:
`define START_SC 3'b000
`define WAIT_SOF_EN 3'b001
`define WAIT_SEND_RESUME 3'b010
`define INC_TIMER 3'b011
`define SC_WAIT_GNT 3'b100
`define CLR_WEN 3'b101

reg [2:0] CurrState_sofCntl;
reg [2:0] NextState_sofCntl;


//--------------------------------------------------------------------
// Machine: sofCntl
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (SOFTimerClr or SOFTimer or SOFEnable or HCTxPortRdy or HCTxPortGnt or HCTxPortReq or HCTxPortWEn or HCTxPortData or HCTxPortCntl or CurrState_sofCntl)
begin : sofCntl_NextState
  NextState_sofCntl <= CurrState_sofCntl;
  // Set default values for outputs and signals
  next_HCTxPortReq <= HCTxPortReq;
  next_HCTxPortWEn <= HCTxPortWEn;
  next_HCTxPortData <= HCTxPortData;
  next_HCTxPortCntl <= HCTxPortCntl;
  next_SOFTimer <= SOFTimer;
  case (CurrState_sofCntl)
    `START_SC:
      NextState_sofCntl <= `WAIT_SOF_EN;
    `WAIT_SOF_EN:
      if (SOFEnable == 1'b1)	
      begin
        NextState_sofCntl <= `SC_WAIT_GNT;
        next_HCTxPortReq <= 1'b1;
      end
    `WAIT_SEND_RESUME:
      if (HCTxPortRdy == 1'b1)	
      begin
        NextState_sofCntl <= `CLR_WEN;
        next_HCTxPortWEn <= 1'b1;
        next_HCTxPortData <= 8'h00;
        next_HCTxPortCntl <= `TX_RESUME_START;
      end
    `INC_TIMER:
    begin
      next_HCTxPortReq <= 1'b0;
      if (SOFTimerClr == 1'b1)
        next_SOFTimer <= 16'h0000;
      else
        next_SOFTimer <= SOFTimer + 1'b1;
      if (SOFEnable == 1'b0)	
      begin
        NextState_sofCntl <= `WAIT_SOF_EN;
        next_SOFTimer <= 16'h0000;
      end
    end
    `SC_WAIT_GNT:
      if (HCTxPortGnt == 1'b1)	
        NextState_sofCntl <= `WAIT_SEND_RESUME;
    `CLR_WEN:
    begin
      next_HCTxPortWEn <= 1'b0;
      NextState_sofCntl <= `INC_TIMER;
    end
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : sofCntl_CurrentState
  if (rst)	
    CurrState_sofCntl <= `START_SC;
  else
    CurrState_sofCntl <= NextState_sofCntl;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : sofCntl_RegOutput
  if (rst)	
  begin
    SOFTimer <= 16'h0000;
    HCTxPortCntl <= 8'h00;
    HCTxPortData <= 8'h00;
    HCTxPortWEn <= 1'b0;
    HCTxPortReq <= 1'b0;
  end
  else 
  begin
    SOFTimer <= next_SOFTimer;
    HCTxPortCntl <= next_HCTxPortCntl;
    HCTxPortData <= next_HCTxPortData;
    HCTxPortWEn <= next_HCTxPortWEn;
    HCTxPortReq <= next_HCTxPortReq;
  end
end

endmodule