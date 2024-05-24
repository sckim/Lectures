#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

#define NumOfDigit	4
unsigned char POWER[4] = { 0x01, 0x02, 0x04, 0x08};

int main(void) {
	int Index;
	char str[NumOfDigit];
	int iNum=0;

	DDRD = 0xf0;
	DDRB = 0x0f;

	while (1) {
		sprintf(str, "%04d", iNum++);
		for(Index=0;Index<NumOfDigit;Index++) {
			PORTB = POWER[Index];
			PORTD = (str[Index]-0x30)<<4;
			_delay_ms(100);//8ms
		}
	}
	return 0;
}

