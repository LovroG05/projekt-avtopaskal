				; za uporabo najprej klièite proceduro setupUART
				.equ baudrate = 9600

				.macro print
				.cseg
				push r16			; pazimo, da ne bi sluèajno spremenili r16, ZH, ZL
				push ZH
				push ZL

				ldi ZH, high(@0 * 2)
				ldi ZL, low(@0 * 2)
				call printstring

				pop ZL
				pop ZH
				pop r16				; vrnemo v r16 prvotno vrednost
				.endmacro
			

;****************************************************************************************************
;  printstring
;  Z kaže na zaèetek niza v PROGRAMskem pomnilniku (CSEG)
;****************************************************************************************************

				.cseg
printstring:	lpm r16, Z+			; naloži znak in premakni kazalec Z naprej
				cpi r16, 0			; ali je konec niza (niz se konèa z NULL)
				breq stopprinting	; da, skoèi na konec
				call send_char		; ne, pošlji znak
				rjmp printstring	; na vrsti je naslednji znak, skoèi tja
stopprinting:	ret				                

;****************************************************************************************************
;  poslji_hex
;  r16 - stevilka, ki jo zelimo izpisati na UART 
;****************************************************************************************************
				; v r16 damo vrednost, na UART dobimo dve ASCII šestnajstiški števki  (0xFF --> 'FF')
send_hex:		push r16			; kako pretvorimo vrednosti od 0 do 9 v '0' do '9'?
									; kaj pa od 10 do 15 v 'A' do 'F'?
				swap r16			; zamenjamo visoki in nizki del byta
				andi r16, 0x0F		; zanimajo nas samo štirje biti

				cpi r16, 0x0A		; primerjaj z deset
				brcs manjsa_od_10_1
				subi r16, -7		; èe ni manjša od deset, je osnova 'A', r16 je vsaj 10, prištejemo še '0', je potem 58, manjka še 7
manjsa_od_10_1:						; sicer je osnova '0', prištejemo 48 ('0')
				subi r16, -48
				call send_char

				pop r16
				andi r16, 0x0F		; zanimajo nas samo štirje biti, tokrat so to spodnji štirje

				cpi r16, 0x0A		; primerjaj z deset
				brcs manjsa_od_10_2
				subi r16, -7		; èe ni manjša od deset, je osnova 'A', r16 je vsaj 10, prištejemo še '0', je potem 58, manjka še 7
manjsa_od_10_2:						; sicer je osnova '0', prištejemo 48 ('0')
				subi r16, -48
				call send_char

				ret
				
;****************************************************************************************************
;  setupUART
;  pripravi serijska vrata na prenos podatkov, 9600 baud
;
;****************************************************************************************************
setupUART:		; pripravi serijska vrata
				; ne sekirajte se, èe še ne veste, èesa vsega ne poznate

				; 
				; vrednosti not npr. TXEN0 in UBRR0H dobimo v datoteki m328pdef.inc 
				; in so lahko druga?ne glede na model mikrokontrolerja

				; 9600 baudov @ 16Mhz  
				; v IO register UBBR0 naložimo baudrate / 8

				ldi r16, 0x67
				ldi r17, 0x00
				sts UBRR0L, r16
				sts UBRR0H, r17

				; RXEN0 = 4, TXEN0 = 3, znak << pomeni pomik v levo, >> desno
				; 1<<TXEN0 = 0x40 (0b00000001 --> 0b00001000)
				ldi r16, (1<<RXEN0)|(1<<TXEN0) ; vkljuèimo bita za sprejem in za oddajo - pina dobita RX in TX funkcijo
				sts UCSR0B,r16

				ldi r16, (3<<UCSZ00) ; 8 bitov, 1 stop bit
				sts UCSR0C,r16
				clr r16
				sts UCSR0A, r16

				ret

;****************************************************************************************************
; procedura pošlje znak v r16 po UART
;
;****************************************************************************************************
				; poèakajmo, da bo oddajni vmesni pomnilnik na voljo
send_char:		; takrat bo bit UDRE0 enak 1
				push r16				; spravi r16 na sklad, ker bomo po njem pacali 
