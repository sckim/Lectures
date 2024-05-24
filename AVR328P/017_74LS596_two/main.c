/*
 * main.c
 *
 *  Created on: 2017. 11. 16.
 *      Author: Soochan Kim
 */
#include <avr/io.h>
#include <util/delay.h>
#include "74LS575.h"

int main(void) {
	uint8_t led_pattern[8] = { 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };

	//Initialize HC595 system

	HC595Init();

	while (1) {
		for (uint8_t i = 0; i < 8; i++) {
			//HC595Write(led_pattern[i]);   //Write the data to HC595
			shiftOut(led_pattern[i], MSBFIRST);
			_delay_ms(100);                 //Wait

		}
	}
	return 1;
}

