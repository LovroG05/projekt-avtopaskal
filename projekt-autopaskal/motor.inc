/*
 * motor.inc
 *
 *  Created: 14. 11. 2021 21:40:33
 *   Author: Lovro Govekar
 */ 

 .macro toggle_enable_pin
	ldi r16,(1<<PINB3)
	out PORTB, r16
	call delay_1ms
	ldi r16,(0<<PINB3)
	out PORTB, r16
.endmacro

 .macro send_lcd_4bits
	ldi	r20, @0
	andi r21, 0b1111_0000
	in r17, PORTD
	or r17, r21
	out PORTD, r17
	toggle_enable_pin
	andi r21, 0b0000_1111
	in r17, PORTD
	or r17, r21
	out PORTD, r17
	toggle_enable_pin
.endmacro

;0010_1000
; najprej H na pd7-pd4