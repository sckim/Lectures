/*
 * Blink.c
 *
 * Created: 2021-10-06 ¿ÀÈÄ 1:45:56
 * Author : Soochan Kim
 */

#include <avr/io.h>
#include <util/delay.h>

void setup(void)
{
	DDRB |= _BV(5);
}

void loop(void)
{
	PORTB |= _BV(PB5);
	_delay_ms(1000);
	PORTB &= ~_BV(PB5);
	_delay_ms(1000);
}

 int main(void)
{
	setup();

    /* Replace with your application code */
    while (1)
    {
		loop();
    }
}

