; ^QW: find current word
; ^QS: find current word without first letter (for names that start with an
;      underscore)

; - define the symbol 'MSX' to compile the msx compiler
;   otherwise the PC version will be generated

; - define the symbol 'USELIB' to compile all library routines
; - define the symbol 'NEWEXT' to use the new external routine

MESSAGESFORTILBURG:

NEEDEDMEMMANVERSION        EQU 0204h
NEEDEDGIOSVERSION          EQU 0222h

RUNTIME:
;NEWEXT:
FASTREAL:

IFNDEF MAKEPC
MSX:
ENDIF

IFDEF MSX
MSXDOS	EQU 5
USELIB:
ENDIF

         PUBLIC CON1OUTPTR

         PUBLIC L005C,L005D
	PUBLIC L0065,L0066,L006C,L0080,L00CE
	PUBLIC L00E0,L00F4,L0100,L0101,L0168
	PUBLIC L0168,L0169,L01AE,L01E1
	PUBLIC L01B4,L01BC,L01FA,L0200,L021D
	PUBLIC L023E,L0259,L0262,L026B
	PUBLIC L0284,L0299,L02A2,L0310,L03C9
	PUBLIC L03E1,L03EE,L0406,L04A6,L04B4,L04D2,L04AF
	PUBLIC L0591,L059B,L0612,L0783
	PUBLIC L07F7,L1008,L11A3,L14E8,L1726

	PUBLIC A2L

	; defined in COMPILER.MAC
	EXTRN L278E

	INCLUDE STDIO.INC

	INCLUDE LIBDEFS.INC

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

L0038:	DB 0
L0039:	DW 0

         ; L005C points to an area of 64 bytes because of the use
         ; as a file handle or FCB for the new routines
L005C:   DB 0                       ; start of FCB

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

         db 64 - 37 dup (0)

IFDEF MSX
L0080	EQU 0080H
ELSE
         ; L0080 already defined in RUNTIME.ASM
;L0080	 EQU $-1
ENDIF

	GLOBALS CONSTPTR
CONSTPTR:; FUNCTION KeyPressed: BOOLEAN;
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr CONSTPTR_1
ENDIF
CONSTPTR_1:DW L0316

	GLOBALS CONINPTR
CONINPTR:			; console input routine
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr CONINPTR_1
ENDIF
CONINPTR_1:DW L0320

	GLOBALS CONOUTPTR
CONOUTPTR:			; console output routine
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr CON1OUTPTR
ENDIF
CON1OUTPTR:DW L0339

	GLOBALS LSTOUTPTR
LSTOUTPTR:
         DB 0c3h
	DW  L032F                   ; jump opcode at 00A9H
				; LSTOUTPTR at absolute 00AAH

	GLOBALS AUXOUTPTR
AUXOUTPTR:
	DB 0c3h
	DW  L0334 		; jump opcode at 00ACH
				; AUXOUTPTR at absolute 00ADH

	GLOBALS AUXINPTR
AUXINPTR:
	DB 0c3h
	DW  L032A 		; jump opcode at 00AFH
				; AUXINPTR  at absolute 00B0H

	GLOBALS USROUTPTR
USROUTPTR:
	DB 0c3h
	DW  L0339 		; jump opcode at 00B2H
				; USROUTPTR at absolute 00B3H

	GLOBALS USRINPTR
USRINPTR:
	DB 0c3h
	DW  L0320 		; jump opcode at 00B5H
				; USRINPTR  at absolute 00B6H




         ; the order of the next 6 words must not be changed

	GLOBALS L00B8
L00B8:   DW 0                       ; CON, TRM, 00B8

	GLOBALS L00BA
L00BA:	DW 0			; KBD,	   00BA

	GLOBALS LST
LST:	DW 0			; LST,	   00BC, absolute 00BCH

	GLOBALS L00BE
L00BE:	DW 0			; AUX,	   00BE

	GLOBALS L00C0
L00C0:	DW 0			; USR,	   00C0

	GLOBALS OUTPUT
OUTPUT:	DW 0			; OUTPUT,   00C2, absolute 00C2H




	GLOBALS BUFLEN
BUFLEN:	DB 0;			; BUFLEN    at absolute 00D1H

	GLOBALS ERRORPTR
ERRORPTR:
IFDEF MSX
	DB 0C3H
ELSE
;!	jmp word ptr ERRORPTR_1
ENDIF
ERRORPTR_1:DW 0

	GLOBALS CBREAK
CBREAK:DW 0			; CBREAK    at absolute 00DDH

	GLOBALS HEAPPTR
HEAPPTR:DW 0			; HEAPPTR   at absolute 00C4H

	GLOBALS RECURPTR
RECURPTR:DW 0			; RECURPTR  at absolute 00C6H

L00C8:	DW 0			; 32 bit Seed number
         DB 0
L00CB:   DB 0                       ; waarde van R register

L00CC:   DW 0                       ; start of pascal source code
L00CE:	DW 0
ERRORSTACK:DW 0                     ;

ERROREXITOK EQU $-1                 ; high byte of stack pointer is always
                                    ; NZ if filled in

L00D0:   DB 0                       ; IORESULT value

L00D2:   DW 0                       ; address to temp buffer of 256 bytes

L00D4:   DW 0
L00D6:	DW 0
L00D8:	DB 0
L00DC:   DB 0                       ; current Overlay Drive
L00DE:	DW 0
L00E0:	DB 0

L00E2:	DW 0			; current device pointer
                                    ; (FIB pointer)

L00E4:	DW 0
L00E6:	DW 0
L00E8:	DW 0
L00E9    EQU L00E8+1
L00EA:	DW 0
L00EC:	DB 0
L00ED:	DW 0			; old device pointer

OVERLAYLOADONLY:
         DB 0
OVERLAYINFOADDRESS:
         DW 0
OVERLAYPOS:
         DW 0
         DW 0
OVERLAYDATALEN:
         DW 0

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

L01E1:   DB 0cdh
	DW  L0200                 ; print CR,LF
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

L01FA:   ; print ASCIIZ-string with highlighting
	DB 0e5h
	DB 21h
	DW L01EE
	DB 18h,( L0204)-$-1

L0200:	; print ASCIIZ-string without highlighting
	DB 0e5h
	DB 21h
	DW L01E8
L0204:	DB 22h
	DW L0213
	DB 0e1h
	DB 0e3h
L0209:	DB 0f5h
	DB 0c5h
L020B:	DB 0d5h

L020C:	DB 7eh
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

	GLOBALS L021D
L021D:	; LIB, delay
	; in:	HL = time to wait
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

	GLOBALS L023E
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

	GLOBALS L0259
L0259:	; PROCEDURE DelLine
	DB 0f5h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 21h
	DW L01B4		; DelLineStr
	DB 18h,( L024B)-$-1

	GLOBALS L0262
L0262:	; PROCEDURE InsLine;
	DB 0f5h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 21h
	DW L01AE		; InsLineStr
	DB 18h,( L024B)-$-1

	GLOBALS L026B
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

	GLOBALS L0284
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

	GLOBALS L0299
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
	GLOBALS L030A
L030A:	; PROCEDURE CrtInit;
	DB 21h
	DW L016B		; InitialStr
	DB 0c3h
	DW  L0235
ENDIF

	GLOBALS L0310
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
	DB 3eh,1			; assume there are characters present
	DB 20h,(L0316_OK)-$-1		; jump if characters present

	DB 3dh			; FALSE if not
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

L0320:	; in:	-
	; out:	HL = character read from keyboard
	;	H = always zero
IFNDEF MSX
	DB 11h
	DW 2*3		; Console Input
ELSE
         DB 0eh,8                     ; standard input without echo
                                    ; this is not CPM compatible !!!

L0321:
         DB 0cdh
	DW  MSXDOS
         ; L = A = character read from keyboard
         DB 18h,( L0326)-$-1
ENDIF    ; MSX


L0323:   DB 0cdh
	DW  L035F

L0326:	DB 6fh
	DB 26h,0
	DB 0c9h

L032A:
IFNDEF MSX
         DB 11h
	DW 6*3                  ; Reader Input
	DB 18h,( L0323)-$-1
ELSE
         DB 0eh,3                     ; Reader Input, Auxiliary Input
         DB 18h,( L0321)-$-1
ENDIF    ; MSX


L032F:   ; List Output, Printer Output
IFNDEF MSX
         DB 11h
	DW 4*3
	DB 18h,( L033C)-$-1
ELSE
         DB 16h,5
         DB 18h,( L033C)-$-1
ENDIF    ; MSX


L0334:   ; Puncher Output, Auxiliary Output
IFNDEF MSX
         DB 11h
	DW 5*3
	DB 18h,( L033C)-$-1
ELSE
         DB 16h,4
         DB 18h,( L033C)-$-1
ENDIF    ; MSX

L0339:   ; Console Output
IFNDEF MSX
         DB 11h
	DW 3*3                  ; Console Output
ELSE
         DB 16h,2                     ; Console Output
ENDIF    ; MSX

L033C:	DB 0e1h			; pop return address
	DB 0c1h			; C = character to print
	DB 0e5h			; push return address

	DB 3ah
	DW CBREAK
	DB 0b7h
	DB 28h,(L035D_1)-$-1		; jump if no break allowed

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
	DW  L03E1		; A = character from console
	DB 0feh, 3
         DB 0cah
	DW L20D4                 ; jump to Program Abort if ^C pressed

L035D:	DB 0c1h
	DB 0d1h

L035D_1:
IFDEF MSX
         DB 59h                     ; E = character to print
         DB 4ah                     ; DOS function
         DB 0c3h
	DW  MSXDOS
ENDIF    ; MSX

L035F:
IFDEF MSX
	DB 02ah
	DW 0001H
	DB 019h
	DB 0e9h
ELSE
	DB 0c3h
	DW  DOSIO 		; ----
ENDIF    ; MSX

         GLOBALS L0364
L0364:   ; InitCharIO
         DB 22h
	DW L00D2              ; LIB, set temp buffer address
	DB 78h
	DB 32h
	DW CBREAK
;	 LD A,C
;	 OR A
;	 JR Z,L037A

IFDEF MSX ; patch
	DB 3eh,0C3H		; install CBREAK handler at RST 0008H !
	DB 32h
	DW 0008H	        ; LD (L0038),A
	DB 21h
	DW L1FFB
	DB 22h
	DW 0009H	        ; LD (L0039),HL
ENDIF	; MSX

L037A:
IFDEF MSX
	DB 21h
	DW L03A5
	DB 11h
	DW CONSTPTR
	DB 01h
	DW L03A5_L
	DB 0edh,0b0h
ENDIF    ; MSX

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

         DB 0cdh
	DW  INITFILEIO            ; Set DOS2Present variable

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 0c4h
	DW CHECKREDIRECTION

         DB 32h
	DW REDIRECTIONFLAG     ; 0 if DOS 1
                                    ; NonZero if DOS 2 and redirection active

IFDEF MSX
	DB 0c3h
	DW  IGIOS
ELSE
	DB 0c9h
ENDIF	; MSX

IFDEF MSX
REDIRECTIONFLAG:
         DB 0                       ; 0 = no input redirection
                                    ; 255 = input redirection

CHECKREDIRECTION:
         ; in:    -
         ; out:   A = 0 if no redirection
         ;        A = 255 if redirection present
         DB 3eh,0                     ; Get State
         DB 0eh,70H                   ; Get/Set Redirection State
         DB 0cdh
	DW  MSXDOS
         DB 3eh,0                     ; assume no input redirection
         DB 0cbh,040h
         DB 0c8h                      ; return if no input redirection

         DB 3dh                      ; A = 255
         DB 0c9h
ENDIF    ; MSX

IFDEF MSX
IGIOS:   ; checks if GIOS-TSR is present

	DB 0afh
	DB 32h
	DW GIOSOK
	DB 6fh
	DB 67h
	DB 22h
	DW MEMMNVER		; reset MemMan version
	DB 22h
	DW GIOSVER		; reset GIOSVersion

         DB 3eh,0AAH                  ; runtime: MemMan not present
         DB 32h
	DW L201D

         DB 21h
	DW L201C
         DB 22h
	DW RUNGIOS+1          ; default r.error

	DB 0cdh
	DW  CHKMMAN
	DB 32h
	DW MEMMAN		; 1 = MemMan present
				; 0 = MemMan not present
	DB 0c8h			; quit if not present

         DB 3eh,0ABH                  ; runtime: Wrong MemMan version
         DB 32h
	DW L201D

	DB 06h,7			; MemMan version
	DB 11h
	DW 4DH*256+50
	DB 0d5h
	DB 0cdh
	DW  0FFCAH		; get MemMan version
	DB 22h
	DW MEMMNVER		; save MemManVersion #H.L

         DB 11h
	DW NEEDEDMEMMANVERSION  ; minimum version
         DB 0b7h
         DB 0EDH,052h                  ; current >= NeededMemManVersion ?

	DB 06h,8			; address of XTsrCall
	DB 0d1h

         DB 0d8h                      ; return if Wrong MemMan version

         DB 3eh,0ACH                  ; runtime: GIOS-tsr not present
         DB 32h
	DW L201D

	DB 0cdh
	DW  0FFCAH		; get address of XTsrCall
	DB 22h
	DW TSRCALL1

	DB 21h
	DW GIOSTSRNAME
         DB 0cdh
	DW  CHECKTSR
	DB 0c8h			; quit if GIOS TSR not present

         DB 3eh,0ADH                  ; runtime: GIOS not present
         DB 32h
	DW L201D

         ; BC = TsrID

;         PUSH BC                    ; save TsrID
;
;         LD A,1                     ; WriteIndex
;         LD HL,4                    ; Set address of ErrorNumber
;         LD DE,ErrorNumber          ; ErrorNumber address
;
;         CALL TSRCALL
;
;         POP BC                     ; restore TsrID


         DB 0c5h                    ; save TsrID

	DB 0afh			; ReadIndex
	DB 21h
	DW 0			; GetVersion

         DB 0cdh
	DW  TSRCALL
	DW 53edh,GIOSVER

	DB 0c1h			; restore TsrID


         DB 7ah
	DB 0b3h
	DB 0c8h			; quit if COM-file not loaded
                                    ; runtime: GIOS not present

         DB 3eh,0AEH                  ; runtime: Wrong GIOS version
         DB 32h
	DW L201D

         DB 21h
	DW NEEDEDGIOSVERSION
         DB 0ebh
         DB 0b7h
         DB 0EDH,052h                  ; current - NeededGIOSVersion
         DB 0d8h                      ; quit if current < NeededGIOSVersion

         DB 3eh,1
	DB 32h
	DW GIOSOK		; 1 = GIOS Present, if TSR and COM-file
				;		  loaded

	DB 0afh			; ReadIndex
	DB 21h
	DW 1			; Get RunGIOS
	DB 0cdh
	DW  TSRCALL
         DW 53edh,RUNGIOS+1

         DB 21h
	DW ERRORNUMBER
         DB 0e5h                    ; address of ErrorNumber
         DB 21h
	DW 0
         DB 0e5h                    ; Dummy
         DB 0e5h                    ; Dummy

         DB 3eh,1                     ; GIOSInit ( AddressErrorNumber, 0, 0)
         DB 0cdh
	DW  RUNGIOS               ; call because return address must
                                    ; be pushed before entering GIOS

         DB 0c9h

TSRCALL: ; in:	BC = TsrID
	DB 0c5h
	DB 0ddh,0e1h			; IX = TsrID
	DB 0C3H
TSRCALL1:DW 0

CHECKMEMMAN:
         ; caution: the second address popped from the stack must be the
         ;          address to return to when pascal continues
         DB 3ah
	DW L201D
         DB 0feh, 0ACH
         DB 0d0h                     ; continue if error = MemMan not present or
                                    ;             error = wrong MemMan version

         DB 0e1h                     ; remove call address to checkmemman
         DB 0c3h
	DW  L2027

CHECKTSR:
	; in:	HL = name of TSR
	; out:	BC = TsrID code
	;	A = 1, present
	;	A = 0, not present
	DB 11h
	DW 4DH*256+62
	DB 0cdh
	DW  0FFCAH
	DB 3fh
	DB 3eh,0
	DB 08fh
	DB 0c9h

TSRNAME: DB '            '

	GLOBALS TSRPRESENT
TSRPRESENT:
	; in:	string with tsr-name pushed on stack
         DB 0cdh
	DW  CHECKMEMMAN           ; check if memman is present

	DB 0ddh,0e1h			; IX = return address

	DB 21h
	DW 0
	DB 45h
	DB 039h		; HL = SP
	DB 4eh		; BC = length of string

	DB 23h

	DB 0e5h
	DB 09h		; HL + length of string
	DB 0e3h		; push new stack pointer
				; HL = start of first data byte

	DB 79h
	DB 0feh, 12 + 1
	DB 3eh,12			; assume 12 spaces
	DB 38h,(TSRPRESENT1)-$-1		; jump if length <= 12

	DB 4fh			; maximum length of 12

TSRPRESENT1:
	DB 091h			; minus number of characters

	DB 11h
	DW TSRNAME

	DB 0ch
	DB 0dh
	DB 28h,(TSRPRESENT2)-$-1		; jump if string = empty

	DB 0edh,0b0h			; copy string

TSRPRESENT2:
	DB 0ebh

TSRPRESENT3:
	DB 0b7h
	DB 28h,(TSRPRESENT4)-$-1

	DB 36h,' '
	DB 23h
	DB 3dh
	DB 18h,( TSRPRESENT3)-$-1

TSRPRESENT4:
	DB 0e1h
	DB 0f9h 		; pop string from stack

	DB 0ddh,0e5h			; restore return address

	DB 21h
	DW TSRNAME
	DB 0cdh
	DW  CHECKTSR
	DB 6fh			; return boolean
	DB 26h,0
	DB 0c9h


CHKMMAN: ; in:	-
	; out:	A = 1, MemMan present, Z-flag = 0
	;	A = 0, not present, Z-flag = 1
	DB 3eh,65H
	DB 11h
	DW 4DH*256+30
	DB 0cdh
	DW  0FFCAH
	DB 11h
	DW 4DH*256+30
	DB 0cdh
	DW  0FFCAH
	DB 0c6h,1
	DB 3eh,0
	DB 08fh
	DB 0c9h

ENDIF	; MSX

	GLOBALS RUNGIOS
RUNGIOS: DB 0C3H
         DW L201C                   ; default r.error GIOS not present

	GLOBALS MEMMAN
MEMMAN:	DB 0			; 1 = MemMan present, 0 = not present

	GLOBALS MEMMNVER
MEMMNVER:DW 0			; version: H.L

	GLOBALS GIOSOK
GIOSOK:	DB 0			; 1 = GIOS present,   0 = not present

	GLOBALS GIOSVER
GIOSVER: DW 0			; version: H.L, hexadecimal
GIOSTSRNAME:
	DB 'FH GIOS 2.1 '

L03A5:	DB 0c3h
	DW  L0316 		; keypressed
	DB 0c3h
	DW  L0320 		; read character from console
	DB 0c3h
	DW  L0339 		; write character to console
	DB 0c3h
	DW  L032F
	DB 0c3h
	DW  L0334
	DB 0c3h
	DW  L032A
	DB 0c3h
	DW  L0339 		; write character to console
	DB 0c3h
	DW  L0320 		; read character from console
L03A5_L EQU $ - L03A5

L03BD:	DW 0C1H			; Con / Trm	, read and write
	DW 82H			; Kbd		, read
	DW 43H			; Lst		, write
	DW 0C4H			; Aux		, read and write
	DW 0C5H			; Usr		, read and write
	DW 0C1H			; Input / Output	, read and write

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

L03D9:	DB 0fdh,0e1h
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
L03E8:   DB 0cdh
	DW  CONINPTR
	DB 7dh
	DB 18h,( L03D9)-$-1 		; same end as 'print character'

	; -----------------------------------------------------------

L03EE:   ; parses a filename at DE with wildcards to FCB at L005C
	DB 0eh,0FFH		; with wildcards
	DB 18h,( L03FE)-$-1

L03F2:   ; parses a string whose address is in L00D2 to FCB at L005C
	; with no wildcards, skips leading spaces in string
	DB 0eh,0			; don't allow wildcards
	DB 0edh,5bh
	DW L00D2
L03F8:   DB 13h
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
         DB 06h,FCB_LEN-11            ; 33e, -12
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

L04C8:	; converts integer HL to an unsigned byte A
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
	DB 0c8h			; return if HL < 256

L04D2:	DB 3ah
	DW L04D2_D		; code area
	DB 0c9h

L04D2_D: DB 0			; data area


IFDEF USELIB

	GLOBALS L04D4
L04D4:   ; the return address of this routine is the start address
         ; of the pascal code !!
         DB 0f3h
         DB 32h
	DW L00D8
	DB 0c5h
         DB 0cdh
	DW  L1EAF
	DB 0c1h
IFDEF MSX
	DB 02ah
	DW 0006H		; HL = top of memory
ELSE
	DB 02ah
	DW L0006		; HL = top of memory
ENDIF
	DB 0b7h
	DB 0EDH,042h		; < top of memory ?
         DB 0dah
	DW L20A8                 ; jump if out of memory

	DB 0ebh
	DB 0d1h
	DB 0f9h
         DB 0fbh
	DB 01h
	DW -1024
	DB 09h
	DB 22h
	DW RECURPTR

	DB 0afh
;         LD L,A
;         LD H,A
;         LD (L00CE),HL
         DB 32h
	DW L00DC               ; reset Overlay Drive
	DB 3eh,0C3H
         DB 32h
	DW ERRORPTR
         DB 21h
	DW L20DE
	DB 22h
	DW ERRORPTR_1
	DB 0ebh
         DB 22h
	DW L00CC              ; set start address of pascal code
	DB 0e9h

	GLOBALS L0508
L0508:	; heap alloc
	; in:	HL = source of data to put on heap
	;	BC = length of data to allocate
	DB 0e5h
	DB 02ah
	DW RECURPTR
	DB 0b7h
	DB 0EDH,042h		; decrease with BC bytes
	DB 22h
	DW RECURPTR
	DB 0edh,5bh
	DW HEAPPTR
	DB 0b7h
	DB 0EDH,052h
	DB 019h
	DB 0ebh
	DB 0e1h
	DB 0dah
	DW L1D75
	DB 0edh,0b0h
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L0522
L0522:	; heap de-alloc
	DB 02ah
	DW RECURPTR
	DB 0edh,0b0h
	DB 22h
	DW RECURPTR
; 33e         EXX                        ; restore registers
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L052C
L052C:	; LIB
	; get REAL HLDEBC from address HL
	; in:	HL = address of REAL, variable
	; out:	HLDEBC = REAL stored at that address
	DB 5eh		; get HL part
	DB 23h
	DB 56h
	DB 23h
	DB 0d5h			; save HL part
	DB 5eh		; get DE part
	DB 23h
	DB 56h
	DB 23h
	DB 4eh		; get BC part
	DB 23h
	DB 46h
	DB 0e1h			; restore HL part
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L053A
L053A:	; PushString
	DB 0ddh,0e1h			; LIB
	DB 0ebh
	DB 1ah
	DB 4fh
	DB 06h,0
	DB 2fh
	DB 6fh
	DB 26h,0FFH
	DB 039h
	DB 0f9h
	DB 0ebh
	DB 03h
	DB 0edh,0b0h
	DB 0ddh,0e9h

	GLOBALS L054D
L054D:	; PushConstantString
	; string follows call to this function
	DB 0d1h
	DB 1ah
	DB 4fh
	DB 06h,0
	DB 2fh
	DB 6fh
	DB 26h,0FFH
	DB 039h
	DB 0f9h
	DB 0ebh
	DB 03h
	DB 0edh,0b0h
	DB 0e9h

	GLOBALS L055D
L055D:	; push a SET on to the stack
	; in:	HL = address of SET to push on the stack
	;	B = offset within SET
	;	C = length of SET
	DB 0ddh,0e1h
	DB 0ebh
	DB 21h
	DW -32
	DB 039h
	DB 0f9h 		; reserve 32 bytes for a SET
	DB 0ebh 		; HL = source address of SET
				; DE = start of reserved SET
	DB 0c5h

	; clear first unused bytes
	DB 04h
	DB 05h
	DB 28h,(L0570)-$-1		; jump if no unused bytes

	DB 0afh

L056C:	DB 12h
	DB 13h
	DB 10h,( L056C)-$-1
	; B = 0
L0570:
	DB 0edh,0b0h			; copy used bytes to reserved SET
	DB 0c1h			; B = offset
				; C = length

	DB 3eh,020H		; A = 32 - offset - length
	DB 090h
	DB 091h
	DB 28h,(L057F)-$-1		; jump if no last unused bytes

	; clear last unused bytes
	DB 47h
	DB 0afh
L057B:	DB 12h
	DB 13h
	DB 10h,( L057B)-$-1
L057F:	DB 0ddh,0e9h			; jump to return address

ENDIF	; USELIB

	GLOBALS L0581
L0581:	; LIB
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

	GLOBALS L0591
L0591:	; add element HL to SET at stack
	;
	DB 0ddh,0e1h
	DB 45h			; B = element to add
	DB 0cdh
	DW  L05BA

L0597:	DB 0b6h
	DB 77h

L0599:	DB 0ddh,0e9h

	GLOBALS L059B
L059B:
	DB 0ddh,0e1h			; LIB
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


IFDEF USELIB

	GLOBALS L05D1
L05D1:	; LIB
	; puts REAL HL'DE'BC' at address HL
	; compare with 'A:=ln(2)' where HL = address of A and HL'DE'BC'
	; is the result of ln(2)
	; in:	HL, HL',DE',BC'
	; out:	HL + 5
	DB 0e5h			; destination address on stack
	DB 0d9h			; REAL in HLDEBC
	DB 0ebh
	DB 0e3h
	DB 73h		; save HL first
	DB 23h
	DB 72h
	DB 23h
	DB 0d1h
	DB 73h		; save DE
	DB 23h
	DB 72h
	DB 23h
	DB 71h		; save BC
	DB 23h
	DB 70h
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB
	GLOBALS L05E2
