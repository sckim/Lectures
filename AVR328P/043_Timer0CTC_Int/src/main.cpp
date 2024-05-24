/*************************************
 *
 * TIMSK
 * TCCR0
 * OCR0A
 *************************************/
#include <avr/io.h>
#include <avr/interrupt.h>

// from TCNT = (CS / 16000000 ) * (256-x) =10msec
// x = time * (16000000/CS)
// 15625*8msec = 125
#define cDelay 125

volatile int sec = 0;
volatile int msec8 = 0;

//SIGNAL (TIMER0_COMPA_vect) {
ISR (TIMER0_COMPA_vect) {
	//char s10;
	char s1;

	msec8++;
	if (msec8 == 125) {
		sec++;
		msec8 = 0;
		//s10 = sec/10;
		s1 = sec%10;
		//PORTD = (s10<<4) + s1;
		PORTD = s1;
	}
	if (sec == 99) {
		sec = 0;
	}
	PORTB ^= _BV(PB5);
}

int main(void) {
	DDRD = 0xFF;
	DDRB |= _BV(PB5);

	PORTD = 0;

	// Toggle on Compare Match
	TCCR0A |= _BV(COM0A0);
	//TCCR0A |= _BV(COM0A1);
	TCCR0A |= _BV(COM0B0);

	cli();

	TIMSK0 |= (1 << OCIE0A);    // Compare match 인터럽트 에이블
	TCCR0A |= (1 << WGM01);	    // CTC mode
	//CS0[2:0]
	TCCR0B |= (1 << CS02);	// Clock/1024
	TCCR0B |= (1 << CS00);	// Clock/1024
	OCR0A = cDelay;

	sei();
	while (1) {
	}
}
