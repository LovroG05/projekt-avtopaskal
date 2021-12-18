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
	; set DDRD to OUTPUT GOD DAMMNIT
	ser r16
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

	
	rjmp gameLoop

gameLoop:
	

	lds r16, wait_ms
	call time_loop
	lds r16, wait_ms
	dec r16
	sts wait_ms, r16 ; TODO nared da ni usak cikeLJ
	rjmp gameLoop
	rjmp end_loop

time_loop:
	call delay_1ms
	dec r16
	brne time_loop
	ret

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

enable_PD3:
	in r17, PORTD
	ori r17, 0b0000_1000 ; set PD3
	out PORTD, r17
	ret

disable_PD3:
	in r17, PORTD
	andi r17, 0b1111_0111 ; set PD3
	out PORTD, r17
	ret

toggle_enable_pin:
	ldi r16,(1<<PINB0)
	out PORTB, r16
	nop
	nop
	nop
	ldi r16,(0<<PINB0)
	out PORTB, r16
	ret

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

func_send:
	mov r21, r20
	andi r21, 0b1111_0000
	in r17, PORTD
	andi r17, 0b0000_1111
	or r17, r21
	out PORTD, r17
	call toggle_enable_pin

	mov r21, r20
	swap r21
	andi r21, 0b1111_0000
	in r17, PORTD
	andi r17, 0b0000_1111
	or r17, r21
	out PORTD, r17
	call toggle_enable_pin
	ret

end_loop:
	rjmp end_loop


.dseg

line1: .byte 2
line1pointer: .byte 1

line2: .byte 2
line2pointer: .byte 1

wait_ms: .byte 1

line1carry: .byte 1
line2carry: .byte 1