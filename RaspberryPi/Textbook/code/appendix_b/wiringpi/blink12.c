/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.1.4 blink12.c (WiringPi-master/examples/blink12.c와 데이터 배열 줄바꿈만 다름)
 * 저작   : Gordon Henderson, wiringPi 예제 (LGPLv3). 강의용으로 정리
 * pigpio : ../blink12_pigpio.c
 * 빌드   : gcc -Wall -o blink12 blink12.c -lwiringPi   (WiringPi 설치 시)
 */
#include <stdio.h>
#include <wiringPi.h>

// Simple sequencer data
// Triplets of LED, On/Off and delay
int data[] =
    {
        0, 1, 1, 1, 1, 1,
        0, 0, 0, 2, 1, 1,
        1, 0, 0, 3, 1, 1,
        2, 0, 0, 4, 1, 1,
        3, 0, 0, 5, 1, 1,
        4, 0, 0, 6, 1, 1,
        5, 0, 0, 7, 1, 1,
        6, 0, 0, 11, 1, 1,
        7, 0, 0, 10, 1, 1,
        11, 0, 0, 13, 1, 1,
        10, 0, 0, 12, 1, 1,
        13, 0, 1, 12, 0, 1,
        0, 0, 1, // Extra delay

        // Back again

        12, 1, 1, 13, 1, 1,
        12, 0, 0, 10, 1, 1,
        13, 0, 0, 11, 1, 1,
        10, 0, 0, 7, 1, 1,
        11, 0, 0, 6, 1, 1,
        7, 0, 0, 5, 1, 1,
        6, 0, 0, 4, 1, 1,
        5, 0, 0, 3, 1, 1,
        4, 0, 0, 2, 1, 1,
        3, 0, 0, 1, 1, 1,
        2, 0, 0, 0, 1, 1,
        1, 0, 1, 0, 0, 1,
        0, 0, 1, // Extra delay

        0, 9, 0, // End marker
};

int main(void)
{
    int pin;
    int dataPtr;
    int l, s, d;

    printf("Raspberry Pi - 12-LED Sequence\n");
    printf("==============================\n");
    printf("\n");
    printf("Connect LEDs up to the first 8 GPIO pins, then pins 11, 10, 13, 12 in\n");
    printf("    that order, then sit back and watch the show!\n");

    wiringPiSetup();

    for (pin = 0; pin < 14; ++pin)
        pinMode(pin, OUTPUT);

    dataPtr = 0;

    for (;;)
    {
        l = data[dataPtr++]; // LED
        s = data[dataPtr++]; // State
        d = data[dataPtr++]; // Duration (10ths)

        if (s == 9) // 9 -> End Marker
        {
            dataPtr = 0;
            continue;
        }

        digitalWrite(l, s);
        delay(d * 100);
    }

    return 0;
}
