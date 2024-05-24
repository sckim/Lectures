#include <avr/io.h>
#include <avr/interrupt.h>

uint16_t divider = 256;

uint16_t Duty(uint8_t percentage) {
	percentage = (percentage > 100 ? 100 : (percentage < 0 ? 0 : percentage));
	uint16_t OCR = (uint16_t) (((uint32_t) percentage * (uint32_t) ICR1) / 100); // Set pwm percent of pwm period

	return OCR;
}

void SetPeriod(uint16_t frequency) {
	uint16_t TOP = F_CPU / (divider * frequency) - 1;
	ICR1 = TOP;
}
void SpeedA(uint8_t percentage) {
	OCR1A = Duty(percentage);
}

void SpeedB(uint8_t percentage) {
	OCR1B = Duty(percentage);
}

void PWM1_INIT() {
	DDRB |= (1 << PB1);
	DDRB |= (1 << PB2);
	// Timer/Counter 1 initialization
	// Clock source: System Clock
	// Clock value: 62.500 kHz
	// Mode: Fast PWM top=ICR1
	// OC1A output: Non-Inverted PWM
	// OC1B output: Non-Inverted PWM
	// Noise Canceler: Off
	// Input Capture on Falling Edge
	// Timer Period: 1 s
	// Output Pulse(s):
	// OC1A Period: 1 s Width: 0.2 s
	// OC1B Period: 1 s Width: 0.40001 s
	// Timer1 Overflow Interrupt: Off
	// Input Capture Interrupt: Off
	// Compare A Match Interrupt: Off
	// Compare B Match Interrupt: Off
	TCCR1A = (1 << COM1A1) | (0 << COM1A0) | (1 << COM1B1) | (0 << COM1B0)
			| (1 << WGM11) | (0 << WGM10);
	TCCR1B = (0 << ICNC1) | (0 << ICES1) | (1 << WGM13) | (1 << WGM12)
			| (1 << CS12) | (0 << CS11) | (0 << CS10);
	TCNT1H = 0x00;
	TCNT1L = 0x00;
}

long map(long x, long in_min, long in_max, long out_min, long out_max) {
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

ISR(PCINT2_vect) {
	if (bit_is_set(PIND, PD5)) {
		PORTD |= _BV(PD6);
		PORTD &= ~_BV(PD7);
	} else {
		PORTD &= ~_BV(PD6);
		PORTD |= _BV(PD7);
	}
}

void InitADC() {
	// For Aref=AVcc;
	ADMUX = (1 << REFS0);
	//Rrescalar div factor =128
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
}

uint16_t ReadADC(uint8_t ch) {
	// Clear lower three bits and set them from chan
	ADMUX &= 0xF8;
	ADMUX |= (ch & 7);

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
	InitADC();

	PWM1_INIT();
	SetPeriod(100);

	DDRD &= ~_BV(PD5);
	PORTD |= (1 << PD5); //pull up

	DDRD |= _BV(PD6);
	DDRD |= _BV(PD7);
	PORTD |= _BV(PD6);
	PORTD &= ~_BV(PD7);

	SpeedA(20);
	SpeedB(20);

  // set PCINT0 to trigger an interrupt on state change 	SREG = 0b10000000;
	PCMSK2 |= (1 << PCINT21); 
	
  // set PCIE0 to enable PCMSK0 scan
	PCICR |= (1 << PCIE2);
  
	sei();
	while (1) {
		SpeedA(map(ReadADC(0), 0, 1023, 0, 100));
		SpeedB(map(ReadADC(1), 0, 1023, 0, 100));
	}
}
