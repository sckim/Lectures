#include <stdio.h>
#include <wiringPi.h>
#define OUTPUT_PIN 1 // GPIO 18
#define INPUT_PIN  0 // GPIO 17
 
int main(void)
{
    printf("Hello, world\n");
    if(wiringPiSetup() == -1) {
        return 1;
    }
 
    pinMode(INPUT_PIN, INPUT);
    pinMode(OUTPUT_PIN, OUTPUT);
    digitalWrite(OUTPUT_PIN, 0);    
    pullUpDnControl(INPUT_PIN, PUD_DOWN);

    while(1) {
        if(digitalRead(INPUT_PIN) == HIGH) {
            printf("digitalRead(INPUT_PIN) : High\n");
            digitalWrite(OUTPUT_PIN, 1);
        } 
        
        if(digitalRead(INPUT_PIN) == LOW) {
            printf("digitalRead(INPUT_PIN) : Low\n");
            digitalWrite(OUTPUT_PIN, 0);
        }
    }
    return 0; 
}