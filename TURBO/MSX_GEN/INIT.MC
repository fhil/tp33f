; ^QW: find current word
; ^QS: find current word without first letter (for names that start with an
;      underscore)

; - define the symbol 'MSX' to compile the msx compiler
;   otherwise the PC version will be generated

; - define the symbol 'USELIB' to compile all library routines
; - define the symbol 'NEWEXT' to use the new external routine

;NEWEXT:
FASTREAL:

IFNDEF MAKEPC
MSX:
ENDIF

IFDEF MSX
MSXDOS	EQU 5
USELIB:
ENDIF

	INCLUDE STDIO.INC

         INCLUDE LIBDEFS.INC

         INCLUDE LIBCONST.INC

         ORG 100H

L0100:

IFDEF MAKEPC
         DW 73edh,L0006
;!       jmp word ptr L0101

ELSE

         DB 0C3H

ENDIF

L0101:   DW L20E2

MAGICNUMBER:                        ; must be at 103H
         DB 12H,34H,56H,78H
TURBOPASCALVERSION:
         DB 03H,03H,'a',04H         ; must be at 107H

         DW L016B                   ; must be at 10BH
         DW 0                       ; reserved 10DH
         DW 0                       ; reserved 10FH
         DW 0                       ; reserved 111H
         DW 0
         DW 0
         DW 0
         DW 0
         DW 0
         DW 0
         DW 0
         DW 0
         DW 0

;PREFIX:  DB 'TURBO '                ; for 'TURBO.MSG' or 'TURBO.OVR'

;L0000:   DB 0
;L0001:   DW 0

;L0004:   DB 0                        ; current drive ?

;L0005:   DB 0

IFDEF MAKEPC
L0006:   DW 0
ENDIF    ; MAKEPC

;L0038:   DB 0
;L0039:   DW 0

L005C:	DB 0			; start of FCB

L005D:	db 8 dup (0)			; name

L0065:	DB 0			; FCB extension, first letter
L0066:	db 2 dup (0)			; second and third letter

L0068:	DB 0			; 0CH
	DB 0			; 0DH
	DB 0			; 0EH
	DB 0			; 0FH
L006C:	db 4 dup (0)			; 10H-13H
L0070:	db 4 dup (0)			; 14H-17H
L0074:	db 8 dup (0)			; 18H-1FH
L007C:	DB 0			; 20H
L007D:	DW 0			; 21H-22H
	DW 0			; 23H-24H

IFDEF MSX
L0080    EQU 0080H
ELSE
; L0080    EQU $-1
ENDIF

CONSTPTR:; FUNCTION KeyPressed: BOOLEAN;
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr CONSTPTR_1
ENDIF
CONSTPTR_1:DW L0316

CONINPTR:			; console input routine
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr CONINPTR_1
ENDIF
CONINPTR_1:DW L0320

CONOUTPTR:                          ; console output routine
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr CON1OUTPTR
ENDIF
CON1OUTPTR:DW L0339

LSTOUTPTR:
	DB 0c3h
	DW  L032F
	;DS 3			; jump opcode at 00A9H
				; LSTOUTPTR at absolute 00AAH
AUXOUTPTR:
	DB 0c3h
	DW  L0334
	;DS 3			; jump opcode at 00ACH
				; AUXOUTPTR at absolute 00ADH
AUXINPTR:
	DB 0c3h
	DW  L032A
	;DS 3			; jump opcode at 00AFH
				; AUXINPTR  at absolute 00B0H
USROUTPTR:
	DB 0c3h
	DW  L0339
	;DS 3			; jump opcode at 00B2H
				; USROUTPTR at absolute 00B3H
USRINPTR:
	DB 0c3h
	DW  L0320
	;DS 3			; jump opcode at 00B5H
				; USRINPTR  at absolute 00B6H

L00B8:	DW 0			; CON, TRM, 00B8
L00BA:	DW 0			; KBD,	   00BA
LST:	DW 0			; LST,	   00BC, absolute 00BCH
L00BE:	DW 0			; AUX,	   00BE
L00C0:	DW 0			; USR,	   00C0
OUTPUT:	DW 0			; OUTPUT,   00C2, absolute 00C2H

BUFLEN:	DB 0;			; BUFLEN    at absolute 00D1H

ERRORPTR:
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr ERRORPTR_1
ENDIF
ERRORPTR_1:DW 0

CBREAK:DW 0			; CBREAK    at absolute 00DDH
HEAPPTR:DW 0			; HEAPPTR   at absolute 00C4H
RECURPTR:DW 0			; RECURPTR  at absolute 00C6H

L00C8:	DW 0			; 32 bit Seed number
         DB 0

L00CB:	DB 0			; waarde van R register

L00CC:	DW 0
L00CE:	DW 0

L00D0:	DB 0			 ; IORESULT value
L00D2:	DW 0
L00D4:	DW 0
L00D6:	DW 0
L00D8:	DB 0
L00DC:	DB 0
L00DE:	DW 0
L00E0:	DB 0

L00E2:	DW 0			; current device pointer

L00E4:	DW 0
L00E6:	DW 0
L00E8:	DW 0
L00E9	EQU L00E8+1
L00EA:	DW 0
L00EC:	DB 0
L00ED:	DW 0			; old device pointer

	; tabel van 16 bytes, soort buffer
L00F0:	DW 0
L00F2:	DW 0
L00F4:	DW 0			; MemAvail
L00F6:	DW 0			; MaxAvail
L00F8:	DW 0
	db 8 dup (0)

;	 DW 0ABCDH		 ; Magic
;	 DB 0CDH,0ABH
;	 DB 'Copyright (C) 1994 MSX Computer Club Enschede',0

L0124:	DW 4			; Operating frequency of CPU (1-12 MHz)

L0126:	DB 0A1H,'B',0

	db 42 dup (0)			; patch area of 42 bytes

L0153:	; TermTypStr
	DB 3,'msx'                 ; STRING
	db L0153+21-$ dup (0)

L0168:	DB 80			; ScreenWidth
L0169:	DB 24			; ScreenHeight

	DB 0			; Why ?

L016B:	; InitialStr, 16 bytes
	DB 3,1BH,'x5',1DH
	db L016B+16-$ dup (0)		; fill rest

L017B:	; ResetStr, 16 bytes
	db L017B+16-$ dup (0)		; fill rest

L018B:	; CursorStr, 16 bytes
	DB 4,1BH,'Y',0,0
	db L018B+16-$ dup (0)		; fill rest

L019B:	DB 1			; 0 = ASCII, 1 = Binary Address
L019C:	DB 32			; ColumnOffset
L019D:	DB 32			; LineOffset
L019E:	DB 4			; XPosition in CursorStr
L019F:	DB 3			; YPosition in CursorStr
L01A0:	DW 0			; Delay after cursor address (0 - 255 ms)

L01A2:	; ClearScrStr, 6 bytes
	DB 1,0CH 		; length = 1
	db L01A2+6-$ dup (0)		; fill rest

L01A8:	; HomeStr, 6 bytes
	DB 0			; length = 0
	db L01A8+6-$ dup (0)

L01AE:	; InsLineStr, 6 bytes
	DB 2,1BH,'L'
	db L01AE+6-$ dup (0)

L01B4:	; DelLineStr, 6 bytes
	DB 2,1BH,'M'
	db L01B4+6-$ dup (0)

L01BA:	DW 0			; DelayLine

L01BC:	; EraToEolStr
	DB 2,1BH,'K'
	db L01BC+6-$ dup (0)

L01C2:	; HLStartStr		; Start of highlighting
	DB 0
	db L01C2+6-$ dup (0)

L01C8:	; HLEndStr		; End of highlighting
	DB 0
	db L01C8+6-$ dup (0)

L01CE:	DW 0			; DelayHL, delay after
				; EraToEol and HighLight

L01D0:   DB 7eh
	DB 0b7h
	DB 37h
	DB 0c8h
L01D4:	DB 23h
	DB 0f5h
	DB 0e5h
	DB 7eh
	DB 0cdh
	DW  L01E8
	DB 0e1h
	DB 0f1h
	DB 3dh
	DB 0c8h
	DB 18h,( L01D4)-$-1

L01E1:	DB 0cdh
	DW  L0200		; print CR,LF
	DB 0DH,0AH,0
	DB 0c9h

L01E8:   DB 6fh
	DB 0e5h
	DB 0cdh
	DW  CONOUTPTR
	DB 0c9h

L01EE:	; print character A with/without highlighting
	DB 0feh, 080H
	DB 0dch
	DW L026B		; LowVideo
	DB 0d4h
	DW L0284		; HighVideo
	DB 0e6h, 07FH
	DB 18h,( L01E8)-$-1

L01FA:	; print ASCIIZ-string with highlighting
	DB 0e5h
	DB 21h
	DW L01EE
	DB 18h,( L0204)-$-1

L0200:   ; print ASCIIZ-string without highlighting
	DB 0e5h
	DB 21h
	DW L01E8
L0204:   DB 22h
	DW L0213
	DB 0e1h
	DB 0e3h
L0209:	DB 0f5h
	DB 0c5h
L020B:	DB 0d5h

L020C:   DB 7eh
	DB 23h
	DB 0b7h
	DB 28h,(L0218)-$-1
	DB 0e5h
L0212:	DB 0cdh
	DW  J0213		; call address, address is change able
	DB 0e1h
	DB 18h,( L020C)-$-1

L0218:	DB 0d1h
	DB 0c1h
	DB 0f1h
	DB 0e3h		; continue after string data
	DB 0c9h

J0213:
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr L0213
ENDIF
L0213:	DW L04D2

L021D:	; in:	HL = time to wait
	DB 7dh			; delay
	DB 0b4h
	DB 0c8h
	DB 3ah
	DW L0124		; A = frequency
	DB 087h
	DB 087h
	DB 087h
L0226:	DB 0e3h
	DB 0e3h
	DB 0e3h
	DB 0e3h
	DB 0c5h
	DB 01h
	DW 1234
	DB 0c1h
	DB 3dh
	DB 20h,(L0226)-$-1
	DB 2bh
	DB 18h,( L021D)-$-1 		; Delay

L0235:	DB 0cdh
	DW  L01D0
	DB 0d8h
	DB 02ah
	DW L01CE		; HL = DelayHL, delay highlighting
	DB 18h,( L021D)-$-1 		; Delay

L023E:	; PROCEDURE ClrSCr;
	DB 0f5h
	DB 0c5h
	DB 0d5h
	DB 0e5h

	DB 21h
	DW L01A8		; HL = HomeStr
	DB 0cdh
	DW  L0235
	DB 21h
	DW L01A2		; HL = ClearScrStr

L024B:	DB 0cdh
	DW  L01D0
	DB 02ah
	DW L01BA		; HL = DelayLine
	DB 0d4h
	DW L021D		; Delay

	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0f1h
	DB 0c9h

L0259:	; PROCEDURE DelLine
	DB 0f5h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 21h
	DW L01B4		; DelLineStr
	DB 18h,( L024B)-$-1

L0262:	; PROCEDURE InsLine;
	DB 0f5h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 21h
	DW L01AE		; InsLineStr
	DB 18h,( L024B)-$-1

L026B:	; PROCEDURE LowVideo;
	DB 0f5h
	DB 3ah
	DW L00E0
	DB 0b7h
	DB 28h,(L0282)-$-1

	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0afh
	DB 32h
	DW L00E0
	DB 21h
	DW L01C8		; HLEndStr

L027C:	DB 0cdh
	DW  L0235

	DB 0e1h
	DB 0d1h
	DB 0c1h
