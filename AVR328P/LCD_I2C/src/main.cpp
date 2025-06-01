#include <Arduino.h>
#include <LiquidCrystal_PCF8574.h>

LiquidCrystal_PCF8574 lcd(0x20); // set the LCD address to 0x27 for a 20 chars and 4 line display

void setup()
{
  Serial.begin(115200);
  Serial.println("LCD...");

  // wait on Serial to be available on Leonardo
  while (!Serial)
    ;

  Serial.println("Probing for PCF8574 on address 0x20...");

  lcd.begin(16,2);
  lcd.setBacklight(HIGH); // initialize the lcd
  // Print a message to the LCD.
  lcd.home();  // set the cursor to (0,0)
  lcd.clear(); // clear the display
  lcd.print("Hello, world!");
  lcd.setCursor(2, 1);
  lcd.print("HKNU Univ.");
}

void loop()
{
}