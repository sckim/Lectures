/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.6.2 softpwm.c (WiringPi-master/examples/softPwm.c에 안내 문구를 더한 판)
 * 저작   : Gordon Henderson, wiringPi 예제 (LGPLv3). 강의용으로 수정
 * pigpio : ../softpwm_pigpio.c
 * 빌드   : gcc -Wall -o softpwm softpwm.c -lwiringPi -pthread   (WiringPi 설치 시)
 */
/*
 * softPwm.c:
 * Test of the software PWM driver. 
*/

#include <stdio.h>
#include <errno.h>
#include <string.h>

#include <wiringPi.h>
#include <softPwm.h>

#define RANGE 100
#define NUM_LEDS 8

int ledMap[NUM_LEDS] = {0, 1, 2, 3, 4, 5, 6, 7};
int values[NUM_LEDS] = {0, 25, 50, 75, 100, 75, 50, 25};

int main()
{
    int i, j;
    char buf[80];

    wiringPiSetup();

    for (i = 0; i < NUM_LEDS; ++i)
    {
        softPwmCreate(ledMap[i], 0, RANGE);
        printf("%3d, %3d, %3d\n", i, ledMap[i], values[i]);
    }

    printf("Press any key....");
    fgets(buf, 80, stdin);

    // Bring all up one by one:
    for (i = 0; i < NUM_LEDS; ++i)
        for (j = 0; j <= 100; ++j)
        {
            softPwmWrite(ledMap[i], j);
            delay(10);
        }
    printf("Press any key....");
    fgets(buf, 80, stdin);

    // All Down
    for (i = 100; i > 0; --i)
    {
        for (j = 0; j < NUM_LEDS; ++j)
            softPwmWrite(ledMap[j], i);
        delay(10);
    }
    printf("Press any key....");
    fgets(buf, 80, stdin);

    for (;;)
    {
        for (i = 0; i < NUM_LEDS; ++i)
            softPwmWrite(ledMap[i], values[i]);

        delay(50);

        i = values[0];
        for (j = 0; j < NUM_LEDS - 1; ++j)
            values[j] = values[j + 1];
        values[NUM_LEDS - 1] = i;
    }
}
