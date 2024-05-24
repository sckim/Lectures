#include <avr/io.h>

uint16_t divider = 256;

void Duty( uint8_t percentage, uint16_t ICR1_value)
{
	percentage =  (percentage > 100 ? 100 : (percentage < 0 ? 0 : percentage));
	uint16_t OCR = (uint16_t)(((uint32_t)percentage * (uint32_t)ICR1_value)/100) ;    // Set pwm percent of pwm period

//	OCR1AH = OCR >> 8;
//	OCR1AL = OCR & 0xFF;
	OCR1A = OCR;
}

void FrequencyPWM(uint8_t frequency, uint8_t percentage)
{
	uint16_t TOP = F_CPU/(divider*frequency) - 1;
	ICR1H = TOP >> 8;
	ICR1L = TOP & 0xFF;
	Duty(percentage, TOP);
}

void PWM1_INIT()
{
	DDRB |= (1 << PINB1);
	//DDRB |= (1 << PINB2);
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
	TCCR1A=(1<<COM1A1) | (0<<COM1A0) | (1<<COM1B1) | (0<<COM1B0) | (1<<WGM11) | (0<<WGM10);
	TCCR1B=(0<<ICNC1) | (0<<ICES1) | (1<<WGM13) | (1<<WGM12) | (1<<CS12) | (0<<CS11) | (0<<CS10);
	TCNT1H=0x00;
	TCNT1L=0x00;
}

int main(void)
{
	PWM1_INIT();
	FrequencyPWM(200, 50);

	while(1);
}