L05E2:	; pop pushed STRING
	; copy pushed <string> to address HL, truncate to maximum length of B
	; in:	<string> pushed at stack
	;	HL = destination address for string
	;	 B = maximum length of string to copy
	; out:	DE = first byte after destination string
	; changes: AF,BC,DE,HL,IX
	DB 0ddh,0e1h			; IX = return address

	DB 78h			; A = maximum length of string
	DB 0ebh 		; DE = destination address

	DB 21h
	DW 0
	DB 44h			; B = 0
	DB 039h		; HL = SP
	DB 4eh		; BC = length byte of string
	DB 0e5h			; save start of string
	DB 09h		; HL = address of last string character

L05EE:	DB 23h			; HL = address just after string
                                    ; stack pointer to return

	DB 0e3h		; HL = start of string
				; address just after string at stack
				; new stack pointer pushed at stack

	DB 0b9h			; maximum length - string length
				; string length > maximum length ?
	DB 38h,(L05F4)-$-1		; yes, jump if true (ignore rest of string)

	; maximum length <= string length
	DB 79h			; truncate string length to maximum

L05F4:	DB 12h		; set length of destination string
	DB 13h			; DE = first databyte of destination string
	DB 23h			; HL = first databyte of string
	DB 0b7h
	DB 28h,(L05FD)-$-1		; quit if length = 0

	DB 4fh			; C = length of truncated string
	DB 0edh,0b0h			; copy string data

L05FD:	DB 0e1h			; address just after string
	DB 0f9h 		; remove string from stack

	DB 0ddh,0e9h			; jump to return address

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L0601
L0601:	; pop pushed STRING
	; copy pushed <string> to address HL, truncate to maximum length of B
	; in:	<string> pushed first on stack
	;	<destination> pushed as second on stack
	DB 0ddh,0e1h
	DB 78h
	DB 21h
	DW 0
	DB 44h			; B = 0
	DB 039h
	DB 4eh		; BC = length of start
	DB 0e5h			; save start of string
	DB 09h
	DB 23h
	DB 5eh		; DE = destination address of string
	DB 23h
	DB 56h		; HL = highest byte of pushed parameters
	DB 18h,( L05EE)-$-1

ENDIF	; USELIB


	GLOBALS L0612
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

L061F:	DB 039h
	DB 0f9h
	DB 0ddh,0e9h


IFDEF USELIB

	GLOBALS L0623
L0623:	; pop pushed set to the pushed address
	; PROCEDURE CopySet(VAR Set1: set; Set2: set);
	;
	; in:	<SET> first pushed parameter
	;	<ADDRESS> second pushed parameter
	;	C = bytes to copy from SET
	;	B = offset within SET
	DB 0ddh,0e1h
	DB 21h
	DW 0020H		; HL = length of a SET
	DB 039h
	DB 5eh		; DE = address where to put SET
	DB 23h			;
	DB 56h		;

	DB 68h			; HL = offset within SET
	DB 26h,0
	DB 44h			; BC = length
	DB 039h		; HL = SP + offset

	DB 0edh,0b0h
	DB 21h
	DW 0022H		; remove SET and address
	DB 18h,( L061F)-$-1

	GLOBALS L0638
L0638:	; push ARRAY OF CHAR as string
	; in:	HL = source-address
	;	B  = length, > 0
	; out:	<length> pushed first (byte)
	;	<data> pushed next
	DB 0ddh,0e1h			; LIB
	DB 0ebh 		; DE = source-address
	DB 78h
	DB 2fh
	DB 6fh			; HL = -length
	DB 26h,0FFH
	DB 039h		; HL = SP - length
	DB 0f9h 		; SP = SP - length    make space in stack
	DB 70h		; put length on top
	DB 23h			; HL = destination address of data
	DB 48h			; BC = length of data
	DB 06h,0
	DB 0ebh 		; HL = source-address
				; DE = destination address
	DB 0edh,0b0h
	DB 0ddh,0e9h

	GLOBALS L064C
L064C:	; Index Check
	DB 0b7h			; if DE > HL then r.error 90H else RET
	DB 0EDH,052h
	DB 019h
	DB 0d8h
	DB 3eh,090H		; r.error 90H: Index out of range
	DB 0c3h
	DW  L2027 		; Run-Time error

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L0656
L0656:   ; Subrange Check
	; in:	HL = value to check if its >= DE and < DE+BC
	;	DE = base
	;	BC = length
	; out:	HL,DE,BC unchanged
	DB 0b7h
	DB 0EDH,052h		; subtract base
	DB 0b7h
	DB 0EDH,042h		; subtract length
	DB 30h,(L0661)-$-1		; jump if result >= length

	DB 09h		; undo subtracting
	DB 019h
	DB 0c9h

L0661:	DB 3eh,091H		; r.error 91H: Scalar or subrange out of range
	DB 0c3h
	DW  L2027 		; Run-time error

ENDIF	; USELIB


         GLOBALS L_FOR_TO
L_FOR_TO:
         ; FOR xx := start TO end
         ; in:    DE:HL = end
         ;        (sp+2):(sp) = start
         ; out:   DE:HL = length
         ;        Carry set if start > end
         ;POP IX                     ; IX = return address


         GLOBALS L_FOR_DOWNTO
L_FOR_DOWNTO:
         ; FOR xx := start TO end
         ; in:    DE:HL = end
         ;        (sp+2):(sp) = start
         ; out:   DE:HL = length
         ;        Carry set if start > end

IFDEF USELIB

	GLOBALS L0666
L0666:   ; FOR xx := start TO end
	; in:	HL = end
	;	DE = start
         ; out:   DE = length
	DB 0b7h			; LIB
         DB 0EDH,052h                  ; end - start
         DB 0ebh                   ; DE = length
L066A:

;!	pushf
         DB 13h                     ; end - start + 1
;!	popf
IFDEF MSX
	DB 0eah
	DW L0671
ELSE
;!	jo near ptr L0671 	; jump if overflow, PE
ENDIF

	DB 0f0h
	DB 18h,( L0672)-$-1

L0671:	DB 0f8h

L0672:	DB 11h
	DW 0000
	DB 0c9h

	GLOBALS L0676
L0676:	; FOR xx := start DOWNTO end
	; in:	HL = end
	;	DE = start
	DB 0d5h			; LIB
	DB 0ebh
	DB 0b7h
         DB 0EDH,052h                  ; start - end
	DB 0ebh
	DB 0e1h
	DB 18h,( L066A)-$-1

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L067F
L067F:	; X = Y ? : Integer, Byte, Boolean or Char
	; in:	X = DE, Previous
	;	Y = HL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0b7h
	DB 0EDH,052h

L0682:	; Equal
	DB 21h
	DW 1
	DB 0c8h
	DB 2bh
	DB 0c9h

         GLOBALS L_PRED
L_PRED:  ; in:    DE:HL
         ; out:   DE:HL
         ; changes: BC

         DB 01h
	DW 1
         DB 0b7h
         DB 0EDH,042h                  ; low-word - 1
         DB 0d0h                     ; return if >= 0

         DB 1bh                     ; high-word - 1
         DB 0c9h

         GLOBALS L_SUCC
L_SUCC:  ; in:    DE:HL
         ; out:   DE:HL
         ; changes: BC

         DB 01h
	DW 1
         DB 09h                  ; low-word + 1
         DB 0d0h                     ; return if <= 0ffffh

         DB 13h                     ; high-word + 1
         DB 0c9h

	GLOBALS L_EQ
L_EQ:	; X = Y ? : Longint
	; in:	X at stack, Previous
	;	Y in DEHL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L_CMP		; Compare longints
         DB 0c3h
	DW  L0682

	GLOBALS L0688
L0688:	; X = Y ? : Real
	; in:	X = BCDEHL , Previous
	;	Y = BCDEHL', Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0BDF		; Compare REALS
         DB 0c3h
	DW  L0682                   ; Equal

	GLOBALS L068D
L068D:	; X = Y ? : String
	; in:	X = pushed first , Previous
	;	Y = pushed second, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L09B0		; Compare STRINGS
         DB 0c3h
	DW  L0682                   ; Equal

	GLOBALS L0692
L0692:	; X <> Y ? : Integer, Byte, Boolean or Char
	; in:	X = DE, Previous
	;	Y = HL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0b7h
	DB 0EDH,052h

L0695:	; Not Equal
	DB 21h
	DW 1
	DB 0c0h
	DB 2bh
	DB 0c9h

	GLOBALS L_NEQ
L_NEQ:	; X <> Y ? : Longint
	; in:	X at stack, Previous
	;	Y in DEHL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L_CMP		; Compare longints
	DB 18h,( L0695)-$-1 		; Not Equal

	GLOBALS L069B
L069B:	; X <> Y ? : Real
	; in:	X = BCDEHL , Previous
	;	Y = BCDEHL', Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 18h,( L0695)-$-1 		; Not Equal

	GLOBALS L06A0
L06A0:	; X <> Y ? : String
	; in:	X = pushed first , Previous
	;	Y = pushed second, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L09B0		; Compare STRINGS
	DB 18h,( L0695)-$-1 		; Not Equal


	GLOBALS L06A5
L06A5:	; X >= Y ? : Integer, Byte, Boolean or Char
	; in:	X = DE, Previous
	;	Y = HL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0772		; Compare signed Integers

L06A8:	; Greater or Equal
	DB 21h
	DW 1
	DB 0d0h
	DB 2bh
	DB 0c9h

	GLOBALS L_GTE
L_GTE:	; X >= Y ? : Longint
	; in:	X at stack, Previous
	;	Y in DEHL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L_CMP		; Compare longints
	DB 18h,( L06A8)-$-1 		; Greater or Equal

	GLOBALS L06AE
L06AE:	; X >= Y ? : Real
	; in:	X = BCDEHL , Previous
	;	Y = BCDEHL', Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 18h,( L06A8)-$-1 		; Greater or Equal

	GLOBALS L06B3
L06B3:	; X >= Y ? : String
	; in:	X = pushed first , Previous
	;	Y = pushed second, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L09B0		; Compare STRINGS
	DB 18h,( L06A8)-$-1 		; Greater or Equal

	GLOBALS L06B8
L06B8:	; X <= Y ? : Integer, Byte, Boolean or Char
	; in:	X = DE, Previous
	;	Y = HL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0772		; Compare signed Integers

L06BB:	; Less or Equal
	DB 21h
	DW 1
	DB 0c8h
	DB 0d8h
	DB 2bh
	DB 0c9h

	GLOBALS L_LSE
L_LSE:	 ; X <= Y ? : Longint
	; in:	X at stack, Previous
	;	Y in DEHL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L_CMP		; Compare longints
	DB 18h,( L06BB)-$-1 		; Less or Equal

	GLOBALS L06C2
L06C2:	; X <= Y ? : Real
	; in:	X = BCDEHL , Previous
	;	Y = BCDEHL', Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 18h,( L06BB)-$-1 		; Less or Equal

	GLOBALS L06C7
L06C7:	; X <= Y ? : String
	; in:	X = pushed first , Previous
	;	Y = pushed second, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L09B0		; Compare STRINGS
	DB 18h,( L06BB)-$-1 		; Less or Equal

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L06CC
L06CC:	; X > Y ? : Integer, Byte, Boolean or Char
	; in:	X = DE, Previous
	;	Y = HL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0772		; Compare signed Integers

L06CF:	; Greater
	DB 21h
	DW 0
	DB 0c8h
	DB 0d8h
	DB 23h
	DB 0c9h

	GLOBALS L_GT
L_GT:	; X > Y ? : Longint
	; in:	X at stack, Previous
	;	Y in DEHL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L_CMP		; Compare longints
	DB 18h,( L06CF)-$-1 		; Greater

	GLOBALS L06D6
L06D6:	; X > Y ? : Real
	; in:	X = BCDEHL , Previous
	;	Y = BCDEHL', Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 18h,( L06CF)-$-1 		; Greater

	GLOBALS L06DB
L06DB:	; X > Y ? : String
	; in:	X = pushed first , Previous
	;	Y = pushed second, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L09B0		; Compare STRINGS
	DB 18h,( L06CF)-$-1 		; Greater

	GLOBALS L06E0
L06E0:	; X < Y ? : Integer, Byte, Boolean or Char
	; in:	X = DE, Previous
	;	Y = HL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
         DB 0cdh
	DW  L0772                 ; Compare Signed Integers

L06E3:	; Less
	DB 21h
	DW 1
	DB 0d8h
	DB 2bh
	DB 0c9h

	GLOBALS L_LS
L_LS:	; X < Y ? : Longint
	; in:	X at stack, Previous
	;	Y in DEHL, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L_CMP		; Compare longints
	DB 18h,( L06E3)-$-1 		; Less

	GLOBALS L06E9
L06E9:	; X < Y ? : Real
	; in:	X = BCDEHL , Previous
	;	Y = BCDEHL', Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 18h,( L06E3)-$-1 		; Less

	GLOBALS L06EE
L06EE:	; X < Y ? : String
	; in:	X = pushed first , Previous
	;	Y = pushed second, Current
	; out:	HL = 1, if true
	;	HL = 0, if false
	DB 0cdh
	DW  L09B0		; Compare STRINGS
	DB 18h,( L06E3)-$-1 		; Less

	; INTEGER-Arithmetic

	GLOBALS L06F3
L06F3:	; LIB
	; FUNCTION SQR(I: INTEGER): INTEGER;
	; in:	HL = value to calcute square
	; out:	HL = HL * HL
	DB 54h			; DE = HL
	DB 5dh

ENDIF	; USELIB


	GLOBALS L06F5
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


IFDEF USELIB

	GLOBALS L070F
L070F:	; X div Y : INTEGER
	; in:	DE = X
	;	HL = Y
	; out:	HL = X div Y
	;	DE = X mod Y
	DB 7ch			; Y = 0 ?
	DB 0b5h
	DB 0cah
	DW L0A03		; jump if Division by zero

	DB 0cdh
	DW  I_DIV_0

	DB 02ah
	DW I_DDAT
	DB 0f0h			; quit if result = positive

	DB 0c3h
	DW  L0783

I_DDAT:	DW 0
I_DIV_0: ; X div Y : INTEGER
	; in:	DE = X
	;	HL = Y
	; out:	C = number of bits processed
	;	result in I_DDAT
	;	MOD = HL shr C
	;	A = positive if result is positive
	;	A = negative if result is negative

	; HL = INTEGER A = Y
	; DE = INTEGER B = X

	DB 7ch
	DB 0aah
	DB 0f5h			; save resulting sign
				; P = positive, M = minus

	DB 0cdh
	DW  L0780		; HL = absolute HL

	DB 0ebh
	DB 0cdh
	DW  L0780		; HL = absolute HL

	; HL = X
	; DE = Y

	DB 01h
	DW 0
	DW 43edh,I_DDAT

	DB 0eh,1			; bits = 1

I_DIV1:	; save old B and multiply b by 2
	DB 0d5h
	DB 0cbh,23h
	DB 0cbh,12h

	DB 0e5h
	DB 0b7h
	DB 0EDH,052h
	DB 0e1h
	DB 38h,(I_DIV_2)-$-1

	DB 0ch
	DB 0f1h			; remove saved INTEGER B
	DB 0c3h
	DW  I_DIV1		; repeat loop

I_DIV_2: DB 0d1h			; restore INTEGER B

	DB 06h,8			; assume 8 bits, 0 rest

	DB 79h
	DB 0e6h, 7
	DB 28h,(I_DIV_3)-$-1		; jump if zero, means 8 bits
	DB 47h

I_DIV_3: DB 79h
	DB 3dh
	DB 0e6h, 18H
	DB 0fh
	DB 0fh
	DB 0fh			; A = index to byte to start at
	DB 0d9h
	DB 01h
	DW I_DDAT
	DB 081h
	DB 4fh
	DB 78h
	DB 0ceh,0
	DB 47h
	DB 0d9h

	; HL = unsigned INTEGER A
	; DE = unsigned INTEGER B * (2^(C - 1))
	;   B = initial number of bits after which the first byte will
	;       be stored
	;   C = number of bits to proces
	; BC' = address where to store result
	DB 0afh			; init first result byte

	DB 0c5h			; save number of bits to proces

I_DIV_4: DB 087h			; result * 2

	DB 0e5h			; save INTEGER A
	DB 0b7h
	DB 0EDH,052h
	DB 38h,(I_DIV_5)-$-1		; jump if A < B

	DB 33h			; remove saved LONGINT A
	DB 33h

	DB 3ch			; result:=result+1
	DB 18h,( I_DIV_6)-$-1

I_DIV_5: DB 0e1h			; restore INTEGER A

I_DIV_6: DB 029h		; LONGINT A * 2

	DB 10h,( I_DIV_7)-$-1		; result bits - 1
                                    ; result = full ?
				; jump if not
	DB 0d9h
	DB 02h		; save result
	DB 0bh
	DB 0d9h
	DB 06h,8			; start al over

I_DIV_7: DB 0dh
	DB 20h,(I_DIV_4)-$-1

	DB 0c1h			; C = number of bits processes (for MOD)
	DB 0f1h			; A = resulting sign
				; Sign flag still set !
	DB 0c9h

	GLOBALS L073B
L073B:	; FUNCTION Random(Range: INTEGER): INTEGER;
	DB 0e5h
	DB 0cdh
	DW  L0792
	DB 0cbh,3ch
	DB 0cbh,1dh
	DB 0d1h			; DE = Range
	DB 0ebh 		; HL = random value

	GLOBALS L0745
L0745:	; X mod Y : INTEGER
	; in:	DE = X
	;	HL = Y
	; out:	HL = X mod Y
;         BIT 7,D                    ; test for result sign
;         PUSH AF                    ; save resulting sign

	DB 0cdh
	DW  I_DIV_0
         DB 0f5h                    ; 33f, save resulting sign

	; HL = RESULT SHL C
	DB 41h
	DB 0cdh
	DW  L075A

	DB 0f1h
         DB 0f0h                      ; return if sign bit was '0'

	DB 0c3h
	DW  L0783 		; X mod Y = negative

	GLOBALS L074E
L074E:	; X shl Y : INTEGER
	; in:	DE = X
	;	HL = Y
	; out:	HL = X shl Y
	DB 0cdh
	DW  L0761		; Range16
	DB 0c8h			; return if count = 0

L0752:	DB 029h
	DB 10h,( L0752)-$-1
	DB 0c9h

	GLOBALS L0756
L0756:	; X shr Y : INTEGER
	; in:	DE = X
	;	HL = Y
	; out:	HL = X shr Y
	DB 0cdh
	DW  L0761		; Range16
	DB 0c8h			; return if count = 0

L075A:	DB 0cbh,3ch
	DB 0cbh,1dh
	DB 10h,( L075A)-$-1
	DB 0c9h

ENDIF	; USELIB


L0761:	; Range16
	DB 0ebh
	DB 7ah
	DB 0b7h
	DB 20h,(L076E)-$-1		; HL = 0
	DB 7bh
	DB 0feh, 16
	DB 30h,(L076E)-$-1		; HL = 0
	DB 47h
	DB 0b7h
	DB 0c9h

L076E:	; HL = 0
	DB 0afh
	DB 67h
	DB 6fh
	DB 0c9h

L0772:	; compare two signed integers
	; in:	DE = X, Previous
	;	HL = Y, Current
	; out:	DE = Y
	;	HL = X
	;	Equal,		if DE = HL,  Zero
	;	Not Equal,	if DE <> HL, NonZero
	;	Greater or Equal, if DE >= HL, NonCarry
	;	Less or Equal,	if DE <= HL, Zero or Carry
	;	Greater than,	if DE > HL,  NonZero and NonCarry
	;	Less than,	if DE < HL,  Carry
	DB 0ebh
	DB 7ch
	DB 0aah
	DB 7ch			; high byte of X
	DB 0fah
	DW L077E
	DB 0bah
	DB 0c0h
	DB 7dh
	DB 0bbh
	DB 0c9h

L077E:	DB 17h
	DB 0c9h

	GLOBALS L0780
L0780:	; Abs X : INTEGER
	; in:	HL = X
	; out:	HL = -X, if X < 0
	;	HL = X, if X >= 0
	DB 0cbh,07ch			; LIB, HL = negative ?
	DB 0c8h			; return if positive

	GLOBALS L0783
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


IFDEF USELIB

	GLOBALS L078B
L078B:	; convert integer HL to boolean HL
	; Odd X : INTEGER
	; in:	HL = X
	; out:	HL = 0, false if X = even
	;	HL = 1, true  if X = odd
	DB 7dh
	DB 0e6h, 1
	DB 6fh
	DB 26h,0
	DB 0c9h

ENDIF	; USELIB

L_CMP:	; compare two signed longints
	; in:	X at stack, Previous
	;	Y in DEHL, Current
	; out:	HL'HL = X
	;	DE'DE = Y
	;	Equal,		if DE = HL,  Zero
	;	Not Equal,	if DE <> HL, NonZero
	;	Greater or Equal, if DE >= HL, NonCarry
	;	Less or Equal,	if DE <= HL, Zero or Carry
	;	Greater than,	if DE > HL,  NonZero and NonCarry
	;	Less than,	if DE < HL,  Carry
	DB 0ddh,0e1h			; save return address
	DB 0c1h			; return address from previous caller

	DB 0ebh 		; remove X from stack
	DB 0e3h
	DB 0d9h
	DB 0d1h
	DB 0e1h
	DB 0d9h

	DB 0c5h			; restore return address from previous call
	DB 0ddh,0e5h			; restore return address

L_CM0:	; in:	X = HL'HL, Previous
	;	Y = DE'DE, Current
	; out:	X = HL'HL, Previous
	;	Y = DE'DE, Current
	DB 0d9h
	DB 7ah
	DB 0ach
	DB 7ch			; high byte of X
	DB 0fah
	DW L_CMP1
	DB 0bah
	DB 0d9h
	DB 0c0h
	DB 0d9h
	DB 7dh
	DB 0bbh
	DB 0d9h
	DB 0c0h

L0A11:                              ; 33e
	DB 7ch
	DB 0bah
	DB 0c0h

	DB 7dh
	DB 0bbh
	DB 0c9h

L_CMP1:	DB 17h
	DB 0d9h
	DB 0c9h

; 33e
L0A1A:                              ; TODO: used ???
         DB 0cdh
	DW  L0A11
         DB 0d8h
         DB 0ebh
         DB 0c9h
; 33e

	GLOBALS L_AND
L_AND:	; X AND Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes: IX
	DB 0ddh,0e1h			; save return address
	DB 0c1h			; X low-word
	DB 7dh
	DB 0a1h
	DB 6fh
	DB 7ch
	DB 0a0h
	DB 67h
	DB 0c1h			; X high-word
	DB 7bh
	DB 0a1h
	DB 5fh
	DB 7ah
	DB 0a0h
	DB 57h
	DB 0ddh,0e9h

	GLOBALS L_OR
L_OR:	; X OR Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes: IX
	DB 0ddh,0e1h			; save return address
	DB 0c1h			; X low-word
	DB 7dh
	DB 0b1h
	DB 6fh
	DB 7ch
	DB 0b0h
	DB 67h
	DB 0c1h			; X high-word
	DB 7bh
	DB 0b1h
	DB 5fh
	DB 7ah
	DB 0b0h
	DB 57h
	DB 0ddh,0e9h

	GLOBALS L_XOR
L_XOR:	; X XOR Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes: IX
	DB 0ddh,0e1h			; save return address
	DB 0c1h			; X low-word
	DB 7dh
	DB 0a9h
	DB 6fh
	DB 7ch
	DB 0a8h
	DB 67h
	DB 0c1h			; X high-word
	DB 7bh
	DB 0a9h
	DB 5fh
	DB 7ah
	DB 0a8h
	DB 57h
	DB 0ddh,0e9h

	GLOBALS L_NOT
L_NOT:	; X = NOT X : LONG
	; in:	X in DEHL
	; out:	DEHL
	; changes: IX
	DB 7dh
	DB 2fh
	DB 6fh
	DB 7ch
	DB 2fh
	DB 67h
	DB 7bh
	DB 2fh
	DB 5fh
	DB 7ah
	DB 2fh
	DB 57h
	DB 0c9h

	GLOBALS L_ABS
L_ABS:	; Abs X : LONGINT
	; in:	DEHL = X
	; out:	DEHL = -X, if X < 0
	;	DEHL =  X, if X >= 0
	DB 0cbh,07ah			; LIB, DEHL = negative ?
	DB 0c8h			; return if positive

	GLOBALS L_NEG
L_NEG:	; X = -X : LONG
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

	GLOBALS L_ADD
L_ADD:	; X + Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes: IX
	DB 0ddh,0e1h			; save return address
	DB 0c1h			; BC = X low-word
	DB 09h		; X + Y, low
	DB 0c1h			; BC = Y high-word
	DB 0ebh
	DB 0EDH,04ah		; X + Y, high
	DB 0ebh
	DB 0ddh,0e9h

	GLOBALS L_SUB
L_SUB:	; X - Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes: IX
	DB 0ddh,0e1h			; save return address
	DB 4dh			; BC = Y low-word
	DB 44h
	DB 0e1h			; HL = X low-word
	DB 0b7h
	DB 0EDH,042h		; X - Y, low
	DB 0ebh
	DB 4dh			; BC = Y high-word
	DB 44h
	DB 0e1h			; HL = X high-word
	DB 0EDH,042h		; X - Y, high
	DB 0ebh
	DB 0ddh,0e9h

L_MDAT:	db 4 dup (0)

         GLOBALS L_SQR
L_SQR:   ; LIB
         ; FUNCTION SQR(L: LONGINT): LONGINT;
         ; in:    DE:HL = value to calcute square
         ; out:   DE:HL = DE:HL * DE:HL
         DB 0ddh,0e1h

         DB 0d5h
         DB 0e5h

         DB 0ddh,0e5h

         GLOBALS L_MUL
L_MUL:	; X * Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes: IX
	DB 0ddh,0e1h

         DB 22h
	DW L_MDAT
	DW 53edh,L_MDAT+2
	DB 21h
	DW 0			; init SUM low-word
	DB 0d1h			; DE = X low-word
	DB 0d9h
	DB 21h
	DW 0			; init SUM high-word
	DB 0d1h			; DE' = X high-word
	DB 0d9h
	DB 3ah
	DW L_MDAT+0
	DB 0cdh
	DW  L_MUL1
	DB 3ah
	DW L_MDAT+1
	DB 0cdh
	DW  L_MUL1
	DB 3ah
	DW L_MDAT+2
	DB 0cdh
	DW  L_MUL1
	DB 3ah
	DW L_MDAT+3
	DB 0b7h
	DB 0c4h
	DW L_MUL11

	; HL = low-word SUM
	DB 0d9h
	DB 0e5h
	DB 0d9h
	DB 0d1h			; DE = high-word SUM
	DB 0ddh,0e9h

