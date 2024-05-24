/*************************************
 * Purpose: Understand GPIO registers
 *
 * DDRn
 * PORTn
 * PINn
 *************************************/

#include <avr/io.h>
#include <util/delay.h>

int main(void) {
	int Value = 0;
	DDRB = 0xF0;
	DDRD = 0xFF;

	while (1) {
		if (bit_is_clear(PINB, PB0)) {
			Value++;
			_delay_ms(200);
		} else if (bit_is_clear(PINB, PB1)) {
			Value--;
			_delay_ms(200);
		} else
			PORTD = Value;

		PORTD = Value;
		_delay_ms(10);
	}
}
