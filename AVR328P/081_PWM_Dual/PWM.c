///*************************************
// * Purpose: Timer0을 이용한 OC0A(PD6)에 PWM 생성
// *
// *
// *************************************/

#include <avr/io.h>

int main(void)
{
	DDRD |= (1 << DDD5);
	// PD6 is now an output
	DDRD |= (1 << DDD6);

    OCR0A = 255/2;
    OCR0B = 255/4;
    // set PWM for 50% duty cycle

    // COM0A1 COM0A0
    // 00: OC0A disconnected
    // 01: Toggle on Match
    // 10: Clear on Match, Non inverting
    // 11: Set on Match , Inverting

    // set non-inverting mode
    TCCR0A |= (1 << COM0A1);
    // clear non-inverting mode
    //TCCR0A |= (1 << COM0A0);
    TCCR0A |= (1 << COM0B1);


    TCCR0A |= (1 << WGM01) | (1 << WGM00);
    // set fast PWM Mode

    // set prescaler to 8 and starts PWM
    // CS02 CS01 CS00
    // 000: No clock source
    // 001: No prescaling
    // 010: clk_IO/8
    // 011: clk_IO/64
    // 100: clk_IO/256
    // 101: clk_IO/1024
    //TCCR0B |= (1 << CS00);
    TCCR0B |= (1 << CS02);

    while (1);
    {
        // we have a working Fast PWM
    }
}
