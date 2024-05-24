/*
 * 10_Blink.c
 *
 * Created: 2017-08-07 �ð� 5:12:02
 * Author : Soochan Kim
 */

#include <avr/io.h>
#include <util/delay.h>

int main1(void) {
	
	// PortB���� PB0���� ����� ������� ����
	DDRB |= 0x01;
	
	while (1) {
		// PortB�� PB0�ɸ� High�� ���, �������� ������ �� �״��
		PORTB |= 0x01;
		// 1000ms ��ٸ�
		_delay_ms(1000);
		// PortB�� PB0�ɸ� Low�� ���, �������� ������ �� �״��
		PORTB &= ~0x01;
		_delay_ms(1000);
	}
	return 0;
}
