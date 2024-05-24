#include <avr/io.h>
#include <stdio.h>
#include "uart.h"

#ifndef BAUD
#define BAUD 9600
#endif

#include <util/setbaud.h>

/* http://www.cs.mun.ca/~rod/Winter2007/4723/notes/serial/serial.html */
void InitUART(unsigned long iBaudrate) {

	// UCSRnA �������͸� �ʱ�ȭ��Ų��.
	// 0��° ��Ʈ, �� MPCMn �� 0���� ��Ʈ (USARTn�� ��Ƽ ���μ��� ��Ÿ��� ����)
	UCSR0A = 0x00;

	// UCSRnB �������͸� �̿��Ͽ� �۽� �� ���� ��뼳���� �Ѵ�.
	// Rx, Tx enable
	UCSR0B = (1 << RXEN0) | (1 << TXEN0);

	// 3��°, 4��° ��Ʈ ��Ʈ ��, TXENn (USARTn����� �۽ź� ���� enable) RXENn (USARTn����� ���ź� ���� enable)
	//  2�� ��Ʈ UCSZ02 = 0���� ��Ʈ

	// UCRnC �������͸� �̿��Ͽ� ���(����/�񵿱�), �и�Ƽ���, ������Ʈ,
	// ���� ������ ��Ʈ���� �����Ѵ�.
	// �񵿱� ���, No Parity bit, 1 Stop bit, 8bits
	UCSR0C |= (1 << UCSZ01);
	UCSR0C |= (1 << UCSZ00);

	// See http://wormfood.net/avrbaudcalc.php
	// UBRRnH(L) �������͸� �̿��� �ۼ��� ������Ʈ ����
	UBRR0H = 0x00;
	switch (iBaudrate) {
	case 9600:
		//UBRR0L = 95; // 14.7456 MHz -> 9600 bps
		UBRR0L = 103; // 16 MHz -> 9600 bps
		break;
	case 19200:
		UBRR0L = 47; // 14.7456 MHz -> 19200 bps
		break;
	case 115200:
		//UBRR0L = 7;  // 14.7456 MHz -> 115200 bps
		UBRR0L = 8;  // 16 MHz -> 115200 bps
		break;
	default:
		UBRR0L = 95;
	}
}

void UART_putch(unsigned char data) {
	//�����غ� �� ������ ���
	while ((UCSR0A & (1 << UDRE0)) == 0)
		;
	// while(!(UCSR0A & 0x20)) ;

	UDR0 = data;
}

void UART_putchar(unsigned char data, FILE *stream) {
	if (data == '\n') {
		UART_putchar('\r', stream);
	}
	loop_until_bit_is_set(UCSR0A, UDRE0);

	UDR0 = data;
}

unsigned char UART_getch(void) {
	loop_until_bit_is_set(UCSR0A, RXC0);

	return UDR0;
}

unsigned char UART_getchar(FILE *stream) {
	loop_until_bit_is_set(UCSR0A, RXC0);

	return UDR0;
}

void UART_putString(char *data) {
	while (*data != '\0')
		UART_putch(*data++);
}
// End while( *data != '\0' )

char *UART_getString(void) {
	unsigned char i = 0;
	char key_input;

	do {
		key_input = getchar();
		printf("%c", key_input);
		str[i] = key_input;
		i++;            // -> Skip ?
	} while (key_input != 0x20);
	str[--i] = 0x00;
	puts("");

	return str;
}
