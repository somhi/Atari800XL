---------------------------------------------------------------------------
-- (c) 2013 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- (ILoveSpeccy) Added PS2_KEYS Output
---------------------------------------------------------------------------
-- Rev. 2020/12/16 - Oduvaldo (ducasp@gmail.com)
--      * Pushed Controler Handling to this VHDL so it can control a 6 button 
--        controller
--      * Also when using a Mega Drive 6 button controller all can be done in
--        the Joystick:
--        X, Y and Z will work as START - PAUSE - RESET
--        A is unused anf B and C are the fire buttons
--      * MODE and START buttons are modifiers, and MODE + START invokes OSD
--      * MODE + (X, Y, Z, A, B, C) generate keypad 1, 2, 3, 4, 5, 6
--      * START + (X, Y, Z, A, B, C) generate keypad 7, 8, 9, *, 0, #

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY ps2_to_atari5200 IS
GENERIC
(
    ps2_enable    : integer := 1;
    direct_enable : integer := 0;
    OSD_CMD       : in   std_logic_vector(2 downto 0) := "011";
    CLK_SPEED     : integer := 14310
);
PORT 
( 
    CLK : IN STD_LOGIC;
    RESET_N : IN STD_LOGIC;
    PS2_CLK : IN STD_LOGIC := '1';
    PS2_DAT : IN STD_LOGIC := '1';
    INPUT : IN STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');

    -- inputs from Joystick
    joystick_0  : in std_logic_vector(5 downto 0);
    joystick_1  : in std_logic_vector(5 downto 0);

    KEYBOARD_SCAN : IN STD_LOGIC_VECTOR(5 downto 0);
    KEYBOARD_RESPONSE : OUT STD_LOGIC_VECTOR(1 downto 0);

    FIRE2 : IN STD_LOGIC_VECTOR(3 downto 0);
    CONTROLLER_SELECT : IN STD_LOGIC_VECTOR(1 downto 0);

    FKEYS : OUT STD_LOGIC_VECTOR(11 downto 0);

    FREEZER_ACTIVATE : OUT STD_LOGIC;
   
    PS2_KEYS : OUT STD_LOGIC_VECTOR(511 downto 0);
    PS2_KEYS_NEXT_OUT : OUT STD_LOGIC_VECTOR(511 downto 0);

    -- C, B, up, down, left, right
    player1     : out std_logic_vector(7 downto 0);
    player2     : out std_logic_vector(7 downto 0);
    OSD_O : OUT STD_LOGIC_VECTOR(7 downto 0);
    -- sega joystick
    sega_strobe : out std_logic
);
END ps2_to_atari5200;

