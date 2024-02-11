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
		
--------------------------------------------------------------------------- -- (c) 2013 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------

---------------------------------------------------------------------------
--
--  Multicore 2+ Top by Victor Trucco
--
---------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

LIBRARY work; 

ENTITY atari5200core_mc2p IS 
    GENERIC
    (
        CSYNC : IN integer := 0
    );
    PORT
    (
    -- Clocks
        clock_50_i         : in    std_logic;

        -- Buttons
        btn_n_i            : in    std_logic_vector(4 downto 1);

        -- SRAM
        sram_addr_o        : out   std_logic_vector(20 downto 0)   := (others => '0');
        sram_data_io       : inout std_logic_vector(7 downto 0)    := (others => 'Z');
        sram_we_n_o        : out   std_logic                               := '1';
        sram_oe_n_o        : out   std_logic                               := '1';

        -- SDRAM
        SDRAM_A            : out std_logic_vector(12 downto 0);
        SDRAM_DQ           : inout std_logic_vector(15 downto 0);

        SDRAM_BA           : out std_logic_vector(1 downto 0);
        SDRAM_DQMH         : out std_logic;
        SDRAM_DQML         : out std_logic;    

        SDRAM_nRAS         : out std_logic;
        SDRAM_nCAS         : out std_logic;
        SDRAM_CKE          : out std_logic;
        SDRAM_CLK          : out std_logic;
        SDRAM_nCS          : out std_logic;
        SDRAM_nWE          : out std_logic;
    
        -- PS2
        ps2_clk_io         : inout std_logic                        := 'Z';
        ps2_data_io        : inout std_logic                        := 'Z';
        ps2_mouse_clk_io   : inout std_logic                        := 'Z';
        ps2_mouse_data_io  : inout std_logic                        := 'Z';

        -- SD Card
        sd_cs_n_o          : out   std_logic                        := 'Z';
        sd_sclk_o          : out   std_logic                        := 'Z';
        sd_mosi_o          : out   std_logic                        := 'Z';
        sd_miso_i          : in    std_logic;

        -- Joysticks
        joy_clock_o        : out   std_logic;
        joy_load_o         : out   std_logic;
        joy_data_i         : in    std_logic;
        joy_p7_o           : out   std_logic                        := '1';

        -- Audio
        AUDIO_L             : out   std_logic                       := '0';
        AUDIO_R             : out   std_logic                       := '0';
        ear_i               : in    std_logic;
        mic_o               : out   std_logic                       := '0';

        -- VGA
        VGA_R               : out   std_logic_vector(4 downto 0)    := (others => '0');
        VGA_G               : out   std_logic_vector(4 downto 0)    := (others => '0');
        VGA_B               : out   std_logic_vector(4 downto 0)    := (others => '0');
        VGA_HS              : out   std_logic                       := '1';
        VGA_VS              : out   std_logic                       := '1';

        LED                 : out   std_logic                       := '1';-- 0 is led on

        --STM32
        stm_rx_o            : out std_logic     := 'Z'; -- stm RX pin, so, is OUT on the slave
        stm_tx_i            : in  std_logic     := 'Z'; -- stm TX pin, so, is IN on the slave
        stm_rst_o           : out std_logic     := 'Z'; -- '0' to hold the microcontroller reset line, to free the SD card
        
        SPI_SCK             : in  std_logic;
        SPI_DO              : out std_logic   := 'Z';
        SPI_DI              : in  std_logic;
        SPI_SS2             : in  std_logic;
        SPI_nWAIT           : out std_logic   := '1';

        GPIO                : inout std_logic_vector(31 downto 0)   := (others => 'Z')
    );
END atari5200core_mc2p;

ARCHITECTURE vhdl OF atari5200core_mc2p IS 

  component joystick_serial is
    port
    (
        clk_i           : in  std_logic;
        joy_data_i      : in  std_logic;
        joy_clk_o       : out  std_logic;
        joy_load_o      : out  std_logic;

        joy1_up_o       : out std_logic;
        joy1_down_o     : out std_logic;
        joy1_left_o     : out std_logic;
        joy1_right_o    : out std_logic;
        joy1_fire1_o    : out std_logic;
        joy1_fire2_o    : out std_logic;
        joy2_up_o       : out std_logic;
        joy2_down_o     : out std_logic;
        joy2_left_o     : out std_logic;
        joy2_right_o    : out std_logic;
        joy2_fire1_o    : out std_logic;
        joy2_fire2_o    : out std_logic
    );
    end component;

