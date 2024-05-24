#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#include "uart.h"
#include "adc.h"

// 7 segments
#define cSegmentPortDir		DDRD
#define cSegmentPortData	PORTD

char str[80];
char key_input;

void printSegment(unsigned char number) {
	cSegmentPortDir |= 0xF0;
	cSegmentPortData = number << 4;
}

int SegmentPrompt(void) {

	printf("Enter your number [press 'q' to upper menu]: \r\n");
	key_input = getchar();
	printf("%c\r\n", key_input);
	_delay_ms(200);
	if (key_input == 'q') {
		printf("Goodbye segment\r\n");
		return 1;
	}
	printSegment(key_input - 0x30);
	return 0;
}

int GetADC(void) {

	printf("\r\nEnter channel number [press 'q' to upper menu]: ");
	key_input = getchar();
	printf("%c\r\n", key_input);
	_delay_ms(200);
	if (key_input == 'q') {
		printf("\r\nGoodbye ADC");
		return 1;
	}
	key_input -= 0x30;
	printf("\r\nCh[%d] = %d\n", key_input, ReadADC(key_input));
	return 0;
}

void menu(void) {
	printf("\r\n===================");
	printf("\r\n     Main Menu     ");
	printf("\r\n-------------------");
	printf("\r\n1. Display Segment");
	printf("\r\n2. Get ADC");
	printf("\r\n\nQ. Exit");
}

int main(void) {
	InitUART(9600UL);
	InitADC();

	stdout = &uart_output;
	stdin = &uart_input;

	printf("Hello world!\r\n");
	while (1) {
		menu();
		printf("\r\nChoose menu : ");
		key_input = UART_Receive();
		printf("%c\r\n", key_input);
		_delay_ms(200);
		switch (key_input) {
			case '1':
			while (!SegmentPrompt())
			;
			break;
			case '2':
			while (!GetADC())
			;
			break;
			case 'q':
			case 'Q':
			printf("\r\nGood bye, Main");
			printSegment(4);
			return 0;
			default:
			printf("\r\n");
		}
	}
	return 0;
}
