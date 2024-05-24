/*
 * Allfunction.c
 *
 *  Created on: 2019. 7. 2.
 *      Author: Soochan Kim
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "pins.h"
#include "gpio.h"
#include "uart.h"
#include "adc.h"

static FILE std_inout = FDEV_SETUP_STREAM(uart_printf, uart_scanf, _FDEV_SETUP_RW);

void menu(void) {
	puts("\r===================");
	puts("\r     Main Menu     ");
	puts("\r-------------------");
	puts("\r1. Check GPIO");
	puts("\r2. LCD");
	puts("\r3. ADC");
	puts("\r4. Timer");
	puts("\r5. PWM");
	puts("\r6. SPI");
	puts("\r7. I2C");
	puts("\r8. EEPROM");
	puts("\rQ. Exit");
}

void checkADC(void)
{
	uint16_t	adc_value;
	char recieved_byte=0;

	while(recieved_byte!='q'){
		for( int i=0; i<8; i++){
			adc_value = adc_read(i);
			printf("\rADC[%d] = %d, %f[V]", i, adc_value, adc_value*(5.0/1024.0));
		}
		printf("\rPress Q to exit this loop");
		_delay_ms(2000);
		if (uart_available()>= 0 )
			scanf("%c", &recieved_byte);
	}
}

int main(void) {
	char recieved_byte;

	stdout = stdin = &std_inout;

	//checkGPIO();

	uart_init(UART_BAUD_SELECT(9600, 16000000L));
	// UART가 인터럽트 방식을 사용하므로 반드시 globral interrupt를 enable해야 한다.
	sei();

	while (1) {
		menu();
		printf("\rChoose menu : ");

		// wait keyinput
		while(uart_available()<=0);

		scanf("%c", &recieved_byte);
		printf("%c\n", recieved_byte);
		_delay_ms(200);
		switch (recieved_byte) {
		case '1': // GPIO
			checkGPIO();
				;
			break;
		case '2':
			;
			//GetString();
			break;
		case '3':
			adc_init();
			checkADC();
				;
			break;
		case 'q':
		case 'Q':
			puts("\nGood Main\n");
			return 0;
		default:
			printf("\n");
		}
	}

	return 0; // never reached
}