ARCHITECTURE vhdl OF ps2_to_atari5200 IS
    signal ps2_keys_next : std_logic_vector(511 downto 0);
    signal ps2_keys_reg : std_logic_vector(511 downto 0);

    signal ps2_key_event : std_logic;
    signal ps2_key_value : std_logic_vector(7 downto 0);
    signal ps2_key_extended : std_logic;
    signal ps2_key_up : std_logic;

    signal direct_key_event : std_logic;
    signal direct_key_value : std_logic_vector(7 downto 0);
    signal direct_key_extended : std_logic;
    signal direct_key_up : std_logic;

    signal key_event : std_logic;
    signal key_value : std_logic_vector(7 downto 0);
    signal key_extended : std_logic;
    signal key_up : std_logic;

    signal FKEYS_INT : std_logic_vector(11 downto 0);

    signal FREEZER_ACTIVATE_INT : std_logic;

    signal atari_keyboard : std_logic_vector(15 downto 0);

    signal fire_pressed_sel : std_logic;

    signal osd_s : std_logic_vector(7 downto 0) := (others=>'1');

    -- Sega Joystick
    signal clk_sega_s : std_logic := '0';
    signal clk_delay : unsigned(9 downto 0) := (others=>'1');
    signal TIMECLK   : integer;
    signal joyP7_s  : std_logic := '0';
    signal sega1_s  : std_logic_vector(11 downto 0) := (others=>'1');
    signal segaf1_s : std_logic_vector(11 downto 0) := (others=>'1');
    signal sega2_s  : std_logic_vector(11 downto 0) := (others=>'1');
    signal segaf2_s : std_logic_vector(11 downto 0) := (others=>'1');
    signal sega1Emulate_Key1 : std_logic := '0';
    signal sega1Emulate_Key2 : std_logic := '0';
    signal sega1Emulate_Key3 : std_logic := '0';
    signal sega1Emulate_Key4 : std_logic := '0';
    signal sega1Emulate_Key5 : std_logic := '0';
    signal sega1Emulate_Key6 : std_logic := '0';
    signal sega1Emulate_Key7 : std_logic := '0';
    signal sega1Emulate_Key8 : std_logic := '0';
    signal sega1Emulate_Key9 : std_logic := '0';
    signal sega1Emulate_KeyS : std_logic := '0';
    signal sega1Emulate_Key0 : std_logic := '0';
    signal sega1Emulate_KeyH : std_logic := '0';
    signal sega2Emulate_Key1 : std_logic := '0';
    signal sega2Emulate_Key2 : std_logic := '0';
    signal sega2Emulate_Key3 : std_logic := '0';
    signal sega2Emulate_Key4 : std_logic := '0';
    signal sega2Emulate_Key5 : std_logic := '0';
    signal sega2Emulate_Key6 : std_logic := '0';
    signal sega2Emulate_Key7 : std_logic := '0';
    signal sega2Emulate_Key8 : std_logic := '0';
    signal sega2Emulate_Key9 : std_logic := '0';
    signal sega2Emulate_KeyS : std_logic := '0';
    signal sega2Emulate_Key0 : std_logic := '0';
    signal sega2Emulate_KeyH : std_logic := '0';
