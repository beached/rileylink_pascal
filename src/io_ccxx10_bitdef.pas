UNIT io_ccxx10_bitdef;

INTERFACE

USES CStdInt;

	CONST
		PERCFG_T1CFG : uint8_t = $40;
		PERCFG_T3CFG : uint8_t = $20;
		PERCFG_T4CFG : uint8_t = $10;
		PERCFG_U1CFG : uint8_t = $02;
		PERCFG_U0CFG : uint8_t = $01;
		U1CSR_MODE = $80;
		U1CSR_RE = $40;
		U1CSR_SLAVE = $20;
		U1CSR_FE = $10;
		U1CSR_ERR = $08;
		U1CSR_RX_BYTE = $04;
		U1CSR_TX_BYTE = $02;
		U1CSR_ACTIVE = $01;
		U1GCR_CPOL = $80;
		U1GCR_CPHA = $40;
		U1GCR_ORDER = $20;
		U1GCR_BAUD_E = $1F;
		U1GCR_BAUD_E0 = $01;
		U1GCR_BAUD_E1 = $02;
		U1GCR_BAUD_E2 = $04;
		U1GCR_BAUD_E3 = $08;
		U1GCR_BAUD_E4 = $10;

		//*******************************************************************************
		//* Power Management and Clocks
		//*
		PCON_IDLE = $01;
		SLEEP_USB_EN = $80;
		SLEEP_XOSC_S = $40;
		SLEEP_HFRC_S = $20;
		SLEEP_RST = $18;
		SLEEP_RST0 = $08;
		SLEEP_RST1 = $10;
		SLEEP_OSC_PD = $04;
		SLEEP_MODE= $03;
		SLEEP_MODE1 = $02;
		SLEEP_MODE0 = $01;
		SLEEP_RST_POR_BOD = $00 SHL 3;
		SLEEP_RST_EXT = $01 SHL 3;
		SLEEP_RST_WDT = $02 SHL 3;
		SLEEP_MODE_PM0 = $00;
		SLEEP_MODE_PM1 = $01;
		SLEEP_MODE_PM2 = $02;
		SLEEP_MODE_PM3 = $03;
		CLKCON_OSC32 = $80;  // bit mask, for the slow 32k clock oscillator
		CLKCON_OSC = $40;  // bit mask, for the system clock oscillator
		CLKCON_TICKSPD = $38;  // bit mask, for timer ticks output setting
		CLKCON_TICKSPD0 = $08;  // bit mask, for timer ticks output setting
		CLKCON_TICKSPD1 = $10;  // bit mask, for timer ticks output setting
		CLKCON_TICKSPD2 = $20;  // bit mask, for timer ticks output setting
		CLKCON_CLKSPD = $07;  // bit mask, for the clock speed
		CLKCON_CLKSPD0 = $01;  // bit mask, for the clock speed
		CLKCON_CLKSPD1 = $02;  // bit mask, for the clock speed
		CLKCON_CLKSPD2 = $04;  // bit mask, for the clock speed
		TICKSPD_DIV_1 = $00 SHL 3;
		TICKSPD_DIV_2 = $01 SHL 3;
		TICKSPD_DIV_4 = $02 SHL 3;
		TICKSPD_DIV_8 = $03 SHL 3;
		TICKSPD_DIV_16 = $04 SHL 3;
		TICKSPD_DIV_32 = $05 SHL 3;
		TICKSPD_DIV_64 = $06 SHL 3;
		TICKSPD_DIV_128 = $07 SHL 3;
		CLKSPD_DIV_1 = $00;
		CLKSPD_DIV_2 = $01;
		CLKSPD_DIV_4 = $02;
		CLKSPD_DIV_8 = $03;
		CLKSPD_DIV_16 = $04;
		CLKSPD_DIV_32 = $05;
		CLKSPD_DIV_64 = $06;
		CLKSPD_DIV_128 = $07;

		
		T1CTL_CH2IF = $80; // Timer 1 channel 2 interrupt flag
		T1CTL_CH1IF = $40; // Timer 1 channel 1 interrupt flag
		T1CTL_CH0IF = $20; // Timer 1 channel 0 interrupt flag
		T1CTL_OVFIF = $10; // Timer 1 counter overflow interrupt flag
		T1CTL_DIV = $0C;
		T1CTL_DIV0 = $04;
		T1CTL_DIV1 = $08;
		T1CTL_MODE = $03;
		T1CTL_MODE0 = $01;
		T1CTL_MODE1 = $02;

		T1CTL_DIV_1 = $00 SHL 2; // Divide tick frequency by 1
		T1CTL_DIV_8 = $01 SHL 2; // Divide tick frequency by 8
		T1CTL_DIV_32 = $02 SHL 2; // Divide tick frequency by 32
		T1CTL_DIV_128 = $03 SHL 2; // Divide tick frequency by 128

		T1CTL_MODE_SUSPEND = $00;		// Operation is suspended halt;
		T1CTL_MODE_FREERUN = $01;		// Free Running mode
		T1CTL_MODE_MODULO = $02;		// Modulo
		T1CTL_MODE_UPDOWN = $03;		// Up/down

		T1CCTL0_CPSEL = $80;		// Timer 1 channel 0 capture select
		T1CCTL0_IM = $40;		// Channel 0 Interrupt mask
		T1CCTL0_CMP = $38;
		T1CCTL0_CMP0 = $08;
		T1CCTL0_CMP1 = $10;
		T1CCTL0_CMP2 = $20;
		T1CCTL0_MODE = $04;		// Capture or compare mode
		T1CCTL0_CAP = $03;
		T1CCTL0_CAP0 = $01;
		T1CCTL0_CAP1 = $02;

		T1C0_SET_ON_CMP = $00 SHL 3;		// Clear output on compare-up set on 0
		T1C0_CLR_ON_CMP = $01 SHL 3;		// Set output on compare-up clear on 0
		T1C0_TOG_ON_CMP = $02 SHL 3;		// Toggle output on compare
		T1C0_SET_CMP_UP_CLR_0 = $03 SHL 3;		// Clear output on compare
		T1C0_CLR_CMP_UP_SET_0 = $04 SHL 3;		// Set output on compare

		T1C0_NO_CAP = $00;		// No capture
		T1C0_RISE_EDGE = $01;		// Capture on rising edge
		T1C0_FALL_EDGE = $02;		// Capture on falling edge
		T1C0_BOTH_EDGE = $03;		// Capture on both edges

		T1CCTL1_CPSEL = $80;		// Timer 1 channel 1 capture select
		T1CCTL1_IM = $40;		// Channel 1 Interrupt mask
		T1CCTL1_CMP = $38;
		T1CCTL1_CMP0 = $08;
		T1CCTL1_CMP1 = $10;
		T1CCTL1_CMP2 = $20;
		T1CCTL1_MODE = $04;		// Capture or compare mode
		T1CCTL1_DSM_SPD = $04;
		T1CCTL1_CAP = $03;
		T1CCTL1_CAP0 = $01;
		T1CCTL1_CAP1 = $02;

		T1C1_SET_ON_CMP = $00 SHL 3;  // Set output on compare
		T1C1_CLR_ON_CMP = $01 SHL 3;  // Clear output on compare
		T1C1_TOG_ON_CMP = $02 SHL 3;  // Toggle output on compare
		T1C1_SET_CMP_UP_CLR_0 = $03 SHL 3;  // Set output on compare-up clear on 0
		T1C1_CLR_CMP_UP_SET_0 = $04 SHL 3;  // Clear output on compare-up set on 0
		T1C1_SET_C1_CLR_C0 = $05 SHL 3;  // Set when equal to T1CC1, clear when equal to T1CC0
		T1C1_CLR_C1_SET_C0 = $06 SHL 3;  // Clear when equal to T1CC1, set when equal to T1CC0
		T1C1_DSM_MODE= $07 SHL 3;  // DSM mode

		T1C1_NO_CAP = $00;		// No capture
		T1C1_RISE_EDGE = $01;		// Capture on rising edge
		T1C1_FALL_EDGE = $02;		// Capture on falling edge
		T1C1_BOTH_EDGE = $03;		// Capture on both edges

		// IEN2 (0x9A) - Interrupt Enable 2 Register
		IEN2_WDTIE = $20;
		IEN2_P1IE = $10;
		IEN2_UTX1IE = $08;
		IEN2_I2STXIE = $08;
		IEN2_UTX0IE = $04;
		IEN2_P2IE = $02;
		IEN2_USBIE = $02;
		IEN2_RFIE = $01;
		
		// RFIF (0xE9) - RF Interrupt Flags
		RFIF_IRQ_TXUNF = $80;
		RFIF_IRQ_RXOVF = $40;
		RFIF_IRQ_TIMEOUT = $20;
		RFIF_IRQ_DONE = $10;
		RFIF_IRQ_CS = $08;
		RFIF_IRQ_PQT = $04;
		RFIF_IRQ_CCA = $02;
		RFIF_IRQ_SFD = $01;

		// RFST (0xE1) - RF Strobe Commands
		RFST_SFSTXON = $00;
		RFST_SCAL = $01;
		RFST_SRX = $02;
		RFST_STX = $03;
		RFST_SIDLE = $04;
		RFST_SNOP = $05;

		// 0xDF3B: MARCSTATE - Main Radio Control State Machine State
		MARCSTATE_MARC_STATE = $1F;

		MARC_STATE_SLEEP = $00;
		MARC_STATE_IDLE = $01;
		MARC_STATE_VCOON_MC = $03;
		MARC_STATE_REGON_MC = $04;
		MARC_STATE_MANCAL = $05; 
		MARC_STATE_VCOON = $06;
		MARC_STATE_REGON = $07;
		MARC_STATE_STARTCAL = $08;
		MARC_STATE_BWBOOST = $09;
		MARC_STATE_FS_LOCK = $0A;
		MARC_STATE_IFADCON = $0B;
		MARC_STATE_ENDCAL = $0C;
		MARC_STATE_RX = $0D;
		MARC_STATE_RX_END = $0E;
		MARC_STATE_RX_RST = $0F;
		MARC_STATE_TXRX_SWITCH = $10;
		MARC_STATE_RX_OVERFLOW = $11;
		MARC_STATE_FSTXON = $12;
		MARC_STATE_TX = $13;
		MARC_STATE_TX_END = $14;
		MARC_STATE_RXTX_SWITCH = $15;
		MARC_STATE_TX_UNDERFLOW = $16;
		S1CON_RFIF_1 = $02;
		S1CON_RFIF_0 = $01;

	VAR
		PERCFG : uint8_t ABSOLUTE $F1; VOLATILE; // PERCFG (0xF1) - Peripheral Control
		P0SEL : uint8_t ABSOLUTE $F3; VOLATILE; // P0SEL (0xF3) - Port 0 Function Select (bit 7 not used)
		P1SEL : uint8_t ABSOLUTE $F4; VOLATILE; // P1SEL (0xF4) - Port 1 Function Select
		P2SEL : uint8_t ABSOLUTE $F5; VOLATILE; // P2SEL (0xF5) - Port 2 Function Select
		U1CSR : uint8_t ABSOLUTE $F8; VOLATILE; // U1CSR (0xF8) - USART 1 Control and Status - bit accessible SFR register
		U1BAUD : uint8_t ABSOLUTE $FA; VOLATILE;		// U1BAUD (0xFA) - USART 1 Baud Rate Control
		U1GCR : uint8_t ABSOLUTE $FC; VOLATILE;		// U1GCR (0xFC) - USART 1 Generic Control
		PCON : uint8_t ABSOLUTE $87; VOLATILE;		// PCON (0x87) - Power Mode Control
		SLEEP : uint8_t ABSOLUTE $BE; VOLATILE;		// SLEEP (0xBE) - Sleep Mode Control
		CLKCON : uint8_t ABSOLUTE $C6; VOLATILE;		// CLKCON (0xC6) - Clock Control
		T1CTL : uint8_t ABSOLUTE $E4; VOLATILE;		// T1CTL (0xE4) - Timer 1 Control and Status
		T1CCTL0 : uint8_t ABSOLUTE $E5; VOLATILE;		// T1CCTL0 (0xE5) - Timer 1 Channel 0 Capture/Compare Control
		T1CC0H : uint8_t ABSOLUTE $DB; VOLATILE;		// T1CC0H (0xDB) - Timer 1 Channel 0 Capture/Compare Value High
		T1CC0L : uint8_t ABSOLUTE $DA; VOLATILE;		// T1CC0L (0xDA) - Timer 1 Channel 0 Capture/Compare Value Low
		T1CCTL1 : uint8_t ABSOLUTE $E6; VOLATILE;		// T1CCTL1 (0xE6) - Timer 1 Channel 1 Capture/Compare Control

		TCON : uint8_t ABSOLUTE $88; VOLATILE; // TCON (0x88) - CPU Interrupt Flag 1 - bit accessible SFR register
		S0CON : uint8_t ABSOLUTE $98; VOLATILE; // S0CON (0x98) - CPU Interrupt Flag 2 - bit accessible SFR register
		S1CON : uint8_t ABSOLUTE $9B; VOLATILE; // S1CON (0x9B) - CPU Interrupt Flag 3
	
IMPLEMENTATION

END.