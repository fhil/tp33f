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

         ; ORG 100H

L0100:

IFDEF MAKEPC
         MOV word ptr L0006,sp
       jmp word ptr L0101

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
	jmp word ptr CONSTPTR_1
ENDIF
CONSTPTR_1:DW L0316

CONINPTR:			; console input routine
IFDEF MSX
	DB 0C3H
ELSE
	jmp word ptr CONINPTR_1
ENDIF
CONINPTR_1:DW L0320

CONOUTPTR:                          ; console output routine
IFDEF MSX
	DB 0C3H
ELSE
	jmp word ptr CON1OUTPTR
ENDIF
CON1OUTPTR:DW L0339

LSTOUTPTR:
	JMP near ptr  L032F
	;DS 3			; jump opcode at 00A9H
				; LSTOUTPTR at absolute 00AAH
AUXOUTPTR:
	JMP near ptr  L0334
	;DS 3			; jump opcode at 00ACH
				; AUXOUTPTR at absolute 00ADH
AUXINPTR:
	JMP near ptr  L032A
	;DS 3			; jump opcode at 00AFH
				; AUXINPTR  at absolute 00B0H
USROUTPTR:
	JMP near ptr  L0339
	;DS 3			; jump opcode at 00B2H
				; USROUTPTR at absolute 00B3H
USRINPTR:
	JMP near ptr  L0320
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
	jmp word ptr ERRORPTR_1
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

L01D0:   MOV al,byte ptr [bx]
	OR al, al
	STC
	RETZ 
L01D4:	INC bx
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH bx
	MOV al,byte ptr [bx]
	CALL near ptr L01E8
	POP bx
	POP ax
	xchg ah,al
	sahf
	DEC al
	RETZ 
	JMP near ptr  L01D4

L01E1:	CALL near ptr L0200		; print CR,LF
	DB 0DH,0AH,0
	RET

L01E8:   MOV bl,al
	PUSH bx
	CALL near ptr CONOUTPTR
	RET

L01EE:	; print character A with/without highlighting
	CMP al, 080H
	CALLC L026B		; LowVideo
	CALLNC L0284		; HighVideo
	AND al, 07FH
	JMP near ptr  L01E8

L01FA:	; print ASCIIZ-string with highlighting
	PUSH bx
	MOV bx,offset L01EE
	JMP near ptr  L0204

L0200:   ; print ASCIIZ-string without highlighting
	PUSH bx
	MOV bx,offset L01E8
L0204:   MOV word ptr L0213,bx
	POP bx
	mov bp,sp
	XCHG [bp],bx
L0209:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx
L020B:	PUSH dx

L020C:   MOV al,byte ptr [bx]
	INC bx
	OR al, al
	JZ near ptr L0218
	PUSH bx
L0212:	CALL near ptr J0213		; call address, address is change able
	POP bx
	JMP near ptr  L020C

L0218:	POP dx
	POP cx
	POP ax
	xchg ah,al
	sahf
	mov bp,sp
	XCHG [bp],bx		; continue after string data
	RET

J0213:
IFDEF MSX
	DB 0C3H
ELSE
	jmp word ptr L0213
ENDIF
L0213:	DW L04D2

L021D:	; in:	HL = time to wait
	MOV al,bl			; delay
	OR al, bh
	RETZ 
	MOV al,byte ptr L0124		; A = frequency
	ADD al,al
	ADD al,al
	ADD al,al
L0226:	mov bp,sp
	XCHG [bp],bx
	mov bp,sp
	XCHG [bp],bx
	mov bp,sp
	XCHG [bp],bx
	mov bp,sp
	XCHG [bp],bx
	PUSH cx
	MOV cx,1234
	POP cx
	DEC al
	JNZ near ptr L0226
	DEC bx
	JMP near ptr  L021D 		; Delay

L0235:	CALL near ptr L01D0
	RETC 
	MOV bx,word ptr L01CE		; HL = DelayHL, delay highlighting
	JMP near ptr  L021D 		; Delay

L023E:	; PROCEDURE ClrSCr;
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx
	PUSH dx
	PUSH bx

	MOV bx,offset L01A8		; HL = HomeStr
	CALL near ptr L0235
	MOV bx,offset L01A2		; HL = ClearScrStr

L024B:	CALL near ptr L01D0
	MOV bx,word ptr L01BA		; HL = DelayLine
	CALLNC L021D		; Delay

	POP bx
	POP dx
	POP cx
	POP ax
	xchg ah,al
	sahf
	RET

L0259:	; PROCEDURE DelLine
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx
	PUSH dx
	PUSH bx
	MOV bx,offset L01B4		; DelLineStr
	JMP near ptr  L024B

L0262:	; PROCEDURE InsLine;
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx
	PUSH dx
	PUSH bx
	MOV bx,offset L01AE		; InsLineStr
	JMP near ptr  L024B

L026B:	; PROCEDURE LowVideo;
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,byte ptr L00E0
	OR al, al
	JZ near ptr L0282

	PUSH cx
	PUSH dx
	PUSH bx
	XOR al, al
	MOV byte ptr L00E0,al
	MOV bx,offset L01C8		; HLEndStr

L027C:	CALL near ptr L0235

	POP bx
	POP dx
	POP cx
L0282:	POP ax
	xchg ah,al
	sahf
	RET

L0284:	; PROCEDURE NormVideo;
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,byte ptr L00E0
	CMP al, 0FFH
	JZ near ptr L0282

	PUSH cx
	PUSH dx
	PUSH bx
	MOV al,0FFH
	MOV byte ptr L00E0,al
	MOV bx,offset L01C2		; HLStartStr
	JMP near ptr  L027C

L0299:	; PROCEDURE ClrEol;
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx
	PUSH dx
	PUSH bx
	MOV bx,offset L01BC		; EraToEolStr
	JMP near ptr  L027C

L02A2:	; in:	L = X, 0..79
	;	H = Y, 0..23
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx
	PUSH dx
	PUSH bx
	PUSH bx
	MOV bx,offset L018B
	MOV dx,offset L00F0
	MOV cx,0010H
	CALL __LDIR
	POP dx
	MOV al,byte ptr L019E
	MOV cl,al
	MOV al,byte ptr L019C
	ADD al,dh
	PUSH dx
	CALL near ptr L02DC
	POP dx
	MOV al,byte ptr L019F
	MOV cl,al
	MOV al,byte ptr L019D
	ADD al,dl
	CALL near ptr L02DC
	MOV bx,offset L00F0
	CALL near ptr L01D0

	MOV bx,word ptr L01A0		; DelayCursor
	CALL near ptr L021D		; Delay
	POP bx
	POP dx
	POP cx
	POP ax
	xchg ah,al
	sahf
	RET

L02DC:	MOV bx,offset L00F0
	MOV ch,0
	ADD bx,cx
	XCHG dx,bx
	MOV bx,offset L019B
	INC byte ptr [bx]
	DEC byte ptr [bx]
	JZ near ptr L02EC
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	RET

L02EC:	DEC dx
	DEC dx
	MOV bx,offset TAB110100+3
	MOV ch,3

L02F3:	DEC bx

	MOV cl,'0'-1
L02F6:	INC cl
	SUB al, byte ptr [bx]
	JNC near ptr L02F6

	ADD al,byte ptr [bx]
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,cl
	CMP al, '0'
L02FF:	JZ near ptr L0302
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
L0302:	INC dx
	POP ax
	xchg ah,al
	sahf
	DEC ch
	JNZ near ptr L02F3
	RET

TAB110100:
	DB 1,10,100

IFDEF MSX
L030A:	; PROCEDURE CrtInit;
	MOV bx,offset L016B		; InitialStr
	JMP near ptr  L0235
ENDIF

L0310:	; PROCEDURE CrtExit;
	MOV bx,offset L017B		; ResetStr
	JMP near ptr  L0235

L0316:   ; tests if there is a character in the input buffer
	; and places it in a temporary buffer to read it the next time
	; in:	-
	; out:	HL = false = 0, if no character present
	;	HL = true = 1, if a character was present
IFDEF MSX
         ; MSX version, FAST
         MOV bx,word ptr 0F3FAH
         MOV al,byte ptr 0F3F8H
         SUB al, bl
         MOV al,1                     ; assume there are characters present
         JNZ near ptr L0316_OK             ; jump if characters present

         DEC al                      ; FALSE if not
L0316_OK:

ELSE
         ; PC version, slow CPM call
         MOV dx,3
         CALL near ptr L035F
	AND al, 1
ENDIF
	JMP near ptr  L0326

L0320:   ; in:    -
	; out:	HL = character read from keyboard
	;	H = always zero
IFNDEF MSX
         MOV dx,2*3                  ; Console Input
ELSE
         ; FAST character input
         PUSH si
         PUSH di
         MOV al,cl
         DW 80F7H
         DW 009FH
         POP di
         POP si
         MOV bl,al
         MOV bh,0
         RET
ENDIF

L0323:   CALL near ptr L035F

L0326:   MOV bl,al
	MOV bh,0
	RET

L032A:	MOV dx,6*3		; Reader Input
	JMP near ptr  L0323

L032F:	MOV dx,4*3		; List Output
	JMP near ptr  L033C

L0334:	MOV dx,5*3		; Puncher Output
	JMP near ptr  L033C

L0339:
IFNDEF MSX
         MOV dx,3*3                  ; Console Output
ENDIF

L033C:	POP bx			; pop return address
	POP cx			; C = character to print
	PUSH bx			; push return address

         MOV al,byte ptr CBREAK
	OR al, al
         JZ near ptr L035D_1               ; jump if no break allowed

         PUSH dx
	PUSH cx
	CALL near ptr CONSTPTR
	MOV al,bh
	OR al, bl
	JZ near ptr L035D		; jump if no character present

         CALL near ptr L03E1                 ; A = character from console
	CMP al, 013H
	JNZ near ptr L035D

         CALL near ptr L03E1                 ; A = character from console
	CMP al, 3
         JZ near ptr L20D4                 ; jump to Program Abort if ^C pressed

