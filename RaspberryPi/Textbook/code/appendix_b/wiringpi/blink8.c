/*
 * [부록 B 참고용 원본: WiringPi 판, 본문은 수정하지 않음]
 * 출처   : Raspberry Pi Codes §4.1.2 blink8.c = WiringPi-master/examples/blink8.c
 * 저작   : Gordon Henderson, wiringPi 예제 (LGPLv3). 저작권 고지는 원 파일 머리말 참고
 * pigpio : ../blink8_pigpio.c
 * 빌드   : gcc -Wall -o blink8 blink8.c -lwiringPi   (WiringPi 설치 시)
 */
/*
 * blink8.c:
 *	Simple sequence over the first 8 GPIO pins - LEDs
 *	Aimed at the Gertboard, but it's fairly generic.
 *
 * Copyright (c) 2012-2013 Gordon Henderson.
 ***********************************************************************
 * This file is part of wiringPi:
 *      https://github.com/WiringPi/WiringPi
 *
 *    wiringPi is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU Lesser General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    wiringPi is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public License
 *    along with wiringPi.  If not, see <http://www.gnu.org/licenses/>.
 ***********************************************************************
 */

#include <stdio.h>
#include <wiringPi.h>

int main (void)
{
  int i, led ;

  printf ("Raspberry Pi - 8-LED Sequencer\n") ;
  printf ("==============================\n") ;
  printf ("\n") ;
  printf ("Connect LEDs to the first 8 GPIO pins and watch ...\n") ;

  wiringPiSetup () ;

  for (i = 0 ; i < 8 ; ++i)
    pinMode (i, OUTPUT) ;

  for (;;)
  {
    for (led = 0 ; led < 8 ; ++led)
    {
      digitalWrite (led, 1) ;
      delay (100) ;
    }

    for (led = 0 ; led < 8 ; ++led)
    {
      digitalWrite (led, 0) ;
      delay (100) ;
    }
  }
}
