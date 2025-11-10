#include <io.h>
#include <progmem.h>

unsigned char __attribute__((progmem)) SEG[6]=
{0xc0,0xf9,0xa4,0xb0,0x99,0x92};

unsigned char __attribute__((progmem))POWER[6]=
{0x01,0x02,0x04,0x08,0x10,0x20};

void delay(int i)
{
        while(--i);
}

int main(void)
{
        outp(0xff,DDRD);
        outp(0xff,DDRB);
        outp(0xff,PORTB);
        outp(0x00,PORTD);

        int j;

        while(1)
        {
                for(j=0;j<6;j++)
                {
                        outp(PRG_RDB(&POWER[j]),PORTD);
                        outp(PRG_RDB(&SEG[j]),PORTB);
                        delay(10);
                 }
        }
}
