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
////                                                              ////
////  wb_master_model.v                                           ////
////                                                              ////
////  This file is part of the SPI IP core project                ////
////  http://www.opencores.org/projects/spi/                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Srot (simons@opencores.org)                     ////
////                                                              ////
////  Based on:                                                   ////
////      - i2c/bench/verilog/wb_master_model.v                   ////
////        Copyright (C) 2001 Richard Herveille                  ////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002 Authors                                   ////
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
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "timescale.v"

module wb_master_model(clk, rst, adr, din, dout, cyc, stb, we, sel, ack, err, rty);

  parameter dwidth = 32;
  parameter awidth = 32;
  
  input                  clk, rst;
  output [awidth   -1:0] adr;
  input  [dwidth   -1:0] din;
  output [dwidth   -1:0] dout;
  output                 cyc, stb;
  output                 we;
  output [dwidth/8 -1:0] sel;
  input                  ack, err, rty;
  
  // Internal signals
  reg    [awidth   -1:0] adr;
  reg    [dwidth   -1:0] dout;
  reg                    cyc, stb;
  reg                    we;
  reg    [dwidth/8 -1:0] sel;
         
  reg    [dwidth   -1:0] q;
  
  // Memory Logic
  initial
    begin
      adr  = {awidth{1'bx}};
      dout = {dwidth{1'bx}};
      cyc  = 1'b0;
      stb  = 1'bx;
      we   = 1'hx;
      sel  = {dwidth/8{1'bx}};
      #1;
    end
  
  // Wishbone write cycle
  task wb_write;
    input   delay;
    integer delay;
  
    input [awidth -1:0] a;
    input [dwidth -1:0] d;
  
    begin
  
      // wait initial delay
      repeat(delay) @(posedge clk);
  
      // assert wishbone signal
      #1;
      adr  = a;
      dout = d;
      cyc  = 1'b1;
      stb  = 1'b1;
      we   = 1'b1;
      sel  = {dwidth/8{1'b1}};
      @(posedge clk);
  
      // wait for acknowledge from slave
      while(~ack) @(posedge clk);
  
      // negate wishbone signals
      #1;
      cyc  = 1'b0;
      stb  = 1'bx;
      adr  = {awidth{1'bx}};
      dout = {dwidth{1'bx}};
      we   = 1'hx;
      sel  = {dwidth/8{1'bx}};
  
    end
  endtask
  
  // Wishbone read cycle
  task wb_read;
    input   delay;
    integer delay;
  
    input  [awidth -1:0]  a;
    output  [dwidth -1:0] d;
  
    begin
  
      // wait initial delay
      repeat(delay) @(posedge clk);
  
      // assert wishbone signals
      #1;
      adr  = a;
      dout = {dwidth{1'bx}};
      cyc  = 1'b1;
      stb  = 1'b1;
      we   = 1'b0;
      sel  = {dwidth/8{1'b1}};
      @(posedge clk);
  
      // wait for acknowledge from slave
      while(~ack) @(posedge clk);
  
      // negate wishbone signals
      #1;
      cyc  = 1'b0;
      stb  = 1'bx;
      adr  = {awidth{1'bx}};
      dout = {dwidth{1'bx}};
      we   = 1'hx;
      sel  = {dwidth/8{1'bx}};
      d    = din;
  
    end
  endtask
  
  // Wishbone compare cycle (read data from location and compare with expected data)
  task wb_cmp;
    input   delay;
    integer delay;
  
    input [awidth -1:0] a;
    input [dwidth -1:0] d_exp;
  
    begin
      wb_read (delay, a, q);

      if (d_exp !== q) begin
        $display("\n--- ERROR: At address 0x%0x, got 0x%0x, expected 0x%0x at time %t", a, q, d_exp, $time);
        $stop;
      end
    end
  endtask
  
endmodule
 
