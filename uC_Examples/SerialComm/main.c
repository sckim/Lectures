/*
* Library�� �̿��� �ø��� ���
*
*/

#define F_CPU 16000000UL

#include <avr/io.h>
#include <stdio.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "uart.h"

void uart_printf(char data, FILE * stream)
{
	uart_putc(data);
}

unsigned char uart_scanf(FILE * stream)
{
	return uart_getc();
}

//���ο� standard io�� �����Ѵ�.
static FILE std_output = FDEV_SETUP_STREAM(uart_printf, NULL, _FDEV_SETUP_WRITE);
static FILE std_input = FDEV_SETUP_STREAM(NULL, uart_scanf, _FDEV_SETUP_READ);

int main(void) {
	char recieved_byte;
	char text[] =
	"\r\nWelcome! Serial communication world!!\r\n Good Luck\r\n";
	char echo[] = "HKNU >> ";

	//stdout�� stdin�� ����ڰ� ������ �Լ��� ����
	//�Ʒ� 2���� main �Լ� �ۿ� �ۼ��ϸ� ������ �߻��ϹǷ� ����
	stdout = &std_output;
	stdin = &std_input;

	uart_init(UART_BAUD_SELECT(9600, 16000000L));
	sei();

	printf("%s", text);

//	uart_puts(echo);
	printf("%s", echo);

	for (;;) {
		scanf("%c", &recieved_byte);
		_delay_ms(50);
		//uart_putc(recieved_byte);
		if( recieved_byte==0x0D)
			printf("\r\n%s", echo);
		else if (recieved_byte!=0)
			printf("%c", recieved_byte);

	}
	return 0; // never reached
}
