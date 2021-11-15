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
	ldi	r16, @0
	out PORTD, r16
	toggle_enable_pin
.endmacro