L_MUL1:	DB 0b7h
	DB 28h,(L_MUL4)-$-1

L_MUL11: DB 06h,8

L_MUL2:	DB 0fh			; rotate byte from Y
	DB 30h,(L_MUL3)-$-1

	DB 019h		; SUM += X
	DB 0d9h
	DB 0EDH,05ah
	DB 0d9h

L_MUL3:
	DB 0cbh,23h			; X * 2
	DB 0cbh,12h
	DB 0d9h
	DB 0cbh,13h
	DB 0cbh,12h
	DB 0d9h

	DB 10h,( L_MUL2)-$-1
	DB 0c9h

L_MUL4:	; in:	DE'DE
	; out:	DE'DE SHL 8
	DB 7ah
	DB 53h
	DB 1eh,0
	DB 0d9h
	DB 53h
	DB 5fh
	DB 0d9h
	DB 0c9h

L_DIV10: ; divides DE:HL by 10
	; in:	DE:HL = long
	; out:	DE:HL div 10, A = remainder
	; changes: BC

	DB 0eh,0
	DB 06h,32			; 32 bits
	DB 0afh			; carry 0

L_DIV101:
	DB 0cbh,15h
	DB 0cbh,14h
	DB 0cbh,13h
	DB 0cbh,12h
	DB 0cbh,11h
	DB 79h
	DB 0d6h, 10
	DB 3fh
	DB 0d2h
	DW L_DIV102

	DB 4fh

L_DIV102:
	DB 10h,( L_DIV101)-$-1		; repeat for 32 bits

	DB 0cbh,15h			; DE:HL = 32 bit result
	DB 0cbh,14h
	DB 0cbh,13h
	DB 0cbh,12h
	DB 79h			; A = remainder
	DB 0c9h

L_DDAT:	db 4 dup (0)

	GLOBALS L_DIV
L_DIV:	; X / Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes:

	DB 0c1h

	DB 0ebh
	DB 0e3h
	DB 0d9h
	DB 0d1h
	DB 0e1h
	DB 0d9h

	DB 0c5h			; restore return address

	DB 0cdh
	DW  L_DIV_0

	DB 02ah
	DW L_DDAT
	DB 0edh,5bh
	DW L_DDAT+2
	DB 0f0h

	DB 0c3h
	DW  L_NEG

	GLOBALS L_MOD
L_MOD:	; X mod Y : LONG
	; in:	X at stack
	;	Y in DEHL
	; out:	DEHL
	; changes:

	DB 0c1h			; save return address

	DB 0ebh
	DB 0e3h
	DB 0d9h
	DB 0d1h
	DB 0e1h
; 33f    BIT 7,H                    ; test for result sign
	DB 0d9h

	DB 0c5h			; restore return address
; 33f    PUSH AF                    ; save resulting sign

	DB 0cdh
	DW  L_DIV_0
         DB 0f5h                    ; 33f, save resulting sign

	DB 0d9h
	DB 0e5h
	DB 0d9h
	DB 0d1h			; DE:HL = RESULT SHL C

	DB 79h
	DB 0cdh
	DW  L_SHR_1

         DB 0f1h                     ; restore resulting sign
	DB 0f0h

	DB 0c3h
	DW  L_NEG

L_DIV_0: ; X DIV Y : LONG
	; in:	X = HL'HL
	;	Y = DE'DE
	; out:	C = number of bits processed
	;	result in L_DDAT
	;	MOD = HL'HL shr C
	;	A = positive if result is positive
	;	A = negative if result is negative

	; HL'HL = LONGINT A
	; DE'DE = LONGINT B

	DB 0d9h
	DB 7ch
	DB 0aah
	DB 0d9h
	DB 0f5h			; save resulting sign
				; P = positive, M = minus

	DB 0cdh
	DW  L_ABS1		; HL'HL = ABS( HL'HL )

	DB 0d9h			; swap HL'HL with DE'DE
	DB 0ebh
	DB 7ch
	DB 0b5h
	DB 0d9h
	DB 0ebh
	DB 0b4h
	DB 0b5h			; B = 0 ?
	DB 0cah
	DW L0A03		; jump if Division by zero

	DB 0cdh
	DW  L_ABS1		; DE'DE = ABS( DE'DE )

	DB 0d9h			; swap HL'HL with DE'DE
	DB 0ebh
	DB 0d9h
	DB 0ebh

	DB 01h
	DW 0
	DW 43edh,L_DDAT
	DW 43edh,L_DDAT+2

	DB 0eh,1			; bits = 1

L_DIV1:	; save old B and multiply b by 2
	DB 0d5h
	DB 0cbh,23h
	DB 0cbh,12h
	DB 0d9h
	DB 0d5h
	DB 0cbh,13h
	DB 0cbh,12h
	DB 0d9h

	DB 0e5h
	DB 0b7h
	DB 0EDH,052h
	DB 0e1h
	DB 0d9h
	DB 0e5h
	DB 0EDH,052h
	DB 0e1h
	DB 0d9h
	DB 38h,(L_DIV_2)-$-1

	DB 0ch
	DB 0f1h			; remove saved LONGINT B
	DB 0f1h
	DB 0c3h
	DW  L_DIV1		; repeat loop

L_DIV_2: DB 0d9h
	DB 0d1h			; restore high-word LONGINT B
	DB 0d9h
	DB 0d1h			; restore low-word LONGINT B

	DB 06h,8			; assume 8 bits, 0 rest

	DB 79h
	DB 0e6h, 7
	DB 28h,(L_DIV_3)-$-1		; jump if zero, means 8 bits
	DB 47h

L_DIV_3: DB 79h
	DB 3dh
	DB 0e6h, 18H
	DB 0fh
	DB 0fh
	DB 0fh			; A = index to byte to start at
	DB 0d9h
	DB 01h
	DW L_DDAT
	DB 081h
	DB 4fh
	DB 78h
	DB 0ceh,0
	DB 47h
	DB 0d9h

	; HL'HL = unsigned LONGINT A
	; DE'DE = unsigned LONGINT B * (2^(C - 1))
	;   B = initial number of bits after which the first byte will
	;       be stored
	;   C = number of bits to proces
	; BC' = address where to store result
	DB 0afh			; init first result byte

	DB 0c5h			; save number of bits to proces

L_DIV_4: DB 087h			; result * 2

	DB 0e5h			; save low-word LONGINT A
	DB 0b7h
	DB 0EDH,052h
	DB 0d9h
	DB 0e5h			; save high-word LONGINT A
	DB 0EDH,052h
	DB 0d9h
	DB 38h,(L_DIV_5)-$-1		; jump if A < B

	DB 33h			; remove saved LONGINT A
	DB 33h
	DB 33h
	DB 33h

	DB 3ch			; result:=result+1
	DB 18h,( L_DIV_6)-$-1

L_DIV_5:
	DB 0d9h
	DB 0e1h			; restore high-word LONGINT A
	DB 0d9h
	DB 0e1h			; restore low-word LONGINT A

L_DIV_6: DB 029h		; LONGINT A * 2
	DB 0d9h
	DB 0EDH,06ah
	DB 0d9h

	DB 10h,( L_DIV_7)-$-1		; result bits - 1
				; result = full ?
				; jump if not
	DB 0d9h
	DB 02h		; save result
	DB 0bh
	DB 0d9h
	DB 06h,8			; start al over

L_DIV_7: DB 0dh
	DB 20h,(L_DIV_4)-$-1

	DB 0c1h			; C = number of bits processes (for MOD)
	DB 0f1h			; A = resulting sign
				; Sign flag still set !
	DB 0c9h

	GLOBALS L_SHL
L_SHL:	; X shl Y : LONGINT
	; in:	X at stack
	;	HL = count
	; out:	DEHL shl count
	; changes: AF,BC,DE,HL

	DB 0c1h			; save return address
	DB 7dh			; A = count
	DB 0e1h			; DE:HL = X
	DB 0d1h
	DB 0c5h			; restore stack

L_SHL_1: DB 0d6h, 8
	DB 38h,(L_SHL_2)-$-1
	DB 53h
	DB 5ch
	DB 65h
	DB 2eh,0
	DB 18h,( L_SHL_1)-$-1

L_SHL_2: DB 0c6h,8
	DB 0c8h
	DB 47h

L_SHL_3: DB 029h
	DB 0ebh
	DB 0EDH,06ah
	DB 0ebh
	DB 10h,( L_SHL_3)-$-1
	DB 0c9h

	GLOBALS L_SHR
L_SHR:	; X shr Y : LONGINT
	; in:	X at stack
	;	HL = count
	; out:	DEHL shr count
	; changes: AF,BC,DE,HL

	DB 0c1h			; save return address
	DB 7dh			; A = count
	DB 0e1h			; DE:HL = X
	DB 0d1h
	DB 0c5h			; restore stack

L_SHR_1: DB 0d6h, 8
	DB 38h,(L_SHR_2)-$-1
	DB 6ch
	DB 63h
	DB 5ah
	DB 16h,0
	DB 18h,( L_SHR_1)-$-1

L_SHR_2: DB 0c6h,8
	DB 0c8h
	DB 47h

L_SHR_3: DB 0cbh,3ah
	DB 0cbh,1bh
	DB 0cbh,1ch
	DB 0cbh,1dh
	DB 10h,( L_SHR_3)-$-1
	DB 0c9h

L_ABS1:	; in:	HL'HL = LONGINT
	; out:  -HL'HL if HL'HL < 0
	;	HL'HL if HL'HL >= 0
	DB 0d9h
	DB 0cbh,07ch
	DB 0d9h
	DB 0c8h			; quit if positive

	DB 4dh			; BC = low-word
	DB 44h
	DB 0afh			; Carry = 0
	DB 6fh
	DB 67h
	DB 0EDH,042h		; 0 - low-word
	DB 0d9h
	DB 4dh			; BC = high-word
	DB 44h
	DB 6fh
	DB 67h
	DB 0EDH,042h		; 0 - high-word - carry
	DB 0d9h
	DB 0c9h

L0792:	; in:	-
	; out:	Seed := Seed + (Seed shl 7) + 361962E9h
	;	equals
	;	Seed := (Seed * 129) + 907,633,385d
	;	BCDE = Seed
	DB 0edh,4bh
	DW L00C8+2
	DB 0edh,5bh
	DW L00C8
	DB 0c5h
	DB 0d5h
	DB 78h			; shl 8
	DB 41h
	DB 4ah
	DB 53h
	DB 1eh,0

	DB 1fh			; shr 1
	DB 0cbh,18h
	DB 0cbh,19h
	DB 0cbh,1ah
	DB 0cbh,1bh

	DB 0e1h			; Seed := Seed + (Seed shl 7)
	DB 019h
	DB 0ebh
	DB 0e1h
	DB 0EDH,04ah
	DB 44h
	DB 4dh

	DB 21h
	DW 62E9H		; Seed := Seed + 361962E9h
	DB 019h
	DB 22h
	DW L00C8
	DB 0ebh
	DB 21h
	DW 3619H
	DB 0EDH,04ah
	DB 22h
	DW L00C8+2
	DB 44h
	DB 4dh
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

L07F7:	; ASCII hexadecimal or decimal to Integer
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

L0837:	DB 0b7h
	;RET Z			; quit if carry reset if hexadecimal
				; allow hexadecimals that are negative
				; decimals
	;LD A,H
	;ADD A,A
	DB 0c9h			; quit with carry set if HL > 32767?

L2A:     ; unsigned long to ASCII
	; in:	DE:HL = unsigned long
	;	IX = destination address of ASCII result
	; out:	IX = address after ASCII result

	DB 0afh
	DB 0f5h			; set end of digits

L2A_1:
	DB 0cdh
	DW  L_DIV10		; divide by 10

	DB 3ch
	DB 0f5h			; save remainder, 1..10

	DB 7ch
	DB 0b5h
	DB 0b2h
	DB 0b3h
	DB 20h,(L2A_1)-$-1		; repeat while long > 0

L2A_2:
	DB 0f1h			; take digit
	DB 3dh
	DB 0f8h			; quit if end of digits

         DB 0c6h,'0'
	DB 0ddh,77h,+0		; store in result
	DB 0ddh,23h
	DB 18h,( L2A_2)-$-1

A2L_FLAG:DB 0			; hexadecimal flag
				; 0 = convert as hexadecimal
				; NonZero = convert as decimal
A2L:	; ASCII hexadecimal or decimal to LONGINT
	; converts ascii hexadecimal or decimal number at IX to
	; an unsigned value in DE:HL
	; in:	IX = address of ascii digit sequence
	; out:	carry set if value out of range
	;	carry reset, DE:HL = unsigned value
	;	A = 0, if hexadecimal constant parsed
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

A2L04:	DB 3ah
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
	DB 0ch			; started with '$' ?
	DB 0dh
	DB 20h,(A2L37)-$-1		; no, quit --> error

	; hexadecimal
	DB 0d6h, 7			; 'A' --> 10, 'B' --> 11
	DB 0feh, 10			; < 10 ?
	DB 38h,(A2L37)-$-1		; yes, quit --> error
	DB 0feh, 16			; >= 16 ?
	DB 30h,(A2L37)-$-1		; yes, quit --> error

A2L20:	DB 0f5h
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
	DB 78h			; A = digit to add
	DB 0d8h			; quit if carry, overflow

	DB 0cdh
	DW  L_M2		; DE:HL * 2
	DB 0d8h
	DB 18h,( A2L36)-$-1 		; add the current digit

A2L_HEX: DB 0f1h
	DB 0cdh
	DW  L_M2		; DE:HL * 2
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

A2L36:	; add the new digit and repeat
	DB 4fh
	DB 06h,0
	DB 09h
	DB 0ebh
	DB 01h
	DW 0
	DB 0EDH,04ah
	DB 0ebh
	DB 18h,( A2L02)-$-1 		; go for the next digit

A2L37:	DB 79h
	DB 0b7h
	DB 0c9h

A2L38:	DB 0e1h
	DB 0e1h
	DB 0d1h
	DB 0c9h

L_M2:	; in:	DE:HL
	; out:	DE:HL * 2
	;	Carry if overflow
	DB 029h
	DB 0ebh
	DB 0EDH,06ah
	DB 0ebh
	DB 0c9h

IFDEF USELIB

	GLOBALS L083D
L083D:	; STRING + STRING
	DB 0ddh,0e1h			; LIB
	DB 0e1h
	DB 0e5h
	DB 7dh
	DB 26h,0
	DB 23h
	DB 039h
	DB 4eh
	DB 081h
	DB 38h,(L0866)-$-1		; jump if String Length Error
	DB 77h
	DB 0ebh
	DB 21h
	DW 0
	DB 44h
	DB 0EDH,042h
	DB 039h
	DB 0f9h
	DB 0ebh
	DB 0e5h
	DB 03h
	DB 0edh,0b0h
	DB 0ebh
	DB 0e1h
	DB 2bh
	DB 1bh
	DB 4fh
	DB 03h
	DB 0edh,0b8h
	DB 0ebh
	DB 23h
	DB 0f9h
	DB 0ddh,0e9h

L0866:	DB 3eh,10H 		; r.error 10H: String length error
	DB 0c3h
	DW  L2029

	GLOBALS L086B
L086B:	DB 0ddh,0e1h			; LIB
	DB 0cdh
	DW  L04C8		; int HL to byte A
	DB 57h
	DB 0e1h
	DB 0cdh
	DW  L09DD
	DB 5fh
	DB 0e1h
	DB 0e5h
	DB 7dh
	DB 093h
	DB 38h,(L0896)-$-1
	DB 14h
	DB 15h
	DB 28h,(L0896)-$-1
	DB 0bah
	DB 38h,(L0899)-$-1
	DB 4ah
	DB 06h,0
	DB 60h
	DB 039h
	DB 7bh
	DB 082h
	DB 54h
	DB 5dh
	DB 3dh
	DB 6fh
	DB 60h
	DB 039h
	DB 79h
	DB 0edh,0b8h
	DB 0ebh
	DB 18h,( L089F)-$-1

L0896:	DB 0afh
	DB 18h,( L089C)-$-1

L0899:	DB 3ch
	DB 6bh
	DB 2dh

L089C:	DB 26h,0
	DB 039h

L089F:	DB 77h
	DB 0f9h
	DB 0ddh,0e9h

	GLOBALS L08A3
L08A3:	; LIB
	DB 0ddh,0e1h
	DB 0e1h
	DB 0e5h
	DB 7dh
	DB 26h,0
	DB 23h
	DB 039h
	DB 0f9h
	DB 6fh
	DB 26h,0
	DB 0ddh,0e9h

	GLOBALS L08B2
L08B2:	; LIB
	DB 0ddh,0e1h
	DB 21h
	DW 0
	DB 54h
	DB 039h
	DB 5eh
	DB 4bh
	DB 23h
	DB 0e5h
	DB 019h
	DB 5eh
	DB 43h
	DB 23h
	DB 0e5h
	DB 019h
	DB 0e5h
	DB 0fdh,0e1h
	DB 0d1h
	DB 0e1h
	DB 79h
	DB 090h
	DB 38h,(L08DC)-$-1
	DB 3ch
	DB 4fh

L08CE:	DB 0c5h
	DB 0d5h
	DB 0e5h

L08D1:	DB 1ah
	DB 0beh
	DB 28h,(L08E1)-$-1
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 23h
	DB 0dh
	DB 20h,(L08CE)-$-1

L08DC:	DB 21h
	DW 0
	DB 18h,( L08EF)-$-1

L08E1:	DB 23h
	DB 13h
	DB 10h,( L08D1)-$-1
	DB 0d1h
	DB 0e1h
	DB 0c1h
	DB 21h
	DW 0
	DB 039h
	DB 0ebh
	DB 0EDH,052h
L08EF:	DB 0fdh,0f9h
	DB 0ddh,0e9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L08F3
L08F3:	; PROCEDURE Delete(VAR S: STRING; Pos, Len: INTEGER);
	; in:	S pushed first
	;	Pos pushed second
	;	HL = len
	DB 0ddh,0e1h
	DB 0cdh
	DW  L04C8		; int HL to byte A
	DB 4fh			; C = Len
	DB 0e1h
	DB 0cdh
	DW  L09DD
	DB 5fh
	DB 0e1h
	DB 7eh
	DB 093h
	DB 38h,(L091E)-$-1
	DB 0ch
	DB 0dh
	DB 28h,(L091E)-$-1
	DB 091h
	DB 38h,(L091C)-$-1
	DB 0f5h
	DB 7eh
	DB 091h
	DB 77h
	DB 06h,0
	DB 50h
	DB 019h
	DB 54h
	DB 5dh
	DB 09h
	DB 0f1h
	DB 3ch
	DB 4fh
	DB 0edh,0b0h
	DB 18h,( L091E)-$-1

L091C:	DB 1dh
	DB 73h
L091E:	DB 0ddh,0e9h

ENDIF	; USELIB

	GLOBALS L0920
L0920:	; LIB
	DB 0ddh,0e1h
	DB 0cdh
	DW  L09DD
	DB 4fh
	DB 0d1h
	DW 53edh,L00E8
	DB 21h
	DW 0
	DB 039h
	DB 1ah
	DB 0f5h
	DB 086h
	DB 38h,(L0937)-$-1
	DB 0b8h
	DB 38h,(L0938)-$-1
L0937:	DB 78h
L0938:	DB 12h
	DB 0f1h
	DB 57h
	DB 5eh
	DB 091h
	DB 38h,(L096E)-$-1
	DB 3ch
	DB 6fh
	DB 7ah
	DB 083h
	DB 38h,(L0949)-$-1
	DB 0b8h
	DB 7dh
	DB 38h,(L0951)-$-1
L0949:	DB 78h
	DB 093h
	DB 38h,(L0973)-$-1
	DB 091h
	DB 38h,(L0973)-$-1
	DB 3ch
L0951:	DB 0b7h
	DB 28h,(L0973)-$-1
	DB 0c5h
	DB 0d5h
	DB 02ah
	DW L00E8
	DB 5fh
	DB 1dh
	DB 16h,0
	DB 42h
	DB 019h
	DB 09h
	DB 0d1h
	DB 0d5h
	DB 0e5h
	DB 50h
	DB 019h
	DB 0ebh
	DB 0e1h
	DB 4fh
	DB 0edh,0b8h
	DB 0d1h
	DB 0c1h
	DB 18h,( L0973)-$-1
L096E:	DB 7ah
	DB 3ch
	DB 28h,(L098B)-$-1
	DB 4fh
L0973:	DB 78h
	DB 091h
	DB 3ch
	DB 0bbh
	DB 38h,(L097A)-$-1
	DB 7bh
L097A:	DB 0b7h
	DB 28h,(L098B)-$-1
	DB 02ah
	DW L00E8
	DB 06h,0
	DB 09h
	DB 0ebh
	DB 21h
	DW 1
	DB 039h
	DB 4fh
	DB 0edh,0b0h
L098B:	DB 21h
	DW 0
	DB 54h
	DB 039h
	DB 5eh
	DB 13h
	DB 019h
	DB 0f9h
	DB 0ddh,0e9h


IFDEF USELIB

	GLOBALS L0996
L0996:	DB 0ddh,0e1h			; LIB, convert string to character
	DB 0e1h
	DB 2dh			; original length > 1
	DB 0c2h
	DW L0866		; jump if String Length Error
	DB 6ch
	DB 26h,0
	DB 0ddh,0e9h

	GLOBALS L09A2
L09A2:	; LIB
	; this routine converts the second parameter that is on the stack
	; to a string, the first parameter is a string
	; in:	<return address>
	;	<string>
	;	<character value>
	; out:	<return address>
	;	<string>
	;	<string>
	DB 21h
	DW 2
	DB 54h			; D = 0
	DB 039h
	DB 5eh		; DE = string length
	DB 13h
	DB 019h
	DB 7eh
	DB 36h,1
	DB 23h
	DB 77h
	DB 0c9h

ENDIF	; USELIB


L09B0:	; Compare STRINGS
	DB 21h
	DW 4
	DB 54h
	DB 039h
	DB 5eh
	DB 4bh
	DB 23h
	DB 0e5h
	DB 019h
	DB 5eh
	DB 43h
	DB 23h
	DB 0e5h
	DB 019h
	DB 0e5h
	DB 0fdh,0e1h
	DB 0d1h
	DB 0e1h
L09C4:	DB 0afh
	DB 0b8h
	DB 28h,(L09CC)-$-1
	DB 0b9h
	DB 20h,(L09D3)-$-1
	DB 78h
L09CC:	DB 0b9h
L09CD:	DB 0e1h
	DB 0d1h
	DB 0fdh,0f9h
	DB 0d5h
	DB 0e9h
L09D3:	DB 1ah
	DB 0beh
	DB 20h,(L09CD)-$-1
	DB 23h
	DB 13h
	DB 05h
	DB 0dh
	DB 18h,( L09C4)-$-1
L09DD:	DB 7ch
	DB 0b7h
	DB 20h,(L09E4)-$-1
	DB 7dh
	DB 0b7h
	DB 0c0h
L09E4:	DB 3eh,11H 		; r.error 11H: Invalid string index
	DB 0c3h
	DW  L2029

	GLOBALS L09E9
L09E9:	DB 0cdh
	DW  L0A0D		; LIB

L09EC:	DB 0d0h
	DB 3eh,1			; r.error 1: Floating point overflow
	DB 0c3h
	DW  L2027 		; Run-time error


IFDEF USELIB

	GLOBALS L09F2
L09F2:	DB 0cdh
	DW  L0A81		; LIB
	DB 18h,( L09EC)-$-1

	GLOBALS L09F7
L09F7:	; FUNCTION Sqr(R: REAL): REAL;
	DB 0cdh
	DW  L0FAC		; LIB

	GLOBALS L09FA
L09FA:	DB 0cdh
	DW  L0A97		; LIB
	DB 18h,( L09EC)-$-1

	GLOBALS L09FF
L09FF:	; Divide two REALS
	DB 0d9h			; LIB
	DB 7dh
	DB 0b7h
	DB 0d9h

ENDIF	; USELIB

L0A03:	DB 3eh,2			; r.error 2: Division by zero attempted
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

L0A5B:   DB 0cdh
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
;	 LD C,(IX+0)
IFDEF MSX
	DB 0ddh,4eh,+0
ELSE
;!	mov cl,ss:[si + 0]	; read from stack !!! ----
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

L0AF5:   DB 7dh
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

;	 LD (IX+5),C
IFDEF MSX
	DB 0ddh,71h,+5
ELSE
;!	mov byte ptr ss:[si+5],cl
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
L0B86:	DB 0b7h
L0B87:	DB 0cbh,14h
	DB 0cbh,13h
	DB 0cbh,12h
	DB 0cbh,11h
	DB 0cbh,10h
	DB 0c9h
L0B92:	DB 7ch
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


IFDEF USELIB

	GLOBALS L0BFD
L0BFD:	; FUNCTION Int(R: REAL): REAL;
	DB 7dh			; LIB
	DB 0d6h, 81H
	DB 0dah
	DW L0B72		; Carry --> HLDEBC = 0.0

	DB 3ch
	DB 0feh, 28H
	DB 0d0h
	DB 0d9h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 08h
	DB 0cdh
	DW  L0B72		; HLDEBC = 0.0
	DB 08h
L0C10:	DB 37h
	DB 0cdh
	DW  L0B7B
	DB 3dh
	DB 20h,(L0C10)-$-1
	DB 0d9h
	DB 7ch
	DB 0d9h
	DB 0a4h
	DB 0d9h
	DB 67h
	DB 7bh
	DB 0d9h
	DB 0a3h
	DB 0d9h
	DB 5fh
	DB 7ah
	DB 0d9h
	DB 0a2h
	DB 0d9h
	DB 57h
	DB 79h
	DB 0d9h
	DB 0a1h
	DB 0d9h
	DB 4fh
	DB 78h
	DB 0d9h
	DB 0a0h
	DB 0d9h
	DB 47h
L0C31:	DB 0c3h
	DW  L0A7B

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L0C34
L0C34:	; FUNCTION Frac(R: REAL): REAL;
	DB 0d9h			; LIB
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0d9h
	DB 0cdh
	DW  L0FAC
	DB 0d9h
	DB 0cdh
	DW  L0BFD		; FUNCTION Int(R: REAL): REAL;
	DB 0d9h
	DB 0cdh
	DW  L0A81
	DB 18h,( L0C31)-$-1

	GLOBALS L0C46
