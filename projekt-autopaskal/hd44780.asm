;------------------------------------------------------------------------------
; HD44780 LCD Assembly driver
; http://avr-mcu.dxp.pl
; (c) Radoslaw Kwiecien
;------------------------------------------------------------------------------
.include "tn2313def.inc"
.include "hd44780.inc"

.equ	LCD_PORT 	= PORTB
.equ	LCD_DDR		= DDRB
.equ    LCD_PIN		= PINB

.equ	LCD_D4 		= 0
.equ	LCD_D5 		= 1
.equ 	LCD_D6 		= 2
.equ	LCD_D7 		= 3

.equ	LCD_RS		= 4
.equ	LCD_EN		= 6

;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
.dseg
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
.cseg
#include "div8u.asm"
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------	
LCD_WriteNibble:
	sbi		LCD_PORT, LCD_EN

	sbrs	r16, 0
	cbi		LCD_PORT, LCD_D4
	sbrc	r16, 0
	sbi		LCD_PORT, LCD_D4
	
	sbrs	r16, 1
	cbi		LCD_PORT, LCD_D5
	sbrc	r16, 1
	sbi		LCD_PORT, LCD_D5
	
	sbrs	r16, 2
	cbi		LCD_PORT, LCD_D6
	sbrc	r16, 2
	sbi		LCD_PORT, LCD_D6
	
	sbrs	r16, 3
	cbi		LCD_PORT, LCD_D7
	sbrc	r16, 3
	sbi		LCD_PORT, LCD_D7

	cbi		LCD_PORT, LCD_EN
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_WriteData:
	sbi		LCD_PORT, LCD_RS
	push	r16
	swap	r16
	rcall	LCD_WriteNibble
	pop		r16
	rcall	LCD_WriteNibble

	clr		XH
	ldi		XL,250
	rcall	Wait4xCycles
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_WriteCommand:
	cbi		LCD_PORT, LCD_RS
	push	r16
	swap	r16
	rcall	LCD_WriteNibble
	pop		r16
	rcall	LCD_WriteNibble
	ldi		r16,2
	rcall	WaitMiliseconds
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_WriteString:
	lpm		r16, Z+
	cpi		r16, 0
	breq	exit
	rcall	LCD_WriteData
	rjmp	LCD_WriteString
exit:
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_WriteHexDigit:
	cpi		r16,10
	brlo	Num
	ldi		r17,'7'
	add		r16,r17
	rcall	LCD_WriteData
	ret
Num:
	ldi		r17,'0'
	add		r16,r17
	rcall	LCD_WriteData
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_WriteHex8:
	push	r16
	
	swap	r16
	andi	r16,0x0F
	rcall	LCD_WriteHexDigit

	pop		r16
	andi	r16,0x0F
	rcall	LCD_WriteHexDigit
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_WriteDecimal:
	clr		r14
LCD_WriteDecimalLoop:
	ldi		r17,10
	rcall	div8u
	inc		r14
	push	r15
	cpi		r16,0
	brne	LCD_WriteDecimalLoop	

LCD_WriteDecimalLoop2:
	ldi		r17,'0'
	pop		r16
	add		r16,r17
	rcall	LCD_WriteData
	dec		r14
	brne	LCD_WriteDecimalLoop2

	ret

;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_SetAddressDD:
	ori		r16, HD44780_DDRAM_SET
	rcall	LCD_WriteCommand
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_SetAddressCG:
	ori		r16, HD44780_CGRAM_SET
	rcall	LCD_WriteCommand
	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
LCD_Init:
	sbi		LCD_DDR, LCD_D4
	sbi		LCD_DDR, LCD_D5
	sbi		LCD_DDR, LCD_D6
	sbi		LCD_DDR, LCD_D7
	
	sbi		LCD_DDR, LCD_RS
	sbi		LCD_DDR, LCD_EN

	cbi		LCD_PORT, LCD_RS
	cbi		LCD_PORT, LCD_EN

	ldi		r16, 100
	rcall	WaitMiliseconds

	ldi		r17, 3
InitLoop:
	ldi		r16, 0x03
	rcall	LCD_WriteNibble
	ldi		r16, 5
	rcall	WaitMiliseconds
	dec		r17
	brne	InitLoop

	ldi		r16, 0x02
	rcall	LCD_WriteNibble

	ldi		r16, 1
	rcall	WaitMiliseconds

	ldi		r16, HD44780_FUNCTION_SET | HD44780_FONT5x7 | HD44780_TWO_LINE | HD44780_4_BIT
	rcall	LCD_WriteCommand

	ldi		r16, HD44780_DISPLAY_ONOFF | HD44780_DISPLAY_OFF
	rcall	LCD_WriteCommand

	ldi		r16, HD44780_CLEAR
	rcall	LCD_WriteCommand

	ldi		r16, HD44780_ENTRY_MODE |HD44780_EM_SHIFT_CURSOR | HD44780_EM_INCREMENT
	rcall	LCD_WriteCommand

	ldi		r16, HD44780_DISPLAY_ONOFF | HD44780_DISPLAY_ON | HD44780_CURSOR_OFF | HD44780_CURSOR_NOBLINK
	rcall	LCD_WriteCommand

	ret
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------

	
