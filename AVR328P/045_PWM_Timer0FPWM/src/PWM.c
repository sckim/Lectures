///*************************************
// * Purpose: Timer0을 이용한 OC0A(PD6)에 PWM 생성
// *
// *
// *************************************/
#define F_CPU	16000000L

#include <avr/io.h>
#include "timer0.h"

#define DutyRatio	20
#define DutyValue (DutyRatio / 100.0 * 256)

int main(void)
{
	OCR0A = DutyValue;
	OCR0B = 2*DutyValue;
	// set PWM for 50% duty cycle

	Timer0Mode(FPWM);		 // Compare capture mode
	Timer0Prescaler(1024);	 // 16MHz/256 => 1 step = 16us
	Timer0OutputA(Invert);
	Timer0OutputB(NonInvert);

	while (1)
	{
		// we have a working Fast PWM
	}
}
