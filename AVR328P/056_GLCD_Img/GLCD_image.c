#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>					/* Include standard i/o library file */
#include "Image.h"
#include "Font_Header.h"

#define Data_Port	 	PORTD		/* Define data port for GLCD */
#define Command_Port	 PORTB		/* Define command port for GLCD */
#define Data_Port_Dir	 DDRD		/* Define data port for GLCD */
#define Command_Port_Dir DDRB		/* Define command port for GLCD */

#define LEFT	0
#define RIGHT	1

#define GLCD_RS		PB0
#define GLCD_RW		PB1
#define GLCD_E		PB2
#define GLCD_CS1	PB3
#define GLCD_CS2	PB4
#define GLCD_RST	PB5

#define TotalPage	 8

void GLCD_Data(char Data)		/* GLCD data function */
{
	Data_Port = Data;		/* Copy data on data pin */
	Command_Port |=  (1 << GLCD_RS);	/* Make RS HIGH for data register */
	Command_Port &= ~(1 << GLCD_RW);	/* Make RW LOW for write operation */

	/* HIGH-LOW transition on Enable */
	Command_Port |=  (1 << GLCD_E);
	_delay_us(3);
	Command_Port &= ~(1 << GLCD_E);
//	_delay_us(5);
}

void GLCD_Command(char Command)		/* GLCD command function */
{
	Data_Port = Command;		/* Copy command on data pin */
	Command_Port &= ~(1 << GLCD_RS);	/* Make RS LOW for command register*/
	Command_Port &= ~(1 << GLCD_RW);	/* Make RW LOW for write operation */

	/* HIGH-LOW transition on Enable */
	Command_Port |=  (1 << GLCD_E);
	_delay_us(3);
	Command_Port &= ~(1 << GLCD_E);
//	_delay_us(5);
}

void SetSide(uint8_t flag)
{
	if( flag==RIGHT ) {
		Command_Port |= (1 << GLCD_CS1);
		Command_Port &= ~(1 << GLCD_CS2);
	} else {
		Command_Port &= ~(1 << GLCD_CS1);
		Command_Port |= (1 << GLCD_CS2);
	}
}

void SetYAddress(uint8_t add)
{
	// 0b01xx xxxx : xx xxxx address
	GLCD_Command(0b01000000 | (add & 0x3F) );
}

void SetPage(uint8_t add)
{
	// 0b1011 1xxx : xx xxxx address
	GLCD_Command(0b10111000 | (add & 0x07) );
}

void SetStartLine(uint8_t add)
{
	// 0b11xx xxxx : xx xxxx address
	GLCD_Command(0b11000000 | (add & 0x3F) );
}

void GLCD_ClearAll()			/* GLCD all display clear function */
{
	int a;

	/* Select both left & right half of display */
	SetSide(LEFT);
	for(int i = 0; i < TotalPage; i++)
	{
		SetPage(i);/* Increment page */
		SetYAddress(0);		/* Set Y address (column=0) */
		a=1;
		for(int j = 0; j < 64; j++)
		{
			GLCD_Data(0xff);	/* Write zeros to all 64 column */
			_delay_ms(1);
		}
	}
	SetYAddress(0);		/* Set Y address (column=0) */
	SetPage(0);				/* Set x address (page=0) */
}

void GLCD_OnOff(uint8_t flag)			/* GLCD initialize function */
{
	if( flag ) {
		SetSide(RIGHT);
		GLCD_Command(0x3F);
		SetSide(LEFT);
		GLCD_Command(0x3F);
	}	else {
		SetSide(RIGHT);
		GLCD_Command(0x3E);
		SetSide(LEFT);
		GLCD_Command(0x3E);
	}
}


void GLCD_Init()			/* GLCD initialize function */
{
	Data_Port_Dir = 0xFF;
	Command_Port_Dir = 0xFF;
	/* Select both left & right half of display & Keep reset pin high */
	Command_Port |= (1 << GLCD_RST);
	Command_Port |= (1 << GLCD_CS1);	/* Select Left half of display */
	Command_Port |= (1 << GLCD_CS2);

	_delay_ms(20);
	GLCD_Command(0x3E);		/* Display OFF */
	GLCD_Command(0x40);		/* Set Y address (column=0) */
	GLCD_Command(0xB8);		/* Set x address (page=0) */
	GLCD_Command(0xC0);		/* Set z address (start line=0) */
	GLCD_Command(0x3F);		/* Display ON */
}

