#include <Arduino.h> // Remove this line if you run in the TinkerCAD

#define SW1 5
#define SW2 6
#define SW3 7
#define SW4 8
#define SW5 9
#define SW6 10

volatile char button = 0;
volatile char new_event_flag = false;
char oldButton = button;

// Install Pin change interrupt for a pin, can be called multiple times
void pciSetup(byte pin)
{
    // enable pin
    *digitalPinToPCMSK(pin) |= bit(digitalPinToPCMSKbit(pin));
    // enable interrupt for the group
    PCICR |= bit(digitalPinToPCICRbit(pin));
    // clear any outstanding interrupt
    PCIFR |= bit(digitalPinToPCICRbit(pin));
}

// Use one Routine to handle each group
ISR(PCINT0_vect) // handle pin change interrupt for D8 to D13 here
{
    for (int i = SW4; i <= SW6; i++)
    {
        if (!digitalRead(i))
        {
            button = i;
            new_event_flag = true;
        }
    }
}

// Use one Routine to handle each group
ISR(PCINT2_vect) // handle pin change interrupt for D8 to D13 here
{
    for (int i = SW1; i <= SW3; i++)
    {
        if (!digitalRead(i))
        {
            button = i;
            new_event_flag = true;
        }
    }
}

// 핀 하나하나를 개별적으로 제어하여 프로그램하는 예
void setup()
{
    noInterrupts();
    for (int i = SW1; i <= SW6; i++)
    {
        pinMode(i, INPUT_PULLUP);
        pciSetup(i);
    }
    pinMode(13, OUTPUT);

    Serial.begin(9600);
    interrupts();
}

void loop()
{
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
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