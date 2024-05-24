/*
 * main.c
 *
 *  Created on: 2019. 11. 15.
 *      Author: Soochan Kim
 */

#include <avr/io.h>
#include <util/delay.h>

#define motor_pin_1	PD0
#define motor_pin_2	PD1
#define motor_pin_3	PD2
#define motor_pin_4	PD3
#define motor_port	PORTD

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

void stepMotor(int thisStep)
{
	switch (thisStep) {
		case 0:  // 1000
		cbi(motor_port, motor_pin_1);
		cbi(motor_port, motor_pin_2);
		cbi(motor_port, motor_pin_3);
		sbi(motor_port, motor_pin_4);
		break;
		case 1:// 1100
		cbi(motor_port, motor_pin_1);
		cbi(motor_port, motor_pin_2);
		sbi(motor_port, motor_pin_3);
		sbi(motor_port, motor_pin_4);
		break;
		case 2://0100
		cbi(motor_port, motor_pin_1);
		cbi(motor_port, motor_pin_2);
		sbi(motor_port, motor_pin_3);
		cbi(motor_port, motor_pin_4);
		break;
		case 3://0110
		cbi(motor_port, motor_pin_1);
		sbi(motor_port, motor_pin_2);
		sbi(motor_port, motor_pin_3);
		cbi(motor_port, motor_pin_4);
		break;
		case 4:  // 0010
		cbi(motor_port, motor_pin_1);
		sbi(motor_port, motor_pin_2);
		cbi(motor_port, motor_pin_3);
		cbi(motor_port, motor_pin_4);
		break;
		case 5:// 0011
		sbi(motor_port, motor_pin_1);
		sbi(motor_port, motor_pin_2);
		cbi(motor_port, motor_pin_3);
		cbi(motor_port, motor_pin_4);
		break;
		case 6://0001
		sbi(motor_port, motor_pin_1);
		cbi(motor_port, motor_pin_2);
		cbi(motor_port, motor_pin_3);
		cbi(motor_port, motor_pin_4);
		break;
		case 7://1001
		sbi(motor_port, motor_pin_1);
		cbi(motor_port, motor_pin_2);
		cbi(motor_port, motor_pin_3);
		sbi(motor_port, motor_pin_4);
		break;
		default:
		sbi(motor_port, motor_pin_1);
		cbi(motor_port, motor_pin_2);
		cbi(motor_port, motor_pin_3);
		sbi(motor_port, motor_pin_4);
	}
}

void runMotor(int steps, int dir)
{
	int i;

	if(dir){
		for(i=0; i<steps; i++){
			stepMotor(i%8);
			_delay_ms(1);
		}
	} else	{
		for(i=steps; i>=0; i--){
			stepMotor(i%8);
			_delay_ms(1);
		}
	}
}

int main(void)
{
	DDRD = 0x0F;

	while(1){
		runMotor(100,1);
		//runMotor(100,0);
	}
}
