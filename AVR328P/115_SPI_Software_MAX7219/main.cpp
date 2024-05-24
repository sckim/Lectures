#include <avr/io.h>
#include <util/delay.h>

#include "myMAX7219.h"

unsigned long delaytime = 100;

LedControl lc = LedControl(11, 13, 10, 2);

/*
 This function lights up a some Leds in a row.
 The pattern will be repeated on every row.
 The pattern will blink along with the row-number.
 row number 4 (index==3) will blink 4 times etc.
 */
void rows() {
	for (int row = 3; row < 8; row++) {
		lc.setRow(0, row, 0b10100000);
		_delay_ms(delaytime);
		lc.setRow(1, row, 0b10110000);
		_delay_ms(delaytime);
		lc.setRow(0, row, (byte) 0);
		for (int i = 0; i < row; i++) {
			_delay_ms(delaytime);
			lc.setRow(0, row, 0b10100000);
			_delay_ms(delaytime);
			lc.setRow(0, row, (byte) 0);
		}
	}
}

/*
 This function lights up a some Leds in a column.
 The pattern will be repeated on every column.
 The pattern will blink along with the column-number.
 column number 4 (index==3) will blink 4 times etc.
 */
void columns() {
	for (int col = 0; col < 8; col++) {
		_delay_ms(delaytime);
		lc.setColumn(0, col, 0b10100000);
		_delay_ms(delaytime);
		lc.setColumn(0, col, (byte) 0);
		for (int i = 0; i < col; i++) {
			_delay_ms(delaytime);
			lc.setColumn(0, col, 0b10100000);
			_delay_ms(delaytime);
			lc.setColumn(0, col, (byte) 0);
		}
	}
}

/*
 This function will light up every Led on the matrix.
 The led will blink along with the row-number.
 row number 4 (index==3) will blink 4 times etc.
 */
void single() {
	for (int row = 0; row < 8; row++) {
		for (int col = 0; col < 8; col++) {
			_delay_ms(delaytime);
			lc.setLed(0, row, col, true);
			_delay_ms(delaytime);
			for (int i = 0; i < col; i++) {
				lc.setLed(0, row, col, false);
				_delay_ms(delaytime);
				lc.setLed(0, row, col, true);
				_delay_ms(delaytime);
			}
		}
	}
}

int main(void) {
	lc.shutdown(0, false);
	lc.shutdown(1, false);
//	/* Set the brightness to a medium values */
	lc.setIntensity(0, 8);
	lc.setIntensity(1, 8);
//	/* and clear the display */
	lc.clearDisplay(0);
	lc.clearDisplay(1);

	while (1) {
		for (int row = 3; row < 8; row++) {
			lc.setRow(1, row, 0b10100000);
			_delay_ms(100);
		}
		rows();
		columns();
	}

	return 1;
}