BEGIN

    OSD_O <= osd_s;
    player1 <= ("00" & not segaf1_s(5) & not segaf1_s(4) & not segaf1_s(3) & not segaf1_s(2) & not segaf1_s(1) & not segaf1_s(0));
    player2 <= ("00" & not segaf2_s(5) & not segaf2_s(4) & not segaf2_s(3) & not segaf2_s(2) & not segaf2_s(1) & not segaf2_s(0));

    process(clk,reset_n)
    begin
        if (reset_n='0') then
            ps2_keys_reg <= (others=>'0');
        elsif (clk'event and clk='1') then
            ps2_keys_reg <= ps2_keys_next;
        end if;
    end process;

gen_ps2_on : if ps2_enable=1 generate
    keyboard1: entity work.ps2_keyboard
    PORT MAP
    ( 
        CLK => CLK,
        RESET_N => RESET_N,
        PS2_CLK => PS2_CLK,
        PS2_DAT => PS2_DAT,
        
        KEY_EVENT => PS2_KEY_EVENT,
        KEY_VALUE => PS2_KEY_VALUE,
        KEY_EXTENDED => PS2_KEY_EXTENDED,
        KEY_UP => PS2_KEY_UP
--      KEY_EVENT : OUT STD_LOGIC; -- high for 1 cycle on new key pressed(or repeated)/released
--      KEY_VALUE : OUT STD_LOGIC_VECTOR(7 downto 0); -- valid on event, raw scan code
--      KEY_EXTENDED : OUT STD_LOGIC;           -- valid on event, if scan code extended
--      KEY_UP : OUT STD_LOGIC                 -- value on event, if key released
    );
end generate;

gen_ps2_off : if ps2_enable=0 generate
    PS2_KEY_EVENT <= '0';
    PS2_KEY_VALUE <= (others=>'0');
    PS2_KEY_EXTENDED <= '0';
    PS2_KEY_UP <= '0';
end generate;

gen_direct_on : if direct_enable=1 generate
    direct_key_value <= input(7 downto 0);
    direct_key_extended <= input(12);
    direct_key_up <= not(input(16));
    direct_key_event <= '1';
end generate;

gen_direct_off : if direct_enable=0 generate
    DIRECT_KEY_EVENT <= '0';
    DIRECT_KEY_VALUE <= (others=>'0');
    DIRECT_KEY_EXTENDED <= '0';
    DIRECT_KEY_UP <= '0';
end generate;

    KEY_EVENT <= DIRECT_KEY_EVENT or PS2_KEY_EVENT;
    KEY_VALUE <= PS2_KEY_VALUE when PS2_KEY_EVENT='1' else DIRECT_KEY_VALUE;
    KEY_EXTENDED <= PS2_KEY_EXTENDED when PS2_KEY_EVENT='1' else DIRECT_KEY_EXTENDED;
    KEY_UP <= PS2_KEY_UP when PS2_KEY_EVENT='1' else DIRECT_KEY_UP;

    process(KEY_EVENT, KEY_VALUE, KEY_EXTENDED, KEY_UP, ps2_keys_reg)
    begin
        ps2_keys_next <= ps2_keys_reg;

        if (KEY_EVENT = '1') then
            ps2_keys_next(to_integer(unsigned(KEY_EXTENDED&KEY_VALUE))) <= NOT(KEY_UP);       
        end if;
    end process;

    process(clk)
    begin
    if rising_edge(clk) then
        if (ps2_keys_reg(16#07#) = '1') or ((segaf1_s(11) or segaf1_s(7)) = '0') then
            osd_s(7 downto 5) <= "011";
        else
            osd_s(7 downto 5) <= "111";
        end if;
        osd_s(0) <= (not ps2_keys_reg(16#175#)) and segaf1_s(3); --up
        osd_s(1) <= (not ps2_keys_reg(16#172#)) and segaf1_s(2); --down
        osd_s(2) <= (not ps2_keys_reg(16#16b#)) and segaf1_s(1); --left
        osd_s(3) <= (not ps2_keys_reg(16#174#)) and segaf1_s(0); --right
        osd_s(4) <= (not ps2_keys_reg(16#5A#))  and (segaf1_s(4) and segaf1_s(5) and segaf1_s(6));  --enter
    end if;
    end process;

    -- map to atari key code
    process(ps2_keys_reg, fire2, controller_select)
    begin
        atari_keyboard <= (others=>'0');

        fire_pressed_sel <= '0';

        case controller_select is
            when "00" =>
                -- todo change order to match keycode! check with petes test
                atari_keyboard(12) <= (ps2_keys_reg(16#05#) and not(ps2_keys_reg(16#14#))) or (not segaf1_s(10));-- f1
                atari_keyboard( 8) <= (ps2_keys_reg(16#06#) and not(ps2_keys_reg(16#14#))) or (not segaf1_s( 9));-- f2
                atari_keyboard( 4) <= (ps2_keys_reg(16#04#) and not(ps2_keys_reg(16#14#))) or (not segaf1_s( 8));-- f3
                atari_keyboard(15) <= (ps2_keys_reg(16#16#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key1; -- 1
                atari_keyboard(14) <= (ps2_keys_reg(16#1E#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key2; -- 2
                atari_keyboard(13) <= (ps2_keys_reg(16#26#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key3; -- 3
                atari_keyboard(11) <= (ps2_keys_reg(16#15#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key4; -- q
                atari_keyboard(10) <= (ps2_keys_reg(16#1D#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key5; -- w
                atari_keyboard( 9) <= (ps2_keys_reg(16#24#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key6; -- e
                atari_keyboard( 7) <= (ps2_keys_reg(16#1c#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key7; -- a
                atari_keyboard( 6) <= (ps2_keys_reg(16#1b#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key8; -- s
                atari_keyboard( 5) <= (ps2_keys_reg(16#23#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key9; -- d
                atari_keyboard( 3) <= (ps2_keys_reg(16#1a#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_KeyS; -- z 
                atari_keyboard( 2) <= (ps2_keys_reg(16#22#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_Key0; -- x
                atari_keyboard( 1) <= (ps2_keys_reg(16#21#) and not(ps2_keys_reg(16#14#))) or sega1Emulate_KeyH; -- c
                fire_pressed_sel   <= fire2(0);
                
            when "01" =>
                atari_keyboard(12) <= (ps2_keys_reg(16#0c#) and not(ps2_keys_reg(16#14#))) or (not segaf2_s(10));-- f4
                atari_keyboard( 8) <= (ps2_keys_reg(16#03#) and not(ps2_keys_reg(16#14#))) or (not segaf2_s( 9));-- f5
                atari_keyboard( 4) <= (ps2_keys_reg(16#0b#) and not(ps2_keys_reg(16#14#))) or (not segaf2_s( 8));-- f6
                atari_keyboard(15) <= (ps2_keys_reg(16#25#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key1; -- 4
                atari_keyboard(14) <= (ps2_keys_reg(16#2e#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key2; -- 5
                atari_keyboard(13) <= (ps2_keys_reg(16#36#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key3; -- 6
                atari_keyboard(11) <= (ps2_keys_reg(16#2d#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key4; -- r
                atari_keyboard(10) <= (ps2_keys_reg(16#2c#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key5; -- t 
                atari_keyboard( 9) <= (ps2_keys_reg(16#35#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key6; -- y
                atari_keyboard( 7) <= (ps2_keys_reg(16#2b#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key7; -- f
                atari_keyboard( 6) <= (ps2_keys_reg(16#34#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key8; -- g
                atari_keyboard( 5) <= (ps2_keys_reg(16#33#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key9; -- h
                atari_keyboard( 3) <= (ps2_keys_reg(16#2a#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_KeyS; -- v
                atari_keyboard( 2) <= (ps2_keys_reg(16#32#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_Key0; -- b
                atari_keyboard( 1) <= (ps2_keys_reg(16#31#) and not(ps2_keys_reg(16#14#))) or sega2Emulate_KeyH; -- n
                fire_pressed_sel   <=  fire2(1);

            when "10" =>
                atari_keyboard(12) <= ps2_keys_reg(16#05#) and ps2_keys_reg(16#14#); -- f1
                atari_keyboard( 8) <= ps2_keys_reg(16#06#) and ps2_keys_reg(16#14#); -- f2
                atari_keyboard( 4) <= ps2_keys_reg(16#04#) and ps2_keys_reg(16#14#); -- f3
                atari_keyboard(15) <= ps2_keys_reg(16#16#) and ps2_keys_reg(16#14#); -- 1
                atari_keyboard(14) <= ps2_keys_reg(16#1E#) and ps2_keys_reg(16#14#); -- 2
                atari_keyboard(13) <= ps2_keys_reg(16#26#) and ps2_keys_reg(16#14#); -- 3
                atari_keyboard(11) <= ps2_keys_reg(16#15#) and ps2_keys_reg(16#14#); -- q
                atari_keyboard(10) <= ps2_keys_reg(16#1D#) and ps2_keys_reg(16#14#); -- w
                atari_keyboard( 9) <= ps2_keys_reg(16#24#) and ps2_keys_reg(16#14#); -- e
                atari_keyboard( 7) <= ps2_keys_reg(16#1c#) and ps2_keys_reg(16#14#); -- a
                atari_keyboard( 6) <= ps2_keys_reg(16#1b#) and ps2_keys_reg(16#14#); -- s
                atari_keyboard( 5) <= ps2_keys_reg(16#23#) and ps2_keys_reg(16#14#); -- d
                atari_keyboard( 3) <= ps2_keys_reg(16#1a#) and ps2_keys_reg(16#14#); -- z 
                atari_keyboard( 2) <= ps2_keys_reg(16#22#) and ps2_keys_reg(16#14#); -- x
                atari_keyboard( 1) <= ps2_keys_reg(16#21#) and ps2_keys_reg(16#14#); -- c
                fire_pressed_sel   <=  fire2(2);

            when "11" =>
                atari_keyboard(12) <= ps2_keys_reg(16#0c#) and ps2_keys_reg(16#14#); -- f4
                atari_keyboard( 8) <= ps2_keys_reg(16#03#) and ps2_keys_reg(16#14#); -- f5
                atari_keyboard( 4) <= ps2_keys_reg(16#0b#) and ps2_keys_reg(16#14#); -- f6
                atari_keyboard(15) <= ps2_keys_reg(16#25#) and ps2_keys_reg(16#14#); -- 4
                atari_keyboard(14) <= ps2_keys_reg(16#2e#) and ps2_keys_reg(16#14#); -- 5
                atari_keyboard(13) <= ps2_keys_reg(16#36#) and ps2_keys_reg(16#14#); -- 6
                atari_keyboard(11) <= ps2_keys_reg(16#2d#) and ps2_keys_reg(16#14#); -- r
                atari_keyboard(10) <= ps2_keys_reg(16#2c#) and ps2_keys_reg(16#14#); -- t 
                atari_keyboard( 9) <= ps2_keys_reg(16#35#) and ps2_keys_reg(16#14#); -- y
                atari_keyboard( 7) <= ps2_keys_reg(16#2b#) and ps2_keys_reg(16#14#); -- f
                atari_keyboard( 6) <= ps2_keys_reg(16#34#) and ps2_keys_reg(16#14#); -- g
                atari_keyboard( 5) <= ps2_keys_reg(16#33#) and ps2_keys_reg(16#14#); -- h
                atari_keyboard( 3) <= ps2_keys_reg(16#2a#) and ps2_keys_reg(16#14#); -- v
                atari_keyboard( 2) <= ps2_keys_reg(16#32#) and ps2_keys_reg(16#14#); -- b
                atari_keyboard( 1) <= ps2_keys_reg(16#31#) and ps2_keys_reg(16#14#); -- n
                fire_pressed_sel   <= fire2(3);
            when others =>
        end case;

        fkeys_int( 0) <= ps2_keys_reg(16#05#) or (not segaf1_s(10));
        fkeys_int( 1) <= ps2_keys_reg(16#06#) or (not segaf1_s( 9));
        fkeys_int( 2) <= ps2_keys_reg(16#04#) or (not segaf1_s( 8));
        fkeys_int( 3) <= ps2_keys_reg(16#0C#) or (not segaf2_s(10));
        fkeys_int( 4) <= ps2_keys_reg(16#03#) or (not segaf2_s( 9));
        fkeys_int( 5) <= ps2_keys_reg(16#0B#) or (not segaf2_s( 8));
        fkeys_int( 6) <= ps2_keys_reg(16#83#);
        fkeys_int( 7) <= ps2_keys_reg(16#0a#);
        fkeys_int( 8) <= ps2_keys_reg(16#01#);
        fkeys_int( 9) <= ps2_keys_reg(16#09#);
        fkeys_int(10) <= ps2_keys_reg(16#78#);
        fkeys_int(11) <= ps2_keys_reg(16#07#) or (not (segaf1_s(11) or segaf1_s(7)));

        -- use scroll lock or delete to activate freezer (same key on my keyboard + scroll lock does not seem to work on mist!)
        freezer_activate_int <= ps2_keys_reg(16#7e#) or ps2_keys_reg(16#171#);
    end process;

    -- provide results as if we were a grid to pokey...
    process(keyboard_scan, atari_keyboard, fire_pressed_sel)
        begin   
            keyboard_response <= (others=>'1');     
            
            if (atari_keyboard(to_integer(unsigned(not(keyboard_scan(4 downto 1))))) = '1') then
                keyboard_response(0) <= '0';
            end if;
            
            keyboard_response(1) <= not(fire_pressed_sel);
    end process;         

--- Joystick read with sega 6 button support----------------------

    process(clk)
    begin
    if rising_edge(clk) then

        
        TIMECLK <= (9 * (CLK_SPEED/1000)); -- calculate ~9us from the master clock

        clk_delay <= clk_delay - 1;
        
        if (clk_delay = 0) then
            clk_sega_s <= not clk_sega_s;
            clk_delay <= to_unsigned(TIMECLK,10); 
        end if;

    end if;
    end process;


    process(clk)
    variable state_v : unsigned(8 downto 0) := (others=>'0');
    variable j1_sixbutton_v : std_logic := '0';
    variable j2_sixbutton_v : std_logic := '0';
    variable sega_edge : std_logic_vector(1 downto 0);

    begin
    if rising_edge(clk) then

        sega_edge := sega_edge(0) & clk_sega_s;

        if sega_edge = "01" then
            state_v := state_v + 1;
            
            case state_v is
                -- joy_s format MXYZ ASCB UDLR
                
                when '0'&X"01" =>  
                    joyP7_s <= '0';
                    
                when '0'&X"02" =>  
                    joyP7_s <= '1';
                    
                when '0'&X"03" => 
                    sega1_s(5 downto 0) <= joystick_0(5 downto 0); -- C, B, up, down, left, right 
                    sega2_s(5 downto 0) <= joystick_1(5 downto 0);
                    
                    j1_sixbutton_v := '0'; -- Assume it's not a six-button controller
                    j2_sixbutton_v := '0'; -- Assume it's not a six-button controller

                    joyP7_s <= '0';

                when '0'&X"04" =>
                    if joystick_0(0) = '0' and joystick_0(1) = '0' then -- it's a megadrive controller
                                sega1_s(7 downto 6) <= joystick_0(5 downto 4); -- A, Start
                    else
                                sega1_s(7 downto 4) <= joystick_0(4) & '1' & joystick_0(5) & '1'; -- read A/B as master System
                    end if;
                            
                    if joystick_1(0) = '0' and joystick_1(1) = '0' then -- it's a megadrive controller
                                sega2_s(7 downto 6) <= joystick_1(5 downto 4); -- A, Start
                    else
                                sega2_s(7 downto 4) <= joystick_1(4) & '1' & joystick_1(5) & '1'; -- read A/B as master System
                    end if;
                    
                                        
                    joyP7_s <= '1';
            
                when '0'&X"05" =>  
                    joyP7_s <= '0';
                    
                when '0'&X"06" =>
                    if joystick_0(2) = '0' and joystick_0(3) = '0' then 
                        j1_sixbutton_v := '1'; --it's a six button
                    end if;
                    
                    if joystick_1(2) = '0' and joystick_1(3) = '0' then 
                        j2_sixbutton_v := '1'; --it's a six button
                    end if;
                    
                    joyP7_s <= '1';
                    
                when '0'&X"07" =>
                    if j1_sixbutton_v = '1' then
                        sega1_s(11 downto 8) <= joystick_0(0) & joystick_0(1) & joystick_0(2) & joystick_0(3); -- Mode, X, Y e Z                        
                    end if;

                    if j2_sixbutton_v = '1' then
                        sega2_s(11 downto 8) <= joystick_1(0) & joystick_1(1) & joystick_1(2) & joystick_1(3); -- Mode, X, Y e Z
                    end if;

                    joyP7_s <= '0';

                when others =>
                    joyP7_s <= '1';
                    
            end case;

            sega1Emulate_Key1 <= (not sega1_s(10)) and sega1_s(7)       and (not sega1_s(11));
            sega1Emulate_Key2 <= (not sega1_s(9))  and sega1_s(7)       and (not sega1_s(11));
            sega1Emulate_Key3 <= (not sega1_s(8))  and sega1_s(7)       and (not sega1_s(11));
            sega1Emulate_Key4 <= (not sega1_s(6))  and sega1_s(7)       and (not sega1_s(11));
            sega1Emulate_Key5 <= (not sega1_s(4))  and sega1_s(7)       and (not sega1_s(11));
            sega1Emulate_Key6 <= (not sega1_s(5))  and sega1_s(7)       and (not sega1_s(11));
            sega1Emulate_Key7 <= (not sega1_s(10)) and (not sega1_s(7)) and sega1_s(11);
            sega1Emulate_Key8 <= (not sega1_s(9))  and (not sega1_s(7)) and sega1_s(11);
            sega1Emulate_Key9 <= (not sega1_s(8))  and (not sega1_s(7)) and sega1_s(11);
            sega1Emulate_KeyS <= (not sega1_s(6))  and (not sega1_s(7)) and sega1_s(11);
            sega1Emulate_Key0 <= (not sega1_s(4))  and (not sega1_s(7)) and sega1_s(11);
            sega1Emulate_KeyH <= (not sega1_s(5))  and (not sega1_s(7)) and sega1_s(11);
            sega2Emulate_Key1 <= (not sega2_s(10)) and sega2_s(7)       and (not sega2_s(11));
            sega2Emulate_Key2 <= (not sega2_s(9))  and sega2_s(7)       and (not sega2_s(11));
            sega2Emulate_Key3 <= (not sega2_s(8))  and sega2_s(7)       and (not sega2_s(11));
            sega2Emulate_Key4 <= (not sega2_s(6))  and sega2_s(7)       and (not sega2_s(11));
            sega2Emulate_Key5 <= (not sega2_s(4))  and sega2_s(7)       and (not sega2_s(11));
            sega2Emulate_Key6 <= (not sega2_s(5))  and sega2_s(7)       and (not sega2_s(11));
            sega2Emulate_Key7 <= (not sega2_s(10)) and (not sega2_s(7)) and sega2_s(11);
            sega2Emulate_Key8 <= (not sega2_s(9))  and (not sega2_s(7)) and sega2_s(11);
            sega2Emulate_Key9 <= (not sega2_s(8))  and (not sega2_s(7)) and sega2_s(11);
            sega2Emulate_KeyS <= (not sega2_s(6))  and (not sega2_s(7)) and sega2_s(11);
            sega2Emulate_Key0 <= (not sega2_s(4))  and (not sega2_s(7)) and sega2_s(11);
            sega2Emulate_KeyH <= (not sega2_s(5))  and (not sega2_s(7)) and sega2_s(11);
            segaf1_s <= sega1_s;
            segaf2_s <= sega2_s;
            --- In case virtual keypad key is pressed, do not press the button related to it
            if ( sega1Emulate_Key1 = '1' or sega1Emulate_Key7 = '1' ) then segaf1_s(10) <= '1'; end if;
            if ( sega1Emulate_Key2 = '1' or sega1Emulate_Key8 = '1' ) then segaf1_s( 9) <= '1'; end if;
            if ( sega1Emulate_Key3 = '1' or sega1Emulate_Key9 = '1' ) then segaf1_s( 8) <= '1'; end if;
            if ( sega1Emulate_Key4 = '1' or sega1Emulate_KeyS = '1' ) then segaf1_s( 6) <= '1'; end if;
            if ( sega1Emulate_Key5 = '1' or sega1Emulate_Key0 = '1' ) then segaf1_s( 4) <= '1'; end if;
            if ( sega1Emulate_Key6 = '1' or sega1Emulate_KeyH = '1' ) then segaf1_s( 5) <= '1'; end if;
            if ( sega2Emulate_Key1 = '1' or sega2Emulate_Key7 = '1' ) then segaf2_s(10) <= '1'; end if;
            if ( sega2Emulate_Key2 = '1' or sega2Emulate_Key8 = '1' ) then segaf2_s( 9) <= '1'; end if;
            if ( sega2Emulate_Key3 = '1' or sega2Emulate_Key9 = '1' ) then segaf2_s( 8) <= '1'; end if;
            if ( sega2Emulate_Key4 = '1' or sega2Emulate_KeyS = '1' ) then segaf2_s( 6) <= '1'; end if;
            if ( sega2Emulate_Key5 = '1' or sega2Emulate_Key0 = '1' ) then segaf2_s( 4) <= '1'; end if;
            if ( sega2Emulate_Key6 = '1' or sega2Emulate_KeyH = '1' ) then segaf2_s( 5) <= '1'; end if;
        end if;
    end if;
    end process;

    sega_strobe <= joyP7_s;

    -- outputs
    FKEYS <= FKEYS_INT;
    FREEZER_ACTIVATE <= FREEZER_ACTIVATE_INT;

    PS2_KEYS <= ps2_keys_reg;
    PS2_KEYS_NEXT_OUT <= ps2_keys_next;
END vhdl;

