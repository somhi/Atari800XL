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
		
-- (c) 2017 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

LIBRARY work;

ENTITY gpio_debug IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		RESET_N :  IN  STD_LOGIC;

		PBI_DEBUG : IN STD_LOGIC_VECTOR(31 downto 0);
		PBI_DEBUG_READY : IN STD_LOGIC;

		DATA_OUT :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		CLK_OUT :  OUT  STD_LOGIC
	);
END gpio_debug;

ARCHITECTURE vhdl OF gpio_debug IS 
	signal cycle_reg : std_logic_vector(4 downto 0);
	signal cycle_next : std_logic_vector(4 downto 0);

	signal pbi_debug_reg : std_logic_vector(31 downto 0);
	signal pbi_debug_next : std_logic_vector(31 downto 0);

	signal data_out_reg : std_logic_vector(7 downto 0);
	signal data_out_next : std_logic_vector(7 downto 0);

	signal clk_out_reg : std_logic;
	signal clk_out_next : std_logic;
	
BEGIN

	process(clk,reset_n)
	begin
		if (reset_n='0') then
			pbi_debug_reg <= (others=>'0');
			cycle_reg <= (others=>'0');
			data_out_reg <= (others=>'0');
			clk_out_reg <= '0';
		elsif (clk'event and clk='1') then
			pbi_debug_reg <= pbi_debug_next;
			cycle_reg <= cycle_next;
			data_out_reg <= data_out_next;
			clk_out_reg <= clk_out_next;
		end if;
	end process;

	process(cycle_reg,pbi_debug_ready,pbi_debug,pbi_debug_reg,data_out_reg,clk_out_reg)
	begin	
		pbi_debug_next <= pbi_debug_reg;
		cycle_next <= std_logic_vector(unsigned(cycle_reg)+1);
		data_out_next <= data_out_reg;
		clk_out_next <= clk_out_reg;

		if (pbi_debug_ready='1') then
			cycle_next <= (others=>'0');
			pbi_debug_next <= pbi_debug;
		end if;

		case cycle_reg is
		when "0"&x"0" => 
			data_out_next <= pbi_debug_reg(7 downto 0);
		when "0"&x"4" => 
			clk_out_next <= not(clk_out_reg);
		when "0"&x"8" => 
			data_out_next <= pbi_debug_reg(15 downto 8);
		when "0"&x"c" => 
			clk_out_next <= not(clk_out_reg);
		when "1"&x"0" => 
			data_out_next <= pbi_debug_reg(23 downto 16);
		when "1"&x"4" => 
			clk_out_next <= not(clk_out_reg);
		when "1"&x"8" => 
			data_out_next <= pbi_debug_reg(31 downto 24);
		when "1"&x"c" => 
			clk_out_next <= not(clk_out_reg);
		when others =>
		end case;

	end process;

	data_out <= data_out_reg;
	clk_out <= clk_out_reg;

END vhdl;

