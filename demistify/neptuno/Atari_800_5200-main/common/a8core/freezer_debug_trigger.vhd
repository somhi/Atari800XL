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
		
-- (c) 2019 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity freezer_debug_trigger is
PORT
(
	CLK :  IN  STD_LOGIC;
	RESET_N :  IN  STD_LOGIC;

	-- cpu state
	CPU_ADDR : IN STD_LOGIC_VECTOR(15 downto 0);
	CPU_WRITE_DATA : IN STD_LOGIC_VECTOR(7 downto 0);
	CPU_READ_DATA : IN STD_LOGIC_VECTOR(7 downto 0);
	CPU_FETCH : IN STD_LOGIC;
	CPU_FETCH_COMPLETE : IN STD_LOGIC;
	CPU_W_N : IN STD_LOGIC;

	-- freezer info
	FREEZER_ENABLE : IN STD_LOGIC;
	FREEZER_STATE : IN STD_LOGIC_VECTOR(2 downto 0);

	-- settings on what we should match
	DEBUG_ADDR : IN STD_LOGIC_VECTOR(15 downto 0); 
	DEBUG_DATA : IN STD_LOGIC_VECTOR(7 downto 0);
	DEBUG_READ : IN STD_LOGIC;
	DEBUG_WRITE : IN STD_LOGIC;
	DEBUG_DATA_MATCH : IN STD_LOGIC;

	FREEZER_TRIGGER : OUT STD_LOGIC;
	FREEZER_NMI_N : OUT STD_LOGIC
);
END freezer_debug_trigger;

ARCHITECTURE vhdl OF freezer_debug_trigger IS 
	signal freezer_activate_debug_state_reg: std_logic_vector(1 downto 0);
	signal freezer_activate_debug_state_next: std_logic_vector(1 downto 0);
	constant FREEZER_DEBUG_IDLE : std_logic_vector(1 downto 0) := "00";
	constant FREEZER_DEBUG_WAIT_FROZEN : std_logic_vector(1 downto 0) := "10";
	constant FREEZER_DEBUG_IDLE_NEXT : std_logic_vector(1 downto 0) := "11";
	signal freezer_debug_trigger : std_logic;

BEGIN

	-- regs
	process(clk,RESET_N)
	begin
		if (RESET_N='0') then
			freezer_activate_debug_state_reg <= FREEZER_DEBUG_IDLE;
		elsif (clk'event and clk='1') then
			freezer_activate_debug_state_reg <= freezer_activate_debug_state_next;
		end if;
	end process;

	-- match combinatorial logic
	process(debug_addr, debug_data, debug_read, debug_write, debug_data_match, 
		cpu_addr, cpu_write_data, cpu_read_data, cpu_fetch, cpu_fetch_complete, cpu_w_n, 
		freezer_enable)
		variable addr_match : std_logic;
		variable addr_valid : std_logic;
		variable read_data_valid : std_logic;
		variable write_data_valid : std_logic;
		variable read_data_match : std_logic;
		variable write_data_match : std_logic;

		variable read_mode : std_logic;
		variable write_mode : std_logic;
		variable data_must_match : std_logic;

		variable data_match : std_logic;
	begin
		addr_match := '0';
		if (cpu_addr = debug_addr) then
			addr_match := '1';
		end if;
		addr_valid := cpu_fetch;

		read_data_valid := cpu_fetch_complete and cpu_w_n;
		write_data_valid := cpu_fetch and not(cpu_w_n);

		read_data_match := '0';
		if (cpu_read_data = debug_data) then
			read_data_match := '1';
		end if;
		write_data_match := '0';
		if (cpu_write_data = debug_data) then
			write_data_match := '1';
		end if;

		-- options
		-- i) read, write, both or off
		-- ii) data match
		read_mode := debug_read;
		write_mode := debug_write;
		data_must_match := debug_data_match;

		data_match := (read_mode and read_data_match and read_data_valid) or (write_mode and write_data_match and write_data_valid) or not(data_must_match);
		freezer_debug_trigger <= addr_match and addr_valid and (read_mode or write_mode) and data_match and freezer_enable;
	end process;

	--constant FREEZER_DEBUG_IDLE : std_logic_vector(1 downto 0) := "00";
        --constant FREEZER_DEBUG_NMI : std_logic_vector(1 downto 0) := "01";
        --constant FREEZER_DEBUG_WAIT_FROZEN : std_logic_vector(1 downto 0) := "10";

	-- state machine to generate nmi until freezer active
	process(freezer_debug_trigger, freezer_state, freezer_activate_debug_state_reg)
	begin
		freezer_activate_debug_state_next <= freezer_activate_debug_state_reg;
		freezer_nmi_n <= '1';

		case freezer_activate_debug_state_reg is
			when FREEZER_DEBUG_IDLE =>
				if (freezer_debug_trigger='1') then
					freezer_activate_debug_state_next <= FREEZER_DEBUG_WAIT_FROZEN;
				end if;
			when FREEZER_DEBUG_WAIT_FROZEN =>
				freezer_nmi_n <= '0';
				if (freezer_state="100") then
					freezer_activate_debug_state_next <= FREEZER_DEBUG_IDLE_NEXT;
				end if;
			when FREEZER_DEBUG_IDLE_NEXT =>
				freezer_activate_debug_state_next <= FREEZER_DEBUG_IDLE;		
			when others =>
				freezer_activate_debug_state_next <= FREEZER_DEBUG_IDLE;		
		end case;
	end process;

	-- output
	freezer_trigger <= freezer_activate_debug_state_reg(1);

END vhdl;
