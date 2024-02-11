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

ENTITY hexdecoder IS
PORT 
( 
	CLK : IN STD_LOGIC;
	NUMBER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	DIGIT : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
END hexdecoder;

ARCHITECTURE vhdl OF hexdecoder IS
	signal numinv : STD_LOGIC_VECTOR(3 downto 0);
	signal digit_next : std_logic_vector(6 downto 0);
	signal digit_reg : STD_LOGIC_VECTOR(6 DOWNTO 0);
BEGIN
	--numinv <= not(NUMBER);
	numinv <= NUMBER;
	process(numinv)
	begin
		case numinv is
			when "0000" =>
				digit_next <= "1111111";
			when "0001" =>
				digit_next <= "1111001";
			when "0010" =>
				digit_next <= "0100100";
			when "0011" =>
				digit_next <= "0110000";
			when "0100" =>
				digit_next <= "0011001";
			when "0101" =>
				digit_next <= "0010010";
			when "0110" =>
				digit_next <= "0000010";
			when "0111" =>
				digit_next <= "1111000";
			when "1000" =>
				digit_next <= "0000000";
			when "1001" =>
				digit_next <= "0011000";
			when "1010" =>
				digit_next <= "0001000";
			when "1011" =>
				digit_next <= "0000011";
			when "1100" =>
				digit_next <= "1000110";
			when "1101" =>
				digit_next <= "0100001";
			when "1110" =>
				digit_next <= "0000110";
			when "1111" =>
				digit_next <= "0001110";
			when others =>
				digit_next <= "1111111";
		end case;
	end process;
	
	process(clk)
	begin
		if (clk'event and clk='1') then
			digit_reg <= digit_next;
		end if;
	end process;
	
	digit<=digit_reg;
END vhdl;