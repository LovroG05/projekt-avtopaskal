/*
 * main.asm
 *
 *  Created: 14. 11. 2021 19:59:26
 *   Author: Lovro Govekar
 */ 

 .cseg
	.org 0x00
	rjmp start
	.org 0x034
	.include "motor.inc"

start:
	;-----------INITIALIZE STACK POINTER----------------
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
	;---------------------------------------------------

	;-----------SET OUTPUT PINS-------------------------
	; PD3 - RS display pin
	ldi	r16,(1<<PIND3)
    out DDRD,r16
	out PIND,r16 ; set RS to instruction

	; PD4 - D4 display data pin
	ldi	r16,(1<<PIND4)
    out DDRD,r16

	; PD5 - D5 display data pin
	ldi	r16,(1<<PIND5)
    out DDRD,r16

	; PD6 - D6 display data pin
	ldi	r16,(1<<PIND6)
    out DDRD,r16

	; PD7 - D7 display data pin
	ldi	r16,(1<<PIND7)
    out DDRD,r16

	; PB0 - ENABLE display pin
	ldi	r16,(1<<PINB0)
    out DDRB,r16
	;---------------------------------------------------
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	call delay_1ms
	; ne tega ni noben vidu ssssssh

	; function set command
	send_lcd_4bits 0b0010_1000
	call delay_1ms

	;display on/off command
	send_lcd_4bits 0b0000_1111
	call delay_1ms
	rjmp loop

delay_1ms:
	ldi  r18, 21
	ldi  r19, 199
	call L1
	ret

L1: dec  r19
    brne L1
    dec  r18
    brne L1
	ret

loop:
	rjmp loop