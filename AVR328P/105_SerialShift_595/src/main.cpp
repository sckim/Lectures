int pos = 0;

/*
unsigned char lookup[8] = {
    0x01, 0x02, 0x04, 0x08, 0x10,
    0x20, 0x40, 0x80 
};
*/
unsigned char lookup[8] = {
    0b00000001,
    0b00000011,
    0b00000111,
    0b00001111,
    0b00011111,
    0b00111111,
    0b01111111,
    0b11111111};

#ifdef Arduino
#include <avr/io.h>
#include <util/delay.h>

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

#define LSBFIRST 0
#define MSBFIRST 1

#define SerialIn PD3
#define LatchCP PD4
#define ShiftCP PD5

#define cPORT PORTD
#define cDDR DDRD

void shiftOut(uint8_t bitOrder, uint8_t val)
{
    uint8_t i;

    for (i = 0; i < 8; i++)
    {
        if (bitOrder == LSBFIRST)
        {
            if (val & (1 << i))
                sbi(cPORT, SerialIn);
            else
                cbi(cPORT, SerialIn);
        }
        else
        {
            if (val & (1 << (7 - i)))
                sbi(cPORT, SerialIn);
            else
                cbi(cPORT, SerialIn);
        }

        sbi(cPORT, ShiftCP);
        //_delay_ms(100);
        cbi(cPORT, ShiftCP);
    }
}

int main(void)
{
    sbi(cDDR, SerialIn);
    sbi(cDDR, LatchCP);
    sbi(cDDR, ShiftCP);

    while (1)
    {
        shiftOut(MSBFIRST, lookup[pos++ % 8]);

        // Generate latch clock
        cbi(cPORT, LatchCP);
        sbi(cPORT, LatchCP);

        _delay_ms(100);
    }
}
#else
#include <Arduino.h>

#define SerialIn 3
#define LatchCP 4
#define ShiftCP 5

void setup()
{
    pinMode(SerialIn, OUTPUT);
    pinMode(LatchCP, OUTPUT);
    pinMode(ShiftCP, OUTPUT);
}
void loop()
{
    //shiftOut(dataPin, clockPin, bitOrder, value);
    shiftOut(SerialIn, ShiftCP, MSBFIRST, lookup[pos++ % 8]);

    // Generate latch clock
    digitalWrite(LatchCP, LOW);
    digitalWrite(LatchCP, HIGH);

    delay(100);
}
#endif