L0C46:	; FUNCTION Sqrt(R: REAL): REAL;
	DB 7dh			; LIB
	DB 0b7h
	DB 0c8h
	DB 0cbh,078h
	DB 3eh,3			; r.error 3: Sqrt argument error
	DB 0c2h
	DW L2027		; Run-time error
	DB 0cdh
	DW  L0FAC
	DB 7dh
	DB 0c6h,80H
	DB 0cbh,2fh
	DB 0c6h,80H
	DB 6fh
	DB 0d6h, 14H
	DB 0f5h
	DB 0d9h
L0C5F:	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0cdh
	DW  L0AF5
	DB 0cdh
	DW  L0A0D
	DB 2dh
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0cdh
	DW  L0A81
	DB 7dh
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0e3h
	DB 0bch
	DB 0e3h
	DB 30h,(L0C5F)-$-1
	DB 0f1h
	DB 0d9h
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L0C7F
L0C7F:	; FUNCTION Cos(R: REAL): REAL;
	DB 0d9h			; LIB
	DB 0cdh
	DW  L0F8E		; get REAL PI
	DB 2dh
	DB 0cdh
	DW  L0A81

	GLOBALS L0C87
L0C87:	; FUNCTION Sin(R: REAL): REAL;
	DB 0d9h			; LIB
	DB 0cdh
	DW  L0F8E		; get REAL PI
	DB 2ch
	DB 0d9h
	DB 7dh
	DB 0feh, 6CH
	DB 0d8h
	DB 0c5h
	DB 0cbh,0b8h
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 0c1h
	DB 38h,(L0CA3)-$-1

	DB 0cdh
	DW  L0AF5
	DB 0cdh
	DW  L0C34		; FUNCTION Frac(R: REAL): REAL;
	DB 0cdh
	DW  L0A97

L0CA3:	DB 0cbh,078h
	DB 28h,(L0CAA)-$-1
	DB 0cdh
	DW  L0A0D

L0CAA:	DB 0d9h
	DB 2dh
	DB 0d9h
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 0f5h
	DB 38h,(L0CB6)-$-1
	DB 0cdh
	DW  L0A81

L0CB6:	DB 0d9h
	DB 2dh
	DB 0d9h
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 38h,(L0CC3)-$-1
	DB 0d9h
	DB 2ch
	DB 0cdh
	DW  L0A81

L0CC3:	DB 7dh
	DB 0feh, 6CH
	DB 38h,(L0D03)-$-1
	DB 0d9h

	DB 01h
	DW 2AAAH		; 3.3333333333E-01
	DB 11h
	DW 0AAAAH
	DB 21h
	DW 0AA7FH

	DB 0cdh
	DW  L0A97
	DB 0ddh,0e5h
	DB 0ddh,21h
	DW L0D0D-6
	DB 3eh,5
	DB 0cdh
	DW  L0F34
	DB 0ddh,0e1h
	DB 0cdh
	DW  L0FAC
	DB 0cdh
	DW  L0A97
	DB 0cdh
	DW  L0A97
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0d9h
	DB 0cdh
	DW  L0FAC
	DB 2dh
	DB 2dh
	DB 0d9h
	DB 2dh
	DB 0cdh
	DW  L0A0D
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0d9h
	DB 0cdh
	DW  L0A81
	DB 2ch
	DB 2ch
L0D03:	DB 0f1h
	DB 2ch
	DB 2dh
	DB 0c8h
	DB 0d8h
	DB 78h
	DB 0eeh, 80H
	DB 47h
	DB 0c9h

L0D0D:
	; arctan
	DB 67H,0AAH, 3FH, 2BH, 32H,0D7H		; -1 / 11!
	DB 6EH,0B6H,02AH, 1DH,0EFH, 38H		;  1 / 9!
	DB 74H, 0DH,0D0H,  0,  0DH,0D0H		; -1 / 7!
	DB 7AH, 88H, 88H, 88H, 88H,  8		;  1 / 5!
	DB 7EH,0ABH,0AAH,0AAH,0AAH,0AAH		; -1 / 3!

	GLOBALS L0D2B
L0D2B:	; FUNCTION Ln(R: REAL): REAL;
	; calculates ln(REAL HLDEBC) ; LIB
	DB 2ch
	DB 2dh
	DB 3eh,4			; r.error 4: Ln argument error
	DB 0cah
	DW L2027		; error if zero
	DB 0cbh,078h
	DB 0c2h
	DW L2027		; error if negative
	DB 0d9h
	DB 0cdh
	DW  L0F98		; get REAL sqrt(2)
	DB 0d9h
	DB 7dh
	DB 2eh,81H
	DB 095h
	DB 0f5h
	DB 0cdh
	DW  L0AF5
	DB 0d9h
	DB 0cdh
	DW  L0F86		; get REAL 1.0
	DB 0d9h
	DB 0cdh
	DW  L0A81
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0d9h
	DB 2ch
	DB 0cdh
	DW  L0A0D
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0cdh
	DW  L0AF5
	DB 0ddh,0e5h
	DB 0ddh,21h
	DW L0DF2-6
	DB 3eh,6
	DB 0cdh
	DW  L0F34
	DB 0ddh,0e1h
	DB 2ch
	DB 0d9h
	DB 0cdh
	DW  L0FA2		; get REAL ln(2)
	DB 2dh
	DB 0d9h
	DB 0cdh
	DW  L0A0D
	DB 0f1h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 6fh
	DB 26h,0
	DB 30h,(L0D7C)-$-1
	DB 25h

L0D7C:	DB 0cdh
	DW  L1008		; convert integer HL to REAL HLDEBC
	DB 0d9h
	DB 2ch
	DB 0cdh
	DW  L0A97
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0cdh
	DW  L0A0D
	DB 7dh
	DB 0feh, 67H
	DB 0dah
	DW L0B72		; Carry --> HLDEBC = 0.0
	DB 0c9h

L0DF2:
	DB 7DH, 8AH, 9DH,0D8H, 89H,1DH	; 1 / 13.0
	DB 7DH,0E9H,0A2H, 8BH, 2EH,3AH	; 1 / 11.0
	DB 7DH, 8EH,0E3H, 38H, 8EH,63H	; 1 /  9.0
	DB 7EH, 49H, 92H, 24H, 49H,12H	; 1 /  7.0
	DB 7EH,0CDH,0CCH,0CCH,0CCH,4CH	; 1 /  5.0
	DB 7FH,0ABH,0AAH,0AAH,0AAH,2AH	; 1 /  3.0

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L0DB6
L0DB6:	; FUNCTION Exp(R: REAL): REAL;
	DB 0d9h			; LIB
	DB 0cdh
	DW  L0FA2		; get REAL ln(2)
	DB 0d9h
	DB 0b7h
	DB 0cbh,078h
	DB 0f5h
	DB 0cbh,0b8h
	DB 0cdh
	DW  L0AF5
	DB 7dh
	DB 0feh, 88H
	DB 30h,(L0E10)-$-1
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 2ch
	DB 0cdh
	DW  L0FD0
	DB 0e5h
	DB 0cbh,3ch
	DB 0cbh,1dh
	DB 7dh
	DB 0e1h
	DB 0f5h
	DB 0cdh
	DW  L1008		; convert integer HL to REAL HLDEBC
	DB 2ch
	DB 2dh
	DB 28h,(L0DE0)-$-1
	DB 2dh

L0DE0:	DB 0d9h
	DB 0f1h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0f5h
	DB 0cdh
	DW  L0A81
	DB 0ddh,0e5h
	DB 0ddh,21h
	DW L0E16-6
	DB 3eh,8
	DB 0cdh
	DW  L0F49
	DB 0ddh,0e1h
	DB 0f1h
	DB 30h,(L0E03)-$-1
	DB 0f5h
	DB 0d9h
	DB 0cdh
	DW  L0F98		; get REAL sqrt(2)
	DB 0d9h
	DB 0cdh
	DW  L0A97
	DB 0f1h

L0E03:	DB 085h
	DB 6fh
	DB 38h,(L0E10)-$-1

	DB 0f1h
	DB 0c8h
	DB 0d9h
	DB 0cdh
	DW  L0F86		; get REAL 1.0
	DB 0c3h
	DW  L0AF5

L0E10:	DB 0e1h
	DB 3eh,1			; r.error 1: Floating point overflow
	DB 0c3h
	DW  L2027 		; Run-time error

L0E16:	DB 6DH,2EH,1DH,11H,60H,31H 	; 1.3215486790E-06
	DB 70H,46H,2CH,0FEH,0E5H,7FH	; 1.5252733804E-05
	DB 74H,36H,7CH,89H,84H,21H 	; 1.5403530393E-04
	DB 77H,53H,3CH,0FFH,0C3H,2EH	; 1.3333558146E-03
	DB 7AH,0D2H,7DH,5BH,95H,1DH	; 9.6181291076E-03
	DB 7CH,25H,0B8H,46H,58H,63H	; 5.5504108665E-02
	DB 7EH,16H,0FCH,0EFH,0FDH,75H	; 2.4022650696E-01
	DB 80H,0D2H,0F7H,17H,72H,31H	; 6.9314718056E-01

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L0E46
L0E46:	; FUNCTION ArcTan(R: REAL): REAL;
	DB 7dh			; LIB
	DB 0b7h
	DB 0c8h
	DB 0ddh,0e5h
	DB 0d9h
	DB 0cdh
	DW  L0F86		; get REAL 1.0
	DB 0d9h
	DB 0afh
	DB 0cbh,078h
	DB 28h,(L0E58)-$-1
	DB 3ch
	DB 0cbh,0b8h

L0E58:	DB 0f5h
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 38h,(L0E66)-$-1
	DB 0d9h
	DB 0cdh
	DW  L0AF5
	DB 0f1h
	DB 0cbh,0ffh
	DB 0f5h

L0E66:	DB 0d9h
	DB 01h
	DW   6CFH		; 1.3165249759E-01
	DB 11h
	DW 0E98EH
	DB 21h
	DW  4A7EH
	DB 0d9h
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 30h,(L0E7B)-$-1

	DB 0cdh
	DW  L0F2E
	DB 18h,( L0ECA)-$-1

L0E7B:	DB 0ddh,21h
	DW L0EE0-18
	DB 3eh,2
L0E81:	DB 08h
	DB 0d9h
	DB 11h
	DW 18
	DB 0ddh,019h
	DB 0cdh
	DW  L0F73		; get REAL at address IX
	DB 0d9h
	DB 0cdh
	DW  L0BDF		; Compare REALS
	DB 38h,(L0E9C)-$-1
	DB 08h
	DB 3dh
	DB 20h,(L0E81)-$-1
	DB 0d9h
	DB 11h
	DW 12
	DB 0ddh,019h
	DB 0d9h

L0E9C:	DB 0d9h
	DB 0cdh
	DW  L0F6E		; get REAL at address IX+6
	DB 0cbh,0f8h
	DB 0cdh
	DW  L0A0D
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0cdh
	DW  L0F73		; get REAL at address IX
	DB 0cdh
	DW  L0A97
	DB 0d9h
	DB 0cdh
	DW  L0F86		; get REAL 1.0
	DB 0cdh
	DW  L0A0D
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0cdh
	DW  L0AF5
	DB 0ddh,0e5h
	DB 0cdh
	DW  L0F2E
	DB 0ddh,0e1h
	DB 0d9h
	DB 0cdh
	DW  L0F6E		; get REAL at address IX+6
	DB 0cdh
	DW  L0A0D

L0ECA:	DB 0f1h
	DB 17h
	DB 30h,(L0ED8)-$-1

L0ECE:	DB 0f5h
	DB 0d9h
	DB 0cdh
	DW  L0F8E		; get REAL PI
	DB 2dh
	DB 0cdh
	DW  L0A81
	DB 0f1h

L0ED8:	DB 0ddh,0e1h
	DB 0cbh,04fh
	DB 0c8h
	DB 0cbh,0f8h
	DB 0c9h

ENDIF	; USELIB


L0EE0:	DB 7FH,0E7H,0CFH,0CCH, 13H, 54H	; 2.4142135624E+00
	DB 7FH,0F6H,0F4H,0A2H, 30H,  9	; TAN(PI/12)
	DB 7FH, 6AH,0C1H, 91H, 0AH,  6	; 3.8197186342E+00
	DB 80H,0B5H, 9EH, 8AH, 6FH, 44H	; 1.3032253728E+00
	DB 80H, 82H, 2CH, 3AH,0CDH, 13H	; TAN(PI/6)
	DB 80H, 6AH,0C1H, 91H, 0AH,  6	; PI/6
	DB 81H,	0,   0,	 0,   0,   0	; 1.0

L0F0A:	DB 80H, 21H,0A2H,0DAH, 0FH, 49H	; PI/4

L0F10:	DB 7DH,0E8H,0A2H, 8BH, 2EH,0BAH	; -1 / 11.0
	DB 7DH, 8EH,0E3H, 38H, 8EH, 63H	;  1 /  9.0
	DB 7EH, 49H, 92H, 24H, 49H, 92H	; -1 /  7.0
	DB 7EH,0CDH,0CCH,0CCH,0CCH, 4CH	;  1 /  5.0
	DB 7FH,0ABH,0AAH,0AAH,0AAH,0AAH	; -1 /  3.0

L0F2E:	DB 0ddh,21h
	DW L0F10-6

	DB 3eh,5			; 5 iteration for a accurate result
L0F34:	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0f5h
	DB 0cdh
	DW  L0FAC
	DB 0cdh
	DW  L0A97
	DB 0f1h
	DB 0cdh
	DW  L0F49
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0c3h
	DW  L0A97

L0F49:	DB 0f5h
	DB 0d9h
	DB 0cdh
	DW  L0F6E		; get REAL at address IX+6
	DB 18h,( L0F60)-$-1

L0F50:	DB 0f5h
	DB 0d9h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0cdh
	DW  L0F6E		; get REAL at address IX+6
	DB 0cdh
	DW  L0A0D
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0d9h
L0F60:	DB 0cdh
	DW  L0A97
	DB 0f1h
	DB 3dh
	DB 20h,(L0F50)-$-1
	DB 0d9h
	DB 0cdh
	DW  L0F86		; get REAL 1.0
	DB 0c3h
	DW  L0A0D

L0F6E:	; get REAL at address IX+6
	DB 11h
	DW 6
	DB 0ddh,019h

L0F73:	; in:	IX = address of REAL
	; out:	HLDEBC = REAL located at address IX
	;	IX unchanged
	DB 0ddh,6eh,+0
	DB 0ddh,66h,+1
	DB 0ddh,5eh,+2
	DB 0ddh,56h,+3
	DB 0ddh,4eh,+4
	DB 0ddh,46h,+5
	DB 0c9h

L0F86:	DB 21h
	DW 81H		; 1.0
	DB 44h
	DB 4ch
	DB 54h
	DB 5ch
	DB 0c9h

L0F8E:	DB 01h
	DW  490FH		; PI
	DB 11h
	DW 0DAA2H
	DB 21h
	DW  2182H
	DB 0c9h

L0F98:	DB 01h
	DW  3504H		; sqrt(2)
	DB 11h
	DW 0F333H
	DB 21h
	DW 0FA81H
	DB 0c9h

L0FA2:	DB 01h
	DW  3172H		; ln(2)
	DB 11h
	DW  17F7H
	DB 21h
	DW 0D280H
	DB 0c9h

L0FAC:	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0d9h
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0c9h


IFDEF USELIB

	GLOBALS L0FB4
L0FB4:	; FUNCTION Random: REAL;
	DB 0cdh
	DW  L0792		; LIB
	DB 21h
	DW 80H
	DB 3eh,20H
L0FBC:	DB 0cbh,078h
	DB 20h,(L0FCD)-$-1
	DB 0cbh,23h
	DB 0cbh,12h
	DB 0cbh,11h
	DB 0cbh,10h
	DB 2dh
	DB 3dh
	DB 20h,(L0FBC)-$-1
	DB 6fh

L0FCD:	DB 0cbh,0b8h
	DB 0c9h

	GLOBALS L0FD0
L0FD0:	DB 0cbh,078h			; LIB
	DB 0d9h
	DB 0cdh
	DW  L0F86		; get REAL 1.0
	DB 28h,(L0FDA)-$-1
	DB 0cbh,0f8h
L0FDA:	DB 2dh
	DB 0cdh
	DW  L0A0D

	GLOBALS L0FDE
L0FDE:	DB 0b7h			; LIB, convert REAL HLDEBC to int HL
	DB 0cbh,07dh
	DB 28h,(L0FFF)-$-1		; return HL = 0 if REAL = 0.0

	DB 0cbh,078h
	DB 08h
	DB 0cbh,0f8h
L0FE8:	DB 3eh,8FH
	DB 0bdh
	DB 38h,(L1003)-$-1
	DB 28h,(L0FF5)-$-1
	DB 0cdh
	DW  L0B7A
	DB 2ch
	DB 18h,( L0FE8)-$-1

L0FF5:	DB 0cdh
	DW  L0B7A
	DB 08h
	DB 60h
	DB 69h
	DB 0c8h
	DB 0c3h
	DW  L0783 		; negate HL

L0FFF:	DB 21h
	DW 0
	DB 0c9h

L1003:	DB 3eh,92H 		; r.error 92H: Out of INTEGER range
	DB 0c3h
	DW  L2027 		; Run-time error

ENDIF	; USELIB

L10031:	DB 3eh,93H 		; r.error 93H: Out of LONGINT range
	DB 0c3h
	DW  L2027

	GLOBALS L1008
L1008:	DB 7ch			; LIB, convert integer HL to REAL HLDEBC
	DB 0b5h
	DB 0cah
	DW L0B72		; return 0.0 REAL if HL = 0

	DB 0cbh,07ch
	DB 08h                  ; save NZ for negative

	DB 0cdh
	DW  L0780		; absolute HL

	DB 3eh,90H

	; shift, normalization
L1015:	DB 029h
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

	GLOBALS L_R
L_R:	; convert LONGINT DEHL to REAL HLDEBC
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

	; perform normalization
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

	GLOBALS R_L
R_L:	; convert LONGINT DEHL to REAL HLDEBC
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

L1027:	; in:	BCDEHL' = REAL to convert to ASCII
	;	HL = number of digits after decimal point
	DB 0cdh
	DW  L04C8		; int to byte
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
	DW  L1236                 ; check digit at (IX+0)
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
	DW  L0F73                 ; get REAL at address IX

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


IFDEF USELIB

	GLOBALS L12DD
L12DD:	; SET <> SET ?
	; HL = 1, if true
	; HL = 0, if false
	DB 0eh,1			; LIB
	DB 18h,( L12E3)-$-1

	GLOBALS L12E1
L12E1:	; SET = SET ?
	; HL = 1, if true
	; HL = 0, if false
	DB 0eh,0			; LIB

L12E3:	DB 0cdh
	DW  L133F
L12E6:	DB 1ah
	DB 0beh
	DB 20h,(L12F2)-$-1

	DB 23h
	DB 13h
	DB 10h,( L12E6)-$-1

	DB 79h
	DB 0eeh, 1
	DB 4fh

L12F2:	; removes the two sets from the stack
	; in:	IX = return address
	;	C = boolean value to return
	; out:	HL = C
	DB 21h
	DW 40H
	DB 039h
	DB 0f9h 		; remove the two sets from the stack
	DB 69h			; 0 = false, 1 = true
	DB 26h,0
	DB 0ddh,0e9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L12FC
L12FC:	; SET <= SET ?
	; HL = 1, if true
	; HL = 0, if false
	DB 0eh,1			; LIB
	DB 18h,( L1302)-$-1

	GLOBALS L1300
L1300:	; SET >= SET ?
	; HL = 1, if true
	; HL = 0, if false
	DB 0eh,0			; LIB

ENDIF	; USELIB


IFDEF USELIB
L1302:	DB 0cdh
	DW  L133F
	DB 0dh
	DB 20h,(L1309)-$-1
	DB 0ebh

L1309:	DB 0eh,0

L130B:	DB 1ah
	DB 0b6h
	DB 0beh
	DB 20h,(L12F2)-$-1
	DB 23h
	DB 13h
	DB 10h,( L130B)-$-1
	DB 0eh,1
	DB 18h,( L12F2)-$-1
ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L1318
L1318:	; LIB
	DB 0cdh
	DW  L133F		; LIB

L131B:	DB 1ah
	DB 0b6h
	DB 77h
	DB 23h
	DB 13h
	DB 10h,( L131B)-$-1

ENDIF	; USELIB


L1322:	DB 0ebh
	DB 0f9h
	DB 0ddh,0e9h


IFDEF USELIB

	GLOBALS L1326
L1326:	; LIB
	DB 0cdh
	DW  L133F		; LIB

L1329:	DB 1ah
	DB 2fh
	DB 0a6h
	DB 77h
	DB 23h
	DB 13h
	DB 10h,( L1329)-$-1
	DB 18h,( L1322)-$-1

	GLOBALS L1333
L1333:	; X * Y : SET
	DB 0cdh
	DW  L133F		; LIB

L1336:	DB 1ah
	DB 0a6h
	DB 77h
	DB 23h
	DB 13h
	DB 10h,( L1336)-$-1
	DB 18h,( L1322)-$-1

ENDIF	; USELIB


L133F:	; in:	2 sets pushed at the stack
	; out:	DE = address of second pushed set
	;	HL = address of first pushed set
	;	IX = return address from routine that called this routine
	DB 0fdh,0e1h			; pop return address
	DB 0ddh,0e1h			; IX = return address of main call !!!
	DB 21h
	DW 0
	DB 039h
	DB 0ebh 		; DE = address of second pushed set

	DB 21h
	DW 20H		; HL = length of set
	DB 45h
	DB 039h		; HL = address of first pushed set

	DB 0fdh,0e9h			; jump to return address


IFDEF USELIB

	GLOBALS L134F
L134F:	DB 0ddh,0e1h			; LIB
	DB 21h
	DW 21H
	DB 039h
	DB 7eh
	DB 0b7h
	DB 28h,(L135C)-$-1
	DB 0afh
	DB 18h,( L1362)-$-1

L135C:	DB 2bh
	DB 46h
	DB 0cdh
	DW  L05BA
	DB 0a6h
L1362:
;!	pushf
	DB 21h
	DW 22H
	DB 039h
	DB 0f9h
	DB 21h
	DW 0
;!	popf
	DB 28h,(L136D)-$-1
	DB 23h
L136D:	DB 0ddh,0e9h

	GLOBALS L136F
L136F:	; assign (text file, filename);
         DB 3Eh
;         LD A,0AFH                  ; LIB, text file
;         JR L1371

	GLOBALS L1370
L1370:	; assign (untyped/typed file, filename);
         DB 0afh                      ; LIB, untyped or typed file
;L1371:
         DB 32h
	DW L00E8
	DB 0fdh,0e1h			; save return address

         DB 02ah
	DW L00D2              ; HL = destination address of string
;         LD B,10H                   ; maximum length of 16
         DB 06h,63                    ; maximum length of 63
	DB 0cdh
	DW  L05E2		; LIB, pop string from stack
	DB 0afh
	DB 12h		; fill byte after string with 0

	DB 0e1h
         DB 22h
	DW L00E2              ; save address of FIB

	DB 0fdh,0e5h			; restore return address

         DB 7ch                     ; std file if address < 400h
         DB 0feh, 4                       ; HL < 400h ?
         DB 30h,(L1390)-$-1                ; jump if >= 400h

	DB 3eh,22H
	DB 32h
	DW L00D0		; IORESULT = 22H = Assign to std files
				; not allowed

SETUSERERROR62:
         DB 3eh,62
         DB 32h
	DW ERRORNUMBER         ; set user error 62
         DB 0c9h

L1390:
         ; HL = address of FIB
         DB 3ah
	DW L00E8
         DB 0b7h                       ; text or untyped/typed ?
         DB 28h,(L13A0)-$-1                 ; jump if untyped/typed file

         ; text file
         DB 0cdh
	DW  L13B6                 ; search for device name at L00D2
	DB 20h,(L13A0)-$-1		; jump if not found, normal file name

         ; A = read/write flags for this device

	DB 02ah
	DW L00E2
	DB 77h		; save read/write flag of device name in FIB
	DB 0c9h

L13A0:
         DB 02ah
	DW L00E2              ; HL = FIB address
         OFF_HL 0 DOS_FCB           ; offset to handle/FCB
         DB 0ebh
         DB 02ah
	DW L00D2
         DB 23h                     ; skip length of string
         DB 3eh,' '
         DB 47h
         DB 4fh
         DB 0cdh
	DW  PARSENAME

;         CALL L03F2                 ; parse filename at address in L00D2 without
;                                    ; wildcards to FCB at L005C

	DB 02ah
	DW L00E2		; HL = FIB, byte 0
	DB 36h,0		; reset flags byte

;         OFF_HL 0 FIB_FCB
;	 LD DE,FIB_FCB		 ; offset to FCB
;	 ADD HL,DE		 ; HL = first byte of FCB

;         EX DE,HL
;         LD HL,L005C
;         LD BC,FCB_LEN              ; length of FCB
;         LDIR                       ; fill FIB with FCB data of address L005CH

         DB 0c9h

L13B6:	; searches for a device name 'KBD:' or 'CON:' etc..
	; in:	L00D2 contains address to string that may start with
	;	a device name
	; out:	Z-flag set if a device name was found
	;	and A = read/write flags for this device
	; changes: BC,DE,HL
	DB 06h,6			; B = 6 entries in table
	DB 21h
	DW L13E6		; HL = table address
L13BB:	DB 0c5h
	DB 0e5h

	DB 06h,3			; compare 3 characters
	DB 0edh,5bh
	DW L00D2
L13C3:	DB 13h
	DB 1ah
	DB 0feh, ' '
	DB 28h,(L13C3)-$-1		; skip spaces

L13C9:	DB 1ah
	DB 0cdh
	DW  L04A6		; upcase
	DB 096h
	DB 28h,(L13DA)-$-1		; compare next letter if equal

	DB 0e1h
	DB 0c1h
	DB 11h
	DW 4
	DB 019h		; HL = address of next
	DB 10h,( L13BB)-$-1
	DB 0b7h			; return A <> 0 and Z-flag reset if not found
	DB 0c9h

