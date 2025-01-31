-- -----------------------------------------------------------------------
--
-- Turbo Chameleon
--
-- Multi purpose FPGA expansion for the Commodore 64 computer
--
-- -----------------------------------------------------------------------
-- Copyright 2005-2013 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com
--
-- This source file is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This source file is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.
--
-- -----------------------------------------------------------------------
--
-- Keyboard/joystick readout in cartridge mode
--
-- -----------------------------------------------------------------------
-- clk             - system clock
-- ena_1mhz        - Enable must be '1' one clk cycle each 1 Mhz.
--
-- joystick*       - Joystick outputs (fire1, right, left, down, up) low active
-- keys            - State of the keyboard (low is pressed)
-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- -----------------------------------------------------------------------

entity chameleon_c64_joykeyb is
	generic (
		enable_4player : boolean
	);
	port (
		clk : in std_logic;
		ena_1mhz : in std_logic;
		no_clock : in std_logic;
		reset : in std_logic;
		
		-- To C64 cartridge logic
		ba : in std_logic;
		req : out std_logic;
		ack : in std_logic;
		we : out std_logic;
		a : out unsigned(15 downto 0);
		d : in unsigned(7 downto 0);
		q : out unsigned(7 downto 0);
		
		joystick1 : out unsigned(4 downto 0);
		joystick2 : out unsigned(4 downto 0);
		joystick3 : out unsigned(4 downto 0);
		joystick4 : out unsigned(4 downto 0);
		--  0 = col0, row0
		--  1 = col1, row0
		--  8 = col0, row1
		-- 63 = col7, row7
		keys : out unsigned(63 downto 0)
	);
end entity;

-- -----------------------------------------------------------------------

architecture rtl of chameleon_c64_joykeyb is
	type state_t is (
		INIT_RESET, INIT_DISABLE_VIC, INIT_DISABLE_MOB,
		INIT_CIA1_A, INIT_CIA1_B, INIT_CIA2_B, --INIT_CIA2_A, ,
		SET_COL, READ_ROW, STORE_ROW, SET_NOCOL,
		READ_JOY1, STORE_JOY1, STORE_JOY2,
		READ_JOY34, STORE_JOY34);
	signal state : state_t := INIT_RESET;
	signal req_reg : std_logic := '0';
	signal joy34_flag : std_logic := '0';
	signal cnt : unsigned(3 downto 0) := (others => '0');
	signal col : integer range 0 to 7 := 0;
	signal keys_reg : unsigned(63 downto 0) := (others => '1');
	signal last_keys_reg : unsigned(63 downto 0) := (others => '1');
	signal approved_keys_reg : unsigned(63 downto 0) := (others => '1');
	signal joystick1_reg : unsigned(4 downto 0);
	signal joystick1_prev_reg : unsigned(4 downto 0);
	signal joystick2_prev_reg : unsigned(4 downto 0);