L035D:	POP cx
	POP dx

L035D_1:
IFDEF MSX
         ; FAST character output
         PUSH si
         PUSH di
         MOV al,cl
         DW 80F7H
         DW 00A2H
         POP di
         POP si
         RET
ENDIF

L035F:
IFDEF MSX
	MOV bx,word ptr 0001H
	ADD bx,dx
	JMP bx
ELSE
	JMP near ptr  DOSIO 		; ----
ENDIF

L0364:   ; InitCharIO
	MOV word ptr L00D2,bx		; LIB
	MOV al,ch
	MOV byte ptr CBREAK,al
;	 LD A,C
;	 OR A
;	 JR Z,L037A

L037A:
IFDEF MSX
	MOV bx,offset L03A5
	MOV dx,offset CONSTPTR
	MOV cx,offset L03A5_L
	CALL __LDIR
ENDIF

	MOV bx,offset L03BD
	MOV dx,offset L00B8
	MOV cx,000CH
	CALL __LDIR			; flag bits of I/O routines

	XOR al, al
	MOV bl,al
	MOV bh,al
	MOV byte ptr L00D0,al		; reset IORESULT value
	MOV word ptr L00D4,bx
	MOV word ptr L00D6,bx
	MOV al,07EH
	MOV byte ptr BUFLEN,al
	MOV byte ptr L00E0,al

         JMP near ptr  INITFILEIO              ; Set DOS2Present variable

L03A5:   JMP near ptr  L0316                   ; keypressed
         JMP near ptr  L0320                   ; read character from console
         JMP near ptr  L0339                   ; write character to console
	JMP near ptr  L032F
	JMP near ptr  L0334
	JMP near ptr  L032A
         JMP near ptr  L0339                   ; write character to console
         JMP near ptr  L0320                   ; read character from console
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
	PUSH cx
	PUSH dx
	PUSH bx
	PUSH si
	PUSH di
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV bl,al
	MOV bh,0
	PUSH bx
	CALL near ptr CONOUTPTR
	POP ax
	xchg ah,al
	sahf

L03D9:   POP di
	POP si
	POP bx
	POP dx
	POP cx
	RET

L03E1:	; in:	-
	; out:	A = character read from console
	; changes: F
	PUSH cx
	PUSH dx
	PUSH bx
	PUSH si
	PUSH di
L03E8:	CALL near ptr CONINPTR
	MOV al,bl
	JMP near ptr  L03D9 		; same end as 'print character'

	; -----------------------------------------------------------

L03EE:	; parses a filename at DE with wildcards to FCB at L005C
	MOV cl,0FFH		; with wildcards
	JMP near ptr  L03FE

L03F2:	; parses a string whose address is in L00D2 to FCB at L005C
	; with no wildcards, skips leading spaces in string
	MOV cl,0			; don't allow wildcards
	MOV dx,word ptr L00D2
L03F8:	INC dx
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, ' '
	JZ near ptr L03F8		; skip leading spaces

L03FE:	MOV bx,offset L0065		; HL = start address for extension
	MOV ch,3			; 3 characters
	CALL near ptr L047B

L0406:	; parses a complete filename at address in DE to FCB at L005C
	; in:	DE = source address for filename
	;	 C = 0, no wildcards
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CALL near ptr L04A6		; upcase
	CMP al, 'A'
	JC near ptr L0420		; jump if < 'A'
	CMP al, 'Q'
	JNC near ptr L0420		; jump if >= 'Q'
	MOV ch,al			; save first character in B
	INC dx
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, ':'                     ; next character is ':' ?
	JNZ near ptr L041F		; no, don't start with a drive specification
	MOV al,ch			; A = drive letter
	SUB al, 040H 		; 1 = 'A:', 2 = 'B:' etc..
	INC dx			; to character after ':'
	JMP near ptr  L0421

L041F:	DEC dx			; back to first character

L0420:	XOR al, al			; default drive
L0421:	MOV bx,offset L005C
	MOV byte ptr [bx],al		; set drive specification
	INC bx

	INC cl			; C = 0 if no wildcards are allowed
	DEC cl
	JZ near ptr L0443		; jump to skip wildcards

	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CALL near ptr L0482
	JNZ near ptr L0443
	CMP al, '?'
	JZ near ptr L0443
	CMP al, '*'
	JZ near ptr L0443
	CMP al, '.'
	JZ near ptr L0443
	MOV ch,11
	CALL near ptr L0477
	JMP near ptr  L0453

L0443:	MOV ch,8
	CALL near ptr L045E
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, '.'                     ; followed by an extension ?
	JNZ near ptr L0453		; no, skip parsing of an extension

	INC dx			; to first character of extension
	MOV ch,3
	CALL near ptr L045E		; parse extension

L0453:	MOV bx,offset L005C+12		; clear rest of the FCB
         MOV ch,FCB_LEN -11           ; 33e -12
L0458:	MOV byte ptr [bx],0
	INC bx
	DEC ch
	JNZ near ptr L0458
	RET

L045E:	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	INC cl			; skip wildcard check if not allowed
	DEC cl
	JZ near ptr L046B

	CMP al, '?'
	JZ near ptr L0470		; fill as if normal letter
	CMP al, '*'
	JZ near ptr L0476		; fill rest with '?'-wildcards

L046B:	CALL near ptr L0482
	JZ near ptr L047B		; jump if abnormal character found, end of
				; string found, fill rest with spaces

L0470:	MOV byte ptr [bx],al
	INC bx
	INC dx
	DEC ch
	JNZ near ptr L045E
	RET

L0476:	INC dx

L0477:	; fill rest with '?'-wildcards
	MOV al,'?'
	JMP near ptr  L047D

L047B:	; fill rest with spaces
	MOV al,' '

L047D:	MOV byte ptr [bx],al
	INC bx
	DEC ch
	JNZ near ptr L047D
	RET

L0482:	CALL near ptr L04A6		; upcase A
	CMP al, ' '                     ; < ' ' ?
	JC near ptr L0496

	PUSH bx
	PUSH cx
	MOV bx,offset L0498		; HL = address of data to scan
	MOV cx,offset L04911		; BC = length of data to scan
	CALL __CPIR
	POP cx
	POP bx
	RET			; return Z-flag = '1' if A found in data

L0496:	CMP al, al			; return with Z-flag corresponding to A
	RET

L0498:	; SepTable
	DB ' .,;:=?*[]<>{}'
L04911	EQU $-L0498

	; -----------------------------------------------------------

L04A6:	; in:	A = character
	; out:	A = upcased, if A >= 'a' and A <= 'z'
	CMP al, 'a'
	RETC 
	CMP al, 'z'+1
	RETNC 
	SUB al, 'a'-'A'
	RET

L04AF:	MOV al,bh
	CALL near ptr L04B4
	MOV al,bl

L04B4:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	RCR al,1
	RCR al,1
	RCR al,1
	RCR al,1
	CALL near ptr L04BD
	POP ax
	xchg ah,al
	sahf
L04BD:	AND al, 00FH
	CMP al, 10
	JC near ptr L04BE
	ADD al,7
L04BE:	ADD al,'0'
	JMP near ptr  L03C9 		; print digit

L04C8:   ; converts integer HL to an unsigned byte A
	; in:	HL
	; out:	A = 0 and carry set, if HL < 0
	;	A = L and carry reset, if HL < 256
	;	otherwise A = 255
	XOR al, al
	STC			; assume HL is negative
	TEST bh,128
	RETNZ 			; return with carry set if negative

         MOV al,bh
	OR al, al
	MOV al,bl
         RETZ                       ; return if HL < 256

L04D2:   MOV al,byte ptr L04D2_D             ; code area
	RET

L04D2_D: DB 0                       ; data area


L0581:   ; LIB
	; push new empty SET on stack
	; in:	-
	; out:	a new SET pushed on to the stack
	POP si			; LIB
	MOV bx,-32
	ADD bx,sp
	MOV sp,bx 		; reserve 32 bytes

	; clear the SET with zeroes
	MOV ch,020H
	XOR al, al
L058B:	MOV byte ptr [bx],al
	INC bx
	DEC ch
	JNZ near ptr L058B

	JMP si

L0591:	; add element HL to SET at stack
	;
	POP si
	MOV ch,bl			; B = element to add
	CALL near ptr L05BA

L0597:	OR al, byte ptr [bx]
	MOV byte ptr [bx],al

L0599:	JMP si

L059B:   POP si                     ; LIB
	POP dx
	MOV al,bl
	SUB al, dl
	JC near ptr L0599
	INC al
	MOV cl,al
	MOV ch,dl
	CALL near ptr L05BA
	MOV dl,al
	MOV ch,cl
	XOR al, al
L05AB:	OR al, dl
	SAL dl,1
	JNC near ptr L05B6
	OR al, byte ptr [bx]
	MOV byte ptr [bx],al
	INC bx
	XOR al, al
	MOV dl,1
L05B6:	DEC ch
	JNZ near ptr L05AB
	JMP near ptr  L0597

L05BA:	MOV al,ch
	AND al, 0F8H 		; calculate byte offset
	ROR al,1
	ROR al,1
	ROR al,1
	ADD al,2			; add 2 for return address
	MOV bl,al
	MOV bh,0
	ADD bx,sp
	MOV al,ch
	AND al, 7
	INC al
	MOV ch,al
	XOR al, al
	STC
L05CD:	RCL al,1
	DEC ch
	JNZ near ptr L05CD
	RET