L13DA:	DB 23h
	DB 13h
	DB 10h,( L13C9)-$-1

	; device name found
	DB 0c1h			; clean stack
	DB 0c1h

	DB 1ah
	DB 0feh, ':'
	DB 0c0h			; return with next character after three
				; characters and Z-flag reset for not found

	DB 7eh		; return A = read/write flags and Z-flag set
				; if device name correct ended with a ':'
	DB 0c9h

L13E6:	DB 'CON',0C1H              ; device 1 = input/output
	DB 'TRM',0C1H              ; device 1 = input/output
	DB 'KBD',82H  ;0C1H        ; device 2 = input only
	DB 'LST',43H  ;0C1H        ; device 3 = output only and read semaphore
	DB 'AUX',0C4H ;0C1H        ; device 4 = input/output
	DB 'USR',0C5H              ; device 5 = input/output

	GLOBALS L13FE
L13FE:   ; rewrite (text file);
         ; HL = file pointer
         DB 3Eh
;         LD A,0AFH                  ; LIB, write
;         JP L1400

	GLOBALS L13FF
L13FF:   ; reset (text file);
         ; HL = file pointer
         DB 0afh                      ; LIB, read

;L1400:
         DB 32h
	DW L00E8               ; 0 = reset, NZ = rewrite

         DB 0cdh
	DW  L1469                 ; close a text file
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred
	DB 02ah
	DW L00E2		; HL = FIB, byte 0
	DB 0cbh,0aeh		; reset write semaphore bit
	DB 7eh
	DB 0e6h, 0FH
	DB 0c0h			; return if not a disk file type
	DB 0cdh
	DW  L1430		; open or create file
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred

	DB 02ah
	DW L00E2		; HL = FIB, byte 0

	DB 3ah
	DW L00E8
	DB 0b7h
	DB 01h
	DW 8080H		; buffer pointer at 128 and read only
	DB 28h,(L142B)-$-1

	DB 01h
	DW 0040H		; buffer pointer at 0 and write only

L142B:	DB 71h		; set flags byte
         OFF_HL 0 DOS_PTR
;	 INC HL
;	 INC HL			 ; FIB_PTR
	DB 70h		; set sector buffer pointer
         DB 23h
         DB 36h,0                  ; high byte is 0

         DB 01h
	DW 0080H
         OFF_HL DOS_PTR+1 DOS_REC
         DB 71h
         DB 23h
         DB 70h
	DB 0c9h

L1430:   ; 33e CALL L145A                 ; clear FCB first
	DB 02ah
	DW L00E2
         OFF_HL 0 DOS_FCB
;	 LD DE,FIB_FCB		 ; offset to FCB
;	 ADD HL,DE
;         EX DE,HL
;         LD A,(L00E8)               ; reset or rewrite ?
;         OR A
;         LD BC,010FH                ; C = file open (0FH), B = error 1
;         JR Z,L144E                 ; jump if reset

;         PUSH DE
;         LD C,13H                   ; C = file delete
;         CALL MSXDOS
;         POP DE
;         LD BC,0F116H               ; C = file create (16H), B = error F1
;L144E:   PUSH BC
;         CALL MSXDOS
;         POP BC
;         INC A
;         RET NZ                     ; quit if no error, A = 0
;         LD A,B
;         LD (L00D0),A               ; IORESULT = 001H = File does not exist
				; IORESULT = 0F1H = Directory is full

;         RET

;L145A:   ; resets the FCB
;         LD HL,(L00E2)
;         OFF_HL 0 DOS_FCB
;	 LD DE,FIB_FCB+12 	 ; offset to first byte after name in FCB
;	 ADD HL,DE

;         LD B,FCB_LEN-12            ; clear rest of FCB
;L1463:   LD (HL),0
;         INC HL
;         DJNZ L1463
;         RET

; 33e
         DB 54h
         DB 5dh
         DB 23h
         DB 3ah
	DW L00E8
         DB 0b7h
         DB 20h,(L1A3B)-$-1                ; jump if rewrite

         DB 3eh,' '
         DB 47h
         DB 4fh
         DB 0cdh
	DW  OPENFILE              ; 33e, TODO OpenFile
         DB 0c8h
         DB 3eh,1
         DB 32h
	DW L00D0               ; IORESULT = 1
         DB 0c9h

L1A3B:
         DB 3eh,' '
         DB 47h
         DB 4fh
         DB 0cdh
	DW  CREATEFILE ; L2C4A             ; 33e, TODO CreateFile
         DB 0c8h
         DB 3eh,0F1H
         DB 32h
	DW L00D0               ; IORESULT = 0F1H
         DB 0c9h
; 33e

	GLOBALS L1469
L1469:	; LIB
	; PROCEDURE Close(VAR F: FILE);
	; closes a text file
         ; in:    HL = FIB address

	DB 22h
	DW L00E2		; save FIB address
	DB 7eh
	DB 0e6h, 0FH
	DB 0c0h			; quit if it is a device

	DB 0cbh,076h
	DB 28h,(L147E)-$-1		; jump if no output allowed

	DB 3eh,1AH
	DB 0cdh
	DW  L16C6		; write a ^Z to end the text file
         DB 0cdh
	DW  L170C                 ; flush buffer
	DB 18h,( L1481)-$-1 		; close file

L147E:	DB 0cbh,07eh
	DB 0c8h			; return if no input allowed

L1481:	; closes a file
	DB 02ah
	DW L00E2
	DB 0e5h
         OFF_HL 0 DOS_FCB
;	 LD DE,FIB_FCB		 ; offset to FCB
;	 ADD HL,DE

         DB 44h
         DB 4dh
         DB 0cdh
	DW  CLOSEFILE              ; 33e, L2DB4, CloseFile
;         EX DE,HL                   ; DE = FCB address
;         LD C,10H                   ; file close
;         CALL MSXDOS
	DB 0e1h
;         INC A
         DB 28h,(L1498)-$-1                 ; jump if file closed normally

	DB 3eh,0FFH
	DB 32h
	DW L00D0		; IORESULT = 0FFH, File disappeared

L1498:	DB 36h,0		; always resets the FIB
	DB 0c9h

ENDIF	; USELIB

	GLOBALS L149B
L149B:	; LIB
	; sets current FIB address to standard output (OUTPUT)
	; in:	HL = FIB address
	; out:	-
	DB 0e3h		; LIB, for search ???
         DB 22h
	DW L00E4              ; save return address
	DB 0e3h
	DB 0e5h
         DB 21h
	DW OUTPUT
	DB 22h
	DW L00E2
	DB 0e1h
	DB 0c9h

	GLOBALS L14A9
L14A9:	; LIB
	; sets current FIB address and checks if it is open for input
	; in:	HL = FIB address
	DB 0e3h
	DB 22h
	DW L00E4
	DB 0e3h
	DB 22h
	DW L00E2		; save FIB address

	DB 0cbh,07eh		; open for input ?
	DB 0c0h			; yes, quit

         DB 3eh,2
	DB 32h
	DW L00D0		; IORESULT = 2, File not open for input
	DB 0c9h

	GLOBALS L14BA
L14BA:	; LIB
	; sets current FIB address and checks if it is open for output
	; in:	HL = FIB address
	; out:	-
	DB 0e3h
	DB 22h
	DW L00E4
	DB 0e3h
	DB 22h
	DW L00E2		; save FIB address
	DB 0cbh,076h		; open for output ?
	DB 0c0h			; yes, quit
	DB 3eh,3
	DB 32h
	DW L00D0		; IORESULT = 3, File not open for output
	DB 0c9h


IFDEF USELIB

	GLOBALS L14CB
L14CB:   ; LIB, readln from console
         DB 3eh,0AFH

         DB 18h,( L14CD)-$-1

	GLOBALS L14CC
L14CC:   ; LIB, read from console
         DB 0afh

L14CD:   DB 0e3h
	DB 22h
	DW L00E4
	DB 0e3h
	DB 0e5h
         DB 21h
	DW OUTPUT
	DB 22h
	DW L00E2
	DB 0cbh,0aeh
	DB 0f5h

         DB 3ah
	DW REDIRECTIONFLAG
         DB 47h
         DB 0cdh
	DW  L14EA                 ; do real read

         DB 0f1h
	DB 0b7h
	DB 28h,(L14E6)-$-1		; jump if not readln

         DB 3ah
	DW REDIRECTIONFLAG
         DB 0b7h
         DB 0cch
	DW L01E1               ; print CR, LF if no input redirection

L14E6:	DB 0e1h
	DB 0c9h

ENDIF	; USELIB


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

L14FD:   DB 16h,0

L14FF:	DB 0cdh
	DW  L03E1		; A = character from console
	DB 77h

	DB 1eh,1
	DB 0feh, 8			; backspace ?
         DB 28h,(L153F)-$-1
         DB 0feh, 7FH                     ; delete ?
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

         DB 14h

         DB 3ah
	DW REDIRECTIONFLAG
         DB 0b7h                       ; Zero if no input redirection

         DB 7eh
	DB 23h

         DB 0cch
	DW L03C9               ; print character, if no input redirection
	DB 18h,( L14FF)-$-1

L153F:   ; E = 1 if backspace or delete
         ; E = 0 if insert or escape
         DB 15h
	DB 0fah
	DW L14FD
	DB 2bh

         DB 0cdh
	DW  L0200
	DB 8,' ',8,0               ; backspace, space, backspace
	DB 1dh
	DB 28h,(L14FF)-$-1

         DB 18h,( L153F)-$-1

L1550:   ; ^Z typed in
         DB 04h
	DB 05h
         DB 28h,(L14FF)-$-1                 ; ignore ^Z if B = 0

         DB 18h,( L155A)-$-1                   ; quit with ^Z

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
	DW L00D6              ; save end address
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
         DB 0c2h
	DW L15E9                ; jump if pre-read character present

	DB 0e6h, 0FH
         DB 0c2h
	DW L15AB                ; jump if device

	; read character from text file
         OFF_HL 0 DOS_PTR
;	 INC HL
;	 INC HL
         DB 7eh                  ; A = DOS_PTR
	DB 0b7h
	DB 0f2h
	DW L1597		; < 128 ?

; 33e
         DB 0e5h

         OFF_HL DOS_PTR DOS_REC
         DB 5eh
         DB 23h
         DB 56h
         DB 0d5h                    ; save record length

         OFF_HL DOS_REC+1 DOS_FCB   ; HL = handle/FCB address

         DB 0e5h                    ; save HL

         OFF_HL DOS_FCB DOS_BUF     ; HL = address of buffer
         DB 54h
         DB 5dh

         DB 0c1h                     ; BC = handle/FCB address
         DB 0e1h                     ; HL = number of bytes to read

         DB 0cdh
	DW  READFILE              ; 33e, TODO ReadFile
         DB 44h                     ; BC = number of bytes read
         DB 4dh

         DB 0e1h                     ; HL = DOS_PTR
         DB 28h,(L1594)-$-1

          DB 0e5h                    ; save HL = DOS_PTR
;         OFF_HL DOS_PTR DOS_BUF
;         LD (HL),26

; 33e
;         ; read next FIB_BUF
;         LD C,14H                   ; sequential read
;         PUSH HL
;         CALL L19BA                 ; sequential read from current position
;                                    ; to FIB_BUF
;         POP HL
;         JR Z,L1594                 ; jump if no error

	; error occurred, fill first byte of FIB_BUF with ^Z (end of file)

         OFF_HL DOS_PTR DOS_BUF
;	 LD DE,2EH
;	 ADD HL,DE
L1590:
	DB 36h,1AH
         DB 0e1h                     ; restore to FIB_PTR
         DB 18h,( L1596)-$-1                   ; 33e, TODO L1BB8

L1594:
         DB 11h
	DW 128
         DB 7ah
         DB 0b8h
         DB 20h,(L1595)-$-1
         DB 7bh
         DB 0b9h
         DB 28h,(L1596)-$-1

L1595:
         DB 0e5h
         DB 09h                  ; HL += number of bytes read
         DB 01h
	DW DOS_BUF - DOS_PTR
         DB 09h
         DB 18h,( L1590)-$-1

L1596:
         DB 0afh
	DB 77h		; FIB_PTR = 0

L1597:	DB 034h
         DB 0c6h,DOS_BUF - DOS_PTR    ; 33e, 4F ; 2EH
	DB 5fh
	DB 16h,0
	DB 019h
	DB 7eh
	DB 0feh, 1AH			; first character = ^Z (eof)
         DB 0c2h
	DW L15E0

	DB 02ah
	DW L00E2
         OFF_HL 0 DOS_PTR
;	 INC HL
;	 INC HL
	DB 035h 		; FIB_PTR does not move beyond ^Z
         DB 0c3h
	DW  L15E0

L15AB:	DB 3dh			; device = 1, 'CON:' ?
	DB 20h,(L15C9)-$-1		; jump if not 'CON:'

         DB 02ah
	DW L00D4              ; start address of buffer
         DB 0edh,5bh
	DW L00D6              ; end address of buffer
	DB 0b7h
	DB 0EDH,052h
	DB 38h,(L15BF)-$-1		; read from buffer until current = end address

         DB 06h,0FFH                  ; do not ignore ^Z
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


IFDEF USELIB

	GLOBALS L1644
L1644:   ; READ (VAR F: TEXT; VAR C: CHAR);
         DB 0e5h                    ; LIB
	DB 0cdh
	DW  L156B		; read character from file or device
	DB 0cbh,0aeh
	DB 0e1h
	DB 77h
	DB 0c9h

	GLOBALS L164D
L164D:   ; READ (VAR F: TEXT; VAR B: BYTE);
         ; store as BYTE
	DB 3eh,1			; store as BYTE
	DB 18h,( L164F)-$-1

ENDIF	; USELIB


	GLOBALS L164E
L164E:   ; READ (VAR F: TEXT; VAR I: INTEGER);
         ; store as INTEGER
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
	DW  L1624		; read an optional sign
	DB 0c8h			; quit if end of ASCII-text

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

	GLOBALS L1671
L1671:   ; READ (VAR F: TEXT; VAR L: LONGINT);
         ; LIB
	; in:	HL = destination address for LONGINT value
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

IFDEF USELIB

	GLOBALS L1672
L1672:   ; READ (VAR F: TEXT; VAR R: REAL);
         DB 0cdh
	DW  L15F0                 ; LIB
	DB 0cdh
	DW  L1624
	DB 0c8h

         DB 0c5h
	DB 0e5h

         DB 0cdh
	DW  L11A3                 ; convert ascii to HLDEBC

         DB 0d9h
	DB 0e1h
	DB 0c1h

         DB 0cdh
	DW  L1636
	DB 0d8h

         DB 05h

         DB 0d9h
	DB 0cch
	DW L0A8F
	DB 0d9h
	DB 0c3h
	DW  L05D1 		; PUTFLT

	GLOBALS L168E
L168E:   ; READ (VAR F: TEXT; VAR S: STRING);
         DB 0e5h                    ; LIB
	DB 0ebh
	DB 0eh,0
L1692:	DB 0c5h
	DB 0d5h
	DB 0cdh
	DW  L156B		; read character from file or device
	DB 0d1h
	DB 0c1h
	DB 0feh, 0DH
	DB 28h,(L16A8)-$-1
	DB 0feh, 1AH
	DB 28h,(L16A8)-$-1
	DB 0cbh,0aeh
	DB 0ch
	DB 13h
	DB 12h
	DB 10h,( L1692)-$-1
L16A8:	DB 0e1h
	DB 71h
	DB 0c9h

	GLOBALS L16AB
L16AB:   ; READLN (VAR F: TEXT);
         ; LIB
	DB 0cdh
	DW  L156B		; read character from file or device
	DB 0feh, 1AH
	DB 28h,(L16C5)-$-1		; quit if ^Z

         DB 0cbh,0aeh                 ; no pre-read character

	DB 0feh, 0AH
         DB 28h,(L16C5)-$-1                 ; quit if linefeed

	DB 0feh, 0DH
	DB 20h,(L16AB)-$-1		; repeat while not return


	DB 0cdh
	DW  L156B		; read character from file or device
	DB 0feh, 0AH
         DB 20h,(L16C5)-$-1                ; jump if not linefeed
                                    ; this character will be read the next time

         ; 0Dh, 0Ah found, carriage return and linefeed found

         DB 0cbh,0aeh                 ; no pre-read character

L16C5:   DB 0c9h

ENDIF	; USELIB


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

         OFF_HL 0 DOS_PTR
;	 INC HL
;	 INC HL			 ; offset to FIB_PTR
	DB 0e5h
	DB 7eh		; A = low byte of FIB_PTR
         DB 0c6h,DOS_BUF-DOS_PTR      ; 2EH, distance between FIB_PTR and FIB_BUF
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
         OFF_HL 0 DOS_PTR
;	 INC HL
;	 INC HL
         DB 7eh                  ; A = low byte of DOS_PTR
	DB 0b7h
	DB 0c8h			; quit if nothing written
         DB 36h,0                  ; reset to start of DOS_BUF

         DB 5fh                     ; DE = number of bytes in buffer
         DB 16h,0
         DB 0d5h                    ; save DE

         OFF_HL DOS_PTR DOS_FCB     ; HL = handle/FCB address

         DB 0e5h                    ; save HL

         OFF_HL DOS_FCB DOS_BUF     ; HL = address of buffer
         DB 54h                     ; DE = address of buffer
         DB 5dh
         DB 0c1h                     ; BC = handle/FCB address
         DB 0e1h                     ; HL = number of bytes to write
         DB 0cdh
	DW  WRITEFILE             ; 33e, L2D8E WriteFile

         DB 44h                     ; BC = number of bytes read
         DB 4dh

;         LD C,15H                   ; sequential write 128 bytes
;         CALL L19BA                 ; write FIB_BUF to current position
	DB 0c8h			; quit if no error
	DB 3eh,0F0H
	DB 32h
	DW L00D0		; IORESULT = 0F0H, Disk write error
	DB 0c9h


IFDEF USELIB

	GLOBALS L1722
L1722:   ; WRITE (VAR F: TEXT; C: CHAR);
         DB 7dh                     ; LIB
	DB 0c3h
	DW  L16C6

ENDIF	; USELIB

	GLOBALS L1726
L1726:   ; WRITE (VAR F: TEXT; I: INTEGER);
         ; LIB, print INTEGER
	; in:	value to print is pushed on stack
	;	HL = size in characters
	;	(L00D2) destination address for ASCII result
	; out:	-
	DB 0c1h			; LIB
	DB 0d1h
	DB 0c5h
	DB 0ddh,02ah
	DW L00D2
	DB 0cbh,07ch
	DB 28h,(L1737)-$-1		; jump if size = positive

	; print INTEGER as unsigned
	DB 0cdh
	DW  L0783		; negate HL (size)
	DB 0ebh 		; HL = value, DE = size
	DB 18h,( L1745)-$-1

L1737:	DB 0ebh 		; HL = value, DE = size
	DB 0cbh,07ch
	DB 28h,(L1745)-$-1		; jump if value = positive

	DB 0cdh
	DW  L0783		; negate HL
	DB 0ddh,36h,+0,'-'              ; print minus sign
	DB 0ddh,23h

L1745:	DB 0d5h			; push size

	DB 0cdh
	DW  L07C6		; unsigned INTEGER to ASCII

L1749:	; print string from character buffer (L00D2) with leading spaces if
	; pushed size > characters written in buffer
	; in:	total size wanted is pushed
	DB 0e1h			; size, ( WRITELN(int : size) )

	DB 0cdh
	DW  L04C8		; int to byte
	; A = size

	DB 0edh,5bh
	DW L00D2		; DE = start of ASCII buffer
	DB 0ddh,0e5h
	DB 0e1h
	DB 0b7h
	DB 0EDH,052h
	DB 4dh			; C = characters written in buffer

	DB 0ebh 		; HL = start of ASCII buffer

L1759:	; in:   HL = start of ASCII buffer
	;	C = characters written in buffer
	DB 091h			; size - characters written
	DB 38h,(L176A)-$-1		; jump if size is less, no spaces first
	DB 28h,(L176A)-$-1		; jump if size is equal, no spaces first

	DB 47h			; B = number of spaces to add
	DB 0e5h			; save start of ASCII buffer

L1760:	DB 3eh,' '
	DB 0c5h
	DB 0cdh
	DW  L16C6		; write space character
	DB 0c1h
	DB 10h,( L1760)-$-1		; repeat

	DB 0e1h			; HL = start of ASCII buffer

L176A:	DB 41h			; B = characters in ASCII buffer
	DB 04h

L176C:	DB 05h
	DB 0c8h			; quit if all printed (or empty)

	DB 7eh		; A = chacacter to print
	DB 0c5h
	DB 0e5h
	DB 0cdh
	DW  L16C6		; print character
	DB 0e1h
	DB 0c1h
	DB 23h			; next one
	DB 18h,( L176C)-$-1

	GLOBALS L1779
L1779:   ; WRITE (VAR F: TEXT; R: REAL);
         ; LIB, print REAL
	; in:	push REAL
	;	push size
	;	HL = number of digits after decimal point
	DB 0c1h			; return address

	DB 0d1h			; DE = size of real

	DB 0d9h
	DB 0e1h			; HLDEBC = REAL to be printed
	DB 0d1h
	DB 0c1h
	DB 0d9h

	DB 0c5h			; return address

	DB 0ddh,02ah
	DW L00D2		; IX = destination address for ASCII
	DB 0d5h			; push size

	DB 0cdh
	DW  L1027		; convert REAL to ASCII

	DB 18h,( L1749)-$-1

	GLOBALS PRT_LONG
PRT_LONG:
         ; WRITE (VAR F: TEXT; L: LONGINT);
	; LIB, print LONG
	; in:	value to print is pushed on stack
	;	HL = size in characters
	;	(L00D2) destination address for ASCII result
	; out:	-
	DB 0ddh,0e1h			; LIB
	DB 0c1h			; BC = low-word
	DB 0d1h			; DE = high-word
	DB 0ddh,0e5h

	DB 0ddh,02ah
	DW L00D2
	DB 0cbh,07ch
	DB 28h,(PRT_LONG1)-$-1		; jump if size = positive

	; print LONG as unsigned
	DB 0cdh
	DW  L0783		; negate HL (size)
	DB 18h,( PRT_LONG2)-$-1

PRT_LONG1:
	; print LONG as signed
	DB 0c5h
	DB 0e3h		; HL = low-word, (SP) = size

         ; DE:HL = value
         DB 0cbh,07ah
	DB 28h,(PRT_LONG11)-$-1		; jump if value = positive

	DB 0cdh
	DW  L_NEG		; negate DE:HL
	DB 0ddh,36h,+0,'-'              ; print minus sign
	DB 0ddh,23h

PRT_LONG11:
	DB 0e3h		; HL = size, (SP) = low-word
	DB 0c1h			; BC = low-word

PRT_LONG2:

	; DE:BC = LONG
	;    HL = size
	DB 0e5h			; push size

         DB 60h
         DB 69h
	DB 0cdh
	DW  L2A 		; unsigned LONG to ASCII

	DB 18h,( L1749)-$-1

IFDEF USELIB

	GLOBALS L178B
L178B:   ; WRITE (VAR F: TEXT; B: BOOLEAN);
         ; LIB, print BOOLEAN
	DB 0c1h			; LIB
	DB 0d1h
	DB 0c5h
	DB 0cdh
	DW  L04C8		; int to byte
	DB 0cbh,043h
	DB 21h
	DW L17A1		; HL = 'TRUE' text
	DB 0eh,4			;  C = 4 characters
	DB 20h,(L1759)-$-1
	DB 21h
	DW L17A5		; HL = 'FALSE' test
	DB 0eh,5			;  C = 5 characters
	DB 18h,( L1759)-$-1

L17A1:	DB 'TRUE'
L17A5:	DB 'FALSE'

	GLOBALS L17AA
L17AA:   ; WRITE (VAR F: TEXT; S: STRING);
         ; LIB
         DB 0cdh
	DW  L04C8                 ; int to byte
	DB 21h
	DW 2
	DB 039h

	DB 4eh
	DB 23h

         DB 0cdh
	DW  L1759

         DB 0d1h                     ; DE = return address

         DB 0f9h                   ; remove string from stack

         DB 0d5h                    ; jump to return address
	DB 0c9h

	GLOBALS L17BA
L17BA:   ; WRITE (VAR F: TEXT; CONSTANT STRING);
         DB 0e1h                     ; LIB
	DB 7eh
	DB 23h
	DB 0b7h
	DB 28h,(L17CC)-$-1
	DB 47h

L17C1:	DB 7eh
	DB 0c5h
	DB 0e5h
	DB 0cdh
	DW  L16C6
	DB 0e1h
	DB 0c1h
	DB 23h
	DB 10h,( L17C1)-$-1

L17CC:   DB 0e9h                    ; jump to return address

	GLOBALS L17CD
L17CD:   ; WRITELN (VAR F: TEXT);
         DB 3eh,0DH                   ; LIB, prints CR LF codes
	DB 0cdh
	DW  L16C6
	DB 3eh,0AH
	DB 0c3h
	DW  L16C6

	GLOBALS L17D7
L17D7:	; FUNCTION SeekEoln(VAR F: TEXT): BOOLEAN;
         DB 11h
	DW 010DH                ; D = 1 (repeat), search 0Dh
	DB 18h,( L17E9)-$-1

	GLOBALS L17DC
L17DC:	; FUNCTION Eoln(VAR F: TEXT): BOOLEAN;
         DB 11h
	DW 0DH                  ; D = 0 (no repeat), test if 0Dh
	DB 18h,( L17E9)-$-1

	GLOBALS L17E1
L17E1:	; LIB
         ; FUNCTION SeekEof(VAR F: TEXT): BOOLEAN;
         DB 11h
	DW 011AH                ; D = 1 (repeat), search 1Ah
	DB 18h,( L17E9)-$-1

	GLOBALS L17E6
L17E6:	; LIB
         ; FUNCTION Eof(VAR F: TEXT): BOOLEAN;
         DB 11h
	DW 1AH                  ; D = 0 (no repeat), test if 1Ah

L17E9:	; in:	HL = FIB address
	DB 22h
	DW L00E2		; save FIB address
	DB 0cbh,07eh
	DB 28h,(L180C)-$-1		; jump if no input allowed, return False