begin
	keys <= approved_keys_reg;
	req <= req_reg;

	process(clk)
	begin
		if rising_edge(clk) then
			if ena_1mhz = '1' then
				cnt <= cnt - 1;
				if cnt = 0 then
					cnt <= (others => '0');
				end if;
			end if;
			if (req_reg = ack) and (ba = '1') and (cnt = 0) then
				we <= '-';
				a <= (others => '-');
				q <= (others => '-');
				case state is
				when INIT_RESET =>
					if (reset = '0') and (ba = '1') then
						state <= INIT_DISABLE_VIC;
					end if;
				when INIT_DISABLE_VIC =>
					-- Turn off VIC-II raster DMA, so we don't have to deal with BA.
					we <= '1';
					a <= X"D011";
					q <= X"00";
					req_reg <= not req_reg;
					state <= INIT_DISABLE_MOB;
				when INIT_DISABLE_MOB =>
					-- Turn off VIC-II sprite DMA, so we don't have to deal with BA.
					we <= '1';
					a <= X"D015";
					q <= X"00";
					req_reg <= not req_reg;
					state <= INIT_CIA1_A;
				when INIT_CIA1_A =>
					-- Set keyboard columns port (joy2) to output
					we <= '1';
					a <= X"DC02";
					q <= X"FF";
					req_reg <= not req_reg;
					state <= INIT_CIA1_B;
				when INIT_CIA1_B =>
					-- Set keyboard rows port (joy1) to input
					we <= '1';
					a <= X"DC03";
					q <= X"00";
					req_reg <= not req_reg;
					state <= SET_COL;
					if enable_4player then
						state <= INIT_CIA2_B;
					end if;
				when INIT_CIA2_B =>
					-- Set CIA2 port B for 4 player adapter
					-- Bit7 output and others input.
					we <= '1';
					a <= X"DD03";
					q <= X"80";
					req_reg <= not req_reg;
					state <= SET_COL;
				when SET_COL =>
					we <= '1';
					a <= X"DC00";
					q <= to_unsigned(255 - 2**col, 8);
					req_reg <= not req_reg;
					cnt <= (others => '1');
					state <= READ_ROW;
				when READ_ROW =>
					we <= '0';
					a <= X"DC01";
					req_reg <= not req_reg;
					state <= STORE_ROW;
				when STORE_ROW =>
					keys_reg(0 + col) <= d(0);
					keys_reg(8 + col) <= d(1);
					keys_reg(16 + col) <= d(2);
					keys_reg(24 + col) <= d(3);
					keys_reg(32 + col) <= d(4);
					keys_reg(40 + col) <= d(5);
					keys_reg(48 + col) <= d(6);
					keys_reg(56 + col) <= d(7);
					if col /= 7 then
						col <= col + 1;
						state <= SET_COL;
					else
						col <= 0;
						state <= SET_NOCOL;
					end if;
				when SET_NOCOL =>
					we <= '1';
					a <= X"DC00";
					q <= X"FF";
					req_reg <= not req_reg;
					cnt <= (others => '1');
					state <= READ_JOY1;
				when READ_JOY1 =>
					-- read joystick port 1
					we <= '0';
					a <= X"DC01";
					req_reg <= not req_reg;
					state <= STORE_JOY1;
				when STORE_JOY1 =>
					-- read joystick port 2
					we <= '0';
					a <= X"DC00";
					req_reg <= not req_reg;
					joystick1 <= d(4 downto 0);
					joystick1_prev_reg <= joystick1_reg;
					joystick1_reg <= d(4 downto 0);
					state <= STORE_JOY2;
				when STORE_JOY2 =>
					joystick2 <= d(4 downto 0);
					state <= SET_COL;
					if enable_4player then
						state <= READ_JOY34;
					end if;
					last_keys_reg <= keys_reg;
					if ((joystick1_reg and d(4 downto 0) and joystick1_prev_reg and joystick2_prev_reg) = "11111" and last_keys_reg = keys_reg) then
						approved_keys_reg <= keys_reg;
					end if;
					joystick2_prev_reg <= d(4 downto 0);

				when READ_JOY34 =>
					-- read user port for joystick 3 or 4
					we <= '0';
					a <= X"DD01";
					req_reg <= not req_reg;
					state <= STORE_JOY34;
				when STORE_JOY34 =>
					joystick3(4) <= d(5);
					joystick4(4) <= d(4);
					if joy34_flag = '0' then
						joystick4(3 downto 0) <= d(3 downto 0);
					else
						joystick3(3 downto 0) <= d(3 downto 0);
					end if;
					-- select the other joystick (3 or 4) on the userport
					we <= '1';
					a <= X"DD01";
					q <= joy34_flag & "0000000";
					joy34_flag <= not joy34_flag;
					req_reg <= not req_reg;
					state <= SET_COL;
				end case;
			end if;
			if reset = '1' then
				state <= INIT_RESET;
			end if;
			if no_clock = '1' then
				joystick1 <= (others => '1');
				joystick2 <= (others => '1');
				joystick3 <= (others => '1');
				joystick4 <= (others => '1');
				keys_reg <= (others => '1');
			end if;
			if not enable_4player then
				joystick3 <= (others => '1');
				joystick4 <= (others => '1');
			end if;
		end if;
	end process;
end architecture;


