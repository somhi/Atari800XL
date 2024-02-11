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
		
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY internalromram IS
	GENERIC
	(
		internal_rom : integer := 1;  
		internal_ram : integer := 16384 
	);
  PORT(
    clock   : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous reset

	ROM_ADDR : in STD_LOGIC_VECTOR(21 downto 0);
	ROM_WR_ENABLE : in std_logic;
	ROM_DATA_IN : in STD_LOGIC_VECTOR(7 downto 0);
	ROM_REQUEST_COMPLETE : out STD_LOGIC;
	ROM_REQUEST : in std_logic;
	ROM_DATA : out std_logic_vector(7 downto 0);
	
	RAM_ADDR : in STD_LOGIC_VECTOR(18 downto 0);
	RAM_WR_ENABLE : in std_logic;
	RAM_DATA_IN : in STD_LOGIC_VECTOR(7 downto 0);
	RAM_REQUEST_COMPLETE : out STD_LOGIC;
	RAM_REQUEST : in std_logic;
	RAM_DATA : out std_logic_vector(7 downto 0)
	);
END internalromram;

architecture vhdl of internalromram is
	signal rom_request_reg : std_logic;
	signal rom_request_next : std_logic;
	signal ram_request_reg : std_logic;
	signal ram_request_next : std_logic;
	
	signal ROM16_DATA : std_logic_vector(7 downto 0);
	signal ROM8_DATA : std_logic_vector(7 downto 0);
	signal ROM2_DATA : std_logic_vector(7 downto 0);
	signal BASIC_DATA : std_logic_vector(7 downto 0);	
	
	signal ramwe_temp : std_logic;

	signal romwe_temp : std_logic;
	signal os_romwe_temp : std_logic;
	signal basic_romwe_temp : std_logic;
begin
	process(clock,reset_n)
	begin
		if (reset_n ='0') then
			rom_request_reg <= '0';
			ram_request_reg <= '0';
		elsif (clock'event and clock='1') then
			rom_request_reg <= rom_request_next;
			ram_request_reg <= ram_request_next;
		end if;
	end process;

gen_internal_5200 : if internal_rom=4 generate
	-- f000 to ffff (4k)
	rom4 : entity work.os_5200
	PORT MAP(clock => clock,
			 address => rom_addr(10 downto 0),
			 q => ROM_data
			 );
	rom_request_next <= rom_request and not(ROM_WR_ENABLE);
	rom_request_complete <= rom_request_reg;
	
end generate;

gen_internal_os_b : if internal_rom=3 generate
	-- d800 to dfff (2k)
	rom2 : entity work.os2
	PORT MAP(clock => clock,
			 address => rom_addr(10 downto 0),
			 q => ROM2_data
			 );

	-- e000 to ffff (8k)
	rom10 : entity work.os8
	PORT MAP(clock => clock,
			 address => rom_addr(12 downto 0),
			 q => ROM8_data
			 );

	process(rom_addr)
	begin
		case rom_addr(13 downto 11) is
		when "011" =>
			ROM_DATA <= ROM2_data;
		when "100"|"101"|"110"|"111" =>
			ROM_DATA <= ROM8_data;
		when others=>
			ROM_DATA <= x"ff";
		end case;
	end process;

	rom_request_complete <= rom_request_reg;
	
end generate;

gen_internal_os_loop : if internal_rom=2 generate
	rom16a : entity work.os16_loop
	PORT MAP(clock => clock,
			 address => rom_addr(13 downto 0),
			 q => ROM16_data
			 );

	ROM_DATA <= ROM16_DATA;

	rom_request_complete <= rom_request_reg;
	
end generate;

gen_internal_os : if internal_rom=1 generate
	rom16a : entity work.os16
	PORT MAP(clock => clock,
			 address => rom_addr(13 downto 0),
			 we => os_romwe_temp,
			 data => rom_data_in(7 downto 0),
			 q => ROM16_data
			 );

	basic1 : entity work.basic
	PORT MAP(clock => clock,
			 address => rom_addr(12 downto 0),
			 we => basic_romwe_temp,
			 data => rom_data_in(7 downto 0),
			 q => BASIC_data
			 );			 

	romwe_temp <= ROM_WR_ENABLE and rom_request;
	process(rom16_data,basic_data, rom_addr(15 downto 0),romwe_temp)
	begin
		os_romwe_temp <= romwe_temp;
		basic_romwe_temp <= '0';

		ROM_DATA <= ROM16_DATA;
		if (rom_addr(15)='1') then
			ROM_DATA <= BASIC_DATA;
			os_romwe_temp <= '0';
			basic_romwe_temp <= romwe_temp;
		end if;
	end process;

	rom_request_next <= rom_request and not(ROM_WR_ENABLE);
	rom_request_complete <= romwe_temp or rom_request_reg;
	
end generate;

--gen_internal_os_nobasic : if internal_rom=5 generate
--	rom16a : entity work.os16
--	PORT MAP(clock => clock,
--			 address => rom_addr(13 downto 0),
--			 q => ROM16_data
--			 );			 
--
--	process(rom16_data,basic_data, rom_addr(15 downto 0))
--	begin
--		ROM_DATA <= ROM16_DATA;
--		if (rom_addr(15)='1') then
--			ROM_DATA <= x"FF";
--		end if;
--	end process;
--
--	rom_request_complete <= rom_request_reg;
--	
--end generate;


gen_no_internal_os : if internal_rom=0 generate
	ROM16_data <= (others=>'0');

	rom_request_complete <= '0';
end generate;
	
gen_internal_ram: if internal_ram>0 generate
	ramwe_temp <= RAM_WR_ENABLE and ram_request;
	ramint1 : entity work.generic_ram_infer
        generic map
        (
                ADDRESS_WIDTH => 19,
                SPACE => internal_ram,
                DATA_WIDTH =>8
        )
	PORT MAP(clock => clock,
			 address => ram_addr,
			 data => ram_data_in(7 downto 0),
			 we => ramwe_temp,
			 q => ram_data
			 );	
	ram_request_next <= ram_request and not(RAM_WR_ENABLE);
	ram_request_complete <= ramwe_temp or ram_request_reg;
end generate;
gen_no_internal_ram : if internal_ram=0 generate
	ram_request_complete <='1';
	ram_data <= (others=>'1');
end generate;
        
end vhdl;
