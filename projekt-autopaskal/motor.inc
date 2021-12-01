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

.macro send_lcd_4bits ; send to lcd in 4bit mode
	ldi	r20, @0			; naloži parameter (ukaz za lcd) v r20
	mov r21, r20		; kopira r20 v r21
	andi r21, 0b1111_0000	; po?isti L ukaza
	in r17, PORTD		; naloži PORTD v r17
	andi r17, 0b0000_1111 ; po?isti zgornje bite
	or r17, r21			; kombinira r17 in r21
	out PORTD, r17		; nastavi PORTD na r17
	toggle_enable_pin

	mov r21, r20		; kopira r20 v r21
	andi r21, 0b0000_1111	; po?sti H ukaza
	swap r21			; zamenja H in L nibbla ukaza, da jih pravilno mappa
	in r17, PORTD		; naloži PORTD v r17
	andi r17, 0b0000_1111 ; po?isti zgornje bite
	or r17, r21			; kombinira r17 in r21
	out PORTD, r17		; nastavi PORTD na r17
	toggle_enable_pin
.endmacro

;0010_1000
; najprej H na pd7-pd4