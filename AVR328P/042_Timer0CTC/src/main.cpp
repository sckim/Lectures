#include <avr/io.h>

#define cDelay 125

volatile int sec = 0;
volatile int msec8 = 0;

void dispSeg(unsigned char ch) {
	PORTB &= 0xF0;
	PORTB |= ch;
}

int main(void) {
    DDRB |= 0x0F; 


    // Waveform Generation Mode 6가지 중 하나를 선택
    // CTC mode를 활성화한다.
    TCCR0A |= (1<<WGM01);

    //CS0[2:0]
    TCCR0B |= (1 << CS02);    // Clock/1024
    TCCR0B |= (1 << CS00);    // Clock/1024

    // Clear OC0A on Compare Match
    // set OC0A at BOTTOM (non-inverting mode)
    DDRD |= _BV(PD6);
    TCCR0A |= _BV(COM0A0);


    OCR0A = cDelay;
    while (1) {
        // Check overflow flag
        if (bit_is_set(TIFR0, OCF0A)) {
            // reset the overflow flag
            TIFR0 |= _BV(OCF0A);

            msec8++;
            if (msec8 == 125) {
                msec8 = 0;
                dispSeg(sec++);
            }
            if (sec == 10) {
                sec = 0;
            }
        }
    }
}
