/*
 * Library를 이용한 시리얼 통신
 *
 */
#include <avr/io.h>
#include <stdio.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "uart.h"

int main(void) {
	char recieved_byte;
	char text[] =
			"\r\nWelcome! Serial communication world!!\r\n Good Luck\r\n";
	char echo[] = "HKNU >> ";
	int i;

	uart_init(UART_BAUD_SELECT(9600, 16000000L));
	sei();
	i = 0;
	while (text[i] != '\0') {
		uart_putc(text[i++]);
	}

	uart_puts(echo);
//	while (echo[i] != '\0') {
//		USART_Transmit(echo[i++]);
//	}

	for (;;) {
		recieved_byte = uart_getc();
		_delay_ms(50);
		uart_putc(recieved_byte);
		if( recieved_byte==0x0D)
			uart_puts(echo);
	}
	return 0; // never reached
}
