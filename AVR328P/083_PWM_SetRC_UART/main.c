/*
 * Library를 이용한 시리얼 통신
 *
 */

#define F_CPU 16000000UL

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "uart.h"
#include "timer1.h"

void uart_printf(char data, FILE * stream) {
	uart_putc(data);
}

unsigned char uart_scanf(FILE * stream) {
	return uart_getc();
}

//새로운 standard io를 지정한다.
static FILE std_output = FDEV_SETUP_STREAM(uart_printf, NULL, _FDEV_SETUP_WRITE);
static FILE std_input = FDEV_SETUP_STREAM(NULL, uart_scanf, _FDEV_SETUP_READ);

long map(long x, long in_min, long in_max, long out_min, long out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

int main(void) {
	const char intro[] = "\r\nWelcome! Set RC servo control through UART";
	const char echo[] = "\r\nEnter new deg: ";
	char str[10];

	// Period of PWM
	// 1/16000000 * 64 * 5000 = 20msec
	ICR1 = 5000;

	int deg = 90;  //1msec = 250, 2msec = 500
	char recieved_byte = 0;

	// set Fast PWM mode using ICR1 as TOP
	Timer1Mode(FPWM_ICR1);
	Timer1Prescaler(64);	 // 16MHz/64 => 1 step = 4us

	// set none-inverting mode
	Timer1OutputA(NonInvert);
	Timer1OutputB(NonInvert);

	//stdout과 stdin에 사용자가 정의한 함수로 설정
	//아래 2줄은 main 함수 밖에 작성하면 오류가 발생하므로 주의
	stdout = &std_output;
	stdin = &std_input;

	uart_init(UART_BAUD_SELECT(9600, 16000000L));
	sei();

	printf("%s", intro);
	printf("%s", echo);

	int i = 0;
	//OCR1A = map(deg, 0, 180, 250, 500);
	OCR1A = map(deg, -90, 90, 250, 500);
	for (;;) {
		scanf("%c", &recieved_byte);

		//uart_putc(recieved_byte);
		if (recieved_byte == 0x0D || recieved_byte == 0x20) {
			str[i] = 0x00;
			i = 0;
			deg = atoi(str);
			//if (deg >= 0 && deg <= 180) {
			if (deg >= -90 && deg <= 90) {
				printf("\r\n%d", deg);
				//OCR1A = map(deg, 0, 180, 250, 500);
				OCR1A = map(deg, -90, 90, 125, 625);
				printf("\r\n%d", OCR1A);
			} else {
				printf("\r\nOut of range.");
			}
			printf("%s", echo);
		} else if (recieved_byte != 0) {
			printf("%c", recieved_byte);
			str[i++] = recieved_byte;
		}
	}
	return 0; // never reached
}
