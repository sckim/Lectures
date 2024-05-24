/***********************************************************
* Purpose: 7 segements�� 0���� F���� ����ϱ�
*
* DDRn
* PORTn
*************************************/
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	// Common cathod�� ���� �� decode ��

	unsigned char SEG[16]= {0xC0, 0xF9,0xA4,0xB0,0x99,0x92,0x82,
		0xD8,0x80,0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8e};

	DDRF = 0xFF;

	while(1) {
		// i�� 0���� 15���� �ݺ��Ѵ�.
		for(int i=0; i<16; i++) {
			PORTF = SEG[i];
			_delay_ms(500);
		}
	}
}
