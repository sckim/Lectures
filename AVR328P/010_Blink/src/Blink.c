/*
 * 10_Blink.c
 *
 * Created: 2017-08-07 오후 5:12:02
 * Author : Soochan Kim
 */

#define F_CPU 16000000L  //clear warning message

#include <avr/io.h>
#include <util/delay.h>
#include <avr/sfr_defs.h>
#include <avr/interrupt.h>

//void blink(void)
ISR(INT1_vect)  
{
	PORTB ^= _BV(cLED);
//    PORTB = PORTB ^ _BV(cLED);
/*    
    if(PORTB &_BV(cLED))
       PORTB &= ~_BV(cLED);
    else
       PORTB |= _BV(cLED);

  // ^: XOR
  // |: OR
  // &: AND
  // ~: NOT
*/  
}

int main(void) {
	DDRB = 0xFF;

	while (1) {
		PORTB |= _BV(PB5);
		//PORTB |= (1<<PB5);
		_delay_ms(1000);
		PORTB &= ~_BV(PB5);
		//PORTB &= ~(1<<PB5);
		_delay_ms(1000);
		bit_is_set(PORTB, PB5);
	}
	return 0;
}