L0282:	DB 0f1h
	DB 0c9h

L0284:	; PROCEDURE NormVideo;
	DB 0f5h
	DB 3ah
	DW L00E0
	DB 0feh, 0FFH
	DB 28h,(L0282)-$-1

	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 3eh,0FFH
	DB 32h
	DW L00E0
	DB 21h
	DW L01C2		; HLStartStr
	DB 18h,( L027C)-$-1

L0299:	; PROCEDURE ClrEol;
	DB 0f5h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 21h
	DW L01BC		; EraToEolStr
	DB 18h,( L027C)-$-1

L02A2:	; in:	L = X, 0..79
	;	H = Y, 0..23
	DB 0f5h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0e5h
	DB 21h
	DW L018B
	DB 11h
	DW L00F0
	DB 01h
	DW 0010H
	DB 0edh,0b0h
	DB 0d1h
	DB 3ah
	DW L019E
	DB 4fh
	DB 3ah
	DW L019C
	DB 082h
	DB 0d5h
	DB 0cdh
	DW  L02DC
	DB 0d1h
	DB 3ah
	DW L019F
	DB 4fh
	DB 3ah
	DW L019D
	DB 083h
	DB 0cdh
	DW  L02DC
	DB 21h
	DW L00F0
	DB 0cdh
	DW  L01D0

	DB 02ah
	DW L01A0		; DelayCursor
	DB 0cdh
	DW  L021D		; Delay
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0f1h
	DB 0c9h

L02DC:	DB 21h
	DW L00F0
	DB 06h,0
	DB 09h
	DB 0ebh
	DB 21h
	DW L019B
	DB 034h
	DB 035h
	DB 28h,(L02EC)-$-1
	DB 12h
	DB 0c9h

L02EC:	DB 1bh
	DB 1bh
	DB 21h
	DW TAB110100+3
	DB 06h,3

L02F3:	DB 2bh

	DB 0eh,'0'-1
L02F6:	DB 0ch
	DB 096h
	DB 30h,(L02F6)-$-1

	DB 086h
	DB 0f5h
	DB 79h
	DB 0feh, '0'
L02FF:	DB 28h,(L0302)-$-1
	DB 12h
L0302:	DB 13h
	DB 0f1h
	DB 10h,( L02F3)-$-1
	DB 0c9h

TAB110100:
	DB 1,10,100

IFDEF MSX
L030A:	; PROCEDURE CrtInit;
	DB 21h
	DW L016B		; InitialStr
	DB 0c3h
	DW  L0235
ENDIF

L0310:	; PROCEDURE CrtExit;
	DB 21h
	DW L017B		; ResetStr
	DB 0c3h
	DW  L0235

L0316:   ; tests if there is a character in the input buffer
	; and places it in a temporary buffer to read it the next time
	; in:	-
	; out:	HL = false = 0, if no character present
	;	HL = true = 1, if a character was present
IFDEF MSX
         ; MSX version, FAST
         DB 02ah
	DW 0F3FAH
         DB 3ah
	DW 0F3F8H
         DB 095h
         DB 3eh,1                     ; assume there are characters present
         DB 20h,(L0316_OK)-$-1             ; jump if characters present

         DB 3dh                      ; FALSE if not
L0316_OK:

ELSE
         ; PC version, slow CPM call
         DB 11h
	DW 3
         DB 0cdh
	DW  L035F
	DB 0e6h, 1
ENDIF
	DB 18h,( L0326)-$-1

L0320:   ; in:    -
	; out:	HL = character read from keyboard
	;	H = always zero
IFNDEF MSX
         DB 11h
	DW 2*3                  ; Console Input
ELSE
         ; FAST character input
         DB 0ddh,0e5h
         DB 0fdh,0e5h
         DB 79h
         DW 80F7H
         DW 009FH
         DB 0fdh,0e1h
         DB 0ddh,0e1h
         DB 6fh
         DB 26h,0
         DB 0c9h
ENDIF

L0323:   DB 0cdh
	DW  L035F

L0326:   DB 6fh
	DB 26h,0
	DB 0c9h

L032A:	DB 11h
	DW 6*3		; Reader Input
	DB 18h,( L0323)-$-1

L032F:	DB 11h
	DW 4*3		; List Output
	DB 18h,( L033C)-$-1

L0334:	DB 11h
	DW 5*3		; Puncher Output
	DB 18h,( L033C)-$-1

L0339:
IFNDEF MSX
         DB 11h
	DW 3*3                  ; Console Output
ENDIF

L033C:	DB 0e1h			; pop return address
	DB 0c1h			; C = character to print
	DB 0e5h			; push return address

         DB 3ah
	DW CBREAK
	DB 0b7h
         DB 28h,(L035D_1)-$-1               ; jump if no break allowed

         DB 0d5h
	DB 0c5h
	DB 0cdh
	DW  CONSTPTR
	DB 7ch
	DB 0b5h
	DB 28h,(L035D)-$-1		; jump if no character present

         DB 0cdh
	DW  L03E1                 ; A = character from console
	DB 0feh, 013H
	DB 20h,(L035D)-$-1

         DB 0cdh
	DW  L03E1                 ; A = character from console
	DB 0feh, 3
         DB 0cah
	DW L20D4                 ; jump to Program Abort if ^C pressed

L035D:	DB 0c1h
	DB 0d1h

L035D_1:
IFDEF MSX
         ; FAST character output
         DB 0ddh,0e5h
         DB 0fdh,0e5h
         DB 79h
         DW 80F7H
         DW 00A2H
         DB 0fdh,0e1h
         DB 0ddh,0e1h
         DB 0c9h
ENDIF

L035F:
IFDEF MSX
	DB 02ah
	DW 0001H
	DB 019h
	DB 0e9h
ELSE
	DB 0c3h
	DW  DOSIO 		; ----
ENDIF

L0364:   ; InitCharIO
	DB 22h
	DW L00D2		; LIB
	DB 78h
	DB 32h
	DW CBREAK
;	 LD A,C
;	 OR A
;	 JR Z,L037A

L037A:
IFDEF MSX
	DB 21h
	DW L03A5
	DB 11h
	DW CONSTPTR
	DB 01h
	DW L03A5_L
	DB 0edh,0b0h
ENDIF

	DB 21h
	DW L03BD
	DB 11h
	DW L00B8
	DB 01h
	DW 000CH
	DB 0edh,0b0h			; flag bits of I/O routines

	DB 0afh
	DB 6fh
	DB 67h
	DB 32h
	DW L00D0		; reset IORESULT value
	DB 22h
	DW L00D4
	DB 22h
	DW L00D6
	DB 3eh,07EH
	DB 32h
	DW BUFLEN
	DB 32h
	DW L00E0

         DB 0c3h
	DW  INITFILEIO              ; Set DOS2Present variable

L03A5:   DB 0c3h
	DW  L0316                   ; keypressed
         DB 0c3h
	DW  L0320                   ; read character from console
         DB 0c3h
	DW  L0339                   ; write character to console
	DB 0c3h
	DW  L032F
	DB 0c3h
	DW  L0334
	DB 0c3h
	DW  L032A
         DB 0c3h
	DW  L0339                   ; write character to console
         DB 0c3h
	DW  L0320                   ; read character from console
L03A5_L EQU $ - L03A5

L03BD:   DW 0C1H                    ; Con / Trm       , read and write
         DW 82H                     ; Kbd             , read
         DW 43H                     ; Lst             , write
         DW 0C4H                    ; Aux             , read and write
         DW 0C5H                    ; Usr             , read and write
         DW 0C1H                    ; Input / Output  , read and write

L03C9:	; in:	A = character to print
	; out:	-
	; changes: -
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0ddh,0e5h
	DB 0fdh,0e5h
	DB 0f5h
	DB 6fh
	DB 26h,0
	DB 0e5h
	DB 0cdh
	DW  CONOUTPTR
	DB 0f1h

L03D9:   DB 0fdh,0e1h
	DB 0ddh,0e1h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0c9h

L03E1:	; in:	-
	; out:	A = character read from console
	; changes: F
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0ddh,0e5h
	DB 0fdh,0e5h
L03E8:	DB 0cdh
	DW  CONINPTR
	DB 7dh
	DB 18h,( L03D9)-$-1 		; same end as 'print character'

	; -----------------------------------------------------------

L03EE:	; parses a filename at DE with wildcards to FCB at L005C
	DB 0eh,0FFH		; with wildcards
	DB 18h,( L03FE)-$-1

L03F2:	; parses a string whose address is in L00D2 to FCB at L005C
	; with no wildcards, skips leading spaces in string
	DB 0eh,0			; don't allow wildcards
	DB 0edh,5bh
	DW L00D2
L03F8:	DB 13h
	DB 1ah
	DB 0feh, ' '
	DB 28h,(L03F8)-$-1		; skip leading spaces

L03FE:	DB 21h
	DW L0065		; HL = start address for extension
	DB 06h,3			; 3 characters
	DB 0cdh
	DW  L047B

L0406:	; parses a complete filename at address in DE to FCB at L005C
	; in:	DE = source address for filename
	;	 C = 0, no wildcards
	DB 1ah
	DB 0cdh
	DW  L04A6		; upcase
	DB 0feh, 'A'
	DB 38h,(L0420)-$-1		; jump if < 'A'
	DB 0feh, 'Q'
	DB 30h,(L0420)-$-1		; jump if >= 'Q'
	DB 47h			; save first character in B
	DB 13h
	DB 1ah
	DB 0feh, ':'                     ; next character is ':' ?
	DB 20h,(L041F)-$-1		; no, don't start with a drive specification
	DB 78h			; A = drive letter
	DB 0d6h, 040H 		; 1 = 'A:', 2 = 'B:' etc..
	DB 13h			; to character after ':'
	DB 18h,( L0421)-$-1

L041F:	DB 1bh			; back to first character

L0420:	DB 0afh			; default drive
L0421:	DB 21h
	DW L005C
	DB 77h		; set drive specification
	DB 23h

	DB 0ch			; C = 0 if no wildcards are allowed
	DB 0dh
	DB 28h,(L0443)-$-1		; jump to skip wildcards

	DB 1ah
	DB 0cdh
	DW  L0482
	DB 20h,(L0443)-$-1
	DB 0feh, '?'
	DB 28h,(L0443)-$-1
	DB 0feh, '*'
	DB 28h,(L0443)-$-1
	DB 0feh, '.'
	DB 28h,(L0443)-$-1
	DB 06h,11
	DB 0cdh
	DW  L0477
	DB 18h,( L0453)-$-1

L0443:	DB 06h,8
	DB 0cdh
	DW  L045E
	DB 1ah
	DB 0feh, '.'                     ; followed by an extension ?
	DB 20h,(L0453)-$-1		; no, skip parsing of an extension

	DB 13h			; to first character of extension
	DB 06h,3
	DB 0cdh
	DW  L045E		; parse extension

L0453:	DB 21h
	DW L005C+12		; clear rest of the FCB
         DB 06h,FCB_LEN -11           ; 33e -12
L0458:	DB 36h,0
	DB 23h
	DB 10h,( L0458)-$-1
	DB 0c9h

L045E:	DB 1ah
	DB 0ch			; skip wildcard check if not allowed
	DB 0dh
	DB 28h,(L046B)-$-1

	DB 0feh, '?'
	DB 28h,(L0470)-$-1		; fill as if normal letter
	DB 0feh, '*'
	DB 28h,(L0476)-$-1		; fill rest with '?'-wildcards

