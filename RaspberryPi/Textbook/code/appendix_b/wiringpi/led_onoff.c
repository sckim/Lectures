/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : 저장소 WiringPi/led_onoff.c (Raspberry Pi Codes §4.1.1 blink.c와 같은 코드, 주석만 다름)
 * 저작   : Gordon Henderson, wiringPi 예제 (LGPLv3) - 강의용으로 주석 수정
 * pigpio : ../../ch08/led_blink.c
 * 빌드   : gcc -Wall -o led_onoff led_onoff.c -lwiringPi   (WiringPi 설치 시)
 */
#include <stdio.h>
#include <wiringPi.h>

// LED Pin - wiringPi pin 0 is BCM_GPIO 17.(Broadcom)
//#define LED 17
#define LED 0

int main(void)
{
    printf("Raspberry Pi blink\n");

    // Initializes wiringPi using wiringPi's simlified number system.
    wiringPiSetup();
    //wiringPiSetupGpio();
    // Initializes wiringPi using the Broadcom GPIO pin numbers

    pinMode(LED, OUTPUT);

    for (;;)
    {
        printf("LED on\n");
        digitalWrite(LED, HIGH);
        delay(500); 
        printf("LED off\n");
        digitalWrite(LED, LOW); 
        delay(500);
    }
    return 0;
}
