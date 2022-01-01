/*
 * main.asm
 *
 *  Created: 14. 11. 2021 19:59:26
 *   Author: Lovro Govekar
 *
 *
 *	DISCLAIMER: ne vem kaj delam, commenti prolly niso accurate
 */ 

/* 
 E = PINB0

 RS = PIND3
 D4 = PIND4
 D5 = PIND5
 D5 = PIND6
 D7 = PIND7
*/

 .cseg
	.org 0x00
	rjmp start
	.org 0x034

start:
	ldi r16, 255
	sts wait_ms, r16
	;-----------INITIALIZE STACK POINTER----------------
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
	;---------------------------------------------------

	;-----------SET OUTPUT PINS-------------------------
	; set DDRD to OUTPUT GOD DAMMNIT + PD2 IN
	ldi r16, 0b1111_1011
    out DDRD,r16
	

	; PB0 - ENABLE display pin
	ldi	r16,(1<<PINB0)
    out DDRB,r16
	;---------------------------------------------------
	ldi r16, 16
	call time_loop
	; dobr zdej pa loh gledate to

	; okej apparently rabm H od func set poslt 2x so here it goes
	call func_set_H
	; in pol rabm ?akat 4.1ms so 5ms
	ldi r16, 6
	call time_loop

	; in to je full function set
	ldi r20, 0x28
	call func_send
	call delay_1ms
	
	; display on
	ldi r20, 0b0000_1111
	call func_send
	call delay_1ms

	; clear display
	ldi r20, 0b0000_0001
	call func_send
	call delay_1ms

	; entry mode set
	ldi r20, 0b0000_0111
	call func_send
	call delay_1ms

	; enables RS
	call enable_PD3

	; load game level
	ldi r16, 0b0011_0001
	ldi r16, 0b0000_0100
	ldi r16, 0b1000_0100
	ldi r16, 0b0011_0001
	sts line1H, r16
	sts line2H, r16

	sts line1L, r16
	sts line2L, r16

	
	rjmp gameLoop

gameLoop:
	; clear display
	ldi r20, 0b0000_0001 ; 1
	call func_send ; 39
	call delay_1ms ; 16 004

	; goto line 2
	call disable_PD3 ; 7
	ldi r20, 0b1100_0000 ; 1
	call func_send ; 39
	call delay_1ms ; 16 004
	call enable_PD3 ; 7

	ldi r16, 500 ; oz kukrkol bo ostal do 1s
	call time_loop ; 2 + 16 009 * r16
	rjmp gameLoop ; 2
	;rjmp end_loop

time_loop: ; 16 009 * r16
	call delay_1ms ; 16 004
	dec r16 ; 1
	brne time_loop ; 2
	ret ; 2

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

enable_PD3: ; 5 cycles
	in r17, PORTD
	ori r17, 0b0000_1000 ; set PD3
	out PORTD, r17
	ret

disable_PD3: ; 5 cycles
	in r17, PORTD ; 1
	andi r17, 0b1111_0111 ; set PD3 1
	out PORTD, r17 ; 1
	ret ; 2

toggle_enable_pin: ; 9 cycles
	ldi r16,(1<<PINB0) ; 1
	out PORTB, r16 ; 1
	nop ; 1
	nop ; 1
	nop ; 1
	ldi r16,(0<<PINB0) ; 1
	out PORTB, r16 ; 1
	ret ; 2

func_set_H:
	ldi	r20, 0b0010_0000	; naloži parameter (ukaz za lcd) v r20
	mov r21, r20		; kopira r20 v r21
	andi r21, 0b1111_0000	; po?isti L ukaza
	in r17, PORTD		; naloži PORTD v r17
	andi r17, 0b0000_1111 ; po?isti zgornje bite
	or r17, r21			; kombinira r17 in r21
	out PORTD, r17		; nastavi PORTD na r17
	call toggle_enable_pin
	ret

func_send: ; 37 cycles
	mov r21, r20 ; 1
	andi r21, 0b1111_0000 ; 1
	in r17, PORTD ; 1
	andi r17, 0b0000_1111 ; 1
	or r17, r21 ; 1
	out PORTD, r17 ; 1
	call toggle_enable_pin ; 11

	mov r21, r20 ; 1
	swap r21 ; 1
	andi r21, 0b1111_0000 ; 1
	in r17, PORTD ; 1
	andi r17, 0b0000_1111 ; 1
	or r17, r21 ; 1
	out PORTD, r17 ; 1
	call toggle_enable_pin ; 11
	ret ; 2

end_loop:
	rjmp end_loop


.dseg

time_counter: .byte 1