L0612:	; pop pushed set to the address in HL
	; in:	HL = destination address of SET
	;	C = bytes to copy from SET
	;	B = offset within SET
	POP si			; LIB
	XCHG dx,bx
	MOV bl,ch			; HL = offset within SET
	MOV bh,0
	MOV ch,bh			; BC = length
	ADD bx,sp
	CALL __LDIR			; copy set to given address

	MOV bx,0020H

L061F:   ADD bx,sp
	MOV sp,bx
	JMP si

L06F5:	; X * Y : INTEGER
	; in:	DE = X
	;	HL = Y
	; out:	HL = X * Y
	MOV cl,dl			; BC = X
	MOV ch,dh
	XCHG dx,bx
	MOV bx,0
	MOV al,dh			; D non zero?
	OR al, al
	MOV al,16			; assume 16 bits
	JNZ near ptr L0704		; yes, continue
	MOV dh,dl			; no, shift E to D
	MOV al,8			; shift rest over 8 bits
L0704:	ADD bx,bx
	XCHG dx,bx
	ADD bx,bx
	XCHG dx,bx
	JNC near ptr L070B
	ADD bx,cx
L070B:	DEC al
	JNZ near ptr L0704
	RET

L0780:   ; Abs X : INTEGER
	; in:	HL = X
	; out:	HL = -X, if X < 0
	;	HL = X, if X >= 0
	TEST bh,128			; LIB, HL = negative ?
	RETZ 			; return if positive

L0783:	; X = -X : INTEGER
	; in:	HL = X
	; out:	HL = -X
	MOV al,bh			; negate HL
	NOT al
	MOV bh,al
	MOV al,bl
	NOT al
	MOV bl,al
	INC bx
	RET

L07C6:   ; unsigned Integer to ASCII
	; in:	HL = unsigned INTEGER
	;	IX = destination address of ASCII result
	; out:	IX = address after ASCII result
	MOV ch,0			; Flag = 0, no leading zero
	MOV dx,10000
	CALL near ptr L07E2
	MOV dx,1000
	CALL near ptr L07E2
	MOV dx,100
	CALL near ptr L07E2
	MOV dl,10
	CALL near ptr L07E2
	MOV al,bl
	JMP near ptr  L07EF

L07E2:	XOR al, al
L07E3:	INC al
	SBB bx,dx
	JNC near ptr L07E3
	ADD bx,dx
	INC ch			; increase, assume NonZero
	DEC al
	JNZ near ptr L07EF		; jump if digit > 0

	DEC ch			; Flag = 0 ?, suppress leading zero's
	RETZ 

L07EF:	ADD al,'0'
	MOV byte ptr [si+0],al
	INC si
	RET

L07F7:   ; ASCII hexadecimal or decimal to Integer
	; converts ascii hexadecimal or decimal number at IX to
	; a value in HL
	; in:	IX = address of ascii digit sequence
	; out:	carry set if value out of range
	;	carry reset, HL = value
	MOV al,byte ptr [si+0]
	SUB al, '$'
	MOV cl,al
	MOV bx,0
	JNZ near ptr L0804		; NonZero, do not skip '$' character
L0802:	INC si

L0804:	MOV al,byte ptr [si+0]
	CALL near ptr L04A6		; upcase
	SUB al, '0'                    ; < '0' ?
	JC near ptr L0837		; yes, quit
	CMP al, 10			; < 10 ?
	JC near ptr L0820		; yes, continue

	; A..F ?
	INC cl			; started with '$' ?
	DEC cl
	JNZ near ptr L0837		; no, quit
	SUB al, 7			; 'A' --> 10, 'B' --> 11
	CMP al, 10			; < 10 ?
	JC near ptr L0837		; yes, quit
	CMP al, 16			; >= 16 ?
	JNC near ptr L0837		; yes, quit
L0820:	MOV dh,bh			; save old HL
	MOV dl,bl
	ADD bx,bx		; * 2
	RETC 			; quit if carry, overflow
	ADD bx,bx		; * 4
	RETC 			; quit if error
	INC cl			; hexadecimal ?
	DEC cl
	JNZ near ptr L082C
	MOV dh,bh			; yes, hexadecimal (perform * 16)
	MOV dl,bl
L082C:	ADD bx,dx		; * 5 if decimal
				; * 8 if hexadecimal
	RETC 			; quit if error
	ADD bx,bx		; * 10 if decimal
				; * 16 if hexadecimal
	RETC 			; quit if error
	MOV dl,al
	MOV dh,0
	ADD bx,dx		; * 10 + digit if decimal
				; * 16 + digit if hexadecimal
	RETC 			; quit if error
	JMP near ptr  L0802 		; go for the next digit

L0837:   OR al, al
	;RET Z			; quit if carry reset if hexadecimal
				; allow hexadecimals that are negative
				; decimals
	;LD A,H
	;ADD A,A
	RET			; quit with carry set if HL > 32767?

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
	MOV al,byte ptr [si+0]
	SUB al, '$'
	MOV byte ptr A2L_FLAG,al
	MOV bx,0			; DE:HL = 0
	MOV dx,0
	JNZ near ptr A2L04		; NonZero, do not skip '$' character

A2L02:	INC si

A2L04:   MOV al,byte ptr A2L_FLAG
         MOV cl,al
         MOV al,byte ptr [si+0]
	CALL near ptr L04A6		; upcase
	SUB al, '0'                    ; < '0' ?
	JC near ptr A2L37		; yes, quit --> error
	CMP al, 10			; < 10 ?
	JC near ptr A2L20		; yes, continue

	; A..F ?
         INC cl                      ; started with '$' ?
         DEC cl
         JNZ near ptr A2L37                ; no, quit --> error

	; hexadecimal
	SUB al, 7			; 'A' --> 10, 'B' --> 11
	CMP al, 10			; < 10 ?
         JC near ptr A2L37                 ; yes, quit --> error
	CMP al, 16			; >= 16 ?
         JNC near ptr A2L37                ; yes, quit --> error

A2L20:   lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         MOV al,byte ptr A2L_FLAG
	OR al, al			; hexadecimal or decimal ?
	JZ near ptr A2L_HEX		; jump if hexadecimal

	; multiply DE:HL by 10 with overflow detection
	PUSH dx			; save old DE:HL * 1
	PUSH bx
	CALL near ptr L_M2		; DE:HL * 2
	JC near ptr A2L38		; quit if carry, overflow

	CALL near ptr L_M2		; DE:HL * 4
	JC near ptr A2L38		; quit if carry, overflow

	POP cx			; DE:HL * 4 + DE:HL * 1
	ADD bx,cx
	XCHG dx,bx
	POP cx
	ADC bx,cx
	XCHG dx,bx
         POP cx
         MOV al,ch                     ; A = digit to add
         RETC                       ; quit if carry, overflow

         CALL near ptr L_M2                  ; DE:HL * 2
         RETC 
         JMP near ptr  A2L36                   ; add the current digit

A2L_HEX: POP ax
	xchg ah,al
	sahf
         CALL near ptr L_M2                  ; DE:HL * 2
	RETC 			; quit if carry, overflow
	CALL near ptr L_M2		; DE:HL * 4
	RETC 			; quit if carry, overflow
	CALL near ptr L_M2		; DE:HL * 8
	RETC 			; quit if carry, overflow
	CALL near ptr L_M2		; DE:HL * 16
	RETC 			; quit if carry, overflow

A2L36:   ; add the new digit and repeat
         MOV cl,al
         MOV ch,0
         ADD bx,cx
         XCHG dx,bx
         MOV cx,0
         ADC bx,cx
         XCHG dx,bx
         JMP near ptr  A2L02                   ; go for the next digit

A2L37:   MOV al,cl
	OR al, al
	RET

A2L38:   POP bx
         POP bx
	POP dx
	RET

L_M2:    ; in:    DE:HL
	; out:	DE:HL * 2
	;	Carry if overflow
	ADD bx,bx
	XCHG dx,bx
	ADC bx,bx
	XCHG dx,bx
	RET

; ------------------------------------------------------
; ------------------------------------------------------
; ------------------------------------------------------
; ------------------------------------------------------
; ------------------------------------------------------


L09E9:   ; REAL + REAL
         CALL near ptr L0A0D                 ; LIB

L09EC:	RETNC 
	MOV al,1			; r.error 1: Floating point overflow
	JMP near ptr  L2027 		; Run-time error


L0A03:   MOV al,2                     ; r.error 2: Division by zero attempted
	JZ near ptr L2027		; Run-time error
         CALL near ptr L0AF5
	JMP near ptr  L09EC

L0A0D:	CALL __EXX
	TEST ch,128
	CALL __EXX
	JNZ near ptr L0A88
L0A14:	CALL __EXX
	MOV al,bl
	OR al, al
	CALL __EXX
	RETZ 
	CALL __EXX
	PUSH cx
	PUSH dx
	PUSH bx
	CALL __EXX
	MOV al,bl
	OR al, al
	JNZ near ptr L0A27
	CALL __EXX
	pushf
	AND ch,01111111b
	popf
	JMP near ptr  L0A7B
L0A27:	PUSH cx
	pushf
	OR ch,128
	popf
	XOR al, al
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	CALL __EXX
	pushf
	OR ch,128
	popf
	MOV al,bl
	CALL __EXX
	SUB al, bl
	JZ near ptr L0A47
	JNC near ptr L0A3C
	NEG al
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	DEC al
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	CALL __EXX
L0A3C:	CALL near ptr L0B7A
	INC bl
	DEC al
	JNZ near ptr L0A3C
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	JZ near ptr L0A47
	CALL __EXX
