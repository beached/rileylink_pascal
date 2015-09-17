{$M $0,$7FFF,$F000,$0FFF,$0}

PROGRAM RileyLink;

USES Sys_CC1010, io_ccxx10_bitdef, cc1110, minimed_rf, CStdInt;

CONST
	// These values will give a baud rate of approx. 62.5kbps for 26 MHz clock
	SPI_BAUD_M : uint8_t = 59;
	SPI_BAUD_E : uint8_t = 11;
	
PROCEDURE configure_spi;
BEGIN
	PERCFG := (PERCFG AND NOT( PERCFG_U0CFG )) OR PERCFG_U1CFG;

	// Give priority to USART 1 over USART 0 for port 0 pins
	P2DIR := $01;

	// Set pins 2, 3 and 5 as peripheral I/O and pin 4 as GPIO output
	P1SEL := P1SEL OR BIT4 OR BIT5 OR BIT6 OR BIT7;
	P1DIR := P1DIR AND NOT( BIT4 OR BIT5 OR BIT6 OR BIT7 );

	{***************************************************************************
	* Configure SPI
	*}

	// Set USART to SPI mode and Slave mode
	U1CSR := (U1CSR AND NOT( U1CSR_MODE )) OR U1CSR_SLAVE;

	// Set:
	// - mantissa value
	// - exponent value
	// - clock phase to be centered on first edge of SCK period
	// - negative clock polarity (SCK low when idle)
	// - bit order for transfers to LSB first
	U1BAUD := SPI_BAUD_M;
	U1GCR := (U1GCR AND NOT(U1GCR_BAUD_E OR U1GCR_CPOL OR U1GCR_CPHA OR U1GCR_ORDER)) OR SPI_BAUD_E;
END;

PROCEDURE configure_radio;
BEGIN
	// RF settings SoC: CC1110
	SYNC1 := $FF; // sync word, high byte
	SYNC0 := $00; // sync word, low byte
	PKTLEN := $FF; // packet length
	PKTCTRL1 := $00; // packet automation control
	PKTCTRL0 := $00; // packet automation control
	ADDR := $00;
	CHANNR := $02; // channel number
	FSCTRL1 := $06; // frequency synthesizer control
	FSCTRL0 := $00;
	FREQ2 := $23; // frequency control word, high byte
	FREQ1 := $40; // frequency control word, middle byte
	FREQ0 := $78; // frequency control word, low byte
	MDMCFG4 := $69; // modem configuration
	MDMCFG3 := $4A; // modem configuration
	MDMCFG2 := $33; // modem configuration
	MDMCFG1 := $61; // modem configuration
	MDMCFG0 := $84; // modem configuration
	DEVIATN := $15; // modem deviation setting
	MCSM2 := $07;
	MCSM1 := $30;
	MCSM0 := $18; // main radio control state machine configuration
	FOCCFG := $17; // frequency offset compensation configuration
	BSCFG := $6C;
	FSCAL3 := $E9; // frequency synthesizer calibration
	FSCAL2 := $2A; // frequency synthesizer calibration
	FSCAL1 := $00; // frequency synthesizer calibration
	FSCAL0 := $1F; // frequency synthesizer calibration
	PA_TABLE0 := $00; // needs to be explicitly set!
	PA_TABLE1 := $C0; // pa power setting 10 dBm
	AGCCTRL2 := $03;
	AGCCTRL1 := $0;
	AGCCTRL0 := $91;
	FREND1 := $B6;
	FREND0 := $12;
	TEST2 := $81;
	TEST1 := $35;
	TEST0 := $09;
END;

{$R-}
PROCEDURE urx1_isr; INTERRUPT URX1_VECTOR;
BEGIN
	handle_rx1;
END;
		

BEGIN
	// init LEDS
	P0DIR := P0DIR OR $03;

	// Set the system clock source to HS XOSC and max CPU speed,
	// ref. [clk]=>[clk_xosc.c]
	SLEEP := SLEEP AND NOT( SLEEP_OSC_PD );
	
	{$O-}
	WHILE NOT( SLEEP AND SLEEP_XOSC_S <> 0 ) DO BEGIN
		{ spin }
	END;
	
	CLKCON := (CLKCON AND NOT( CLKCON_CLKSPD OR CLKCON_OSC )) OR CLKSPD_DIV_1;

	{$O-}
	WHILE NOT( CLKCON AND CLKCON_OSC ) <> 0 DO BEGIN
		{ spin }
	END;

	SLEEP := SLEEP OR SLEEP_OSC_PD;

	configure_spi;
	configure_radio;

	init_minimed_rf( minimed_rf_state );

	GREEN_LED := false;
	BLUE_LED := false;

	// Configure timer
	T1CTL := $0e;	// TickFreq/128, Free Running
	IEN1 := IEN1 OR $02;		  // Enable Timer 1 interrupts
	/// TIMIF := TIMIF OR OVFIM; // Enable Timer 1 overflow interrupt mask
	OVFIM := TRUE;
	T1CNTL := $00; // Clear counter low
	T1CC0H := $FF;
	T1CC0L := $FF;
	// Set Timer 1 mode
	T1CCTL0 := $44;

	// Clear any pending Timer 1 Interrupt Flag
	IRCON := IRCON AND NOT( $02 );

	// Start Timer 1
	//T1CTL := $0E;

	TCON := TCON AND NOT( BIT3 ); // Clear URX1IF
	URX1IE := TRUE; // Enable URX1IE interrupt

	// Global interrupt enable
	EA := TRUE;

	// Enable General RF IE
	IEN2 := IEN2 OR IEN2_RFIE;

	RFIM := RFIM OR RFIF_IRQ_TXUNF OR RFIF_IRQ_RXOVF OR RFIF_IRQ_TIMEOUT;

	WHILE TRUE DO BEGIN
		// Reset radio
		RFST := RFST_SIDLE;
		{$O-}
		WHILE (MARCSTATE AND MARCSTATE_MARC_STATE) <> MARC_STATE_IDLE DO BEGIN
			{ Spin }
		END;

		// Enable rx/tx interrupt
		RFTXRXIF := false;
		RFTXRXIE := true;

		IF minimed_rf_state.radio_mode = RADIO_MODE_TX THEN BEGIN
			enter_tx( minimed_rf_state );
		END ELSE IF minimed_rf_state.radio_mode = RADIO_MODE_RX THEN BEGIN
			enter_rx( minimed_rf_state );
		END;
	END;	
END.