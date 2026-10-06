/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.1.5 첫 번째 코드 (저장소의 examples/blink_thread.c는 두 스레드 판이므로 문서 판을 옮김)
 * 저작   : Gordon Henderson, wiringPi 예제 (LGPLv3). 강의용으로 정리
 * pigpio : ../blink_thread_pigpio.c
 * 빌드   : gcc -Wall -o blink_thread blink_thread.c -lwiringPi   (WiringPi 설치 시)
 */
#include <stdio.h>
#include <wiringPi.h>

// LED Pin - wiringPi pin 0 is BCM_GPIO 17.

#define LED 0

PI_THREAD (blinky)
{
  for (;;)
  {
    digitalWrite (LED, HIGH) ; // On
    delay (500) ;  // mS
    digitalWrite (LED, LOW) ; // Off
    delay (500) ;
  }
}


int main (void)
{
  printf ("Raspberry Pi blink\n") ;

  wiringPiSetup () ;
  pinMode (LED, OUTPUT) ;

  piThreadCreate (blinky) ;

  for (;;)
  {
    printf ("Hello, world\n") ;
    delay (2000) ;
  }

  return 0 ;
}
