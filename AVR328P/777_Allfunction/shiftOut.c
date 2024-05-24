/*
 * shiftOut.c
 *
 *  Created on: 2019. 7. 3.
 *      Author: Soochan Kim
 */

#include "shiftout.h"

void shiftOut(uint8_t bitOrder, uint8_t val) {
	uint8_t i;

	for (i = 0; i < 8; i++) {
		if (bitOrder == LSBFIRST)	{
			if(val & (1 << i))
				sbi(dataPort, dataPin);
			else
				cbi(dataPort, dataPin);
		}
		else{
			if(val & (1 << (7 - i)))
				sbi(dataPort, dataPin);
			else
				cbi(dataPort, dataPin);
		}

		sbi(clockPort, clockPin);
		//_delay_ms(100);
		cbi(clockPort, clockPin);
	}
}

void shiftSetup(void)
{
	sbi(DDRD, dataPin);
	sbi(DDRD, clockPin);
	sbi(DDRD, latchPin);
}
