/*************************************
 *
 * TIMSK0
 * TCCR0A
 * TCCR0B
 * OCR0A
 *************************************/
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

// from TCNT = (CS / 16000000 ) * (256-x) =10msec
// x = time * (16000000/CS)
// 15625*8msec = 125
#define cDelay 250

void InitADC() {
	// For Aref=AVcc;
	ADMUX = (1 << REFS0);
	//Rrescalar div factor =128
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
}

uint16_t ReadADC(uint8_t ch) {
	//Select ADC Channel ch must be 0-7
	ADMUX |= (ch & 0x07);

	//Start Single conversion
	ADCSRA |= (1 << ADSC);

	//Wait for conversion to complete
	while (!(ADCSRA & (1 << ADIF)))
		;

	//Clear ADIF by writing one to it
	//Note you may be wondering why we have write one to clear it
	//This is standard way of clearing bits in io as said in datasheets.
	//The code writes '1' but it result in setting bit to '0' !!!
	ADCSRA |= (1 << ADIF);

	return (ADC);
}

int main(void) {

	DDRD |= _BV(6);

	InitADC();

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

	while (1) {
		OCR0A = ReadADC(0)>>2;
		_delay_ms(100);
	}
}
