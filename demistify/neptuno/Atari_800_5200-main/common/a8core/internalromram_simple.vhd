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

ENTITY internalromram_simple IS
  PORT(
    clock   : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous reset

    ROM_ADDR : in STD_LOGIC_VECTOR(21 downto 0);
    ROM_REQUEST_COMPLETE : out STD_LOGIC;
    ROM_REQUEST : in std_logic;
    OS_DATA : out std_logic_vector(7 downto 0);
    BASIC_DATA : out std_logic_vector(7 downto 0);
    
    RAM_ADDR : in STD_LOGIC_VECTOR(18 downto 0);
    RAM_WR_ENABLE : in std_logic;
    RAM_DATA_IN : in STD_LOGIC_VECTOR(7 downto 0);
    RAM_REQUEST_COMPLETE : out STD_LOGIC;
    RAM_REQUEST : in std_logic;
    RAM_DATA : out std_logic_vector(7 downto 0)
    );
END internalromram_simple;

architecture vhdl of internalromram_simple is
    signal rom_request_reg : std_logic;
    signal ram_request_reg : std_logic;
    
    signal ramwe_temp : std_logic;
begin
    process(clock,reset_n)
    begin
        if (reset_n ='0') then
            rom_request_reg <= '0';
            ram_request_reg <= '0';
        elsif (clock'event and clock='1') then
            rom_request_reg <= rom_request;
            ram_request_reg <= ram_request;
        end if;
    end process;

    rom16a : entity work.os16
    PORT MAP(clock => clock,
            we => '0',
            data => (others=>'0'),
             address => rom_addr(13 downto 0),
             q => OS_DATA
             );

    basic1 : entity work.basic
    PORT MAP(clock => clock,
         we => '0',
            data => (others=>'0'),
             address => rom_addr(12 downto 0),
             q => BASIC_data
             );          

    rom_request_complete <= rom_request_reg;
    
    ramwe_temp <= RAM_WR_ENABLE and ram_request;
    ramint1 : entity work.generic_ram_infer
        generic map
        (
                ADDRESS_WIDTH => 19,
                SPACE => 65536,
                DATA_WIDTH =>8
        )
    PORT MAP(clock => clock,
            reset_n => reset_n,
             address => ram_addr,
             data => ram_data_in(7 downto 0),
             we => ramwe_temp,
             q => ram_data
             ); 
    ram_request_complete <= ram_request_reg;
        
end vhdl;
