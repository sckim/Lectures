/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.1.3 = WiringPi-master/examples/blink_sweep.c (강의용 추가 예제)
 * 저작   : 강의 작성
 * pigpio : ../../ch08/led_sweep.c
 * 빌드   : gcc -Wall -o blink_sweep blink_sweep.c -lwiringPi   (WiringPi 설치 시)
 */
/*
 * gpio_sweep.c:
 * Sweep wPin from 0 to 7
 */

#include <stdio.h>
#include <stdint.h>
#include <wiringPi.h>

#define cDeday  10

void setup(void)
{
    wiringPiSetup();

    for(uint8_t i=0; i<8; i++)
        pinMode(i, OUTPUT);
}

void loop(void)
{
    for(uint8_t i=0; i<8; i++) {
        printf("GPIO[%d] = High\n", i);
        digitalWrite(i, HIGH); 
        delay(cDeday);           
        printf("GPIO[%d] = Low\n", i);
        digitalWrite(i, LOW); 
        delay(cDeday);           
    }
}

int main(void)
{
    printf("Raspberry Pi GPIO Sweep\n");

    setup();
    for (;;)
        loop();

    return 0;
}
