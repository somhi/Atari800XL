--
-- Multicore 2 / Multicore 2+
--
-- Copyright (c) 2017-2020 - Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
		
---------------------------------------------------------------------------
-- (c) 2013 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY covox IS
PORT 
( 
	CLK : IN STD_LOGIC;
	ADDR : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	WR_EN : IN STD_LOGIC;
	
	covox_channel0 : out std_logic_vector(7 downto 0);
	covox_channel1 : out std_logic_vector(7 downto 0);
	covox_channel2 : out std_logic_vector(7 downto 0);
	covox_channel3 : out std_logic_vector(7 downto 0)
);
END covox;

ARCHITECTURE vhdl OF covox IS
	component complete_address_decoder IS
	generic (width : natural := 1);
	PORT 
	( 
		addr_in : in std_logic_vector(width-1 downto 0);	
		
		addr_decoded : out std_logic_vector((2**width)-1 downto 0)
	);
	END component;
	
	signal channel0_next : std_logic_vector(7 downto 0);
	signal channel1_next : std_logic_vector(7 downto 0);
	signal channel2_next : std_logic_vector(7 downto 0);
	signal channel3_next : std_logic_vector(7 downto 0);
	signal channel0_reg : std_logic_vector(7 downto 0);
	signal channel1_reg : std_logic_vector(7 downto 0);
	signal channel2_reg : std_logic_vector(7 downto 0);
	signal channel3_reg : std_logic_vector(7 downto 0);
	
	signal addr_decoded : std_logic_vector(3 downto 0);
BEGIN
	complete_address_decoder1 : complete_address_decoder
		generic map (width => 2)
		port map (addr_in => addr, addr_decoded => addr_decoded);

	-- next state logic
	process(channel0_reg,channel1_reg,channel2_reg,channel3_reg,addr_decoded,data_in,WR_EN)
	begin
		channel0_next <= channel0_reg;
		channel1_next <= channel1_reg;
		channel2_next <= channel2_reg;
		channel3_next <= channel3_reg;
		
		if (WR_EN = '1') then		
			if (addr_decoded(0) = '1') then				
				channel0_next <= data_in;
			end if;
			if (addr_decoded(1) = '1') then				
				channel1_next <= data_in;
			end if;
			if (addr_decoded(2) = '1') then				
				channel2_next <= data_in;
			end if;
			if (addr_decoded(3) = '1') then				
				channel3_next <= data_in;
			end if;		
		end if;
	end process;
	
	-- register
	process(clk)
	begin
		if (clk'event and clk='1') then
			channel0_reg <= channel0_next;
			channel1_reg <= channel1_next;
			channel2_reg <= channel2_next;
			channel3_reg <= channel3_next;
		end if;
	end process;
	
	-- output
	covox_channel0 <= channel0_reg;
	covox_channel1 <= channel1_reg;
	covox_channel2 <= channel2_reg;
	covox_channel3 <= channel3_reg;
END vhdl;