/*
 * 10_Blink.c
 *
 * Created: 2017-08-07 시간 5:12:02
 * Author : Soochan Kim
 */

#include <avr/io.h>
#include <util/delay.h>

int main1(void) {
	
	// PortB에서 PB0핀의 기능을 출력으로 설정
	DDRB |= 0x01;
	
	while (1) {
		// PortB의 PB0핀만 High를 출력, 나머지는 현재의 값 그대로
		PORTB |= 0x01;
		// 1000ms 기다림
		_delay_ms(1000);
		// PortB의 PB0핀만 Low로 출력, 나머지는 현재의 값 그대로
		PORTB &= ~0x01;
		_delay_ms(1000);
	}
	return 0;
}
