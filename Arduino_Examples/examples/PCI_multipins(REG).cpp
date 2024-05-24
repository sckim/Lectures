#include <Arduino.h> // Remove this line if you run in the TinkerCAD

#define SW1 5 // PD5
#define SW2 6 // PD6
#define SW3 7 // PD7

#define SW4 8  // PB0
#define SW5 9  // PB1
#define SW6 10 // PB2

volatile char button = 0;
volatile char new_event_flag = false;
char oldButton = button;

// Use one Routine to handle each group
// handle pin change interrupt for D8 to D13 here
ISR(PCINT0_vect)
{
    uint8_t pinStatus = PINB;

    for (int i = SW4 - SW4; i <= SW6 - SW4; i++)
    {
        if (!(pinStatus & (1 << i)))
        {
            button = i + SW4;
            new_event_flag = true;
        }
    }
}

// Use one Routine to handle each group
// handle pin change interrupt for D0 to D7 here
ISR(PCINT2_vect)
{
    uint8_t pinStatus = PIND;

    for (int i = SW1; i <= SW3; i++)
    {
        if (!(pinStatus & (1 << i)))
        {
            button = i;
            new_event_flag = true;
        }
    }
}

// 핀 하나하나를 개별적으로 제어하여 프로그램하는 예
void setup()
{
    // set Output
    DDRB |= (1 << PB5);

    // enable internal pull up resistor
    PORTB |= (1 << PB0);
    PORTB |= (1 << PB1);
    PORTB |= (1 << PB2);

    // enable internal pull up resistor
    PORTD |= (1 << PD5);
    PORTD |= (1 << PD6);
    PORTD |= (1 << PD7);

    // enable pin change interrupt for pin...
    PCICR |= _BV(PCIE0);
    PCICR |= _BV(PCIE2);

    PCMSK0 |= (_BV(PCINT0) | _BV(PCINT1) | _BV(PCINT2));    // PB0, 1, 2
    PCMSK2 |= (_BV(PCINT21) | _BV(PCINT22) | _BV(PCINT23)); // PD5, 6, 7

    Serial.begin(9600);
}

void loop()
{
    PORTB |= (1 << PB5);
    delay(100);
    PORTB &= ~(1 << PB5);
    delay(100);

    if (oldButton != button || new_event_flag)
    {
        Serial.print("Button ");
        Serial.print(button, DEC);
        Serial.println(" was pressed");
        oldButton = button;
        new_event_flag = false;
    }
}