void GLCD_String(const char* image)	/* GLCD string write function */
{
	int column,page,page_add=0xB8,k=0;
	float page_inc=0.5;
	char byte;

	SetSide(LEFT);

	for(page=0;page<2*TotalPage;page++)	/* Print pages(8 page of each half)*/
	{
		for(column=0;column<64;column++)
		{
			byte = pgm_read_byte(&image[k+column]);
			GLCD_Data(~byte);/* Print 64 column of each page */
			// 아래 delay는 proteus에서 시뮬레이션 할때만 추가
			// 이것이 없으니 출력 위치에 문제가 발생함.
			_delay_ms(1);
		}
		Command_Port ^= (1 << GLCD_CS1);/* Change segment controller */
		Command_Port ^= (1 << GLCD_CS2);
		SetPage(page_inc);/* Increment page address*/
		page_inc=page_inc+0.5;
		k=k+64;			/* Increment pointer */
	}
	SetYAddress(0);		/* Set Y address (column=0) */
	SetPage(0);		/* Set x address (page=0) */
}

void GLCD_String_P(char page_no, char *str)/* GLCD string write function */
{
	unsigned int i, column;
	unsigned int Page = ((0xB8) + page_no);
	unsigned int Y_address = 0;
	float Page_inc = 0.5;

	Command_Port |= (1 << GLCD_CS1);	/* Select Left half of display */
	Command_Port &= ~(1 << GLCD_CS2);

	GLCD_Command(Page);
	for(i = 0; str[i] != 0; i++)	/* Print char in string till null */
	{
		if (Y_address > (1024-(((page_no)*128)+FontWidth)))
		break;
		if (str[i]!=32)
		{
			for (column=1; column<=FontWidth; column++)
			{
				if ((Y_address+column)==(128*((int)(Page_inc+0.5))))
				{
					if (column == FontWidth)
					break;
					GLCD_Command(0x40);
					Y_address = Y_address + column;
					Command_Port ^= (1 << GLCD_CS1);
					Command_Port ^= (1 << GLCD_CS2);
					GLCD_Command(Page + Page_inc);
					Page_inc = Page_inc + 0.5;
				}
			}
		}
		if (Y_address>(1024-(((page_no)*128)+FontWidth)))
		break;
		if((font[((str[i]-32)*FontWidth)+4])==0 || str[i]==32)
		{
			for(column=0; column<FontWidth; column++)
			{
				GLCD_Data(font[str[i]-32][column]);
				if((Y_address+1)%64==0)
				{
					Command_Port ^= (1 << GLCD_CS1);
					Command_Port ^= (1 << GLCD_CS2);
					GLCD_Command((Page+Page_inc));
					Page_inc = Page_inc + 0.5;
				}
				Y_address++;
			}
		}
		else
		{
			for(column=0; column<FontWidth; column++)
			{
				GLCD_Data(font[str[i]-32][column]);
				if((Y_address+1)%64==0)
				{
					Command_Port ^= (1 << GLCD_CS1);
					Command_Port ^= (1 << GLCD_CS2);
					GLCD_Command((Page+Page_inc));
					Page_inc = Page_inc + 0.5;
				}
				Y_address++;
			}
			GLCD_Data(0);
			Y_address++;
			if((Y_address)%64 == 0)
			{
				Command_Port ^= (1 << GLCD_CS1);
				Command_Port ^= (1 << GLCD_CS2);
				GLCD_Command((Page+Page_inc));
				Page_inc = Page_inc + 0.5;
			}
		}
	}
	GLCD_Command(0x40);	/* Set Y address (column=0) */
}

int main(void) {
	GLCD_Init();
	GLCD_ClearAll();	/* Clear all GLCD display */
	GLCD_String(img);	/* Print String on 0th page of display */
	GLCD_OnOff(0);
	_delay_ms(1000);
	GLCD_OnOff(1);
	_delay_ms(1000);
	GLCD_OnOff(0);
	_delay_ms(1000);
	GLCD_OnOff(1);
	while(1);
}
