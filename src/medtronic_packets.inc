{
 Define the Medtronic Packet Structures
}
USES CStdInt;

TYPE
	packet_header_t = RECORD
		type_id : uint8_t;
		device_id : ARRAY[1..4] OF uint8_t;
	END;

	packet_enlite_t = RECORD
		header : packet_header_t;  { type_id is always AA }				
		version : uint8_t;
		unknown0 : uint8_t;
		isig_adjustment : uint8_t;
		sequence_number : uint8_t;
		recent_isig : ARRAY[1..4] OF uint8_t;
		unknown1 : uint8_t;
		unknown2 : uint8_t;
		unknown3 : uint8_t;
		battery_level : uint8_t;
		past_isig : ARRAY[1..14] OF uint8_t;
		crc16 : uint16_t;
	END;
		
	packet_glucometre_t = RECORD
		header : packet_header_t;  { type_id is always A5 }
		glucose_value : uint16_t; { probably in mg/dl }
		crc8 : uint8_t;															   
	END;
