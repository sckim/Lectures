/*************************************
 * Purpose: Timer0을 이용하여 1초마다 overflow
 * interrupt에 의한 LED Shift
 *
 * TIMSK0
 * TCCR0A
 * TCCR0B
 * TCNT0
 *************************************/
#include <avr/io.h>
#include <avr/interrupt.h>

// from TCNT = (CS / 16000000 ) * (256-x) =10msec
// x = time * (16000000/CS)
// 15625*8msec = 125
#define cDelay 256-125

volatile int sec = 0;
volatile int msec8 = 0;

void setup(void) {
	for (int i = 4; i < 8; i++) {
		DDRD |= _BV(i);
		PORTD |= _BV(i);
	}

	DDRB |= _BV(PB5);

	cli();
	// SREG &= ~_BV(7);
	TIMSK0 |= (1 << TOIE0);    // Timer0 오버플로 인터럽트 에이블
	// 인터럽트를 사용할 경우 TIFR0 register의 flag를 인위적으로 조정할 필요가 없다.

	//CS0[2:0]
	TCCR0B |= (1 << CS02);	// Clock/1024
	TCCR0B |= (1 << CS00);	// Clock/1024

	TCNT0 = cDelay;
	sei();
	// SREG |= _BV(7);
}

void loop(void) {
}

void dispSeg(unsigned char ch) {
	PORTD &= 0x0F;
	PORTD |= (ch << 4);
}

ISR (TIMER0_OVF_vect) {
	//background로 처리할 작업들
	TCNT0 = cDelay;

	msec8++;
	PORTB ^= _BV(PB5);
	if (msec8 == 125) {
		msec8 = 0;
		dispSeg(sec++);
	}
	if (sec > 9) {
		sec = 0;
	}
}

int main(void) {
	setup();

	while (1) {
		loop();
	}
}