poskusi_poslati:
				lds r16, UCSR0A
				sbrs r16,UDRE0			; preskoèi naslednjo instrukcijo, èe je ta bit 1
				rjmp poskusi_poslati	; bit še ni 1, skoèi nazaj na preverjanje
									
				pop r16					; daj podatek (r16) v vmesni pomnilnik za UART, 
				sts UDR0,r16	
				ret

;****************************************************************************************************
; procedura sprejme znak  po UART v r16
;
;****************************************************************************************************

get_char:		; poèakajmo, da bo znak prispel, bit RXC0 bo takrat 1
				lds r16, UCSR0A
				sbrs r16, RXC0
				rjmp get_char

				lds r16, UDR0
vrnise:			ret

;****************************************************************************************************
;  8-bitno deljenje z 10
;  deli r16 z 10, r17 je ostanek
;
;****************************************************************************************************

div10_8bit:		push r0
				push r1
				
dobro:			ldi r17, 205	; more magic
				mul r16, r17	; mind blown
				ldi r17, 32
				mul r17, r1		; r1 = r16/10 (celi del, seveda)

				ldi r17, 10
				mov r0, r17
				mov r17, r16

				mov r16, r1     ; spravimo rezultat v r16
				mul r1, r0
				sub r17, r0		; ostanek

				pop r1
				pop r0				
				ret				; confused?


;****************************************************************************************************
;  izpiši 8-bitno število kot ascii
;  r16 število
;  r17 mest
;
;****************************************************************************************************

print_8bit_base10:
				push r18			; pacamo po r18
				mov r18, r17
				clr r17
				push r17
naslednja_cifra:					; najprej izracunamo stevke in jih damo na stack
				call div10_8bit		; r16 = r16 / 10, r17 je ostanek
				ori r17, 0x30		; naredimo iz njega ASCII cifro (npr. 2 => 0x32 = '2')
				push r17			; ker je ostanke potrebno izpisati v obratnem vrstnem redu
				dec r18				; jih damo na sklad, vendar samo toliko cifer max, kot je bilo podano
				brne naslednja_cifra	; èe imamo dovolj števk, nehamo
							
izpisi_cifre:   pop r16
				or r16, r16			; zadnja cifra je ascii NULL (=0x00)
				breq konec_izpisa
				call send_char
				rjmp izpisi_cifre

konec_izpisa:	pop r18				; popravimo r18 nazaj...
				ret

dump_registers:						; grda procedura... ampak deluje.. :p
				push r31
				push r30
				push r29
				push r28
				push r27
				push r26
				push r25
				push r24
				push r23
				push r22
				push r21
				push r20
				push r19
				push r18
				push r17
				push r16
				push r15
				push r14
				push r13
				push r12
				push r11
				push r10
				push r9
				push r8
				push r7
				push r6
				push r5
				push r4				
				push r3
				push r2
				push r1
				push r0

				in ZH, SPH
				in ZL, SPL
				ldi r18, 32		; 32 registrov na skladu
				clr r19			; števec registrov
				ld r16, Z+		; vrednost na vrhu skladu nima pomena
naslednji_register:
				ldi r16, 'r'
				call send_char

				mov r16, r19
				inc r19
				ldi r17, 2
				call print_8bit_base10

				ldi r16, ':'
				call send_char

				ld r16, Z+
				call send_hex
				ldi r16,0x20
				call send_char
				call send_char

				mov r16, r19
				andi r16, 0x07
				brne no_new_line

				ldi r16, 0x0d
				call send_char
				ldi r16, 0x0a
				call send_char
				call send_char

no_new_line:	dec r18
				brne naslednji_register

				pop r0
				pop r1
				pop r2
				pop r3
				pop r4
				pop r5
				pop r6
				pop r7
				pop r8
				pop r9
				pop r10
				pop r11
				pop r12
				pop r13
				pop r14
				pop r15
				pop r16
				pop r17
				pop r18
				pop r19
				pop r20
				pop r21
				pop r22
				pop r23
				pop r24
				pop r25
				pop r26
				pop r27
				pop r28
				pop r29
				pop r30
				pop r31

				ret				; we are done here

				.dseg
StackHI:		.byte 1
StackLO:		.byte 1

				.cseg