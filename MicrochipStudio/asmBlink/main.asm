;
; asmBlink.asm
;
; Created: 2024-09-25 오전 2:12:45
; Author : Soochan Kim
;


; Replace with your application code
Setup:
    	sbi DDRB,DDB5 ; pinMode(PB5, HIGH)
 
Loop:
    	cbi PORTB,PB5 ; digitalWrite(PB5, LOW) 
    	sbi PORTB,PB5 ; digitalWrite(PB5, HIGH) 
    	rjmp Loop ; Jump relative back to label Loop, 2 clock cycles
