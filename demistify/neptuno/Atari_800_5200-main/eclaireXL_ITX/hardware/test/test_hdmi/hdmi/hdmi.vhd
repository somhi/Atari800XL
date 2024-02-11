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
-- HDMI
-------------------------------------------------------------------------------
-- Engineer: MVV

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

entity hdmi is
port (
	I_CLK_PIXEL	: in std_logic;		-- pixelclock
	I_CLK_TMDS	: in std_logic;		-- pixelclock*5
	I_HSYNC		: in std_logic;
	I_VSYNC		: in std_logic;
	I_BLANK		: in std_logic;
	I_RED		: in std_logic_vector(7 downto 0);
	I_GREEN		: in std_logic_vector(7 downto 0);
	I_BLUE		: in std_logic_vector(7 downto 0);
	O_TMDS		: out std_logic_vector(7 downto 0));
end entity hdmi;

architecture rtl of hdmi is
   
	signal r	: std_logic_vector(9 downto 0);
	signal g	: std_logic_vector(9 downto 0);
	signal b	: std_logic_vector(9 downto 0);
	signal mod5	: std_logic_vector(2 downto 0) := "000";	-- modulus 5 counter
	signal shift_r	: std_logic_vector(9 downto 0) := "0000000000";
	signal shift_g	: std_logic_vector(9 downto 0) := "0000000000";
	signal shift_b	: std_logic_vector(9 downto 0) := "0000000000";
	signal shift_clk : std_logic_vector(9 downto 0) := "0000000000";

begin

	encode_r : entity work.encoder
	port map (
		I_CLK	=> I_CLK_PIXEL,
		I_VD	=> I_RED,
		I_CD	=> "00",
		I_VDE	=> not(I_BLANK),
		O_TMDS	=> r);

	encode_g : entity work.encoder
	port map (
		I_CLK   => I_CLK_PIXEL,
		I_VD    => I_GREEN,
		I_CD    => "00",
		I_VDE   => not(I_BLANK),
		O_TMDS  => g);

	encode_b : entity work.encoder
	port map (
		I_CLK   => I_CLK_PIXEL,
		I_VD    => I_BLUE,
		I_CD    => (I_VSYNC & I_HSYNC),
		I_VDE   => not(I_BLANK),
		O_TMDS  => b);

	process (I_CLK_TMDS)
	begin
		if (I_CLK_TMDS'event and I_CLK_TMDS = '1') then
			if mod5(2) = '1' then
				mod5 <= "000";
				shift_r <= r;
				shift_g <= g;
				shift_b <= b;
				shift_clk <= "0000011111";
			else
				mod5 <= mod5 + "001";
				shift_r <= "00" & shift_r(9 downto 2);
				shift_g <= "00" & shift_g(9 downto 2);
				shift_b <= "00" & shift_b(9 downto 2);
				shift_clk <= "00" & shift_clk(9 downto 2);
			end if;
		end if;
	end process;
	
	ddio_inst : entity work.altddio_out1
	port map (
		datain_h => shift_r(0) & not(shift_r(0)) & shift_g(0) & not(shift_g(0)) & shift_b(0) & not(shift_b(0)) & shift_clk(0) & not(shift_clk(0)),
		datain_l => shift_r(1) & not(shift_r(1)) & shift_g(1) & not(shift_g(1)) & shift_b(1) & not(shift_b(1)) & shift_clk(1) & not(shift_clk(1)),
		outclock => I_CLK_TMDS,
		dataout  => O_TMDS);

end architecture rtl;


