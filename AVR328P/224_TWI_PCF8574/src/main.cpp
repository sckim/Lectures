/*
 * mani.cpp
 *
 *  Created on: 2019. 6. 28.
 *      Author: Soochan Kim
 */

#define F_CPU	16000000UL

#include <avr/io.h>
#include <util/delay.h>
#include "PCF8574.h"

//0x38
PCF8574 PCF_01(0x38);

int main(void) {

	DDRD |= _BV(PD7);

	PCF_01.begin();

	for (int i = 0; i < 8; i++) {
		PCF_01.digitalWrite(i, 0);
		_delay_ms(100);
	}
	for (int i = 0; i < 8; i++) {
		PCF_01.togglePin(i);
		_delay_ms(100);
	}

	PCF_01.digitalWriteAll(0);
	_delay_ms(1000);

	PCF_01.digitalWrite(7, 1);
	_delay_ms(1000);
	
	for (int i = 0; i < 7; i++) {
		PCF_01.shiftRight(1);
		_delay_ms(100);
	}
	for (int i = 0; i < 7; i++) {
		PCF_01.shiftLeft(1);
		_delay_ms(100);
	}
	for (int i = 0; i < 8; i++) {
		PCF_01.toggle8(0xFF);
		_delay_ms(100);
	}

	unsigned char a;

	while (1) {
//		a = PCF_01.digitalReadAll();
//		if (a&0x80)
//			PORTD |= 0x80;
//		else
//			PORTD &= ~0x80;

		a = PCF_01.digitalRead(7);
		if(a)
			PORTD |= 0x80;
		else
			PORTD &= ~0x80;

		_delay_ms(10);
	}

	return 0;
}
