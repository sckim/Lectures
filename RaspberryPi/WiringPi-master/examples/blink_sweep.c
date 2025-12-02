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
