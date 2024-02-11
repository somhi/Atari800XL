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
use ieee.numeric_std.all;

ENTITY syncreset_enable_divider IS
generic(COUNT : natural := 1; RESETCOUNT : natural := 0);
PORT 
( 
	CLK : IN STD_LOGIC;
	SYNCRESET : in std_logic;
	RESET_N : IN STD_LOGIC;
	ENABLE_IN : IN STD_LOGIC;
	
	ENABLE_OUT : OUT STD_LOGIC
);
END syncreset_enable_divider;

ARCHITECTURE vhdl OF syncreset_enable_divider IS
	function log2c(n : integer) return integer is
		variable m,p : integer;
	begin
		m := 0;
		p := 1;
		while p<n loop
			m:=m+1;
			p:=p*2;
		end loop;
		return m;
	end log2c;

	constant WIDTH : natural := log2c(COUNT);
	signal count_reg : std_logic_vector(WIDTH-1 downto 0); -- width should depend on count
	signal count_next : std_logic_vector(WIDTH-1 downto 0);
	
	signal enabled_out_next : std_logic;
	signal enabled_out_reg : std_logic;
BEGIN
	-- register
	process(clk,reset_n)
	begin
		if (reset_n = '0') then
			count_reg <= (others=>'0');
			enabled_out_reg <= '0';
		elsif (clk'event and clk='1') then
			count_reg <= count_next;
			enabled_out_reg <= enabled_out_next;
		end if;
	end process;

	-- Maintain a count in order to calculate a clock circa 1.79 (in this case 25/14) -> 64KHz -> /28
	process(count_reg,enable_in,enabled_out_reg,syncreset)
	begin
		count_next <= count_reg;
		enabled_out_next <= enabled_out_reg;
		
		if (enable_in = '1') then
			count_next <= std_logic_vector(unsigned(count_reg) + 1);
			enabled_out_next <= '0';
		
			if (unsigned(count_reg) = to_unsigned(COUNT-1,WIDTH)) then
				count_next <= std_logic_vector(to_unsigned(0,WIDTH));
				enabled_out_next <= '1';
			end if;
		end if;
		
		if (syncreset='1') then
			count_next <= std_logic_vector(to_unsigned(resetcount,width));
		end if;
	end process;
	
	-- output
	enable_out <= enabled_out_reg and enable_in;
		
END vhdl;
