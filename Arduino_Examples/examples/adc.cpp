#include <Arduino.h> // Remove this line if you run in the TinkerCAD
void setup()
{
  Serial.begin(9600);
}

unsigned int values[6];

void loop()
{
  for(uint8_t i=A0; i <= A5; i++) {
  	values[i] = analogRead(i);
  	Serial.print(values[i]);
    Serial.print(", ");
  }
  Serial.println();
  
  delay(500);
}