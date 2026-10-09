/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.5 두 번째 코드 = WiringPi-master/examples/serialTest2.c
 * 저작   : 출처 미상의 공개 예제를 강의용으로 수정
 * pigpio : ../serialTest2_pigpio.c
 * 빌드   : gcc -Wall -o serialTest2 serialTest2.c -lwiringPi   (WiringPi 설치 시)
 */
#include <stdio.h> //for printf
#include <stdint.h> //uint8_t definitions
#include <stdlib.h> //for exit(int);
#include <string.h> //for errno
#include <errno.h> //error output
 
//wiring Pi
#include <wiringPi.h>
#include <wiringSerial.h>
 
// Find Serial device on Raspberry with ~ls /dev/tty*
// ARDUINO_UNO "/dev/ttyACM0"
// FTDI_PROGRAMMER "/dev/ttyUSB0"
// HARDWARE_UART "/dev/ttyAMA0"
char device[]= "/dev/ttyAMA0";
// filedescriptor
int fd;
unsigned long baud = 9600;
unsigned long time=0;
 
//prototypes
int main(void);
void loop(void);
void setup(void);
 
void setup(){
 
  printf("%s \n", "Raspberry Startup!");
  fflush(stdout);
 
  //get filedescriptor
  if((fd = serialOpen(device, baud)) < 0){
    fprintf(stderr, "Unable to open serial device: %s\n", strerror(errno));
    exit(1); //error
  }
 
  //setup GPIO in wiringPi mode
  if(wiringPiSetup() == -1){
    fprintf(stdout, "Unable to start wiringPi: %s\n", strerror(errno));
    exit(1); //error
  }
 
}
 
void loop(){
  // Pong every 3 seconds
  if(millis()-time>=3000){
    printf("Sending: Pong!\n"); // 디버그 출력 추가
    serialPuts(fd, "Pong!\n");
    printf("Sending: A\n"); // 디버그 출력 추가
    serialPutchar(fd, 65);
    time=millis();
  }

  // read signal
  if(serialDataAvail(fd)){
    char newChar = serialGetchar(fd);
    printf("Received: %c (ASCII: %d)\n", newChar, newChar); // 디버그 출력 개선
    fflush(stdout);
  }
}
 
// main function for normal c++ programs on Raspberry
int main(){
  setup();
  while(1) 
      loop();
  return 0;
}
