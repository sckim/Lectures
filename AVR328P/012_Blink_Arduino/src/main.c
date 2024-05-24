/*
 * main.c
 *
 *  Created on: 2017. 10. 27.
 *      Author: Soochan Kim
 */

#include <avr/io.h>
#include <util/delay.h>
#include "Arduino.h"

void setup(void) {
	// initialize digital pin 13 as an output.
	pinMode(13, OUTPUT);
}

// the loop function runs over and over again forever
void loop(void) {

	digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
	delay(1000);              // wait for a second
	//_delay_ms(1000);
	digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
	delay(1000);              // wait for a second
	//_delay_ms(1000);
}

int main(void) {
	init();

	setup();

	for (;;) {
		loop();
	}

	return 0;
}
