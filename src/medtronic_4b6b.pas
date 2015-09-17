UNIT medtronic_4b6b;
{$XDATA}			
INTERFACE
USES queues, CStdInt;

		FUNCTION decode_4b6b( VAR buffer : ARRAY OF uint8_t; start: size_t; finish : size_t ) : size_t;
		FUNCTION decode_4b6b_symbol( VAR symbol : uint8_t ) : uint8_t;
IMPLEMENTATION
		FUNCTION decode_4b6b_symbol( VAR symbol : uint8_t ) : uint8_t;
		CONST
			radio_symbol_table : ARRAY[0..52] OF uint8_t = ( 
				0,  0,  0,  0,  0,  0,  0,  0, 
				0,  0,  0, 11,  0, 13, 14,  0,
				0,  0,  0,  0,  0,  0,  7,  0, 
				0,  9,  8,  0, 15,  0,  0,  0, 
				0,  0,  0,  3,  0,  5,  6,  0, 
				0,  0, 10,  0, 12,  0,  0,  0, 
				0,  1,  2,  0,  4 );
		BEGIN
			IF symbol > 52 THEN BEGIN 
				decode_4b6b_symbol := 0
			END ELSE BEGIN
				decode_4b6b_symbol := radio_symbol_table[symbol];
			END;
		END;
		
		FUNCTION decode_4b6b( VAR buffer : ARRAY OF uint8_t; start: size_t; finish : size_t ) : size_t;
		VAR
			res : size_t;
			nq : NibbleQueue XDATA;
			bq : BitQueue XDATA;
			n : size_t;
		BEGIN
			res := 0;
			nibblequeue_clear( nq );
			bitqueue_clear( bq );			
			
			FOR n := start TO finish DO BEGIN
				nibblequeue_push_back( nq, buffer[n], 2 );
				bitqueue_push_back( bq, nibblequeue_pop_front( nq, 1 ), 6 );
				bitqueue_push_back( bq, nibblequeue_pop_front( nq, 1 ), 6 );
				WHILE bitqueue_can_pop( bq, 8 ) DO BEGIN
					buffer[res] := bitqueue_pop_front( bq, 8 );
					res := res + 1;
				END;
			END;
					
			IF NOT( bitqueue_empty( bq ) ) THEN BEGIN
				WHILE bitqueue_can_pop( bq, 8 ) DO BEGIN
					buffer[res] := bitqueue_pop_front( bq, 8 );
					res := res + 1;
				END;				
			END;
			
			decode_4b6b := res;
		END;
END.