L0A47:	POP ax
	xchg ah,al
	sahf
	AND al, 80H
	JNZ near ptr L0A5B
	CALL near ptr L0B92
	JNC near ptr L0A76
	CALL near ptr L0B7B
	OR al, al
	INC bl
	JNZ near ptr L0A76
	STC
	JMP near ptr  L0A7B
L0A5B:	CALL near ptr L0BC6
	CMC
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	JZ near ptr L0A72
	JC near ptr L0A65
	CALL __EXX
L0A65:	CALL near ptr L0BAC
L0A68:	TEST ch,128
	JNZ near ptr L0A75
	CALL near ptr L0B86
	DEC bl
	JNZ near ptr L0A68

L0A72:	CALL near ptr L0B72		; HLDEBC = 0.0

L0A75:	POP ax
	xchg ah,al
	sahf
L0A76:	JC near ptr L0A7A
	pushf
	AND ch,01111111b
	popf
L0A7A:	OR al, al
L0A7B:	CALL __EXX
	POP bx
	POP dx
	POP cx
	CALL __EXX
	RET
L0A81:	CALL __EXX
	TEST ch,128
	CALL __EXX
	JNZ near ptr L0A14
L0A88:	CALL near ptr L0A8F
	CALL near ptr L0A14
	RETC 
L0A8F:	INC bl
	DEC bl
	RETZ 
	MOV al,ch
	XOR al, 80H
	MOV ch,al
	RET
L0A97:	CALL __EXX
	MOV al,bl
	OR al, al
	CALL __EXX
	JZ near ptr L0B72		; Zero --> HLDEBC = 0.0

	MOV al,bl
	OR al, al
	RETZ 
	CALL __EXX
	ADD al,bl
	CALL __EXX
	CALL near ptr L0B4D
	PUSH cx
	PUSH dx
	PUSH bx
	ADD si,sp

IFNDEF FASTREAL
	CALL near ptr L0B72		; HLDEBC = 0.0
	CALL __EXX
	MOV bl,5
	CALL __EXX
L0AB3:	MOV al,8
	INC si
IFDEF MSX
	MOV bl,byte ptr [si+0]
ELSE
	mov bl,ss:[si + 0]	; read from stack !!! ----
ENDIF
L0ABA:	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	RCR bl,1
	JNC near ptr L0AC2
	CALL near ptr L0B92
L0AC2:	CALL near ptr L0B7B
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	DEC al
	JNZ near ptr L0ABA
	CALL __EXX
	DEC bl
	CALL __EXX
	JNZ near ptr L0AB3

ELSE	; FASTREAL

	CALL __EXX
	PUSH cx
	MOV cl,bh
	CALL __EXX
	POP dx			; BCDEHL' --> DED'E'C'

	XOR al, al			; HLH'L'A = 0
	MOV bl,al
	MOV bh,al
	CALL __EXX
	MOV bl,al
	MOV bh,al
	MOV ch,5			; B' = byte count
	CALL __EXX

MULTREAL1:
	MOV ch,8			; B = bit count
	INC si
;         LD C,(IX+0)
IFDEF MSX
         MOV cl,byte ptr [si+0]
ELSE
       mov cl,ss:[si + 0]         ; read from stack !!! ----
ENDIF

MULTREAL2:
	RCR cl,1
	JNC near ptr MULTREAL3
	CALL __EXX
	ADD al,cl
	ADC bx,dx
	CALL __EXX
	ADC bx,dx

MULTREAL3:
	RCR bh,1
	RCR bl,1
	CALL __EXX
	RCR bh,1
	RCR bl,1
	CALL __EXX
	RCR al,1

	DEC ch
	JNZ near ptr MULTREAL2

	CALL __EXX
	DEC ch
	CALL __EXX
	JNZ near ptr MULTREAL1

	; BCDEH = HLH'L'A
	MOV ch,bh
	MOV cl,bl
	MOV bh,al
	CALL __EXX
	PUSH bx
	CALL __EXX
	POP dx

	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf                  ; save Carry from RRA

ENDIF	; FASTREAL

IFDEF MSX
	MOV bl,byte ptr [si-5]
ELSE
	mov bl,ss:[si - 5]
ENDIF
	TEST ch,128
	JNZ near ptr L0ADE
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	CALL near ptr L0B87
	INC bl
	DEC bl
	JZ near ptr L0ADE
	DEC bl
L0ADE:	POP ax
	xchg ah,al
	sahf
	POP ax
	xchg ah,al
	sahf
	POP ax
	xchg ah,al
	sahf

L0AE1:	OR al, al

L0AE2:	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	POP ax
	xchg ah,al
	sahf
	CALL __EXX
	POP cx
	POP dx			; FastReal
	POP bx
	CALL __EXX
	POP si
	pushf
	AND ch,01111111b
	popf
	OR al, ch
	MOV ch,al
	INC bl
	DEC bl
	CALLZ L0B72		; Zero --> HLDEBC = 0.0

	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	RET

L0AF5:	MOV al,bl
	OR al, al
	RETZ 
	CALL __EXX
	SUB al, bl
	CALL __EXX
	CMC
	CALL near ptr L0B4D
	PUSH bx
L0B00:	PUSH bx
	PUSH bx
	ADD si,sp

IFNDEF FASTREAL
	CALL __EXX
	MOV bl,5
	CALL __EXX
	MOV al,8
L0B0A:	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	CALL near ptr L0BC6
	JC near ptr L0B13
	CALL near ptr L0BAC
L0B13:	CMC
	RCL bl,1
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	DEC al
	JNZ near ptr L0B26
IFDEF MSX
	MOV byte ptr [si+5],bl
ELSE
	mov byte ptr ss:[si+5],bl
ENDIF
	DEC si
	CALL __EXX
	DEC bl
	CALL __EXX
	JZ near ptr L0B32
	MOV al,8
L0B26:	CALL near ptr L0B86
	JNC near ptr L0B0A
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	CALL near ptr L0BAC
	OR al, al
	JMP near ptr  L0B13
L0B32:	CALL near ptr L0B86
	JC near ptr L0B3B
	CALL near ptr L0BC6
	CMC
ELSE	; FASTREAL

	MOV al,bh
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	MOV bh,ch
	MOV bl,cl
	PUSH dx
	CALL __EXX
	MOV al,bh
	POP bx
	PUSH cx
	MOV cl,al
	MOV ch,5			; B' = byte count
	CALL __EXX
	POP dx
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf

	MOV ch,8			; B = bit count

DIVREAL1:CALL near ptr COMPMANTISSE
	JC near ptr DIVREAL2

	; SubMantisse
	CALL __EXX
	SUB al, cl
	SBB bx,dx
	CALL __EXX
	SBB bx,dx

DIVREAL2:CMC
	RCL cl,1

	DEC ch
	JNZ near ptr DIVREAL3

;         LD (IX+5),C
IFDEF MSX
         MOV byte ptr [si+5],cl
ELSE
       mov byte ptr ss:[si+5],cl
ENDIF
	DEC si

	CALL __EXX
	DEC ch
	CALL __EXX
	JZ near ptr DIVREAL4

	MOV ch,8			; B = bit count

DIVREAL3:; SLAMantisse
	OR al, al
	RCL al,1
	CALL __EXX
	ADC bx,bx
	CALL __EXX
	ADC bx,bx
	JNC near ptr DIVREAL1

	; SubMantisse
	CALL __EXX
	SUB al, cl
	SBB bx,dx
	CALL __EXX
	SBB bx,dx
	OR al, al
	JMP near ptr  DIVREAL2

DIVREAL4:; SLAMantisse
	OR al, al
	RCL al,1
	CALL __EXX
	ADC bx,bx
	CALL __EXX
	ADC bx,bx
	JC near ptr DIVREAL5

	CALL near ptr COMPMANTISSE
	CMC

DIVREAL5:

ENDIF	; FASTREAL

L0B3B:	POP bx
	POP dx
	POP cx
       lahf                       ; store carry in ah

         TEST ch,128
         JNZ near ptr L0B47

       sahf                       ; restore carry
         CALL near ptr L0B87
	JMP near ptr  L0AE1

IFDEF FASTREAL
COMPMANTISSE:
	OR al, al
	SBB bx,dx
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	ADD bx,dx
	POP ax
	xchg ah,al
	sahf
	RETNZ 

	CALL __EXX
	OR al, al
	SBB bx,dx
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	ADD bx,dx
	POP ax
	xchg ah,al
	sahf
	CALL __EXX
	RETNZ 

	CALL __EXX
	CMP al, cl
	CALL __EXX
	RET

ENDIF	; FASTREAL

L0B47:	INC bl
	JNZ near ptr L0AE1
	STC
	JMP near ptr  L0AE2

L0B4D:	JC near ptr L0B55
	ADD al,80H
	JC near ptr L0B59
	JMP near ptr  L0B70
L0B55:	ADD al,80H
	JC near ptr L0B70
L0B59:	MOV bl,al
	mov bp,sp
	XCHG [bp],si
	CALL __EXX
	PUSH bx
	PUSH dx
	PUSH cx
	MOV al,ch
	pushf
	OR ch,128
	popf
	CALL __EXX
	XOR al, ch
	AND al, 80H
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	pushf
	OR ch,128
	popf
	PUSH si
	MOV si,0
	RET
L0B70:	POP bx
	RETC 

L0B72:	; create a REAL HLDEBC with 0.0 as value
	; in:	-
	; out:	REAL HLDEBC filled with zeroes
	XOR al, al
	MOV bl,al
	MOV ch,al
	MOV cl,al
	MOV dh,al
	MOV dl,al
	MOV bh,al
	RET

L0B7A:	OR al, al
L0B7B:	RCR ch,1
	RCR cl,1
	RCR dh,1
	RCR dl,1
	RCR bh,1
	RET

L0B86:   OR al, al

