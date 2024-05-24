
/*=======================================================*/
//������Ʈ 0�� 1�� ���
//���ͷ�Ʈ Ʈ������ �ϰ��������� ���ͷ�Ʈ�� �䱸
/*=======================================================*/
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

typedef unsigned char BYTE;

int Index=0;

volatile BYTE	SEG[10]= {0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82, 0XD8,0X80,0X90};
volatile BYTE	LED[9] = {0xFF, 0xFE,0xFC,0xF8,0xF0,0xE0,0xC0,0x80,0x00};


SIGNAL(SIG_INTERRUPT0)		//�ܺ����ͷ�Ʈ 0���� ���α׷�
{
	Index++;

	if(Index==9) Index = 8;
	
	PORTB = LED[Index];
	PORTF = SEG[Index];
}

SIGNAL(SIG_INTERRUPT1)		//�ܺ����ͷ�Ʈ 0���� ���α׷�
{
	Index--;

	if(Index<0) Index = 0;

	PORTB = LED[Index];
	PORTF = SEG[Index];
}


int main(void)
{
	DDRB = 0xFF;
	DDRD = 0x00;
	DDRF = 0xFF;

	PORTB = LED[Index];
	PORTF = SEG[Index];


	// External Interrupt Mask Register
	EIMSK=0x03;		//2���� (16����:0x41)

 	// External Interrupt Control Register 
	EICRA=0x0f;		//��� ����

	SREG=0x80;		//16����(2����:0b10000000)


	while(1) {

    }
}

