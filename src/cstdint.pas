UNIT CStdInt;

INTERFACE
{ Define size based data types to match those in cstdint defines in C++ }
TYPE
	int8_t = ShortInt;
	uint8_t = Byte;
	int16_t = Integer;
	uint16_t = Word;
	int32_t = LongInt;
	size_t = uint16_t;

IMPLEMENTATION

END.			