L0B87:   RCL bh,1
	RCL dl,1
	RCL dh,1
	RCL cl,1
	RCL ch,1
	RET

L0B92:   MOV al,bh
	CALL __EXX
	ADD al,bh
	CALL __EXX
	MOV bh,al
	MOV al,dl
	CALL __EXX
	ADC al,dl
	CALL __EXX
	MOV dl,al
	MOV al,dh
	CALL __EXX
	ADC al,dh
	CALL __EXX
	MOV dh,al
	MOV al,cl
	CALL __EXX
	ADC al,cl
	CALL __EXX
	MOV cl,al
	MOV al,ch
	CALL __EXX
	ADC al,ch
	CALL __EXX
	MOV ch,al
	RET
L0BAC:	MOV al,bh
	CALL __EXX
	SUB al, bh
	CALL __EXX
	MOV bh,al
	MOV al,dl
	CALL __EXX
	SBB al,dl
	CALL __EXX
	MOV dl,al
	MOV al,dh
	CALL __EXX
	SBB al,dh
	CALL __EXX
	MOV dh,al
	MOV al,cl
	CALL __EXX
	SBB al,cl
	CALL __EXX
	MOV cl,al
	MOV al,ch
	CALL __EXX
	SBB al,ch
	CALL __EXX
	MOV ch,al
	RET

L0BC6:	MOV al,ch
	CALL __EXX
	CMP al, ch
	CALL __EXX
	RETNZ 
	MOV al,cl
	CALL __EXX
	CMP al, cl
	CALL __EXX
	RETNZ 
	MOV al,dh
	CALL __EXX
	CMP al, dh
	CALL __EXX
	RETNZ 
	MOV al,dl
	CALL __EXX
	CMP al, dl
	CALL __EXX
	RETNZ 
	MOV al,bh
	CALL __EXX
	CMP al, bh
	CALL __EXX
	RET

L0BDF:	; Compare REALS
	CALL __EXX
	MOV al,ch
	CALL __EXX
	XOR al, ch
	JNS near ptr L0BE9
	MOV al,ch
	RCL al,1
	RET
L0BE9:	TEST ch,128
	JZ near ptr L0BF3
	CALL near ptr L0BF3
	RETZ 
	CMC
	RET
L0BF3:	MOV al,bl
	CALL __EXX
	CMP al, bl
	CALL __EXX
	RETNZ 
	OR al, al
	RETZ 
	JMP near ptr  L0BC6


L0F73:   ; in:    IX = address of REAL
	; out:	HLDEBC = REAL located at address IX
	;	IX unchanged
	MOV bl,byte ptr [si+0]
	MOV bh,byte ptr [si+1]
	MOV dl,byte ptr [si+2]
	MOV dh,byte ptr [si+3]
	MOV cl,byte ptr [si+4]
	MOV ch,byte ptr [si+5]
	RET

L0F86:   MOV bx,81H                  ; 1.0
	MOV ch,bh
	MOV cl,bh
	MOV dh,bh
	MOV dl,bh
	RET

L10031:  MOV al,93H                   ; r.error 93H: Out of LONGINT range
	JMP near ptr  L2027

L1008:   MOV al,bh                     ; LIB, convert integer HL to REAL HLDEBC
	OR al, bl
	JZ near ptr L0B72		; return 0.0 REAL if HL = 0

	TEST bh,128
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf                  ; save NZ for negative

         CALL near ptr L0780                 ; absolute HL

	MOV al,90H

	; shift, normalization
L1015:   ADD bx,bx
	DEC al
	TEST bh,128
	JZ near ptr L1015

	MOV ch,bh			; BC = integer, bit 7 of B always '1'
	MOV cl,bl
	MOV dx,0			; D = E = 0
	MOV bh,dh			; H = 0
	MOV bl,al

	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	RETNZ 			; keep bit 7 of B '1' if negative

	pushf
	AND ch,01111111b
	popf			; no, make if positive
	RET

L_NEG:   ; X = -X : LONG
	; in:	X in DEHL
	; out:	DEHL
         ; changes: BC, A = 0
	MOV cl,bl			; BC = low-word
	MOV ch,bh
	XOR al, al			; Carry = 0
	MOV bl,al
	MOV bh,al
	SBB bx,cx		; 0 - low-word
	XCHG dx,bx
	MOV cl,bl			; BC = high-word
	MOV ch,bh
	MOV bl,al
	MOV bh,al
	SBB bx,cx		; 0 - high-word - carry
	XCHG dx,bx
	RET

L_R:     ; convert LONGINT DEHL to REAL HLDEBC
	; in:	DEHL = signed LONGINT
	; out:	HLDEBC = REAL
	MOV al,bh
	OR al, bl
	OR al, dh
	OR al, dl
	JZ near ptr L0B72		; jump if long is zero

	TEST dh,128			; is this long negative ?
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; rember this
	CALLNZ L_NEG		; make positive if long is negative
	MOV al,0A0H

	; perform normlization
L_R_SH:	ADD bx,bx
	XCHG dx,bx
	ADC bx,bx
	XCHG dx,bx
	DEC al
	TEST dh,128
	JZ near ptr L_R_SH		; shift until bit 31 = '1'

	XCHG dx,bx 		; HL:DE = normalized mantissa
	MOV ch,bh
	MOV cl,bl
	MOV bh,0
	MOV bl,al			; exponent + 81H in A
	POP ax
	xchg ah,al
	sahf			; ZeroFlag = 0 if long was negative
	RETNZ 			; if negative then leave bit 7 of B '1'

	pushf
	AND ch,01111111b
	popf
	RET

R_L:     ; convert REAL HLDEBC to LONGINT DEHL
	; in:	HLDEBC = REAL
	; out:	DEHL = signed LONGINT
	TEST bl,128			; exponent < 80H then float = 0.0
				; in other words float < 1.0
	JZ near ptr L0B72		; return DEHL = 0 if REAL < 1.0

	TEST ch,128			; ZeroFlag = 0 if REAL is negative
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save sign of REAL

	pushf
	OR ch,128
	popf			; restore hidden bit

R_L_SH:	MOV al,9FH
	CMP al, bl			; more than 31 bits before the comma
	JC near ptr L10031		; r.error 93H: Out of LONGINT range

	JZ near ptr R_L_READY		; jump if no more shifts
	SHR ch,1
	RCR cl,1
	RCR dh,1
	RCR dl,1
	RCR bh,1
	INC bl
	JMP near ptr  R_L_SH		; go for next possible shift

R_L_READY:
	SHR ch,1
	RCR cl,1
	RCR dh,1
	RCR dl,1
	RCR bh,1
	POP ax
	xchg ah,al
	sahf			; restore sign of REAL
	MOV bh,ch
	MOV bl,cl			; long HLDE complete, if positive
	XCHG dx,bx 		; deliver in format DE:HL

	RETZ 			; return if float was positive

	JMP near ptr  L_NEG 		; make long negative if REAL was negative

L1027:   ; in:    BCDEHL' = REAL to convert to ASCII
         ;        HL = number of digits after decimal point
         CALL near ptr L04C8                 ; int to byte
	XCHG dx,bx
	MOV dl,0
	JC near ptr L1033
	CMP al, 19H
	JC near ptr L104B

L1033:	DEC dl
	CALL near ptr L04C8		; int to byte
	CALL __EXX
	TEST ch,128			; NonZero if REAL HLDEBC is negative
	CALL __EXX
	MOV dh,7			; 7 digits if positive
	JZ near ptr L1040

	INC dh			; no, 8 digits, sign included

L1040:	SUB al, dh			; subtract from total bytes of space
	JNC near ptr L1044		; jump if enough room
	XOR al, al
L1044:	CMP al, 9			; less than 9 digits of space left ?
	JC near ptr L104A		; yes, jump

	MOV al,9			; no, make it 9 digits at the most

L104A:	INC al

L104B:	MOV dh,al
	PUSH dx
	CALL __EXX
	MOV di,offset L005D		; destination for ascii-float
	PUSH si
	CALL near ptr L10EB		; convert HLDEBC to ascii at IY
	POP si
	POP dx
	MOV cl,al
	MOV al,dh
	INC al
	TEST dl,128
	JNZ near ptr L1071
	ADD al,cl
	JNS near ptr L106B

	MOV byte ptr [di+0],0
	JMP near ptr  L1076

L106B:	CMP al, 0CH
	JC near ptr L1071

	MOV al,0BH

L1071:	PUSH dx
	CALL near ptr L1180
	POP dx
L1076:	TEST ch,128
	JZ near ptr L107F

	MOV al,'-'
	CALL near ptr L10E5		; add '-' at (IX+0)

L107F:	TEST dl,128
	JZ near ptr L1086
	MOV bh,cl
	MOV cl,0
L1086:	TEST cl,128
	JZ near ptr L108F

	CALL near ptr L10E3		; add '0' at (IX+0)
	JMP near ptr  L1096

L108F:	CALL near ptr L10D9
	DEC cl
	JNS near ptr L108F

L1096:	MOV al,dh
	OR al, al
	JZ near ptr L10B1

	MOV al,'.'
	CALL near ptr L10E5		; add '.' at (IX+0)

L109F:	INC cl
	JZ near ptr L10A8

	CALL near ptr L10E3		; add '0' at (IX+0)
	DEC dh
	JNZ near ptr L109F
L10A8:	DEC dh
	JS near ptr L10B1
	CALL near ptr L10D9
	JMP near ptr  L10A8

L10B1:	TEST dl,128
	RETZ 

	MOV al,'E'
	CALL near ptr L10E5		; add 'E' at (IX+0)

	MOV al,'+'                   ; add '+'
	TEST bh,128
	JZ near ptr L10C5
	MOV al,bh
	NEG al
	MOV bh,al

	MOV al,'-'
