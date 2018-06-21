//-------------------------------------------------------------------//
//
//	SiTCP_sample_LAN8810i
//
//-------------------------------------------------------------------//


module	SiTCP_sample_LAN8810i(
	// System
		OSC				,	// 25MHz clock
	// MII interface
		ETH_RESETn		,	
		// TX
		ETH_TXD			,	// Tx data[7:0]
		ETH_TX_ER		,	// TX error
		ETH_TX_EN		,	// Tx enable
		ETH_TX_CLK		,	// Tx clock(2.5 or 25MHz)		-- PD
		ETH_GTX_CLK		,	// GTX clock
		// RX
		ETH_RXD			,	// Rx data[7:0]
		ETH_RX_ER		,	// Rx error
		ETH_RX_DV		,	// Rx data valid
		ETH_RX_CLK		,	// Rx clock(2.5 or 25MHz)
		ETH_RX_CRS		,	// Carrier sense				-- PD
		ETH_RX_COL		,	// Collision detected			-- PD
		// Management IF
		ETH_MDIO		,	// data in/out
		ETH_MDC			,	// Clock for MDIO
		ETH_PHY_CLK		,	
		// LED
		ETH_LED_Y		,	// FullDuplex LED
		ETH_LED_G		,	// Link, Activity
		ETH_ACT_LED		,	// Active LED
		ETH_10_LED		,	// Speed is 10M select LED
		ETH_100_LED		,	// Speed is 100M select LED
		ETH_1000_LED	,	// Speed is 1000M select LED
	// EEPROM(AT93C46DSH)
		EEPROM_CS		,	// Chip Select
		EEPROM_SK		,	// Clock
		EEPROM_DI		,	// Data Input
		EEPROM_DO		,	// Data Output
	// SW
		DIPSW				// Force Default
	);


//-------- Input/Output --------
	input	wire			OSC;

	output	wire			ETH_RESETn;
	output	wire	[ 7:0]	ETH_TXD;
	output	wire			ETH_TX_ER;
	output	wire			ETH_TX_EN;
	input	wire			ETH_TX_CLK;
	output	wire			ETH_GTX_CLK;
	input	wire	[ 7:0]	ETH_RXD;
	input	wire			ETH_RX_ER;
	input	wire			ETH_RX_DV;
	input	wire			ETH_RX_CLK;
	input	wire			ETH_RX_CRS;
	input	wire			ETH_RX_COL;
	inout	wire			ETH_MDIO;
	output	wire			ETH_MDC;
	output	wire			ETH_PHY_CLK;

	input	wire			ETH_ACT_LED;
	input	wire			ETH_10_LED;
	input	wire			ETH_100_LED;
	input	wire			ETH_1000_LED;

	output	wire			ETH_LED_Y;
	output	wire			ETH_LED_G;

	output	wire			EEPROM_CS;
	output	wire			EEPROM_SK;
	output	wire			EEPROM_DI;
	input	wire			EEPROM_DO;

	input	wire	[ 7:0]	DIPSW;

		
