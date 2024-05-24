#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#define SW_A	PB0
#define SW_B	PB1

volatile char num = 0;
volatile char inc = 1;

// Use one Routine to handle each group
ISR (PCINT0_vect) // handle pin change interrupt for D8 to D13 here
{
	//if( !digitalRead(SW_A) )
	//if( !(PINB & _BV(SW_A)) )
	if (bit_is_clear(PINB, SW_A))
		num = 0;

	//if( !digitalRead(SW_B) ) {
	//if( !(PINB & _BV(SW_B)) ) {
	if (bit_is_clear(PINB, SW_B)) {
		if (inc > 0)
			inc = -1;
		else
			inc = 1;
	}
}

void dispSeg(unsigned char ch) {
	//for(int i=0; i<4; i++)
	//  digitalWrite(i+4, bitRead(ch, i));
	int temp;

	// 상위 4비트만 update
	temp = PORTD & 0x0F;
	PORTD = ((ch << 4) | temp);
}

// 핀 하나하나를 개별적으로 제어하여 프로그램하는 예
void setup() {
	// PORTD의 상위 4비트를 출력으로
	//  DDRD |= 0xF0; or
	DDRD |= (_BV(PD7) | _BV(PD6) | _BV(PD5) | _BV(PD4));

	// 스위치가 있는 포트를 pull up 저항 활성화
	//  pinMode(SW_A, INPUT_PULLUP);
	//  pinMode(SW_B, INPUT_PULLUP);
	PORTB |= (_BV(SW_A) | _BV(SW_B));

	// enable pin change interrupt for pin...
	//  pciSetup(SW_A);
	//  pciSetup(SW_B);
	PCICR |= _BV(PCIE0);
	PCMSK0 |= (_BV(PCINT0) | _BV(PCINT1));
	SREG |= _BV(7);
}

void loop() {
	dispSeg(num);
	num += inc;

	if (num > 9)
		num = 0;
	if (num < 0)
		num = 9;

	_delay_ms(500);
}

int main(void) {
	setup();

	while (1) {
		loop();
	}
}
