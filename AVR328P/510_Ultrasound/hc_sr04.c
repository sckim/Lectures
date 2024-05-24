/*
 * Measure distance using HC SR04 sensor
 * S.C. Kim
 *
 * 2017.11.28
 */
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>
#include <avr/interrupt.h>
#include "uart.h"
#include "timer1.h"

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

#define LED_PORT                PORTB
#define LED_PIN                 PINB
#define LED_DDR                 DDRB

#define PinPort            PORTD
#define PinIn              PIND
#define PinDirection       DDRD
#define BUTTON             PD2

char str[80];

//새로운 standard io를 지정한다.
static FILE std_output = FDEV_SETUP_STREAM(uart_putc, NULL, _FDEV_SETUP_WRITE);

int main(void) {
	uint16_t duration;
	double	distance;

	// -------- Inits --------- //
	stdout = &std_output;
	uart_init(UART_BAUD_SELECT(9600, 16000000L));
	sei();	// set Fast PWM mode using ICR1 as TOP

	Timer1Prescaler(64);	 // 16MHz/64 => 1 step = 4us


	sbi(LED_DDR, PB5);			// Trigger
	cbi(PinDirection, BUTTON);	// Echo

	printf("\r\nGet Distance using HC_SR04\r\n");
	printf("---------------\r\n");

	// ------ Event loop ------ //
	while (1) {
		// Generate Trigger signal
		cbi(LED_PORT, PB5);
		_delay_us(100);
		sbi(LED_PORT, PB5);
		_delay_us(15);
		cbi(LED_PORT, PB5);

		// Find the rising edge of echo signal
		loop_until_bit_is_set(PinIn, BUTTON);
		TCNT1 = 0; /* reset counter */

		// Find falling edge
		loop_until_bit_is_clear(PinIn, BUTTON);
		duration = TCNT1 * 4;  // 1clock = 4us because of using /64 clock source

		// 340m/sec = 0.034/usec
		// (t/2)*0.034 = t*0.017

		printf("\r\nTime: %d[usec]", duration );
		distance = (duration * 0.017);
		if (distance >= 400 || distance <= 2) {
			printf("\r\nOut of range\r\n");
		} else {
			printf(", Distance: %4.1f[cm]\n", distance);
		}

		_delay_ms(1000);

	} /* End event loop */
	return 0; /* This line is never reached */
}