//-------- reg/wire --------

	wire			OSCCLK25M;
	wire			PLL_CLKFB;
	wire			CLK200M_DCM;
	wire			CLK125M_DCM;
	wire			CLK200M;
	wire			CLK125M;
	reg		[ 1:0]	CNT25M;
	reg				RE_CLK25M;
	reg				FE_CLK25M;
	wire			CLK25M;
	reg				SYS_RST;
	wire			SiTCP_RST;
	wire			SYS_PLL_LOCK;
	wire			EEPROM_CS_int;
	wire			EEPROM_SK_int;
	wire			EEPROM_DI_int;
	wire			IB_EEPROM_DO;
	wire			ETH_GTXCLK_int;
	wire			GMII_MDC;
	wire			GMII_MDIO_IN;
	wire			GMII_MDIO_OUT;
	wire			GMII_MDIO_OE;
	wire			GMII_COL;
	wire			GMII_CRS;
	wire			GMII_RX_CLK;
	wire			GMII_RX_DV;
	wire			GMII_RX_ER;
	wire			GMII_TX_CLK;
	wire			GMII_TX_EN;
	wire			GMII_TX_ER;
	wire			IB_TX_CLK;
	wire			GMII_RSTn;
	wire	[ 7:0]	GMII_TXD;
	wire	[ 7:0]	GMII_RXD;
	wire			GMII_1000M;
	wire			IB_ETH_ACT_LED;
	wire			IB_ETH_1000_LED;
	wire			IB_ETH_100_LED;
	wire			IB_ETH_10_LED;
	wire			ETH_LED_G_int;
	wire			ETH_LED_Y_int;
	wire			TCP_OPEN_ACK;
	wire			TCP_CLOSE_REQ;
	wire			TCP_CLOSE_ACK;
	wire			TCP_TX_FULL;
	wire			TCP_TX_WR;
	wire	[ 7:0]	TCP_TX_DATA;
	wire			RBCP_ACT;
	wire	[31:0]	RBCP_ADDR;
	wire	[ 7:0]	RBCP_WD;
	wire			RBCP_WE;
	wire			RBCP_RE;
	wire			RBCP_ACK;
	wire	[ 7:0]	RBCP_RD;
	wire	[ 7:0]	IB_DIPSW;
	wire			FORCE_DEFAULTn;
	reg		[ 6:0]	RSTCNT;
	reg				RX_RST200NS;
	reg				RX_RST_2ND;
	reg		[ 4:0]	RX_COUNT;
	reg				RX_SELECT;
	reg		[ 8:0]	SYS_RST_CNT;