component hq_dac
port (
  reset :in std_logic;
  clk :in std_logic;
  clk_ena : in std_logic;
  pcm_in : in std_logic_vector(19 downto 0);
  dac_out : out std_logic
);
end component;

COMPONENT rgb2ypbpr
PORT (
        red     :        IN std_logic_vector(5 DOWNTO 0);
        green   :        IN std_logic_vector(5 DOWNTO 0);
        blue    :        IN std_logic_vector(5 DOWNTO 0);
        y       :        OUT std_logic_vector(5 DOWNTO 0);
        pb      :        OUT std_logic_vector(5 DOWNTO 0);
        pr      :        OUT std_logic_vector(5 DOWNTO 0)
        );
END COMPONENT;

component osd
generic ( OSD_COLOR : integer := 1 );  -- blue
port (
        clk_sys     : in std_logic;
        R_in        : in std_logic_vector(5 downto 0);
        G_in        : in std_logic_vector(5 downto 0);
        B_in        : in std_logic_vector(5 downto 0);
        HSync       : in std_logic;
        VSync       : in std_logic;

        R_out       : out std_logic_vector(5 downto 0);
        G_out       : out std_logic_vector(5 downto 0);
        B_out       : out std_logic_vector(5 downto 0);

        SPI_SCK     : in std_logic;
        SPI_SS3     : in std_logic;
        SPI_DI      : in std_logic
);
end component osd;

component user_io
    generic (
        STRLEN : integer := 0;
        PS2DIV : integer := 1500 );
    port (
        clk_sys : in std_logic;
        clk_sd  : in std_logic;
        SPI_CLK, SPI_SS_IO, SPI_MOSI :in std_logic;
        SPI_MISO : out std_logic;
        conf_str : in std_logic_vector(8*STRLEN-1 downto 0);
        joystick_0 : out std_logic_vector(31 downto 0);
        joystick_1 : out std_logic_vector(31 downto 0);
        joystick_analog_0 : out std_logic_vector(15 downto 0);
        joystick_analog_1 : out std_logic_vector(15 downto 0);
        status: out std_logic_vector(31 downto 0);
        switches : out std_logic_vector(1 downto 0);
        buttons : out std_logic_vector(1 downto 0);
        scandoubler_disable: out std_logic;
        ypbpr: out std_logic;
        ps2_kbd_clk : out std_logic;
        ps2_kbd_data : out std_logic;
        ps2_mouse_clk : out std_logic;
        ps2_mouse_data : out std_logic;
        serial_data : in std_logic_vector(7 downto 0);
        serial_strobe : in std_logic
      );
end component user_io;

component data_io
    generic 
    (
        STRLEN : integer := 0
    );
    port 
    (
        clk_sys : in std_logic;

        SPI_SCK : in std_logic;
        SPI_SS2 : in std_logic;
        SPI_DI  : in std_logic;
        SPI_DO  : out std_logic;

        data_in  : in  std_logic_vector(7 downto 0);
        conf_str : in  std_logic_vector(8*STRLEN-1 downto 0);
        status   : out std_logic_vector(31 downto 0);

        ioctl_download : out std_logic;
        ioctl_index    : out std_logic_vector(7 downto 0);
        ioctl_wr       : out std_logic;
        ioctl_addr     : out std_logic_vector(24 downto 0);
        ioctl_dout     : out std_logic_vector(15 downto 0);
        ioctl_last     : out std_logic_vector(24 downto 0)
    );
end component data_io;

signal AUDIO_L_PCM : std_logic_vector(15 downto 0);
signal AUDIO_R_PCM : std_logic_vector(15 downto 0);

signal VGA_VS_RAW : std_logic;
signal VGA_HS_RAW : std_logic;
signal VGA_CS_RAW : std_logic;

signal RESET_n : std_logic;
signal PLL_LOCKED : std_logic;
signal CLK : std_logic;
signal CLK_SDRAM : std_logic;

SIGNAL PS2_CLK : std_logic;
SIGNAL PS2_DAT : std_logic;
SIGNAL FKEYS : std_logic_vector(11 downto 0);

signal capslock_pressed : std_logic;
signal capsheld_next : std_logic;
signal capsheld_reg : std_logic;
  
signal spi_miso_io : std_logic;

