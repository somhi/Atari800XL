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
-- 
-- A simpler corverter to simulate analog joystick movement 
-- with the digital joystick
-- 
-- Victor Trucco - 2020
---------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY digital_to_analog IS
PORT 
( 
    clk     : IN STD_LOGIC;
    
    up_n_i  : in std_logic;
    down_n_i  : in std_logic;
    left_n_i  : in std_logic;
    right_n_i  : in std_logic;

    x_o : out signed (7 downto 0);
    y_o : out signed (7 downto 0)
);
END digital_to_analog;

ARCHITECTURE vhdl OF digital_to_analog IS
BEGIN

process (clk)
variable y : signed (7 downto 0) := to_signed(0,8);
variable x : signed (7 downto 0) := to_signed(0,8);
begin
    if rising_edge(clk) then
        if left_n_i = '0' then
            if x>to_signed(-127,8) then x := x - 1; end if;
        elsif right_n_i = '0' then
            if x<to_signed(127,8) then x := x + 1; end if;
        else --no direction, so we are going to center
            if x<0 then x := x + 1; end if;
            if x>0 then x := x - 1; end if;
        end if;

        x_o <= x;

        if up_n_i = '0' then
            if y>to_signed(-127,8) then y := y - 1; end if;
        elsif down_n_i = '0' then
            if y<to_signed(127,8) then y := y + 1; end if;
        else --no direction, so we are going to center
            if y<0 then y := y + 1; end if;
            if y>0 then y := y - 1; end if;
        end if;

        y_o <= y;
    end if;
end process;

end vhdl;

