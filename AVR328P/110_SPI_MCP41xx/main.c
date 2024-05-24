/*
 * MCP410x digital potentiometer
 * SPI communication
 */
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include "uart.h"
#include "pinDefines.h"

#define SLAVE_SELECT    SPI_SS_PORT &= ~(1 << SPI_SS)
#define SLAVE_DESELECT  SPI_SS_PORT |= (1 << SPI_SS)

void SPI_init(void) {
	SPI_SS_DDR |= (1 << SPI_SS); /* set SS output */
	SPI_SS_PORT |= (1 << SPI_SS); /* start off not selected (high) */

	SPI_MOSI_DDR |= (1 << SPI_MOSI); /* output on MOSI */
	SPI_MISO_PORT |= (1 << SPI_MISO); /* pullup on MISO */
	SPI_SCK_DDR |= (1 << SPI_SCK); /* output on SCK */

	SPCR |= (1 << SPR1); /* div 16, safer for breadboards */
	SPCR |= (1 << MSTR); /* clockmaster */
	SPCR |= (1 << SPE); /* enable */
}

void SPI_MasterTransmit(char cData) {
	/* Start transmission */
	SPDR = cData;
	/* Wait for transmission complete */
	while (!(SPSR & (1 << SPIF)))
		;
}

// MCP410x
// Send 0 and byte
// http://ww1.microchip.com/downloads/en/DeviceDoc/11195c.pdf
//
void SPI_writeByte(uint8_t byte) {
	SLAVE_SELECT;
	SPI_MasterTransmit(0);
	SPI_MasterTransmit(byte);
	SLAVE_DESELECT;
}

char SPI_SlaveReceive(void) {
	/* Wait for reception complete */
	while (!(SPSR & (1 << SPIF)))
		;
	/* Return Data Register */
	return SPDR;
}

void InitADC() {
	// For Aref=AVcc;
	ADMUX = (1 << REFS0);
	//Rrescalar div factor =128
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
}

uint16_t ReadADC(uint8_t ch) {
	// Clear lower three bits and set them from chan
	ADMUX = (ADMUX & 0xF8) | (ch & 7);

	//Start Single conversion
	ADCSRA |= (1 << ADSC);

	//Wait for conversion to complete
	while (!(ADCSRA & (1 << ADIF)))
		;

	//Clear ADIF by writing one to it
	//Note you may be wondering why we have write one to clear it
	//This is standard way of clearing bits in io as said in datasheets.
	//The code writes '1' but it result in setting bit to '0' !!!
	ADCSRA |= (1 << ADIF);

	return (ADC);
}

static FILE std_inout = FDEV_SETUP_STREAM(uart_printf,uart_scanf, _FDEV_SETUP_RW);

int main(void) {
	stdin = stdout = &std_inout;

	InitADC();
	SPI_init();
	uart_init(UART_BAUD_SELECT(9600, 16000000L));
	sei();

	while (1) {
		for (int i = 0; i < 255; i++) {
			SPI_writeByte(i);
			printf("Potentio value = %4d, ADC Value = %4d\r\n", i, ReadADC(0));
			_delay_ms(100);
		}
	}

	return 1;
}
