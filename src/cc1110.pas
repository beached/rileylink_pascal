UNIT cc1110;
{$XDATA}

INTERFACE

USES CStdInt;

CONST
	BIT0 = $1;
	BIT1 = $2;
	BIT2 = $4;
	BIT3 = $8;
	BIT4 = $10;
	BIT5 = $20;
	BIT6 = $40;
	BIT7 = $80;
	
	{ ------------------------------------------------------------------------------------------------
	*                                        Interrupt Vectors
	* ------------------------------------------------------------------------------------------------
	*}
	
	 RFTXRX_VECTOR = 0;    {  RF TX done / RX ready                       }
	 ADC_VECTOR = 1;    {  ADC End of Conversion                       }
	 URX0_VECTOR = 2;    {  USART0 RX Complete                          }
	 URX1_VECTOR = 3;    {  USART1 RX Complete                          }
	 ENC_VECTOR = 4;    {  AES Encryption/Decryption Complete          }
	 ST_VECTOR = 5;    {  Sleep Timer Compare                         }
	 P2INT_VECTOR = 6;    {  Port 2 Inputs                               }
	 UTX0_VECTOR = 7;    {  USART0 TX Complete                          }
	 DMA_VECTOR = 8;    {  DMA Transfer Complete                       }
	 T1_VECTOR = 9;    {  Timer 1 (16-bit) Capture/Compare/Overflow   }
	 T2_VECTOR = 10;   {  Timer 2 (MAC Timer) Overflow                }
	 T3_VECTOR = 11;   {  Timer 3 (8-bit) Capture/Compare/Overflow    }
	 T4_VECTOR = 12;   {  Timer 4 (8-bit) Capture/Compare/Overflow    }
	 P0INT_VECTOR = 13;   {  Port 0 Inputs                               }
	 UTX1_VECTOR = 14;   {  USART1 TX Complete                          }
	 P1INT_VECTOR = 15;   {  Port 1 Inputs                               }
	 RF_VECTOR = 16;   {  RF General Interrupts                       }
	 WDT_VECTOR = 17;   {  Watchdog Overflow in Timer Mode             }

