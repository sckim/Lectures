/*
 * mani.cpp
 *
 *  Created on: 2019. 6. 28.
 *      Author: Soochan Kim
 */

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "PCF8575.h"

#define F_CPU	16000000UL

extern "C" {
#include "uart.h"
}
//0x38
//20
PCF8574 PCF_01(0x40);

int main(void) {
	FILE std_inout;

	std_inout.put = uart_printf;
	std_inout.get = uart_scanf;
	std_inout.flags = _FDEV_SETUP_RW;

	stdout = stdin = &std_inout;

//checkGPIO();

	uart_init(UART_BAUD_SELECT(9600, 16000000L));
// UART가 인터럽트 방식을 사용하므로 반드시 globral interrupt를 enable해야 한다.
	sei();

	DDRD = 0xFF;
//	DDRC = 0xFF;
//
//	PCF_01.begin();
//
//	PCF_01.digitalWriteAll(0);
//	_delay_ms(1000);
//	PCF_01.digitalWriteAll(0xffff);
//	_delay_ms(1000);
//	PCF_01.digitalWriteAll(0);
//
//	for (int i = 0; i < 16; i++) {
//		PCF_01.digitalWrite(i, 1);
//		_delay_ms(100);
//	}
//	for (int i = 0; i < 8; i++) {
//		PCF_01.toggle16(0xFFFF);
//		_delay_ms(100);
//	}
//	for (int i = 0; i < 16; i++) {
//		PCF_01.digitalWrite(i, 0);
//		_delay_ms(100);
//	}
//
//	PCF_01.digitalWriteAll(1);
//	for (int i = 0; i < 15; i++) {
//		PCF_01.shiftLeft(1);
//		_delay_ms(100);
//	}
//	for (int i = 0; i < 16; i++) {
//		PCF_01.shiftRight(1);
//		_delay_ms(100);
//	}
//	for (int i = 0; i < 16; i++) {
//		PCF_01.toggle16(0xFFFF);
//		_delay_ms(100);
//	}

	uint16_t a;
	while (1) {
		a = PCF_01.digitalReadAll();
		printf("\r\n%X", a);

		PORTD = a>>8;
		_delay_ms(100);
		PORTD = a & 0xFF;
		_delay_ms(100);
	}

	return 0;
}