L10C5:	CALL near ptr L10E5		; add '+' or '-' at (IX+0)
	MOV al,bh
	MOV ch,'0'-1

L10CB:	INC ch
	SUB al, 10
	JNC near ptr L10CB

	ADD al,'0'+10
	MOV byte ptr [si+0],ch
	INC si
	JMP near ptr  L10E5

L10D9:	MOV al,byte ptr [di+0]
	INC di
	OR al, al
	JNZ near ptr L10E5

	DEC di

L10E3:	MOV al,'0'
L10E5:	MOV byte ptr [si+0],al
	INC si
	RET

L10EB:	; in:	IY = destination address for REAL in ASCII format
	;	HLDEBC = REAL
	PUSH di
	INC bl			; REAL represents zero?
	DEC bl
	JNZ near ptr L10FF		; no, continue

	; fill destination address at IY with 12 '0' characters
	MOV ch,12
L10F3:	MOV byte ptr [di+0],'0'
	INC di
	DEC ch
	JNZ near ptr L10F3
	XOR al, al
	JMP near ptr  L117D 		; jump POP IY and RET

L10FF:	PUSH cx
	pushf
	AND ch,01111111b
	popf
	MOV al,bl
	CALL __EXX
	SUB al, 80H
	MOV bl,al
	SBB al,al			; A = 255, if L was < 80H, otherwise A = 0
	MOV bh,al			; HL = signed L - 80H = exponend
	MOV dx,4DH
	CALL near ptr L06F5		; LIB
	MOV dx,5
	ADD bx,dx
	MOV al,bh
	CMP al, 0D9H
	JNZ near ptr L1119
	INC al
L1119:	MOV byte ptr [di+0],al
	NEG al
	CALL near ptr L1240
	MOV al,bl
	CMP al, 81H
	JNC near ptr L112C
	CALL near ptr L12B3
	DEC byte ptr [di+0]
L112C:	pushf
	OR ch,128
	popf
	MOV al,84H
	SUB al, bl
	MOV bl,0
	JZ near ptr L113D
L1135:	CALL near ptr L0B7A
	RCR bl,1
	DEC al
	JNZ near ptr L1135
L113D:	MOV al,byte ptr [di+0]
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,0CH
L1143:	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	MOV al,ch
	RCR al,1
	RCR al,1
	RCR al,1
	RCR al,1
	AND al, 0FH
	ADD al,30H
	MOV byte ptr [di+0],al
	INC di
	MOV al,ch
	AND al, 0FH
	MOV ch,al
	PUSH cx
	PUSH dx
	PUSH bx
	SAL bl,1
	CALL near ptr L0B87
	SAL bl,1
	CALL near ptr L0B87
	XCHG dx,bx
	mov bp,sp
	XCHG [bp],bx
	ADD bx,dx
	POP dx
	mov bp,sp
	XCHG [bp],bx
	ADC bx,dx
	XCHG dx,bx
	POP bx
	mov bp,sp
	XCHG [bp],bx
	ADC bx,cx
	MOV ch,bh
	MOV cl,bl
	POP bx
	SAL bl,1
	CALL near ptr L0B87
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	DEC al
	JNZ near ptr L1143		; repeat until ready with conversion
	POP ax
	xchg ah,al
	sahf
	POP cx
L117D:	POP di
	RET


	; ----------
	; subroutine
	; ----------
L1180:	PUSH di
	POP bx
	MOV dl,al
	MOV dh,0
	ADD bx,dx
	MOV al,byte ptr [bx]
	MOV byte ptr [bx],0
	CMP al, 35H
	RETC 

L118D:	DEC dl
	JS near ptr L119C
	DEC bx
	MOV al,byte ptr [bx]
	INC al
	MOV byte ptr [bx],al
	CMP al, 3AH
	RETC 
	MOV byte ptr [bx],0
	JMP near ptr  L118D

L119C:	MOV byte ptr [bx],31H
	INC bx
	MOV byte ptr [bx],0
	INC cl
	RET
	; ----------

L11A3:	; converts ascii REAL at IX to binary REAL in HLDEBC
	; in:	IX = address of ascii REAL
	; out:	carry set if conversion did not succeed
	CALL __EXX
	MOV cx,0
	CALL __EXX
	CALL near ptr L0B72		; HLDEBC = 0.0

L11AB:	MOV al,byte ptr [si+0]
	CALL near ptr L04A6		; upcase
	CMP al, '.'
	JNZ near ptr L11C1

	CALL __EXX
	TEST ch,64
	STC
	RETNZ 

	pushf
	OR ch,64
	popf
	CALL __EXX
L11BD:	INC si
	JMP near ptr  L11AB

L11C1:	CMP al, 'E'
	JZ near ptr L11E6
	CALL near ptr L1239
	JNC near ptr L121E
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	CALL near ptr L12B3
	RETC 
	lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
	CALL __EXX
	PUSH cx
	MOV bl,al
	MOV bh,0
	CALL near ptr L1008		; convert integer HL to REAL HLDEBC
	CALL near ptr L09E9
	CALL __EXX
	POP cx
	RETC 
	TEST ch,64
	JZ near ptr L11E3
	DEC cl
L11E3:	CALL __EXX
	JMP near ptr  L11BD

L11E6:	CALL near ptr L121E
	RETC 

	CALL __EXX
	pushf
	OR ch,16
	popf
	INC si

	MOV al,byte ptr [si+0]

	CMP al, '+'
	JZ near ptr L11FC		; jump if '+', ignore it

	CMP al, '-'
	JNZ near ptr L11FE

	pushf
	OR ch,32
	popf			; set bit 5 for negative

L11FC:	INC si
L11FE:	CALL near ptr L1236		; check digit at (IX+0)
	CMC
	RETC 
	MOV cl,al
	INC si
	CALL near ptr L1236		; check digit at (IX+0)
	JNC near ptr L1215
	INC si
	MOV dh,al
	MOV al,cl
	ADD al,al
	ADD al,al
	ADD al,cl
	ADD al,al
	ADD al,dh
	MOV cl,al
L1215:	TEST ch,32
	JZ near ptr L121D
	MOV al,cl
	NEG al
	MOV cl,al
L121D:	CALL __EXX

L121E:	CALL __EXX
	MOV al,cl
	ADD al,80H
	CMP al, 5AH
	RETC 
	CMP al, 0A6H
	CMC
	RETC 
	PUSH cx
	PUSH si
	MOV al,cl
	CALL near ptr L1240
	POP si
	CALL __EXX
	POP cx
	CALL __EXX
	RET

L1236:	; checks if byte at (IX+0)

	MOV al,byte ptr [si+0]

L1239:	; in:	A = byte to check
	; out:	A = 0 .. 9
	;	C-flag set if A is a correct digit
	SUB al, '0'
	CMC
	RETNC 
	CMP al, 10
	RET

L1240:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	OR al, al
	JNS near ptr L1247
	NEG al

L1247:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	SHR al,1
	SHR al,1
	INC al
	MOV bx,-6
	MOV dx,6

L1253:	ADD bx,dx
	DEC al
	JNZ near ptr L1253
	XCHG dx,bx
	MOV si,offset L1277
	ADD si,dx
	CALL near ptr L0F73		; get REAL at address IX
	POP ax
	xchg ah,al
	sahf
	AND al, 3
	JZ near ptr L126E

L1266:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L12B3
	POP ax
	xchg ah,al
	sahf
	DEC al
	JNZ near ptr L1266
L126E:	POP ax
	xchg ah,al
	sahf
	OR al, al
	JNS near ptr L0A97
	CALL __EXX
	JMP near ptr  L0AF5

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

L12B3:	MOV al,bl
	OR al, al
	RETZ 
	pushf
	OR ch,128
	popf
	PUSH cx
	PUSH dx
	MOV al,bh
	CALL near ptr L0B7A
	CALL near ptr L0B7A
	ADD al,bh
	MOV bh,al
	mov bp,sp
	XCHG [bp],bx
	ADC bx,dx
	XCHG dx,bx
	POP bx
	mov bp,sp
	XCHG [bp],bx
	ADC bx,cx
	MOV ch,bh
	MOV cl,bl
	POP bx
	JNC near ptr L12D6
	CALL near ptr L0B7B
	INC bl
	STC
	RETZ 

L12D6:	MOV al,bl
	ADD al,3
	MOV bl,al
	pushf
	AND ch,01111111b
	popf
	RET


L149B:   ; LIB
	; sets current FIB address to standard output (OUTPUT)
	; in:	HL = FIB address
	; out:	-
	mov bp,sp
	XCHG [bp],bx		; LIB, for search ???
	MOV word ptr L00E4,bx		; save return address
	mov bp,sp
	XCHG [bp],bx
	PUSH bx
	MOV bx,offset OUTPUT
	MOV word ptr L00E2,bx
	POP bx
	RET


L14E8:   MOV ch,0                     ; ^Z is ignored when typed in

L14EA:   MOV bx,offset BUFLEN
	MOV al,byte ptr [bx]
	CMP al, 7FH			; < 127
	JC near ptr L14F4		; jump if < 127

	MOV al,7EH 		; trunc to a length of 126 characters
L14F4:	MOV cl,al
	MOV byte ptr [bx],7EH
	MOV bx,word ptr L00D2
	MOV word ptr L00D4,bx
L14FD:	MOV dh,0

