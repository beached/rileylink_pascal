UNIT Crc;
{$XDATA}

INTERFACE
Uses CStdInt;

		FUNCTION crc8( var buffer : ARRAY OF uint8_t; start: size_t; finish : size_t ) : uint8_t;
		FUNCTION crc16( var buffer : ARRAY OF uint8_t; start: size_t; finish : size_t ) : uint16_t;
IMPLEMENTATION
	FUNCTION check_crc( var message : ARRAY OF uint8_t; start : size_t; finish : size_t ) : ByteBool;
	VAR
		crc_pos : size_t;
		calc_crc16 : uint16_t;
	BEGIN
		{ CASE message[start] OF
			$AA, $AB : BEGIN
				crc_pos := length - 2;
				calc_crc16 := crc16( message, 0, crc_pos );
				check_crc := (uint8_t(calc_crc16 AND $00FF) = message[crc_pos+1]) AND (uint8_t(calc_crc16 SHR 8) = message[crc_pos]);
			END;
			ELSE BEGIN
				crc_pos := length - 1;
				check_crc := crc8( message, 0, crc_pos ) = message[crc_pos];
			END; 
		END;
		}
		check_crc := true;
	END;
				
	FUNCTION crc8( var buffer : ARRAY OF uint8_t; start: size_t; finish : size_t ) : uint8_t;
	CONST
		crc8_table : ARRAY[0..255] OF uint8_t = ( 
			$00, $9B, $AD, $36, $C1, $5A, $6C, $F7, $19, $82, $B4, $2F, $D8, $43, $75, $EE, $32, $A9, $9F, 
			$04, $F3, $68, $5E, $C5, $2B, $B0, $86, $1D, $EA, $71, $47, $DC, $64, $FF, $C9, $52, $A5, $3E, 
			$08, $93, $7D, $E6, $D0, $4B, $BC, $27, $11, $8A, $56, $CD, $FB, $60, $97, $0C, $3A, $A1, $4F, 
			$D4, $E2, $79, $8E, $15, $23, $B8, $C8, $53, $65, $FE, $09, $92, $A4, $3F, $D1, $4A, $7C, $E7, 
			$10, $8B, $BD, $26, $FA, $61, $57, $CC, $3B, $A0, $96, $0D, $E3, $78, $4E, $D5, $22, $B9, $8F, 
			$14, $AC, $37, $01, $9A, $6D, $F6, $C0, $5B, $B5, $2E, $18, $83, $74, $EF, $D9, $42, $9E, $05, 
			$33, $A8, $5F, $C4, $F2, $69, $87, $1C, $2A, $B1, $46, $DD, $EB, $70, $0B, $90, $A6, $3D, $CA, 
			$51, $67, $FC, $12, $89, $BF, $24, $D3, $48, $7E, $E5, $39, $A2, $94, $0F, $F8, $63, $55, $CE, 
			$20, $BB, $8D, $16, $E1, $7A, $4C, $D7, $6F, $F4, $C2, $59, $AE, $35, $03, $98, $76, $ED, $DB, 
			$40, $B7, $2C, $1A, $81, $5D, $C6, $F0, $6B, $9C, $07, $31, $AA, $44, $DF, $E9, $72, $85, $1E, 
			$28, $B3, $C3, $58, $6E, $F5, $02, $99, $AF, $34, $DA, $41, $77, $EC, $1B, $80, $B6, $2D, $F1, 
			$6A, $5C, $C7, $30, $AB, $9D, $06, $E8, $73, $45, $DE, $29, $B2, $84, $1F, $A7, $3C, $0A, $91, 
			$66, $FD, $CB, $50, $BE, $25, $13, $88, $7F, $E4, $D2, $49, $95, $0E, $38, $A3, $54, $CF, $F9,
			$62, $8C, $17, $21, $BA, $4D, $D6, $E0, $7B );
	VAR
		n : size_t;
		res : uint8_t;		
	BEGIN
		res := 0;
		FOR n := start TO finish DO BEGIN				
			res := crc8_table[res XOR buffer[n]];
		END;
		crc8 := res;   
	END;

	FUNCTION crc16( var buffer : ARRAY OF uint8_t; start: size_t; finish : size_t ) : uint16_t;
	CONST
		crc16_table : ARRAY[0..255] OF uint16_t = ( 
			$0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241, $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
			$CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40, $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
			$D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40, $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
			$1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641, $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
			$F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240, $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
			$3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41, $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
			$2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41, $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
			$E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640, $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
			$A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240, $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
			$6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41, $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
			$7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41, $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
			$B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640, $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
			$5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241, $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
			$9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40, $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
			$8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40, $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
			$4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641, $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040 );
	VAR
		idx : size_t;
		n : size_t;
		res : uint16_t;
	BEGIN
		res := $FFFF;
		FOR n:= start TO finish DO BEGIN
			idx := (res SHR 8) XOR buffer[n];
			res := (res SHL 8) XOR crc16_table[idx];				 
		END;
		crc16 := res;
	END;
END.