L046B:	DB 0cdh
	DW  L0482
	DB 28h,(L047B)-$-1		; jump if abnormal character found, end of
				; string found, fill rest with spaces

L0470:	DB 77h
	DB 23h
	DB 13h
	DB 10h,( L045E)-$-1
	DB 0c9h

L0476:	DB 13h

L0477:	; fill rest with '?'-wildcards
	DB 3eh,'?'
	DB 18h,( L047D)-$-1

L047B:	; fill rest with spaces
	DB 3eh,' '

L047D:	DB 77h
	DB 23h
	DB 10h,( L047D)-$-1
	DB 0c9h

L0482:	DB 0cdh
	DW  L04A6		; upcase A
	DB 0feh, ' '                     ; < ' ' ?
	DB 38h,(L0496)-$-1

	DB 0e5h
	DB 0c5h
	DB 21h
	DW L0498		; HL = address of data to scan
	DB 01h
	DW L04911		; BC = length of data to scan
	DB 0edh,0b1h
	DB 0c1h
	DB 0e1h
	DB 0c9h			; return Z-flag = '1' if A found in data

L0496:	DB 0bfh			; return with Z-flag corresponding to A
	DB 0c9h

L0498:	; SepTable
	DB ' .,;:=?*[]<>{}'
L04911	EQU $-L0498

	; -----------------------------------------------------------

L04A6:	; in:	A = character
	; out:	A = upcased, if A >= 'a' and A <= 'z'
	DB 0feh, 'a'
	DB 0d8h
	DB 0feh, 'z'+1
	DB 0d0h
	DB 0d6h, 'a'-'A'
	DB 0c9h

L04AF:	DB 7ch
	DB 0cdh
	DW  L04B4
	DB 7dh

L04B4:	DB 0f5h
	DB 1fh
	DB 1fh
	DB 1fh
	DB 1fh
	DB 0cdh
	DW  L04BD
	DB 0f1h
L04BD:	DB 0e6h, 00FH
	DB 0feh, 10
	DB 38h,(L04BE)-$-1
	DB 0c6h,7
L04BE:	DB 0c6h,'0'
	DB 0c3h
	DW  L03C9 		; print digit

L04C8:   ; converts integer HL to an unsigned byte A
	; in:	HL
	; out:	A = 0 and carry set, if HL < 0
	;	A = L and carry reset, if HL < 256
	;	otherwise A = 255
	DB 0afh
	DB 37h			; assume HL is negative
	DB 0cbh,07ch
	DB 0c0h			; return with carry set if negative

         DB 7ch
	DB 0b7h
	DB 7dh
         DB 0c8h                      ; return if HL < 256

L04D2:   DB 3ah
	DW L04D2_D             ; code area
	DB 0c9h

L04D2_D: DB 0                       ; data area


L0581:   ; LIB
	; push new empty SET on stack
	; in:	-
	; out:	a new SET pushed on to the stack
	DB 0ddh,0e1h			; LIB
	DB 21h
	DW -32
	DB 039h
	DB 0f9h 		; reserve 32 bytes

	; clear the SET with zeroes
	DB 06h,020H
	DB 0afh
L058B:	DB 77h
	DB 23h
	DB 10h,( L058B)-$-1

	DB 0ddh,0e9h

L0591:	; add element HL to SET at stack
	;
	DB 0ddh,0e1h
	DB 45h			; B = element to add
	DB 0cdh
	DW  L05BA

L0597:	DB 0b6h
	DB 77h

L0599:	DB 0ddh,0e9h

L059B:   DB 0ddh,0e1h                     ; LIB
	DB 0d1h
	DB 7dh
	DB 093h
	DB 38h,(L0599)-$-1
	DB 3ch
	DB 4fh
	DB 43h
	DB 0cdh
	DW  L05BA
	DB 5fh
	DB 41h
	DB 0afh
L05AB:	DB 0b3h
	DB 0cbh,23h
	DB 30h,(L05B6)-$-1
	DB 0b6h
	DB 77h
	DB 23h
	DB 0afh
	DB 1eh,1
L05B6:	DB 10h,( L05AB)-$-1
	DB 18h,( L0597)-$-1

L05BA:	DB 78h
	DB 0e6h, 0F8H 		; calculate byte offset
	DB 0fh
	DB 0fh
	DB 0fh
	DB 0c6h,2			; add 2 for return address
	DB 6fh
	DB 26h,0
	DB 039h
	DB 78h
	DB 0e6h, 7
	DB 3ch
	DB 47h
	DB 0afh
	DB 37h
L05CD:	DB 17h
	DB 10h,( L05CD)-$-1
	DB 0c9h


L0612:	; pop pushed set to the address in HL
	; in:	HL = destination address of SET
	;	C = bytes to copy from SET
	;	B = offset within SET
	DB 0ddh,0e1h			; LIB
	DB 0ebh
	DB 68h			; HL = offset within SET
	DB 26h,0
	DB 44h			; BC = length
	DB 039h
	DB 0edh,0b0h			; copy set to given address

	DB 21h
	DW 0020H

L061F:   DB 039h
	DB 0f9h
	DB 0ddh,0e9h

L06F5:	; X * Y : INTEGER
	; in:	DE = X
	;	HL = Y
	; out:	HL = X * Y
	DB 4bh			; BC = X
	DB 42h
	DB 0ebh
	DB 21h
	DW 0
	DB 7ah			; D non zero?
	DB 0b7h
	DB 3eh,16			; assume 16 bits
	DB 20h,(L0704)-$-1		; yes, continue
	DB 53h			; no, shift E to D
	DB 3eh,8			; shift rest over 8 bits
L0704:	DB 029h
	DB 0ebh
	DB 029h
	DB 0ebh
	DB 30h,(L070B)-$-1
	DB 09h
L070B:	DB 3dh
	DB 20h,(L0704)-$-1
	DB 0c9h

L0780:   ; Abs X : INTEGER
	; in:	HL = X
	; out:	HL = -X, if X < 0
	;	HL = X, if X >= 0
	DB 0cbh,07ch			; LIB, HL = negative ?
	DB 0c8h			; return if positive

L0783:	; X = -X : INTEGER
	; in:	HL = X
	; out:	HL = -X
	DB 7ch			; negate HL
	DB 2fh
	DB 67h
	DB 7dh
	DB 2fh
	DB 6fh
	DB 23h
	DB 0c9h

L07C6:   ; unsigned Integer to ASCII
	; in:	HL = unsigned INTEGER
	;	IX = destination address of ASCII result
	; out:	IX = address after ASCII result
	DB 06h,0			; Flag = 0, no leading zero
	DB 11h
	DW 10000
	DB 0cdh
	DW  L07E2
	DB 11h
	DW 1000
	DB 0cdh
	DW  L07E2
	DB 11h
	DW 100
	DB 0cdh
	DW  L07E2
	DB 1eh,10
	DB 0cdh
	DW  L07E2
	DB 7dh
	DB 18h,( L07EF)-$-1

L07E2:	DB 0afh
L07E3:	DB 3ch
	DB 0EDH,052h
	DB 30h,(L07E3)-$-1
	DB 019h
	DB 04h			; increase, assume NonZero
	DB 3dh
	DB 20h,(L07EF)-$-1		; jump if digit > 0

	DB 05h			; Flag = 0 ?, suppress leading zero's
	DB 0c8h

L07EF:	DB 0c6h,'0'
	DB 0ddh,77h,+0
	DB 0ddh,23h
	DB 0c9h

L07F7:   ; ASCII hexadecimal or decimal to Integer
	; converts ascii hexadecimal or decimal number at IX to
	; a value in HL
	; in:	IX = address of ascii digit sequence
	; out:	carry set if value out of range
	;	carry reset, HL = value
	DB 0ddh,7eh,+0
	DB 0d6h, '$'
	DB 4fh
	DB 21h
	DW 0
	DB 20h,(L0804)-$-1		; NonZero, do not skip '$' character
L0802:	DB 0ddh,23h

L0804:	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L04A6		; upcase
	DB 0d6h, '0'                    ; < '0' ?
	DB 38h,(L0837)-$-1		; yes, quit
	DB 0feh, 10			; < 10 ?
	DB 38h,(L0820)-$-1		; yes, continue

	; A..F ?
	DB 0ch			; started with '$' ?
	DB 0dh
	DB 20h,(L0837)-$-1		; no, quit
	DB 0d6h, 7			; 'A' --> 10, 'B' --> 11
	DB 0feh, 10			; < 10 ?
	DB 38h,(L0837)-$-1		; yes, quit
	DB 0feh, 16			; >= 16 ?
	DB 30h,(L0837)-$-1		; yes, quit
L0820:	DB 54h			; save old HL
	DB 5dh
	DB 029h		; * 2
	DB 0d8h			; quit if carry, overflow
	DB 029h		; * 4
	DB 0d8h			; quit if error
	DB 0ch			; hexadecimal ?
	DB 0dh
	DB 20h,(L082C)-$-1
	DB 54h			; yes, hexadecimal (perform * 16)
	DB 5dh
L082C:	DB 019h		; * 5 if decimal
				; * 8 if hexadecimal
	DB 0d8h			; quit if error
	DB 029h		; * 10 if decimal
				; * 16 if hexadecimal
	DB 0d8h			; quit if error
	DB 5fh
	DB 16h,0
	DB 019h		; * 10 + digit if decimal
				; * 16 + digit if hexadecimal
	DB 0d8h			; quit if error
	DB 18h,( L0802)-$-1 		; go for the next digit

L0837:   DB 0b7h
	;RET Z			; quit if carry reset if hexadecimal
				; allow hexadecimals that are negative
				; decimals
	;LD A,H
	;ADD A,A
	DB 0c9h			; quit with carry set if HL > 32767?

A2L_FLAG:DB 0                       ; hexadecimal flag
				; 0 = convert as hexadecimal
				; NonZero = convert as decimal
A2L:     ; ASCII hexadecimal or decimal to LONGINT
	; converts ascii hexadecimal or decimal number at IX to
	; an unsigned value in DE:HL
	; in:	IX = address of ascii digit sequence
	; out:	carry set if value out of range
	;	carry reset, DE:HL = unsigned value
         ;        A = 0, if hexadecimal constant parsed
	DB 0ddh,7eh,+0
	DB 0d6h, '$'
	DB 32h
	DW A2L_FLAG
	DB 21h
	DW 0			; DE:HL = 0
	DB 11h
	DW 0
	DB 20h,(A2L04)-$-1		; NonZero, do not skip '$' character

A2L02:	DB 0ddh,23h

A2L04:   DB 3ah
	DW A2L_FLAG
         DB 4fh
         DB 0ddh,7eh,+0
	DB 0cdh
	DW  L04A6		; upcase
	DB 0d6h, '0'                    ; < '0' ?
	DB 38h,(A2L37)-$-1		; yes, quit --> error
	DB 0feh, 10			; < 10 ?
	DB 38h,(A2L20)-$-1		; yes, continue

	; A..F ?
         DB 0ch                      ; started with '$' ?
         DB 0dh
         DB 20h,(A2L37)-$-1                ; no, quit --> error

	; hexadecimal
	DB 0d6h, 7			; 'A' --> 10, 'B' --> 11
	DB 0feh, 10			; < 10 ?
         DB 38h,(A2L37)-$-1                 ; yes, quit --> error
	DB 0feh, 16			; >= 16 ?
         DB 30h,(A2L37)-$-1                ; yes, quit --> error

