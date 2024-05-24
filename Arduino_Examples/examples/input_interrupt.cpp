#define interruptPin1 2
#define interruptPin2 3

#define builtinled  13
#define ledPin1  12
#define ledPin2  11
  
//const byte ledPin = 13;
//const byte interruptPin = 2;
volatile byte state1 = LOW; //state of pin 12
volatile byte state2 = LOW; //state of pin 11

void blink1() {
  state1 = !state1; // toggle the state
  digitalWrite(ledPin1, state1);
  
}
void blink2() {
  state2 = !state2; // toggle the state
  digitalWrite(ledPin2, state2);
}


void setup() {
  pinMode(interruptPin1, INPUT_PULLUP);
  pinMode(interruptPin2, INPUT_PULLUP);
  
  pinMode(ledPin1, OUTPUT);
  digitalWrite(ledPin1, state1);
  
  pinMode(ledPin2, OUTPUT);
  digitalWrite(ledPin2, state2);
  
  attachInterrupt(digitalPinToInterrupt(interruptPin1), blink1, FALLING);
  attachInterrupt(digitalPinToInterrupt(interruptPin2), blink2, CHANGE);

}

void loop() {

  digitalWrite(builtinled, HIGH);
  delay(500);
  digitalWrite(builtinled, LOW);
  delay(500);

}