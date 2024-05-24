/*=======================================================*/
// 외부 인터럽트를 이용한 7 segment 값 변경
// INT0 (PD0)를 활성화
/*=======================================================*/
#include <avr/io.h>
#include <avr/interrupt.h>

int Index = 0;

// 인터럽트 수행 함수는 아래와 같이
// SIGNAL(SIG_INTERRUPTn)으로 하여 n이 인터럽트 번호

ISR(INT0_vect)
 {
    if (++Index == 0x10)
        Index = 0;
    PORTD = Index << 4;
}

ISR(INT1_vect) {
    if (--Index < 0)
        Index = 0x0F;
    PORTD = Index << 4;
}

int main(void) {
    DDRD = 0XF0;
    PORTD = 0;

    EIMSK = 0b00000011; //INT0 번 사용 설정
    //EIMSK = 0x01;
    EICRA = 0b00001010; //INT0 하강모서리에서 동작되도록 설정
    //EIMSK = 0x02;
    SREG = 0b10000000;
    sei();
    //SREG = 0x80;

    while (1) {
    }
}