signal status : std_logic_vector(31 downto 0);
signal mc_JOY1X : std_logic_vector(7 downto 0);
signal mc_JOY1Y : std_logic_vector(7 downto 0);
signal mc_JOY2X : std_logic_vector(7 downto 0);
signal mc_JOY2Y : std_logic_vector(7 downto 0);

signal JOY1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal JOY2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
signal JOY1X : std_logic_vector(7 downto 0);
signal JOY1Y : std_logic_vector(7 downto 0);
signal JOY2X : std_logic_vector(7 downto 0);
signal JOY2Y : std_logic_vector(7 downto 0);
signal JOY1_n :  STD_LOGIC_VECTOR(4 DOWNTO 0);
signal JOY2_n :  STD_LOGIC_VECTOR(4 DOWNTO 0);
signal joy_still : std_logic;
signal FIRE2: std_logic_vector(3 downto 0);

SIGNAL KEYBOARD_RESPONSE :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL KEYBOARD_SCAN :  STD_LOGIC_VECTOR(5 DOWNTO 0);
signal controller_select : std_logic_vector(1 downto 0);

SIGNAL PAL : std_logic;
SIGNAL COMPOSITE_ON_HSYNC : std_logic;
SIGNAL VGA : std_logic;

signal SDRAM_REQUEST : std_logic;
signal SDRAM_REQUEST_COMPLETE : std_logic;
signal SDRAM_READ_ENABLE :  STD_LOGIC;
signal SDRAM_WRITE_ENABLE : std_logic;
signal SDRAM_ADDR_OUT : STD_LOGIC_VECTOR(22 DOWNTO 0);
signal SDRAM_ADDR_IN : STD_LOGIC_VECTOR(22 DOWNTO 0);
signal SDRAM_DO : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal SDRAM_DI : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal SDRAM_WIDTH_8bit_ACCESS : std_logic;
signal SDRAM_WIDTH_16bit_ACCESS : std_logic;
signal SDRAM_WIDTH_32bit_ACCESS : std_logic;

signal SDRAM_REFRESH : std_logic;
signal SDRAM_RESET_N : std_logic;

-- dma/virtual drive
signal DMA_ADDR_FETCH : std_logic_vector(23 downto 0);
signal DMA_WRITE_DATA : std_logic_vector(31 downto 0);
signal DMA_FETCH : std_logic;
signal DMA_32BIT_WRITE_ENABLE : std_logic;
signal DMA_16BIT_WRITE_ENABLE : std_logic;
signal DMA_8BIT_WRITE_ENABLE : std_logic;
signal DMA_READ_ENABLE : std_logic;
signal DMA_MEMORY_READY : std_logic;

signal pause_btnD  : std_logic;
signal pause_state : std_logic;
signal reset_atari : std_logic;
signal pause_atari : std_logic;
SIGNAL speed_6502 : std_logic_vector(5 downto 0);

-- data io
type ioctl_t is (
    IOCTL_IDLE,
    IOCTL_WRITE,
    IOCTL_ACK);
signal ioctl_state     : ioctl_t;
signal ioctl_download  : std_logic;
signal ioctl_download_D: std_logic;
signal ioctl_index     : std_logic_vector(7 downto 0);
signal ioctl_wr        : std_logic;
signal ioctl_addr      : std_logic_vector(24 downto 0);
signal ioctl_dout      : std_logic_vector(15 downto 0);
signal ioctl_last      : std_logic_vector(24 downto 0);
signal reset_load      : std_logic;

type cart_t is (
    CART_32k,
    CART_16k_1,
    CART_16k_2,
    CART_8k,
    CART_4k);
signal cart_type : cart_t;

-- ps2
signal PS2_KEYS : STD_LOGIC_VECTOR(511 downto 0);
signal PS2_KEYS_NEXT : STD_LOGIC_VECTOR(511 downto 0);

-- scandoubler
signal half_scandouble_enable_reg : std_logic;
signal half_scandouble_enable_next : std_logic;
signal scanlines_reg : std_logic;
signal VIDEO_B : std_logic_vector(7 downto 0);
signal scandoubler_disable : std_logic := '0';
signal ypbpr : std_logic := '0';

