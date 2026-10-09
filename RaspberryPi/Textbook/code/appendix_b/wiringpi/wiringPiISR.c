/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.4.2 (출처 링크: github.com/UplinkCoder/wiringpi wiringPiISR.c)
 * 저작   : Gordon Henderson, wiringPi 라이브러리 내부 코드 (LGPLv3)
 * pigpio : ../wiringPiISR_pigpio.c
 * 비고   : 강의 문서에 붙여 넣은 발췌본으로, 끝부분이 잘려 있고 변수 선언(modes, fName)이 빠져 있어 컴파일되지 않는다.
 *        또한 pthread_create에 지역 변수 pin의 주소(&pin)를 넘겨, 스레드가 읽기 전에 값이 사라질 수 있다.
 */
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>#include <pthread.h>

#include "wiringPi.h"

static void (*isrFunctions [64])(void) ;
static int    isrFds       [64] ;

/*
 * interruptHandler:
 * This is a thread and gets started to wait for the interrupt we're
 * hoping to catch. It will call the user-function when the interrupt
 * fires.
 *********************************************************************************
 */

static void *interruptHandler (void *arg)
{
  int pin = *(int *)arg ;

  (void)piHiPri (55) ;

  for (;;)
  {
    if (waitForInterrupt (pin, -1) > 0)
      isrFunctions [pin] () ;
  }

  return NULL ;
}

/*
 * wiringPiISR:
 * Take the details and create an interrupt handler that will do a call-
 * back to the user supplied function.
 *********************************************************************************
 */

int wiringPiISR (int pin, int mode, void (*function)(void))
{
  pthread_t threadId ;
  char command [64] ;

  pin &= 63 ;

  if (wiringPiMode == WPI_MODE_UNINITIALISED)
  {
    fprintf (stderr, "wiringPiISR: wiringPi has not been initialised. Unable to continue.\n") ;
    exit (EXIT_FAILURE) ;
  }
  else if (wiringPiMode == WPI_MODE_PINS)
    pin = pinToGpio [pin] ;


  isrFunctions [pin] = function ;

// Now export the pin and set the right edge

  if (mode != INT_EDGE_SETUP)
  {
    /**/ if (mode == INT_EDGE_FALLING)
      modes = "falling" ;
    else if (mode == INT_EDGE_RISING)
      modes = "rising" ;
    else
      modes = "both" ;

    sprintf (command, "/usr/local/bin/gpio edge %d %s", pin, modes) ;
    system (command) ;
  }

  sprintf (fName, "/sys/class/gpio/gpio%d/value", pin) ;
  if ((isrFds [pin] = open (fName, O_RDWR)) < 0)
    return -1 ;

  {
    fprintf ("std

  pthread_create(&threadId, NULL, interruptHandler, &pin) ;
}
