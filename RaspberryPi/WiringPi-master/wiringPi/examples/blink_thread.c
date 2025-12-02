/*
 * blink-thread.c:
 *	Standard "blink" program in wiringPi. Blinks an LED connected
 *	to the first GPIO pin.
 *
 * Copyright (c) 2012-2013 Gordon Henderson.
 ***********************************************************************
 * This file is part of wiringPi:
 *      https://github.com/WiringPi/WiringPi
 *
 *    wiringPi is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU Lesser General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    wiringPi is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public License
 *    along with wiringPi.  If not, see <http://www.gnu.org/licenses/>.
 ***********************************************************************
 */

#include <stdio.h>
#include <wiringPi.h>

// LED Pin - wiringPi pin 0 is BCM_GPIO 17.

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
