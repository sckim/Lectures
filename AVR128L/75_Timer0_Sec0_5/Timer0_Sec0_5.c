/*=======================================================*/
//4��_����4-2(c)
//
//0.5�� ���� led ����Ʈ----------
// overflow interrupt �̿�
/*=======================================================*/
#include <avr/io.h>
#include <avr/interrupt.h>

unsigned char FND[10] = { 0XC0, 0XF9, 0XA4, 0XB0, 0X99, 0X92, 0X82, 0XD8, 0X80, 0X90 };

int Cnt = 0;
SIGNAL(SIG_OVERFLOW1)
{
   PORTF = FND[Cnt++];
   if(Cnt > 9) Cnt = 0;
   TCNT1 = 65535-57600;
}
int main(void)
{
   DDRF = 0xFF;
   PORTF = 0xff;

   TIMSK = 0x04;			// timer1 overflow interrupt
   TCCR1B = 0x04;   		// 256 ����
   TCNT1 = 65535-57600;   	// 
   //OCR1A = 0xE100;
   sei();
   while (1)
   {
   }
}