L17F0:	DB 0d5h
	DB 0cdh
	DW  L156B		; read character from file or device
	DB 0d1h
	DB 0bbh			; character found
	DB 28h,(L1808)-$-1
	DB 0feh, 1AH			; ^Z ?
	DB 28h,(L1808)-$-1		; jump if found, return True
         DB 0feh, 21H                     ; >= 33 ? '!'
	DB 30h,(L180C)-$-1		; jump if >= 31, return False
	DB 14h
	DB 15h
	DB 28h,(L180C)-$-1		; jump if eof called, return False

	; repeat for seek
	DB 0cbh,0aeh		; no pre-read character
	DB 18h,( L17F0)-$-1

L1808:	DB 21h
	DW 1			; return TRUE
	DB 0c9h

L180C:	DB 21h
	DW 0
	DB 0c9h			; return FALSE

	GLOBALS L1810
L1810:	; LIB
	; PROCEDURE Rewrite(VAR F: FILE OF TYPE);
	DB 3eh,0AFH		; LIB, LD A,XOR A
	DB 0c3h
	DW  L1812

	GLOBALS L1811
L1811:	; LIB
	; PROCEDURE Reset(VAR F: FILE OF TYPE);
	DB 0afh			; LIB

L1812:	; in:	HL = FIB address
	;	DE = record length
         DB 32h
	DW L00E8               ; 0 = reset, NZ = rewrite

         DW 53edh,L00E6              ; save record length of typed file

	DB 0cdh
	DW  L187A		; close a typed file
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred

	DB 0cdh
	DW  L1430		; open or create file
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred

	; watch it !!, A = 0
	DB 02ah
	DW L00E2
	DB 36h,0D0H		; bit 7 = '1', input allowed
				; bit 6 = '1', output allowed
				; bit 5 = '0', no data written to buffer
				; bit 4 = '1', contents is undefined

         DB 0afh
         OFF_HL 0 DOS_PTR
         DB 77h                  ; DOS_PTR = 0
         DB 23h
         DB 77h

         OFF_HL DOS_PTR+1 DOS_CUR
;	 LD DE,6
;	 ADD HL,DE
	DB 77h		; FIB_CUR = 0
	DB 23h
	DB 77h
         DB 23h
         DB 77h
         DB 23h
         DB 77h

;         OFF_HL FIB_CUR+1 FIB_FCB+21H ; offset to position in FCB
;;         LD DE,0024H
;;         ADD HL,DE
;         LD (HL),A
;         INC HL
;         LD (HL),A

         OFF_HL DOS_CUR+3 DOS_NUM
;         OFF_HL FIB_FCB+21H+1 FIB_NUM ; offset to FIB_NUM
;	 LD DE,-42
;	 ADD HL,DE

	DB 3ah
	DW L00E8		; reset or rewrite ?
	DB 0b7h
	DB 20h,(L1864)-$-1		; jump if rewrite

         OFF_HL DOS_NUM DOS_FCB

         DB 44h                     ; BC = handle/FCB address
         DB 4dh
         DB 0cdh
	DW  FILESIZE              ; 33e, TODO L2D22

         DB 0d5h
         DB 0e5h

         DB 0d5h
         DB 0e5h
         DB 02ah
	DW L00E6              ; DE:HL = record length
         DB 11h
	DW 0

         DB 0cdh
	DW  L_MOD
         DB 7dh
         DB 0b4h
         DB 0b3h
         DB 0b2h

         DB 0e1h
         DB 0d1h
         DB 0c2h
	DW L1860                ; 33e, TODO L1F28

         DB 0d5h
         DB 0e5h
         DB 02ah
	DW L00E6
         DB 11h
	DW 0
         DB 0cdh
	DW  L_DIV                 ; 33e, TODO L0B18

         DB 0d5h
         DB 0ebh

         DB 02ah
	DW L00E2
         DB 01h
	DW DOS_NUM
         DB 09h

         DB 73h
         DB 23h
         DB 72h
         DB 23h
         DB 0d1h
         DB 73h
         DB 23h
         DB 72h
         DB 23h                     ; HL = address of DOS_REC

         DB 0edh,5bh
	DW L00E6
         DB 73h
         DB 23h
         DB 72h
         DB 0c9h


;         LD BC,FIL_HDR              ; data length
;         XOR A
;         CALL L1909                 ; read data, fill FIB_NUM and FIB_

;         POP HL                     ; restore address to FIB_NUM

;         OFF_HL FIB_NUM FIB_REC
;	 INC HL
;	 INC HL
;         LD C,(HL)                  ; BC = record length from file reset
;         INC HL
;         LD B,(HL)

;         LD HL,(L00E6)
;         OR A
;         SBC HL,BC                  ; file record length = typed length equal
;         RET Z                      ; record length equal ?


L1860:
	DB 3eh,90H
	DB 32h
	DW L00D0		; IORESULT = 90H, Record length mismatch
         DB 3eh,3DH
         DB 32h
	DW ERRORNUMBER         ; 33e, TODO 2BA3
	DB 0c9h

L1864:
; 33e    PUSH HL

	DB 0afh			; FIB_NUM = 0
	DB 77h
	DB 23h
	DB 77h
         DB 23h
         DB 77h
         DB 23h
         DB 77h

         OFF_HL DOS_NUM+3 DOS_REC
;	 INC HL
	DB 0edh,5bh
	DW L00E6		; DE = record length

	DB 73h		; write record length
	DB 23h
	DB 72h
         DB 0c9h

;         POP HL
;         LD BC,FIL_HDR
;         LD A,3
;         JP L1909                   ; write data, FIB_NUM and FIB_REC to file

	GLOBALS L187A
L187A:	; LIB
         ; PROCEDURE Close(VAR F: FILE OF TYPE);
	; closes a typed file
	; in:	HL = FIB address
	DB 22h
	DW L00E2		; save FIB address
	DB 7eh
	DB 0e6h, 0C0H 		; quit if input/output not allowed
	DB 0c8h
         DB 0c3h
	DW  L1481                   ; CloseFile

;         CALL L19AE                 ; write buffer to current record in FCB
;                                    ; position unchanged
;         LD HL,(L00E2)
;         OFF_HL 0 FIB_FCB+21H
;;         LD DE,FIB_FCB+21H          ; 002DH, offset to first byte of file pos.
;;         ADD HL,DE
;         XOR A
;         LD (HL),A                  ; reset current file position
;         INC HL
;         LD (HL),A
;
;         OFF_HL FIB_FCB+21H+1 FIB_PTR
;;         LD DE,FIB_PTR-(FIB_FCB+21H+1) ; -44
;	 ADD HL,DE
;         LD (HL),A                  ; reset sector buffer pointer
;         OFF_HL FIB_PTR FIB_NUM
;;         INC HL
;;         INC HL                     ; HL = address of number of records
;         LD BC,FIL_HDR              ; 0004
;         LD A,1
;         CALL L1909                 ; write data
;         CALL L19AE                 ; write buffer to current record in FCB
;                                    ; position unchanged
;         JP L1481                   ; close file

ENDIF	; USELIB

	GLOBALS L18A4
L18A4:   DB 0e3h
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

         DW 0                       ; ????

IFDEF USELIB

	GLOBALS L18B6
L18B6:   ; READ (VAR F: FILE OF TYPE)
         ; in:    HL = destination address for record to read
	DB 3ah
	DW L00D0		; LIB, read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred

         DB 01h
	DW 1
         DB 0ebh
         DB 3eh,21H

L18C0:
         DB 21h
	DW L00F0                ; 33e, TODO L01C2
         DB 22h
	DW L00E6
         DB 02ah
	DW L00E2
         DB 0c3h
	DW  L1AFD                   ; 33e, TODO L21A6

;         PUSH HL
;         CALL L1A5A                 ; HL = number of records
;                                    ; DE = current record
;                                    ; BC = record length
;         EX DE,HL
;         OR A
;         SBC HL,DE                  ; current >= number of records ?
;         POP HL
;         JR NC,L18D6                ; jump if Unexpected end-of-file
;         XOR A
;         CALL L1909                 ; read data
;
L18CA:
;         LD HL,(L00E2)              ; HL = FIB address
;         OFF_HL 0 FIB_CUR
;;         LD DE,0008
;;         ADD HL,DE
;         INC (HL)                   ; increase low byte of current record
;         RET NZ
;         INC HL
;         INC (HL)                   ; increase high byte of current record
;         RET

L18D6:	DB 3eh,99H
	DB 32h
	DW L00D0		; IORESULT = 99H, Unexpected end-of-file
         DB 3eh,0C7H
         DB 32h
	DW ERRORNUMBER         ; 33e, TODO L2BA3
	DB 0c9h

	GLOBALS L18DC
L18DC:   ; WRITE (VAR F: FILE OF TYPE)
         ; in:    HL = source address of record to write
         ; LIB
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred
         DB 01h
	DW 1
         DB 0ebh
         DB 3eh,22H
         DB 0c3h
	DW  L18C0

;         PUSH HL
;         CALL L1A5A                 ; HL = number of records
;                                    ; DE = current record
;                                    ; BC = record length
;         OR A
;         SBC HL,DE                  ; number = current ?
;         LD A,1                     ; write data
;         JR NZ,L18FC                ; jump if not equal
;
;         ; increase the number of records
;         LD HL,(L00E2)
;         OFF_HL 0 FIB_NUM
;;         LD DE,0004
;;         ADD HL,DE
;         INC (HL)                   ; increase low-byte of position
;         JR NZ,L18FA
;         INC HL
;         INC (HL)                   ; increase high-byte of position
;         JR Z,L1902                 ; jump if File size overflow
;
;L18FA:   LD A,3                     ; write data + append ?
;
;L18FC:   POP HL
;         CALL L1909                 ; write data
;         JR L18CA                   ; jump to increase the current record
;
;L1902:   POP HL
;         LD A,0F2H
;         LD (L00D0),A               ; IORESULT = 0F2H, File size overflow
;         RET
;
;L1909:   ; in:    HL = destination/source address for data
;         ;        A, bit 0 = '1' for copy data from HL to buffer
;         ;        A, bit 0 = '0' for copy data from buffer to HL
;         LD (L00E9),A
;         EX DE,HL                   ; DE = address FIB_NUM
;
;L190D:   LD HL,(L00E2)              ; HL = FIB address
;         BIT 4,(HL)
;         JR Z,L1943                 ; jump if buffer contents is defined
;
;         RES 4,(HL)
;         LD A,(L00E9)
;         BIT 0,A
;         JR Z,L1935                 ; jump if to copy data from the buffer
;
;         OFF_HL 0 FIB_PTR
;;         INC HL
;;         INC HL
;         LD A,(HL)                  ; A = low byte of sector buffer pointer
;         OFF_HL FIB_PTR 0
;;         DEC HL
;;         DEC HL
;         OR A
;         JR NZ,L1935                ; jump if buffer not empty
;
;         LD A,(L00E9)
;         BIT 1,A
;         JR NZ,L1943
;         LD A,B
;         OR A
;         JR NZ,L1943
;         LD A,C
;         OR A
;         JP M,L1943
;
;L1935:   PUSH BC
;         PUSH DE
;         LD C,21H
;         CALL L19BA                 ; random read from current position
;                                    ; to FIB_BUF
;         POP DE
;         POP BC
;         JR NZ,L1991                ; jump if Unexpected end-of-file
;         LD HL,(L00E2)              ; HL = FIB address
;
;L1943:   LD A,(L00E9)
;         BIT 0,A
;         JR Z,L194C
;         SET 5,(HL)                 ; data has been written to the buffer
;
;L194C:   OFF_HL 0 FIB_PTR
;;         INC HL
;;         INC HL
;         LD A,(HL)                  ; A = low byte sector buffer pointer
;         ADD A,FIB_BUF-FIB_PTR      ; 2EH
;         PUSH DE
;         LD E,A
;         LD D,0
;         ADD HL,DE                  ; HL = address within buffer
;         POP DE                     ; DE = address FIB_NUM
;         SUB 2EH
;         CALL L199A                 ; swap HL,DE if L00E9,0 = 1
;
;         ; BC = number of byte to copy, (mostly 4 = FIL_HDR)
;L195C:   LDI                        ; copy from FIB_NUM to buffer or <-->
;IFDEF MSX
;         JP PO,L1966                ; jump if BC = 0, PO
;ELSE
;         JP C,L1966                 ; jump if BC = 0, PO
;ENDIF
;         INC A                      ; increase current pointer
;         JP P,L195C
;         DEC A
;L1966:   INC A
;
;         CALL L199A                 ; swap HL,DE if L00E9,0 = 1
;         LD HL,(L00E2)
;         OFF_HL 0 FIB_PTR
;;         INC HL
;;         INC HL
;         AND 7FH                    ; modulo 128
;         LD (HL),A                  ; write new sector buffer pointer
;         JR NZ,L198A
;
;         ; write complete buffer to disk if sector buffer pointer wrapped around
;         PUSH BC
;         PUSH DE
;         PUSH HL
;         CALL L19AE                 ; write buffer to current record in FCB
;                                    ; position unchanged
;         POP HL
;         POP DE
;         POP BC
;         JR NZ,L1994                ; jump if write error
;
;         PUSH DE
;         OFF_HL FIB_PTR FIB_FCB+21H ; offset to first byte of file position
;;         LD DE,002BH
;;         ADD HL,DE
;         POP DE
;         INC (HL)                   ; increase low byte
;         JR NZ,L198A
;         INC HL
;         INC (HL)                   ; increase high byte
;
;L198A:   LD A,B
;         OR C
;         JP NZ,L190D                ; repeat until BC = 0
;         EX DE,HL
;         RET
;
;L1991:   LD A,99H                   ; IORESULT = 99H, Unexpected end-of-file
;
;IFDEF MSX
;         DB 1                       ; opcode of 'LD BC,', eats 'LD A,0F0H'
;ELSE
;;!       jmp near ptr L1996
;ENDIF
;
;L1994:   LD A,0F0H
;L1996:   LD (L00D0),A               ; IORESULT = 0F0H, Disk write error
;         RET
;
;L199A:   PUSH AF
;         LD A,(L00E9)
;         BIT 0,A
;         JR Z,L19A3
;         EX DE,HL
;L19A3:   POP AF
;         RET

	GLOBALS L19A5
L19A5:   ; FLUSH (VAR F: FILE OF TYPE)
         DB 0c9h
;         LD (L00E2),HL              ; LIB
;         CALL L19AE                 ; write buffer to current record in FCB
;                                    ; position unchanged
;         RET Z                      ; return if no error
;         JR L1994

; 33e MARK START 1F93
L19AE:	; random write a changed buffer to the current position
	; according to the FCB
	DB 0eh,22H 		; random write
	DB 02ah
	DW L00E2
	DB 0cbh,0e6h		; read semaphore = 1, buffer undefined
	DB 0cbh,06eh		; write semephore = 1 ?
	DB 0c8h			; return if no data was written in buffer
	; some data was written to the buffer
	DB 0cbh,0aeh

ENDIF	; USELIB

L19BA:	; write FIB_BUF to current position according to FCB
	DB 02ah
	DW L00E2		; HL = address of FIB
	DB 0e5h
	DB 0c5h			; save record to write

         OFF_HL 0 DOS_BUF
;	 LD DE,FIB_BUF		 ; offset to BUFFER
;	 ADD HL,DE
	DB 0ebh
	DB 0eh,1AH 		; C = set dma at FIB buffer
	DB 0cdh
	DW  MSXDOS

	DB 0c1h
	DB 0e1h
         OFF_HL 0 DOS_FCB
;         LD DE,DOS_FCB              ; offset to FCB
;	 ADD HL,DE
	DB 0ebh
	DB 0cdh
	DW  MSXDOS
	DB 0b7h
	DB 0c9h
; 33e MARK END 1FBE

IFDEF USELIB

	GLOBALS L19D5
L19D5:   ; SEEK (VAR F: FILE OF TYPE; Pos: INTEGER);
         ; LIB
	; seek typed file
	; in:	FIB address at stack
	;	HL = position to seek to

         DB 0c3h
	DW  L1B6F                   ; 33e TODO L21C8, SeekFile

;         POP BC
;         POP DE
;         LD (L00E2),DE              ; save FIB address
;         PUSH BC
;         PUSH HL                    ; save position
;
;         CALL L1A5A                 ; HL = number of records
;                                    ; DE = current record
;                                    ; BC = record length
;
;         POP DE                     ; restore DE = position
;
;         OR A
;         SBC HL,DE                  ; number - position
;         JR C,L1A26                 ; jump if Seek beyond end-of-file
;
;         LD HL,(L00E2)
;         LD BC,FIB_REC              ; offset to record length
;         ADD HL,BC
;         LD C,(HL)                  ; BC = record length
;         INC HL
;         LD B,(HL)
;         INC HL
;         LD (HL),E                  ; set new positon
;         INC HL
;         LD (HL),D

	DB 0cdh
	DW  L1A2C		; DE:HL = DE (current) * BC (length)

	DB 01h
	DW FIL_HDR		; DE:HL = DE:HL + length of file header
	DB 09h
	DB 30h,(L19FE)-$-1
	DB 13h
L19FE:	DB 7dh			; A = byte units
	DB 0e6h, 7FH

	DB 029h		; DE:HL * 2
	DB 0ebh
	DB 0EDH,06ah
	DB 0ebh

	DB 53h			; DE = 128 bytes record number
	DB 5ch

	DB 02ah
	DW L00E2
	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL
	DB 77h		; set new FIB_PTR

	OFF_HL FIB_PTR FIB_FCB+21H
;	 LD BC,FIB_FCB-FIB_PTR + 21H; 002BH, low byte of file position in FCB
;	 ADD HL,BC
	DB 4eh		; BC = previous file position
	DB 23h
	DB 46h
	DB 0ebh 		; HL = new position
				; DE = address of high byte of file pos
	DB 0b7h
	DB 0EDH,042h		; previous == new position ?
;!	pushf
	DB 09h		; restore
;!	popf
	DB 0c8h			; yes, quit

	DB 0d5h
	DB 0e5h
	DB 0cdh
	DW  L19AE		; update current record in FCB
				; position unchanged
	DB 0d1h
	DB 0e1h			; HL = address of high byte of file pos.
	DB 72h		; write new file position
	DB 2bh
	DB 73h
	DB 0c9h

ENDIF	; USELIB


L1A26:	DB 3eh,91H
	DB 32h
	DW L00D0		;  IORESULT = 91H, Seek beyond end-of-file
	DB 0c9h


IFDEF USELIB

L1A2C:	; in:	DE = current record
	;	BC = record length
	; out:	DE:HL = DE * BC
	DB 0d5h
	DB 0d9h
	DB 0e1h			; HL' = current record
	DB 0d9h
	DB 21h
	DW 0000
	DB 54h
	DB 5dh
	DB 3eh,10H
L1A37:	DB 029h
	DB 0ebh
	DB 0EDH,06ah
	DB 0ebh
	DB 0d9h
	DB 029h
	DB 0d9h
	DB 30h,(L1A45)-$-1
	DB 09h
	DB 30h,(L1A45)-$-1
	DB 13h

L1A45:	DB 3dh
	DB 20h,(L1A37)-$-1
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L1A49
L1A49:   ; LIB
	; typed and untyped files
	; FUNCTION Eof(VAR F: FILE): BOOLEAN;
	; in:	HL = FIB address

         DB 0e5h
         DB 0cdh
	DW  L1A5D
         DB 0c1h

         DB 0d5h                    ; push number of records: DE:HL
         DB 0e5h

         DB 60h
         DB 69h

         DB 0cdh
	DW  L1A55                 ; get current record number: DE:HL

         DB 0c5h
         DB 0cdh
	DW  L_CMP
         DB 0c1h
         DB 0c3h
	DW  L0682

         GLOBALS L1A55
L1A55:	; LIB
	; typed file
	; FUNCTION FilePos(VAR F: FILE OF TYPE): INTEGER;
         ; FUNCTION FilePos(VAR F: FILE): INTEGER;

         ; in:     HL = FIB address
         ; out:    BC = record length
         ;      DE:HL = current record

         OFF_HL 0 DOS_REC

         DB 4eh
         DB 23h
         DB 46h
         DB 23h
         DB 5eh
         DB 23h
         DB 56h
         DB 23h
         DB 7eh
         DB 23h
         DB 66h
         DB 6fh
         DB 0ebh

         DB 0c9h

L1A5A:   DB 02ah
	DW L00E2              ; address of FIB

         GLOBALS L1A5D
L1A5D:	; LIB
	; FUNCTION FileSize(VAR F: FILE OF TYPE): INTEGER;
         ; FUNCTION FileSize(VAR F: FILE): INTEGER;

         ; in:     HL = FIB address
         ; out:    BC = record length
         ;      DE:HL = number of records

         OFF_HL 0 DOS_REC+1

         DB 46h
         DB 2bh
         DB 4eh
         DB 2bh
         DB 56h
         DB 2bh
         DB 5eh
         DB 2bh
         DB 7eh
         DB 2bh
         DB 6eh
         DB 67h

         DB 0c9h

;         CALL L1A5D                 ; HL = number of records
;                                    ; DE = current record
;                                    ; BC = record length
;
;         OR A
;         SBC HL,DE                  ; total records == current record ?
;
;         LD HL,0000                 ; assume FALSE
;         RET NZ                     ; return if false
;
;         INC HL                     ; return TRUE
;         RET

;         GLOBALS L1A55
;L1A55:   ; LIB
;         ; typed file
;         ; FUNCTION FilePos(VAR F: FILE OF TYPE): INTEGER;
;         ; FUNCTION FilePos(VAR F: FILE): INTEGER;
;         CALL L1A5D                 ; HL = number of records
;                                    ; DE = current record
;                                    ; BC = record length
;         EX DE,HL                   ; return HL = current record
;         RET
;
ENDIF	; USELIB


IFDEF USELIB

;L1A5A:   LD HL,(L00E2)              ; address of FIB
;
;         GLOBALS L1A5D
;L1A5D:   ; LIB
;         ; FUNCTION FileSize(VAR F: FILE OF TYPE): INTEGER;
;         ; FUNCTION FileSize(VAR F: FILE): INTEGER;
;         ; in:    HL = address of FIB
;         ; out:   HL = number of records
;         ;        DE = current record
;         ;        BC = record length
;         OFF_HL 0 FIB_NUM
;;         LD DE,FIB_NUM              ; offset to number of records
;;         ADD HL,DE
;         LD E,(HL)                  ; DE = number of records
;         INC HL
;         LD D,(HL)
;         OFF_HL FIB_NUM+1 FIB_REC
;;         INC HL
;         PUSH DE                    ; push number of records
;
;         LD C,(HL)                  ; BC = record length
;         INC HL
;         LD B,(HL)
;         OFF_HL FIB_REC+1 FIB_CUR
;;         INC HL
;
;         LD E,(HL)                  ; DE = current record
;         INC HL
;         LD D,(HL)
;
;         POP HL                     ; HL = number of records
;         RET

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L1A6F
L1A6F:	; LIB
	; PROCEDURE Rewrite(VAR F: FILE);
	; rewrites an untyped file
	DB 3eh,0AFH
	DB 0c3h
	DW  L1A71

	GLOBALS L1A70
L1A70:	; LIB
	; PROCEDURE Reset(VAR F: FILE);
	; resets an untyped file
	DB 0afh

L1A71:   ; in:    HL = record size
         ;        FIB address on stack
	DB 32h
	DW L00E8
         DB 22h
	DW L00E6              ; save record size

         DB 0fdh,0e1h
         DB 0e1h                     ; HL = FIB address
         DB 0fdh,0e5h

	DB 0cdh
	DW  L1AB0		; close an untyped file
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred

	DB 0cdh
	DW  L1430		; open or create file
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred

	DB 02ah
	DW L00E2
	DB 36h,0C0H		; input and output allowed
;         PUSH HL

         OFF_HL 0 DOS_PTR
         DB 36h,0
         DB 23h
         DB 36h,0

         OFF_HL DOS_PTR+1 DOS_BLEN
         DB 36h,128
         DB 23h
         DB 36h,0

         OFF_HL DOS_BLEN+1 DOS_NUM
         DB 0e5h                    ; save position of number of records

         OFF_HL DOS_NUM DOS_FCB
         DB 44h
         DB 4dh
         DB 0cdh
	DW  FILESIZE              ; 33e, L2D22 FileSize ?

         DB 0d5h                    ; push filesize: DE:HL
         DB 0e5h

         DB 02ah
	DW L00E6              ; DE:HL = record size
         DB 11h
	DW 0
         DB 0cdh
	DW  L_DIV
         DB 44h
         DB 4dh

         DB 0e1h                     ; HL = address of DOS_NUM
         DB 71h
         DB 23h
         DB 70h
         DB 23h
         DB 73h
         DB 23h
         DB 72h

         OFF_HL DOS_NUM+3 DOS_REC

         DB 0edh,5bh
	DW L00E6              ; DE = record size
         DB 73h
         DB 23h
         DB 72h

         OFF_HL DOS_REC+1 DOS_CUR
;         XOR A                     ; 33e, TODO error ?
         DB 77h
         DB 23h
         DB 77h
         DB 23h
         DB 77h
         DB 23h
         DB 77h

         DB 0c9h

;         OFF_HL 0 FIB_FCB
;;         LD DE,000CH                ; length of FIB header
;;         ADD HL,DE
;         EX DE,HL
;         LD C,23H                   ; C = get file size
;         CALL MSXDOS
;         POP HL
;
;         OFF_HL 0 FIB_FCB+21H       ; offset to first byte of file size
;;         LD DE,FIB_FCB+21H          ; 002DH, offset to first byte of file pos.
;;         ADD HL,DE
;         XOR A
;         LD C,(HL)                  ; BC = file size and reset file pos.
;         LD (HL),A
;         INC HL
;         LD B,(HL)
;         LD (HL),A
;
;         OFF_HL FIB_FCB+21H+1 FIB_NUM
;;         LD DE,-42
;;         ADD HL,DE
;         LD (HL),C                  ; write file size in FIB_NUM
;         INC HL
;         LD (HL),B
;
;         OFF_HL FIB_NUM+1 FIB_REC
;;         INC HL
;         LD (HL),80H                ; FIB_REC = 128 bytes per record
;         INC HL
;         LD (HL),A
;
;         OFF_HL FIB_REC+1 FIB_CUR
;;         INC HL
;         LD (HL),A                  ; FIB_CUR = 0
;         INC HL
;         LD (HL),A
;         RET
;
	GLOBALS L1AB0
