UNIT minimed_rf;
{$XDATA}

INTERFACE
	USES Sys_CC1010, cc1110, crc, medtronic_4b6b, CStdInt, io_ccxx10_bitdef;
 
	TYPE
		Packet = RECORD
			data_start_idx : size_t;
			length : uint8_t;
			packet_rssi : uint8_t;
			packet_number : uint8_t;
		END;

		symbol_buffer_t = RECORD
			bit_count : uint8_t;
			buffer : uint16_t;
		END;

		minimed_state_t = RECORD
			spi_mode : uint8_t;
			rx_channel : uint8_t;
			tx_channel : uint8_t;
			buffer_write_pos : size_t;
			data_buffer_bytes_used : uint16_t;
			packet_number: uint8_t;
			packet_count: size_t;
			packet_head_idx : size_t;
			packet_tail_idx : size_t;
			// Packet sending counters
			last_error : uint8_t;
			packet_overflow_count : uint8_t;
			buffer_overflow_count : uint8_t;
			radio_output_buffer_write_pos : size_t;
			radio_output_buffer_read_pos : size_t;
			radio_output_buffer_data_length : size_t;
			receive_radio_symbol_output_buffer : symbol_buffer_t;
			receive_radio_symbol_input_buffer : symbol_buffer_t;
			receive_radio_symbol_error_count : uint8_t;
			data_buffer : ARRAY[0..511] OF uint8_t;
			packets : ARRAY[0..19] OF Packet;
			radio_output_buffer : ARRAY[0..255] OF uint8_t; 
			timer_counter : uint16_t;
			radio_mode : uint8_t;
			last_cmd : uint8_t;
			get_byte_from_radio_buffer_read_pos :size_t;
			get_byte_from_radio_current_packet_bytes_remaining : size_t;
			get_byte_from_radio_sending_packet : ByteBool;
	END;
 
	CONST
		CMD_NOP = 0;
		CMD_GET_CHANNEL = 1;
		CMD_SET_CHANNEL = 2;
		CMD_GET_LENGTH = 3;
		CMD_GET_BYTE = 4;
		CMD_RESET = 5;
		CMD_GET_ERROR = 6;
		CMD_GET_PACKET_NUMBER = 7;
		CMD_SEND_PACKET = 9;
		CMD_GET_RADIO_MODE = 10;
		CMD_GET_PACKET_COUNT = 11;
		CMD_GET_PACKET_HEAD_IDX = 12;
		CMD_GET_PACKET_TAIL_IDX = 13;
		CMD_GET_PACKET_OVERFLOW_COUNT = 14;
		CMD_GET_BUFFER_OVERFLOW_COUNT = 15;
		CMD_GET_RSSI = 16;
		CMD_SET_TX_CHANNEL = 17;

		// Radio Mode
		RADIO_MODE_IDLE = 0;
		RADIO_MODE_RX = 1;
		RADIO_MODE_TX = 2;
					  
		// SPI Mode
		SPI_MODE_CMD = 0;
		SPI_MODE_ARG = 1;
		SPI_MODE_READ = 2;

		// Errors
		ERROR_DATA_BUFFER_OVERFLOW = $50;
		ERROR_TOO_MANY_PACKETS = $51;
		ERROR_RF_TX_OVERFLOW = $52;

		// Resource usage defines
		BUFFER_SIZE = 512;
		MAX_PACKETS = 20;
		MAX_PACKET_SIZE = 73;
					 	 	   
	VAR 
		// RileyLink HW
		GREEN_LED : Boolean ABSOLUTE P0.0; VOLATILE;
		BLUE_LED : Boolean ABSOLUTE P0.1; VOLATILE;
		minimed_rf_state : minimed_state_t;
						 
	PROCEDURE init_minimed_rf( var state : minimed_state_t );
	PROCEDURE enter_tx( var state : minimed_state_t );
	PROCEDURE enter_rx( var state : minimed_state_t );
    PROCEDURE handle_rx0( var state : minimed_state_t );
    {$R-}
	PROCEDURE handle_rx1;
	PROCEDURE handle_rf_txrx( var state : minimed_state_t );
	PROCEDURE handle_rf( var state : minimed_state_t );
	PROCEDURE handle_timer( var state : minimed_state_t );
	PROCEDURE set_rx_channel( var state : minimed_state_t; new_channel : uint8_t );

    { Private }
	PROCEDURE finish_incoming_packet( var state : minimed_state_t );
	PROCEDURE drop_current_packet( var state : minimed_state_t );
	PROCEDURE add_decoded_byte( var state : minimed_state_t; value : uint8_t );
    
