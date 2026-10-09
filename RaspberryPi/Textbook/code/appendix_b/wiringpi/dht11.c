/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §9.3.2 dht11.c
 * 저작   : 출처 미상의 공개 예제(널리 퍼진 DHT11 wiringPi 예제)
 * pigpio : ../dht11_pigpio.c
 * 비고   : 강의 문서에는 줄바꿈이 모두 사라진 한 줄로 보관되어 있어, 줄바꿈과 들여쓰기만 복원했다(토큰은 원문과 동일).
 * 빌드   : gcc -Wall -o dht11 dht11.c -lwiringPi   (WiringPi 설치 시)
 */
#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#define MAXTIMINGS 85
#define DHTPIN 29

int dht11_dat[5] = {0, 0, 0, 0, 0};

void read_dht11_dat()
{
    uint8_t laststate = HIGH;
    uint8_t counter = 0;
    uint8_t j = 0, i;
    float f; /* fahrenheit */

    dht11_dat[0] = dht11_dat[1] = dht11_dat[2] = dht11_dat[3] = dht11_dat[4] = 0;

    /* pull pin down for 18 milliseconds */
    pinMode(DHTPIN, OUTPUT);
    digitalWrite(DHTPIN, LOW);
    delay(18);
    /* then pull it up for 40 microseconds */
    digitalWrite(DHTPIN, HIGH);
    delayMicroseconds(40);
    /* prepare to read the pin */
    pinMode(DHTPIN, INPUT);

    /* detect change and read data */
    for (i = 0; i < MAXTIMINGS; i++)
    {
        counter = 0;
        while (digitalRead(DHTPIN) == laststate)
        {
            counter++;
            delayMicroseconds(1);
            if (counter == 255)
            {
                break;
            }
        }
        laststate = digitalRead(DHTPIN);

        if (counter == 255)
            break;

        /* ignore first 3 transitions */
        if ((i >= 4) && (i % 2 == 0))
        {
            /* shove each bit into the storage bytes */
            dht11_dat[j / 8] <<= 1;
            if (counter > 16)
                dht11_dat[j / 8] |= 1;
            j++;
        }
    }

    /*
     * check we read 40 bits (8bit x 5 ) + verify checksum in the last byte
     * print it out if data is good
     */
    if ((j >= 40) &&
        (dht11_dat[4] == ((dht11_dat[0] + dht11_dat[1] + dht11_dat[2] + dht11_dat[3]) & 0xFF)))
    {
        f = dht11_dat[2] * 9. / 5. + 32;
        printf("Humidity = %d.%d %% Temperature = %d.%d *C (%.1f *F)\n",
               dht11_dat[0], dht11_dat[1], dht11_dat[2], dht11_dat[3], f);
    }
    else
    {
        printf("Data not good, skip\n");
    }
}

int main(void)
{
    printf("Raspberry Pi wiringPi DHT11 Temperature test program\n");

    if (wiringPiSetup() == -1)
        exit(1);

    while (1)
    {
        read_dht11_dat();
        delay(1000); /* wait 1sec to refresh */
    }

    return (0);
}
