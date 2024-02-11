module poseidon_top (
	input         CLOCK_50,

	output        LED,
	output [5:0]  VGA_R,
	output [5:0]  VGA_G,
	output [5:0]  VGA_B,
	output        VGA_HS,
	output        VGA_VS,

	input         SPI_SCK,
	inout         SPI_DO,
	input         SPI_DI,
	input         SPI_SS2,    // data_io
	input         SPI_SS3,    // OSD
	input         CONF_DATA0, // SPI_SS for user_io

`ifndef NO_DIRECT_UPLOAD
	input         SPI_SS4,
`endif

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


`GUEST_TOP guest
(
 .CLOCK_27  (CLOCK_50),
 .LED      	(~LED),

 .SDRAM_DQ	(SDRAM_DQ),	
 .SDRAM_A	(SDRAM_A),
 .SDRAM_DQML(SDRAM_DQML),
 .SDRAM_DQMH(SDRAM_DQMH),
 .SDRAM_nWE	(SDRAM_nWE),
 .SDRAM_nCAS(SDRAM_nCAS),
 .SDRAM_nRAS(SDRAM_nRAS),
 .SDRAM_nCS	(SDRAM_nCS),
 .SDRAM_BA	(SDRAM_BA),
 .SDRAM_CLK	(SDRAM_CLK),
 .SDRAM_CKE	(SDRAM_CKE),
					 
 .SPI_DO	(SPI_DO),
 .SPI_DI	(SPI_DI),
 .SPI_SCK	(SPI_SCK),
 .SPI_SS2	(SPI_SS2),
 .SPI_SS3	(SPI_SS3),
 .CONF_DATA0(CONF_DATA0),
 `ifndef NO_DIRECT_UPLOAD
 .SPI_SS4	(SPI_SS4),
 `endif
 
 // AUDIO
 .AUDIO_L   (AUDIO_L),
 .AUDIO_R   (AUDIO_R),
 .I2S_BCK	(I2S_BCK),
 .I2S_LRCK	(I2S_LRCK),
 .I2S_DATA	(I2S_DATA),

 .VGA_HS	(VGA_HS),
 .VGA_VS	(VGA_VS),
 .VGA_R	 	(VGA_R),
 .VGA_G		(VGA_G),
 .VGA_B		(VGA_B),

 .AUDIO_IN  (AUDIO_IN),

 .UART_RX	(UART_RX),	
 .UART_TX	(UART_TX)

 );


endmodule
