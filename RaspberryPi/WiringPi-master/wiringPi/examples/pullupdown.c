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