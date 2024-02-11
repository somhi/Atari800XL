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
module usbDeviceActelTop (

  //
  // Global signals
  //
  clk,
  rst_n,

  // eval board features
  ledOut,

  //
  // USB
  //
  usbSlaveVP,
  usbSlaveVM,
  usbSlaveOE_n,
  usbDPlusPullup

);

  //
  // Global signals
  //
  input	clk;
  input rst_n;

  output [9:0] ledOut;

  //
  // USB
  //
  inout usbSlaveVP;
  inout usbSlaveVM;
  output usbSlaveOE_n;
  output usbDPlusPullup;

//local wires and regs
reg [1:0] rstReg;
wire rst;

//generate sync reset
always @(posedge clk) begin
  rstReg[1:0] <= {rstReg[0], ~rst_n};
end
assign rst = rstReg[1];


usbDevice u_usbDevice (
  .clk(clk),
  .rst(rst),
  .usbSlaveVP_in(usbSlaveVP_in),
  .usbSlaveVM_in(usbSlaveVM_in),
  .usbSlaveVP_out(usbSlaveVP_out),
  .usbSlaveVM_out(usbSlaveVM_out),
  .usbSlaveOE_n(usbSlaveOE_n),
  .usbDPlusPullup(usbDPlusPullup),
  .vBusDetect(1'b1)
);


assign {usbSlaveVP_in, usbSlaveVM_in} = {usbSlaveVP, usbSlaveVM};
assign {usbSlaveVP, usbSlaveVM} = (usbSlaveOE_n == 1'b0) ? {usbSlaveVP_out, usbSlaveVM_out} : 2'bzz;


// comfort lights
reg [9:0] ledCntReg;
reg [21:0] cnt;

assign ledOut = ledCntReg;


always @(posedge clk) begin
  if (rst == 1'b1) begin
    ledCntReg <= 10'b00_0000_0000;
    cnt <= {22{1'b0}};
  end
  else begin
    cnt <= cnt + 1'b1;
    if (cnt == {22{1'b0}})
      ledCntReg <= ledCntReg + 1'b1;
  end
end

endmodule


