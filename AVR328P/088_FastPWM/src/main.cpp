#define F_CPU	16000000L

#include <avr/io.h>
#include "timer0.h"

#define DutyRatio	40
#define DutyValue (DutyRatio / 100.0 * 256)

long map(long x, long in_min, long in_max, long out_min, long out_max) {
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

void InitADC() {
	// For Aref=AVcc;
	// REFS[1:0] = 01
	ADMUX = (1 << REFS0);

	//Prescalar div factor =128
	// ADPS[2:0]
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
}

uint16_t ReadADC(uint8_t ch) {
	//Select ADC Channel ch must be 0-7
	// MUXn[3:0]
	ADMUX &= 0xF0;
	ADMUX |= (ch & 0x07);

	//Start Single conversion
	ADCSRA |= (1 << ADSC);

	//Wait for conversion to complete
	//while (!(ADCSRA & (1 << ADIF)))
	//	;
    loop_until_bit_is_clear(ADCSRA, ADIF);
  
	//Clear ADIF by writing one to it
	//Note you may be wondering why we have write one to clear it
	//This is standard way of clearing bits in io as said in datasheets.
	//The code writes '1' but it result in setting bit to '0' !!!
	ADCSRA |= (1 << ADIF);

	return (ADC);
}

int main(void)
{
	InitADC();

	OCR0A = DutyValue;
//	OCR0B = 2*DutyValue;
	// set PWM for 50% duty cycle

	Timer0Mode(FPWM);		 // Compare capture mode
	Timer0Prescaler(1024);	 // 16MHz/256 => 1 step = 16us
	Timer0OutputA(NonInvert);
	// Timer0OutputB(NonInvert);

	while (1)
	{
		// we have a working Fast PWM
		OCR0A = map(ReadADC(0), 0, 1023, 10, 35); //0.8m~1msec
	}
}