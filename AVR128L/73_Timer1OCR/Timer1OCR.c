/*************************************
* Purpose: 1�ʸ��� overflow interrupt�� �̿��Ͽ�
* LED Shift
*
* TIMSK
* TCCR1B
* TCNT1
*************************************/
#include <avr/io.h>
#include <avr/interrupt.h>

#define cDelay	14400	// 1sec 14.7456MHz

unsigned char LED_ARRAY[9] = { 0xff, 0xfe, 0xfd, 0xfb, 0xf7, 0xef, 0xdf, 0xbf,
		0x7f };
unsigned char FND[10] = { 0XC0, 0XF9, 0XA4, 0XB0, 0X99, 0X92, 0X82, 0XD8, 0X80, 0X90 };

volatile unsigned int index = 0;

ISR (TIMER1_COMPA_vect)	{
//SIGNAL(SIG_OUTPUT_COMPARE1A) {
	PORTA = LED_ARRAY[index];
	PORTE = FND[index];
	
	index++;
	if (index == 9)
		index = 0;
	
	// CTC mode������ match�� �Ǹ� TCNT1�� �ڵ����� �ʱ�ȭ�Ǳ� ������
	// �Ʒ��� ���� Timer1�� �ʱ�ȭ�� �ʿ����.
	//TCNT1 = 10000;
}

int main(void) {
	DDRA = 0xFF;
	DDRE = 0xFF;

	// Timer1�� �ʱ�ȭ �Ѵ�.
	
	// Clear interrupt
	cli();
	// Set timer interrupt mask
	TIMSK |= (1<<OCIE1A);

	 // turn on CTC mode:
	 TCCR1B |= (1 << WGM12);

	/* Clock Seclects bits
	CS12	CS11	CS10	Mode Description
	000: Stop Timer/Counter 1
	001: No Prescaler (Timer Clock = System Clock)
	010: divide clock by 8
	011: divide clock by 64
	100: divide clock by 256
	101: divide clock by 1024
	110: increment timer 1 on T1 Pin falling edge
	111: increment timer 1 on T1 Pin rising edge
	*/
	TCCR1B |= (1<<CS12);
	TCCR1B |= (1<<CS10);  // /1024

	// Timer1�� count���� 0���� �ʱ�ȭ�Ѵ�.
	TCNT1 = 0;
	OCR1A = cDelay;

	sei();

	while (1) {
	};
}
