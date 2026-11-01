#include "stdio.h"
#include "system.h"
#include "altera_avalon_timer_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"

// 7-segment display 패턴 정의 (Common Anode - Active Low)
const unsigned char SEG7_PATTERNS[10] = { 0b11000000,  // 0
		0b11111001,  // 1
		0b10100100,  // 2
		0b10110000,  // 3
		0b10011001,  // 4
		0b10010010,  // 5
		0b10000010,  // 6
		0b11111000,  // 7
		0b10000000,  // 8
		0b10010000   // 9
		};

// 메모리 맵 레지스터를 위한 포인터
volatile unsigned int *hex3_0_ptr = (unsigned int *) HEX3_HEX0_BASE;
volatile unsigned int *hex5_4_ptr = (unsigned int *) HEX5_HEX4_BASE;

// 특정 7-segment에 숫자를 표시하는 함수
void display_hex(int position, int value) {
	if (position >= 0 && position <= 3) {
		// HEX3~HEX0 제어
		int current = *hex3_0_ptr;
		current &= ~(0xFF << (position * 8));  // 해당 위치 비트 클리어
		current |= (SEG7_PATTERNS[value] << (position * 8));  // 새 값 설정
		*hex3_0_ptr = current;
	} else if (position >= 4 && position <= 5) {
		position -= 4;
		// HEX5~HEX4 제어
		int current = *hex5_4_ptr;
	    current &= ~(0xFF << (position * 8));  // 해당 위치 비트 클리어
		current |= (SEG7_PATTERNS[value] << (position * 8));  // 새 값 설정
		*hex5_4_ptr = current;
	}
}

// 모든 7-segment에 숫자 표시
void display_number(unsigned int number) {
	display_hex(0, number % 10);        // 1의 자리
	display_hex(1, (number / 10) % 10);   // 10의 자리
	display_hex(2, (number / 100) % 10);  // 100의 자리
	display_hex(3, (number / 1000) % 10); // 1000의 자리
	display_hex(4, (number / 10000) % 10); // 10000의 자리
	display_hex(5, (number / 100000) % 10); // 10000의 자리
}

static void timer_isr(void *context, alt_u32 id) {
	static int count = 0;

	// clear timer
	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_BASE, 0);

	// Do something
	printf("Timer expired = %d\n", count);
//	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, count);
	display_number(count);
	count = (count + 1) % 100000;  // 0~99999 범위로 제한

}

void init_timer_interrupt(void) {
	// Register the ISR with HAL
	alt_ic_isr_register(TIMER_IRQ_INTERRUPT_CONTROLLER_ID, TIMER_IRQ,
			(void *) timer_isr,
			NULL, 0);

	// Start the timer
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_BASE,
			ALTERA_AVALON_TIMER_CONTROL_CONT_MSK | ALTERA_AVALON_TIMER_CONTROL_START_MSK | ALTERA_AVALON_TIMER_CONTROL_ITO_MSK);
}

int main() {
	printf("Hello from Nios II Timer interrupt & 7 segments!\n");
	init_timer_interrupt();

	// 무한 루프로 카운터 값 증가 및 표시
	while (1) {
	}

	return 0;
}
