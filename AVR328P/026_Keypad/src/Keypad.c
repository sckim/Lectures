#include <avr/io.h>
#include <util/delay.h>

//*******************************
#define KEYPAD_PORT 	PORTB
#define KEYPAD_DDR   	DDRB
#define KEYPAD_PIN   	PINB

#define Segment_PORT	PORTD
#define Segment_DDR	DDRD
//*******************************

typedef unsigned char BYTE;

int key_scan(void) {
	BYTE KEY;
	BYTE temp_SW;

	//read Port D
	KEY = KEYPAD_PIN & 0x07;
	//get only low 3 bits
	//KEY &= 0x07;

	temp_SW = 0;

	if (KEY != 0x07)  //if a key is pressed
			{
		//     KEY = PIND;
		//     KEY &= 0x0f;
		//	  if(KEY != 0x0f)
		//	  {
		switch (KEY) {
		case 0x03: //00000011
			temp_SW = 1;
			break;
		case 0x05: //00000101
			temp_SW = 2;
			break;
		default:
			temp_SW = 3;
		}
		//	  }
	}

	return temp_SW;
}

int main(void) {
	BYTE bKey;
//	BYTE SEG[12] = { 0XC0, 0XF9, 0XA4, 0XB0, 0X99, 0X92, 0X82, 0XD8, 0X80, 0X90,
//			0X88, 0X8e };

	Segment_DDR = 0xff;  // 7 segments
	Segment_PORT = 0xff;

	// high 4bits: output
	// low 4bits: input
	KEYPAD_DDR = 0xF8; // 0b11111000

	while (1) {
		KEYPAD_PORT = 0xF7; // only bit 6 low, 0b11110111
		//PORTD = ~_BV(2); // only bit 6 low, 0b1011
		_delay_ms(20);
		bKey = key_scan();
		if (bKey == 1)
			Segment_PORT = 3;
		else if (bKey == 2)
			Segment_PORT = 6;
		else if (bKey == 3)
			Segment_PORT = 9;

		KEYPAD_PORT = 0xE8; // only bit 5 low, 0b1101
		//PORTD = ~_BV(1); // only bit 6 low, 0b1101
		_delay_ms(20);
		bKey = key_scan();
		if (bKey == 1)
			Segment_PORT = 2;
		else if (bKey == 2)
			Segment_PORT = 5;
		else if (bKey == 3)
			Segment_PORT = 8;

		KEYPAD_PORT = 0xD8;  // only bit 4 low, 0b1110
		//PORTD = ~_BV(0); // only bit 6 low, 0b1110
		_delay_ms(20);
		bKey = key_scan();
		if (bKey == 1)
			Segment_PORT = 1;
		else if (bKey == 2)
			Segment_PORT = 4;
		else if (bKey == 3)
			Segment_PORT = 7;
	}
}
