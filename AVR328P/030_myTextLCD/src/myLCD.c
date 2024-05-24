//Using my LCD lib

#include <avr/io.h>
#include <util/delay.h>

#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))

#define LDP PORTD	//define MCU port connected to LCD data pins
#define LCP PORTB	//define MCU port connected to LCD control pins

#define LDDR DDRD	//define MCU direction register for port connected to LCD data pins
#define LCDR DDRB	//define MCU direction register for port connected to LCD control pins

#define RS_SET		sbi(LCP,0)
#define RS_CLEAR	cbi(LCP,0)
#define RW_SET		sbi(LCP,1)
#define RW_CLEAR	cbi(LCP,1)
#define E_SET		sbi(LCP,2)
#define E_CLEAR		cbi(LCP,2)

//#define LED_TurnOn 	sbi(PORTC,3)
//#define LED_TurnOff	cbi(PORTC,3)

unsigned char display_data1[ ]="   HANKYONG";
unsigned char display_data2[ ]="   UNIVERSITY  ";

void lcd_enable(void)
{
	E_SET;
	_delay_ms(1);
	E_CLEAR;
}

// Function Set
// RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
// === === === === === === === === === ===
//  0   0   0   0   1   DL  N   F   *   *
//
// DL : (1) 8bits, (0) 4bits
//
// N: Sets number of display lines
// F: Sets character font
//   display Character  Duty
// N F  lines    Font    Factor Remarks
// === ======= ========= ====== =======
// 0 0    1    5x 7 dots  1/8    -
// 0 1    1    5x10 dots  1/11   -
// 1 *    2    5x 7 dots  1/16  Cannot display 2 lines with 5x10 dot character font

void lcd_command(unsigned char lcd_data)
{
	//_delay_ms(100);
	//lcd_busy();
	RW_CLEAR;
	RS_CLEAR;

	LDP = lcd_data;

	lcd_enable();
	//lcd_busy();
}

// Display on
// RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
// === === === === === === === === === ===
// 0   0   0   0   0   0   1   D   C   B
// D: Display
// C: Cursor
// B: blink

void lcd_OnOff(unsigned char on)
{
	if( on ) {
		lcd_command(0x0C);
	}
	else {
		lcd_command(0x08);
	}
}

void lcd_Clear(void)
{
	lcd_command(0x01);
}

void lcd_CursorHome(void)
{
	lcd_command(0x02);
}

void lcd_CursorMove2ndLine(void)
{
	lcd_command(0xc0);
}

void lcd_write_char(unsigned char lcd_data)
{
	//lcd_busy();
	//_delay_ms(10);
	RW_CLEAR;
	RS_SET;
	LDP = lcd_data;
	lcd_enable();
	RS_CLEAR;
	RW_SET;
}

void lcd_display(void)
{
	unsigned char i;

	// LED_TurnOn;
	lcd_CursorHome();
	for(i=0; i<16; i++) {
		lcd_write_char(display_data1[i]);
		_delay_ms(10);
	}

	lcd_CursorMove2ndLine();
	for(i=0; i<16; i++) {
		lcd_write_char(display_data2[i]);
		_delay_ms(10);
	}
	// LED_TurnOn;
}

// 0: Display On
// 1: Cursor on
// 2: Cursor blink
void lcd_CursorOnOff(unsigned char on)
{
	switch( on ) {
		case 1: lcd_command(0x0E); break;
		case 2: lcd_command(0x0D); break;
		default: lcd_OnOff(1);
	}
}


void lcd_init(void)
{
	E_CLEAR;
	_delay_ms(20);
	//lcd_func_set();
	lcd_command(0x38);
	_delay_ms(5);
	//lcd_func_set();
	lcd_command(0x38);
	_delay_ms(1);
	//lcd_func_set();
	lcd_command(0x38);
	_delay_ms(1);

	// Set the display aline and character font
	lcd_command(0x38);
	// Display clear
	lcd_command(0x01);
	lcd_OnOff(1);
	lcd_CursorOnOff(1);
	// Entry Mode set
	// RS  R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0
	// === === === === === === === === === ===
	// 0   0   0   0   0   0   0   1  I/D  S
	// I/D : (1) increment (0) decrement
	// S : (1) shift (0) fixed
	lcd_command(0x06);
}

int main(void)
{
	LDDR = 0xff;
	LCDR = 0x07;

	LDP = 0x00;

	lcd_init();

	while(1) {
		lcd_display();
		_delay_ms(100);
		lcd_Clear();
	};

}
