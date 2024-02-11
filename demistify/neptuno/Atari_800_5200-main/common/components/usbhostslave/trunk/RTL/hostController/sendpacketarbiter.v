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
// File        : ../RTL/hostController/sendpacketarbiter.v
// Generated   : 11/10/06 05:37:20
// From        : ../RTL/hostController/sendpacketarbiter.asf
// By          : FSM2VHDL ver. 5.0.0.9

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// sendpacketarbiter
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
`include "usbConstants_h.v"

module sendPacketArbiter (HCTxGnt, HCTxReq, HC_PID, HC_SP_WEn, SOFTxGnt, SOFTxReq, SOF_SP_WEn, clk, rst, sendPacketPID, sendPacketWEnable);
input   HCTxReq;
input   [3:0] HC_PID;
input   HC_SP_WEn;
input   SOFTxReq;
input   SOF_SP_WEn;
input   clk;
input   rst;
output  HCTxGnt;
output  SOFTxGnt;
output  [3:0] sendPacketPID;
output  sendPacketWEnable;

reg     HCTxGnt, next_HCTxGnt;
wire    HCTxReq;
wire    [3:0] HC_PID;
wire    HC_SP_WEn;
reg     SOFTxGnt, next_SOFTxGnt;
wire    SOFTxReq;
wire    SOF_SP_WEn;
wire    clk;
wire    rst;
reg     [3:0] sendPacketPID, next_sendPacketPID;
reg     sendPacketWEnable, next_sendPacketWEnable;

// diagram signals declarations
reg  muxSOFNotHC, next_muxSOFNotHC;

// BINARY ENCODED state machine: sendPktArb
// State codes definitions:
`define HC_ACT 2'b00
`define SOF_ACT 2'b01
`define SARB_WAIT_REQ 2'b10
`define START_SARB 2'b11

reg [1:0] CurrState_sendPktArb;
reg [1:0] NextState_sendPktArb;

// Diagram actions (continuous assignments allowed only: assign ...)

// hostController/SOFTransmit mux
always @(muxSOFNotHC or SOF_SP_WEn or HC_SP_WEn or HC_PID)
begin
    if (muxSOFNotHC  == 1'b1)
    begin
        sendPacketWEnable <= SOF_SP_WEn;
        sendPacketPID <= `SOF;
    end
    else
    begin
        sendPacketWEnable <= HC_SP_WEn;
        sendPacketPID <= HC_PID;
    end
end

//--------------------------------------------------------------------
// Machine: sendPktArb
//--------------------------------------------------------------------
//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (HCTxReq or SOFTxReq or HCTxGnt or SOFTxGnt or muxSOFNotHC or CurrState_sendPktArb)
begin : sendPktArb_NextState
  NextState_sendPktArb <= CurrState_sendPktArb;
  // Set default values for outputs and signals
  next_HCTxGnt <= HCTxGnt;
  next_SOFTxGnt <= SOFTxGnt;
  next_muxSOFNotHC <= muxSOFNotHC;
  case (CurrState_sendPktArb)
    `HC_ACT:
      if (HCTxReq == 1'b0)	
      begin
        NextState_sendPktArb <= `SARB_WAIT_REQ;
        next_HCTxGnt <= 1'b0;
      end
    `SOF_ACT:
      if (SOFTxReq == 1'b0)	
      begin
        NextState_sendPktArb <= `SARB_WAIT_REQ;
        next_SOFTxGnt <= 1'b0;
      end
    `SARB_WAIT_REQ:
      if (SOFTxReq == 1'b1)	
      begin
        NextState_sendPktArb <= `SOF_ACT;
        next_SOFTxGnt <= 1'b1;
        next_muxSOFNotHC <= 1'b1;
      end
      else if (HCTxReq == 1'b1)	
      begin
        NextState_sendPktArb <= `HC_ACT;
        next_HCTxGnt <= 1'b1;
        next_muxSOFNotHC <= 1'b0;
      end
    `START_SARB:
      NextState_sendPktArb <= `SARB_WAIT_REQ;
  endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk)
begin : sendPktArb_CurrentState
  if (rst)	
    CurrState_sendPktArb <= `START_SARB;
  else
    CurrState_sendPktArb <= NextState_sendPktArb;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk)
begin : sendPktArb_RegOutput
  if (rst)	
  begin
    muxSOFNotHC <= 1'b0;
    SOFTxGnt <= 1'b0;
    HCTxGnt <= 1'b0;
  end
  else 
  begin
    muxSOFNotHC <= next_muxSOFNotHC;
    SOFTxGnt <= next_SOFTxGnt;
    HCTxGnt <= next_HCTxGnt;
  end
end

endmodule