L14FF:	CALL near ptr L03E1		; A = character from console
	MOV byte ptr [bx],al

	MOV dl,1
	CMP al, 8			; backspace ?
	JZ near ptr L153F
	CMP al, 7FH
	JZ near ptr L153F

	DEC dl			; E = 0
	CMP al, 18H			; insert ?
	JZ near ptr L153F
	CMP al, 1BH			; escape ?
	JZ near ptr L153F

	CMP al, 1AH			; ctrl-z ?
	JZ near ptr L1550		; jump to quit with ^Z

	CMP al, 0DH			; return ?
	JZ near ptr L1556

	CMP al, ' '                     ; space ?
	JNC near ptr L1533
	CMP al, 3			; ctrl-break ?
	JNZ near ptr L14FF
	MOV al,byte ptr CBREAK
	OR al, al
	JZ near ptr L14FF		; ignore character if no CBREAK handler
	MOV si,word ptr L00E4		; IX = return address
	JMP near ptr  L2016 		; force userbreak

L1533:	MOV al,cl
	CMP al, dh
	JZ near ptr L14FF
	MOV al,byte ptr [bx]
	INC dh
	INC bx
	CALL near ptr L03C9		; print character
	JMP near ptr  L14FF

L153F:	DEC dh
	JS near ptr L14FD
	DEC bx
	CALL near ptr L0200
	DB 8,' ',8,0               ; backspace, space, backspace
	DEC dl
	JZ near ptr L14FF
	JMP near ptr  L153F

L1550:	INC ch
	DEC ch
	JZ near ptr L14FF
	JMP near ptr  L155A 		; quit with ^Z

L1556:	INC ch
	DEC ch
	JNZ near ptr L155E		; jump if quit with 0DH,0Ah

L155A:	; quit with ^Z
	MOV byte ptr [bx],1AH
	JMP near ptr  L1566 		; quit

L155E:	CALL near ptr L01E1		; print CR, LF
	MOV byte ptr [bx],0DH
	INC bx
	MOV byte ptr [bx],0AH
L1566:	INC bx
	MOV word ptr L00D6,bx		; save end address
	RET

L156B:   ; read character from current file or device
	; out:	A = character read
	MOV bx,word ptr L00E2
	MOV al,byte ptr L00D0		; read IORESULT
	OR al, al
	JNZ near ptr L15ED		; jump if error occurred, return EOF

	MOV al,byte ptr [bx]
	TEST al,32
	JNZ near ptr L15E9		; jump if pre-read character present

	AND al, 0FH
	JNZ near ptr L15AB		; jump if device

	; read character from text file
	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL
	MOV al,byte ptr [bx]		; A = FIB_PTR
	OR al, al
	JNS near ptr L1597		; < 128 ?

	; read next FIB_BUF
	MOV cl,14H 		; sequential read
	PUSH bx
	CALL near ptr L19BA		; sequential read from current position
				; to FIB_BUF
	POP bx
	JZ near ptr L1595		; jump if no error

	; error occurred, fill first byte of FIB_BUF with ^Z (end of file)
	PUSH bx
	OFF_HL FIB_PTR FIB_BUF
;	 LD DE,2EH
;	 ADD HL,DE
	MOV byte ptr [bx],1AH
	POP bx			; restore to FIB_PTR

L1595:	XOR al, al
	MOV byte ptr [bx],al		; FIB_PTR = 0

L1597:	INC byte ptr [bx]
	ADD al,FIB_BUF - FIB_PTR	; 2EH
	MOV dl,al
	MOV dh,0
	ADD bx,dx
	MOV al,byte ptr [bx]
	CMP al, 1AH			; first character = ^Z (eof)
	JNZ near ptr L15E0

	MOV bx,word ptr L00E2
	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL
	DEC byte ptr [bx] 		; FIB_PTR does not move beyond ^Z
	JMP near ptr  L15E0

L15AB:	DEC al			; device = 1, 'CON:' ?
	JNZ near ptr L15C9		; jump if not 'CON:'
	MOV bx,word ptr L00D4
	MOV dx,word ptr L00D6
	OR al, al
	SBB bx,dx
	JC near ptr L15BF		; read from buffer until current = end address

	MOV ch,0FFH
	CALL near ptr L14EA

L15BF:	MOV bx,word ptr L00D4		; HL = data pointer
	MOV al,byte ptr [bx]		; A = data byte
	INC bx
	MOV word ptr L00D4,bx		; save new data pointer
	JMP near ptr  L15E0 		; put character in FIB_CHR

L15C9:	DEC al			; device = 2, 'KBD:' ?
	JNZ near ptr L15D2		; jump if not 'KBD:'

	CALL near ptr CONINPTR
	MOV al,bl
	JMP near ptr  L15E0 		; put character in FIB_CHR

L15D2:	DEC al			; skip 'LST:' (output device)
	DEC al			; device = 4, 'AUX:' ?
	JNZ near ptr L15DC		; jump if not 'AUX:', then device = 'USR:'

	CALL near ptr AUXINPTR
	MOV al,bl
	JMP near ptr  L15E0 		; put character in FIB_CHR

L15DC:	CALL near ptr USRINPTR
	MOV al,bl

L15E0:	MOV bx,word ptr L00E2		; HL = address of FIB
	pushf
	OR byte ptr [bx],32
	popf		; set write semaphore
				; pre-read character ready
	OFF_HL 0 FIB_CHR
;	 INC HL
	MOV byte ptr [bx],al		; put character in character buffer
	OFF_HL FIB_CHR 0
;	 DEC HL
	RET

L15E9:	OFF_HL 0 FIB_CHR
;	 INC HL
	MOV al,byte ptr [bx]		; read pre-read from character buffer
	OFF_HL FIB_CHR 0
;	 DEC HL
	RET

L15ED:	MOV al,1AH
	RET

L15F0:	PUSH bx
	MOV bx,word ptr L00E2		; HL = address of FIB
	MOV al,byte ptr [bx]		; A = flags byte
	AND al, 0FH

	CMP al, 6			; device 6 = used for 'val'
	JZ near ptr L1622		; quit immediately is device = 6

L15FB:	CALL near ptr L156B		; read character from file or device
	CMP al, 21H
	JNC near ptr L160A
	CMP al, 1AH
	JZ near ptr L160A
	pushf
	AND byte ptr [bx],11011111b
	popf
	JMP near ptr  L15FB

L160A:	MOV dx,offset L005D
	MOV ch,1EH
L160F:	PUSH cx
	PUSH dx
	CALL near ptr L156B		; read character from file or device
	POP dx
	POP cx
	CMP al, 21H
	JC near ptr L1620
	pushf
	AND byte ptr [bx],11011111b
	popf
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	INC dx
	DEC ch
	JNZ near ptr L160F
L1620:	XOR al, al
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
L1622:	POP bx
	RET

L1624:	; in:	-
	; out:	B = 0 and IX = L005D --> no '-' found
	;	B = 1 and IX = L005E --> a '-' found
	;	Zero --> end of string reached
	MOV si,offset L005D
	MOV al,byte ptr [si+0]
	OR al, al
	RETZ 			; quit if zero

	MOV ch,0			; assume positive
	CMP al, '-'                     ; minus sign ?
	RETNZ 			; quit with NonZero of something else

	INC ch			; no, negative number
	INC si			; next character
         ; quit with NonZero (INC B)
	RET

L1636:	; checks a correct termination of the parsed string
	; in:	IX = position of character after parsed string
	;	Carry flag --> IORESULT = 10H
	; out:	NonCarry if '\0' found at (IX), A not changed
	;	Carry if no '\0' found at (IX), A changed
	; changes: AF, IORESULT

	JC near ptr L163D

	INC byte ptr [si+0]		; string correct ended ?
	DEC byte ptr [si+0]
	RETZ 			; yes, quit

L163D:	MOV al,10H
	MOV byte ptr L00D0,al		; IORESULT = 10H, Error in numeric format
	STC
	RET


L164E:   ; store as INTEGER
	XOR al, al			; store as INTEGER

L164F:	; in:	HL = destination address for INTEGER value
	;	IX = address of first ASCII character
	;	C = 0, store as INTEGER
	;	C = > 0, store as BYTE
	; out:	HL = INTEGER value
	;	DE = destination address + 1
	MOV cl,al
	PUSH cx
	CALL near ptr L15F0
	POP cx
         CALL near ptr L1624                 ; read an optional sign
         RETZ                       ; quit if end of ASCII-text

	; B = 0, no sign
	; B = 1, a sign
	PUSH cx
	PUSH bx			; save destination address

	CALL near ptr L07F7		; convert hexadecimal or decimal to HL

	POP dx			; DE = destination address
	POP cx			; B = sign flag
	; Carry if error at conversion

	CALL near ptr L1636		; conversion ended correct ?
	RETC 			; quit if error

	DEC ch			; B = 1 ?, a sign read ?
	CALLZ L0783		; Zero --> negate HL

	XCHG dx,bx 		; HL = destination address
				; DE = INTEGER value
	MOV byte ptr [bx],dl		; store low-byte

	INC cl			; byte ?
	DEC cl
	JNZ near ptr L1670		; yes, only low-byte stored

	INC bx
	MOV byte ptr [bx],dh		; store high-byte

L1670:	XCHG dx,bx
	RET

L1671:	; in:	HL = destination address for LONGINT value
	;	IX = address of first ASCII character
	; out:	DE:HL = LONGINT value
	CALL near ptr L15F0

	CALL near ptr L1624		; read an optional sign
	RETZ 

	; B = 0, no sign
	; B = 1, a sign
	PUSH bx			; save destination address
	PUSH cx			; save sign flag

	CALL near ptr A2L 		; convert hexadecimal or decimal to DE:HL

	POP cx			; B = sign flag

	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	DEC ch
	CALLZ L_NEG		; Zero --> negate LONGINT DE:HL
	POP ax
	xchg ah,al
	sahf

	POP cx			; BC = destination address
	; Carry if error at conversion

	CALL near ptr L1636		; conversion ended correct ?
	RETC 			; quit if error

	PUSH cx			; save destination address
	MOV ch,bh			; BC = low-word
	MOV cl,bl
	POP bx			; HL = destination address

	MOV byte ptr [bx],cl		; store low-word
	INC bx
	MOV byte ptr [bx],ch
	INC bx

	MOV byte ptr [bx],dl		; store high-word
	INC bx
	MOV byte ptr [bx],dh
	MOV bh,ch			; restore low-word
	MOV bl,cl
	; return DE:HL
	RET


