module neptuno2_demist_top (
	input         CLOCK_50,
	input         KEY0,
	input         KEY1,
	output        LED1,
	output        LED2,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,

	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	
	output        SD_CS,
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	
	inout 		  PS2_KEYBOARD_CLK,
	inout	      PS2_KEYBOARD_DAT,
	inout	      PS2_MOUSE_CLK,
	inout	      PS2_MOUSE_DAT,
	
    output        JOY_CLK,
	output        JOY_LOAD,
	input         JOY_DATA,
	output        JOY_SEL,
	
	output        AUDIO_L,
	output        AUDIO_R,
`ifdef I2S_AUDIO
	output        I2S_BCK,
	output        I2S_LRCK,
	output        I2S_DATA,
`endif
`ifdef USE_AUDIO_IN
	input         AUDIO_IN,
`endif
	input         UART_RX,
	output        UART_TX
);

wire reset_n;
wire   LED;

wire SPI_SCK,SPI_DO,SPI_DI,SPI_SS2,SPI_SS3,CONF_DATA0;
`ifndef NO_DIRECT_UPLOAD
wire        SPI_SS4;
`else
wire 		SPI_SS4 = 1;
`endif

`ifdef USE_PLL_50_27
wire CLOCK_27;
wire pll_lock;
pll_50_27 u_pll_50_27 (
	.inclk0 ( CLOCK_50 ),
	.c0     ( CLOCK_27 ),
	.locked ( pll_lock )
);
`endif

wire ps2_keyboard_clk_in = PS2_KEYBOARD_CLK;
wire ps2_keyboard_clk_out;
wire ps2_keyboard_dat_in = PS2_KEYBOARD_DAT ;
wire ps2_keyboard_dat_out;
assign PS2_KEYBOARD_CLK = !ps2_keyboard_clk_out ? 1'b0 : 1'bZ;
assign PS2_KEYBOARD_DAT = !ps2_keyboard_dat_out ? 1'b0 : 1'bZ;

wire ps2_mouse_clk_in = PS2_MOUSE_CLK;
wire ps2_mouse_clk_out;
wire ps2_mouse_dat_in = PS2_MOUSE_DAT;
wire ps2_mouse_dat_out;
assign PS2_MOUSE_CLK = !ps2_mouse_clk_out ? 1'b0 : 1'bZ;
assign PS2_MOUSE_DAT = !ps2_mouse_dat_out ? 1'b0 : 1'bZ;


wire joy1up,joy1down,joy1left,joy1right,joy1fire1,joy1fire2;
wire joy2up,joy2down,joy2left,joy2right,joy2fire1,joy2fire2;
wire [11:0] joy1_b12, joy2_b12;
wire [`DEMISTIFY_JOYBITS-1:0] joy1, joy2;


joydecoder joydecoder
(
	.clk      (CLOCK_50),
	.joy_data (JOY_DATA),
	.joy_clk  (JOY_CLK),
	.joy_load_n (JOY_LOAD),
	.joy1up   (joy1up),
	.joy1down (joy1down),
	.joy1left (joy1left),
	.joy1right(joy1right),
	.joy1fire1(joy1fire1),
	.joy1fire2(joy1fire2),
	.joy2up   (joy2up),
	.joy2down (joy2down),
	.joy2left (joy2left),
	.joy2right(joy2right),
	.joy2fire1(joy2fire1),
	.joy2fire2(joy2fire2) 
);

assign joy1 ={2'b11,joy1fire2,joy1fire1,joy1right,joy1left,joy1down,joy1up};
assign joy2 ={2'b11,joy2fire2,joy2fire1,joy2right,joy2left,joy2down,joy2up};


////////// MIST GUEST TOP MODULE //////////

`GUEST_TOP guest
(
`ifdef USE_PLL_50_27
 	.CLOCK_27	(CLOCK_27),
`else
 	.CLOCK_27	(CLOCK_50),
`endif
// `ifdef USE_CLOCK_50
//  	.CLOCK_50 	(CLOCK_50),
// `endif

	.*

);

assign LED1 = ~LED;



//////////    SUBSTITUTE MCU    //////////

wire rs232_rxd, rs232_txd;
wire intercept;
wire spi_fromguest;

// Pass internal signals to external SPI interface
assign SD_SCK = SPI_SCK;
assign SPI_DO = ~SPI_SS4 ? SD_MISO : 1'bZ;  // to guest
assign spi_fromguest = SPI_DO;  			// to control CPU

substitute_mcu #(
	.sysclk_frequency(500), 
	// .SPI_FASTBIT(3),				//needed if OSD hungs
	// .SPI_INTERNALBIT(2),			//needed if OSD hungs
	.debug("false"), 
	.jtag_uart("false")
) 
controller
(
 .clk          (CLOCK_50),
 .reset_in     (KEY0),			//reset_in  when 0
 .reset_out    (reset_n),		//reset_out  when 0
 
 .spi_miso     (SD_MISO),
 .spi_mosi     (SD_MOSI),
 .spi_clk      (SPI_SCK),
 .spi_cs       (SD_CS),
 .spi_fromguest(spi_fromguest),
 .spi_toguest  (SPI_DI),
 .spi_ss2      (SPI_SS2),
 .spi_ss3      (SPI_SS3),
`ifndef NO_DIRECT_UPLOAD 
 .spi_ss4      (SPI_SS4),
`endif
 .conf_data0   (CONF_DATA0),
 
 .ps2k_clk_in  (ps2_keyboard_clk_in),
 .ps2k_dat_in  (ps2_keyboard_dat_in),
 .ps2k_clk_out (ps2_keyboard_clk_out),
 .ps2k_dat_out (ps2_keyboard_dat_out),
 .ps2m_clk_in  (ps2_mouse_clk_in),
 .ps2m_dat_in  (ps2_mouse_dat_in),
 .ps2m_clk_out (ps2_mouse_clk_out),
 .ps2m_dat_out (ps2_mouse_dat_out),

 // Buttons
 .buttons	   ({31'h7FFFFFFF,KEY1}),		// 0=OSD_button

 // Joysticks
 .joy1         (joy1),
 .joy2         (joy2),

//  // UART
//  .rxd  			(rs232_rxd),
//  .txd  			(rs232_txd),

 // intercept=1 when OSD is on
 .intercept    (intercept)
);

endmodule