A2L20:   DB 0f5h
         DB 3ah
	DW A2L_FLAG
	DB 0b7h			; hexadecimal or decimal ?
	DB 28h,(A2L_HEX)-$-1		; jump if hexadecimal

	; multiply DE:HL by 10 with overflow detection
	DB 0d5h			; save old DE:HL * 1
	DB 0e5h
	DB 0cdh
	DW  L_M2		; DE:HL * 2
	DB 38h,(A2L38)-$-1		; quit if carry, overflow

	DB 0cdh
	DW  L_M2		; DE:HL * 4
	DB 38h,(A2L38)-$-1		; quit if carry, overflow

	DB 0c1h			; DE:HL * 4 + DE:HL * 1
	DB 09h
	DB 0ebh
	DB 0c1h
	DB 0EDH,04ah
	DB 0ebh
         DB 0c1h
         DB 78h                     ; A = digit to add
         DB 0d8h                      ; quit if carry, overflow

         DB 0cdh
	DW  L_M2                  ; DE:HL * 2
         DB 0d8h
         DB 18h,( A2L36)-$-1                   ; add the current digit

A2L_HEX: DB 0f1h
         DB 0cdh
	DW  L_M2                  ; DE:HL * 2
	DB 0d8h			; quit if carry, overflow
	DB 0cdh
	DW  L_M2		; DE:HL * 4
	DB 0d8h			; quit if carry, overflow
	DB 0cdh
	DW  L_M2		; DE:HL * 8
	DB 0d8h			; quit if carry, overflow
	DB 0cdh
	DW  L_M2		; DE:HL * 16
	DB 0d8h			; quit if carry, overflow

A2L36:   ; add the new digit and repeat
         DB 4fh
         DB 06h,0
         DB 09h
         DB 0ebh
         DB 01h
	DW 0
         DB 0EDH,04ah
         DB 0ebh
         DB 18h,( A2L02)-$-1                   ; go for the next digit

A2L37:   DB 79h
	DB 0b7h
	DB 0c9h

A2L38:   DB 0e1h
         DB 0e1h
	DB 0d1h
	DB 0c9h

L_M2:    ; in:    DE:HL
	; out:	DE:HL * 2
	;	Carry if overflow
	DB 029h
	DB 0ebh
	DB 0EDH,06ah
	DB 0ebh
	DB 0c9h

; ------------------------------------------------------
; ------------------------------------------------------
; ------------------------------------------------------
; ------------------------------------------------------
; ------------------------------------------------------


L09E9:   ; REAL + REAL
         DB 0cdh
	DW  L0A0D                 ; LIB

L09EC:	DB 0d0h
	DB 3eh,1			; r.error 1: Floating point overflow
	DB 0c3h
	DW  L2027 		; Run-time error


L0A03:   DB 3eh,2                     ; r.error 2: Division by zero attempted
	DB 0cah
	DW L2027		; Run-time error
         DB 0cdh
	DW  L0AF5
	DB 18h,( L09EC)-$-1

L0A0D:	DB 0d9h
	DB 0cbh,078h
	DB 0d9h
	DB 0c2h
	DW L0A88
L0A14:	DB 0d9h
	DB 7dh
	DB 0b7h
	DB 0d9h
	DB 0c8h
	DB 0d9h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0d9h
	DB 7dh
	DB 0b7h
	DB 20h,(L0A27)-$-1
	DB 0d9h
	DB 0cbh,0b8h
	DB 18h,( L0A7B)-$-1
L0A27:	DB 0c5h
	DB 0cbh,0f8h
	DB 0afh
	DB 08h
	DB 0d9h
	DB 0cbh,0f8h
	DB 7dh
	DB 0d9h
	DB 095h
	DB 28h,(L0A47)-$-1
	DB 30h,(L0A3C)-$-1
	DB 0edh,44h
	DB 08h
	DB 3dh
	DB 08h
	DB 0d9h
L0A3C:	DB 0cdh
	DW  L0B7A
	DB 2ch
	DB 3dh
	DB 20h,(L0A3C)-$-1
	DB 08h
	DB 28h,(L0A47)-$-1
	DB 0d9h
L0A47:	DB 0f1h
	DB 0e6h, 80H
	DB 20h,(L0A5B)-$-1
	DB 0cdh
	DW  L0B92
	DB 30h,(L0A76)-$-1
	DB 0cdh
	DW  L0B7B
	DB 0b7h
	DB 2ch
	DB 20h,(L0A76)-$-1
	DB 37h
	DB 18h,( L0A7B)-$-1
L0A5B:	DB 0cdh
	DW  L0BC6
	DB 3fh
	DB 0f5h
	DB 28h,(L0A72)-$-1
	DB 38h,(L0A65)-$-1
	DB 0d9h
L0A65:	DB 0cdh
	DW  L0BAC
L0A68:	DB 0cbh,078h
	DB 20h,(L0A75)-$-1
	DB 0cdh
	DW  L0B86
	DB 2dh
	DB 20h,(L0A68)-$-1

L0A72:	DB 0cdh
	DW  L0B72		; HLDEBC = 0.0

L0A75:	DB 0f1h
L0A76:	DB 38h,(L0A7A)-$-1
	DB 0cbh,0b8h
L0A7A:	DB 0b7h
L0A7B:	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0d9h
	DB 0c9h
L0A81:	DB 0d9h
	DB 0cbh,078h
	DB 0d9h
	DB 0c2h
	DW L0A14
L0A88:	DB 0cdh
	DW  L0A8F
	DB 0cdh
	DW  L0A14
	DB 0d8h
L0A8F:	DB 2ch
	DB 2dh
	DB 0c8h
	DB 78h
	DB 0eeh, 80H
	DB 47h
	DB 0c9h
L0A97:	DB 0d9h
	DB 7dh
	DB 0b7h
	DB 0d9h
	DB 0cah
	DW L0B72		; Zero --> HLDEBC = 0.0

	DB 7dh
	DB 0b7h
	DB 0c8h
	DB 0d9h
	DB 085h
	DB 0d9h
	DB 0cdh
	DW  L0B4D
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0ddh,039h

IFNDEF FASTREAL
	DB 0cdh
	DW  L0B72		; HLDEBC = 0.0
	DB 0d9h
	DB 2eh,5
	DB 0d9h
L0AB3:	DB 3eh,8
	DB 0ddh,23h
IFDEF MSX
	DB 0ddh,6eh,+0
ELSE
;!	mov bl,ss:[si + 0]	; read from stack !!! ----
ENDIF
L0ABA:	DB 08h
	DB 0cbh,1dh
	DB 30h,(L0AC2)-$-1
	DB 0cdh
	DW  L0B92
L0AC2:	DB 0cdh
	DW  L0B7B
	DB 08h
	DB 3dh
	DB 20h,(L0ABA)-$-1
	DB 0d9h
	DB 2dh
	DB 0d9h
	DB 20h,(L0AB3)-$-1

ELSE	; FASTREAL

	DB 0d9h
	DB 0c5h
	DB 4ch
	DB 0d9h
	DB 0d1h			; BCDEHL' --> DED'E'C'

	DB 0afh			; HLH'L'A = 0
	DB 6fh
	DB 67h
	DB 0d9h
	DB 6fh
	DB 67h
	DB 06h,5			; B' = byte count
	DB 0d9h

MULTREAL1:
	DB 06h,8			; B = bit count
	DB 0ddh,23h
;         LD C,(IX+0)
IFDEF MSX
         DB 0ddh,4eh,+0
ELSE
;!       mov cl,ss:[si + 0]         ; read from stack !!! ----
ENDIF

MULTREAL2:
	DB 0cbh,19h
	DB 30h,(MULTREAL3)-$-1
	DB 0d9h
	DB 081h
	DB 0EDH,05ah
	DB 0d9h
	DB 0EDH,05ah

MULTREAL3:
	DB 0cbh,1ch
	DB 0cbh,1dh
	DB 0d9h
	DB 0cbh,1ch
	DB 0cbh,1dh
	DB 0d9h
	DB 1fh

	DB 10h,( MULTREAL2)-$-1

	DB 0d9h
	DB 05h
	DB 0d9h
	DB 20h,(MULTREAL1)-$-1

	; BCDEH = HLH'L'A
	DB 44h
	DB 4dh
	DB 67h
	DB 0d9h
	DB 0e5h
	DB 0d9h
	DB 0d1h

	DB 08h                  ; save Carry from RRA

ENDIF	; FASTREAL

IFDEF MSX
	DB 0ddh,6eh,-5
ELSE
;!	mov bl,ss:[si - 5]
ENDIF
	DB 0cbh,078h
	DB 20h,(L0ADE)-$-1
	DB 08h
	DB 0cdh
	DW  L0B87
	DB 2ch
	DB 2dh
	DB 28h,(L0ADE)-$-1
	DB 2dh
L0ADE:	DB 0f1h
	DB 0f1h
	DB 0f1h

L0AE1:	DB 0b7h

L0AE2:	DB 08h
	DB 0f1h
	DB 0d9h
	DB 0c1h
	DB 0d1h			; FastReal
	DB 0e1h
	DB 0d9h
	DB 0ddh,0e1h
	DB 0cbh,0b8h
	DB 0b0h
	DB 47h
	DB 2ch
	DB 2dh
	DB 0cch
	DW L0B72		; Zero --> HLDEBC = 0.0

	DB 08h
	DB 0c9h

L0AF5:	DB 7dh
	DB 0b7h
	DB 0c8h
	DB 0d9h
	DB 095h
	DB 0d9h
	DB 3fh
	DB 0cdh
	DW  L0B4D
	DB 0e5h
L0B00:	DB 0e5h
	DB 0e5h
	DB 0ddh,039h

IFNDEF FASTREAL
	DB 0d9h
	DB 2eh,5
	DB 0d9h
	DB 3eh,8
L0B0A:	DB 08h
	DB 0cdh
	DW  L0BC6
	DB 38h,(L0B13)-$-1
	DB 0cdh
	DW  L0BAC
L0B13:	DB 3fh
	DB 0cbh,15h
	DB 08h
	DB 3dh
	DB 20h,(L0B26)-$-1
IFDEF MSX
	DB 0ddh,75h,+5
ELSE
;!	mov byte ptr ss:[si+5],bl
ENDIF
	DB 0ddh,2bh
	DB 0d9h
	DB 2dh
	DB 0d9h
	DB 28h,(L0B32)-$-1
	DB 3eh,8
L0B26:	DB 0cdh
	DW  L0B86
	DB 30h,(L0B0A)-$-1
	DB 08h
	DB 0cdh
	DW  L0BAC
	DB 0b7h
	DB 18h,( L0B13)-$-1
L0B32:	DB 0cdh
	DW  L0B86
	DB 38h,(L0B3B)-$-1
	DB 0cdh
	DW  L0BC6
	DB 3fh
ELSE	; FASTREAL

	DB 7ch
	DB 08h
	DB 60h
	DB 69h
	DB 0d5h
	DB 0d9h
	DB 7ch
	DB 0e1h
	DB 0c5h
	DB 4fh
	DB 06h,5			; B' = byte count
	DB 0d9h
	DB 0d1h
	DB 08h

	DB 06h,8			; B = bit count

DIVREAL1:DB 0cdh
	DW  COMPMANTISSE
	DB 38h,(DIVREAL2)-$-1

	; SubMantisse
	DB 0d9h
	DB 091h
	DB 0EDH,052h
	DB 0d9h
	DB 0EDH,052h

DIVREAL2:DB 3fh
	DB 0cbh,11h

	DB 10h,( DIVREAL3)-$-1

;         LD (IX+5),C
IFDEF MSX
         DB 0ddh,71h,+5
ELSE
;!       mov byte ptr ss:[si+5],cl
ENDIF
	DB 0ddh,2bh

	DB 0d9h
	DB 05h
	DB 0d9h
	DB 28h,(DIVREAL4)-$-1

	DB 06h,8			; B = bit count

DIVREAL3:; SLAMantisse
	DB 0b7h
	DB 17h
	DB 0d9h
	DB 0EDH,06ah
	DB 0d9h
	DB 0EDH,06ah
	DB 30h,(DIVREAL1)-$-1

	; SubMantisse
	DB 0d9h
	DB 091h
	DB 0EDH,052h
	DB 0d9h
	DB 0EDH,052h
	DB 0b7h
	DB 0c3h
	DW  DIVREAL2

DIVREAL4:; SLAMantisse
	DB 0b7h
	DB 17h
	DB 0d9h
	DB 0EDH,06ah
	DB 0d9h
	DB 0EDH,06ah
	DB 38h,(DIVREAL5)-$-1

	DB 0cdh
	DW  COMPMANTISSE
	DB 3fh

DIVREAL5:

ENDIF	; FASTREAL

L0B3B:	DB 0e1h
	DB 0d1h
	DB 0c1h
;!       lahf                       ; store carry in ah

         DB 0cbh,078h
         DB 20h,(L0B47)-$-1

;!       sahf                       ; restore carry
         DB 0cdh
	DW  L0B87
	DB 0c3h
	DW  L0AE1

IFDEF FASTREAL
COMPMANTISSE:
	DB 0b7h
	DB 0EDH,052h
	DB 0f5h
	DB 019h
	DB 0f1h
	DB 0c0h

	DB 0d9h
	DB 0b7h
	DB 0EDH,052h
	DB 0f5h
	DB 019h
	DB 0f1h
	DB 0d9h
	DB 0c0h

	DB 0d9h
	DB 0b9h
	DB 0d9h
	DB 0c9h

ENDIF	; FASTREAL

L0B47:	DB 2ch
	DB 0c2h
	DW L0AE1
	DB 37h
	DB 0c3h
	DW  L0AE2

L0B4D:	DB 38h,(L0B55)-$-1
	DB 0c6h,80H
	DB 38h,(L0B59)-$-1
	DB 18h,( L0B70)-$-1
L0B55:	DB 0c6h,80H
	DB 38h,(L0B70)-$-1
L0B59:	DB 6fh
	DB 0ddh,0e3h
	DB 0d9h
	DB 0e5h
	DB 0d5h
	DB 0c5h
	DB 78h
	DB 0cbh,0f8h
	DB 0d9h
	DB 0a8h
	DB 0e6h, 80H
	DB 0f5h
	DB 0cbh,0f8h
	DB 0ddh,0e5h
	DB 0ddh,21h
	DW 0
	DB 0c9h
L0B70:	DB 0e1h
	DB 0d8h

L0B72:	; create a REAL HLDEBC with 0.0 as value
	; in:	-
	; out:	REAL HLDEBC filled with zeroes
	DB 0afh
	DB 6fh
	DB 47h
	DB 4fh
	DB 57h
	DB 5fh
	DB 67h
	DB 0c9h

L0B7A:	DB 0b7h
L0B7B:	DB 0cbh,18h
	DB 0cbh,19h
	DB 0cbh,1ah
	DB 0cbh,1bh
	DB 0cbh,1ch
	DB 0c9h

L0B86:   DB 0b7h

L0B87:   DB 0cbh,14h
	DB 0cbh,13h
	DB 0cbh,12h
	DB 0cbh,11h
	DB 0cbh,10h
	DB 0c9h

L0B92:   DB 7ch
	DB 0d9h
	DB 084h
	DB 0d9h
	DB 67h
	DB 7bh
	DB 0d9h
	DB 08bh
	DB 0d9h
	DB 5fh
	DB 7ah
	DB 0d9h
	DB 08ah
	DB 0d9h
	DB 57h
	DB 79h
	DB 0d9h
	DB 089h
	DB 0d9h
	DB 4fh
	DB 78h
	DB 0d9h
	DB 088h
	DB 0d9h
	DB 47h
	DB 0c9h
L0BAC:	DB 7ch
	DB 0d9h
	DB 094h
	DB 0d9h
	DB 67h
	DB 7bh
	DB 0d9h
	DB 09bh
	DB 0d9h
	DB 5fh
	DB 7ah
	DB 0d9h
	DB 09ah
	DB 0d9h
	DB 57h
	DB 79h
	DB 0d9h
	DB 099h
	DB 0d9h
	DB 4fh
	DB 78h
	DB 0d9h
	DB 098h
	DB 0d9h
	DB 47h
	DB 0c9h

L0BC6:	DB 78h
	DB 0d9h
	DB 0b8h
	DB 0d9h
	DB 0c0h
	DB 79h
	DB 0d9h
	DB 0b9h
	DB 0d9h
	DB 0c0h
	DB 7ah
	DB 0d9h
	DB 0bah
	DB 0d9h
	DB 0c0h
	DB 7bh
	DB 0d9h
	DB 0bbh
	DB 0d9h
	DB 0c0h
	DB 7ch
	DB 0d9h
	DB 0bch
	DB 0d9h
	DB 0c9h

L0BDF:	; Compare REALS
	DB 0d9h
	DB 78h
	DB 0d9h
	DB 0a8h
	DB 0f2h
	DW L0BE9
	DB 78h
	DB 17h
	DB 0c9h
L0BE9:	DB 0cbh,078h
	DB 28h,(L0BF3)-$-1
	DB 0cdh
	DW  L0BF3
	DB 0c8h
	DB 3fh
	DB 0c9h
L0BF3:	DB 7dh
	DB 0d9h
	DB 0bdh
	DB 0d9h
	DB 0c0h
	DB 0b7h
	DB 0c8h
	DB 0c3h
	DW  L0BC6


L0F73:   ; in:    IX = address of REAL
	; out:	HLDEBC = REAL located at address IX
	;	IX unchanged
	DB 0ddh,6eh,+0
	DB 0ddh,66h,+1
	DB 0ddh,5eh,+2
	DB 0ddh,56h,+3
	DB 0ddh,4eh,+4
	DB 0ddh,46h,+5
	DB 0c9h

L0F86:   DB 21h
	DW 81H                  ; 1.0
	DB 44h
	DB 4ch
	DB 54h
	DB 5ch
	DB 0c9h

L10031:  DB 3eh,93H                   ; r.error 93H: Out of LONGINT range
	DB 0c3h
	DW  L2027

L1008:   DB 7ch                     ; LIB, convert integer HL to REAL HLDEBC
	DB 0b5h
	DB 0cah
	DW L0B72		; return 0.0 REAL if HL = 0

	DB 0cbh,07ch
	DB 08h                  ; save NZ for negative

         DB 0cdh
	DW  L0780                 ; absolute HL

	DB 3eh,90H

	; shift, normalization
L1015:   DB 029h
	DB 3dh
	DB 0cbh,07ch
	DB 28h,(L1015)-$-1

	DB 44h			; BC = integer, bit 7 of B always '1'
	DB 4dh
	DB 11h
	DW 0			; D = E = 0
	DB 62h			; H = 0
	DB 6fh

	DB 08h
	DB 0c0h			; keep bit 7 of B '1' if negative

	DB 0cbh,0b8h			; no, make if positive
	DB 0c9h

L_NEG:   ; X = -X : LONG
	; in:	X in DEHL
	; out:	DEHL
         ; changes: BC, A = 0
	DB 4dh			; BC = low-word
	DB 44h
	DB 0afh			; Carry = 0
	DB 6fh
	DB 67h
	DB 0EDH,042h		; 0 - low-word
	DB 0ebh
	DB 4dh			; BC = high-word
	DB 44h
	DB 6fh
	DB 67h
	DB 0EDH,042h		; 0 - high-word - carry
	DB 0ebh
	DB 0c9h

L_R:     ; convert LONGINT DEHL to REAL HLDEBC
	; in:	DEHL = signed LONGINT
	; out:	HLDEBC = REAL
	DB 7ch
	DB 0b5h
	DB 0b2h
	DB 0b3h
	DB 0cah
	DW L0B72		; jump if long is zero

	DB 0cbh,07ah			; is this long negative ?
	DB 0f5h			; rember this
	DB 0c4h
	DW L_NEG		; make positive if long is negative
	DB 3eh,0A0H

	; perform normlization
L_R_SH:	DB 029h
	DB 0ebh
	DB 0EDH,06ah
	DB 0ebh
	DB 3dh
	DB 0cbh,07ah
	DB 28h,(L_R_SH)-$-1		; shift until bit 31 = '1'

	DB 0ebh 		; HL:DE = normalized mantissa
	DB 44h
	DB 4dh
	DB 26h,0
	DB 6fh			; exponent + 81H in A
	DB 0f1h			; ZeroFlag = 0 if long was negative
	DB 0c0h			; if negative then leave bit 7 of B '1'

	DB 0cbh,0b8h
	DB 0c9h

R_L:     ; convert REAL HLDEBC to LONGINT DEHL
	; in:	HLDEBC = REAL
	; out:	DEHL = signed LONGINT
	DB 0cbh,07dh			; exponent < 80H then float = 0.0
				; in other words float < 1.0
	DB 0cah
	DW L0B72		; return DEHL = 0 if REAL < 1.0

	DB 0cbh,078h			; ZeroFlag = 0 if REAL is negative
	DB 0f5h			; save sign of REAL

	DB 0cbh,0f8h			; restore hidden bit

R_L_SH:	DB 3eh,9FH
	DB 0bdh			; more than 31 bits before the comma
	DB 38h,(L10031)-$-1		; r.error 93H: Out of LONGINT range

	DB 28h,(R_L_READY)-$-1		; jump if no more shifts
	DB 0cbh,38h
	DB 0cbh,19h
	DB 0cbh,1ah
	DB 0cbh,1bh
	DB 0cbh,1ch
	DB 2ch
	DB 18h,( R_L_SH)-$-1		; go for next possible shift

R_L_READY:
	DB 0cbh,38h
	DB 0cbh,19h
	DB 0cbh,1ah
	DB 0cbh,1bh
	DB 0cbh,1ch
	DB 0f1h			; restore sign of REAL
	DB 60h
	DB 69h			; long HLDE complete, if positive
	DB 0ebh 		; deliver in format DE:HL

	DB 0c8h			; return if float was positive

	DB 0c3h
	DW  L_NEG 		; make long negative if REAL was negative

L1027:   ; in:    BCDEHL' = REAL to convert to ASCII
         ;        HL = number of digits after decimal point
         DB 0cdh
	DW  L04C8                 ; int to byte
	DB 0ebh
	DB 1eh,0
	DB 38h,(L1033)-$-1
	DB 0feh, 19H
	DB 38h,(L104B)-$-1

L1033:	DB 1dh
	DB 0cdh
	DW  L04C8		; int to byte
	DB 0d9h
	DB 0cbh,078h			; NonZero if REAL HLDEBC is negative
	DB 0d9h
	DB 16h,7			; 7 digits if positive
	DB 28h,(L1040)-$-1

	DB 14h			; no, 8 digits, sign included

L1040:	DB 092h			; subtract from total bytes of space
	DB 30h,(L1044)-$-1		; jump if enough room
	DB 0afh
L1044:	DB 0feh, 9			; less than 9 digits of space left ?
	DB 38h,(L104A)-$-1		; yes, jump

	DB 3eh,9			; no, make it 9 digits at the most

L104A:	DB 3ch

L104B:	DB 57h
	DB 0d5h
	DB 0d9h
	DB 0fdh,21h
	DW L005D		; destination for ascii-float
	DB 0ddh,0e5h
	DB 0cdh
	DW  L10EB		; convert HLDEBC to ascii at IY
	DB 0ddh,0e1h
	DB 0d1h
	DB 4fh
	DB 7ah
	DB 3ch
	DB 0cbh,07bh
	DB 20h,(L1071)-$-1
	DB 081h
	DB 0f2h
	DW L106B

	DB 0fdh,36h,+0,0
	DB 18h,( L1076)-$-1

L106B:	DB 0feh, 0CH
	DB 38h,(L1071)-$-1

	DB 3eh,0BH

L1071:	DB 0d5h
	DB 0cdh
	DW  L1180
	DB 0d1h
L1076:	DB 0cbh,078h
	DB 28h,(L107F)-$-1

	DB 3eh,'-'
	DB 0cdh
	DW  L10E5		; add '-' at (IX+0)

L107F:	DB 0cbh,07bh
	DB 28h,(L1086)-$-1
	DB 61h
	DB 0eh,0
L1086:	DB 0cbh,079h
	DB 28h,(L108F)-$-1

	DB 0cdh
	DW  L10E3		; add '0' at (IX+0)
	DB 18h,( L1096)-$-1

L108F:	DB 0cdh
	DW  L10D9
	DB 0dh
	DB 0f2h
	DW L108F

L1096:	DB 7ah
	DB 0b7h
	DB 28h,(L10B1)-$-1

	DB 3eh,'.'
	DB 0cdh
	DW  L10E5		; add '.' at (IX+0)

L109F:	DB 0ch
	DB 28h,(L10A8)-$-1

	DB 0cdh
	DW  L10E3		; add '0' at (IX+0)
	DB 15h
	DB 20h,(L109F)-$-1
L10A8:	DB 15h
	DB 0fah
	DW L10B1
	DB 0cdh
	DW  L10D9
	DB 18h,( L10A8)-$-1

L10B1:	DB 0cbh,07bh
	DB 0c8h

	DB 3eh,'E'
	DB 0cdh
	DW  L10E5		; add 'E' at (IX+0)

	DB 3eh,'+'                   ; add '+'
	DB 0cbh,07ch
	DB 28h,(L10C5)-$-1
	DB 7ch
	DB 0edh,44h
	DB 67h

	DB 3eh,'-'
L10C5:	DB 0cdh
	DW  L10E5		; add '+' or '-' at (IX+0)
	DB 7ch
	DB 06h,'0'-1

L10CB:	DB 04h
	DB 0d6h, 10
	DB 30h,(L10CB)-$-1

	DB 0c6h,'0'+10
	DB 0ddh,70h,+0
	DB 0ddh,23h
	DB 18h,( L10E5)-$-1

L10D9:	DB 0fdh,7eh,+0
	DB 0fdh,23h
	DB 0b7h
	DB 20h,(L10E5)-$-1

	DB 0fdh,2bh

L10E3:	DB 3eh,'0'
L10E5:	DB 0ddh,77h,+0
	DB 0ddh,23h
	DB 0c9h

L10EB:	; in:	IY = destination address for REAL in ASCII format
	;	HLDEBC = REAL
	DB 0fdh,0e5h
	DB 2ch			; REAL represents zero?
	DB 2dh
	DB 20h,(L10FF)-$-1		; no, continue

	; fill destination address at IY with 12 '0' characters
	DB 06h,12
L10F3:	DB 0fdh,36h,+0,'0'
	DB 0fdh,23h
	DB 10h,( L10F3)-$-1
	DB 0afh
	DB 0c3h
	DW  L117D 		; jump POP IY and RET

L10FF:	DB 0c5h
	DB 0cbh,0b8h
	DB 7dh
	DB 0d9h
	DB 0d6h, 80H
	DB 6fh
	DB 09fh			; A = 255, if L was < 80H, otherwise A = 0
	DB 67h			; HL = signed L - 80H = exponend
	DB 11h
	DW 4DH
	DB 0cdh
	DW  L06F5		; LIB
	DB 11h
	DW 5
	DB 019h
	DB 7ch
	DB 0feh, 0D9H
	DB 20h,(L1119)-$-1
	DB 3ch
L1119:	DB 0fdh,77h,+0
	DB 0edh,44h
	DB 0cdh
	DW  L1240
	DB 7dh
	DB 0feh, 81H
	DB 30h,(L112C)-$-1
	DB 0cdh
	DW  L12B3
	DB 0fdh,035h,+0
L112C:	DB 0cbh,0f8h
	DB 3eh,84H
	DB 095h
	DB 2eh,0
	DB 28h,(L113D)-$-1
L1135:	DB 0cdh
	DW  L0B7A
	DB 0cbh,1dh
	DB 3dh
	DB 20h,(L1135)-$-1
L113D:	DB 0fdh,7eh,+0
	DB 0f5h
	DB 3eh,0CH
L1143:	DB 08h
	DB 78h
	DB 1fh
	DB 1fh
	DB 1fh
	DB 1fh
	DB 0e6h, 0FH
	DB 0c6h,30H
	DB 0fdh,77h,+0
	DB 0fdh,23h
	DB 78h
	DB 0e6h, 0FH
	DB 47h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0cbh,25h
	DB 0cdh
	DW  L0B87
	DB 0cbh,25h
	DB 0cdh
	DW  L0B87
	DB 0ebh
	DB 0e3h
	DB 019h
	DB 0d1h
	DB 0e3h
	DB 0EDH,05ah
	DB 0ebh
	DB 0e1h
	DB 0e3h
	DB 0EDH,04ah
	DB 44h
	DB 4dh
	DB 0e1h
	DB 0cbh,25h
	DB 0cdh
	DW  L0B87
	DB 08h
	DB 3dh
	DB 20h,(L1143)-$-1		; repeat until ready with conversion
	DB 0f1h
	DB 0c1h
L117D:	DB 0fdh,0e1h
	DB 0c9h


	; ----------
	; subroutine
	; ----------
L1180:	DB 0fdh,0e5h
	DB 0e1h
	DB 5fh
	DB 16h,0
	DB 019h
	DB 7eh
	DB 36h,0
	DB 0feh, 35H
	DB 0d8h

L118D:	DB 1dh
	DB 0fah
	DW L119C
	DB 2bh
	DB 7eh
	DB 3ch
	DB 77h
	DB 0feh, 3AH
	DB 0d8h
	DB 36h,0
	DB 18h,( L118D)-$-1

L119C:	DB 36h,31H
	DB 23h
	DB 36h,0
	DB 0ch
	DB 0c9h
	; ----------

L11A3:	; converts ascii REAL at IX to binary REAL in HLDEBC
	; in:	IX = address of ascii REAL
	; out:	carry set if conversion did not succeed
	DB 0d9h
	DB 01h
	DW 0
	DB 0d9h
	DB 0cdh
	DW  L0B72		; HLDEBC = 0.0

L11AB:	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L04A6		; upcase
	DB 0feh, '.'
	DB 20h,(L11C1)-$-1

	DB 0d9h
	DB 0cbh,070h
	DB 37h
	DB 0c0h

	DB 0cbh,0f0h
	DB 0d9h
L11BD:	DB 0ddh,23h
	DB 18h,( L11AB)-$-1

L11C1:	DB 0feh, 'E'
	DB 28h,(L11E6)-$-1
	DB 0cdh
	DW  L1239
	DB 30h,(L121E)-$-1
	DB 08h
	DB 0cdh
	DW  L12B3
	DB 0d8h
	DB 08h
	DB 0d9h
	DB 0c5h
	DB 6fh
	DB 26h,0
	DB 0cdh
	DW  L1008		; convert integer HL to REAL HLDEBC
	DB 0cdh
	DW  L09E9
	DB 0d9h
	DB 0c1h
	DB 0d8h
	DB 0cbh,070h
	DB 28h,(L11E3)-$-1
	DB 0dh
L11E3:	DB 0d9h
	DB 18h,( L11BD)-$-1

L11E6:	DB 0cdh
	DW  L121E
	DB 0d8h

	DB 0d9h
	DB 0cbh,0e0h
	DB 0ddh,23h

	DB 0ddh,7eh,+0

	DB 0feh, '+'
	DB 28h,(L11FC)-$-1		; jump if '+', ignore it

	DB 0feh, '-'
	DB 20h,(L11FE)-$-1

	DB 0cbh,0e8h			; set bit 5 for negative

L11FC:	DB 0ddh,23h
L11FE:	DB 0cdh
	DW  L1236		; check digit at (IX+0)
	DB 3fh
	DB 0d8h
	DB 4fh
	DB 0ddh,23h
	DB 0cdh
	DW  L1236		; check digit at (IX+0)
	DB 30h,(L1215)-$-1
	DB 0ddh,23h
	DB 57h
	DB 79h
	DB 087h
	DB 087h
	DB 081h
	DB 087h
	DB 082h
	DB 4fh
L1215:	DB 0cbh,068h
	DB 28h,(L121D)-$-1
	DB 79h
	DB 0edh,44h
	DB 4fh
L121D:	DB 0d9h

L121E:	DB 0d9h
	DB 79h
	DB 0c6h,80H
	DB 0feh, 5AH
	DB 0d8h
	DB 0feh, 0A6H
	DB 3fh
	DB 0d8h
	DB 0c5h
	DB 0ddh,0e5h
	DB 79h
	DB 0cdh
	DW  L1240
	DB 0ddh,0e1h
	DB 0d9h
	DB 0c1h
	DB 0d9h
	DB 0c9h

L1236:	; checks if byte at (IX+0)

	DB 0ddh,7eh,+0

L1239:	; in:	A = byte to check
	; out:	A = 0 .. 9
	;	C-flag set if A is a correct digit
	DB 0d6h, '0'
	DB 3fh
	DB 0d0h
	DB 0feh, 10
	DB 0c9h

L1240:	DB 0f5h
	DB 0b7h
	DB 0f2h
	DW L1247
	DB 0edh,44h

L1247:	DB 0f5h
	DB 0cbh,3fh
	DB 0cbh,3fh
	DB 3ch
	DB 21h
	DW -6
	DB 11h
	DW 6

L1253:	DB 019h
	DB 3dh
	DB 20h,(L1253)-$-1
	DB 0ebh
	DB 0ddh,21h
	DW L1277
	DB 0ddh,019h
	DB 0cdh
	DW  L0F73		; get REAL at address IX
	DB 0f1h
	DB 0e6h, 3
	DB 28h,(L126E)-$-1

L1266:	DB 0f5h
	DB 0cdh
	DW  L12B3
	DB 0f1h
	DB 3dh
	DB 20h,(L1266)-$-1
L126E:	DB 0f1h
	DB 0b7h
	DB 0f2h
	DW L0A97
	DB 0d9h
	DB 0c3h
	DW  L0AF5

L1277:	DB  81H,  0 ,  0 ,  0 ,  0 ,  0	; 1.0E+00
	DB  8EH,  0 ,  0 ,  0 , 40H, 1CH	; 1.0E+04
	DB  9BH,  0 ,  0 , 20H,0BCH, 3EH	; 1.0E+08
	DB 0A8H,  0 , 10H,0A5H,0D4H, 68H	; 1.0E+12
	DB 0B6H,  4 ,0BFH,0C9H, 1BH, 0EH	; 1.0E+16
	DB 0C3H,0ACH,0C5H,0EBH, 78H, 2DH	; 1.0E+20
	DB 0D0H,0CDH,0CEH, 1BH,0C2H, 53H	; 1.0E+24
	DB 0DEH,0F9H, 78H, 39H, 3FH,  1	; 1.0E+28
	DB 0EBH, 2BH,0A8H,0ADH,0C5H, 1DH	; 1.0E+32
	DB 0F8H,0C9H, 7BH,0CEH, 97H, 40H	; 1.0E+36

L12B3:	DB 7dh
	DB 0b7h
	DB 0c8h
	DB 0cbh,0f8h
	DB 0c5h
	DB 0d5h
	DB 7ch
	DB 0cdh
	DW  L0B7A
	DB 0cdh
	DW  L0B7A
	DB 084h
	DB 67h
	DB 0e3h
	DB 0EDH,05ah
	DB 0ebh
	DB 0e1h
	DB 0e3h
	DB 0EDH,04ah
	DB 44h
	DB 4dh
	DB 0e1h
	DB 30h,(L12D6)-$-1
	DB 0cdh
	DW  L0B7B
	DB 2ch
	DB 37h
	DB 0c8h

L12D6:	DB 7dh
	DB 0c6h,3
	DB 6fh
	DB 0cbh,0b8h
	DB 0c9h


L149B:   ; LIB
	; sets current FIB address to standard output (OUTPUT)
	; in:	HL = FIB address
	; out:	-
	DB 0e3h		; LIB, for search ???
	DB 22h
	DW L00E4		; save return address
	DB 0e3h
	DB 0e5h
	DB 21h
	DW OUTPUT
	DB 22h
	DW L00E2
	DB 0e1h
	DB 0c9h


L14E8:   DB 06h,0                     ; ^Z is ignored when typed in

L14EA:   DB 21h
	DW BUFLEN
	DB 7eh
	DB 0feh, 7FH			; < 127
	DB 38h,(L14F4)-$-1		; jump if < 127

	DB 3eh,7EH 		; trunc to a length of 126 characters
L14F4:	DB 4fh
	DB 36h,7EH
	DB 02ah
	DW L00D2
	DB 22h
	DW L00D4
L14FD:	DB 16h,0

L14FF:	DB 0cdh
	DW  L03E1		; A = character from console
	DB 77h

	DB 1eh,1
	DB 0feh, 8			; backspace ?
	DB 28h,(L153F)-$-1
	DB 0feh, 7FH
	DB 28h,(L153F)-$-1

	DB 1dh			; E = 0
	DB 0feh, 18H			; insert ?
	DB 28h,(L153F)-$-1
	DB 0feh, 1BH			; escape ?
	DB 28h,(L153F)-$-1

	DB 0feh, 1AH			; ctrl-z ?
	DB 28h,(L1550)-$-1		; jump to quit with ^Z

	DB 0feh, 0DH			; return ?
	DB 28h,(L1556)-$-1

	DB 0feh, ' '                     ; space ?
	DB 30h,(L1533)-$-1
	DB 0feh, 3			; ctrl-break ?
	DB 20h,(L14FF)-$-1
	DB 3ah
	DW CBREAK
	DB 0b7h
	DB 28h,(L14FF)-$-1		; ignore character if no CBREAK handler
	DB 0ddh,02ah
	DW L00E4		; IX = return address
	DB 0c3h
	DW  L2016 		; force userbreak

L1533:	DB 79h
	DB 0bah
	DB 28h,(L14FF)-$-1
	DB 7eh
	DB 14h
	DB 23h
	DB 0cdh
	DW  L03C9		; print character
	DB 18h,( L14FF)-$-1

L153F:	DB 15h
	DB 0fah
	DW L14FD
	DB 2bh
	DB 0cdh
	DW  L0200
	DB 8,' ',8,0               ; backspace, space, backspace
	DB 1dh
	DB 28h,(L14FF)-$-1
	DB 18h,( L153F)-$-1

L1550:	DB 04h
	DB 05h
	DB 28h,(L14FF)-$-1
	DB 18h,( L155A)-$-1 		; quit with ^Z

L1556:	DB 04h
	DB 05h
	DB 20h,(L155E)-$-1		; jump if quit with 0DH,0Ah

L155A:	; quit with ^Z
	DB 36h,1AH
	DB 18h,( L1566)-$-1 		; quit

L155E:	DB 0cdh
	DW  L01E1		; print CR, LF
	DB 36h,0DH
	DB 23h
	DB 36h,0AH
L1566:	DB 23h
	DB 22h
	DW L00D6		; save end address
	DB 0c9h

L156B:   ; read character from current file or device
	; out:	A = character read
	DB 02ah
	DW L00E2
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 20h,(L15ED)-$-1		; jump if error occurred, return EOF

	DB 7eh
	DB 0cbh,06fh
	DB 20h,(L15E9)-$-1		; jump if pre-read character present

	DB 0e6h, 0FH
	DB 20h,(L15AB)-$-1		; jump if device

	; read character from text file
	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL
	DB 7eh		; A = FIB_PTR
	DB 0b7h
	DB 0f2h
	DW L1597		; < 128 ?

	; read next FIB_BUF
	DB 0eh,14H 		; sequential read
	DB 0e5h
	DB 0cdh
	DW  L19BA		; sequential read from current position
				; to FIB_BUF
	DB 0e1h
	DB 28h,(L1595)-$-1		; jump if no error

	; error occurred, fill first byte of FIB_BUF with ^Z (end of file)
	DB 0e5h
	OFF_HL FIB_PTR FIB_BUF
;	 LD DE,2EH
;	 ADD HL,DE
	DB 36h,1AH
	DB 0e1h			; restore to FIB_PTR

L1595:	DB 0afh
	DB 77h		; FIB_PTR = 0

L1597:	DB 034h
	DB 0c6h,FIB_BUF - FIB_PTR	; 2EH
	DB 5fh
	DB 16h,0
	DB 019h
	DB 7eh
	DB 0feh, 1AH			; first character = ^Z (eof)
	DB 20h,(L15E0)-$-1

	DB 02ah
	DW L00E2
	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL
	DB 035h 		; FIB_PTR does not move beyond ^Z
	DB 18h,( L15E0)-$-1

L15AB:	DB 3dh			; device = 1, 'CON:' ?
	DB 20h,(L15C9)-$-1		; jump if not 'CON:'
	DB 02ah
	DW L00D4
	DB 0edh,5bh
	DW L00D6
	DB 0b7h
	DB 0EDH,052h
	DB 38h,(L15BF)-$-1		; read from buffer until current = end address

	DB 06h,0FFH
	DB 0cdh
	DW  L14EA

L15BF:	DB 02ah
	DW L00D4		; HL = data pointer
	DB 7eh		; A = data byte
	DB 23h
	DB 22h
	DW L00D4		; save new data pointer
	DB 18h,( L15E0)-$-1 		; put character in FIB_CHR

L15C9:	DB 3dh			; device = 2, 'KBD:' ?
	DB 20h,(L15D2)-$-1		; jump if not 'KBD:'

	DB 0cdh
	DW  CONINPTR
	DB 7dh
	DB 18h,( L15E0)-$-1 		; put character in FIB_CHR

L15D2:	DB 3dh			; skip 'LST:' (output device)
	DB 3dh			; device = 4, 'AUX:' ?
	DB 20h,(L15DC)-$-1		; jump if not 'AUX:', then device = 'USR:'

	DB 0cdh
	DW  AUXINPTR
	DB 7dh
	DB 18h,( L15E0)-$-1 		; put character in FIB_CHR

L15DC:	DB 0cdh
	DW  USRINPTR
	DB 7dh

L15E0:	DB 02ah
	DW L00E2		; HL = address of FIB
	DB 0cbh,0eeh		; set write semaphore
				; pre-read character ready
	OFF_HL 0 FIB_CHR
;	 INC HL
	DB 77h		; put character in character buffer
	OFF_HL FIB_CHR 0
;	 DEC HL
	DB 0c9h

L15E9:	OFF_HL 0 FIB_CHR
;	 INC HL
	DB 7eh		; read pre-read from character buffer
	OFF_HL FIB_CHR 0
;	 DEC HL
	DB 0c9h

L15ED:	DB 3eh,1AH
	DB 0c9h

L15F0:	DB 0e5h
	DB 02ah
	DW L00E2		; HL = address of FIB
	DB 7eh		; A = flags byte
	DB 0e6h, 0FH

	DB 0feh, 6			; device 6 = used for 'val'
	DB 28h,(L1622)-$-1		; quit immediately is device = 6

L15FB:	DB 0cdh
	DW  L156B		; read character from file or device
	DB 0feh, 21H
	DB 30h,(L160A)-$-1
	DB 0feh, 1AH
	DB 28h,(L160A)-$-1
	DB 0cbh,0aeh
	DB 18h,( L15FB)-$-1

L160A:	DB 11h
	DW L005D
	DB 06h,1EH
L160F:	DB 0c5h
	DB 0d5h
	DB 0cdh
	DW  L156B		; read character from file or device
	DB 0d1h
	DB 0c1h
	DB 0feh, 21H
	DB 38h,(L1620)-$-1
	DB 0cbh,0aeh
	DB 12h
	DB 13h
	DB 10h,( L160F)-$-1
L1620:	DB 0afh
	DB 12h
L1622:	DB 0e1h
	DB 0c9h

L1624:	; in:	-
	; out:	B = 0 and IX = L005D --> no '-' found
	;	B = 1 and IX = L005E --> a '-' found
	;	Zero --> end of string reached
	DB 0ddh,21h
	DW L005D
	DB 0ddh,7eh,+0
	DB 0b7h
	DB 0c8h			; quit if zero

	DB 06h,0			; assume positive
	DB 0feh, '-'                     ; minus sign ?
	DB 0c0h			; quit with NonZero of something else

	DB 04h			; no, negative number
	DB 0ddh,23h			; next character
         ; quit with NonZero (INC B)
	DB 0c9h

L1636:	; checks a correct termination of the parsed string
	; in:	IX = position of character after parsed string
	;	Carry flag --> IORESULT = 10H
	; out:	NonCarry if '\0' found at (IX), A not changed
	;	Carry if no '\0' found at (IX), A changed
	; changes: AF, IORESULT

	DB 38h,(L163D)-$-1

	DB 0ddh,034h,+0		; string correct ended ?
	DB 0ddh,035h,+0
	DB 0c8h			; yes, quit

L163D:	DB 3eh,10H
	DB 32h
	DW L00D0		; IORESULT = 10H, Error in numeric format
	DB 37h
	DB 0c9h


L164E:   ; store as INTEGER
	DB 0afh			; store as INTEGER

L164F:	; in:	HL = destination address for INTEGER value
	;	IX = address of first ASCII character
	;	C = 0, store as INTEGER
	;	C = > 0, store as BYTE
	; out:	HL = INTEGER value
	;	DE = destination address + 1
	DB 4fh
	DB 0c5h
	DB 0cdh
	DW  L15F0
	DB 0c1h
         DB 0cdh
	DW  L1624                 ; read an optional sign
         DB 0c8h                      ; quit if end of ASCII-text

	; B = 0, no sign
	; B = 1, a sign
	DB 0c5h
	DB 0e5h			; save destination address

	DB 0cdh
	DW  L07F7		; convert hexadecimal or decimal to HL

	DB 0d1h			; DE = destination address
	DB 0c1h			; B = sign flag
	; Carry if error at conversion

	DB 0cdh
	DW  L1636		; conversion ended correct ?
	DB 0d8h			; quit if error

	DB 05h			; B = 1 ?, a sign read ?
	DB 0cch
	DW L0783		; Zero --> negate HL

	DB 0ebh 		; HL = destination address
				; DE = INTEGER value
	DB 73h		; store low-byte

	DB 0ch			; byte ?
	DB 0dh
	DB 20h,(L1670)-$-1		; yes, only low-byte stored

	DB 23h
	DB 72h		; store high-byte