L16C6:	; in:	A = character
	; out:	character printed to a device or a file
	MOV bx,word ptr L00E2		; HL = FIB address
	MOV cl,al			; C = character data

	MOV al,byte ptr L00D0		; read IORESULT
	OR al, al
	RETNZ 			; quit if an error occurred
	MOV al,byte ptr [bx]
	AND al, 0FH
	JNZ near ptr L16E4		; jump if device

	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL			 ; offset to FIB_PTR
	PUSH bx
	MOV al,byte ptr [bx]		; A = low byte of FIB_PTR
	ADD al,FIB_BUF-FIB_PTR	; 2EH, distance between FIB_PTR and FIB_BUF
	MOV dl,al
	MOV dh,0
	ADD bx,dx
	MOV byte ptr [bx],cl		; write character
	POP bx
	INC byte ptr [bx] 		; increase FIB_PTR
	RETP 			; quit if < 128
	JMP near ptr  L170C 		; write buffer if FIB_PTR = 128
				; why not directly to 'LD (HL),0' ???

L16E4:	CMP al, 6
	JZ near ptr L16FD		; what kind of a device is this ????

	POP bx			; pop return address
	MOV ch,0
	PUSH cx			; push BC = character data
	PUSH bx			; push return address

	DEC al			; 1: device = 'CON:' ?
	JZ near ptr CONOUTPTR
	DEC al
	DEC al			; 3: device = 'LST:' ?
	JZ near ptr LSTOUTPTR
	DEC al			; 4: device = 'AUX:' ?
	JZ near ptr AUXOUTPTR
	JMP near ptr  USROUTPTR		; 5: device = 'USR:' ?

L16FD:	MOV bx,word ptr L00E8
	MOV al,byte ptr L00EA
	CMP al, byte ptr [bx]
	RETZ 
	INC byte ptr [bx]
	MOV dl,byte ptr [bx]		; DE = index
	MOV dh,0
	ADD bx,dx
	MOV byte ptr [bx],cl		; write character in buffer
	RET

L170C:	; flushes the buffer to disk if it is not empty
	MOV bx,word ptr L00E2
	OFF_HL 0 FIB_PTR
;	 INC HL
;	 INC HL
	MOV al,byte ptr [bx]		; A = low byte of FIB_PTR
	OR al, al
	RETZ 			; quit if nothing written
	MOV byte ptr [bx],0		; reset to start of FIB_BUF

	MOV cl,15H 		; sequential write 128 bytes
	CALL near ptr L19BA		; write FIB_BUF to current position
	RETZ 			; quit if no error
	MOV al,0F0H
	MOV byte ptr L00D0,al		; IORESULT = 0F0H, Disk write error
	RET


L1726:   ; LIB, print INTEGER
         ; in:    value to print is pushed on stack
         ;        HL = size in characters
         ;        (L00D2) destination address for ASCII result
         ; out:   -
         POP cx                     ; LIB
	POP dx
	PUSH cx
	MOV si,word ptr L00D2
	TEST bh,128
         JZ near ptr L1737                 ; jump if size = positive

         CALL near ptr L0783                 ; negate HL (size)
         XCHG dx,bx                   ; HL = value, DE = size
         JMP near ptr  L1745

L1737:   XCHG dx,bx                   ; HL = value, DE = size
	TEST bh,128
         JZ near ptr L1745                 ; jump if value = positive

         CALL near ptr L0783                 ; negate HL
         MOV byte ptr [si+0],'-'              ; print minus sign
	INC si

L1745:   PUSH dx                    ; push size

         CALL near ptr L07C6                 ; unsigned INTEGER to ASCII

L1749:   ; print string from character buffer (L00D2) with leading spaces if
         ; pushed size > characters written in buffer
         ; in:    total size wanted is pushed
         POP bx                     ; size, ( WRITELN(int : size) )

         CALL near ptr L04C8                 ; int to byte
         ; A = size

         MOV dx,word ptr L00D2              ; DE = start of ASCII buffer
	PUSH si
	POP bx
	OR al, al
         SBB bx,dx
         MOV cl,bl                     ; C = characters written in buffer

         XCHG dx,bx                   ; HL = start of ASCII buffer

L1759:   ; in:   HL = start of ASCII buffer
         ;        C = characters written in buffer
         SUB al, cl                      ; size - characters written
         JC near ptr L176A                 ; jump if size is less, no spaces first
         JZ near ptr L176A                 ; jump if size is equal, no spaces first

         MOV ch,al                     ; B = number of spaces to add
         PUSH bx                    ; save start of ASCII buffer

L1760:   MOV al,' '
	PUSH cx
         CALL near ptr L16C6                 ; write space character
	POP cx
         DEC ch
	JNZ near ptr L1760                 ; repeat

         POP bx                     ; HL = start of ASCII buffer

L176A:   MOV ch,cl                     ; B = characters in ASCII buffer
	INC ch

L176C:	DEC ch
         RETZ                       ; quit if all printed (or empty)

         MOV al,byte ptr [bx]                  ; A = chacacter to print
	PUSH cx
	PUSH bx
         CALL near ptr L16C6                 ; print character
	POP bx
	POP cx
         INC bx                     ; next one
	JMP near ptr  L176C

L1779:   ; LIB, print REAL
         ; in:    push REAL
         ;        push size
         ;        HL = number of digits after decimal point
         POP cx                     ; return address

         POP dx                     ; DE = size of real

         CALL __EXX
	POP bx			; HLDEBC = REAL to be printed
	POP dx
	POP cx
	CALL __EXX

         PUSH cx                    ; return address

         MOV si,word ptr L00D2              ; IX = destination address for ASCII
         PUSH dx                    ; push size

         CALL near ptr L1027                 ; convert REAL to ASCII

         JMP near ptr  L1749


L18A4:	mov bp,sp
	XCHG [bp],bx
	MOV word ptr L00E4,bx
	mov bp,sp
	XCHG [bp],bx
	MOV word ptr L00E2,bx
	MOV al,byte ptr [bx]
	AND al, 0C0H 		; read or write flags set?
	RETNZ 			; yes, quit

L18B0:	MOV al,4
	MOV byte ptr L00D0,al		; IORESULT = 4, File not open
	RET

L19BA:	; write FIB_BUF to current position according to FCB
	MOV bx,word ptr L00E2		; HL = address of FIB
	PUSH bx
	PUSH cx			; save record to write

	OFF_HL 0 FIB_BUF
;	 LD DE,FIB_BUF		 ; offset to BUFFER
;	 ADD HL,DE
	XCHG dx,bx
	MOV cl,1AH 		; C = set dma at FIB buffer
	CALL near ptr MSXDOS

	POP cx
	POP bx
	OFF_HL 0 FIB_FCB
;	 LD DE,FIB_FCB		 ; offset to FCB
;	 ADD HL,DE
	XCHG dx,bx
	CALL near ptr MSXDOS
	OR al, al
	RET


L1A26:	MOV al,91H
	MOV byte ptr L00D0,al		;  IORESULT = 91H, Seek beyond end-of-file
	RET


L2016:   MOV dx,0001                 ; user break, D = 0 with error code = 1
	JMP near ptr  L202C

L2027:   ; Run-time error
	POP si

         MOV dl,al                     ; E = error code
	MOV dh,2			; Run-time rror

L202C:   ; in:    D = 0, user break
	;	D = 1, I/O error, E = error number
	;	D = 2, Run-time error	E = error number
	PUSH dx
	CALL near ptr L037A
	POP dx

	XOR al, al
	MOV byte ptr CBREAK,al
	MOV bx,word ptr L00CE
	MOV al,bh
	OR al, bl
	PUSH si
	POP bx
         MOV cx,word ptr L00CC
	SBB bx,cx
	MOV cx,0015H
	ADD bx,cx
	MOV word ptr L00CE,bx
	OR al, al
	JNZ near ptr L2054
	PUSH dx			; save error type and code

	PUSH dx
	PUSH bx			; address where error occurred
         CALL near ptr ERRORPTR
	POP dx			; restore error type and code

L2054:	MOV al,dh
	OR al, al
	JNZ near ptr L206C
	CALL near ptr L0200		; D = 0 >> User Break
	DB '^C',0DH,0AH
	DB 'User break',0
	JMP near ptr  L2097

L206C:   DEC al
	JNZ near ptr L207A
	CALL near ptr L0200		; D = 1 >> I/O error
L2075	EQU $+3
	DB 0DH,0AH,'I/O',0
	JMP near ptr  L2088

L207A:	CALL near ptr L0200		; D = 2 >> Run-time error
	DB 0DH,0AH,'Run-time',0

L2088:	CALL near ptr L0200
	DB ' error ',0

L2093:	MOV al,dl
	CALL near ptr L04B4

L2097:	CALL near ptr L0200
	DB ', PC=',0
	MOV bx,word ptr L00CE
	CALL near ptr L04AF
	JMP near ptr  L20BD

L20A8:   CALL near ptr L0200
	DB 'Not enough memory',0
L20BD:	CALL near ptr L0200
	DB 0DH,0AH,'Program aborted',0DH,0AH,0

L20D4:   MOV al,byte ptr L00D8
	OR al, al
;         JP Z,L278E
	MOV cl,0
	CALL near ptr MSXDOS

L20DE:	POP bx
	POP dx
	POP dx
	JMP bx

;L20E2: