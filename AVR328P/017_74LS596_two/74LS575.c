#include <avr/io.h>
#include <util/delay.h>

#include "74LS575.h"

//Initialize HC595 System
void HC595Init() {
	//Make the Data(DS), Shift clock (SH_CP), Store Clock (ST_CP) lines output
	sbi(LS595_DDR, LS595_DS_POS);
	sbi(LS595_DDR, LS595_SH_CP_POS);
	sbi(LS595_DDR, LS595_ST_CP_POS);
}

//Low level macros to change data (DS)lines
#define LS595DataHigh() sbi(LS595_PORT, LS595_DS_POS)
#define LS595DataLow() cbi(LS595_PORT,LS595_DS_POS)

//Sends a clock pulse on SH_CP line
void HC595Pulse() {
	//Pulse the Shift Clock
	sbi(LS595_PORT, LS595_SH_CP_POS);
	cbi(LS595_PORT, LS595_SH_CP_POS);
}

//Sends a clock pulse on ST_CP line
void HC595Latch() {
	//Pulse the Store Clock

	sbi(LS595_PORT, LS595_ST_CP_POS);
	_delay_loop_1(1);

	cbi(LS595_PORT, LS595_ST_CP_POS);
	_delay_loop_1(1);
}

/*

 Main High level function to write a single byte to
 Output shift register 74HC595.

 Arguments:
 single byte to write to the 74HC595 IC

 Returns:
 NONE

 Description:
 The byte is serially transfered to 74HC595
 and then latched. The byte is then available on
 output line Q0 to Q7 of the HC595 IC.

 */

void shiftOut(uint8_t val, uint8_t bitOrder) {
	uint8_t i;

	for (i = 0; i < 8; i++) {
		if (bitOrder == LSBFIRST)	{
			if(val & (1 << i))
				LS595DataHigh();
			else
				LS595DataLow();
		}
		else{
			if(val & (1 << (7 - i)))
				LS595DataHigh();
			else
				LS595DataLow();
		}
		HC595Pulse();
	}
	HC595Latch();
}

void HC595Write(uint8_t data) {
	uint8_t temp_data;

	//Send each 8 bits serially
	//Order is MSB first
	temp_data = data;
	for (uint8_t i = 0; i < 8; i++) {
		//Output the data on DS line according to the
		//Value of MSB
		if (data & 0b10000000) {
			//MSB is 1 so output high

			LS595DataHigh();
		} else {
			//MSB is 0 so output high
			LS595DataLow();
		}
		HC595Pulse();  //Pulse the Clock line
		data = data << 1;  //Now bring next bit at MSB position
	}

	data = temp_data;
	for (uint8_t i = 0; i < 8; i++) {
		//Output the data on DS line according to the
		//Value of MSB
		if (data & 0b10000000) {
			//MSB is 1 so output high

			LS595DataHigh();
		} else {
			//MSB is 0 so output high
			LS595DataLow();
		}
		HC595Pulse();  //Pulse the Clock line
		data = data << 1;  //Now bring next bit at MSB position
	}

//	for (uint8_t i = 0; i < 8; i++) {
//		//Output the data on DS line according to the
//		//Value of MSB
//		if (data & 0b10000000) {
//			//MSB is 1 so output high
//
//			LS595DataHigh();
//		} else {
//			//MSB is 0 so output high
//			LS595DataLow();
//		}
//		HC595Pulse();  //Pulse the Clock line
//		data = data << 1;  //Now bring next bit at MSB position
//	}

	//Now all 8 bits have been transferred to shift register
	//Move them to output latch at one
	HC595Latch();
}