////////////////////////////////////////////////////////////////////////////////
//	Clock, PLL
////////////////////////////////////////////////////////////////////////////////

	IBUFG	#(.IOSTANDARD ("LVCMOS33"))	OSC_BUF(.O(OSCCLK25M),.I(OSC));

	PLL_BASE #(
		.BANDWIDTH				("HIGH"),
  		.CLK_FEEDBACK			("CLKFBOUT"),
		.COMPENSATION			("INTERNAL"),
		.DIVCLK_DIVIDE			(1),
		.CLKFBOUT_MULT			(40),
		.CLKFBOUT_PHASE			(0.000),

		.CLKOUT0_DIVIDE			(5),
		.CLKOUT0_PHASE			(0.000),
		.CLKOUT0_DUTY_CYCLE		(0.500),

		.CLKOUT1_DIVIDE			(8),
		.CLKOUT1_PHASE			(0.000),
		.CLKOUT1_DUTY_CYCLE		(0.500),

		.CLKIN_PERIOD			(40.0),
		.REF_JITTER				(0.005)
	)
	SYSTEM_PLL(
		.CLKFBOUT				(PLL_CLKFB),
		.CLKOUT0				(CLK200M_DCM),		// for SiTCP CLK(200MHz)
		.CLKOUT1				(CLK125M_DCM),
		.CLKFBIN				(PLL_CLKFB),
		.CLKIN					(OSCCLK25M),
		.LOCKED					(SYS_PLL_LOCK),
		.RST					(1'b0)				// Const
	);

	BUFG	CLK200M_GB		(.O(CLK200M),	.I(CLK200M_DCM));
	BUFG	CLK125M_GB		(.O(CLK125M),	.I(CLK125M_DCM));

	always@ (posedge CLK200M or negedge SYS_PLL_LOCK) begin
		if(SYS_PLL_LOCK == 0) begin
			SYS_RST_CNT[8:0]	<=	9'd198;
			SYS_RST				<=	1'b1;
		end	else begin
			SYS_RST_CNT[8:0]	<=	SYS_RST_CNT[8:0] - ((SYS_RST_CNT[8])?	9'b0:	9'b1);
			SYS_RST				<=	~SYS_RST_CNT[8];
		end
	end

	//	25MHz (for ETH_PHY_CLK) Generator
	initial		CNT25M[1:0]	= 2'b0;
	initial		RE_CLK25M	= 1'b0;
	initial		FE_CLK25M	= 1'b0;

	always@ (posedge CLK125M) begin
		CNT25M[0]	<= ~CNT25M[0] & ~(~CNT25M[1] & RE_CLK25M);
		CNT25M[1]	<= CNT25M[0]^CNT25M[1];
		RE_CLK25M	<= CNT25M[0]|CNT25M[1];
	end

	always@ (negedge CLK125M) begin
		FE_CLK25M	<= CNT25M[1];
	end
	
	ODDR	ETH_MACCLK_OR(.Q(CLK25M), .C(CLK125M), .CE(1'b1), .D1(RE_CLK25M), .D2(FE_CLK25M), .R(1'b0), .S(1'b0));



////////////////////////////////////////////////////////////////////////////////
//	Ether
////////////////////////////////////////////////////////////////////////////////

	generate
		genvar ETH_D_var;
		 for (ETH_D_var=0;ETH_D_var<8;ETH_D_var=ETH_D_var+1) begin : ETH_D_LOOP
			OBUF	#(.IOSTANDARD ("LVCMOS33"), .DRIVE(4), .SLEW("FAST"))		ETH_TXD_OB	(.O(ETH_TXD[ETH_D_var]), .I(GMII_TXD[ETH_D_var]));
			IBUF	#(.IOSTANDARD ("LVCMOS33"))		ETH_RXD_IB	(.O(GMII_RXD[ETH_D_var]), .I(ETH_RXD[ETH_D_var]));
			PULLDOWN	ETH_RXD_PD	(.O(ETH_RXD[ETH_D_var]));
		end
	endgenerate


	OBUF	#(.IOSTANDARD ("LVCMOS33"), .DRIVE(4), .SLEW("SLOW"))	ETH_RESETn_OB	(.O(ETH_RESETn), .I(GMII_RSTn));
	IBUFG	#(.IOSTANDARD ("LVCMOS33"))	ETH_TX_CLK_IB	(.O(IB_TX_CLK),.I(ETH_TX_CLK));
	BUFGMUX GMIIMUX(.O(GMII_TX_CLK), .I0(IB_TX_CLK), .I1(CLK125M), .S(GMII_1000M));
	ODDR	GTXCLK_OR(.Q(ETH_GTXCLK_int), .C(GMII_TX_CLK), .CE(1'b1), .D1(1'b0), .D2(1'b1), .R(1'b0), .S(1'b0));
	OBUF	#(.IOSTANDARD ("LVCMOS33"), .DRIVE(4), .SLEW("SLOW"))	ETH_GTXCLK_OB	(.O(ETH_GTX_CLK), .I(ETH_GTXCLK_int));
	IBUFG	#(.IOSTANDARD ("LVCMOS33"))	ETH_RX_CLK_IB	(.O(ETH_RX_CLK_int),.I(ETH_RX_CLK));
	BUFG	ETH_RX_CLK_IG(.O(GMII_RX_CLK), .I(ETH_RX_CLK_int));
	OBUF	#(.IOSTANDARD ("LVCMOS33"), .DRIVE(4), .SLEW("FAST"))	ETH_TX_ER_OB	(.O(ETH_TX_ER), .I(GMII_TX_ER));
	OBUF	#(.IOSTANDARD ("LVCMOS33"), .DRIVE(4), .SLEW("FAST"))	ETH_TX_EN_OB	(.O(ETH_TX_EN), .I(GMII_TX_EN));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_RX_ER_IB	(.O(GMII_RX_ER),.I(ETH_RX_ER));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_RX_DV_IB	(.O(GMII_RX_DV),.I(ETH_RX_DV));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_CRS_IB		(.O(GMII_CRS),.I(ETH_RX_CRS));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_COL_IB		(.O(GMII_COL),.I(ETH_RX_COL));
	PULLDOWN	ETH_RX_ER_PD		(.O(ETH_RX_ER));
	PULLDOWN	ETH_RX_DV_PD		(.O(ETH_RX_DV));
	PULLDOWN	ETH_RX_CRS_PD		(.O(ETH_RX_CRS));
	PULLDOWN	ETH_RX_COL_PD		(.O(ETH_RX_COL));
	IOBUF	#(.IOSTANDARD ("LVCMOS33"), .DRIVE(4), .SLEW("SLOW"))	ETH_MDIO_BUF	(.O(GMII_MDIO_IN), .IO(ETH_MDIO), .I(GMII_MDIO_OUT), .T(~GMII_MDIO_OE));
	PULLUP		ETH_MDIO_PU		(.O(ETH_MDIO));
	OBUF	#(.IOSTANDARD ("LVCMOS33"), .DRIVE(4), .SLEW("SLOW"))	ETH_MDC_OB		(.O(ETH_MDC), .I(GMII_MDC));
	OBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_XI_25M_OB	(.O(ETH_PHY_CLK), .I(CLK25M));

	assign	GMII_1000M	=	RX_SELECT;

	//	LED
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_ACT_LED_IB		(.O(IB_ETH_ACT_LED),	.I(ETH_ACT_LED));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_1000_LED_IB		(.O(IB_ETH_1000_LED),	.I(ETH_1000_LED));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_100_LED_IB		(.O(IB_ETH_100_LED),	.I(ETH_100_LED));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_10_LED_IB		(.O(IB_ETH_10_LED),		.I(ETH_10_LED));
	PULLDOWN	ETH_ACT_LED_PD		(.O(ETH_ACT_LED));
	PULLDOWN	ETH_1000_LED_PD		(.O(ETH_1000_LED));
	PULLDOWN	ETH_100_LED_PD		(.O(ETH_100_LED));		// HPD_MODE default
	PULLDOWN	ETH_10_LED_PD		(.O(ETH_10_LED));

	OBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_LED_G_OB		(.O(ETH_LED_G),	.I(ETH_LED_G_int));
	OBUF	#(.IOSTANDARD ("LVCMOS33"))	ETH_LED_Y_OB		(.O(ETH_LED_Y),	.I(ETH_LED_Y_int));

	assign	ETH_LED_G_int	=	IB_ETH_1000_LED | IB_ETH_100_LED | IB_ETH_10_LED;
	assign	ETH_LED_Y_int	=	IB_ETH_ACT_LED;


////////////////////////////////////////////////////////////////////////////////
//	SiTCP
////////////////////////////////////////////////////////////////////////////////

	//	EEPROM
	OBUF	#(.IOSTANDARD ("LVCMOS33"), .SLEW("SLOW"))	EEPROM_CS_OB		(.O(EEPROM_CS), .I(EEPROM_CS_int));
	OBUF	#(.IOSTANDARD ("LVCMOS33"), .SLEW("SLOW"))	EEPROM_SK_OB		(.O(EEPROM_SK), .I(EEPROM_SK_int));
	OBUF	#(.IOSTANDARD ("LVCMOS33"), .SLEW("SLOW"))	EEPROM_DI_OB		(.O(EEPROM_DI), .I(EEPROM_DI_int));
	IBUF	#(.IOSTANDARD ("LVCMOS33"))								EEPROM_DO_IB		(.O(IB_EEPROM_DO), .I(EEPROM_DO));
	PULLUP	EEPROM_DO_PU	(.O(EEPROM_DO));

	always@ (posedge CLK200M or posedge SYS_RST) begin
		if(SYS_RST)begin
			RSTCNT[6:0]		<=	7'd0;
			RX_RST200NS		<=	1'b0;
			RX_RST_2ND		<=	1'b0;
		end	else begin
			RSTCNT[6:0]		<=	RSTCNT[6]?	7'd38:		(RSTCNT[6:0] - 7'd1);
			RX_RST200NS		<=	RSTCNT[6];
			RX_RST_2ND		<=	RX_RST200NS;
		end
	end

	always@ (posedge GMII_RX_CLK or posedge RX_RST_2ND) begin
		if(RX_RST_2ND) begin
			RX_COUNT[4:0]	<=	5'd0;
		end	else begin
			RX_COUNT[4:0]	<=	RX_COUNT[4:0] + (RX_COUNT[4]?	5'd0:	5'd1);
		end
	end

	always@ (posedge CLK200M) begin
			RX_SELECT		<=	RX_RST200NS?	RX_COUNT[4]:	RX_SELECT;		//1:125M	0:25M/2.5M
	end

	// DIPSW for Force Default
	IBUF	#(.IOSTANDARD ("LVCMOS33"))		DIPSW_IB	(.O(IB_DIPSW[0]), .I(DIPSW[0]));
	PULLUP	DIPSW_PU(.O(DIPSW[0]));
	assign	FORCE_DEFAULTn	=	IB_DIPSW[0];

	// SiTCP
	WRAP_SiTCP_GMII_XC7A_32K	#(
		.TIM_PERIOD				(8'd200)					// System clock frequency(MHz), integer only
	)
	WRAP_SiTCP_GMII_XC7A_32K(
		.CLK					(CLK200M),					// System Clock >129MHz
		.RST					(SYS_RST),					// System reset
	// Configuration parameters
		.FORCE_DEFAULTn			(FORCE_DEFAULTn),			// Load default parameters
		.EXT_IP_ADDR			(32'd0),					// IP address[31:0]
		.EXT_TCP_PORT			(16'd0),					// TCP port #[15:0]
		.EXT_RBCP_PORT			(16'd0),					// RBCP port #[15:0]
		.PHY_ADDR				(5'b0_0000),				// PHY-device MIF address[4:0]
	// EEPROM
		.EEPROM_CS				(EEPROM_CS_int),				// Chip select
		.EEPROM_SK				(EEPROM_SK_int),				// Serial data clock
		.EEPROM_DI				(EEPROM_DI_int),				// Serial write data
		.EEPROM_DO				(IB_EEPROM_DO),				// Serial read data
	// MII interface
		.GMII_RSTn				(GMII_RSTn),				// PHY reset
		.GMII_1000M				(GMII_1000M),				// GMII mode (0:MII, 1:GMII)
		// TX
		.GMII_TX_CLK			(GMII_TX_CLK),				// Tx clock
		.GMII_TX_EN				(GMII_TX_EN),				// Tx enable
		.GMII_TXD				(GMII_TXD[7:0]),			// Tx data[7:0]
		.GMII_TX_ER				(GMII_TX_ER),				// TX error
		// RX
		.GMII_RX_CLK			(GMII_RX_CLK),				// Rx clock
		.GMII_RX_DV				(GMII_RX_DV),				// Rx data valid
		.GMII_RXD				(GMII_RXD[7:0]),			// Rx data[7:0]
		.GMII_RX_ER				(GMII_RX_ER),				// Rx error
		.GMII_CRS				(GMII_CRS),					// Carrier sense
		.GMII_COL				(GMII_COL),					// Collision detected
	// Management IF
		.GMII_MDC				(GMII_MDC),					// Clock for MDIO
		.GMII_MDIO_IN			(GMII_MDIO_IN),				// Data
		.GMII_MDIO_OUT			(GMII_MDIO_OUT),			// Data
		.GMII_MDIO_OE			(GMII_MDIO_OE),				// MDIO output enable
	// User I/F
		.SiTCP_RST				(SiTCP_RST),				// Reset for SiTCP and related circuits
		// TCP connection control
		.TCP_OPEN_REQ			(1'b0),						// Reserved input, shoud be 0
		.TCP_OPEN_ACK			(TCP_OPEN_ACK),				// Acknowledge for open (=Socket busy)
		.TCP_ERROR				(),							// TCP error, its active period is equal to MSL
		.TCP_CLOSE_REQ			(TCP_CLOSE_REQ),			// Connection close request
		.TCP_CLOSE_ACK			(TCP_CLOSE_ACK),			// Acknowledge for closing
		// FIFO I/F
		.TCP_RX_WC				(16'h0000),					// Rx FIFO write count[15:0] (Unused bits should be set 1)
		.TCP_RX_WR				(),							// Write enable
		.TCP_RX_DATA			(),							// Write data[7:0]
		.TCP_TX_FULL			(TCP_TX_FULL),				// Almost full flag
		.TCP_TX_WR				(TCP_TX_WR),				// Write enable
		.TCP_TX_DATA			(TCP_TX_DATA[7:0]),			// Write data[7:0]
		// RBCP
		.RBCP_ACT				(RBCP_ACT),					// RBCP active
		.RBCP_ADDR				(RBCP_ADDR[31:0]),			// Address[31:0]
		.RBCP_WD				(RBCP_WD[7:0]),				// Data[7:0]
		.RBCP_WE				(RBCP_WE),					// Write enable
		.RBCP_RE				(RBCP_RE),					// Read enable
		.RBCP_ACK				(RBCP_ACK),					// Access acknowledge
		.RBCP_RD				(RBCP_RD[7:0])				// Read data[7:0]
	);

endmodule