IMPLEMENTATION

	PROCEDURE symbol_buffer_reset( var symbol_buffer : symbol_buffer_t );
	BEGIN
		symbol_buffer.bit_count := 0;
		symbol_buffer.buffer := 0;
	END;

	PROCEDURE symbol_buffer_reset_full( var state : minimed_state_t );
	BEGIN
		symbol_buffer_reset( state.receive_radio_symbol_output_buffer );
		symbol_buffer_reset( state.receive_radio_symbol_input_buffer );
		state.receive_radio_symbol_error_count := 0;
	END;

	PROCEDURE receive_radio_symbol( var state : minimed_state_t; value : uint8_t );
	VAR
		symbol : uint8_t XDATA;
		output_symbol : uint8_t;
	BEGIN
		symbol := 0;
		output_symbol := 0;

		IF $00 = value THEN BEGIN
			IF state.packets[state.packet_head_idx].length >= 4 THEN BEGIN
				finish_incoming_packet( state );
				symbol_buffer_reset_full( state );
			END ELSE BEGIN
				drop_current_packet( state );
			END;
			EXIT;
		END ELSE IF state.packets[state.packet_head_idx].length >= 72 THEN BEGIN //largest expected packet length
			drop_current_packet( state );
			EXIT;
		END;

		state.receive_radio_symbol_input_buffer.buffer := (state.receive_radio_symbol_input_buffer.buffer SHL 8) + value;
		inc( state.receive_radio_symbol_input_buffer.bit_count, 8 );

		WHILE state.receive_radio_symbol_input_buffer.bit_count >= 6 DO BEGIN
			symbol := (state.receive_radio_symbol_input_buffer.buffer SHR (state.receive_radio_symbol_input_buffer.bit_count - 6)) AND %00111111;
			dec( state.receive_radio_symbol_input_buffer.bit_count, 6 );
			IF symbol = 0 THEN BEGIN
				CONTINUE;
			END;

			symbol := decode_4b6b_symbol( symbol );
			IF symbol = 16 THEN BEGIN
				inc( state.receive_radio_symbol_error_count );
				BREAK;
			END;
			state.receive_radio_symbol_output_buffer.buffer := (state.receive_radio_symbol_output_buffer.buffer SHL 4) + symbol;
			inc( state.receive_radio_symbol_output_buffer.bit_count, 4 );
		END;
	
		WHILE state.receive_radio_symbol_output_buffer.bit_count >= 8 DO BEGIN
			output_symbol := (state.receive_radio_symbol_output_buffer.buffer SHR (state.receive_radio_symbol_output_buffer.bit_count-8)) AND %11111111;
			dec( state.receive_radio_symbol_output_buffer.bit_count, 8 );
			add_decoded_byte( state, output_symbol );
		END;
		IF (state.receive_radio_symbol_error_count > 0) AND (state.packets[state.packet_head_idx].length > 0) THEN BEGIN
			drop_current_packet( state );
		END;
	END;

	PROCEDURE init_minimed_rf( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN
			last_cmd := CMD_NOP;
			spi_mode := SPI_MODE_CMD;
			buffer_write_pos := 0;
			data_buffer_bytes_used := 0;
			packet_number := 0;
			packet_count := 0;
			packet_head_idx := 0;
			packet_tail_idx := 0;
			last_error := 0;
			packet_overflow_count := 0;
			buffer_overflow_count := 0;
			radio_output_buffer_write_pos := 0;
			radio_output_buffer_read_pos := 0;
			radio_output_buffer_data_length := 0;
			timer_counter := 0;
			packets[0].data_start_idx := 0;
			packets[0].length := 0;
			get_byte_from_radio_buffer_read_pos := 0;
			get_byte_from_radio_current_packet_bytes_remaining := 0;
			get_byte_from_radio_sending_packet := false;
		END;

		set_rx_channel( state, 2 ); 
		symbol_buffer_reset_full( state );
	END; 
 
	FUNCTION get_byte_from_radio( var state : minimed_state_t ) : uint8_t;
	VAR
		rval : uint8_t;
	BEGIN
		rval := 0;
 
		IF state.packet_count > 0 THEN BEGIN		       
			IF NOT( state.get_byte_from_radio_sending_packet ) THEN BEGIN
				WITH state.packets[state.packet_tail_idx] DO BEGIN 													  
					state.get_byte_from_radio_buffer_read_pos := data_start_idx;
					state.get_byte_from_radio_current_packet_bytes_remaining := length;
					state.get_byte_from_radio_sending_packet := true;
   			END;			  		
			END;
 
			IF state.get_byte_from_radio_current_packet_bytes_remaining > 0 THEN BEGIN
				rval := state.data_buffer[state.get_byte_from_radio_buffer_read_pos];
				inc( state.get_byte_from_radio_buffer_read_pos );
				dec( state.get_byte_from_radio_current_packet_bytes_remaining );

				IF state.get_byte_from_radio_current_packet_bytes_remaining = 0 THEN BEGIN
					// Done sending packet
					state.get_byte_from_radio_sending_packet := false;
					dec( state.packet_count );
					inc( state.packet_tail_idx );
					IF state.packet_tail_idx >= MAX_PACKETS THEN BEGIN
						state.packet_tail_idx := 0;
					END; 
				END;
				IF state.get_byte_from_radio_buffer_read_pos >= BUFFER_SIZE THEN BEGIN
					state.get_byte_from_radio_buffer_read_pos := 0;
				END;
				dec( state.data_buffer_bytes_used );
			END ELSE BEGIN
				rval := $88;
			END;
		END ELSE BEGIN
			rval := $99;
		END;
		get_byte_from_radio := rval;
	END; 

	PROCEDURE do_command( var state : minimed_state_t; cmd : uint8_t );
	BEGIN
		state.last_cmd := cmd;
		CASE cmd OF
			CMD_GET_CHANNEL: BEGIN
				U1DBUF := CHANNR;
			END;
			CMD_SET_CHANNEL, CMD_SET_TX_CHANNEL, CMD_SEND_PACKET: BEGIN
				state.spi_mode := SPI_MODE_ARG;
			END;
			CMD_GET_LENGTH: BEGIN
				IF state.packet_count > 0 THEN BEGIN
					U1DBUF := state.packets[state.packet_tail_idx].length; 
				END ELSE BEGIN
					U1DBUF := 0;
				END;
			END;
			CMD_GET_RSSI: BEGIN
				U1DBUF := state.packets[state.packet_tail_idx].packet_rssi;
			END;
			CMD_GET_PACKET_NUMBER: BEGIN
				U1DBUF := state.packets[state.packet_tail_idx].packet_number;
			END;
			CMD_GET_BYTE: BEGIN
				U1DBUF := get_byte_from_radio( state );
			END;
			CMD_RESET: BEGIN
				P1.1 := true; // Red
				EA := true;
				WDCTL := BIT3 OR BIT0;
			END;
			CMD_GET_ERROR: BEGIN
				U1DBUF := state.last_error;
				state.last_error := 0;
			END;
			CMD_GET_RADIO_MODE: BEGIN
				U1DBUF := state.radio_mode;
	  		END;
			CMD_GET_PACKET_COUNT: BEGIN
				U1DBUF := state.packet_count;
			END;
			CMD_GET_PACKET_HEAD_IDX: BEGIN
				U1DBUF := state.packet_head_idx;
			END;
			CMD_GET_PACKET_TAIL_IDX: BEGIN
				U1DBUF := state.packet_tail_idx;
			END;
			CMD_GET_PACKET_OVERFLOW_COUNT: BEGIN
				U1DBUF := state.packet_overflow_count;
			END;
			CMD_GET_BUFFER_OVERFLOW_COUNT: BEGIN
				U1DBUF := state.buffer_overflow_count;
	        END;
			ELSE BEGIN
				U1DBUF := $22; // A marker for bad data
			END;
		END;
	END;

	PROCEDURE set_rx_channel( var state : minimed_state_t; new_channel : uint8_t );
	BEGIN
		state.rx_channel := new_channel; {* why store channel, it's in CHANNR *}
		CHANNR := new_channel;
		RFTXRXIE := false;
	END; 
 
 	{$R-}
	PROCEDURE handle_rx1;
	VAR
		value : uint8_t;
	BEGIN
		WITH minimed_rf_state DO BEGIN
			CASE minimed_rf_state.spi_mode OF 
				SPI_MODE_CMD: do_command( minimed_rf_state, U1DBUF );
				SPI_MODE_ARG: BEGIN
					value := U1DBUF;
					CASE minimed_rf_state.last_cmd OF
						CMD_SET_CHANNEL: BEGIN
							set_rx_channel( minimed_rf_state, value );
							minimed_rf_state.spi_mode := SPI_MODE_CMD;
						END;
						CMD_SET_TX_CHANNEL: BEGIN
							minimed_rf_state.tx_channel := value;
							minimed_rf_state.spi_mode := SPI_MODE_CMD;
						END;
						CMD_SEND_PACKET: BEGIN
							minimed_rf_state.radio_output_buffer_data_length := value;
							minimed_rf_state.spi_mode := SPI_MODE_READ;
						END;
						ELSE BEGIN
							minimed_rf_state.spi_mode := SPI_MODE_CMD; 
						END;
					END; 
				END; 
				SPI_MODE_READ: BEGIN
					minimed_rf_state.radio_output_buffer[minimed_rf_state.radio_output_buffer_write_pos] := U1DBUF;
					IF minimed_rf_state.radio_output_buffer_write_pos = minimed_rf_state.radio_output_buffer_data_length THEN BEGIN
						minimed_rf_state.radio_output_buffer_read_pos := 0;
						// Set radio mode to tx;
						minimed_rf_state.radio_mode := RADIO_MODE_TX;
						RFTXRXIE := false;
						minimed_rf_state.spi_mode := SPI_MODE_CMD;
					END;
				END;
			END;
		END; 
	END;
 
	PROCEDURE drop_current_packet( var state : minimed_state_t );
	BEGIN
		state.buffer_write_pos := state.packets[state.packet_head_idx].data_start_idx;
		dec( state.data_buffer_bytes_used, state.packets[state.packet_head_idx].length );
		state.packets[state.packet_head_idx].length := 0;
		// Disable RFTXRX interrupt, which signals main loop to restart radio.
		RFTXRXIE := false;
	END;
 
	PROCEDURE add_decoded_byte( var state : minimed_state_t; value : uint8_t );
	BEGIN
		IF state.data_buffer_bytes_used < BUFFER_SIZE THEN BEGIN
			state.data_buffer[state.buffer_write_pos] := value;
			inc( state.buffer_write_pos );
			inc( state.data_buffer_bytes_used );
			inc( state.packets[state.packet_head_idx].length );

			IF state.buffer_write_pos >= BUFFER_SIZE THEN BEGIN
				state.buffer_write_pos := 0;
			END;
 
			IF state.packets[state.packet_head_idx].length >= MAX_PACKET_SIZE THEN BEGIN
				drop_current_packet( state );
			END;
		END ELSE BEGIN
			inc( state.buffer_overflow_count );
			drop_current_packet( state );
		END; 
	END;
	
	PROCEDURE finish_incoming_packet( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN	
			WITH packets[packet_head_idx] DO BEGIN
				packet_rssi := RSSI;
				packet_number := packet_number;
				inc( packet_number );
			END;
 
			IF packet_count + 1 >= MAX_PACKETS THEN BEGIN
				last_error := ERROR_TOO_MANY_PACKETS;
				inc( packet_overflow_count );
				drop_current_packet( state );
			END ELSE BEGIN
				inc( packet_count );
				inc( packet_head_idx );
				IF packet_head_idx >= MAX_PACKETS THEN BEGIN
					packet_head_idx := 0;
				END;
				packets[packet_head_idx].data_start_idx := buffer_write_pos;
				packets[packet_head_idx].length := 0;
			END;
			// Disable RFTXRX interrupt, which signals main loop to restart radio.
			RFTXRXIE := true;
		END;
	END;
	
	
	PROCEDURE handle_rf_txrx( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN
			CASE (MARCSTATE AND MARCSTATE_MARC_STATE) OF
				MARC_STATE_RX: BEGIN
					GREEN_LED := NOT( GREEN_LED );
					receive_radio_symbol( state, RFD ); 
	 			END;
				MARC_STATE_TX: BEGIN
					RFD := radio_output_buffer[radio_output_buffer_read_pos];
					inc( radio_output_buffer_read_pos );
					IF radio_output_buffer_read_pos >= radio_output_buffer_data_length THEN BEGIN
						radio_output_buffer_write_pos := 0;
						radio_output_buffer_read_pos := 0;
						radio_output_buffer_data_length := 0;
						radio_mode := RADIO_MODE_RX;
						RFTXRXIE := false;
					END;
				END;												 	
 			END;		   
		END;
	END;
 
	PROCEDURE handle_rx0( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN
		END;	 
	END;
 
	PROCEDURE handle_rf( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN
			S1CON := S1CON AND NOT( $03 ); // Clear CPU interrupt flag
			IF RFIF AND $80 <> 0 THEN BEGIN // TX underflow
				//irq_txunf(); // Handle TX underflow
				RFIF := RFIF AND NOT( $80 ); // Clear module interrupt flag
			END ELSE IF RFIF AND $40 <> 0 THEN BEGIN // RX overflow
				//irq_rxovf(); // Handle RX overflow
				RFIF := RFIF AND NOT( $40 ); // Clear module interrupt flag
			END ELSE IF RFIF AND $20 <> 0 THEN BEGIN // RX timeout
				RFIF := RFIF AND NOT( $20 ); // Clear module interrupt flag
			END;
		END;	 
	END;
 
	PROCEDURE handle_timer( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN
			inc( timer_counter );
			// If > 20 counts, and not in the middle of rx'ing a packet
			IF (timer_counter > 20) AND (packets[packet_head_idx].length = 0) THEN BEGIN
				BLUE_LED := NOT( BLUE_LED );
				RFTXRXIE := false;
				timer_counter := 0;
			END;
		END;	 
	END;
 
	PROCEDURE enter_tx( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN
			// Put radio into TX.
			CHANNR := tx_channel;
			RFTXRXIF := false;
			RFST := RFST_STX;
			// Wait for radio to enter TX
			WHILE (MARCSTATE AND MARCSTATE_MARC_STATE) <> MARC_STATE_TX DO BEGIN
				{ spin }
			END;
				  
			// Wait for radio to leave TX (usually after packet is sent)
			WHILE (MARCSTATE AND MARCSTATE_MARC_STATE) = MARC_STATE_TX DO BEGIN			 
				{ spin }
			END;
		END;	 
	END;

	PROCEDURE enter_rx( var state : minimed_state_t );
	BEGIN
		WITH state DO BEGIN
			// Put radio into RX.
			CHANNR := rx_channel;
			RFST := RFST_SRX;
			
			WHILE (MARCSTATE AND MARCSTATE_MARC_STATE) <> MARC_STATE_RX DO BEGIN
				{ spin }
			END;

			GREEN_LED := NOT( GREEN_LED );

			// minimed code will clear this when wanting to exit RX
			WHILE RFTXRXIE DO BEGIN
				{ spin }
			END;
		END;	 
	END;   
END.
