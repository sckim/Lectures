/***********************************************************
* ����: ��Ʈ�� �Է� ���¿� ���� ���ڸ� ���� Ȥ�� ���� ��Ų��.
*
* PINn
* DDRn
* PORTn
***********************************************************/

#include <avr/io.h>
#include <util/delay.h>

#define	SegmentPort	PORTB
#define LEDPort		PORTB
#define InputPort	PIND

#define cDelay 		500

typedef unsigned char Byte;

// ��Ʈ�� �ʱ� ���¸� �Լ��� �̿��ؼ� ����
void Initialize_Ports(void)
{
	DDRA = 0xFF;	// ���: 1, �Է� 0
	DDRB = 0xFF;
	DDRC = 0xFF;
	// PORTD�� b0 bit�� 0���� �Ͽ� �Է����� ����
	DDRD = 0xFE;	
	DDRE = 0xFF;
	DDRF = 0xFF;
}

int main (void)
{
	Byte LED[9] = {0xFF, 0xFE,0xFC,0xF8,0xF0,0xE0,0xC0,0x80, 0x00};
	Byte SEG[16]= {0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82, 
					0XD8,0X80,0X90, 0X88, 0X83, 0XC6, 0XA1, 0X86, 0X8e};

	signed char Index = 0;
	unsigned char flag = 1;
	
	Initialize_Ports();

	while (1)  // ���ѷ��� ����
	{
		// ��ư�� �Է��� ����
		flag = PIND&0x01;
		//flag = InputPort & 0x01;
		//flag = InputPort & B0;

		if (flag)
			Index++;
		else
			Index--;

		// ���ڰ� 8�̸� �ٽ� 0����
		if (Index==9)
			Index = 0;
		// Index�� -1�̸� �ִ밪 8��
		if (Index==-1)
			Index = 8;

		LEDPort = LED[Index];
		SegmentPort = ~SEG[Index];
		_delay_ms(cDelay);  // 500ms ������Ŵ
	}
}