VAR
	{* ----------------------------------------------------------------------------------------------
	*						Xdata Radio Registers
	* -----------------------------------------------------------------------------------------------
	*}
	MDMCTRL0H : uint8_t XDATA ABSOLUTE $DF02; VOLATILE;
	SYNC1 : uint8_t XDATA ABSOLUTE $DF00; VOLATILE; // Sync word, high byte	
	SYNC0 : uint8_t XDATA ABSOLUTE $DF01; VOLATILE; // Sync word, low byte	
	PKTLEN : uint8_t XDATA ABSOLUTE $DF02; VOLATILE; // Packet length	 
	PKTCTRL1 : uint8_t XDATA ABSOLUTE $DF03; VOLATILE; // Packet automation control	
	PKTCTRL0 : uint8_t XDATA ABSOLUTE $DF04; VOLATILE; // Packet automation control	
	ADDR : uint8_t XDATA ABSOLUTE $DF05; VOLATILE; // Device address	 
	CHANNR : uint8_t XDATA ABSOLUTE $DF06; VOLATILE; // Channel number	 
	FSCTRL1 : uint8_t XDATA ABSOLUTE $DF07; VOLATILE; // Frequency synthesizer control	
	FSCTRL0 : uint8_t XDATA ABSOLUTE $DF08; VOLATILE; // Frequency synthesizer control	
	FREQ2 : uint8_t XDATA ABSOLUTE $DF09; VOLATILE; // Frequency control word, high byte  
	FREQ1 : uint8_t XDATA ABSOLUTE $DF0A; VOLATILE; // Frequency control word, middle byte  
	FREQ0 : uint8_t XDATA ABSOLUTE $DF0B; VOLATILE; // Frequency control word, low byte  
	MDMCFG4 : uint8_t XDATA ABSOLUTE $DF0C; VOLATILE; // Modem configuration	
	MDMCFG3 : uint8_t XDATA ABSOLUTE $DF0D; VOLATILE; // Modem configuration	
	MDMCFG2 : uint8_t XDATA ABSOLUTE $DF0E; VOLATILE; // Modem configuration	
	MDMCFG1 : uint8_t XDATA ABSOLUTE $DF0F; VOLATILE; // Modem configuration	
	MDMCFG0 : uint8_t XDATA ABSOLUTE $DF10; VOLATILE; // Modem configuration	
	DEVIATN : uint8_t XDATA ABSOLUTE $DF11; VOLATILE; // Modem deviation setting	
	MCSM2 : uint8_t XDATA ABSOLUTE $DF12; VOLATILE; // Main Radio Control State Machine configuration 
	MCSM1 : uint8_t XDATA ABSOLUTE $DF13; VOLATILE; // Main Radio Control State Machine configuration 
	MCSM0 : uint8_t XDATA ABSOLUTE $DF14; VOLATILE; // Main Radio Control State Machine configuration 
	FOCCFG : uint8_t XDATA ABSOLUTE $DF15; VOLATILE; // Frequency Offset Compensation configuration 
	BSCFG : uint8_t XDATA ABSOLUTE $DF16; VOLATILE; // Bit Synchronization configuration  
	AGCCTRL2 : uint8_t XDATA ABSOLUTE $DF17; VOLATILE; // AGC control	 
	AGCCTRL1 : uint8_t XDATA ABSOLUTE $DF18; VOLATILE; // AGC control	 
	AGCCTRL0 : uint8_t XDATA ABSOLUTE $DF19; VOLATILE; // AGC control	 
	FREND1 : uint8_t XDATA ABSOLUTE $DF1A; VOLATILE; // Front end RX configuration	
	FREND0 : uint8_t XDATA ABSOLUTE $DF1B; VOLATILE; // Front end TX configuration	
	FSCAL3 : uint8_t XDATA ABSOLUTE $DF1C; VOLATILE; // Frequency synthesizer calibration  
	FSCAL2 : uint8_t XDATA ABSOLUTE $DF1D; VOLATILE; // Frequency synthesizer calibration  
	FSCAL1 : uint8_t XDATA ABSOLUTE $DF1E; VOLATILE; // Frequency synthesizer calibration  
	FSCAL0 : uint8_t XDATA ABSOLUTE $DF1F; VOLATILE; // Frequency synthesizer calibration  
	_XREGDF20 : uint8_t XDATA ABSOLUTE $DF20; VOLATILE; // reserved	 
	_XREGDF21 : uint8_t XDATA ABSOLUTE $DF21; VOLATILE; // reserved	 
	_XREGDF22 : uint8_t XDATA ABSOLUTE $DF22; VOLATILE; // reserved	 
	TEST2 : uint8_t XDATA ABSOLUTE $DF23; VOLATILE; // Various test settings	
	TEST1 : uint8_t XDATA ABSOLUTE $DF24; VOLATILE; // Various test settings	
	TEST0 : uint8_t XDATA ABSOLUTE $DF25; VOLATILE; // Various test settings	
	_XREGDF26 : uint8_t XDATA ABSOLUTE $DF26; VOLATILE; // reserved	 
	PA_TABLE7 : uint8_t XDATA ABSOLUTE $DF27; VOLATILE; // PA power setting 7	
	PA_TABLE6 : uint8_t XDATA ABSOLUTE $DF28; VOLATILE; // PA power setting 6	
	PA_TABLE5 : uint8_t XDATA ABSOLUTE $DF29; VOLATILE; // PA power setting 5	
	PA_TABLE4 : uint8_t XDATA ABSOLUTE $DF2A; VOLATILE; // PA power setting 4	
	PA_TABLE3 : uint8_t XDATA ABSOLUTE $DF2B; VOLATILE; // PA power setting 3	
	PA_TABLE2 : uint8_t XDATA ABSOLUTE $DF2C; VOLATILE; // PA power setting 2	
	PA_TABLE1 : uint8_t XDATA ABSOLUTE $DF2D; VOLATILE; // PA power setting 1	
	PA_TABLE0 : uint8_t XDATA ABSOLUTE $DF2E; VOLATILE; // PA power setting 0	
	IOCFG2 : uint8_t XDATA ABSOLUTE $DF2F; VOLATILE; // Radio Test Signal Configuration (P1_7  
	IOCFG1 : uint8_t XDATA ABSOLUTE $DF30; VOLATILE; // Radio Test Signal Configuration (P1_6  
	IOCFG0 : uint8_t XDATA ABSOLUTE $DF31; VOLATILE; // Radio Test Signal Configuration (P1_5  
	_XREGDF32 : uint8_t XDATA ABSOLUTE $DF32; VOLATILE; // reserved	 
	_XREGDF33 : uint8_t XDATA ABSOLUTE $DF33; VOLATILE; // reserved	 
	_XREGDF34 : uint8_t XDATA ABSOLUTE $DF34; VOLATILE; // reserved	 
	_XREGDF35 : uint8_t XDATA ABSOLUTE $DF35; VOLATILE; // reserved	 
	PARTNUM : uint8_t XDATA ABSOLUTE $DF36; VOLATILE; // Chip ID [15:8]	 
	VERSION : uint8_t XDATA ABSOLUTE $DF37; VOLATILE; // Chip ID [7:0]	 
	FREQEST : uint8_t XDATA ABSOLUTE $DF38; VOLATILE; // Frequency Offset Estimate	
	LQI : uint8_t XDATA ABSOLUTE $DF39; VOLATILE; // Link Quality Indicator	
	RSSI : uint8_t XDATA ABSOLUTE $DF3A; VOLATILE; // Received Signal Strength Indication  
	MARCSTATE : uint8_t XDATA ABSOLUTE $DF3B; VOLATILE; // Main Radio Control State	
	PKTSTATUS : uint8_t XDATA ABSOLUTE $DF3C; VOLATILE; // Packet status	 
	VCO_VC_DAC : uint8_t XDATA ABSOLUTE $DF3D; VOLATILE; // PLL calibration current

	IEN1 : uint8_t DATA ABSOLUTE $B8; VOLATILE;			 // Interrupt Enable 1
	TIMIF : uint8_t ABSOLUTE $D8; VOLATILE;	 // Timers 1/3/4 Interrupt Mask/Flag
	RFST : uint8_t ABSOLUTE $E1; VOLATILE; // RF Strobe Commands
	T1CNTL : uint8_t ABSOLUTE $E2; VOLATILE; // Timer 1 Counter Low
	T1CNTH : uint8_t ABSOLUTE $E3; VOLATILE; // Timer 1 Counter High
	T1CTL : uint8_t ABSOLUTE $E4; VOLATILE; // Timer 1 Control and Status
	T1CCTL0 : uint8_t ABSOLUTE $E5; VOLATILE; // Timer 1 Channel 0 Capture/Compare Control
	T1CCTL1 : uint8_t ABSOLUTE $E6; VOLATILE; // Timer 1 Channel 1 Capture/Compare Control
	T1CCTL2 : uint8_t ABSOLUTE $E7; VOLATILE; // Timer 1 Channel 2 Capture/Compare Control

	
	T3OVFIF : Boolean ABSOLUTE $D8.0; VOLATILE; // Timer 3 overflow interrupt flag 0:no pending 1:pending
	T3CH0IF : Boolean ABSOLUTE $D8.1; VOLATILE; // Timer 3 channel 0 interrupt flag 0:no pending 1:pending
	T3CH1IF : Boolean ABSOLUTE $D8.2; VOLATILE; // Timer 3 channel 1 interrupt flag 0:no pending 1:pending
	T4OVFIF : Boolean ABSOLUTE $D8.3; VOLATILE; // Timer 4 overflow interrupt flag 0:no pending 1:pending
	T4CH0IF : Boolean ABSOLUTE $D8.4; VOLATILE; // Timer 4 channel 0 interrupt flag 0:no pending 1:pending
	T4CH1IF : Boolean ABSOLUTE $D8.5; VOLATILE; // Timer 4 channel 1 interrupt flag 0:no pending 1:pending
	OVFIM : Boolean ABSOLUTE $D8.6; VOLATILE; // Timer 1 overflow interrupt mask

	IRCON : uint8_t ABSOLUTE $C0; VOLATILE; // Interrupt Flags 4
	DMAIF : Boolean ABSOLUTE $C0.0; VOLATILE; // DMA Complete Interrupt Flag
	T1IF : Boolean ABSOLUTE $C0.1; VOLATILE; // Timer 1 Interrupt Flag
	T2IF : Boolean ABSOLUTE $C0.2; VOLATILE; // Timer 2 Interrupt Flag
	T3IF : Boolean ABSOLUTE $C0.3; VOLATILE; // Timer 3 Interrupt Flag
	T4IF : Boolean ABSOLUTE $C0.4; VOLATILE; // Timer 4 Interrupt Flag
	P0IF : Boolean ABSOLUTE $C0.5; VOLATILE; // Port 0 Interrupt Flag
	STIF : Boolean ABSOLUTE $C0.7; VOLATILE; // Sleep Timer Interrupt Flag

	IEN0 : uint8_t ABSOLUTE $A8; VOLATILE; // Interrupt Enable 0
	RFTXRXIE : Boolean ABSOLUTE $A8.0; VOLATILE; // RF TX/RX FIFO interrupt enable
	ADCIE : Boolean ABSOLUTE $A8.1; VOLATILE; // ADC Interrupt Enable
	URX0IE : Boolean ABSOLUTE $A8.2; VOLATILE; // USART0 RX Interrupt Enable
	URX1IE : Boolean ABSOLUTE $A8.3; VOLATILE; // USART1 RX Interrupt Enable
	ENCIE : Boolean ABSOLUTE $A8.4; VOLATILE; // AES Encryption/Decryption Interrupt Enable
	STIE : Boolean ABSOLUTE $A8.5; VOLATILE; // Sleep Timer Interrupt Enable
	EA : Boolean ABSOLUTE $A8.7; VOLATILE; // Global Interrupt Enable

	IEN2 : uint8_t ABSOLUTE $9A; VOLATILE; // Interrupt Enable 2
	RFIM : uint8_t ABSOLUTE $91; VOLATILE; // RF Interrupt Mask

	TCON : uint8_t ABSOLUTE $88; VOLATILE; // Interrupt Flags
	IT0 : Boolean ABSOLUTE $88.0; VOLATILE; // reserved (must always be set to 1; VOLATILE
	RFTXRXIF : Boolean ABSOLUTE $88.1; VOLATILE; // RFERR – RF TX/RX FIFO interrupt flag
	IT1 : Boolean ABSOLUTE $88.2; VOLATILE; // reserved (must always be set to 1; VOLATILE
	URX0IF : Boolean ABSOLUTE $88.3; VOLATILE; // USART0 RX Interrupt Flag
	ADCIF : Boolean ABSOLUTE $88.5; VOLATILE; // ADC Interrupt Flag
	URX1IF : Boolean ABSOLUTE $88.7; VOLATILE; // USART1 RX Interrupt Flag

	U1DBUF : uint8_t ABSOLUTE $F9; VOLATILE; // USART 1 Receive/Transmit Data Buffer
	U1BAUD : uint8_t ABSOLUTE $FA; VOLATILE; // USART 1 Baud Rate Control
	U1UCR : uint8_t ABSOLUTE $FB; VOLATILE; // USART 1 UART Control
	U1GCR : uint8_t ABSOLUTE $FC; VOLATILE; // USART 1 Generic Control
	P0DIR : uint8_t ABSOLUTE $FD; VOLATILE; // Port 0 Direction
	P1DIR : uint8_t ABSOLUTE $FE; VOLATILE; // Port 1 Direction
	P2DIR : uint8_t ABSOLUTE $FF; VOLATILE; // Port 2 Direction

	WDCTL : uint8_t ABSOLUTE $C9; VOLATILE; // Watchdog Timer Control
	RFD : uint8_t ABSOLUTE $D9; VOLATILE;	// RF Data
	RFIF : uint8_t ABSOLUTE $E9; VOLATILE; // RF Interrupt Flags

IMPLEMENTATION

END.