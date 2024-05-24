/***************************************
 Configure Connections
 ****************************************/

#ifndef	_74LS575_H
#define _74LS575_H  1

#define LS595_PORT   PORTD
#define LS595_DDR    DDRD

#define LS595_DS_POS PD2      //Data pin (DS) pin location

#define LS595_SH_CP_POS PD3      //Shift Clock (SH_CP) pin location
#define LS595_ST_CP_POS PD4      //Store Clock (ST_CP) pin location

#define LSBFIRST 0
#define MSBFIRST 1

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

/***************************************
 Configure Connections ***ENDS***
 ****************************************/

//Initialize HC595 System
void HC595Init();

//Low level macros to change data (DS)lines
#define LS595DataHigh() sbi(LS595_PORT, LS595_DS_POS)
#define LS595DataLow() cbi(LS595_PORT,LS595_DS_POS)

//Sends a clock pulse on SH_CP line
void HC595Pulse();
//Sends a clock pulse on ST_CP line
void HC595Latch();
void HC595Write(uint8_t data);

void shiftOut(uint8_t val, uint8_t bitOrder);

#endif
