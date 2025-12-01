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