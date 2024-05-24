;
; asmBlink.asm
;
; Created: 2021-10-02 오후 1:36:30
; Author : Soochan Kim
;
;.INCLUDE "m328Pdef.inc"    ; NO SE QUE SIGNIFICA ESTO

#define	PORTB 0x05
#define DDRB  0x04
#define PB5	  5

.global main

; Replace with your application code
main:
    	sbi DDRB, PB5 ; pinMode(PB5, HIGH)
 
Loop:
    	cbi PORTB, PB5 ; digitalWrite(PB5, LOW) 
    	sbi PORTB, PB5 ; digitalWrite(PB5, HIGH) 
    	rjmp Loop ; Jump relative back to label Loop, 2 clock cycles