L1AB0:	; LIB
	; PROCEDURE Close(VAR F: FILE);
	; closes an untyped file
	; in:	HL = FIB address
	DB 22h
	DW L00E2		; save FIB address
	DB 7eh
	DB 0e6h, 0C0H 		; input/output allowed ?
	DB 0c8h			; return if not allowed

	DB 0c3h
	DW  L1481 		; close file

	GLOBALS L1ABA
L1ABA:	; PROCEDURE BlockWrite(VAR F: FILE; VAR Dest: Type; Num: INTEGER);
	DB 3eh,22H
	DB 18h,( L1AC0)-$-1

	GLOBALS L1ABE
L1ABE:	; PROCEDURE BlockRead(VAR F: FILE; VAR Dest: Type; Num: INTEGER);
	DB 3eh,21H

L1AC0:	DB 44h			; BC = Num parameter
	DB 4dh
	DB 21h
	DW L00F0		; dummy address for result parameter
	DB 22h
	DW L00E6

         DB 0afh
         DB 32h
	DW L00D0

	DB 0ddh,0e1h			; return address
	DB 0d1h			; DE = destination address
	DB 0e1h			; HL = address of FIB
	DB 0ddh,0e5h			; restore return address

	DB 0c5h			; save Num
	DB 0cdh
	DW  L1AFD		; perform real blockread
	DB 0c1h
         DB 0c0h

	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c0h			; quit if an error occurred

	DB 02ah
	DW L00F0
	DB 0EDH,042h
	DB 0c8h

	DB 3ah
	DW L00E9		; 21H = random read, 22H = random write
	DB 0feh, 21H

;         LD A,99H                   ; IORESULT = 99H, Unexpected end-of-file
         DB 0cah
	DW L18D6

	DB 3eh,0F0H		; IORESULT = 0F0H, Disk write error

L1AE9:	DB 32h
	DW L00D0		; set IORESULT
	DB 0c9h

; 33e, used ????
L20FD:
         DB 0cdh
	DW  L0A1A
         DB 7ch
         DB 0b5h
         DB 0c8h
         DB 0c5h
         DB 0ebh
         DB 44h
         DB 4dh
         DB 21h
	DW 0

L210A:
         DB 09h
         DB 1bh
         DB 7ah
         DB 0b3h
         DB 20h,(L210A)-$-1

         DB 0c1h
         DB 0c9h

L2112:
         DB 0d5h                    ; save FIB address

         OFF_HL 0 DOS_REC

         DB 7eh                  ; HL = record size
         DB 23h
         DB 66h
         DB 6fh

         DB 0d1h

         DB 0c3h
	DW  L20FD

L2121:   DB 0e5h                    ; HL = FIB address

         DB 0d5h

         DB 0ebh
         DB 21h
	DW DOS_FCB
         DB 019h
         DB 0ebh

         DB 0d5h

         DB 50h
         DB 59h

         DB 0cdh
	DW  L2112

         DB 0c1h
         DB 0d1h
         DB 0cdh
	DW  L218B                 ; 33e, TODO L218B

         DB 0ebh

         DB 0e1h                     ; HL = FIB address

         DB 0c0h

         DB 0e5h                    ; HL = FIB address

         DB 01h
	DW 0
         DB 0c5h
         DB 0d5h

         OFF_HL 0 DOS_REC

         DB 5eh                  ; DE = record length
         DB 23h
         DB 56h

         DB 0ebh
         DB 11h
	DW 0

         DB 0cdh
	DW  L_DIV

         DB 44h
         DB 4dh

         DB 0e1h                     ; HL = FIB address

         OFF_HL 0 DOS_CUR

         DB 0c5h
         DB 0e5h

         DB 7eh
         DB 081h
         DB 77h
         DB 23h

         DB 7eh
         DB 088h
         DB 77h
         DB 23h

         DB 7eh
         DB 0ceh,0
         DB 77h
         DB 23h

         DB 7eh
         DB 0ceh,0
         DB 77h

         DB 0d1h

         DB 3ah
	DW L00E9
         DB 0feh, 21H
         DB 28h,(L2188)-$-1

         DB 0ebh

         OFF_HL DOS_CUR DOS_NUM+3

         DB 01h
	DW 4
L2178:
         DB 1ah
         DB 0beh
         DB 38h,(L2188)-$-1
         DB 20h,(L2185)-$-1

         DB 1bh
         DB 2bh
         DB 0dh
         DB 20h,(L2178)-$-1
         DB 18h,( L2188)-$-1

L2185:   DB 0ebh
         DB 0edh,0b8h

L2188:
         DB 0e1h
         DB 0afh
         DB 0c9h

L218B:   DB 3ah
	DW L00E9
         DB 0feh, 21H
         DB 0cah
	DW READFILE              ; 33e, TODO L2D62
         DB 0c3h
	DW  WRITEFILE               ; 33e, TODO L2D8E

; 33e

	GLOBALS L1AED
L1AED:	; PROCEDURE BlockWrite(VAR F: FILE; VAR Dest: Type; Num: INTEGER;
	;		     VAR Result: INTEGER);
	DB 3eh,22H
	DB 18h,( L1AF3)-$-1

	GLOBALS L1AF1
L1AF1:	; PROCEDURE BlockRead(VAR F: FILE; VAR Dest: Type; Num: INTEGER;
	;		    VAR Result: INTEGER);
	DB 3eh,21H

L1AF3:	DB 22h
	DW L00E6		; save address of result parameter
	DB 0ddh,0e1h
	DB 0c1h			; BC = Num parameter
	DB 0d1h			; DE = destination/source address
	DB 0e1h			; HL = FIB address
	DB 0ddh,0e5h

L1AFD:	; in:	HL = FIB address
	;	DE = destination/source address
	;	BC = number of records of 128 bytes to read
	DB 32h
	DW L00E9		; 21H = random read, 22H = random write
         DB 22h
	DW L00E2              ; save FIB address
	DB 7eh
	DB 0e6h, 0C0H 		; read or write flags set ?
	DB 0cah
	DW L18B0		; jump if both are not set, File not open
				; input and/or output allowed

	DB 02ah
	DW L00E6		; HL = address of read record count
	DB 0afh
	DB 77h		; zero records read
	DB 23h
	DB 77h

         DB 02ah
	DW L00E2
         DB 0cdh
	DW  L2121
         DB 0c0h

         DB 0ebh
         DB 02ah
	DW L00E6
         DB 73h
         DB 23h
         DB 72h
         DB 0c9h

; hier ben ik

;L1B10:   LD A,B
;         OR C
;         JR Z,L1B4D                 ; quit if count = 0
;
;         PUSH BC
;         PUSH DE
;
;         LD C,1AH                   ; C = set dma
;         CALL MSXDOS
;         LD HL,(L00E2)
;         OFF_HL 0 FIB_FCB
;;         LD DE,FIB_FCB              ; length of FIB header
;;         ADD HL,DE
;
;         EX DE,HL                   ; DE = address of FIB
;         LD A,(L00E9)               ; random read/write
;         LD C,A
;         CALL MSXDOS
;
;         POP DE
;         POP BC
;         OR A
;         JR NZ,L1B4D                ; jump if error
;
;         PUSH DE
;         LD HL,(L00E2)
;         OFF_HL 0 FIB_FCB+21H
;;         LD DE,FIB_FCB+21H          ; 002DH, offset to first byte of file pos.
;;         ADD HL,DE
;         INC (HL)                   ; increase low byte
;         JR NZ,L1B3C
;         INC HL
;         INC (HL)                   ; increase high byte
;
;L1B3C:   POP DE
;         LD HL,128                  ; next DMA address
;         ADD HL,DE
;         EX DE,HL
;
;         LD HL,(L00E6)              ; increase number of records read
;         INC (HL)                   ; low byte
;         JR NZ,L1B4A
;         INC HL
;         INC (HL)                   ; high byte
;
;L1B4A:   DEC BC                     ; decrease records to go
;         JR L1B10
;
;L1B4D:   LD HL,(L00E2)
;         OFF_HL 0 FIB_FCB+21H
;;         LD DE,FIB_FCB+21H          ; 002DH, offset to first byte of file pos.
;;         ADD HL,DE
;         LD C,(HL)                  ; BC = updated current record in FCB
;         INC HL
;         LD B,(HL)
;
;         OFF_HL FIB_FCB+21H+1 FIB_CUR
;;         LD DE,FIB_CUR-(FIB_FCB+21H+1) ; -38, HL = address of current record
;;         ADD HL,DE
;         LD (HL),C                  ; copy to the FIB current record
;         INC HL
;         LD (HL),B
;
;         OFF_HL FIB_CUR+1 FIB_NUM+1
;;         LD DE,FIB_NUM-FIB_CUR      ; -4, HL = address of number of records
;	 ADD HL,DE
;         LD D,(HL)
;         DEC HL
;         LD E,(HL)
;         EX DE,HL                   ; HL = number of records
;         OR A
;         SBC HL,BC                  ; current record <= number of records ?
;         RET NC                     ; return and don't increase it
;         EX DE,HL
;         LD (HL),C                  ; update to a new number of records
;         INC HL
;         LD (HL),B
;         RET

	GLOBALS L1B6F
L1B6F:   ; SEEK (VAR F: FILE; Pos: INTEGER);
         ; LIB
	; seek untyped file
	; in:	FIB address at stack
         ;        DE:HL = position to seek to
         DB 0ddh,0e1h
         DB 0c1h
         DW 43edh,L00E2              ; save FIB address
         DB 0ddh,0e5h

         DB 0d5h
	DB 0e5h

         DB 0d5h
         DB 0e5h

         DB 0cdh
	DW  L1A5A                 ; FileSize

         DB 0c5h
         DB 0cdh
	DW  L_CMP                 ; Pos > FileSize ?
         DB 0c1h

         DB 38h,(L1B72)-$-1
         DB 20h,(L2212)-$-1

L1B72:
         DB 0d1h
         DB 60h
         DB 69h
         DB 0e3h
         DB 0d5h
         DB 44h
         DB 4dh

         DB 02ah
	DW L00E2              ; HL = FIB address
         OFF_HL 0 DOS_CUR+3

         DB 0d1h
         DB 72h
         DB 2bh
         DB 73h
         DB 2bh
         DB 70h
         DB 2bh
         DB 71h

         DB 21h
	DW 0
         DB 0e3h
         DB 0e5h

         DB 60h
         DB 69h

         DB 0cdh
	DW  L_MUL

         DB 0e5h                    ; save low-word

         DB 02ah
	DW L00E2
         DB 01h
	DW DOS_FCB
         DB 09h
         DB 44h
         DB 4dh

         DB 0e1h                     ; restore low-word

         DB 0cdh
	DW  FILESEEK              ; L2CCD

         DB 0c9h

; 33e 2212
L2212:
         DB 0e1h
         DB 0d1h
         DB 0c3h
	DW  L1A26

;         CALL L1A5A                 ; HL = number of records
;                                    ; DE = current record
;                                    ; BC = record length
;         POP DE
;         OR A
;         SBC HL,DE
;         JP C,L1A26                 ; jump if Seek beyond end-of-file
;
;         LD HL,(L00E2)
;         LD BC,FIB_CUR
;         ADD HL,BC                  ; offset to current record
;         LD (HL),E                  ; set new position
;         INC HL
;         LD (HL),D
;
;         LD BC,FIB_FCB+21H-(FIB_CUR+1); 0024H, address of file position in FCB
;         ADD HL,BC
;         LD (HL),E                  ; set new position in FCB, 128 byte records
;         INC HL
;         LD (HL),D
;         RET

; 33e 2217
	GLOBALS L1B93
L1B93:	; LIB
	; PROCEDURE Erase(VAR F: FILE);
	DB 0cdh
	DW  L1C4C		; check on a logical device
	DB 0c0h			; return if it is a logical device

         OFF_HL 0 DOS_FCB+1         ; address of filename

         DB 0ebh
         DB 0cdh
	DW  DELETEFILE
;	 LD DE,000CH		 ; length of FIB header
;	 ADD HL,DE
;         EX DE,HL
;         LD C,13H                   ; C = file delete
;         CALL MSXDOS
;         INC A
         DB 0c8h                      ; return if no error

         DB 0c3h
	DW  L1BE4                   ; jump if error, File does not exist

; 33e 2229
         GLOBALS RENAMEFILE_LIB
RENAMEFILE_LIB:
         ; PROCEDURE RenameFile(OldName: STRING; NewName: STRING);
         DB 0fdh,0e1h                     ; IY = return address

         DB 02ah
	DW L00D2              ; TEMP address for NewName
         DB 06h,63                    ; maximum string length
         DB 0cdh
	DW  L05E2                 ; pop NewName from stack
         DB 0afh
         DB 12h                  ; make ASCIIZ string
         DB 02ah
	DW L00D2
         DB 11h
	DW 64
         DB 019h
         DB 06h,63                    ; maximum string length
         DB 0cdh
	DW  L05E2                 ; pop OldName from stack
         DB 0afh
         DB 12h                  ; make ASCIIZ string

         DB 0fdh,0e5h                    ; restore return address

         DB 0edh,5bh
	DW L00D2              ; DE = (L00D2)
         DB 21h
	DW 64
         DB 019h                  ; HL = (L00D2) + 64
         DB 23h
         DB 13h
         DB 0ebh                   ; DE = old Drive/path/file ASCIIZ string
                                    ; HL = new filename ASCIIZ string
         DB 0c3h
	DW  RENAMEFILE

; 33e 2253
	GLOBALS L1BA5
L1BA5:	; LIB
	; rename(var F: file; Name: string);
	DB 0fdh,0e1h			; IY = return address
         DB 02ah
	DW L00D2              ; HL = destination address of string
         DB 06h,63                    ; maximum of 63 bytes
         DB 0cdh
	DW  L05E2                 ; LIB, pop string from stack
	DB 0afh
	DB 12h		; zero byte direct after string

	DB 0e1h			; HL = FIB address
	DB 0fdh,0e5h			; restore return address

	DB 0cdh
	DW  L1C4C		; check on a logical device
	DB 0c0h			; return if it is a logical device

         OFF_HL 0 DOS_FCB+1         ; HL = address of filename in handle/FCB
         DB 0ebh                   ; DE = address of old filename

         DB 02ah
	DW L00D2
         DB 23h                     ; HL = address of new filename

         DB 0cdh
	DW  RENAMEFILE
         DB 0c8h                      ; quit if succeeded

         DB 0c3h
	DW  L1BE4                   ; set IORESULT = 1

;         PUSH HL
;
;         CALL L03F2                 ; parse filename at address in L00D2 without
;                                    ; wildcards to FCB at L005C
;
;         POP HL
;         PUSH HL
;         OFF_HL 0 FIB_FCB+16        ; fill second half of FCB with new name
;;         LD DE,001CH
;;         ADD HL,DE
;         EX DE,HL
;         LD HL,L005C
;         LD BC,12                   ; drive, name and extension
;         LDIR                       ; copy new name to second half at FIB_FCB
;         POP HL
;         OFF_HL 0 FIB_FCB
;;         LD DE,FIB_FCB              ; offset to FCB
;;         ADD HL,DE
;         PUSH HL
;
;         EX DE,HL
;         LD C,17H                   ; C = file rename
;         CALL MSXDOS
;         POP DE
;         INC A
;         JR Z,L1BE4                 ; jump if error, File does not exist
;
;         LD HL,L005C
;         LD BC,FCB_LEN
;         LDIR                       ; copy FCB with new name to FIB_FCB address
;         RET

; 33e, 2278

L1BE4:	DB 3eh,1			; IORESULT = 1, File does not exist

L1BE6:	DB 32h
	DW L00D0
	DB 0c9h

	GLOBALS L1BEA
L1BEA:	; PROCEDURE Execute(VAR F: FILE);
	DB 3eh,0AFH		; LIB, LD A,XOR A
	DB 18h,( L1BEC)-$-1

	GLOBALS L1BEB
L1BEB:	; PROCEDURE Chain(F: FILE);
	DB 0afh			; LIB

L1BEC:	DB 32h
	DW L00E8		; 0 = Chain, NonZero = Execute

	DB 0cdh
	DW  L1C4C		; check on a logical device
	DB 0c0h			; return if it is a logical device

;         LD A,(L00D8)               ; running from compiler memory mode ?
;         OR A
;         LD A,21H                   ; IORESULT = 21H, Not Allowed in direct mode
;         JR Z,L1BE6

	DB 02ah
	DW L00E2
         OFF_HL 0 DOS_FCB+1

         DB 0edh,5bh
	DW L00D2
         DB 3eh,' '
         DB 01h
	DW ' '*256 + ' '
         DB 0cdh
	DW  OPENFILE
         DB 0c2h
	DW L1BE4                ; IORESULT = 1, File does not exist

         DB 44h
         DB 4dh
         DB 0cdh
	DW  FILESIZE

         DB 11h
	DW L0100
         DB 3ah
	DW L00E8
         DB 0b7h
         DB 20h,(L1C2D)-$-1                ; nonzero, do Execute
         DB 0edh,5bh
	DW L0101

L1C2D:
         DB 0cdh
	DW  READFILE

;;         LD DE,FIB_FCB              ; length of FIB header
;;         ADD HL,DE
;         LD DE,005CH                ; !!!
;         LD BC,FCB_LEN              ; 37 bytes for a FCB !!!
;         LDIR
;         XOR A
;         LD (DE),A                  ; reset 4th byte of file position
;         LD DE,005CH                ; !!!
;         LD C,0FH                   ; C = file open
;         CALL MSXDOS
;         INC A
;         JR Z,L1BE4                 ; jump if error, File does not exist
;IFDEF MSX
;         LD HL,1
;         LD (006AH),HL              ; FCB + 14 = record size
;ENDIF
;         LD HL,L1C33
;         LD DE,00B0H                ; load code at some neutral address
;                                    ; at least outside the program
;                                    ; AUXINPTR+1
;         LD BC,L1C33_A-L1C33        ; maximum of 100H-0B0H bytes !!!
;         LDIR
;
;         LD DE,L0100                ; assume load from 100H, Execute
;         LD A,(L00E8)
;         OR A
;         JR NZ,L1C2D                ; jump if Execute
;
;; L22B0
;         LD DE,(L0101)              ; load direct after runtime library
;
;L1C2D:
         DB 31h
	DW L0100
IFDEF MSX
         DB 0c3h
	DW  L0100
;         JP 00B0H                   ; some address outside the running program
				; AUXINPTR+1	        ; ???
ENDIF

L1C33:	DB 0d5h
	DB 0eh,1AH 		; C = set dma
	DB 0cdh
	DW  MSXDOS

IFDEF MSX
	DB 02ah
	DW 006CH		; HL = file length, read the complete file
ENDIF
	DB 11h
	DW 005CH		; !!!
	DB 0eh,27H
	DB 0cdh
	DW  MSXDOS

;	 LD DE,L005C
;	 LD C,14H		 ; C = sequential read
;	 CALL MSXDOS
;	 POP DE
;	 LD HL,0080H
;	 ADD HL,DE
;	 EX DE,HL
;	 OR A
;	 JR Z,L1C33
IFDEF MSX
	DB 0c3h
	DW  100H
ENDIF
L1C33_A:

; 33e 22D1
L1C4C:	DB 22h
	DW L00E2		; save address of FIB
	DB 7eh
	DB 0e6h, 0FH			; a logical device ?
	DB 0c8h			; quit if not a logical device

         DB 3eh,0C1H
         DB 32h
	DW ERRORNUMBER         ; 33e, TODO 2BA3
	DB 3eh,20H
	DB 32h
	DW L00D0		; IORESULT = 20H, Operation not allowed on
				; a logical device
	DB 0c9h

;         GLOBALS L1C59
;L1C59:   LD A,255                   ; OverlayLoadOnly = TRUE
;         JP RUNOVERLAY

OVERLAYCOMPAREID:
         ; in:    HL = address of low-byte of ID in info-block
         ;        BC:DE = position to compare it with
         ; out:   HL = address of low-byte of ID in info-block (unchanged)
         ;        NonZero if not equal
         ;        Zero if equal
; 33e 22E3
         ; new position equals current position ?
         DB 0e5h

         DB 7eh
         DB 0b9h                       ; byte 0
         DB 20h,(OVERLAYCOMPAREIDEND)-$-1  ; quit if not equal

         DB 23h
         DB 7eh
         DB 0b8h                       ; byte 1
         DB 20h,(OVERLAYCOMPAREIDEND)-$-1  ; jump if not equal

         DB 23h
         DB 7eh
         DB 0bbh                       ; byte 2
         DB 20h,(OVERLAYCOMPAREIDEND)-$-1  ; jump if not equal

         DB 23h
         DB 7eh
         DB 0bah                       ; byte 3
         DB 28h,(OVERLAYCOMPAREIDEND)-$-1   ; jump if equal, run the program

OVERLAYCOMPAREIDEND:
         DB 0e1h
         DB 0c9h

OVERLAYSAVEPARAMS:
         DW 43edh,OVERLAYDATALEN     ; save length

         DB 22h
	DW OVERLAYPOS         ; save low-word of position
         DW 53edh,OVERLAYPOS+2       ; save high-word of position
         DB 0c9h

         GLOBALS OVERLAYREC1
OVERLAYREC1:
         DB 0e5h                    ; save address of overlay-info block

         DB 11h
	DW OVERLAYPOS           ; destination address
         DB 01h
	DW 6                    ; restore 6 bytes from heap
         DB 0cdh
	DW  L0522                 ; heap de-alloc

         DB 0e1h                     ; HL = address of overlay-info block

         DB 22h
	DW OVERLAYINFOADDRESS

         DB 0d1h
         DW 53edh,L00E2              ; save return address
         DB 0d5h

         DB 0edh,4bh
	DW OVERLAYPOS
         DB 0edh,5bh
	DW OVERLAYPOS+2

         DB 0d9h
         DB 0c5h
         DB 0d5h
         DB 0e5h
         DB 0d9h

         DB 3eh,255                   ; OverlayLoadOnly = TRUE
         DB 0cdh
	DW  LOADORRUNOVERLAY

         DB 0d9h
         DB 0e1h
         DB 0d1h
         DB 0c1h

         DB 0c9h

; 33e 2330
         GLOBALS LOADRUNOVERLAYREC
LOADRUNOVERLAYREC:
         ; recursive overlay loader and runner

         DB 0d9h

         DB 01h
	DW 6                    ; save 6 bytes on heap
         DB 0e1h                     ; HL = address of position in
                                    ;      overlay-info block
         DB 22h
	DW L00E2              ; save address if an error would occur
         DB 0e5h
         DB 0cdh
	DW  L0508                 ; heap alloc

         DB 0d9h

;         GLOBALS L1C59
;L1C59:
         GLOBALS LOADRUNOVERLAY
LOADRUNOVERLAY:
         ; non-recursive overlay loader and runner

         ; in:    DEHL = position in file to read from
         ;        BC = length in bytes to read from file

         DB 0afh                      ; OverlayLoadOnly = FALSE

         DB 0cdh
	DW  OVERLAYSAVEPARAMS

         DB 44h                     ; BC = HL = low-word position
         DB 4dh

         DB 0e1h
         DB 22h
	DW L00E2              ; save address of overlay-info block
         DB 22h
	DW OVERLAYINFOADDRESS

LOADORRUNOVERLAY:
         ; in:    DEBC = position in file to read from
         ;        HL = address of overlay-info block

         DB 0cbh,07ah                    ; negative position ?
         DB 0c0h                     ; quit if negative

         DB 32h
	DW OVERLAYLOADONLY     ; 0 = FALSE, NonZero = TRUE

         DB 0e5h
         DB 0d9h
         DB 0e1h
         DB 01h
	DW 21
         DB 09h
         DB 0d9h

         DB 7ah
         DB 0feh, 40H

         DB 0d9h
         DB 28h,(RUNOVERLAY_PROGRAM1)-$-1
         DB 0d9h

         DB 0cdh
	DW  OVERLAYCOMPAREID

         DB 3ah
	DW OVERLAYLOADONLY

         DB 28h,(RUNOVERLAY_PROGRAM)-$-1    ; jump if equal, run the program

         DB 71h
         DB 23h
         DB 70h
         DB 23h
         DB 73h
         DB 23h
         DB 72h
         DB 23h                     ; HL = address of overlay data length

         DB 3ah
	DW OVERLAYLOADONLY
         DB 0f5h
         DB 0d9h
         DB 0e5h

         DB 0e5h                    ; push Address of data
         DB 0d9h

         DB 0d5h                    ; push high-word first
         DB 0c5h                    ; push low-word second
                                    ; Position pushed

         DB 0edh,5bh
	DW OVERLAYDATALEN
         DB 73h
         DB 23h
         DB 72h
         DB 23h                     ; HL = address of overlay number
         DB 0d5h                    ; DataLen pushed

         DB 7eh
         DB 23h
         DB 06h,0
         DB 4fh
         DB 0c5h                    ; save overlay number

         DB 0e5h                    ; save adress of file name string as
                                    ; var string
         DB 23h                     ; HL = address of ASCIIZ-string

         DB 0cdh
	DW  OVERLAYLOAD

         DB 0e1h                     ; run address for overlay code

         DB 0f1h                     ; OverlayLoadOnly flag


RUNOVERLAY_PROGRAM:

         DB 0b7h
         DB 0c0h                     ; quit if it should not be executed

; 33e 2391
RUNOVERLAY_PROGRAM1:

;L1CCA:
         ; run the overlay program
;         LD HL,(OverlayInfoAddress)
;         LD DE,21 ; 19 ; 17 ; 13
;         ADD HL,DE
	DB 0e9h

OVERLAYLOAD:

         GLOBALS OVERLAYLOADPTR
OVERLAYLOADPTR:
         DB 0c3h
	DW  OVERLAYLOADDEFAULT

OVERLAYLOADDEFAULT:
         ; (Address: INTEGER; DataLength: INTEGER; FilePos: LONGINT;
         ;  OverlayNumber: BYTE; VAR Name: STRING);

