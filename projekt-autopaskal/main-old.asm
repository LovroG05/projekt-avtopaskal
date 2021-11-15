;
; projekt-autopaskal.asm
;
; Created: 11. 11. 2021 14:30:11
; Author : Lovro Govekar
;

.def button_flag = r23
.def last_button_flag = r21


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
	ldi r16, (1<<ISC01)|(0<<ISC00)	
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
    out DDRB,r16		; write register 16 to DDRB

	ldi	r16,(1<<PIND6)		; load  into register 16 ;d7
    out DDRD,r16		; write register 16 to DDRD

	ldi	r16,(1<<PIND3)		; load  into register 16 ;d6
    out DDRD,r16		; write register 16 to DDRD

	ldi	r16,(1<<PIND4)		; load  into register 16 ;d5
    out DDRD,r16		; write register 16 to DDRD

	ldi	r16,(1<<PIND5)		; load  into register 16 ;d4
    out DDRD,r16		; write register 16 to DDRD

	;enable pin
	ldi	r16,(1<<PINB3)		; load 00000001 into register 16
    out DDRB,r16		; write register 16 to DDRB

	ldi R17,100
	call delay

	call function_set
	call clear_display
	call display_on

	clr	r16		; load 00000001 into register 16
    out DDRD,r16		; write register 16 to DDRB
	ldi r16,(1<<PIND2)
	out PORTD, r16

	ldi button_flag, 0
	mov last_button_flag, button_flag
	;call turn_on_4

	rjmp loop

function_set:
	; set to use 4bits
	; send 1st part of function set command
	ldi	r16,(0<<PIND3)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND4)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND5)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(1<<PIND6)		; load xxxxxxx0 into register 16
	out PORTD, r16
	call enable_pin

	;send 2nd part of function set command
	ldi	r16,(0<<PIND3)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(1<<PIND4)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND5)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND6)		; load xxxxxxx0 into register 16
	out PORTD, r16
	call enable_pin
	ret

clear_display:
	; set to use 4bits
	; send 1st part of function set command
	ldi	r16,(0<<PIND3)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND4)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND5)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND6)		; load xxxxxxx0 into register 16
	out PORTD, r16
	call enable_pin

	;send 2nd part of function set command
	ldi	r16,(0<<PIND3)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND4)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND5)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(1<<PIND6)		; load xxxxxxx0 into register 16
	out PORTD, r16
	call enable_pin
	ret

display_on:
	; set to use 4bits
	; send 1st part of function set command
	ldi	r16,(0<<PIND3)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND4)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND5)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(0<<PIND6)		; load xxxxxxx0 into register 16
	out PORTD, r16
	call enable_pin

	;send 2nd part of function set command
	ldi	r16,(1<<PIND3)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(1<<PIND4)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(1<<PIND5)		; load xxxxxxx0 into register 16
	out PORTD, r16

	ldi	r16,(1<<PIND6)		; load xxxxxxx0 into register 16
	out PORTD, r16
	call enable_pin
	ret

enable_pin:
	;toggle enable pin
	ldi	r16,(1<<PINB3)		; load  into register 16
    out PORTB,r16		; write register 16 to DDRD
	ldi R17,6
	rcall delay
	ldi	r16,(0<<PINB3)		; load  into register 16
    out PORTB,r16		; write register 16 to DDRD
	ret

delay:
	ldi XL,Low (16000)
	ldi XH,High (16000)
	ldi YL,Low (1000)
	ldi YH,High (1000)

	push YL
    subi R17,1
    brne delay_ms
    ret

delay_ms:
    sbiw XL,1
    brne delay_ms
    pop XL


set_btn_flag:
	ldi button_flag, 1
	reti

button_action:
	ldi r16, 0
	cp button_flag, r16
	breq set_btn_flag
	;ldi button_flag, 0
	reti
	

loop:
	;cp button_flag, last_button_flag
	;brne toggle_led

	rjmp    loop			; stay in infinite loop