signal sd_hs        : std_logic;
signal sd_vs        : std_logic;
signal osd_red_i    : std_logic_vector(5 downto 0);
signal osd_green_i  : std_logic_vector(5 downto 0);
signal osd_blue_i   : std_logic_vector(5 downto 0);
signal osd_vs_i     : std_logic;
signal osd_hs_i     : std_logic;
signal osd_red_o    : std_logic_vector(5 downto 0);
signal osd_green_o  : std_logic_vector(5 downto 0);
signal osd_blue_o   : std_logic_vector(5 downto 0);
signal vga_y_o      : std_logic_vector(5 downto 0);
signal vga_pb_o     : std_logic_vector(5 downto 0);
signal vga_pr_o     : std_logic_vector(5 downto 0);

signal osd_s        : std_logic_vector(7 downto 0) := (others=>'1');
signal clk_kbd_s    : std_logic_vector(24 downto 0) := (others=>'0');

constant CONF_STR : string :=
    "S1,A52/BIN,Load Game...;"&
    "O3,16k Cart,1 Chip,2 Chips;"& 
    "O2,Joystick swap,Off,On;"&
    "O46,CPU Speed,1x,2x,4x,8x,16x;"&
    "O1,Scanlines,Off,On;"&
    "T7,Reset;";

-- convert string to std_logic_vector to be given to user_io
   function to_slv(s: string) return std_logic_vector is
        constant ss: string(1 to s'length) := s;
        variable rval: std_logic_vector(1 to 8 * s'length);
        variable p: integer;
        variable c: integer;
    begin
        for i in ss'range loop
            p := 8 * i;
            c := character'pos(ss(i));
            rval(p - 7 to p) := std_logic_vector(to_unsigned(c,8));
        end loop;
        return rval;
    end function;

    CONSTANT V01 : std_logic_vector(0 TO 1):="01";

    
  signal joy1_up_i, joy1_down_i, joy1_left_i, joy1_right_i, joy1_p6_i, joy1_p9_i : std_logic;
  signal joy2_up_i, joy2_down_i, joy2_left_i, joy2_right_i, joy2_p6_i, joy2_p9_i : std_logic;

BEGIN


 joystick_serial1 : joystick_serial 
    port map
    (
        clk_i           => clk_kbd_s(1), -- 14,31 MHz
        joy_data_i      => joy_data_i,
        joy_clk_o       => joy_clock_o,
        joy_load_o      => joy_load_o,

        joy1_up_o       => joy1_up_i,
        joy1_down_o     => joy1_down_i,
        joy1_left_o     => joy1_left_i,
        joy1_right_o    => joy1_right_i,
        joy1_fire1_o    => joy1_p6_i,
        joy1_fire2_o    => joy1_p9_i,

        joy2_up_o       => joy2_up_i,
        joy2_down_o     => joy2_down_i,
        joy2_left_o     => joy2_left_i,
        joy2_right_o    => joy2_right_i,
        joy2_fire1_o    => joy2_p6_i,
        joy2_fire2_o    => joy2_p9_i
    );

    
sram_we_n_o  <= '1';
sram_oe_n_o  <= '1';
stm_rst_o    <= 'Z';

pal <= '1';
vga <= not scandoubler_disable;

-- mist spi io
--spi_do <= spi_miso_io when CONF_DATA0 ='0' else 'Z';
--
--mc_user_io : user_io
--    generic map (STRLEN => CONF_STR'length)
--    PORT map(
--        clk_sys => CLK,
--        clk_sd  => CLK,
--        SPI_CLK => SPI_SCK,
--        SPI_SS_IO => CONF_DATA0,
--        SPI_MISO => SPI_miso_io,
--        SPI_MOSI => SPI_DI,
--        conf_str => to_slv(CONF_STR),

--        JOYSTICK_0 => joy1,
--        JOYSTICK_1 => joy2,
--        JOYSTICK_ANALOG_0(15 downto 8) => mc_joy1x,
--        JOYSTICK_ANALOG_0(7 downto 0) => mc_joy1y,
--        JOYSTICK_ANALOG_1(15 downto 8) => mc_joy2x,
--        JOYSTICK_ANALOG_1(7 downto 0) => mc_joy2y,

--        BUTTONS => mc_buttons,
--        SWITCHES => mc_switches,
--        STATUS => status,
--        scandoubler_disable => scandoubler_disable,
--        ypbpr => ypbpr,
--
--        PS2_KBD_CLK => ps2_clk,
--        PS2_KBD_DATA => ps2_dat,
--
--        SERIAL_DATA => (others=>'0'),
--        SERIAL_STROBE => '0'
--    );

joy1_n <= not(joy1(4 downto 0)) when status(2) = '0' else not(joy2(4 downto 0));
joy2_n <= not(joy2(4 downto 0)) when status(2) = '0' else not(joy1(4 downto 0));
joy1x <= mc_joy1x when status(2) = '0' else mc_joy2x;
joy1y <= mc_joy1y when status(2) = '0' else mc_joy2y;
joy2x <= mc_joy2x when status(2) = '0' else mc_joy1x;
joy2y <= mc_joy2y when status(2) = '0' else mc_joy1y;

FIRE2 <= "00" & joy2(5)&joy1(5) when status(2) = '0' else "00"&joy1(5)&joy2(5);

process (clk)
begin
    if rising_edge(clk) then
        clk_kbd_s <= clk_kbd_s + 1;
    end if;
end process;

-----------------------------------------------------------------
--    Analog simulation for a digital joystick input           --
--process (clk_kbd_s(14))
--variable y : signed (7 downto 0) := to_signed(0,8);
--variable x : signed (7 downto 0) := to_signed(0,8);
--begin
--    if rising_edge(clk_kbd_s(14)) then
--        if joy1_left_i = '0' then
--            if x>to_signed(-127,8) then x := x - 1; end if;
--        elsif joy1_right_i = '0' then
--            if x<to_signed(127,8) then x := x + 1; end if;
--        else --no direction, so we are going to center
--            if x<0 then x := x + 1; end if;
--            if x>0 then x := x - 1; end if;
--        end if;
--
--        joy1x <= std_logic_vector(x);
--
--        if joy1_up_i = '0' then
--            if y>to_signed(-127,8) then y := y - 1; end if;
--        elsif joy1_down_i = '0' then
--            if y<to_signed(127,8) then y := y + 1; end if;
--        else --no direction, so we are going to center
--            if y<0 then y := y + 1; end if;
--            if y>0 then y := y - 1; end if;
--        end if;
--
--        joy1y <= std_logic_vector(y);
--    end if;
--end process;
-----------------------------------------------------------------

digitaljoy1: entity work.digital_to_analog 
port map
( 
    clk       => clk_kbd_s(14),
    
    up_n_i    => joy1_up_i,
    down_n_i  => joy1_down_i,
    left_n_i  => joy1_left_i,
    right_n_i => joy1_right_i,

    std_logic_vector(x_o) => mc_joy1x,
    std_logic_vector(y_o) => mc_joy1y
);

digitaljoy2: entity work.digital_to_analog 
port map
( 
    clk       => clk_kbd_s(14),
    
    up_n_i    => joy2_up_i,
    down_n_i  => joy2_down_i,
    left_n_i  => joy2_left_i,
    right_n_i => joy2_right_i,

    std_logic_vector(x_o) => mc_joy2x,
    std_logic_vector(y_o) => mc_joy2y
);

    -- PS2 to pokey
    keyboard_map1 : entity work.ps2_to_atari5200
    generic map ( OSD_CMD => "011", CLK_SPEED => 14310 )
    PORT MAP
    ( 
        CLK                 => clk_kbd_s(1), -- 14,31MHz
        RESET_N             => reset_n,
        PS2_CLK             => ps2_clk_io,
        PS2_DAT             => ps2_data_io,

        joystick_0          => joy1_p9_i & joy1_p6_i & joy1_up_i & joy1_down_i & joy1_left_i & joy1_right_i,
        joystick_1          => joy2_p9_i & joy2_p6_i & joy2_up_i & joy2_down_i & joy2_left_i & joy2_right_i,

        FIRE2               => FIRE2,
        CONTROLLER_SELECT   => CONTROLLER_SELECT, -- selected stick keyboard/shift button
        
        KEYBOARD_SCAN       => KEYBOARD_SCAN,
        KEYBOARD_RESPONSE   => KEYBOARD_RESPONSE,

        FKEYS               => FKEYS,

        PS2_KEYS            => PS2_KEYS,
        PS2_KEYS_NEXT_OUT   => PS2_KEYS_NEXT,

        player1             => joy1(7 downto 0),
        player2             => joy2(7 downto 0),
        OSD_O               => osd_s,
        sega_strobe         => joy_p7_o
    );
-- stick 0: consol(1 downto 0)="00"

joy_still <= joy1_n(3) and joy1_n(2) and joy1_n(1) and joy1_n(0); -- TODO, need something better here I think! e.g. keypad? 5200 not centreing

dac_left : hq_dac
port map
(
    reset => not(reset_n),
    clk => clk,
    clk_ena => '1',
    pcm_in => AUDIO_L_PCM&"0000",
    dac_out => audio_l
);

dac_right : hq_dac
port map
(
    reset => not(reset_n),
    clk => clk,
    clk_ena => '1',
    pcm_in => AUDIO_R_PCM&"0000",
    dac_out => audio_r
);

mc_pll : entity work.pll_ntsc
PORT MAP
(
    inclk0 => clock_50_i,
    c0     => CLK_SDRAM,        -- 114.48MHz
    c1     => CLK,              -- 57.24MHz
    c2     => SDRAM_CLK,        -- 114.48MHz
    locked => PLL_LOCKED
);

reset_n <= PLL_LOCKED;

atari5200 : entity work.atari5200core_simplesdram
    GENERIC MAP
    (
        cycle_length => 32,
--      internal_rom => 4, --5200 rom...
--      internal_rom => 0, --5200 rom...
--      internal_ram => 16384 -- only 1 option for 5200...
        video_bits => 8,
        palette => 0
    )
    PORT MAP
    (
        CLK => CLK,
        RESET_N => RESET_N and SDRAM_RESET_N and not(reset_atari),

        VIDEO_VS => VGA_VS_RAW,
        VIDEO_HS => VGA_HS_RAW,
        VIDEO_CS => VGA_CS_RAW,
        VIDEO_B => VIDEO_B,
        VIDEO_G => open,
        VIDEO_R => open,

        AUDIO_L => AUDIO_L_PCM,
        AUDIO_R => AUDIO_R_PCM,

        -- JOYSTICK
        JOY1_X => signed(joy1x),
        JOY1_Y => signed(joy1y),
        JOY2_X => signed(joy2x),
        JOY2_Y => signed(joy2y),

        JOY1_n => JOY1_n(4)&JOY1_n(0)&JOY1_n(1)&JOY1_n(2)&JOY1_n(3),
        JOY2_n => JOY2_n(4)&JOY2_n(0)&JOY2_n(1)&JOY2_n(2)&JOY2_n(3),

        KEYBOARD_RESPONSE => KEYBOARD_RESPONSE,
        KEYBOARD_SCAN => KEYBOARD_SCAN,

        SDRAM_REQUEST => SDRAM_REQUEST,
        SDRAM_REQUEST_COMPLETE => SDRAM_REQUEST_COMPLETE,
        SDRAM_READ_ENABLE => SDRAM_READ_ENABLE,
        SDRAM_WRITE_ENABLE => SDRAM_WRITE_ENABLE,
        SDRAM_ADDR => SDRAM_ADDR_OUT,
        SDRAM_DO => SDRAM_DO,
        SDRAM_DI => SDRAM_DI,
        SDRAM_32BIT_WRITE_ENABLE => SDRAM_WIDTH_32bit_ACCESS,
        SDRAM_16BIT_WRITE_ENABLE => SDRAM_WIDTH_16bit_ACCESS,
        SDRAM_8BIT_WRITE_ENABLE => SDRAM_WIDTH_8bit_ACCESS,
        SDRAM_REFRESH => SDRAM_REFRESH,

        DMA_FETCH => dma_fetch, -- in
        DMA_READ_ENABLE => dma_read_enable, -- in
        DMA_32BIT_WRITE_ENABLE => dma_32bit_write_enable, -- in
        DMA_16BIT_WRITE_ENABLE => dma_16bit_write_enable, -- in
        DMA_8BIT_WRITE_ENABLE => dma_8bit_write_enable, -- in
        DMA_ADDR => dma_addr_fetch, -- in
        DMA_WRITE_DATA => dma_write_data,   -- in
        MEMORY_READY_DMA => dma_memory_ready,   -- out
        DMA_MEMORY_DATA => open, -- out

        --PAL => PAL,
        HALT => pause_atari,
        THROTTLE_COUNT_6502 => speed_6502,
        --emulated_cartridge_select => emulated_cartridge_select,
        --freezer_enable => freezer_enable,
        --freezer_activate => freezer_activate,

        CONTROLLER_SELECT => CONTROLLER_SELECT
    );
sdram_adaptor : entity work.sdram_statemachine
GENERIC MAP(ADDRESS_WIDTH => 22,
        AP_BIT => 10,
        COLUMN_WIDTH => 8,
        ROW_WIDTH => 12
)
PORT MAP(CLK_SYSTEM => CLK,
        CLK_SDRAM => CLK_SDRAM,
        RESET_N =>  RESET_N,
        READ_EN => SDRAM_READ_ENABLE,
        WRITE_EN => SDRAM_WRITE_ENABLE,
        REQUEST => SDRAM_REQUEST,
        BYTE_ACCESS => SDRAM_WIDTH_8BIT_ACCESS,
        WORD_ACCESS => SDRAM_WIDTH_16BIT_ACCESS,
        LONGWORD_ACCESS => SDRAM_WIDTH_32BIT_ACCESS,
        REFRESH => SDRAM_REFRESH,
        ADDRESS_IN => SDRAM_ADDR_IN,
        DATA_IN => SDRAM_DI,
        SDRAM_DQ => SDRAM_DQ,
        COMPLETE => SDRAM_REQUEST_COMPLETE,
        SDRAM_BA0 => SDRAM_BA(0),
        SDRAM_BA1 => SDRAM_BA(1),
        SDRAM_CKE => SDRAM_CKE,
        SDRAM_CS_N => SDRAM_nCS,
        SDRAM_RAS_N => SDRAM_nRAS,
        SDRAM_CAS_N => SDRAM_nCAS,
        SDRAM_WE_N => SDRAM_nWE,
        SDRAM_ldqm => SDRAM_DQML,
        SDRAM_udqm => SDRAM_DQMH,
        DATA_OUT => SDRAM_DO,
        SDRAM_ADDR => SDRAM_A(11 downto 0),
        reset_client_n => SDRAM_RESET_N
);

SDRAM_A(12) <= '0';

--LED <= not ioctl_download;

process(clk,RESET_N,SDRAM_RESET_N,reset_atari)
begin
    if ((RESET_N and SDRAM_RESET_N and not(reset_atari))='0') then
        half_scandouble_enable_reg <= '0';
        scanlines_reg <= '0';
    elsif (clk'event and clk='1') then
        half_scandouble_enable_reg <= half_scandouble_enable_next;
        scanlines_reg <= status(1);
    end if;
end process;

half_scandouble_enable_next <= not(half_scandouble_enable_reg);

scandoubler1: entity work.scandoubler
GENERIC MAP
    (
        video_bits=>6
    )
PORT MAP
    ( 
        CLK => CLK,
        RESET_N => RESET_N and SDRAM_RESET_N and not(reset_atari),

        VGA => vga,
        COMPOSITE_ON_HSYNC => V01(csync),
        colour_enable => half_scandouble_enable_reg, 
        doubled_enable => '1',
        scanlines_on => scanlines_reg,

        -- GTIA interface
        pal => PAL,
        colour_in => VIDEO_B,
        vsync_in => VGA_VS_RAW,
        hsync_in => VGA_HS_RAW,
        csync_in => VGA_CS_RAW,

        -- TO OSD
        R => osd_red_i,
        G => osd_green_i,
        B => osd_blue_i,

        VSYNC => sd_vs,
        HSYNC => sd_hs
);

osd_inst: osd
port map (
        clk_sys     => CLK,
        SPI_SCK     => SPI_SCK,
        SPI_SS3     => SPI_SS2,
        SPI_DI      => SPI_DI,

        R_in        => osd_red_i,
        G_in        => osd_green_i,
        B_in        => osd_blue_i,
        HSync       => sd_hs,
        VSync       => sd_vs,

        R_out       => osd_red_o,
        G_out       => osd_green_o,
        B_out       => osd_blue_o
);

rgb2component: rgb2ypbpr
port map (
        red => osd_red_o,
        green => osd_green_o,
        blue => osd_blue_o,
        y => vga_y_o,
        pb => vga_pb_o,
        pr => vga_pr_o
);

 -- If 15kHz Video - composite sync to VGA_HS and VGA_VS high for MiST RGB cable
VGA_HS <= not (sd_hs xor sd_vs) when scandoubler_disable='1' or ypbpr='1' else sd_hs;
VGA_VS <= '1' when scandoubler_disable='1' or ypbpr='1' else sd_vs;
VGA_R <= vga_pr_o(5 downto 1) when ypbpr='1' else osd_red_o  (5 downto 1);
VGA_G <= vga_y_o (5 downto 1) when ypbpr='1' else osd_green_o(5 downto 1);
VGA_B <= vga_pb_o(5 downto 1) when ypbpr='1' else osd_blue_o (5 downto 1);

pause_atari <= ioctl_download or pause_state;
process (CLK, RESET_N) begin
    if RESET_N = '0' then
        pause_state <= '0';
    elsif rising_edge(CLK) then
        pause_btnD <= joy1(6) or joy2(6);
        if (joy1(6) or joy2(6)) = '1' and pause_btnD = '0' then
            pause_state <= not pause_state;
        end if;
    end if;
end process;

reset_atari <=  reset_load or (not btn_n_i(4)) or status(7);

speed_6502 <= "000001" when status(6 downto 4) = "000" else
              "000010" when status(6 downto 4) = "001" else
              "000100" when status(6 downto 4) = "010" else
              "001000" when status(6 downto 4) = "011" else
              "010000";

dma_read_enable <= '0'; -- in
dma_32bit_write_enable <= '0'; -- in
dma_8bit_write_enable <= '0'; -- in

mc_data_io: data_io
generic map 
(
    STRLEN => CONF_STR'length
)
port map 
(
    clk_sys => CLK,

    SPI_SCK => SPI_SCK,
    SPI_SS2 => SPI_SS2,
    SPI_DI  => SPI_DI,
    SPI_DO  => SPI_DO,

    data_in  => osd_s,-- and keys_s,
    conf_str => to_slv(CONF_STR),
    status   => status,
    
    ioctl_download => ioctl_download,
    ioctl_index    => ioctl_index,
    ioctl_wr       => ioctl_wr,
    ioctl_addr     => ioctl_addr,
    ioctl_dout     => ioctl_dout,
    ioctl_last     => ioctl_last
);

process (CLK, RESET_N) begin
    if RESET_N = '0' then
        ioctl_state <= IOCTL_IDLE;
        reset_load <= '0';
    elsif rising_edge(CLK) then
        ioctl_download_D <= ioctl_download;
        case ioctl_state is
        when IOCTL_IDLE =>
            reset_load <= '0';
            dma_fetch <= '0';
            dma_16bit_write_enable <= '0';
            if ioctl_download_D = '0' and ioctl_download = '1' then
                cart_type <= CART_32k;
                ioctl_state <= IOCTL_WRITE;
            end if;
        when IOCTL_WRITE =>
            if ioctl_download = '0' then
                   if ioctl_last(15 downto 12) = x"5" then cart_type <= CART_4k;
                elsif ioctl_last(15 downto 12) = x"6" then cart_type <= CART_8k;
                elsif ioctl_last(15 downto 12) = x"8" then
                    if status(3) = '0' then cart_type <= CART_16k_1; else cart_type <= CART_16k_2; end if;
                end if;
                ioctl_state <= IOCTL_IDLE;
                reset_load <= '1';
            elsif ioctl_wr = '1' then
                dma_fetch <= '1';
                dma_16bit_write_enable <= '1';
                dma_write_data <= ioctl_dout & ioctl_dout;
                dma_addr_fetch <= ioctl_addr(23 downto 0);
                ioctl_state <= IOCTL_ACK;
            end if;
        when IOCTL_ACK =>
            if dma_memory_ready = '1' then
                dma_fetch <= '0';
                dma_16bit_write_enable <= '0';
                ioctl_state <= IOCTL_WRITE;
            end if;
        when others => null;
        end case;
    end if;
end process;

process (SDRAM_ADDR_OUT, cart_type) begin
    SDRAM_ADDR_IN <= SDRAM_ADDR_OUT;
    case cart_type is
    when CART_16k_1 =>
    -- one chip 16k
        case SDRAM_ADDR_OUT(15 downto 14) is
            when "10" => SDRAM_ADDR_IN(15 downto 14) <= "01";
            when others => null;
        end case;

    when CART_16k_2 =>
    -- two chip 16k
        case SDRAM_ADDR_OUT(15 downto 13) is
            when "011" => SDRAM_ADDR_IN(15 downto 13) <= "010";
            when "100" => SDRAM_ADDR_IN(15 downto 13) <= "011";
            when "101" => SDRAM_ADDR_IN(15 downto 13) <= "011";
        when others => null;
        end case;

    when CART_8k =>
    -- 8k
        SDRAM_ADDR_IN(15 downto 13) <= "010";

    when CART_4k =>
    -- 4k
        SDRAM_ADDR_IN(15 downto 12) <= "0100";
    
    when others => null;
    end case;

end process;

END vhdl;
