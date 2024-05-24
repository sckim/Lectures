#include <avr/io.h>
#include <avr/interrupt.h>

int Index = -1;
unsigned char SEG[10]= {0XC0, 0XF9, 0XA4, 0XB0, 0X99, 0X92, 0X82, 0XD8, 0X80, 0X90};

// ���ͷ�Ʈ ���� �Լ��� �Ʒ��� ����
// SIGNAL(SIG_INTERRUPTn)���� �Ͽ� n�� ���ͷ�Ʈ ��ȣ
SIGNAL(SIG_INTERRUPT0)
{
   Index++;
   if (Index >= 10) Index = 0;

   PORTF = SEG[Index];    
   
} //���ͷ�Ʈ ���๮

SIGNAL(SIG_INTERRUPT1)
{
   Index--;
   if (Index < 0) Index = 9;
   
   PORTF = SEG[Index];    
} //���ͷ�Ʈ ���๮

int main(void)
{
    DDRF  = 0XFF;
    PORTF = 0xFF;
  
    EIMSK = 0b00000011;      //INT0 ��, INT1�� ��� ����
    //EIMSK = 0x01;
    EICRA = 0b00001010;       //INT0 �ϰ��𼭸����� ���۵ǵ��� ����(0��,1�� ���ͷ�Ʈ)
    //EICRA = 0x02;
    SREG = 0b10000000;
    //SREG = 0x80;


    while(1) //���α׷��� �������ʰ� �ϱ�����  ���ѹݺ���
    { 
    }
}
