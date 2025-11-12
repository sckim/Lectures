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
