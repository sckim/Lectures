/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.2.2 = WiringPi-master/examples/gpio_read.c (강의용 추가 예제)
 * 저작   : 강의 작성
 * pigpio : ../../ch08/button_led.c
 * 빌드   : gcc -Wall -o gpio_read gpio_read.c -lwiringPi   (WiringPi 설치 시)
 */
#include <stdio.h>
#include <wiringPi.h>
#define OUTPUT_PIN 1 // GPIO 18
#define INPUT_PIN  0 // GPIO 17
 
int main(void)
{
    printf("Hello, world\n");
    if(wiringPiSetup() == -1) {
        return 1;
    }
 
    pinMode(INPUT_PIN, INPUT);
    pinMode(OUTPUT_PIN, OUTPUT);
    digitalWrite(OUTPUT_PIN, 0);    
    pullUpDnControl(INPUT_PIN, PUD_DOWN);

    while(1) {
        if(digitalRead(INPUT_PIN) == HIGH) {
            printf("digitalRead(INPUT_PIN) : High\n");
            digitalWrite(OUTPUT_PIN, 1);
        } 
        
        if(digitalRead(INPUT_PIN) == LOW) {
            printf("digitalRead(INPUT_PIN) : Low\n");
            digitalWrite(OUTPUT_PIN, 0);
        }
    }
    return 0; 
}
