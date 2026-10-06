/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §9.2.3 rht03.c (WiringPi-master/examples/rht03.c와 들여쓰기만 다름)
 * 저작   : Gordon Henderson, wiringPi 예제 (LGPLv3). 강의용으로 정리
 * pigpio : ../rht03_pigpio.c
 * 비고   : maxdetect.h는 WiringPi devLib에 있다.
 * 빌드   : gcc -Wall -o rht03 rht03.c -lwiringPi -lwiringPiDev   (WiringPi 설치 시)
 */
/*
 * rht03.c:
 * Driver for the MaxDetect series sensors
 */

#include <stdio.h>

#include <wiringPi.h>
#include <maxdetect.h>

#define RHT03_PIN 7

/*
 ***********************************************************************
 * The main program
 ***********************************************************************
 */

int main(void)
{
    int result, temp, rh;
    int minT, maxT, minRH, maxRH;

    int numGood, numBad;

    wiringPiSetup();
    piHiPri(55);

    minT = 1000;
    maxT = -1000;

    minRH = 1000;
    maxRH = -1000;

    numGood = numBad = 0;

    for (;;)
    {
        delay(100);

        result = readRHT03(RHT03_PIN, &temp, &rh);

        if (!result)
        {
            printf(".");
            fflush(stdout);
            ++numBad;
            continue;
        }

        ++numGood;

        if (temp < minT)
            minT = temp;
        if (temp > maxT)
            maxT = temp;
        if (rh < minRH)
            minRH = rh;
        if (rh > maxRH)
            maxRH = rh;

        printf("\r%6d, %6d: ", numGood, numBad);
        printf("Temp: %5.1f, RH: %5.1f%%", temp / 10.0, rh / 10.0);
        printf("  Max/Min Temp: %5.1f:%5.1f", maxT / 10.0, minT / 10.0);
        printf("  Max/Min RH: %5.1f:%5.1f", maxRH / 10.0, minRH / 10.0);

        printf("\n");
    }

    return 0;
}
