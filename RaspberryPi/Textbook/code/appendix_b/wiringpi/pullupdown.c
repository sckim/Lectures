/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.2.1 = WiringPi-master/examples/pullupdown.c
 * 저작   : 강의 작성
 * pigpio : ../pullupdown_pigpio.c
 * 빌드   : gcc -Wall -o pullupdown pullupdown.c -lwiringPi   (WiringPi 설치 시)
 */
// Pull up/down example

#include <stdio.h>
#include <wiringPi.h>

#define INPUT_PIN 0 // BCM GPIO 17

int main(void)
{
    printf("Hello, world\n");
    if (wiringPiSetup() == -1)
    {
        return 1;
    }

    pinMode(INPUT_PIN, INPUT);

    for (;;)
    {
        pullUpDnControl(INPUT_PIN, PUD_UP);
        printf("digitalRead (INPUT_PIN) : %d\n", digitalRead(INPUT_PIN));

        delay(1000);
        pullUpDnControl(INPUT_PIN, PUD_DOWN);
        printf("digitalRead (INPUT_PIN) : %d\n", digitalRead(INPUT_PIN));
        delay(1000);
    }
    return 0;
}
