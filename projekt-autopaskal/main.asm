;
; projekt-autopaskal.asm
;
; Created: 11. 11. 2021 14:30:11
; Author : Lovro
;

.def led_state = r22


.cseg
	.org 	0x00
	rjmp start
	.org INT0addr
	rjmp button_action
	.org 0x34
	.include "volcini-default.asm"
	
    

start:
	rjmp setup

setup:
	call setupUART
	;clr EICRA
	ldi r16, (1<<ISC01)|(1<<ISC00)	
	sts EICRA, r16
	ldi r16, (1<<INT0)				
	out EIMSK, r16					
	;ldi r16, (1<<INTF0)
	;out EIFR, r16
	sei

	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	ldi	r16,(1<<PINB4)		; load 00000001 into register 16
    out     DDRB,r16		; write register 16 to DDRB
    ; out     PORTB,r16	

	clr	r16;,(1<<PIND2)		; load 00000001 into register 16
    out DDRD,r16		; write register 16 to DDRB
	ldi r16,(1<<PIND2)
	out PORTD, r16

	ldi led_state, 0
	;call turn_on_4

	rjmp loop

turn_on_4:
	ldi	r16,(1<<PINB4)		; load 00000001 into register 16
	out PORTB,r16		; write register 16 to PORTB
	ldi led_state, 1
	reti

turn_off_4:
	ldi	r16,(0<<PINB4)		; load xxxxxxx0 into register 16
	out PORTB, r16
	ldi led_state, 0
	ret

button_action:
	ldi r16, 'i'
	call send_char
	ldi r16, 0
	cp led_state, r16
	breq turn_on_4
	call turn_off_4
	reti
	
	

loop:	rjmp    loop			; stay in infinite loop