;         ; in:    HL = address of ASCIIZ-string (filename)

         ; overlay drive/path must be added if DOS 2
         ; overlay drive name must be added if DOS 1

         DB 0d1h                     ; DE = return address

         DB 0e1h                     ; HL = VAR STRING
         DB 23h

         DB 0d5h                    ; restore return address

         DB 11h
	DW L005C                ; address of 64 byte buffer
         DB 3eh,' '                   ; default extension of '   '
         DB 47h
         DB 4fh
         DB 0cdh
	DW  OPENFILE
         DB 0c2h
	DW L1CD2                ; jump: Overlay file not found

         DB 44h                     ; BC = handle/FCB address
         DB 4dh

         DB 0d1h                     ; DE = return address

         DB 0e1h                     ; remove OverlayNumber

         DB 0e1h
         DB 22h
	DW OVERLAYDATALEN     ; save OverlayDataLen

         DB 0ebh
         DB 0d1h                     ; DE = low-word of Position
         DB 0e3h                 ; push return address
                                    ; pop high-word in HL
         DB 0ebh                   ; DE:HL = position

;         LD HL,(OVERLAYPOS)
;         LD DE,(OVERLAYPOS+2)
         DB 0cdh
	DW  FILESEEK              ; set new file position

         DB 0e1h                     ; HL = return address
         DB 0d1h                     ; DE = Address of data
         DB 0e5h                    ; restore return address


;         LD HL,(OverlayInfoAddress) ; HL = address of overlay-info block
;         LD DE,2+2+2+2+13           ; length of overlay-info block
;         ADD HL,DE
;         EX DE,HL                   ; DE = destination address for overlay code
         DB 02ah
	DW OVERLAYDATALEN     ; HL = length in bytes

         ; BC = handle/FCB address
         DB 0cdh
	DW  READFILE
;        JP NZ,$$$$                 ; jump if error reading overlay file

         ; BC = handle/FCB address
         DB 0c3h
	DW  CLOSEFILE               ; Close the File

L1CD2:   DB 0ddh,02ah
	DW L00E2              ; IX = runtime error address
	DB 3eh,0F0H		; r.error 0F0H: Overlay file not found
	DB 0c3h
	DW  L2029

	GLOBALS L1CDB
L1CDB:   ; PROCEDURE OvrDrive(Drive: INTEGER);
         DB 0cdh
	DW  L04C8                 ; LIB, int to byte
	DB 0feh, 11H
	DB 0d0h
         DB 32h
	DW L00DC               ; set new overlay drive
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

; 33e 23D4
	GLOBALS L1CE5
L1CE5:   ; PROCEDURE New(VAR P: POINTER);
         ; in:    HL = size
         DB 22h
	DW L00F0              ; LIB
         DB 0ebh                   ; DE = size

         DB 0e1h                     ; HL = return address
	DB 0e3h

         ; HL = pointer address
         ; return address on stack
         DB 22h
	DW L00F2
	DB 13h
	DB 13h
	DB 13h
	DB 7bh
	DB 0e6h, 0FCH
	DB 5fh
	DB 21h
	DW L00DE
	DB 22h
	DW L00F8
	DB 0ddh,02ah
	DW L00DE
L1CFF:	DB 0ddh,6eh,+2
	DB 0ddh,66h,+3
	DB 7dh
	DB 0b4h
	DB 28h,(L1D51)-$-1
	DB 0EDH,052h
	DB 30h,(L1D1C)-$-1
	DB 0ddh,6eh,+0
	DB 0ddh,66h,+1
	DB 0e5h
	DW 22ddh,L00F8
	DB 0ddh,0e1h
	DB 18h,( L1CFF)-$-1

L1D1C:	DB 20h,(L1D28)-$-1
	DB 0ddh,5eh,+0
	DB 0ddh,56h,+1
	DB 0ddh,0e5h
	DB 18h,( L1D43)-$-1

L1D28:	DB 4dh
	DB 44h
	DB 0ddh,6eh,+0
	DB 0ddh,66h,+1
L1D30:	DB 0ddh,0e5h
	DB 0ddh,019h
	DB 0ddh,75h,+0
	DB 0ddh,74h,+1
	DB 0ddh,71h,+2
	DB 0ddh,70h,+3
	DB 0ddh,0e5h
	DB 0d1h
L1D43:	DB 02ah
	DW L00F8
	DB 73h
	DB 23h
	DB 72h
	DB 0d1h
	DB 02ah
	DW L00F2
	DB 73h
	DB 23h
	DB 72h
	DB 0c9h

L1D51:	DB 0ddh,0e5h
	DB 0e1h
	DB 019h
	DB 22h
	DW HEAPPTR
	DB 02ah
	DW L00F0
	DB 01h
	DW 0004
	DB 09h
	DB 0ddh,0e5h
	DB 0c1h
	DB 09h
	DB 0dah
	DW L1D75
	DB 0edh,4bh
	DW RECURPTR
	DB 0EDH,042h
	DB 01h
	DW 0000
	DB 21h
	DW 0000
	DB 0dah
	DW L1D30

L1D75:	DB 3eh,0FFH		; r.error 0FFH: Heap/stack collision
	DB 0c3h
	DW  L2027 		; Run-time error

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L1D7A
L1D7A:	DB 0ebh 		; LIB
	DB 0e1h
	DB 0e3h
	DB 7eh
	DB 23h
	DB 66h
	DB 6fh
	DB 13h
	DB 13h
	DB 13h
	DB 7bh
	DB 0e6h, 0FCH
	DB 5fh
	DB 0ebh
	DB 22h
	DW L00F0
	DB 02ah
	DW L00DE
	DB 0e5h
	DB 0ddh,0e1h
	DB 0b7h
	DB 0EDH,052h
	DB 30h,(L1DE9)-$-1

L1D97:	DB 0ddh,6eh,+0
	DB 0ddh,66h,+1
	DB 0e5h
	DB 0b7h
	DB 0EDH,052h
	DB 30h,(L1DA7)-$-1
	DB 0ddh,0e1h
	DB 18h,( L1D97)-$-1

L1DA7:	DB 0e1h
	DB 0d5h
	DB 0fdh,0e1h
	DB 0edh,4bh
	DW L00F0
	DB 0fdh,71h,+2
	DB 0fdh,70h,+3
	DB 0fdh,75h,+0
	DB 0fdh,74h,+1
	DB 0ddh,73h,+0
	DB 0ddh,72h,+1
	DB 0ddh,0e5h
	DB 0e1h
	DB 0ddh,4eh,+2
	DB 0ddh,46h,+3
	DB 0cdh
	DW  L1E04
	DB 28h,(L1DD8)-$-1
	DB 0ddh,5eh,+0
	DB 0ddh,56h,+1
	DB 0d5h
	DB 0ddh,0e1h

L1DD8:	DB 0ddh,0e5h
	DB 0e1h
	DB 0ddh,4eh,+2
	DB 0ddh,46h,+3
	DB 0ddh,5eh,+0
	DB 0ddh,56h,+1
	DB 18h,( L1E04)-$-1

L1DE9:	DB 02ah
	DW L00DE		; ----
	DW 53edh,L00DE
	DB 0d5h
	DB 0ddh,0e1h
	DB 0ddh,75h,+0
	DB 0ddh,74h,+1
	DB 0edh,4bh
	DW L00F0
	DB 0ddh,71h,+2
	DB 0ddh,70h,+3
	DB 0ebh

L1E04:	DB 09h
	DB 0b7h
	DB 0EDH,052h
	DB 0c0h
	DB 0d5h
	DB 0fdh,0e1h
	DB 02ah
	DW HEAPPTR
	DB 0b7h
	DB 0EDH,052h
	DB 28h,(L1E2F)-$-1
	DB 0fdh,7eh,+0
	DB 0ddh,77h,+0
	DB 0fdh,7eh,+1
	DB 0ddh,77h,+1
	DB 0fdh,6eh,+2
	DB 0fdh,66h,+3
	DB 09h
	DB 0ddh,75h,+2
	DB 0ddh,74h,+3
	DB 0afh
	DB 0c9h

L1E2F:	DB 0ddh,0e5h
	DB 0e1h
	DB 22h
	DW HEAPPTR
	DB 06h,4
L1E37:	DB 36h,0
	DB 23h
	DB 10h,( L1E37)-$-1
	DB 0c9h

ENDIF	; USELIB



IFDEF USELIB

	GLOBALS L1E3D
L1E3D:	; FUNCTION MemAvail: INTEGER;
	DB 0cdh
	DW  L1E4B		; LIB
	DB 02ah
	DW L00F4		; return MemAvail
	DB 0c9h

	GLOBALS L1E44
L1E44:	; FUNCTION MaxAvail: INTEGER;
	DB 0cdh
	DW  L1E4B		; LIB
	DB 02ah
	DW L00F6		; return MaxAvail
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

L1E4B:	; info for: MemAvail, MaxAvail
	DB 21h
	DW 0000
	DB 22h
	DW L00F4		; MemAvail = 0
	DB 22h
	DW L00F6		; MaxAvail = 0

	DB 0ddh,02ah
	DW L00DE
L1E58:	DB 0ddh,4eh,+2
	DB 0ddh,46h,+3
	DB 79h
	DB 0b0h
	DB 28h,(L1E80)-$-1

	DB 02ah
	DW L00F4		; MemAvail += BC
	DB 09h
	DB 22h
	DW L00F4

	DB 02ah
	DW L00F6		; MaxAvail
	DB 0b7h
	DB 0EDH,042h
	DB 30h,(L1E75)-$-1
	DW 43edh,L00F6

L1E75:	DB 0ddh,6eh,+0		; get pointer to next Block
	DB 0ddh,66h,+1
	DB 0e5h
	DB 0ddh,0e1h
	DB 18h,( L1E58)-$-1

L1E80:	DB 02ah
	DW RECURPTR
	DB 01h
	DW -5
	DB 09h
	DB 0edh,5bh
	DW HEAPPTR
	DB 0b7h
	DB 0EDH,052h
	DB 0d8h
	DB 0ebh
	DB 02ah
	DW L00F4		; MemAvail += DE
	DB 019h
	DB 22h
	DW L00F4
	DB 02ah
	DW L00F6		; MaxAvail
	DB 0b7h
	DB 0EDH,052h
	DB 0d0h
	DW 53edh,L00F6
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L1EA3
L1EA3:	DB 0edh,5bh
	DW HEAPPTR		; LIB
	DB 73h
	DB 23h
	DB 72h
	DB 0c9h

	GLOBALS L1EAB
L1EAB:	DB 5eh		; LIB
	DB 23h
	DB 56h
	DB 0ebh

L1EAF:	DB 22h
	DW HEAPPTR
	DB 22h
	DW L00DE
	DB 06h,4			; clear top 4 bytes of new HEAPPTR
L1EB7:	DB 36h,0
	DB 23h
	DB 10h,( L1EB7)-$-1
	DB 0c9h

         GLOBALS L1EBC
L1EBC:   ; LIB, print LONG
         DB 3eh,2
         DB 18h,( L1EBF)-$-1

         GLOBALS L1EBD
L1EBD:   ; LIB, print REAL
         DB 3eh,1
	DB 18h,( L1EBF)-$-1

	GLOBALS L1EBE
L1EBE:   ; LIB, print INTEGER
	DB 0afh			; LIB

L1EBF:   DB 4fh
	DB 22h
	DW L00E8
	DB 0afh
	DB 77h
	DB 32h
	DW L00D0		; reset IORESULT
	DB 78h
         DB 32h
	DW L00EA               ; save destination string length
	DB 02ah
	DW L00E2		; HL = current device pointer
	DB 22h
	DW L00ED		; save old device pointer
	DB 21h
	DW L1F46		; device 6
	DB 22h
	DW L00E2
	DB 0e1h
	DB 22h
	DW L00E4
	DB 0e1h

         DB 0dh                      ; REAL ?
         DB 28h,(L1EE6)-$-1                 ; jump to print REAL

         DB 0dh                      ; LONG ?
         DB 28h,(L1EE5)-$-1                 ; jump to print LONG

         DB 0cdh
	DW  L1726                 ; print INTEGER
	DB 18h,( L1EE9)-$-1 		; restore device and continue
				; add saved return address

L1EE5:   DB 0cdh
	DW  PRT_LONG
         DB 18h,( L1EE9)-$-1

L1EE6:	DB 0cdh
	DW  L1779		; call print REAL

L1EE9:	; restore to old device
	; and jumps to address in L00E4
	DB 02ah
	DW L00ED		; HL = old device pointer
	DB 22h
	DW L00E2		; restore to old device

	DB 02ah
	DW L00E4		; HL = return address
	DB 0e9h			; continue

	GLOBALS L1EF2
L1EF2:	; val(S: string; var L: longint; var P: integer);
	DB 3eh,2			; LIB, ascii to LONGINT
	DB 18h,( L1EF5)-$-1

	GLOBALS L1EF3
L1EF3:	; val(S: string; var R: real; var P: integer);
	DB 3eh,1			; LIB, ascii to REAL
	DB 18h,( L1EF5)-$-1

	GLOBALS L1EF4
L1EF4:	; val(S: string; var I,P: integer);
	DB 0afh			; LIB, ascii to INTEGER

L1EF5:	DB 32h
	DW L00EC		; flag for conversion
				; 0 = to INTEGER
				; 1 = to REAL
				; 2 = to LONGINT
	DB 22h
	DW L00E8		; save optional address P

	DB 02ah
	DW L00E2		; HL = current device pointer
	DB 22h
	DW L00ED		; save old device pointer
	DB 21h
	DW L1F46		; device 6
	DB 22h
	DW L00E2

	DB 0e1h
	DB 22h
	DW L00E4		; save return address

	DB 0e1h
	DB 22h
	DW L00EA		; save address resulting REAL,
				; INTEGER, BYTE or LONGINT

	DB 21h
	DW L005C		; HL = destination address of string
	DB 06h,1EH 		; maximum of 30 bytes
	DB 0cdh
	DW  L05E2		; LIB, pop string from stack
	DB 0afh
	DB 12h		; end string with a '\0'

	DB 02ah
	DW L00EA		; destination address for real / integer

	DB 3ah
	DW L00EC		; conversion flag
	DB 0b7h
	DB 28h,(L1F26)-$-1		; jump if conversion to INTEGER
	DB 3dh
	DB 28h,(L1F27)-$-1		; jump if conversion to REAL

	DB 0cdh
	DW  L1671		; conversion to LONGINT
	DB 18h,( L1F2A)-$-1

L1F26:	DB 0cdh
	DW  L164E		; conversion to INTEGER
	DB 18h,( L1F2A)-$-1

L1F27:	DB 0cdh
	DW  L1672		; conversion to REAL

L1F2A:	; IX = last read character or position of the error
	DB 21h
	DW L00D0
	DB 7eh		; read IORESULT
	DB 36h,0		; reset IORESULT
	DB 0b7h
	DB 67h			; HL = 0
	DB 6fh
	DB 28h,(L1F3D)-$-1		; jump if no error occurred

	; watch it!, stil NonCarry
	DB 0ddh,0e5h
	DB 0e1h
	DB 11h
	DW L005D-1
	DB 0EDH,052h		; calculate position of the error

L1F3D:	DB 0ebh
	DB 02ah
	DW L00E8		; HL = address of error position
	DB 73h		; save position
	DB 23h
	DB 72h

	DB 18h,( L1EE9)-$-1 		; restore device and continue
				; add saved return address

L1F46:	DB 0C6H,0		; device 6

	GLOBALS L1F48
L1F48:	; randomize
	DB 0edh,5fh
	DB 32h
	DW L00CB		; random waarde ?
	DB 0c9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L1F4E
L1F4E:	DB 0ebh 		; LIB
	DB 0ddh,0e1h
	DB 0c1h
	DB 0e1h
	DB 78h
	DB 0b1h
	DB 28h,(L1F62)-$-1
	DB 73h
	DB 0bh
	DB 78h
	DB 0b1h
	DB 28h,(L1F62)-$-1
	DB 54h
	DB 5dh
	DB 13h
L1F60:	DB 0edh,0b0h
L1F62:	DB 0ddh,0e9h

	GLOBALS L1F64
L1F64:	; LIB
	DB 44h			; LIB
	DB 4dh
	DB 0ddh,0e1h
	DB 0d1h
	DB 0e1h
	DB 78h
	DB 0b1h
	DB 28h,(L1F62)-$-1
	DB 0EDH,052h
	DB 019h
	DB 30h,(L1F60)-$-1
	DB 0bh
	DB 09h
	DB 0ebh
	DB 09h
	DB 0ebh
	DB 03h
	DB 0edh,0b8h
	DB 0ddh,0e9h

ENDIF	; USELIB


IFDEF USELIB

	GLOBALS L1F7D
L1F7D:	; FUNCTION ParamStr(N: INTEGER): STRING;
	DB 55h			; LIB
	DB 14h
	DB 15h
	DB 28h,(L1F85)-$-1
	DB 0cdh
	DW  L1F9D

L1F85:	DB 0ddh,0e1h
	DB 4fh
	DB 06h,0
	DB 2fh
	DB 6fh
	DB 26h,0FFH
	DB 039h
	DB 0f9h
	DB 71h
	DB 23h
	DB 0ebh
	DB 0ch
	DB 0dh
	DB 28h,(L1F99)-$-1
	DB 0edh,0b0h
L1F99:	DB 0ddh,0e9h

	GLOBALS L1F9B
L1F9B:	; FUNCTION ParamCount: INTEGER;
	DB 16h,0			; LIB

L1F9D:   DB 21h
	DW L0080
	DB 3eh,1FH
	DB 46h
	DB 0b8h
	DB 30h,(L1FA8)-$-1
	DB 06h,1FH
L1FA8:	DB 23h
	DB 0eh,0

L1FAB:	DB 04h
	DB 05h
	DB 28h,(L1FBC)-$-1
	DB 7eh
	DB 0feh, 20H
	DB 28h,(L1FB8)-$-1
	DB 0feh, 9
	DB 20h,(L1FBC)-$-1
L1FB8:	DB 23h
	DB 05h
	DB 18h,( L1FAB)-$-1

L1FBC:	DB 5dh
L1FBD:	DB 04h
	DB 05h
	DB 28h,(L1FCE)-$-1
	DB 7eh
	DB 0feh, 20H
	DB 28h,(L1FCE)-$-1
	DB 0feh, 9
	DB 28h,(L1FCE)-$-1
	DB 23h
	DB 05h
	DB 18h,( L1FBD)-$-1

L1FCE:	DB 7dh
	DB 093h
	DB 28h,(L1FD6)-$-1
	DB 0ch
	DB 15h
	DB 20h,(L1FAB)-$-1
L1FD6:	DB 69h
	DB 26h,0
	DB 54h
	DB 0c9h

ENDIF	; USELIB


	GLOBALS L1FDB
L1FDB:	; LIB
	; in:	X pushed on stack
	;	L = Y
	DB 0d1h			; gotoxy(x,y)
	DB 0c1h			; C = Y
	DB 0d5h
	DB 2dh			; L = X - 1
	DB 61h
	DB 25h			; H = Y - 1
	DB 0c3h
	DW  L02A2


IFDEF USELIB

	GLOBALS L1FE4
L1FE4:	DB 7dh			; LIB
	DB 0cdh
	DW  L04A6		; upcase
	DB 6fh
	DB 0c9h

	GLOBALS L1FEA
L1FEA:	DB 02ah
	DW 0001		; LIB
	DB 019h
	DB 019h
	DB 019h
	DB 0e9h

	GLOBALS L1FF1
L1FF1:	; FUNCTION IOresult: BYTE; ; LIB
	DB 21h
	DW L00D0		; HL = address of IORESULT value
	DB 7eh
	DB 36h,0

L1FF2:
         DB 6fh
	DB 26h,0
	DB 0c9h

         GLOBALS GETERROR_LIB
GETERROR_LIB:
         DB 0afh
         DB 32h
	DW L00D0
         DB 0c3h
	DW  GETERROR
;         INC L
;         DEC L
;         RET NZ                     ; quit with error if there was one
;
;         LD A,(GIOSOK)
;         OR A
;         RET Z                      ; quit if GIOS not present
;                                    ; and return 0 for no error
;
;         LD A,75
;         JP RUNGIOS                 ; call GIOS function 75 (GetError)

ENDIF	; USELIB


IFDEF USELIB

	; LIB, CBREAK handler
L1FFB:	DB 0cdh
	DW  L0316		; keypressed
	DB 7ch
	DB 0b5h
	DB 0c8h			; quit if not
	DB 3ah
	DW CBREAK
	DB 0f5h			; save previous CBREAK
	DB 0afh
	DB 32h
	DW CBREAK
	DB 0cdh
	DW  L0320		; read character with CBREAK off
	DB 0f1h
	DB 32h
	DW CBREAK		; restore CBREAK

	DB 7dh
	DB 0feh, 3
	DB 0c0h			; quit if CBREAK not pressed

	DB 0ddh,0e1h			; IX = return address

ENDIF	; USELIB


L2016:	DB 11h
	DW 0001		; user break, D = 0 with error code = 1
	DB 18h,( L202C)-$-1

	GLOBALS L201B
L201B:	; I/O error
	DB 3ah
	DW L00D0		; read IORESULT
	DB 0b7h
	DB 0c8h			; quit if no error
	DB 0ddh,0e1h
	DB 5fh			; E = IORESULT error code
	DB 16h,1			; I/O error
	DB 18h,( L202C)-$-1

L201C:   ; error: 0AAH throug 0AEH
         DB 3eh,0AAH
L201D    EQU $-1

L2027:   ; Run-time error
         DB 0ddh,0e1h                     ; return address of original call

L2029:	DB 5fh			; E = error code
	DB 16h,2			; Run-time rror

L202C:	; in:	D = 0, user break
	;	D = 1, I/O error, E = error number
	;	D = 2, Run-time error	E = error number
         ;        IX = return address of original call

	DB 0afh
         DB 32h
	DW CBREAK

         DB 0ddh,0e5h
         DB 0e1h

         DB 3ah
	DW ERROREXITOK
         DB 0b7h
         DB 0c2h
	DW ERRORHANDLERRETURN

         DB 22h
	DW L00CE
         DW 73edh,ERRORSTACK

         DB 0d5h                    ; save error type and code

	DB 0d5h
         DB 0e5h                    ; address where error occurred
         DB 0cdh
	DW  ERRORPTR              ; ErrorHandler(DE = type, HL = address)

         DB 0d1h                     ; restore error type and code

L2054:	DB 7ah
	DB 0b7h
	DB 20h,(L206C)-$-1
	DB 0cdh
	DW  L0200		; D = 0 >> User Break
	DB '^C',0DH,0AH
	DB 'User break',0
	DB 18h,( L2097)-$-1

L206C:	DB 3dh
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

L2097:   DB 0d5h
         DB 0cdh
	DW  L0200
	DB ', PC=',0
         DB 02ah
	DW L00CE
	DB 0cdh
	DW  L04AF
         DB 0d1h

IFDEF MESSAGESFORTILBURG
         DB 7bh
         DB 0feh, 0AAH
         DB 38h,(L20BD)-$-1                 ; jump if < 0AAH
         DB 0feh, 0AEH+1
         DB 30h,(L20BD)-$-1                ; jump if > 0AEH

         DB 0cdh
	DW  L0200
         DB 13,10,0

         DB 21h
	DW GIOSMESSAGES
         DB 0d6h, 0AAH - 1
         DB 47h                     ; 1 = 0AAH, 2 = 0ABH etc.

GIOSMESSAGELOOP:
         DB 05h
         DB 28h,(GIOSMESSAGEFOUND)-$-1

GIOSMESSAGESCAN:
         DB 7eh
         DB 23h

         DB 0b7h
         DB 20h,(GIOSMESSAGESCAN)-$-1

         DB 18h,( GIOSMESSAGELOOP)-$-1

GIOSMESSAGEFOUND:
         ; Do something
         DB 0cdh
	DW  L01D0

ENDIF    ; MessagesForTilburg

         DB 18h,( L20BD)-$-1

L20A8:   DB 0cdh
	DW  L0200
	DB 'Not enough memory',0

L20BD:   DB 0cdh
	DW  L0200
	DB 0DH,0AH,'Program aborted',0DH,0AH,0

	GLOBALS L20D4
L20D4:
;         CALL GotoTextMode

;         LD A,(L00D8)
;         OR A
;	 JP Z,L278E
	DB 0eh,0
	DB 0cdh
	DW  MSXDOS

IFDEF MESSAGESFORTILBURG
GIOSMESSAGES:
         DB 18,'MemMan not present',0   ; 0AAH
         DB 20,'Wrong MemMan version',0 ; 0ABH
         DB 20,'GIOS-tsr not present',0 ; 0ACH
         DB 16,'GIOS not present',0     ; 0ADH
         DB 18,'Wrong GIOS version',0   ; 0AEH
ENDIF    ; MessageForTilburg

L20DE:
         DB 0cdh
	DW  GOTOTEXTMODE

         DB 0e1h
	DB 0d1h
	DB 0d1h

ERRORHANDLERRETURN:
         DB 0e9h

         GLOBALS ERROREXIT
ERROREXIT:
         DB 0d9h
         DB 21h
	DW ERROREXITOK
         DB 7eh
         DB 0b7h
         DB 0d9h
         DB 0c8h                      ; quit if no ErrorExit

         DB 0d9h

         DB 36h,0

         DB 0edh,7bh
	DW ERRORSTACK

         DB 02ah
	DW L00CE              ; HL = return address of original call
         DB 0e5h

         DB 0d9h
         DB 0c9h

         GLOBALS DOSERRORHANDLERON
DOSERRORHANDLERON:
         DB 0c3h
	DW  SETERRORHANDLER

         GLOBALS DOSERRORHANDLEROFF
DOSERRORHANDLEROFF:
         DB 0c3h
	DW  RESERRORHANDLER

GOTOTEXTMODE:
         DB 3ah
	DW 0FCAFH
         DB 0feh, 2
         DB 0d8h                      ; quit if screen number < 2

         DB 21h
	DW 0

         DB 3ah
	DW GIOSOK
         DB 0b7h
         DB 20h,(GOTOTEXTMODE1)-$-1        ; jump if GIOS present

         DB 039h                  ; HL = SP

         DB 11h
	DW 8000H+300
         DB 0ebh
         DB 0b7h
         DB 0EDH,052h                  ; 8000H+300 - SP
         DB 0d0h                     ; quit if not enough space on stack left

         ; A = 0
         DW 0F7H
         DW 05FH                    ; SCREEN 0
         DB 0c9h

GOTOTEXTMODE1:
         DB 0e5h
         DB 3eh,8
         DB 0cdh
	DW  RUNGIOS               ; call GIOS function 8 (SCREEN)
                                    ; must be a call because of return address
         DB 0c9h