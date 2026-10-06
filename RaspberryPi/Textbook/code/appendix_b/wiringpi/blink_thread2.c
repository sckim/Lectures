/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.1.5 두 번째 코드 = WiringPi-master/examples/blink_thread2.c
 * 저작   : 강의 작성 (blink_thread.c 확장)
 * pigpio : ../blink_thread2_pigpio.c
 * 빌드   : gcc -Wall -o blink_thread2 blink_thread2.c -lwiringPi   (WiringPi 설치 시)
 */
#include <stdio.h>
#include <wiringPi.h>

#define LED0 0
#define LED1 1

PI_THREAD(blinky)
{
    for (;;)
    {
        digitalWrite(LED0, HIGH); // On
        delay(10);               // mS
        digitalWrite(LED0, LOW);  // Off
        delay(10);
    }
}

PI_THREAD(blinky2)
{
    for (;;)
    {
        digitalWrite(LED1, HIGH); // On
        delay(20);               // mS
        digitalWrite(LED1, LOW);  // Off
        delay(20);
    }
}

void setup(void)
{
    wiringPiSetup();
    pinMode(LED0, OUTPUT);
    pinMode(LED1, OUTPUT);

    piThreadCreate(blinky);
    piThreadCreate(blinky2);
}

void loop(void)
{
    printf("Hello, world\n");
    delay(1000);
}

int main(void)
{
    printf("Raspberry Pi blink\n");

    setup();
    for (;;)
    {
        loop();
    }

    return 0;
}
