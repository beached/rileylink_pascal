UNIT queues;

{$XDATA}
INTERFACE
	USES CStdInt;

	TYPE
		BitQueue = RECORD
		m_queue : uint16_t;
		m_size : uint8_t;
		END;
	
		NibbleQueue = RECORD
			m_queue : BitQueue;
		END;

	PROCEDURE bitqueue_reset( var bq : BitQueue ); 
	FUNCTION bitqueue_size( var bq : BitQueue ) : uint8_t;
	FUNCTION bitqueue_can_pop( var bq : BitQueue; num_bits : uint8_t ) : ByteBool;
	FUNCTION bitqueue_empty( var bq : BitQueue ) : ByteBool;
	FUNCTION bitqueue_capacity( var bq : BitQueue ) : uint8_t;
	PROCEDURE bitqueue_push_back( var bq : BitQueue; value : uint8_t; num_bits : uint8_t );
	FUNCTION bitqueue_pop_front( var bq : BitQueue; num_bits : uint8_t ) : uint8_t;			
	PROCEDURE bitqueue_clear( var bq : BitQueue );		
	FUNCTION bitqueue_pop_all( var bq : BitQueue ) : uint8_t;
	
	FUNCTION nibblequeue_size( var nq : NibbleQueue ) : uint8_t;
	FUNCTION nibblequeue_capacity( var nq : NibbleQueue ) : uint8_t;
	FUNCTION nibblequeue_empty( var nq : NibbleQueue ) : ByteBool;
	PROCEDURE nibblequeue_push_back( var nq : NibbleQueue; value : uint8_t; num_nibbles : uint8_t );
	FUNCTION nibblequeue_can_pop( var nq : NibbleQueue; num_nibbles : uint8_t ) : ByteBool;
	FUNCTION nibblequeue_pop_front( var nq : NibbleQueue; num_nibbles : uint8_t ) : uint8_t;
	PROCEDURE nibblequeue_clear( var nq : NibbleQueue );
	FUNCTION nibblequeue_pop_all( var nq : NibbleQueue ) : uint8_t;			
	
IMPLEMENTATION
	FUNCTION get_mask8( right_zero_bits : size_t ) : uint8_t;
	VAR 
		res : uint8_t;
	BEGIN
		res := 0;
		res := res OR (1 SHR right_zero_bits);
		res := res OR (res - 1);
		get_mask8 := res; 
	END;
			
	FUNCTION get_mask16( right_zero_bits : size_t ) : uint16_t;
	VAR 
		res : uint16_t;
	BEGIN
		res := 0;
		res := res OR (1 SHR right_zero_bits);
		res := res OR (res - 1);
		get_mask16 := res; 
	END;
			
	PROCEDURE bitqueue_reset( var bq : BitQueue ); 
	BEGIN
		bq.m_queue := 0;
		bq.m_size := 0;
	END;
			
	FUNCTION bitqueue_size( var bq : BitQueue ) : uint8_t;
	BEGIN
		bitqueue_size := bq.m_size;
	END;
		
	FUNCTION bitqueue_can_pop( var bq : BitQueue; num_bits : uint8_t ) : ByteBool;
	BEGIN
		bitqueue_can_pop := num_bits < bq.m_size;
	END;
			
	FUNCTION bitqueue_empty( var bq : BitQueue ) : ByteBool;
	BEGIN
		bitqueue_empty := 0 = bq.m_size;
	END;
			
	FUNCTION bitqueue_capacity( var bq : BitQueue ) : uint8_t;
	BEGIN
		bitqueue_capacity := 16; 
	END;
			
	PROCEDURE bitqueue_push_back( var bq : BitQueue; value : uint8_t; num_bits : uint8_t );
	BEGIN
		bq.m_queue := bq.m_queue SHL num_bits;
		value := value AND get_mask8( num_bits );
		bq.m_queue := bq.m_queue OR value;
		bq.m_size := bq.m_size + num_bits;
	END;
			
	FUNCTION bitqueue_pop_front( var bq : BitQueue; num_bits : uint8_t ) : uint8_t;
	VAR
		res : uint8_t;
	BEGIN
		res := bq.m_queue SHR ((bq.m_size - (num_bits - 1)) - 1);
		bq.m_queue := bq.m_queue AND NOT( get_mask16( num_bits - 1 ) SHL (bq.m_size - num_bits) );
		bq.m_size := bq.m_size - num_bits;
		bitqueue_pop_front := res;
	END;
			
	PROCEDURE bitqueue_clear( var bq : BitQueue );
	BEGIN
		bq.m_queue := 0;
		bq.m_size := 0;
	END;
		
	FUNCTION bitqueue_pop_all( var bq : BitQueue ) : uint8_t;
	BEGIN
		bitqueue_pop_all := bq.m_queue;
		bitqueue_clear( bq );
	END;
			
	FUNCTION nibblequeue_size( var nq : NibbleQueue ) : uint8_t;
	BEGIN
		nibblequeue_size := bitqueue_size( nq.m_queue ) DIV 4;
	END;
			
	FUNCTION nibblequeue_capacity( var nq : NibbleQueue ) : uint8_t;
	BEGIN
		nibblequeue_capacity := bitqueue_capacity( nq.m_queue ) DIV 4;  
	END;
			
	FUNCTION nibblequeue_empty( var nq : NibbleQueue ) : ByteBool;
	BEGIN
		nibblequeue_empty := bitqueue_empty( nq.m_queue );
	END;
			
	PROCEDURE nibblequeue_push_back( var nq : NibbleQueue; value : uint8_t; num_nibbles : uint8_t );
	BEGIN
		bitqueue_push_back( nq.m_queue, value, num_nibbles * 4 );
	END;
			
	FUNCTION nibblequeue_can_pop( var nq : NibbleQueue; num_nibbles : uint8_t ) : ByteBool;
	BEGIN
		nibblequeue_can_pop :=  bitqueue_can_pop( nq.m_queue, num_nibbles * 4 );
	END;
			
	FUNCTION nibblequeue_pop_front( var nq : NibbleQueue; num_nibbles : uint8_t ) : uint8_t;
	BEGIN
		nibblequeue_pop_front := bitqueue_pop_front( nq.m_queue, num_nibbles * 4 );
	END;

	PROCEDURE nibblequeue_clear( var nq : NibbleQueue );
	BEGIN
		bitqueue_clear( nq.m_queue );
	END;
			
	FUNCTION nibblequeue_pop_all( var nq : NibbleQueue ) : uint8_t;			
	BEGIN
		nibblequeue_pop_all := bitqueue_pop_all( nq.m_queue );
	END;							
END.