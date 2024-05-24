#include <avr/io.h>

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

#define LSBFIRST 0
#define MSBFIRST 1

#define dataPort	PORTD
#define dataPin		PORTD2		//DS
#define clockPort	PORTD
#define clockPin	PORTD3		// SH_CP
#define latchPort	PORTD
#define latchPin	PORTD4		// ST_CP

void shiftOut(uint8_t bitOrder, uint8_t val);
void shiftSetup(void);
