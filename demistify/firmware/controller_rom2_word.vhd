library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic	(
	ADDR_WIDTH : integer := 8; -- ROM's address width (words, not bytes)
	COL_WIDTH  : integer := 8;  -- Column width (8bit -> byte)
	NB_COL     : integer := 4  -- Number of columns in memory
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

architecture arch of controller_rom2 is

-- type word_t is std_logic_vector(31 downto 0);
type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);

signal ram : ram_type :=
(

     0 => x"c01ec178",
     1 => x"fd49c71e",
     2 => x"86c887cd",
     3 => x"cd029870",
     4 => x"fb49ff87",
     5 => x"dac187cc",
     6 => x"87eae349",
     7 => x"e0c24dc1",
     8 => x"02bf97d1",
     9 => x"f3cc87c3",
    10 => x"d6e0c287",
    11 => x"c8c24bbf",
    12 => x"c005bff2",
    13 => x"fdc387e9",
    14 => x"87cae349",
    15 => x"e349fac3",
    16 => x"497387c4",
    17 => x"7199ffc3",
    18 => x"fb49c01e",
    19 => x"497387ce",
    20 => x"7129b7c8",
    21 => x"fb49c11e",
    22 => x"86c887c2",
    23 => x"c287f9c5",
    24 => x"4bbfdae0",
    25 => x"87dd029b",
    26 => x"bfeec8c2",
    27 => x"87d6c749",
    28 => x"c4059870",
    29 => x"d24bc087",
    30 => x"49e0c287",
    31 => x"c287fbc6",
    32 => x"c658f2c8",
    33 => x"eec8c287",
    34 => x"7378c048",
    35 => x"0599c249",
    36 => x"ebc387cd",
    37 => x"87eee149",
    38 => x"99c24970",
    39 => x"fb87c202",
    40 => x"c149734c",
    41 => x"87cd0599",
    42 => x"e149f4c3",
    43 => x"497087d8",
    44 => x"c20299c2",
    45 => x"734cfa87",
    46 => x"0599c849",
    47 => x"f5c387cd",
    48 => x"87c2e149",
    49 => x"99c24970",
    50 => x"c287d402",
    51 => x"02bfe2e0",
    52 => x"c14887c9",
    53 => x"e6e0c288",
    54 => x"ff87c258",
    55 => x"734dc14c",
    56 => x"0599c449",
    57 => x"f2c387cd",
    58 => x"87dae049",
    59 => x"99c24970",
    60 => x"c287db02",
    61 => x"7ebfe2e0",
    62 => x"a8b7c748",
    63 => x"6e87cb03",
    64 => x"c280c148",
    65 => x"c058e6e0",
    66 => x"4cfe87c2",
    67 => x"fdc34dc1",
    68 => x"f1dfff49",
    69 => x"c2497087",
    70 => x"87d50299",
    71 => x"bfe2e0c2",
    72 => x"87c9c002",
    73 => x"48e2e0c2",
    74 => x"c2c078c0",
    75 => x"c14cfd87",
    76 => x"49fac34d",
    77 => x"87cedfff",
    78 => x"99c24970",
    79 => x"c287d902",
    80 => x"48bfe2e0",
    81 => x"03a8b7c7",
    82 => x"c287c9c0",
    83 => x"c748e2e0",
    84 => x"87c2c078",
    85 => x"4dc14cfc",
    86 => x"03acb7c0",
    87 => x"c487d1c0",
    88 => x"d8c14a66",
    89 => x"c0026a82",
    90 => x"4b6a87c6",
    91 => x"0f734974",
    92 => x"f0c31ec0",
    93 => x"49dac11e",
    94 => x"c887dcf7",
    95 => x"02987086",
    96 => x"c887e2c0",
    97 => x"e0c248a6",
    98 => x"c878bfe2",
    99 => x"91cb4966",
   100 => x"714866c4",
   101 => x"6e7e7080",
   102 => x"c8c002bf",
   103 => x"4bbf6e87",
   104 => x"734966c8",
   105 => x"029d750f",
   106 => x"c287c8c0",
   107 => x"49bfe2e0",
   108 => x"c287caf3",
   109 => x"02bff6c8",
   110 => x"4987ddc0",
   111 => x"7087c7c2",
   112 => x"d3c00298",
   113 => x"e2e0c287",
   114 => x"f0f249bf",
   115 => x"f449c087",
   116 => x"c8c287d0",
   117 => x"78c048f6",
   118 => x"eaf38ef4",
   119 => x"5b5e0e87",
   120 => x"1e0e5d5c",
   121 => x"e0c24c71",
   122 => x"c149bfde",
   123 => x"c14da1cd",
   124 => x"7e6981d1",
   125 => x"cf029c74",
   126 => x"4ba5c487",
   127 => x"e0c27b74",
   128 => x"f349bfde",
   129 => x"7b6e87c9",
   130 => x"c4059c74",
   131 => x"c24bc087",
   132 => x"734bc187",
   133 => x"87caf349",
   134 => x"c70266d4",
   135 => x"87da4987",
   136 => x"87c24a70",
   137 => x"c8c24ac0",
   138 => x"f2265afa",
   139 => x"000087d9",
   140 => x"00000000",
   141 => x"00000000",
   142 => x"711e0000",
   143 => x"bfc8ff4a",
   144 => x"48a17249",
   145 => x"ff1e4f26",
   146 => x"fe89bfc8",
   147 => x"c0c0c0c0",
   148 => x"c401a9c0",
   149 => x"c24ac087",
   150 => x"724ac187",
   151 => x"0e4f2648",
   152 => x"5d5c5b5e",
   153 => x"7e711e0e",
   154 => x"6e4bd4ff",
   155 => x"e6e0c21e",
   156 => x"e0d5fe49",
   157 => x"7086c487",
   158 => x"c3029d4d",
   159 => x"e0c287c3",
   160 => x"6e4cbfee",
   161 => x"d5e7fe49",
   162 => x"48d0ff87",
   163 => x"c178c5c8",
   164 => x"4ac07bd6",
   165 => x"82c17b15",
   166 => x"aab7e0c0",
   167 => x"ff87f504",
   168 => x"78c448d0",
   169 => x"c178c5c8",
   170 => x"7bc17bd3",
   171 => x"9c7478c4",
   172 => x"87fcc102",
   173 => x"7ed6cfc2",
   174 => x"8c4dc0c8",
   175 => x"03acb7c0",
   176 => x"c0c887c6",
   177 => x"4cc04da4",
   178 => x"97c7dcc2",
   179 => x"99d049bf",
   180 => x"c087d202",
   181 => x"e6e0c21e",
   182 => x"d4d7fe49",
   183 => x"7086c487",
   184 => x"efc04a49",
   185 => x"d6cfc287",
   186 => x"e6e0c21e",
   187 => x"c0d7fe49",
   188 => x"7086c487",
   189 => x"d0ff4a49",
   190 => x"78c5c848",
   191 => x"6e7bd4c1",
   192 => x"6e7bbf97",
   193 => x"7080c148",
   194 => x"058dc17e",
   195 => x"ff87f0ff",
   196 => x"78c448d0",
   197 => x"c5059a72",
   198 => x"c048c087",
   199 => x"1ec187e5",
   200 => x"49e6e0c2",
   201 => x"87e8d4fe",
   202 => x"9c7486c4",
   203 => x"87c4fe05",
   204 => x"c848d0ff",
   205 => x"d3c178c5",
   206 => x"c47bc07b",
   207 => x"c248c178",
   208 => x"2648c087",
   209 => x"4c264d26",
   210 => x"4f264b26",
   211 => x"c44a711e",
   212 => x"87c50566",
   213 => x"c6fc4972",
   214 => x"004f2687",
   215 => x"eacec21e",
   216 => x"b9c149bf",
   217 => x"59eecec2",
   218 => x"c348d4ff",
   219 => x"d0ff78ff",
   220 => x"78e1c848",
   221 => x"c148d4ff",
   222 => x"7131c478",
   223 => x"48d0ff78",
   224 => x"2678e0c0",
   225 => x"cec21e4f",
   226 => x"e0c21ede",
   227 => x"d1fe49e6",
   228 => x"86c487c3",
   229 => x"c3029870",
   230 => x"87c0ff87",
   231 => x"35314f26",
   232 => x"205a484b",
   233 => x"46432020",
   234 => x"00000047",
   235 => x"00000000",
  others => ( x"00000000")
);

-- Xilinx Vivado attributes
attribute ram_style: string;
attribute ram_style of ram: signal is "block";

signal q_local : std_logic_vector((NB_COL * COL_WIDTH)-1 downto 0);

signal wea : std_logic_vector(NB_COL - 1 downto 0);

begin

	output:
	for i in 0 to NB_COL - 1 generate
		q((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= q_local((i+1) * COL_WIDTH - 1 downto i * COL_WIDTH);
	end generate;
    
    -- Generate write enable signals
    -- The Block ram generator doesn't like it when the compare is done in the if statement it self.
    wea <= bytesel when we = '1' else (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
            q_local <= ram(to_integer(unsigned(addr)));
            for i in 0 to NB_COL - 1 loop
                if (wea(NB_COL-i-1) = '1') then
                    ram(to_integer(unsigned(addr)))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= d((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
                end if;
            end loop;
        end if;
    end process;

end arch;
