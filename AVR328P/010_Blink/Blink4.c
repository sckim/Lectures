/*
 * 10_Blink.c
 *
 * Created: 2017-08-07 오후 5:12:02
 * Author : Soochan Kim
 */


#include <avr/io.h>
#include <util/delay.h>

int main1(void) {

#if defined (__AVR_ATmega128__)
// 컴파일 환경에서 uC가 128로 설정했을 때 실행
	DDRA = 0xFF;

	while (1) {
		PORTA = 0x00;
		_delay_ms(1000);
		PORTA = 0xFF;
		_delay_ms(1000);
	}
#elif __AVR_ATmega328P__
// 컴파일 환경에서 uC가 328P로 설정했을 때 실행
	DDRB = 0xFF;

	while(1) {
		PORTB = 0x00;
		_delay_ms(1000);
		PORTB = 0xFF;
		_delay_ms(1000);
	}
#endif
	return 0;
}
