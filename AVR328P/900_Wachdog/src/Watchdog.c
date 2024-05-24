#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <util/delay.h>

void WDT_off(void) {
	cli();
	wdt_reset();
	/* Clear WDRF in MCUSR */
	MCUSR &= ~(1 << WDRF);
	/* Write logical one to WDCE and WDE */
	/* Keep old prescaler setting to prevent unintentional time-out */
	WDTCSR |= (1 << WDCE) | (1 << WDE);
	/* Turn off WDT */
	WDTCSR = 0x00;
	sei();
}
// void WDT_off(void)
// {
// 	__disable_interrupt();
// 	__watchdog_reset();
// 	/* Clear WDRF in MCUSR */
// 	MCUSR &= ~(1<<WDRF);
// 	/* Write logical one to WDCE and WDE */
// 	/* Keep old prescaler setting to prevent unintentional time-out */
// 	WDTCSR |= (1<<WDCE) | (1<<WDE);
// 	/* Turn off WDT */
// 	WDTCSR = 0x00;
// 	__enable_interrupt();
// }


void WDT_Prescaler_Change(int time) {
	// Turn off global interrupt
	cli();

	wdt_reset();

	/* Start timed sequence */
	WDTCSR |= (1 << WDCE) | (1 << WDE);

	/* Set new prescaler(time-out) value = 64K cycles (~0.5 s) */
//	WDTCSR = (1 << WDIE) | (1 << WDP2) | (1 << WDP0);
//or
	wdt_enable(time);
	WDTCSR = (1 << WDIE);

// Turn on global interrupt
	sei();
}
// void WDT_Prescaler_Change(void)
// {
// 	__disable_interrupt();
// 	__watchdog_reset();
// 	/* Start timed sequence */
// 	WDTCSR |= (1<<WDCE) | (1<<WDE);
// 	/* Set new prescaler(time-out) value = 64K cycles (~0.5 s) */
// 	WDTCSR = (1<<WDE) | (1<<WDP2) | (1<<WDP0);
// 	__enable_interrupt();
// }

int main(void) {
	DDRB |= _BV(5);  // watchdog timer 인터럽트
	DDRD |= _BV(6);  // timer reset 상태
	PORTD |= 0b00000000;

	_delay_ms(50);
	PORTD |= _BV(6);
	_delay_ms(10);
	PORTD &= ~_BV(6);
	_delay_ms(10);
	PORTD |= _BV(6);
	_delay_ms(10);
	PORTD &= ~_BV(6);

	WDT_Prescaler_Change(WDTO_15MS);
	//WDT_Prescaler_Change(WDTO_2S);

	while (1){
		_delay_ms(50);
		PORTD ^= _BV(6);
		wdt_reset();
	}
}

ISR(WDT_vect) {
	PORTB ^= _BV(5);
	_delay_ms(10);
}
