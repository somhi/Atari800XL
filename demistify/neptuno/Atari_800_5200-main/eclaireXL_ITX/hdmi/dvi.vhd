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
		
-------------------------------------------------------------------[09.05.2016]
-- DVI
-------------------------------------------------------------------------------
-- Engineer: MVV

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

entity dvi is
port (
	I_CLK_PIXEL	: in std_logic;		-- pixelclock
	I_HSYNC		: in std_logic;
	I_VSYNC		: in std_logic;
	I_BLANK		: in std_logic;
	I_RED		: in std_logic_vector(7 downto 0);
	I_GREEN		: in std_logic_vector(7 downto 0);
	I_BLUE		: in std_logic_vector(7 downto 0);

 	O_R	: out std_logic_vector(9 downto 0);
 	O_G	: out std_logic_vector(9 downto 0);
 	O_B	: out std_logic_vector(9 downto 0));
end entity dvi;

architecture rtl of dvi is

	signal r	: std_logic_vector(9 downto 0);
	signal g	: std_logic_vector(9 downto 0);
	signal b	: std_logic_vector(9 downto 0);
   
begin
	encode_r : entity work.encoder
	port map (
		CLK	=> I_CLK_PIXEL,
		DATA	=> I_RED,
		C	=> "00",
		VDE	=> not(I_BLANK),
		ENCODED	=> r);

	encode_g : entity work.encoder
	port map (
		CLK   => I_CLK_PIXEL,
		DATA  => I_GREEN,
		C     => "00",
		VDE   => not(I_BLANK),
		ENCODED  => g);

	encode_b : entity work.encoder
	port map (
		CLK   => I_CLK_PIXEL,
		DATA  => I_BLUE,
		C     => (I_VSYNC & I_HSYNC),
		VDE   => not(I_BLANK),
		ENCODED  => b);

	o_r <= r;
	o_g <= g;
	o_b <= b;

end architecture rtl;


