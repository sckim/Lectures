///*************************************
// * Purpose: Timer0 OC0A(PD6)PWM 
// *
// *
// *************************************/

#include <avr/io.h>

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
	// PD6 is now an output
	DDRD |= (1 << DDD6);

    // COM0A1 COM0A0
    // 00: OC0A disconnected
    // 01: Toggle on Match
    // 10: Clear on Match, Non inverting
    // 11: Set on Match , Inverting
    TCCR0A |= (1 << COM0A1);
    //TCCR0A |= (1 << COM0A0);

    // WGM01 WMG00
    // 00: Normal
    // 01: PWM, Phase Correct
    // 10: CTC
    // 11: Fast PWM
    TCCR0A |= (1 << WGM01);
    TCCR0A |= (1 << WGM00);

    // set prescaler to 8 and starts PWM
    // CS02 CS01 CS00
    // 000: No clock source
    // 001: No prescaling
    // 010: clk_IO/8
    // 011: clk_IO/64
    // 100: clk_IO/256
    // 101: clk_IO/1024
    TCCR0B |= (1 << CS02);
    TCCR0B |= (1 << CS00);

    // set PWM for 50% duty cycle
    OCR0A = 10;

    InitADC();

	unsigned char deg;
    while(1)
    {
        // we have a working Fast PWM
		deg = map(ReadADC(0), 0, 1023, 10, 35); //0.8m~1msec
		OCR0A = deg;
    }
}
