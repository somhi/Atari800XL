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
ENTITY sync_switches IS
PORT ( 
	CLK : IN STD_LOGIC;

	SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	KEY : IN STD_LOGIC_VECTOR(3 downto 0);
	
	SYNC_KEYS : out std_logic_vector(3 downto 0);
	SYNC_SWITCHES : out std_logic_vector(9 downto 0)
); 
END sync_switches;

ARCHITECTURE Behavior OF sync_switches IS
	component synchronizer IS
	PORT 
	( 
		CLK : IN STD_LOGIC;
		RAW : IN STD_LOGIC;
		SYNC : OUT STD_LOGIC
	);
	END component;
		
	signal sw_reg : std_logic_vector(9 downto 0);
	signal key_reg : std_logic_vector(3 downto 0);
	
BEGIN
	sw9_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(9), sync=>sw_reg(9));	
	sw8_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(8), sync=>sw_reg(8));	
	sw7_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(7), sync=>sw_reg(7));	
	sw6_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(6), sync=>sw_reg(6));	
	sw5_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(5), sync=>sw_reg(5));			
	sw4_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(4), sync=>sw_reg(4));	
	sw3_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(3), sync=>sw_reg(3));	
	sw2_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(2), sync=>sw_reg(2));	
	sw1_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(1), sync=>sw_reg(1));	
	sw0_synchronizer : synchronizer
		port map (clk=>clk, raw=>sw(0), sync=>sw_reg(0));			

	key3_synchronizer : synchronizer
		port map (clk=>clk, raw=>not(key(3)), sync=>key_reg(3));	
	key2_synchronizer : synchronizer
		port map (clk=>clk, raw=>not(key(2)), sync=>key_reg(2));	
	key1_synchronizer : synchronizer
		port map (clk=>clk, raw=>not(key(1)), sync=>key_reg(1));	
	key0_synchronizer : synchronizer
		port map (clk=>clk, raw=>not(key(0)), sync=>key_reg(0));			
	
	-- outputs
	SYNC_KEYS <= key_reg(3)&key_reg(2)&key_reg(1)&key_reg(0);
	SYNC_SWITCHES <= sw_reg(9)&sw_reg(8)&sw_reg(7)&sw_reg(6)&sw_reg(5)&sw_reg(4)&sw_reg(3)&sw_reg(2)&sw_reg(1)&sw_reg(0);
END Behavior;
