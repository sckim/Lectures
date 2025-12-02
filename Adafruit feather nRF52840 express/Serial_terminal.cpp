#include <Adafruit_TinyUSB.h>

#define SERIAL_PRINT  Serial
#define SERIAL_UART   Serial1

void setup() {
   // 하드웨어 시리얼 통신 초기화 (기본 RX:0, TX:1 핀 사용)
   SERIAL_PRINT.begin(115200); // for Debug
   SERIAL_UART.begin(115200);  // to Raspberry Pi
}

void loop() {
   // Arduino IDE로 입력
   if (SERIAL_PRINT.available()) {
     char receivedChar = Serial.read();

     SERIAL_UART.write(receivedChar);      // Tx 핀으로 출력
   }
   // Rx 핀으로 수신
   if (SERIAL_UART.available()) {
       char receivedChar = SERIAL_UART.read();

       SERIAL_PRINT.write(receivedChar);   // Arduino IDE로 출력
   }
}