L1670:	DB 0ebh
	DB 0c9h

L1671:	; in:	HL = destination address for LONGINT value
	;	IX = address of first ASCII character
	; out:	DE:HL = LONGINT value
	DB 0cdh
	DW  L15F0

	DB 0cdh
	DW  L1624		; read an optional sign
	DB 0c8h

	; B = 0, no sign
	; B = 1, a sign
	DB 0e5h			; save destination address
	DB 0c5h			; save sign flag

	DB 0cdh
	DW  A2L 		; convert hexadecimal or decimal to DE:HL

	DB 0c1h			; B = sign flag

	DB 0f5h
	DB 05h
	DB 0cch
	DW L_NEG		; Zero --> negate LONGINT DE:HL
	DB 0f1h

	DB 0c1h			; BC = destination address
	; Carry if error at conversion

	DB 0cdh
	DW  L1636		; conversion ended correct ?
	DB 0d8h			; quit if error

	DB 0c5h			; save destination address
	DB 44h			; BC = low-word
	DB 4dh
	DB 0e1h			; HL = destination address

	DB 71h		; store low-word
	DB 23h
	DB 70h
	DB 23h

	DB 73h		; store high-word
	DB 23h
	DB 72h
	DB 60h			; restore low-word
	DB 69h
	; return DE:HL
	DB 0c9h


L16C6:	; in:	A = character
	; out:	character printed to a device or a file
	DB 02ah
	DW L00E2		; HL = FIB address
	DB 4fh			; C = character data

	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred
	DB 7eh
	DB 0e6h, 0FH
	DB 20h,(L16E4)-$-1		; jump if device

	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL			 ; offset to FIB_PTR
	DB 0e5h
	DB 7eh		; A = low byte of FIB_PTR
	DB 0c6h,FIB_BUF-FIB_PTR	; 2EH, distance between FIB_PTR and FIB_BUF
	DB 5fh
	DB 16h,0
	DB 019h
	DB 71h		; write character
	DB 0e1h
	DB 034h 		; increase FIB_PTR
	DB 0f0h			; quit if < 128
	DB 18h,( L170C)-$-1 		; write buffer if FIB_PTR = 128
				; why not directly to 'LD (HL),0' ???

L16E4:	DB 0feh, 6
	DB 28h,(L16FD)-$-1		; what kind of a device is this ????

	DB 0e1h			; pop return address
	DB 06h,0
	DB 0c5h			; push BC = character data
	DB 0e5h			; push return address

	DB 3dh			; 1: device = 'CON:' ?
	DB 0cah
	DW CONOUTPTR
	DB 3dh
	DB 3dh			; 3: device = 'LST:' ?
	DB 0cah
	DW LSTOUTPTR
	DB 3dh			; 4: device = 'AUX:' ?
	DB 0cah
	DW AUXOUTPTR
	DB 0c3h
	DW  USROUTPTR		; 5: device = 'USR:' ?

L16FD:	DB 02ah
	DW L00E8
	DB 3ah
	DW L00EA
	DB 0beh
	DB 0c8h
	DB 034h
	DB 5eh		; DE = index
	DB 16h,0
	DB 019h
	DB 71h		; write character in buffer
	DB 0c9h

L170C:	; flushes the buffer to disk if it is not empty
	DB 02ah
	DW L00E2
	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL
	DB 7eh		; A = low byte of FIB_PTR
	DB 0b7h
	DB 0c8h			; quit if nothing written
	DB 36h,0		; reset to start of FIB_BUF

	DB 0eh,15H 		; sequential write 128 bytes
	DB 0cdh
	DW  L19BA		; write FIB_BUF to current position
	DB 0c8h			; quit if no error
	DB 3eh,0F0H
	DB 32h
	DW L00D0		; IORESULT = 0F0H, Disk write error
	DB 0c9h


L1726:   ; LIB, print INTEGER
         ; in:    value to print is pushed on stack
         ;        HL = size in characters
         ;        (L00D2) destination address for ASCII result
         ; out:   -
         DB 0c1h                     ; LIB
	DB 0d1h
	DB 0c5h
	DB 0ddh,02ah
	DW L00D2
	DB 0cbh,07ch
         DB 28h,(L1737)-$-1                 ; jump if size = positive

         DB 0cdh
	DW  L0783                 ; negate HL (size)
         DB 0ebh                   ; HL = value, DE = size
         DB 18h,( L1745)-$-1

L1737:   DB 0ebh                   ; HL = value, DE = size
	DB 0cbh,07ch
         DB 28h,(L1745)-$-1                 ; jump if value = positive

         DB 0cdh
	DW  L0783                 ; negate HL
         DB 0ddh,36h,+0,'-'              ; print minus sign
	DB 0ddh,23h

L1745:   DB 0d5h                    ; push size

         DB 0cdh
	DW  L07C6                 ; unsigned INTEGER to ASCII

L1749:   ; print string from character buffer (L00D2) with leading spaces if
         ; pushed size > characters written in buffer
         ; in:    total size wanted is pushed
         DB 0e1h                     ; size, ( WRITELN(int : size) )

         DB 0cdh
	DW  L04C8                 ; int to byte
         ; A = size

         DB 0edh,5bh
	DW L00D2              ; DE = start of ASCII buffer
	DB 0ddh,0e5h
	DB 0e1h
	DB 0b7h
         DB 0EDH,052h
         DB 4dh                     ; C = characters written in buffer

         DB 0ebh                   ; HL = start of ASCII buffer

L1759:   ; in:   HL = start of ASCII buffer
         ;        C = characters written in buffer
         DB 091h                      ; size - characters written
         DB 38h,(L176A)-$-1                 ; jump if size is less, no spaces first
         DB 28h,(L176A)-$-1                 ; jump if size is equal, no spaces first

         DB 47h                     ; B = number of spaces to add
         DB 0e5h                    ; save start of ASCII buffer

L1760:   DB 3eh,' '
	DB 0c5h
         DB 0cdh
	DW  L16C6                 ; write space character
	DB 0c1h
         DB 10h,( L1760)-$-1                 ; repeat

         DB 0e1h                     ; HL = start of ASCII buffer

L176A:   DB 41h                     ; B = characters in ASCII buffer
	DB 04h

L176C:	DB 05h
         DB 0c8h                      ; quit if all printed (or empty)

         DB 7eh                  ; A = chacacter to print
	DB 0c5h
	DB 0e5h
         DB 0cdh
	DW  L16C6                 ; print character
	DB 0e1h
	DB 0c1h
         DB 23h                     ; next one
	DB 18h,( L176C)-$-1

L1779:   ; LIB, print REAL
         ; in:    push REAL
         ;        push size
         ;        HL = number of digits after decimal point
         DB 0c1h                     ; return address

         DB 0d1h                     ; DE = size of real

         DB 0d9h
	DB 0e1h			; HLDEBC = REAL to be printed
	DB 0d1h
	DB 0c1h
	DB 0d9h

         DB 0c5h                    ; return address

         DB 0ddh,02ah
	DW L00D2              ; IX = destination address for ASCII
         DB 0d5h                    ; push size

         DB 0cdh
	DW  L1027                 ; convert REAL to ASCII

         DB 18h,( L1749)-$-1


L18A4:	DB 0e3h
	DB 22h
	DW L00E4
	DB 0e3h
	DB 22h
	DW L00E2
	DB 7eh
	DB 0e6h, 0C0H 		; read or write flags set?
	DB 0c0h			; yes, quit

L18B0:	DB 3eh,4
	DB 32h
	DW L00D0		; IORESULT = 4, File not open
	DB 0c9h

L19BA:	; write FIB_BUF to current position according to FCB
	DB 02ah
	DW L00E2		; HL = address of FIB
	DB 0e5h
	DB 0c5h			; save record to write

	OFF_HL 0 FIB_BUF
;	 LD DE,FIB_BUF		 ; offset to BUFFER
;	 ADD HL,DE
	DB 0ebh
	DB 0eh,1AH 		; C = set dma at FIB buffer
	DB 0cdh
	DW  MSXDOS

	DB 0c1h
	DB 0e1h
	OFF_HL 0 FIB_FCB
;	 LD DE,FIB_FCB		 ; offset to FCB
;	 ADD HL,DE
	DB 0ebh
	DB 0cdh
	DW  MSXDOS
	DB 0b7h
	DB 0c9h


L1A26:	DB 3eh,91H
	DB 32h
	DW L00D0		;  IORESULT = 91H, Seek beyond end-of-file
	DB 0c9h


L2016:   DB 11h
	DW 0001                 ; user break, D = 0 with error code = 1
	DB 18h,( L202C)-$-1

L2027:   ; Run-time error
	DB 0ddh,0e1h

         DB 5fh                     ; E = error code
	DB 16h,2			; Run-time rror

L202C:   ; in:    D = 0, user break
	;	D = 1, I/O error, E = error number
	;	D = 2, Run-time error	E = error number
	DB 0d5h
	DB 0cdh
	DW  L037A
	DB 0d1h

	DB 0afh
	DB 32h
	DW CBREAK
	DB 02ah
	DW L00CE
	DB 7ch
	DB 0b5h
	DB 0ddh,0e5h
	DB 0e1h
         DB 0edh,4bh
	DW L00CC
	DB 0EDH,042h
	DB 01h
	DW 0015H
	DB 09h
	DB 22h
	DW L00CE
	DB 0b7h
	DB 20h,(L2054)-$-1
	DB 0d5h			; save error type and code

	DB 0d5h
	DB 0e5h			; address where error occurred
         DB 0cdh
	DW  ERRORPTR
	DB 0d1h			; restore error type and code

L2054:	DB 7ah
	DB 0b7h
	DB 20h,(L206C)-$-1
	DB 0cdh
	DW  L0200		; D = 0 >> User Break
	DB '^C',0DH,0AH
	DB 'User break',0
	DB 18h,( L2097)-$-1

L206C:   DB 3dh
	DB 20h,(L207A)-$-1
	DB 0cdh
	DW  L0200		; D = 1 >> I/O error
L2075	EQU $+3
	DB 0DH,0AH,'I/O',0
	DB 18h,( L2088)-$-1

L207A:	DB 0cdh
	DW  L0200		; D = 2 >> Run-time error
	DB 0DH,0AH,'Run-time',0

L2088:	DB 0cdh
	DW  L0200
	DB ' error ',0

L2093:	DB 7bh
	DB 0cdh
	DW  L04B4

L2097:	DB 0cdh
	DW  L0200
	DB ', PC=',0
	DB 02ah
	DW L00CE
	DB 0cdh
	DW  L04AF
	DB 18h,( L20BD)-$-1

L20A8:   DB 0cdh
	DW  L0200
	DB 'Not enough memory',0
L20BD:	DB 0cdh
	DW  L0200
	DB 0DH,0AH,'Program aborted',0DH,0AH,0

L20D4:   DB 3ah
	DW L00D8
	DB 0b7h
;         JP Z,L278E
	DB 0eh,0
	DB 0cdh
	DW  MSXDOS

L20DE:	DB 0e1h
	DB 0d1h
	DB 0d1h
	DB 0e9h

;L20E2: