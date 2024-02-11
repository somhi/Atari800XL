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
  
*/module infopacketstate (
clock      , // clock
reset      , // Active high, syn reset

start_of_frame,
audio_regen_needed,
packet_sent,

audio_regen,
audio_info,
video_info,
packet_needed
);
//-------------Input Ports-----------------------------
input   clock,reset,start_of_frame,audio_regen_needed,packet_sent;
 //-------------Output Ports----------------------------
output  audio_regen,audio_info,video_info,packet_needed;
//-------------Input ports Data Type-------------------
wire    clock,reset,start_of_frame,audio_regen_needed,packet_sent;
//-------------Output Ports Data Type------------------
reg     audio_regen,audio_info,video_info,packet_needed;
//-------------Internal Constants--------------------------
parameter SIZE = 5           ;
parameter CHOOSE  = 2'b00,AUDIO_REGEN = 2'b01,AUDIO_INFO = 2'b10,VIDEO_INFO = 2'b11;
//-------------Internal Variables---------------------------
reg   [SIZE-1:0]          state        ;// Seq part of the FSM
wire  [SIZE-1:0]          next_state   ;// combo part of FSM
//----------Code startes Here------------------------
assign next_state = fsm_function(state,start_of_frame,audio_regen_needed,packet_sent);
//----------Function for Combo Logic-----------------
function [SIZE-1:0] fsm_function;
  input  [SIZE-1:0]  state ;	
  input    start_of_frame ;
  input    audio_regen_needed ;
  input    packet_sent ;
  
  fsm_function[4] = start_of_frame | state[4];     //video_info
  fsm_function[3] = start_of_frame | state[3];     //audio_info
  fsm_function[2] = audio_regen_needed | state[2]; //audio_regen
  fsm_function[1:0] = state[1:0];

  case(state[1:0])
   CHOOSE : if (state[2] == 1'b1) begin
                fsm_function[1:0] = AUDIO_REGEN;;
              end else if (state[3] == 1'b1) begin
                fsm_function[1:0] = AUDIO_INFO;
               end else if (state[4] == 1'b1) begin
                fsm_function[1:0] = VIDEO_INFO;
              end
   AUDIO_REGEN : if (packet_sent == 1'b1) begin
                fsm_function[1:0] = CHOOSE;
		fsm_function[2] = 0;
              end
   AUDIO_INFO : if (packet_sent == 1'b1) begin
                fsm_function[1:0] = CHOOSE;
		fsm_function[3] = 0;
              end
   VIDEO_INFO : if (packet_sent == 1'b1) begin
                fsm_function[1:0] = CHOOSE;
		fsm_function[4] = 0;
              end
   default : fsm_function = CHOOSE;
  endcase
endfunction
//----------Seq Logic-----------------------------
always @ (posedge clock)
begin : FSM_SEQ
  if (reset == 1'b1) begin
    state <=  #1  CHOOSE;
  end else begin
    state <=  #1  next_state;
  end
end
//----------Output Logic-----------------------------
always @ (posedge clock)
begin : OUTPUT_LOGIC
if (reset == 1'b1) begin
  audio_regen <=  #1  1'b0;
  video_info <=   #1  1'b0;
  audio_info <=   #1  1'b0;
  packet_needed <=   #1  1'b0;
end
else begin
  case(state[1:0])
    CHOOSE : begin
                  audio_regen <=  #1  1'b0;
                  video_info <=  #1  1'b0;
                  audio_info <=  #1  1'b0;
                  packet_needed <=  #1  1'b0;
               end
   AUDIO_REGEN : begin
                  audio_regen <=  #1  1'b1;
                  video_info <=  #1  1'b0;
                  audio_info <=  #1  1'b0;
                  packet_needed <=  #1  1'b1;
                end
   AUDIO_INFO : begin
                  audio_regen <=  #1  1'b0;
                  video_info <=  #1  1'b0;
                  audio_info <=  #1  1'b1;
                  packet_needed <=  #1  1'b1;
                end
   VIDEO_INFO : begin
                  audio_regen <=  #1  1'b0;
                  video_info <=  #1  1'b1;
                  audio_info <=  #1  1'b0;
                  packet_needed <=  #1  1'b1;
                end
   default : begin
                  audio_regen <=  #1  1'b0;
                  video_info <=  #1  1'b0;
                  audio_info <=  #1  1'b0;
                  packet_needed <=  #1  1'b0;
                  end
  endcase
end
end // End Of Block OUTPUT_LOGIC

endmodule // End of Module arbiter
