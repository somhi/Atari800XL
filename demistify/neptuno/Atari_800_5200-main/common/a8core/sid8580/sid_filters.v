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
module sid_filters
(
	input             clk,
	input             rst,
	input      [ 7:0] Fc_lo,
	input      [ 7:0] Fc_hi,
	input      [ 7:0] Res_Filt,
	input      [ 7:0] Mode_Vol,
	input      [11:0] voice1,
	input      [11:0] voice2,
	input      [11:0] voice3,
	input             input_valid,
	input      [11:0] ext_in,
	input             extfilter_en,

	output reg [17:0] sound
);

reg signed [17:0] Vhp;
reg signed [17:0] Vbp;
reg signed [17:0] w0;
reg signed [17:0] q;

wire [10:0] divmul[16];
assign divmul[0]  = 1448;
assign divmul[1]  = 1328;
assign divmul[2]  = 1218;
assign divmul[3]  = 1117;
assign divmul[4]  = 1024;
assign divmul[5]  = 939;
assign divmul[6]  = 861;
assign divmul[7]  = 790;
assign divmul[8]  = 724;
assign divmul[9]  = 664;
assign divmul[10] = 609;
assign divmul[11] = 558;
assign divmul[12] = 512;
assign divmul[13] = 470;
assign divmul[14] = 431;
assign divmul[15] = 395;

wire [35:0] mul1 = w0 * Vhp;
wire [35:0] mul2 = w0 * Vbp;
wire [35:0] mul3 = q  * Vbp;
wire [35:0] mul4 = 18'd82355 * ({Fc_hi, Fc_lo[2:0]} + 1'b1);

// Filter
always @(posedge clk) begin
	reg [17:0] dVbp;
	reg [17:0] Vlp;
	reg [17:0] dVlp;
	reg [17:0] Vi;
	reg [17:0] Vnf;
	reg [17:0] Vf;
	reg  [3:0] state;
	reg signed [35:0] mulr;
	reg signed [17:0] mula;
	reg signed [17:0] mulb;

	if (rst) begin
		state <= 0;
		Vlp   <= 0;
		Vbp   <= 0;
		Vhp   <= 0;
	end
	else begin
		case (state)
			0:	if (input_valid) begin
					state <= state + 1'd1;
					if(!(^mulr[21:20])) sound <= mulr[20:3];
					Vi <= 0;
					Vnf <= 0;
				end
			1:	begin
					state <= state + 1'd1;
					w0 <= {mul4[35], mul4[28:12]};
					if (Res_Filt[0]) Vi  <= Vi  + {voice1,2'b00};
					else             Vnf <= Vnf + {voice1,2'b00};
				end
			2:	begin
					state <= state + 1'd1;
					if (Res_Filt[1]) Vi  <= Vi  + {voice2,2'b00};
					else             Vnf <= Vnf + {voice2,2'b00};
				end
			3:	begin
					state <= state + 1'd1;
					if (Res_Filt[2])       Vi  <= Vi  + {voice3,2'b00};
					else if (!Mode_Vol[7]) Vnf <= Vnf + {voice3,2'b00};
					dVbp <= {mul1[35], mul1[35:19]};            
				end
			4:	begin
					state <= state + 1'd1;
					if (Res_Filt[3]) Vi  <= Vi  + {ext_in,2'b00};
					else             Vnf <= Vnf + {ext_in,2'b00};
					dVlp <= {mul2[35], mul2[35:19]};
					Vbp <= Vbp - dVbp;
					q <= divmul[Res_Filt[7:4]];
				end
			5:	begin
					state <= state + 1'd1;
					Vlp <= Vlp - dVlp;
					Vf <= (Mode_Vol[5]) ? Vbp : 18'd0;
				end
			6: begin
					state <= state + 1'd1;
					Vhp <= {mul3[35], mul3[26:10]} - Vlp;
					if(Mode_Vol[4]) Vf <= Vf + Vlp;
				end
			7: begin
					state <= state + 1'd1;
					Vhp <= Vhp - Vi;
				end
			8:	begin
					state <= state + 1'd1;
					if(Mode_Vol[6]) Vf <= Vf + Vhp;
				end
			9:	begin
					state <= state + 1'd1;
					mula <= (extfilter_en) ? Vnf - Vf : Vnf + Vi;
					mulb <= Mode_Vol[3:0];
				end
			10:begin
					state <= 0;
					mulr <= mula * mulb;
				end
		endcase
	end
end

endmodule
