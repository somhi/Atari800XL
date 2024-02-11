
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"c0",x"1e",x"c1",x"78"),
     1 => (x"fd",x"49",x"c7",x"1e"),
     2 => (x"86",x"c8",x"87",x"cd"),
     3 => (x"cd",x"02",x"98",x"70"),
     4 => (x"fb",x"49",x"ff",x"87"),
     5 => (x"da",x"c1",x"87",x"cc"),
     6 => (x"87",x"ea",x"e3",x"49"),
     7 => (x"e0",x"c2",x"4d",x"c1"),
     8 => (x"02",x"bf",x"97",x"d1"),
     9 => (x"f3",x"cc",x"87",x"c3"),
    10 => (x"d6",x"e0",x"c2",x"87"),
    11 => (x"c8",x"c2",x"4b",x"bf"),
    12 => (x"c0",x"05",x"bf",x"f2"),
    13 => (x"fd",x"c3",x"87",x"e9"),
    14 => (x"87",x"ca",x"e3",x"49"),
    15 => (x"e3",x"49",x"fa",x"c3"),
    16 => (x"49",x"73",x"87",x"c4"),
    17 => (x"71",x"99",x"ff",x"c3"),
    18 => (x"fb",x"49",x"c0",x"1e"),
    19 => (x"49",x"73",x"87",x"ce"),
    20 => (x"71",x"29",x"b7",x"c8"),
    21 => (x"fb",x"49",x"c1",x"1e"),
    22 => (x"86",x"c8",x"87",x"c2"),
    23 => (x"c2",x"87",x"f9",x"c5"),
    24 => (x"4b",x"bf",x"da",x"e0"),
    25 => (x"87",x"dd",x"02",x"9b"),
    26 => (x"bf",x"ee",x"c8",x"c2"),
    27 => (x"87",x"d6",x"c7",x"49"),
    28 => (x"c4",x"05",x"98",x"70"),
    29 => (x"d2",x"4b",x"c0",x"87"),
    30 => (x"49",x"e0",x"c2",x"87"),
    31 => (x"c2",x"87",x"fb",x"c6"),
    32 => (x"c6",x"58",x"f2",x"c8"),
    33 => (x"ee",x"c8",x"c2",x"87"),
    34 => (x"73",x"78",x"c0",x"48"),
    35 => (x"05",x"99",x"c2",x"49"),
    36 => (x"eb",x"c3",x"87",x"cd"),
    37 => (x"87",x"ee",x"e1",x"49"),
    38 => (x"99",x"c2",x"49",x"70"),
    39 => (x"fb",x"87",x"c2",x"02"),
    40 => (x"c1",x"49",x"73",x"4c"),
    41 => (x"87",x"cd",x"05",x"99"),
    42 => (x"e1",x"49",x"f4",x"c3"),
    43 => (x"49",x"70",x"87",x"d8"),
    44 => (x"c2",x"02",x"99",x"c2"),
    45 => (x"73",x"4c",x"fa",x"87"),
    46 => (x"05",x"99",x"c8",x"49"),
    47 => (x"f5",x"c3",x"87",x"cd"),
    48 => (x"87",x"c2",x"e1",x"49"),
    49 => (x"99",x"c2",x"49",x"70"),
    50 => (x"c2",x"87",x"d4",x"02"),
    51 => (x"02",x"bf",x"e2",x"e0"),
    52 => (x"c1",x"48",x"87",x"c9"),
    53 => (x"e6",x"e0",x"c2",x"88"),
    54 => (x"ff",x"87",x"c2",x"58"),
    55 => (x"73",x"4d",x"c1",x"4c"),
    56 => (x"05",x"99",x"c4",x"49"),
    57 => (x"f2",x"c3",x"87",x"cd"),
    58 => (x"87",x"da",x"e0",x"49"),
    59 => (x"99",x"c2",x"49",x"70"),
    60 => (x"c2",x"87",x"db",x"02"),
    61 => (x"7e",x"bf",x"e2",x"e0"),
    62 => (x"a8",x"b7",x"c7",x"48"),
    63 => (x"6e",x"87",x"cb",x"03"),
    64 => (x"c2",x"80",x"c1",x"48"),
    65 => (x"c0",x"58",x"e6",x"e0"),
    66 => (x"4c",x"fe",x"87",x"c2"),
    67 => (x"fd",x"c3",x"4d",x"c1"),
    68 => (x"f1",x"df",x"ff",x"49"),
    69 => (x"c2",x"49",x"70",x"87"),
    70 => (x"87",x"d5",x"02",x"99"),
    71 => (x"bf",x"e2",x"e0",x"c2"),
    72 => (x"87",x"c9",x"c0",x"02"),
    73 => (x"48",x"e2",x"e0",x"c2"),
    74 => (x"c2",x"c0",x"78",x"c0"),
    75 => (x"c1",x"4c",x"fd",x"87"),
    76 => (x"49",x"fa",x"c3",x"4d"),
    77 => (x"87",x"ce",x"df",x"ff"),
    78 => (x"99",x"c2",x"49",x"70"),
    79 => (x"c2",x"87",x"d9",x"02"),
    80 => (x"48",x"bf",x"e2",x"e0"),
    81 => (x"03",x"a8",x"b7",x"c7"),
    82 => (x"c2",x"87",x"c9",x"c0"),
    83 => (x"c7",x"48",x"e2",x"e0"),
    84 => (x"87",x"c2",x"c0",x"78"),
    85 => (x"4d",x"c1",x"4c",x"fc"),
    86 => (x"03",x"ac",x"b7",x"c0"),
    87 => (x"c4",x"87",x"d1",x"c0"),
    88 => (x"d8",x"c1",x"4a",x"66"),
    89 => (x"c0",x"02",x"6a",x"82"),
    90 => (x"4b",x"6a",x"87",x"c6"),
    91 => (x"0f",x"73",x"49",x"74"),
    92 => (x"f0",x"c3",x"1e",x"c0"),
    93 => (x"49",x"da",x"c1",x"1e"),
    94 => (x"c8",x"87",x"dc",x"f7"),
    95 => (x"02",x"98",x"70",x"86"),
    96 => (x"c8",x"87",x"e2",x"c0"),
    97 => (x"e0",x"c2",x"48",x"a6"),
    98 => (x"c8",x"78",x"bf",x"e2"),
    99 => (x"91",x"cb",x"49",x"66"),
   100 => (x"71",x"48",x"66",x"c4"),
   101 => (x"6e",x"7e",x"70",x"80"),
   102 => (x"c8",x"c0",x"02",x"bf"),
   103 => (x"4b",x"bf",x"6e",x"87"),
   104 => (x"73",x"49",x"66",x"c8"),
   105 => (x"02",x"9d",x"75",x"0f"),
   106 => (x"c2",x"87",x"c8",x"c0"),
   107 => (x"49",x"bf",x"e2",x"e0"),
   108 => (x"c2",x"87",x"ca",x"f3"),
   109 => (x"02",x"bf",x"f6",x"c8"),
   110 => (x"49",x"87",x"dd",x"c0"),
   111 => (x"70",x"87",x"c7",x"c2"),
   112 => (x"d3",x"c0",x"02",x"98"),
   113 => (x"e2",x"e0",x"c2",x"87"),
   114 => (x"f0",x"f2",x"49",x"bf"),
   115 => (x"f4",x"49",x"c0",x"87"),
   116 => (x"c8",x"c2",x"87",x"d0"),
   117 => (x"78",x"c0",x"48",x"f6"),
   118 => (x"ea",x"f3",x"8e",x"f4"),
   119 => (x"5b",x"5e",x"0e",x"87"),
   120 => (x"1e",x"0e",x"5d",x"5c"),
   121 => (x"e0",x"c2",x"4c",x"71"),
   122 => (x"c1",x"49",x"bf",x"de"),
   123 => (x"c1",x"4d",x"a1",x"cd"),
   124 => (x"7e",x"69",x"81",x"d1"),
   125 => (x"cf",x"02",x"9c",x"74"),
   126 => (x"4b",x"a5",x"c4",x"87"),
   127 => (x"e0",x"c2",x"7b",x"74"),
   128 => (x"f3",x"49",x"bf",x"de"),
   129 => (x"7b",x"6e",x"87",x"c9"),
   130 => (x"c4",x"05",x"9c",x"74"),
   131 => (x"c2",x"4b",x"c0",x"87"),
   132 => (x"73",x"4b",x"c1",x"87"),
   133 => (x"87",x"ca",x"f3",x"49"),
   134 => (x"c7",x"02",x"66",x"d4"),
   135 => (x"87",x"da",x"49",x"87"),
   136 => (x"87",x"c2",x"4a",x"70"),
   137 => (x"c8",x"c2",x"4a",x"c0"),
   138 => (x"f2",x"26",x"5a",x"fa"),
   139 => (x"00",x"00",x"87",x"d9"),
   140 => (x"00",x"00",x"00",x"00"),
   141 => (x"00",x"00",x"00",x"00"),
   142 => (x"71",x"1e",x"00",x"00"),
   143 => (x"bf",x"c8",x"ff",x"4a"),
   144 => (x"48",x"a1",x"72",x"49"),
   145 => (x"ff",x"1e",x"4f",x"26"),
   146 => (x"fe",x"89",x"bf",x"c8"),
   147 => (x"c0",x"c0",x"c0",x"c0"),
   148 => (x"c4",x"01",x"a9",x"c0"),
   149 => (x"c2",x"4a",x"c0",x"87"),
   150 => (x"72",x"4a",x"c1",x"87"),
   151 => (x"0e",x"4f",x"26",x"48"),
   152 => (x"5d",x"5c",x"5b",x"5e"),
   153 => (x"7e",x"71",x"1e",x"0e"),
   154 => (x"6e",x"4b",x"d4",x"ff"),
   155 => (x"e6",x"e0",x"c2",x"1e"),
   156 => (x"e0",x"d5",x"fe",x"49"),
   157 => (x"70",x"86",x"c4",x"87"),
   158 => (x"c3",x"02",x"9d",x"4d"),
   159 => (x"e0",x"c2",x"87",x"c3"),
   160 => (x"6e",x"4c",x"bf",x"ee"),
   161 => (x"d5",x"e7",x"fe",x"49"),
   162 => (x"48",x"d0",x"ff",x"87"),
   163 => (x"c1",x"78",x"c5",x"c8"),
   164 => (x"4a",x"c0",x"7b",x"d6"),
   165 => (x"82",x"c1",x"7b",x"15"),
   166 => (x"aa",x"b7",x"e0",x"c0"),
   167 => (x"ff",x"87",x"f5",x"04"),
   168 => (x"78",x"c4",x"48",x"d0"),
   169 => (x"c1",x"78",x"c5",x"c8"),
   170 => (x"7b",x"c1",x"7b",x"d3"),
   171 => (x"9c",x"74",x"78",x"c4"),
   172 => (x"87",x"fc",x"c1",x"02"),
   173 => (x"7e",x"d6",x"cf",x"c2"),
   174 => (x"8c",x"4d",x"c0",x"c8"),
   175 => (x"03",x"ac",x"b7",x"c0"),
   176 => (x"c0",x"c8",x"87",x"c6"),
   177 => (x"4c",x"c0",x"4d",x"a4"),
   178 => (x"97",x"c7",x"dc",x"c2"),
   179 => (x"99",x"d0",x"49",x"bf"),
   180 => (x"c0",x"87",x"d2",x"02"),
   181 => (x"e6",x"e0",x"c2",x"1e"),
   182 => (x"d4",x"d7",x"fe",x"49"),
   183 => (x"70",x"86",x"c4",x"87"),
   184 => (x"ef",x"c0",x"4a",x"49"),
   185 => (x"d6",x"cf",x"c2",x"87"),
   186 => (x"e6",x"e0",x"c2",x"1e"),
   187 => (x"c0",x"d7",x"fe",x"49"),
   188 => (x"70",x"86",x"c4",x"87"),
   189 => (x"d0",x"ff",x"4a",x"49"),
   190 => (x"78",x"c5",x"c8",x"48"),
   191 => (x"6e",x"7b",x"d4",x"c1"),
   192 => (x"6e",x"7b",x"bf",x"97"),
   193 => (x"70",x"80",x"c1",x"48"),
   194 => (x"05",x"8d",x"c1",x"7e"),
   195 => (x"ff",x"87",x"f0",x"ff"),
   196 => (x"78",x"c4",x"48",x"d0"),
   197 => (x"c5",x"05",x"9a",x"72"),
   198 => (x"c0",x"48",x"c0",x"87"),
   199 => (x"1e",x"c1",x"87",x"e5"),
   200 => (x"49",x"e6",x"e0",x"c2"),
   201 => (x"87",x"e8",x"d4",x"fe"),
   202 => (x"9c",x"74",x"86",x"c4"),
   203 => (x"87",x"c4",x"fe",x"05"),
   204 => (x"c8",x"48",x"d0",x"ff"),
   205 => (x"d3",x"c1",x"78",x"c5"),
   206 => (x"c4",x"7b",x"c0",x"7b"),
   207 => (x"c2",x"48",x"c1",x"78"),
   208 => (x"26",x"48",x"c0",x"87"),
   209 => (x"4c",x"26",x"4d",x"26"),
   210 => (x"4f",x"26",x"4b",x"26"),
   211 => (x"c4",x"4a",x"71",x"1e"),
   212 => (x"87",x"c5",x"05",x"66"),
   213 => (x"c6",x"fc",x"49",x"72"),
   214 => (x"00",x"4f",x"26",x"87"),
   215 => (x"ea",x"ce",x"c2",x"1e"),
   216 => (x"b9",x"c1",x"49",x"bf"),
   217 => (x"59",x"ee",x"ce",x"c2"),
   218 => (x"c3",x"48",x"d4",x"ff"),
   219 => (x"d0",x"ff",x"78",x"ff"),
   220 => (x"78",x"e1",x"c8",x"48"),
   221 => (x"c1",x"48",x"d4",x"ff"),
   222 => (x"71",x"31",x"c4",x"78"),
   223 => (x"48",x"d0",x"ff",x"78"),
   224 => (x"26",x"78",x"e0",x"c0"),
   225 => (x"ce",x"c2",x"1e",x"4f"),
   226 => (x"e0",x"c2",x"1e",x"de"),
   227 => (x"d1",x"fe",x"49",x"e6"),
   228 => (x"86",x"c4",x"87",x"c3"),
   229 => (x"c3",x"02",x"98",x"70"),
   230 => (x"87",x"c0",x"ff",x"87"),
   231 => (x"35",x"31",x"4f",x"26"),
   232 => (x"20",x"5a",x"48",x"4b"),
   233 => (x"46",x"43",x"20",x"20"),
   234 => (x"00",x"00",x"00",x"47"),
   235 => (x"00",x"00",x"00",x"00"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

