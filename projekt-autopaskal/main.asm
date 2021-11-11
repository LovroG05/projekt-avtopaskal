;
; projekt-autopaskal.asm
;
; Created: 11. 11. 2021 14:30:11
; Author : Lovro
;


	.org 	0x00
	
    

start:
	call setup
	call turn_on_4

	rjmp loop

setup:
	ldi	r16,(1<<PINB4)		; load 00000001 into register 16
    out     DDRB,r16		; write register 16 to DDRB

	ret

turn_on_4:
	ldi	r16,(1<<PINB4)		; load 00000001 into register 16
	out     PORTB,r16		; write register 16 to PORTB
	ret

turn_off_4:
	ldi	r16,(0<<PINB4)		; load xxxxxxx0 into register 16
	out PORTB, r16
	ret
	
	

loop:	rjmp    loop			; stay in infinite loop


