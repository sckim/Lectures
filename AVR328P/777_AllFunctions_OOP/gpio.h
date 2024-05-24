/*
 * gpio.h
 *
 *  Created on: 2019. 7. 2.
 *      Author: Soochan Kim
 */

#ifndef GPIO_H_
#define GPIO_H_

void pinMode(uint8_t pin, uint8_t mode);
void digitalWrite(uint8_t pin, uint8_t val);
int digitalRead(uint8_t pin);
void checkGPIO(void);

#endif /* GPIO_H_ */
