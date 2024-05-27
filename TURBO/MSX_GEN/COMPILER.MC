; ^QW: find current word
; ^QS: find current word without first letter (for names that start with an
;      underscore)

; - define the symbol 'MSX' to compile the msx compiler
;   otherwise the PC version will be generated

; - define the symbol 'USELIB' to compile all library routines
; - define the symbol 'NEWEXT' to use the new external routine
; - define the symbol 'EDIT' to use the editor

;EDIT:
;NEWEXT:

USETIMER:

IFNDEF MAKEPC
MSX:
ENDIF

IFDEF MSX
MSXDOS	EQU 5
USELIB:
ENDIF

UPCASE	EQU L04A6

	EXTRN TURBOERRORMESSAGES

	PUBLIC COMPILED
         PUBLIC L2D01               ; ask for Yes or No
         PUBLIC L2E76               ; wait for escape
         PUBLIC L4543,L4544,L4546,L4548

	PUBLIC L5271,L5287,L5639,L58C5,L5960,L59E9,L5A0C,L5A17,L5CAD
	PUBLIC L5D76,L5E8E,L5E97,L5EA2,L5EB0,L5EBB,L5EBE,L5ED0,L5EDD,L5EE8
	PUBLIC L6148,L6201,L620F,L6540,L65D5,L65DE,L65E7,L65EF,L65F7,L677F
	PUBLIC L678B,L6A5C,L6B5E,L6CC2,L6D24,L6D43,L6E54
         PUBLIC PARSE_O_IL_C,OP_L_I
	PUBLIC L6F0B,L6F13,L6F1B,L6F5E,L6F66,L6F6E,L6F7E
	PUBLIC L72D4,L72DA,L72E1
	PUBLIC L7B59,L7B5E,L7B6D,L7B6F
	PUBLIC L7B71,L7B72,L7B73,L7B74,L7B8B,L7B9E
	PUBLIC L7BA3,L7BA7
	PUBLIC L7BF1,L7BF2,L7BF3

	PUBLIC TEMPID

	; defined in slib.mac
	EXTRN L7638,L77B1

	INCLUDE STDIO.INC

	INCLUDE LIBDEFS.INC

	; include file with generated EQU's from RUNTIME.MAP
	INCLUDE LIBCONST.INC

L20E2:

;         LD A,'A'
;         LD BC,'A'*256+'P'
;         LD HL,File1
;         OR A
;         CALL SetExtension
;
;         CALL PrintASCIIZUPCASED
;         CALL L01E1                 ; print CR, LF
;
;         LD HL,File2
;         CALL PrintASCIIZUPCASED
;         CALL L01E1                 ; print CR, LF
;
;         LD A,'A'
;         LD BC,'A'*256+'P'
;         LD HL,File2
;         OR A
;         CALL SetExtension
;
;         CALL PrintASCIIZUPCASED
;         CALL L01E1                 ; print CR, LF
;
;         LD A,'A'
;         LD BC,'A'*256+'P'
;         LD HL,File3
;         OR A
;         CALL SetExtension
;
;         CALL PrintASCIIZUPCASED
;         CALL L01E1                 ; print CR, LF
;
;         LD A,'A'
;         LD BC,'A'*256+'P'
;         LD HL,File4
;         OR A
;         CALL SetExtension
;
;         CALL PrintASCIIZUPCASED
;         CALL L01E1                 ; print CR, LF
;
;         LD A,'A'
;         LD BC,'A'*256+'P'
;         LD HL,File5
;         OR A
;         CALL SetExtension
;
;         CALL PrintASCIIZUPCASED
;         CALL L01E1                 ; print CR, LF

         DB 0c3h
	DW  L215E

;File1:   DB 'TEST.',0,0,0,0,0,0,0,0,0,0
;File2:   DB '\E',0,0,0,0,0,0,0,0,0,0
;File3:   DB 'E\E',0,0,0,0,0,0,0,0,0,0
;File4:   DB 'DIR.PAS',0,0,0,0,0,0,0,0,0,0
;File5:   DB 'TEST.PAS',0,0,0,0,0,0,0,0,0,0

PRINT_SYNTAX:
	DB 0cdh
	DW  L0200
         DB 'Syntax: TURBO <filename> [/C|/H] [/Sxxxx] [/Exxxx] [/Fxxxx]'
; 33e         DB ' [/R[-|<file>]]'
         DB 13,10
	DB '/C            compiles <filename> to COM-file',13,10
	DB '/H            compiles <filename> to CHAIN-file',13,10
	DB '/Sxxxx        code start address (hexadecimal), min. ',0

	DB 21h
	DW _L20E2
	DB 0cdh
	DW  L04AF

	DB 0cdh
	DW  L0200
	DB 13,10
	DB '/Exxxx        data end address (hexadecimal), max. ',0

IFDEF MSX
	DB 02ah
	DW 0006H
ELSE
	DB 02ah
	DW L0006
ENDIF
	DB 01h
	DW -708
	DB 09h
	DB 0cdh
	DW  L04AF

	DB 0cdh
	DW  L0200
	DB 13,10
	DB '/Fxxxx        find runtime error at address xxxx (hexadecimal)',13,10
	DB '/R<file>      generates this error file with a compiler error',13,10
	DB '/R-           generates no error file'
	DB 13,10
	DB 0			; end of string

	DB 0eh,0
	DB 0cdh
	DW  MSXDOS		; quit program


GETPARAMERRORFILENAME:
	DB 0cdh
	DW  L0200
	DB 10,'commandline: wrong error file name',13,10,10,0
	DB 0c3h
	DW  PRINT_SYNTAX

GETPARAMHEXNUMBER:
	DB 0cdh
	DW  L0200
	DB 10,'commandline: error in hexadecimal number',13,10,10,0
	DB 0c3h
	DW  PRINT_SYNTAX

GETPARAMUNKNOWNOPTION:
	DB 0cdh
	DW  L0200
	DB 10,'commandline: illegal option',13,10,10,0
	DB 0c3h
	DW  PRINT_SYNTAX

GETPARAM:; in:    -
	; out:	DE = destination for file name
	;	Carry set if error occurred
	;	BC = position of error
	DB 0d5h

         DB 21h
	DW L0080
	DB 5eh
	DB 1ch
	DB 16h,0
	DB 019h

         DB 0afh
	DB 77h		; quit command-line with a '\0'

	DB 7bh
	DB 3dh			; was it 1 ?
	DB 37h

	DB 0d1h

	DB 0c8h			; quit with Carry if command-line = empty

	DB 21h
	DW L0080+1		; start of command-line
	DB 3eh,'P'
	DB 01h
	DW 'A'*256+'S'
	DB 0cdh
	DW  PARSENAME		; parse with default extension 'PAS'

         DB 0b7h
         DB 37h
         DB 0c0h                     ; quit with carry if error occurred

         DB 0e5h

	DB 21h
	DW L0080+1
	DB 11h
	DW ERRORFILENAME-1
	DB 3eh,'E'
	DB 01h
	DW 'R'*256+'R'
	DB 0cdh
	DW  PARSENAME		; parse with default extension 'ERR'

         DB 0e1h

	DB 0b7h
	DB 37h
         DB 0c0h                     ; quit with carry if error occurred

	DB 2bh
	DB 44h
	DB 4dh

	DB 21h
	DW ERRORFILENAME
GETPAR_A:
	DB 23h
	DB 7eh
	DB 0b7h
	DB 20h,(GETPAR_A)-$-1		; repeat while not end of string

GETPAR_B:
	DB 2bh
	DB 7eh
	DB 0feh, '.'
	DB 20h,(GETPAR_B)-$-1

	DB 23h

	; add '.ERR'
	DB 36h,'E'
	DB 23h
	DB 36h,'R'
	DB 23h
	DB 36h,'R'
	DB 23h
	DB 36h,0

GETPARLP:DB 03h
	DB 0ah
	DB 0b7h
	DB 0c8h			; quit with NonCarry if zero found

	DB 0feh, '/'
	DB 20h,(GETPARLP)-$-1

GETPAR1:
	DB 03h
	DB 0ah
	DB 0cdh
	DW  UPCASE

	DB 0feh, 'C'                     ; '/C' ?
	DB 20h,(GETPAR2)-$-1		; no, next

	; set COM file = TRUE
	DB 3eh,2			; compile to Com-file
	DB 32h
	DW L44F3
	DB 0c3h
	DW  GETPARLP

GETPAR2:
	DB 0feh, 'H'                     ; '/H' ?
	DB 20h,(GETPAR3)-$-1		; no, next

	; set CHAIN file = TRUE
	DB 3eh,3			; compile to cHn-file
	DB 32h
	DW L44F3
	DB 0c3h
	DW  GETPARLP

GETPAR3:
	DB 0feh, 'S'                     ; '/S' ?
	DB 20h,(GETPAR4)-$-1		; no, next

	DB 0cdh
	DW  GETHEX		; parse hexadecimal number
	DB 0dah
	DW GETPARAMHEXNUMBER

	; set start address = HL
	DB 22h
	DW L44F4
	DB 0bh
	DB 0c3h
	DW  GETPARLP

GETPAR4:
	DB 0feh, 'E'                     ; '/E' ?
	DB 20h,(GETPAR5)-$-1		; no, next

	DB 0cdh
	DW  GETHEX		; parse hexadecimal number
	DB 0dah
	DW GETPARAMHEXNUMBER

	; set end address = HL
	DB 22h
	DW L44F6
	DB 0bh
	DB 0c3h
	DW  GETPARLP

GETPAR5:
	DB 0feh, 'R'                     ; '/R' ?
	DB 20h,(GETPAR6)-$-1

	; parse filename or '-'
	DB 03h
	DB 0ah
	DB 0feh, '-'                     ; '/R-' ?
	DB 0cah
	DW GETPAR51		; jump for no error file

	; file name is given
	; set to string after '/R'
	DB 0c5h			; save start address

	DB 60h			; HL = BC = start of new file name
	DB 69h
	DB 11h
	DW ERRORFILEINFO
	DB 3eh,'E'
	DB 01h
	DW 'R'*256+'R'
	DB 0cdh
	DW  PARSENAME

	DB 0d1h			; DE = start address
	DB 0dah
	DW GETPARAMERRORFILENAME

	DB 0e5h

	DB 0b7h
	DB 0EDH,052h		; HL - DE, end - start
	DB 44h			; BC = length
	DB 4dh
	DB 21h
	DW ERRORFILENAME
	DB 0ebh 		; HL = source
				; DE = destination
	DB 0edh,0b0h			; fill ErrorFileName with new name

	DB 0afh
	DB 12h		; mark end of destination file name

	DB 0e1h			; HL = address after file name

	DB 44h			; BC = address after file name
	DB 4dh
	DB 0c3h
	DW  GETPARLP

GETPAR51:; no error file
	; set file name to ""
	DB 21h
	DW ERRORFILENAME
	DB 36h,0		; clear file name
	DB 0c3h
	DW  GETPARLP

GETPAR6:
	DB 0feh, 'F'                     ; '/F' ?
	DB 37h
         DB 0c2h
	DW GETPARAMUNKNOWNOPTION

	DB 0cdh
	DW  GETHEX		; parse hexadecimal number
	DB 0dah
	DW GETPARAMHEXNUMBER

	; set search address = HL
	DB 22h
	DW L00CE
	DB 3eh,2
	DB 32h
	DW L7900		; compilation with search
	DB 0bh
	DB 0c3h
	DW  GETPARLP

GETHEX:
	DB 21h
	DW 0

GETHEX1:
	DB 03h
	DB 0ah
	DB 0b7h
	DB 0c8h			; quit with NonCarry
	DB 0feh, ' '
	DB 0c8h			; quit with NonCarry

	DB 0bh
	DB 0feh, '/'
	DB 0c8h			; quit with NonCarry
	DB 03h

	DB 0cdh
	DW  UPCASE

	DB 0d6h, '0'
	DB 0d8h			; error, no digit
	DB 0feh, 10
	DB 3fh
	DB 30h,(GETHEX2)-$-1		; jump if '0'-'9'

	DB 0d6h, 7
	DB 0d8h			; error, no digit and < 'A'
	DB 0feh, 16
	DB 3fh
	DB 0d8h			; return with Carry if >= 16

GETHEX2:
	DB 029h
	DB 029h
	DB 029h
	DB 029h
	DB 0b5h
	DB 6fh

	DB 18h,( GETHEX1)-$-1

L20E5:
IFDEF MSX
	DB 02ah
	DW 0006H
ELSE
	DB 02ah
	DW L0006
ENDIF
	DB 0c1h
	DB 0f9h
	DB 0c5h

	DB 11h
	DW -1024
	DB 019h
         DB 22h
	DW L4548              ; highest free address 1Kbyte below call 5

L20F2:	DB 21h
	DW L7AD7		; address of temp buffer (L00D2)
	DB 01h
	DW 0000
         DB 0cdh
	DW  L0364                 ; LIB

	DB 0c9h

L215E:
IFDEF MSX
	DB 02ah
	DW 0006H
ELSE
	DB 02ah
	DW L0006
ENDIF
	DB 01h
	DW -708
	DB 09h

	DB 22h
	DW L44F6		; compile end address

         DB 0cdh
	DW  INITFILEIO

	DB 0cdh
	DW  L0200
IFDEF MSX
         DB 'Z80 TURBO Pascal compiler,             Version 3.3f (DOS 1/2) ',13,10
ELSE
         DB 'Z80 TURBO Pascal cross-compiler,       Version 3.3f ',13,10
ENDIF
         DB 'Copyright (C) MSX computer club Enschede, ''1993-''2000',13,10
	DB 0

	DB 11h
	DW L7AD7		; address of temp buffer
	DB 0afh
	DB 12h
         DB 0cdh
	DW  GETPARAM              ; get command line parameters
	DB 0dah
	DW PRINT_SYNTAX 	; print syntax if error and quit program

	DB 0eh,19H
	DB 0cdh
	DW  MSXDOS		; get logged drive
	DB 3ch
	DB 32h
	DW LOGDRV		; 1 = A:, 2 = B: etc.
         DB 0cdh
	DW  L20E5

         DB 3eh,'P'
         DB 01h
	DW 'A'*256+'S'
         DB 21h
	DW L7AD7+1
         DB 0b7h
         DB 0cdh
	DW  SETEXTENSION

         DB 21h
	DW L7AD7+1              ; address of filename
         DB 11h
	DW L451D                ; DE = handle/FCB address
         DB 3eh,'P'
         DB 01h
	DW 'A'*256+'S'
         DB 0cdh
	DW  PARSENAME             ; parse filename

         DB 0cdh
	DW  L2827                 ; Compile

L223B:	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 0eh,0
	DB 0cdh
	DW  MSXDOS


L232E:	DB 0cdh
	DW  L0200
	DB 'Free: ',0

L2338:	DB 0e5h
	DB 0d5h
	DB 0b7h
	DB 0EDH,052h
	DB 0cdh
	DW  L2E5C		; print HL in decimal
	DB 0cdh
	DW  L0200
	DB ' bytes (',0
	DB 0e1h
	DB 0cdh
	DW  L04AF
	DB 3eh,'-'
	DB 0cdh
	DW  L03C9		; print '-'
	DB 0e1h
	DB 0cdh
	DW  L04AF
	DB 3eh,')'
	DB 0cdh
	DW  L03C9		; print ')'
	DB 0c3h
	DW  L01E1 		; print CR, LF

ENVTPOUT:DB 'TPOUT',0

L27D7:

;         LD HL,L451D                ; assume work filename FCB
;         LD DE,CodeFile
;         LD BC,65                   ; handle/FCB length
;         LDIR

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 0cah
	DW TPOUT_OLD_STYLE       ; jump if DOS 1

         ; DOS 2

         DB 3ah
	DW L451D
         DB 32h
	DW CODEFILE

         DB 21h
	DW ENVTPOUT
         DB 11h
	DW CODEFILE + 1
         DB 06h,64
         DB 0eh,6Bh
         DB 0cdh
	DW  MSXDOS                ; retrieve TPOUT environment item value
         DB 0b7h
         DB 0c2h
	DW TPOUT_OLD_STYLE      ; switch to the old style if error occurred

TPOUT_SCAN:
         DB 1ah
         DB 0b7h
         DB 28h,(TPOUT_SCAN_END)-$-1

         DB 13h
         DB 18h,( TPOUT_SCAN)-$-1

TPOUT_SCAN_END:
         DB 21h
	DW L451D + 1

TPOUT_COPY:
         DB 7eh
         DB 12h
         DB 23h
         DB 13h
         DB 0b7h
         DB 20h,(TPOUT_COPY)-$-1

         DB 0c3h
	DW  L27D9                   ; ready

TPOUT_OLD_STYLE:
         DB 21h
	DW L451D                ; assume work filename FCB

         DB 11h
	DW CODEFILE

         DB 01h
	DW 65                   ; handle/FCB length
         DB 0edh,0b0h

L27D9:
IFDEF MSX
	DB 02ah
	DW 0006H
ELSE
	DB 02ah
	DW L0006
ENDIF
	DB 22h
	DW L790A		; HL = end of data area

	DB 02ah
	DW L4546		; HL = start of free area
	DB 22h
	DW L7904		; code start address
	DB 0c9h

L2827:   ; Compile
         DB 0cdh
	DW  L27D7

	DB 3ah
	DW L44F3
	DB 0d6h, 2			; to com-file ? (= 2)
;	 DEC A			 ; to memory?
;	 JP Z,L28AA		 ; jump if to memory

;	 DEC A			 ; to com-file?
	DB 0f5h

	DB 20h,(L283C)-$-1		; jump if chain-file

	; to com-file
	DB 3eh,'C'                   ; AHL = 'COM' extension
         DB 01h
	DW 'O'*256+'M'
	DB 18h,( L2841)-$-1

L283C:	; to chain-file
	DB 3eh,'C'                   ; AHL = 'CHN' extension
         DB 01h
	DW 'H'*256+'N'

L2841:   DB 21h
	DW CODEFILE+1
         DB 37h                        ; overrule
         DB 0cdh
	DW  SETEXTENSION

;         LD (L793C),A
;         LD (L793D),HL

	DB 3ah
	DW L7900
	DB 0b7h
	DB 20h,(L2842)-$-1		; skip if already filled in for search

	DB 3eh,1
	DB 32h
	DW L7900		; code generation to disk
L2842:

	DB 02ah
	DW L44F4		; compile start address
	DB 22h
	DW L7904		; new code start address
	DB 02ah
	DW L44F6		; compile end address
	DB 22h
	DW L790A		; new data end address
         DB 02ah
	DW L44F4              ; 33e
         DB 22h
	DW L7BF5+1            ; 33e TODO

         DB 0afh
         DB 32h
	DW CODEFILECREATED

         DB 3ah
	DW L7900
         DB 3dh
         DB 0c2h
	DW L2850                ; skip CodeFile creation if searching

         DB 11h
	DW CODEFILE+1
         DB 0cdh
	DW  DELETEFILE            ; delete old file

         DB 21h
	DW CODEFILE+1
         DB 11h
	DW CODEFILE
         DB 3eh,' '
         DB 01h
	DW ' '*256+' '
         DB 0cdh
	DW  CREATEFILE
         DB 0b7h
         DB 0c2h
	DW L2A5A                ; jump if error
                                    ; error: Disk or directory full

         DB 3eh,255
         DB 32h
	DW CODEFILECREATED     ; CodeFile correct created

L2850:

;         LD HL,L7933+FCB_RECSIZE
;         LD (HL),80H                ; record size = 128
;         INC HL
;         LD (HL),0

	DB 0f1h			; NonZero if chain-file
	DB 21h
	DW L0100
	DB 28h,(L2877)-$-1		; jump if com-file

	DB 02ah
	DW L7904		; HL = code start address

L2877:	DB 22h
	DW L7902
	DB 0ebh

L287B:	DB 02ah
	DW L7904		; HL = code start address
         DB 0b7h
         DB 0EDH,052h                  ; HL - DE
         DB 38h,(L28A9)-$-1                 ; jump if DE > HL

         DB 3ah
	DW L7900
         DB 3dh
         DB 0c2h
	DW L28A9                ; jump if searching
                                    ; don't write runtime library

         DB 01h
	DW CODEFILE

;         LD HL,(L7904)              ; HL = compile start address
;         LD (L0101),HL              ; init start jump at 100H

;         PUSH BC

         DB 0e5h                    ; DE = start address of data
         DB 21h
	DW L7BF5-100H           ; !!!
	DB 019h
	DB 0ebh
         DB 0e1h

         DB 0cdh
	DW  WRITEFILE

         DB 0f5h
         DB 0c4h
	DW CLEANUPCODEFILE
         DB 0f1h
         DB 0b7h
         DB 0c2h
	DW L2A5A                ; jump if error
                                    ; error: Disk or directory full

;         LD HL,_L20E2
;         LD (L0101),HL
;         OR A
;         JP NZ,L2A5A

;         LD L,C
;         LD H,B
;	 LD HL,128
;         ADD HL,DE
;         EX DE,HL
;         JR L287B

L28A9:
	DB 0cdh
	DW  L0200
	DB 0DH,0AH,'Compiling ',0

;         LD DE,L7933

         DB 11h
	DW L451D                ; 33e TODO
         DB 0cdh
	DW  PRINTFILENAME

         DB 3ah
	DW L7900
         DB 3dh
         DB 20h,(L28D0)-$-1                ; jump if searching
                                    ; don't print '--> <filename>'

         DB 0cdh
	DW  L0200
	DB ' --> ',0

         DB 11h
	DW CODEFILE
         DB 0cdh
	DW  PRINTFILENAME
;         CALL L2DF8                 ; print file name in DE

L28D0:	DB 0cdh
	DW  L01E1		; print CR, LF

IFDEF MSX
	DB 21h
	DW 0
	DB 22h
	DW 0FC9EH
ENDIF
         DB 0cdh
	DW  L454A                 ; enter the real compiler

IFDEF MSX
IFDEF USETIMER
         DB 02ah
	DW 0FC9EH
         DB 0e5h
ENDIF    ; USETIMER
ENDIF    ; MSX

	DB 3ah
	DW L7901
	DB 0feh, 0CAH			; abort compilation error, keypressed
         DB 20h,(L28FA)-$-1                ; no, continue

         DB 3ah
	DW L7900
         DB 3dh

         DB 0cch
	DW CLEANUPCODEFILE     ; clean mess up if a '.COM' file
                                    ; was generated, if no search was performed


         DB 0cdh
	DW  L0200
	DB 0DH,0AH,0AH,'Compilation aborted',0
	DB 0c3h
	DW  L223B 		; print CR, LF and go to DOS

CLEANUPCODEFILE:
         DB 3ah
	DW CODEFILECREATED
         DB 0b7h
         DB 0c8h                      ; quit if no CodeFile created

         DB 01h
	DW CODEFILE
         DB 0cdh
	DW  CLOSEFILE             ; try to close the file first

         DB 11h
	DW CODEFILE+1
         DB 0c3h
	DW  DELETEFILE

L28FA:
         DB 0cdh
	DW  L0200
	DB 0DH,0AH,0

IFDEF MSX
IFDEF USETIMER
         DB 0cdh
	DW  L0200
         DB 'Time: ',0

         DB 0e1h
         DB 0cdh
	DW  L2E5C                 ; print HL in 5 decimals

         DB 0cdh
	DW  L0200
         DB 0DH,0AH,0
ENDIF    ; USETIMER
ENDIF    ; MSX

	DB 3ah
	DW L7901
	DB 0b7h
	DB 0c2h
	DW L2970		; jump if error occurred during compiling

         DB 3ah
	DW L7900
	DB 0feh, 2			; searching while compiling?
         DB 20h,(L292A)-$-1                ; no, skip checking

	DB 0cdh
	DW  L2A7A		; print 'Run-time error position '

	DB 0cdh
	DW  L0200
	DB 'not found',0DH,0AH,0
	DB 0c3h
	DW  L223B 		; print CR, LF and go to DOS

L292A:
	DB 02ah
	DW L7904		; HL = code start address
	DB 11h
	DW _L20E2		; DE = first available address
	DB 0b7h
	DB 0EDH,052h
;!	pushf
	DB 019h
;!	popf
	DB 0c4h
	DW L232E		; print free memory between
				; _L20E2 and compile start address
				; if it is there
         DB 0cdh
	DW  L0200
	DB 'Code: ',0
	DB 0edh,5bh
	DW L7904		; DE = code start address
	DB 02ah
	DW L7906		; HL = code end address
	DB 0e5h
	DB 2bh
	DB 0cdh
	DW  L2338
	DB 0d1h
	DB 02ah
	DW L7908		; HL = data start address
	DB 0e5h
	DB 0cdh
	DW  L232E
	DB 0d1h
	DB 13h			; DE = data start address
	DB 02ah
	DW L790A		; HL = data end address
	DB 0cdh
	DW  L0200
	DB 'Data: ',0
         DB 0cdh
	DW  L2338

	DB 3eh,0FFH
	DB 32h
	DW COMPILED		; compilation completed
	DB 0c9h

	DB 0			; hoort bij ErrorFileName
ERRORFILENAME:
	DB 'TURBO.ERR',0           ; 10 bytes
	db 65-10 dup (0)

ERRORFILEPTR:
	DW L7A57
ERRORFILEINFO:
	db 65 dup (0)

ERRORFILEWRITE:
	DB 0ddh,0e1h			; HL = return address
	DB 0c1h			;  C = character to print
	DB 02ah
	DW ERRORFILEPTR
	DB 71h
	DB 23h
	DB 22h
	DW ERRORFILEPTR
	DB 0ddh,0e9h

ERRORFILEMAKE:
	DB 02ah
	DW CON1OUTPTR
	DB 0e5h			; save old routine
	DB 21h
	DW ERRORFILEWRITE
	DB 22h
	DW CON1OUTPTR

	DB 21h
	DW ERRORFILENAME
	DB 11h
	DW ERRORFILEINFO
	DB 3eh,' '
	DB 01h
	DW ' '*256+' '
	DB 0cdh
	DW  CREATEFILE
	DB 20h,(ERRORFILEMAKE1)-$-1

	DB 11h
	DW FILECURRENTINFO
         DB 0cdh
	DW  PRINTFILENAME
	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 02ah
	DW FILEBUFFERLINE
	DB 0cdh
	DW  L2E61		; print line number
	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 0cdh
	DW  GETCOLUMNNUMBER
	DB 68h
	DB 26h,0
	DB 0cdh
	DW  L2E61		; print column number
	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 02ah
	DW L7901
	DB 26h,0
	DB 0cdh
	DW  L2E61		; print error number
	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 3ah
	DW L7901
	DB 47h
	DB 0cdh
	DW  PRINTERRORMESSAGE
	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 3eh,1AH
	DB 0cdh
	DW  L03C9

	DB 02ah
	DW ERRORFILEPTR
	DB 01h
	DW L7A57
	DB 0b7h
	DB 0EDH,042h		; HL = length of data to write

	DB 01h
	DW ERRORFILEINFO
	DB 11h
	DW L7A57
	DB 0cdh
	DW  WRITEFILE		; write to error file
	DB 20h,(ERRORFILEMAKE1)-$-1

	DB 01h
	DW ERRORFILEINFO
	DB 0cdh
	DW  CLOSEFILE

ERRORFILEMAKE1:
	DB 0e1h
	DB 22h
	DW CON1OUTPTR	; restore old routine
	DB 0c9h

GETCOLUMNNUMBER:
	DB 06h,1			; start at column 1
	DB 21h
	DW L79D7		; start of line buffer
	DB 0edh,5bh
	DW FILEBUFFERLASTPOS

GETCOLUMNNUMBER1:
	DB 0cdh
	DW  COMPAREHL_DE
	DB 0d0h			; quit if end found

	DB 7eh
	DB 23h
	DB 0feh, 9
	DB 28h,(GETCOLUMNNUMBERTAB)-$-1	; TAB stop found

	DB 05h
	DB 0feh, 8
	DB 28h,(GETCOLUMNNUMBER1)-$-1	; BackSpace found
	DB 04h

	DB 04h
	DB 18h,( GETCOLUMNNUMBER1)-$-1

GETCOLUMNNUMBERTAB:
	DB 78h
	DB 3dh
	DB 0e6h, 7
	DB 0edh,44h
	DB 0c6h,8
	DB 080h
	DB 47h
	DB 18h,( GETCOLUMNNUMBER1)-$-1

EXPANDLINE:
	; in:	DE = destination for expanded line buffer
	DB 21h
	DW L79D7		; start of line buffer
	DB 06h,1			; start at column 1

EXPANDLINE1:
	DB 7eh
	DB 23h

	DB 0b7h
	DB 28h,(ENDOFLINE)-$-1

	DB 0feh, 9
	DB 20h,(EXPANDLINE2)-$-1

	DB 0cdh
	DW  PRINTTAB		; print spaces
	DB 18h,( EXPANDLINE1)-$-1

EXPANDLINE2:
	DB 12h
	DB 13h

	DB 04h			; next column
	DB 18h,( EXPANDLINE1)-$-1

ENDOFLINE:
	DB 12h
	DB 0c9h


PRINTTAB:; in:	DE = address where to put spaces
	;	B = current column, 1 .. 80
	; out:	DE = address after the new spaces
	;	B = new column
	DB 78h
	DB 3dh
	DB 0e6h, 7
	DB 0edh,44h
	DB 0c6h,8
	DB 4fh
	DB 080h
	DB 47h

PRINTTAB1:
	DB 3eh,' '
	DB 12h
	DB 13h

	DB 0dh
	DB 20h,(PRINTTAB1)-$-1

	DB 0c9h

SCANLEFTRIGHT:
	; in:	D = left column >= 1
	;	E = total size
	;	B = total chars permitted to the left
	;	C = total chars left
	DB 7ah
	DB 0feh, 1
	DB 28h,(SCANLEFTRIGHT1)-$-1

	DB 78h
	DB 0b7h
	DB 28h,(SCANLEFTRIGHT1)-$-1
	DB 05h			; decrease maximum before

	DB 15h			; one more to the left
	DB 1ch
	DB 0dh			; decrease chars left
	DB 0c8h

	DB 18h,( SCANLEFTRIGHT2)-$-1

SCANLEFTRIGHT1:
	DB 7bh
	DB 0feh, 79
	DB 0c8h			; quit if both at the border

SCANLEFTRIGHT2:
	DB 7bh
	DB 0feh, 79
	DB 28h,(SCANLEFTRIGHT)-$-1	; continue with other side

	DB 1ch			; one more to the right
	DB 0dh			; decrease chars left
	DB 0c8h

	DB 18h,( SCANLEFTRIGHT)-$-1

L2970:
         DB 0f5h
         DB 0cdh
	DW  CLEANUPCODEFILE       ; clean mess up if a '.COM' file
                                    ; was generated, if no search was performed
         DB 0f1h

         DB 0feh, 0FAH                    ; error 250: Disk or directory full
         DB 0d2h
	DW L2A5A
	DB 0feh, 0C8H			; error 200: run-time error address found
	DB 30h,(L29EC)-$-1

	DB 0f5h

	DB 11h
	DW FILECURRENTINFO
	DB 0cdh
	DW  PRINTFILENAME

	DB 0cdh
	DW  L0200
	DB ', line ',0

	DB 02ah
	DW FILEBUFFERLINE
	DB 0cdh
	DW  L2E61		; print current line number

	DB 0cdh
	DW  L0200
	DB ', column ',0

	DB 0cdh
	DW  GETCOLUMNNUMBER
	DB 26h,0
	DB 68h
	DB 0cdh
	DW  L2E61		; print column number

	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 0cdh
	DW  PRINTCURRENTLINE

	DB 0f1h

	DB 47h
	DB 0cdh
	DW  L0200
	DB 'Error ',0
	DB 26h,0
	DB 68h
	DB 0c5h
	DB 0cdh
	DW  L2E61		; print error number
	DB 0c1h

	DB 0cdh
	DW  L0200
	DB ': ',0

	DB 0cdh
	DW  PRINTERRORMESSAGE
	DB 0c3h
	DW  L29F8

PRINTERRORMESSAGE:
	; in:	B = error code

	DB 21h
	DW TURBOERRORMESSAGES

L2995:	DB 7eh
	DB 0feh, 1AH
	DB 0c8h			; quit if at end of messages

	DB 0feh, 20H
	DB 38h,(L29AD)-$-1

	DB 0d6h, 30H
	DB 4fh
	DB 087h			; * 2
	DB 087h			; * 4
	DB 081h			; * 5
	DB 087h			; * 10
	DB 23h
	DB 086h
	DB 0d6h, 30H
	DB 23h
	DB 0b8h
	DB 28h,(L29B6)-$-1

L29AD:	DB 7eh
	DB 23h
	DB 0feh, 0DH
	DB 20h,(L29AD)-$-1
	DB 23h			; skip LF (0Ah) code
	DB 18h,( L2995)-$-1

L29B6:

L29BC:	DB 7eh
	DB 0feh, 0DH
	DB 0c8h			; quit if the end was found

	DB 0feh, 20H			; < 32 ?
	DB 30h,(L29E6)-$-1		; jump if it is printable

	DB 11h
	DW TURBOERRORMESSAGES

L29C9:	DB 1ah
	DB 13h
	DB 0feh, 20H
	DB 30h,(L29DD)-$-1

	DB 0beh
	DB 20h,(L29DD)-$-1

L29D2:	DB 1ah
	DB 0feh, 0DH
	DB 28h,(L29E9)-$-1
	DB 0cdh
	DW  L03C9		; print character
	DB 13h
	DB 18h,( L29D2)-$-1

L29DD:	DB 1ah
	DB 13h
	DB 0feh, 0DH
	DB 20h,(L29DD)-$-1
	DB 13h
	DB 18h,( L29C9)-$-1

L29E6:	DB 0cdh
	DW  L03C9		; print character

L29E9:	DB 23h
	DB 18h,( L29BC)-$-1

L29EC:	DB 0cdh
	DW  L2A7A
	DB 0cdh
	DW  L0200
	DB 'found',0

L29F8:
	DB 3eh,'.'
	DB 0cdh
	DW  L03C9		; print '.'

	DB 21h
	DW ERRORFILENAME
	DB 7eh
	DB 0b7h
	DB 0c4h
	DW ERRORFILEMAKE	; create error file if wanted

         DB 0c3h
	DW  L223B

PRINTCURRENTLINE:
	DB 11h
	DW FILEBUFFER
	DB 0cdh
	DW  EXPANDLINE		; expand all TABS in command line

	DB 0cdh
	DW  GETCOLUMNNUMBER

	DB 50h			; D = left column number
	DB 1eh,0			; E = starting at a size of 0
	DB 01h
	DW 40*256+79
	DB 0cdh
	DW  SCANLEFTRIGHT

	DB 7bh
	DB 0b7h
	DB 0c8h			; quit if size = 0

	DB 47h			; B = length of chars to print

	DB 0d5h
	DB 6ah
	DB 26h,0
	DB 11h
	DW FILEBUFFER-1
	DB 019h		; HL = start of first character

PRINTCURRENTLINE1:
	DB 7eh
	DB 0b7h
	DB 28h,(PRINTCURRENTLINE2)-$-1	; quit if end of chars found

	DB 0cdh
	DW  L03C9		; print char

	DB 23h
	DB 10h,( PRINTCURRENTLINE1)-$-1

PRINTCURRENTLINE2:
	DB 0cdh
	DW  L01E1		; print CR, LF

	DB 0cdh
	DW  GETCOLUMNNUMBER
	DB 0d1h
	DB 78h
	DB 092h
	DB 47h
	DB 04h

PRINTCURRENTLINE3:
	DB 05h
	DB 28h,(PRINTCURRENTLINE4)-$-1

	DB 3eh,' '
	DB 0cdh
	DW  L03C9		; print char

	DB 18h,( PRINTCURRENTLINE3)-$-1

PRINTCURRENTLINE4:
	DB 3eh,'^'
	DB 0cdh
	DW  L03C9
	DB 0c3h
	DW  L01E1 	       ; print CR, LF

L2A5A:	DB 0cdh
	DW  L0200
	DB 'Disk or directory full',0

         DB 0cdh
	DW  L2E76                 ; wait for escape
	DB 0c3h
	DW  L223B

L2A7A:	DB 0cdh
	DW  L0200
	DB 'Run-time error position ',0
L2A96:	DB 0c9h


L2D01:   ; asks for Yes or No
	; out: NonZero if 'Y' or 'y' pressed
	;	 Zero if 'n' or 'n' pressed
	DB 0cdh
	DW  L0200
	DB ' (Y/N)? ',0

L2D0D:   DB 0cdh
	DW  L03E1                 ; readkey
	DB 0cdh
	DW  L04A6		; upcase A
	DB 0feh, 'Y'
	DB 28h,(L2D1B)-$-1
	DB 0feh, 'N'
	DB 20h,(L2D0D)-$-1

L2D1B:   DB 0cdh
	DW  L03C9                 ; print character, choice
	DB 0d6h, 'N'
	DB 0c9h

L2D21:	DB 0cdh
	DW  L2D01
	DB 0f5h
	DB 0cdh
	DW  L01E1		; print CR, LF
	DB 0f1h
	DB 0c9h

L2E5C:   DB 11h
	DW -5
	DB 18h,( L2E64)-$-1

L2E61:   DB 11h
	DW -1

L2E64:	DB 0ddh,0e5h
	DB 0fdh,0e5h
	DB 0e5h
	DB 0d5h
	DB 0cdh
	DW  L149B		; set and check for output
	DB 0e1h
	DB 0cdh
	DW  L1726
	DB 0fdh,0e1h
	DB 0ddh,0e1h
	DB 0c9h

L2E76:   ; wait for escape
	; changes: -
	DB 0f5h
	DB 0cdh
	DW  L0200
	DB '. Press <ESC>',0

L2E88:   DB 0cdh
	DW  L03E1                 ; A = character from console
	DB 0feh, 1BH			; ESC pressed ?
	DB 20h,(L2E88)-$-1		; no, repeat until ESC pressed
	DB 0f1h
	DB 0c9h

	; TURBO PASCAL COMPILER
L44F1:	DB 0
L44F2:	DB 0

IFDEF MSX
L44F3:	DB 2			; 1 = to memory
				; 2 = to com-file
				; 3 = to chain-file
ELSE	; PC
L44F3:	DB 3			; 1 = to memory
				; 2 = to com-file
				; 3 = to chain-file
ENDIF

L44F4:	DW _L20E2		; compile start address
L44F6:	DW 0			; compile end address
LOGDRV:	DB 0			; logged drive: 1 = A:, 2 = B:

	; FCB with main filename
L44F9:	DB 0
L44FA:	db 12H dup (0)			; 18 x '\0'
L450C:	db 11H dup (0)			; 17 x '\0'

	; FCB with work filename
L451D:   db 1 + 64 dup (0)

;L451D:   DB 0
;L451E:   DS 23H                     ; 35 x '\0'

L4541:	DB 0			; zero = no error messages read
				; nonzero = error messages read

COMPILED:DB 0			; 0  = program not compiled
				;255 = program compiled
L4543:	DB 0

L4544:	DW L7BF5 		; at start of text area
L4546:	DW L7BF5 		; start of free area
L4548:	DW 0			; end of free area

L454A:   DW 73edh,L7B71              ; save stack pointer to return after an error

	DB 21h
	DW L7AD7+1
	DB 0cdh
	DW  FILEINIT

	DB 02ah
	DW L4546		; HL = start of free area
	DB 23h

	DB 22h
	DW L7BDF		; set start address of 1024 bytes
				; update table
	DB 24h
	DB 24h
	DB 24h
	DB 24h
	DB 22h
	DW L7BE1		; start of free area + 1024

	DB 02ah
	DW L790A		; HL = data end address
	DB 22h
	DW L7908		; start of free data area, growing downwards
	DB 0afh
	DB 67h
	DB 6fh
	DB 32h
	DW L7B91		; = 0
	DB 32h
	DW L7B92		; = 0
	DB 32h
	DW L7B94		; = 0
	DB 32h
	DW L7BA2		; = 0, no end of file found
	DB 32h
	DW L7BA0		; = 0
	DB 32h
	DW L7BE3		; = 0, no updates

	DB 32h
	DW L7B96		; = 0, number of the overlay file

	DB 32h
	DW L7BDB		; = 0, already read and not dirty

         DB 22h
	DW L7BDD              ; = 0, first block of the file
				; or first block of current overlay part
         DB 22h
	DW CODEFILESTART
         DB 22h
	DW CODEFILESTART+2

	DB 0cdh
	DW  L718F		; print current line number

	DB 2bh
         DB 22h
	DW L7954              ; init at block 65535, no block read yet

         DB 22h
	DW CODEFILEPOS
         DB 22h
	DW CODEFILEPOS+2

	DB 3eh,10H
	DB 32h
	DW L7B93		; first free type number
				; use by scalar types

	DB 3eh,0F5H
	DB 32h
	DW L7B9D		; default:
				; 0, 1 I/O Error Handling on
				; 1, 0 Index Range Checking off
				; 2, 1 Absolute Code on
				; 3, 0 User Interrupt off
				; 4, 1 Array Optimization on
				; 5, 1 Var-parameter Type Checking on
				; 6, 1 I/O Mode Selection on
				; 7, 1 Control S and C interpretation on
         DB 3eh,4
         DB 32h
	DW WITHDEPTH           ; init number of 'with' levels

	DB 02ah
	DW L4544		; HL = start of text area
;	 LD (L7BD7),HL		 ; init current position of text in memory
;	 LD (L7BD9),HL		 ; init start of line of text in memory

	DB 0ddh,21h
	DW L79D7		; init line buffer as empty, terminated by 0
	DB 0ddh,36h,+0,0

	DB 02ah
	DW L7904		; HL = code start address
         DB 0cdh
	DW  L6CC2

	DB 02ah
	DW L4548		; HL = end of free area
	DB 2bh
	DB 22h
	DW L7B77		; address of the first declared id (CBREAK)
	DB 54h
	DB 5dh
	DB 01h
	DW L74D2-L731F+1	; length of variable table
				; grows down wards
	DB 0b7h
	DB 0EDH,042h
	DB 22h
	DW L7B73		; bottom of variable table
	DB 22h
	DW L7B75		; same
	DB 22h
	DW L7B7B		; same

;	 CALL SETCHK

	DB 0cdh
	DW  L6BC7		; check compiler overflow, memory overflow
	DB 21h
	DW L74D2
	DB 0edh,0b8h			; copy standard variable definitions

         DB 0cdh
	DW  L45EA

	DB 3ah
	DW L7900
	DB 3dh
	DB 20h,(L45E2)-$-1		; jump if search (= 2)

	DB 0cdh
	DW  L6C96

         DB 0cdh
	DW  L6CFD                 ; write 128 bytes to file
				; flush last buffer

         DB 0fdh,0e5h
         DB 01h
	DW CODEFILE
         DB 0cdh
	DW  CLOSEFILE
         DB 0fdh,0e1h

L45E2:   DW 22fdh,L7906              ; new code end address
	DB 0afh
         DB 0c3h
	DW  L72E3

L45EA:	DB 0cdh
	DW  L6F95		; get non-blank
	DB 0cdh
	DW  L6E76		; start with PROGRAM?
	DW L7529 		; start of reserved word: PROGRAM
	DB 20h,(L460A)-$-1		; no, skip PROGRAM stuff

	; PROGRAM identifier ( identifier list )
	DB 0cdh
	DW  L4692		; add identifier at IX

	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 20h,(L4607)-$-1		; jump if '(' not matched

L45FC:	DB 0cdh
	DW  L4692		; add identifier at IX
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L45FC)-$-1		; yes, add next identifier

	DB 0cdh
	DW  L6F6E		; match(')')

L4607:	DB 0cdh
	DW  L6F48		; match(';')

L460A:	DB 3eh,31H 		; opcode 'LD SP,'
	DB 21h
	DW 100H
	DB 0cdh
	DW  O_OPHL		; out: 'LD SP,100H'

	DB 21h
	DW L79D7
	DB 3ah
	DW L7900
	DB 0b7h			; compile to memory?
	DB 28h,(L4621)-$-1		; yes, output L79D7

	DB 11h
	DW 0100H
	DB 0cdh
	DW  L6C30		; allocate 256 bytes of data area

L4621:	DB 0cdh
	DW  O_LDHL		; out: 'LD HL,L79D7'
				;   or 'LD HL,allocated data address'
	DB 3ah
	DW L7B9D
	DB 0cbh,07fh			; 1 = Control S and C interpretation on
	DB 16h,0			; assume no interpretation
	DB 28h,(L462E)-$-1		; jump if off
	DB 15h			; D = 255
L462E:	DB 0d5h
	DB 3eh,1
	DB 0cdh
	DW  O_BYTE		; opcode: 'LD BC,'
				; B = 255 if Control S and C interpretation on
				; C = 255 if User Interrupt on

	DB 0fdh,0e5h			; save code pointer
	DB 0cdh
	DW  O_HL		; out: dummy, reserve 2 bytes
	DB 21h
	DW _L0364		; LIB, done
	DB 0cdh
	DW  O_CALHL		; out: 'CALL L0364'

	DB 3eh,21H
	DB 0cdh
	DW  O_BYTE		; opcode: 'LD HL,'
	DB 0fdh,0e5h			; save code pointer (1st)

	DB 0cdh
	DW  O_HL		; out: dummy, reserve 2 bytes
	DB 3eh,11H
	DB 0cdh
	DW  O_BYTE		; opcode: 'LD DE,'
	DB 0fdh,0e5h			; save code pointer (2nd)

	DB 0cdh
	DW  O_HL		; out: dummy, reserve 2 bytes

	DB 02ah
	DW L790A		; HL = data end address
	DB 0cdh
	DW  O_LDBC		; out: 'LD BC,data end address

	DB 3ah
	DW L7900		; 0 = compiled in memory
				; 1 = compiled to disk
				; 2 = compiled while searching
	DB 67h
	DB 2eh,3EH
	DB 0cdh
	DW  O_HL		; out: 'LD A,value (L7900)'

	DB 21h
	DW _L04D4		; LIB, clear
	DB 0cdh
	DW  O_CALHL		; out: 'CALL L04D4'
	DB 0cdh
	DW  L469E

         DB 0cdh
	DW  L52FC                 ; start main program

         DB 0ddh,7eh,+0
	DB 0feh, '.'                     ; '.' ?, needed for 'END.'

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 0AH			; error 10: '.' expected

	DB 21h
	DW _L20D4		; LIB, done
	DB 0cdh
	DW  O_JPHL		; out: JP L20D4

	DB 0e1h
	DB 0edh,5bh
	DW L7908		; DE = data start address
         DB 0cdh
	DW  L6C42                 ; update address at HL with contents of DE

	DB 0e1h
         DB 0cdh
	DW  L6C3F                 ; update address at HL with current address

	DB 0e1h
	DB 0d1h
	DB 3ah
	DW L7BA0
	DB 5fh
         DB 0c3h
	DW  L6C42                   ; update address at HL with contents of DE

L4692:	; add identifier at address IX
	; in:	IX = address of identifier
	; out:	-
	DB 02ah
	DW L7B73		; HL = address to add a identifier
	DB 0e5h
	DB 0cdh
	DW  L6D87		; add identifier at address IX
	DB 0e1h
	DB 22h
	DW L7B73
	DB 0c9h

L469E:	; in:	-
	; out:	-
	DB 3ah
	DW WITHDEPTH
	DB 0f5h
	DB 087h
	DB 5fh			; DE = 2 * value (WITHDEPTH) bytes to allocate
	DB 16h,0
         DB 0cdh
	DW  L6C30                 ; HL = address newly allocated data
	DB 0e5h
	DB 0cdh
	DW  O_C3		; opcode: 'JP'
	DB 0fdh,0e5h
	DB 0e5h
	DB 0cdh
	DW  O_HL		; out: address of allocated data

L46B3:	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following every reserved word
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 0CH			; error 12: BEGIN expected

	DB 7eh		; A = byte following the found word

L46BE:	DB 0feh, 1			; word is 'LABEL' ?
	DB 20h,(L46C7)-$-1		; no, continue


	DB 0cdh
	DW  L488E		; label-declaration-part
	DB 18h,( L46B3)-$-1 		; repeat

L46C7:	DB 0feh, 2			; word is 'CONST' ?
	DB 20h,(L46D0)-$-1		; no, continue

	DB 0cdh
	DW  L48B7
	DB 18h,( L46BE)-$-1

L46D0:	DB 0feh, 3			; word is 'TYPE' ?
	DB 20h,(L46D9)-$-1		; no, continue
	DB 0cdh
	DW  L4AEB
	DB 18h,( L46BE)-$-1

L46D9:	DB 0feh, 4			; word is 'VAR' ?
	DB 20h,(L46E6)-$-1		; no, continue
	DB 0cdh
	DW  L4B2A
	DB 02ah
	DW L7908		; HL = data start address
	DB 0e3h
	DB 18h,( L46BE)-$-1

L46E6:	DB 0feh, 7			; word is 'OVERLAY' ?
         DB 0c2h
	DW L485E                ; no, continue

	; start of overlay procedure
	DB 3ah
	DW L7900
	DB 0b7h			; only overlays when compiling to disk

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 4DH			; error 77: Overlays not allowed in direct mode

         DB 21h
	DW CODEFILE+1
         DB 11h
	DW TEMPFILEDATA
         DB 3eh,' '
         DB 47h
         DB 4fh
         DB 0cdh
	DW  PARSENAME             ; parse name to get last item

         DB 0c5h                    ; save address of last item

;         LD HL,L7934
;         LD DE,L7BB2
;         LD BC,0008
;         LDIR                       ; fill name of overlay file

	; create 0xy
	DB 21h
	DW L7B96

         DB 7eh
         DB 0f5h                    ; save number to put in overlay-info block

         DB 034h

;         EX DE,HL

;         LD (HL),'0'
;         INC HL

         DB 06h,'0'-1

L4709:	DB 04h
	DB 0d6h, 10
	DB 30h,(L4709)-$-1
;         LD (HL),B
;         INC HL

         DB 0c6h,'0' + 10             ; + 10 to compensate for SUB 10
         DB 4fh

;         LD (HL),A

         DB 3eh,'0'

         DB 21h
	DW TEMPFILEDATA+1
         DB 37h                        ; overrule current extension
         DB 0cdh
	DW  SETEXTENSION

	DB 3ah
	DW L7B9D
         DB 21h
	DW _LOADRUNOVERLAYREC

	DB 0cbh,057h			; 1 = Absolute Code on
         DB 28h,(L470D)-$-1                 ; jump if not on

         DB 21h
	DW _LOADRUNOVERLAY      ; LIB, overlay system call

L470D:
	DB 0cdh
	DW  O_CALHL

         DB 21h
	DW -1                   ; initial ID number, nothing loaded
         DB 0cdh
	DW  O_HL                  ;Ok$$$$, will be long with file position
                                    ; as id of loaded overlay
         DB 21h
	DW -1
         DB 0cdh
	DW  O_HL

         DB 21h
	DW -1
         DB 0cdh
	DW  O_HL                  ; output overlay data length
                                    ; default not present

         DB 0e1h
         DB 7ch
         DB 0cdh
	DW  O_BYTE                ; output overlay number

         DB 0e1h                     ; HL = address of last item
                                    ; drive/path/name drive/name
                                    ;            ^          ^
         DB 0e5h

         DB 0afh                      ; lenght of overlay file name = 0
L4723:
         DB 3ch

         DB 035h
         DB 034h

         DB 23h

         DB 20h,(L4723)-$-1

         DB 3dh

         DB 0cdh
	DW  O_BYTE                ; output length of overlay file name

         DB 0e1h

;         LD HL,L7BB2                ; source address overlay file name
         DB 06h,13                    ; file name is 13 bytes long
                                    ;Ok$$$$, will be ASCIIZ string of 12 bytes
                                    ; + '\0'

L4724:	DB 7eh
	DB 0cdh
	DW  O_BYTE
	DB 23h
	DB 10h,( L4724)-$-1

	DB 3ah
	DW L7900
	DB 3dh
	DB 20h,(L473B)-$-1		; jump if searching

	DB 0cdh
	DW  L6C96		; jump dates

         DB 0afh
         DB 32h
	DW L7BE3               ; no updates

	DB 0cdh
	DW  L6CFD		; write 128 bytes to file, updated record

L473B:
         ;LD HL,(L7BDD)              ; save first block of current part
         ;PUSH HL                    ;Ok$$$$, must be long
                                    ; CodeFileStart
         DB 02ah
	DW CODEFILESTART+2
         DB 0e5h                    ; save high-word
         DB 02ah
	DW CODEFILESTART
         DB 0e5h                    ; save low-word

	DB 02ah
	DW L7902		; save first address of current part
	DB 0e5h

         DB 02ah
	DW L7BB0              ; save length of largest part
         DB 0e5h                    ;Ok$$$$, must be in bytes
                                    ;       now in 128 byte blocks

         DW 22fdh,L7902              ; set first address of current part

         DB 21h
	DW 0                    ; #### 0000
         DB 22h
	DW L7BB0              ; set length of largest part = 0

         DB 21h
	DW -65                  ; size of handle/FCB
         DB 039h

;         LD HL,-FCB_LEN             ; -36
;         ADD HL,SP                  ; allocate space for a new FCB

	DB 0f9h
	DB 0ebh
         DB 21h
	DW CODEFILE ; L7933
         DB 01h
	DW 65 ; FCB_LEN
	DB 0edh,0b0h			; copy current FCB to this new space

	DB 3ah
	DW L7900
	DB 3dh
         DB 0c2h
	DW L478C                ; jump if searching

;         LD HL,L7BB2
;         LD DE,L7933 + 1
;         LD BC,11                   ; length of FCB name
;         LDIR
;
;         EX DE,HL
;         LD B,FCB_LEN - 12          ; length of drive name + name
;L4773:   LD (HL),0
;         INC HL
;         DJNZ L4773

         DB 21h
	DW TEMPFILEDATA
         DB 11h
	DW CODEFILE
         DB 01h
	DW 65
         DB 0edh,0b0h

         DB 11h
	DW CODEFILE+1
         DB 0cdh
	DW  DELETEFILE

         DB 21h
	DW CODEFILE+1
         DB 11h
	DW CODEFILE
         DB 3eh,' '
         DB 47h
         DB 4fh
         DB 0cdh
	DW  CREATEFILE

;         LD DE,L7933
;         PUSH DE
;         LD C,13H                   ; delete file
;         CALL DOSIXIY
;         POP DE
;         LD C,16H                   ; create file
;         CALL DOSIXIY
;         INC A

         DB 0cdh
	DW  L72DA                 ; NonZero --> error
	DB 5CH			; error 92: Unable to create overlay file

         DB 21h
	DW 0
         DB 22h
	DW CODEFILESTART
         DB 22h
	DW CODEFILESTART+2

L478C:
         DB 21h
	DW 0
         DB 22h
	DW CODEFILEBUFFERPOS  ; start at byte 0 of buffer
         DB 0afh
	DB 32h
	DW L7BDB		; already read and not dirty
;         LD (L7BDC),A               ; start at byte 0 of current block

	DB 02ah
	DW L7908		; HL = data start address
	DB 22h
	DW L7BAB		; save data start address
				; all overlay functions and procedures in
				; the same overlay have the same data
				; start address

L4799:	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following
	DW L75A7 		; start of reserved word list:
				; PROCEDURE, FUNCTION

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 10H			; error 16: PROCEDURE or FUNCTION expected

         DB 7eh                  ; A = 5, PROCEDURE
                                    ; A = 6, FUNCTION

         DB 0fdh,0e5h                    ; save start of overlay code
                                    ; just after the filename

         DB 02ah
	DW CODEFILESTART
         DB 22h
	DW CODEFILEPOS
         DB 02ah
	DW CODEFILESTART+2
         DB 22h
	DW CODEFILEPOS+2

;         LD HL,(L7954)              ; HL = current file position
;                                    ;Ok$$$$, must be long
;         LD (L7BDD),HL              ; save current file position
;                                    ; set start of new part
;                                    ;Ok$$$$, must be long CodeFileStart

	DB 02ah
	DW L7908		; HL = data start address
	DB 0e5h			; save old data start address

	DB 02ah
	DW L7BAB
	DB 0e5h

	DB 1eh,0FFH		; this procedure, function is an overlay
         DB 0cdh
	DW  L4B3A

         ; HL = address of high byte of struct length
         DB 44h
         DB 4dh

	DB 0d1h

	DB 02ah
	DW L7908		; HL = new data start address
	DB 0b7h
	DB 0EDH,052h		; used data of last proc/func >
				;	   biggest data of proc/func
         DB 019h
	DB 38h,(L47C6)-$-1		; jump not bigger

	DB 0ebh 		; data of last proc/func is largest data

L47C6:	DB 22h
	DW L7BAB		; save biggest data area

	DB 0e1h			; restore old data start address
	DB 22h
	DW L7908		; set new data start address

	DB 0d1h			; DE = start of overlay code


         DB 0c5h                    ; address of high byte of struct length

	DB 0d5h			; DE = start of overlay code

	DB 3ah
	DW L7900
	DB 3dh
	DB 0cch
	DW L6C96		; call if compiling to disk

	DB 0afh
	DB 32h
	DW L7BE3		; 0 = no updates

	DB 0d1h			; DE = start of overlay code
	DB 0d5h

         ;Ok$$$$, this part should not be done, that is no round up

         ; this routine rounds the overlay up to a multiple of 128 bytes
;L47DD:   PUSH IY
;         POP HL                     ; HL = address of first byte after overlay
;
;         OR A
;         SBC HL,DE                  ; current address - start of overlay address
;
;         LD A,L
;         AND 7FH
;         JR Z,L47EE                 ; jump if at 128 byte boundary
;
;         XOR A
;         CALL O_BYTE
;         JR L47DD
;
;L47EE:

         DB 0fdh,0e5h
         DB 0e1h

         DB 0b7h
         DB 0EDH,052h                  ; HL = length of current part in bytes

         DB 0ebh
;         ;Ok$$$$, must be length in bytes
;         ADD HL,HL                  ; length in bytes * 2
;         LD E,H                     ; E = number of 128 byte blocks
;         LD D,0
;         RL D

         DB 02ah
	DW L7BB0              ; HL = largest part
	DB 0EDH,052h
	DB 30h,(L47FF)-$-1		; jump largest part > length current part

         DW 53edh,L7BB0              ; largest part = length current part
                                    ;Ok$$$$, must be in length in bytes

L47FF:
	DB 0fdh,0e1h			; IY = start of overlay code

         ;Ok$$$$, DE = must become length of function/procedure in bytes
         DB 0e1h                     ; HL = address of high byte of struct length
	DB 23h
	DB 73h		; set size of function/procedure code
	DB 23h			; to number of 128 byte blocks
	DB 72h

         DB 02ah
	DW CODEFILESTART
         DB 019h
         DB 22h
	DW CODEFILESTART
         DB 02ah
	DW CODEFILESTART+2
         DB 11h
	DW 0
         DB 0EDH,05ah
         DB 22h
	DW CODEFILESTART+2

	DB 0cdh
	DW  L6E76
	DW L759F 		; start of reserved word: OVERLAY
         DB 28h,(L4799)-$-1                 ; jump if 'OVERLAY'
				; this jump repeats the LOOP

	DB 02ah
	DW L7BAB		; HL = lowest address with data in overlay
	DB 22h
	DW L7908		; continue the with the rest

	DB 3ah
	DW L7900
	DB 3dh
	DB 20h,(L4821)-$-1		; jump if searching

         DB 0cdh
	DW  L6CFD                 ; write 128 bytes to file
				; flush last buffer

         DB 01h
	DW CODEFILE
         DB 0cdh
	DW  CLOSEFILE

;         LD DE,L7933
;         LD C,10H                   ; close file with generated code
;         CALL DOSIXIY

L4821:	; pop old FCB block (previous overlay or com or chain file)
	DB 21h
	DW 0000
	DB 039h

;         LD DE,L7933
;         LD BC,FCB_LEN
;         LDIR

         DB 11h
	DW CODEFILE
         DB 01h
	DW 65
         DB 0edh,0b0h

         DB 0f9h

	DB 0edh,5bh
	DW L7BB0		; number of blocks of largest part

	DB 0e1h
         DB 22h
	DW L7BB0              ; restore length of largest part
	DB 0e1h
	DB 22h
	DW L7902		; restore first address of previous part

;         POP HL
;         LD (L7BDD),HL              ; restore first block of previous part
;                                    ;Ok$$$$, CodeFileStart
         DB 0e1h
         DB 22h
	DW CODEFILESTART      ; low-word
         DB 0e1h
         DB 22h
	DW CODEFILESTART+2    ; high-word

	DB 0afh
	DB 32h
	DW L7BDB		; already read and not dirty

	DB 21h
	DW -1
         DB 22h
	DW L7954              ; init, no block read yet
         DB 22h
	DW CODEFILEPOS
         DB 22h
	DW CODEFILEPOS+2

	DB 0fdh,0e5h
	DB 0e1h
         DB 0cdh
	DW  L6CC2

         ; create empty area in code file where the overlay is to be loaded
L484E:   DB 06h,1 ; 80H

L4850:   DB 0afh
	DB 0cdh
	DW  O_BYTE
	DB 10h,( L4850)-$-1
	DB 1bh
	DB 7ah
	DB 0b3h
         DB 20h,(L484E)-$-1                ; until no more to go

         DB 0c3h
	DW  L46B3

L485E:	DB 0feh, 8			; word is 'BEGIN' ?
	DB 28h,(L486A)-$-1

	; A = 5, PROCEDURE found
	; A = 6, FUNCTION found
	DB 1eh,0			; this procedure, function is not an overlay
	DB 0cdh
	DW  L4B3A
	DB 0c3h
	DW  L46B3

L486A:	; parses the word BEGIN
	DB 0cdh
	DW  L4E8A
	DB 0d1h			; DE = address of allocated memory
	DB 0e1h			; HL = address after 'JP' opcode
	DB 0d5h			; save address of allocated memory

	DB 0fdh,0e5h
	DB 0d1h			; DE = IY

	DB 1bh
	DB 1bh			; DE - 2

	DB 0b7h
	DB 0EDH,052h		; set flags at HL - DE
;!	pushf
	DB 019h		; restore HL
;!	popf
	DB 28h,(L4880)-$-1		; no more code generated ?

         DB 0cdh
	DW  L6C3F                 ; update address at HL with current address
	DB 18h,( L4884)-$-1

L4880:	DB 2bh			; dispose 'JP' opcode

         DB 0cdh
	DW  L6CC2


L4884:	DB 0d1h			; DE = address of allocated memory
	DB 0e1h			; HL = address of allocated memory
	DB 22h
	DW L7BCA
	DB 0f1h			; A = pushed value of (WITHDEPTH)
	DB 32h
	DW L7BC6
	DB 0c9h

L488E:	; SYNTAX: label-declaration-part ::= LABEL label {, label } ;
	; reserved word LABEL already parsed
	DB 11h
	DW 100H
         DB 0cdh
	DW  L6D75                 ; add DE to id table

	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L7282		; letter, underscore or decimal ?

	DB 0cdh
	DW  L6D8D		; carry set --> error
				; error 58: Illegal character in identifier
	DB 3ah
	DW L7B94
	DB 0cdh
	DW  L6D7A		; add byte to id table

	DB 06h,3
L48A5:	DB 3eh,0FFH
	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 10h,( L48A5)-$-1

	DB 0cdh
	DW  L6DC6		; add length
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L488E)-$-1		; yes, add next id

	DB 0c3h
	DW  L6F48 		; match(';')

L48B7:	DB 02ah
	DW L7B73
	DB 0e5h			; push for later setting of type

	DB 11h
	DW 0000
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6D87		; add identifier to id table
	DB 0cdh
	DW  L6F23		; match('='), if present
	DB 20h,(L4901)-$-1		; jump if '=' not matched

	DB 3eh,0FFH		; default type = INTEGER / LONGINT
	DB 32h
	DW DEF_TYPE
	DB 0cdh
	DW  L6A0D		; parse a constant of any type

	DB 78h			; A = type
	DB 0cdh
	DW  L6D7A		; add type (byte) to id table
	DB 78h
	DB 0feh, 9			; constant type = REAL ?
	DB 20h,(L48DB1)-$-1		; jump if not

	; add real value (6 bytes) to id table
	DB 0d9h
	DB 0e5h
	DB 0d5h
	DB 0c5h
	DB 06h,3

L48DB:	DB 0d1h
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 10h,( L48DB)-$-1
	DB 18h,( L48FA)-$-1

L48DB1:	DB 0feh, 0EH			; type = LONGINT ?
	DB 20h,(L48E3)-$-1		; jump if not

	; add longint value (4 bytes) to id table
	DB 0d9h
	DB 0e5h
	DB 0d5h
	DB 06h,2			; add 2 words
	DB 18h,( L48DB)-$-1

L48E3:	DB 0feh, 8			; type = STRING ?
	DB 20h,(L48F6)-$-1		; jump if not

	DB 21h
	DW L7A57
	DB 79h
	DB 0ch

L48EC:	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 7eh
	DB 23h
	DB 0dh
	DB 20h,(L48EC)-$-1
	DB 18h,( L48FA)-$-1

L48F6:	DB 0ebh
	DB 0cdh
	DW  L6D75		; add DE to id table

L48FA:	DB 0cdh
	DW  L6DC6		; add length
	DB 16h,2			; id type = constant
	DB 18h,( L4928)-$-1

L4901:	DB 0cdh
	DW  L6F40		; match(':')
	DB 0afh
	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 0cdh
	DW  L6D72		; add IY to id table
				; start of constant address

	DB 02ah
	DW L7B73
	DB 0e5h			; push for later setting of type

	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6DC6		; add length

	DB 0cdh
	DW  L4F9B		; parse every possible type

	DB 0e1h
	DB 0edh,5bh
	DW L7B5A
	DB 72h
	DB 2bh
	DB 73h
	DB 0cdh
	DW  L6F76		; match('=')

	DB 0cdh
	DW  L4937
	DB 16h,4

L4928:	DB 0e1h
	DB 72h
	DB 0cdh
	DW  L6F48		; match(';')
	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	DB 0c2h
	DW L48B7		; jump if none of these reserved words
				; repeat for next constant

	DB 7eh
	DB 0c9h

L4937:	DB 3ah
	DW L7B5C		; A = type
	DB 32h
	DW DEF_TYPE
	DB 0feh, 4
	DB 38h,(L4946)-$-1		; jump if type = 0, 1, 2 or 3 (SET)

	DB 0feh, 8
	DB 30h,(L4946)-$-1		; jump if STRING, REAL, INTEGER, BOOLEAN,
				;	 CHAR, LONGINT

	DB 0cdh
	DW  L72E1		; no condition
	DB 3DH			; error 61: Files and pointers are
				;	    not allowed here
L4946:	DB 0feh, 1
	DB 20h,(L49A1)-$-1

	; type = 1
	DB 0cdh
	DW  L6D2A		; push 13, L7B57

	DB 02ah
	DW L7B60
	DB 0cdh
	DW  L5271		; 8 bytes from HL (down) to 7B69 (up)

	DB 02ah
	DW L7B6D
	DB 0edh,5bh
	DW L7B6B
	DB 0b7h
	DB 0EDH,052h
	DB 23h
	DB 0e5h
	DB 02ah
	DW L7B5E		; HL = address of type definition
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)
				; get all information from this type
	DB 0d1h
	DB 3ah
	DW L7B5C
	DB 0feh, 0CH
	DB 20h,(L4978)-$-1
	DB 7ah
	DB 0b7h
	DB 20h,(L4978)-$-1
	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 20h,(L498A)-$-1		; jump if '(' not matched
	DB 18h,( L497B)-$-1

L4978:	DB 0cdh
	DW  L6F66		; match('(')
L497B:	DB 0d5h

	DB 0cdh
	DW  L4937

	DB 0d1h
	DB 1bh
	DB 7ah
	DB 0b3h
	DB 28h,(L499A)-$-1
	DB 0cdh
	DW  L6F5E		; match(',')
	DB 18h,( L497B)-$-1

L498A:	DB 0d5h
	DB 0cdh
	DW  L69FD		; parse string constant
	DB 0d1h
	DB 79h
	DB 0bbh

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 32H			; error 50: String constant length does not
				;	    match type
	DB 0cdh
	DW  L6B62
	DB 18h,( L499D)-$-1

L499A:	DB 0cdh
	DW  L6F6E		; match(')')
L499D:	DB 0cdh
	DW  L6D49		; pop 13, L7B57
	DB 0c9h

L49A1:	DB 0feh, 2
	DB 20h,(L49FA)-$-1

	; type = 2
	DB 0cdh
	DW  L6D2A		; push 13, L7B57
	DB 0cdh
	DW  L6F66		; match('(')
	DB 3ah
	DW L7B5D
	DB 4fh
	DB 02ah
	DW L7B62		; HL = length
	DB 0e5h
	DB 21h
	DW 0000
L49B6:	DB 0c5h
	DB 0e5h
	DB 06h,4			; variable identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax
				;	   error

	DB 0cdh
	DW  L5276		; id info at 7B5C
	DB 0d1h
	DB 02ah
	DW L7B58		; HL = lvalue of current id
	DB 0b7h
	DB 0EDH,052h
;!	pushf
	DB 019h
;!	popf

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 45H			; error 69: Invalid ordering of fields

	DB 0edh,5bh
	DW L7B62		; DE = length
	DB 019h
	DB 0e5h
	DB 0cdh
	DW  L6F40		; match(':')

	DB 0cdh
	DW  L4937

	DB 0e1h
	DB 0c1h
	DB 0cdh
	DW  L6F0F		; match(';'), if present
	DB 28h,(L49B6)-$-1		; jump if ';' matched
	DB 0cdh
	DW  L6F6E		; match(')')
	DB 0d1h
	DB 0ebh
	DB 0b7h
	DB 0EDH,052h
L49EB:	DB 7ch
	DB 0b5h
	DB 28h,(L49F6)-$-1
	DB 0afh
	DB 0cdh
	DW  O_BYTE
	DB 2bh
	DB 18h,( L49EB)-$-1
L49F6:	DB 0cdh
	DW  L6D49		; pop 13, L7B57
	DB 0c9h

L49FA:	DB 0feh, 3			; type = SET ?
	DB 20h,(L4A7A)-$-1		; jump if not

	; type = SET
	DB 0cdh
	DW  L6D2A		; push 13, L7B57
	DB 02ah
	DW L7B62		; HL = length
	DB 22h
	DW L7B6F
	DB 02ah
	DW L7B5E		; HL = address of type definition
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)
	DB 0cdh
	DW  L6F30		; match('[')

	DW 22ddh,L7BA9		; save temporary
	DB 0cdh
	DW  L0581		; LIB, push new empty SET on stack
	DB 0ddh,02ah
	DW L7BA9		; restore text pointer

	DB 0cdh
	DW  L6EF7		; match(']') or match('.)')
	DB 28h,(L4A4B)-$-1		; jump if matched

L4A20:	DB 0cdh
	DW  L4ACA
	DB 0e5h

	DB 0cdh
	DW  L6E76
	DW L7580 		; start of reserved word: ..
	DB 20h,(L4A37)-$-1		; jump if no '..'

	DB 0cdh
	DW  L4ACA

	DW 22ddh,L7BA9		; save temporary
	DB 0cdh
	DW  L059B		; LIB
	DB 18h,( L4A3F)-$-1

L4A37:	DB 0e1h
	DW 22ddh,L7BA9		; save temporary

	DB 0cdh
	DW  L0591		; LIB

L4A3F:	DB 0ddh,02ah
	DW L7BA9		; restore text pointer
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L4A20)-$-1		; jump if ',' matched
	DB 0cdh
	DW  L6F38		; match(']')

L4A4B:	DB 21h
	DW L7A57
	DB 01h
	DW 0020H

	DW 22ddh,L7BA9		; save temporary
	DB 0cdh
	DW  L0612		; LIB, copy pushed set to the address in HL
	DB 0ddh,02ah
	DW L7BA9		; restore text pointer

	DB 21h
	DW L7A57
	DB 3ah
	DW L7B5E
	DB 1fh
	DB 1fh
	DB 1fh
	DB 0e6h, 1FH
	DB 5fh
	DB 16h,0
	DB 019h
	DB 3ah
	DW L7B6F
	DB 47h
L4A6F:	DB 7eh
	DB 0cdh
	DW  O_BYTE
	DB 23h
	DB 10h,( L4A6F)-$-1
	DB 0cdh
	DW  L6D49		; pop 13, L7B57
	DB 0c9h

L4A7A:	DB 0feh, 8			; type = STRING ?
	DB 20h,(L4A99)-$-1

	; type = STRING
	; typed string constant
	DB 0cdh
	DW  L69FD		; parse string constant

	DB 3ah
	DW L7B62		; A = length of constant type
	DB 3dh			; minus 1 for length byte

	DB 091h			; - string constant length
	DB 47h

	DB 30h,(L4A8D)-$-1

	; constant type < string constant
	DB 081h			; restore type length - 1
	DB 4fh			; copy constant type bytes
	DB 06h,0			; no padding at the end

L4A8D:	DB 0cdh
	DW  L6B5E		; output length (C) and data at L7A57
	DB 04h
L4A91:	DB 05h
	DB 0c8h
	DB 0afh
	DB 0cdh
	DW  O_BYTE
	DB 18h,( L4A91)-$-1

L4A99:	DB 0feh, 9			; type = REAL ?
	DB 20h,(L4ABC)-$-1

	; type = REAL
	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 78h
	DB 0feh, 9			; type = REAL ?
	DB 28h,(L4AAF)-$-1		; jump if type = REAL, no conversion

	DB 0feh, 0EH			; type = LONGINT ?
	DB 28h,(L4AAF1)-$-1		; jump if type = LONGINT, L_R

	DB 0feh, 0AH			; type = INTEGER ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 19H			; error 25: Integer, real or longint
				;	   constant expected

	DB 0cdh
	DW  L1008		; convert integer HL to REAL HLDEBC
	DB 0d9h

L4AAF:	; output data for REAL constant
	DB 0d9h
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 06h,3			; output 3 words

L4AB5:	DB 0e1h
	DB 0cdh
	DW  O_HL
	DB 10h,( L4AB5)-$-1
	DB 0c9h

L4AAF1:	; output data for LONGINT constant
	DB 0d9h
	DB 0cdh
	DW  L_R 		; convert longint DEHL to REAL HLDEBC
	DB 0d9h
	DB 18h,( L4AAF)-$-1

L4ABC:	DB 0feh, 0EH			; type = LONGINT ?
	DB 20h,(L4ABC1)-$-1

	; type = LONGINT
	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 78h
	DB 0feh, 9			; type = REAL ?
	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0d9h			; DEHL = value
	DB 0feh, 0EH			; type = LONGINT ?
	DB 28h,(OUT_LONG)-$-1
	DB 0d9h			; HL = integer value

	DB 0feh, 0AH			; type = INTEGER ?
	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0cdh
	DW  I_L 		; convert integer HL to longint DEHL

OUT_LONG:
	DB 0cdh
	DW  O_HL
	DB 0ebh
	DB 0cdh
	DW  O_HL
	DB 0ebh
	DB 0c9h

I_L:	; in:	HL = INTEGER, signed
	; out:	DEHL = LONGINT, signed
	DB 11h
	DW 0
	DB 0cbh,07ch
	DB 0c8h			; return if integer is positive

	DB 1bh			; make long negative
	DB 0c9h

L4ABC1:	DB 0cdh
	DW  L4ACA		; make constant range check
	DB 3ah
	DW L7B62
	DB 3dh			; length = 1 ?
	DB 7dh
	DB 0cah
	DW O_BYTE		; output data
	DB 0c3h
	DW  O_HL

L4ACA:	; make constant range check
	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 3ah
	DW L7B5C
	DB 0b8h			; equal types ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0feh, 0EH			; type = LONGINT ?
	DB 0c8h			; no range check

	DB 0edh,5bh
	DW L7B5E		; DE = minimum value
	DB 0cdh
	DW  L728D		; check if lower bound <= upper bound

	DB 38h,(L4AE7)-$-1		; jump if lower bound > upper bound

	DB 0edh,5bh
	DW L7B60		; DE = maximum value
	DB 0cdh
	DW  L728D		; check if lower bound <= upper bound
	DB 0d8h			; return if HL < maximum value
	DB 0c8h			; return if HL = maximum value

L4AE7:	DB 0cdh
	DW  L72E1		; no condition
	DB 2DH			; error 45: constant out of range

L4AEB:	DB 02ah
	DW L7B73
	DB 0e5h
L4AEF:	DB 02ah
	DW L7B73
	DB 0e5h
	DB 11h
	DW 0000
	DB 0cdh
	DW  L6D75		; add DE to id table
				; represents the type
	DB 0cdh
	DW  L6D87		; add identifier to id table

	DB 02ah
	DW L7B73
	DB 0e5h
	DB 0cdh
	DW  L6D75		; add DE to id table
				; will be filled in later with pointer to
				; the type
	DB 0cdh
	DW  L6DC6		; add length, length is calculated
	DB 0cdh
	DW  L6F76		; match('=')
	DB 0cdh
	DW  L4F9B		; parse every possible type
	DB 0e1h
	DB 0edh,5bh
	DW L7B5A
	DB 72h
	DB 2bh
	DB 73h
	DB 0e1h
	DB 36h,3
	DB 0cdh
	DW  L6F48		; match(';')

	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	DB 20h,(L4AEF)-$-1
	DB 7eh

	DB 0e1h			; address where to stop reference search
	DB 0f5h
	DB 0cdh
	DW  L5295		; update pointer references
	DB 0f1h
	DB 0c9h

	; name1, name2 : type_name;
L4B2A:	DB 0cdh
	DW  L4F35		; parse variable declarations
	DB 0cdh
	DW  L6F48		; match(';')

	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	DB 20h,(L4B2A)-$-1		; no reserved found, parse more names
	DB 7eh		; A = number of one of the reserved words
	DB 0c9h

L4B3A:   DB 47h                     ; B = 5 if procedure
				; B = 6 if function
	DB 0eh,0
	DB 0d6h, 5
	DB 32h
	DW L7B97		; 0 = procedure, 1 = function

L4B42:	DB 7bh
         DB 32h
	DW L7B99               ; 0 = no overlay, 255 = overlay

	DB 3ah
	DW L7B9D		; compiler directives
	DB 32h
	DW L7B9E		; save them

	DB 0c5h
	DB 0cdh
	DW  L6DDB		; ID at current position double defined ?
	DB 0cah
	DW L4C61		; jump if double defined

	DB 0d1h			; DE = type
				; D = 5, PROCEDURE
				; D = 6, FUNCTION
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6D87		; add identifier to id table

	DB 02ah
	DW L7B7B
	DB 0e5h			; save add position of first added struct

	DB 02ah
	DW L7B75		; HL = start of added PROC/FUNC struct
	DB 22h
	DW L7B7B
	DB 02ah
	DW L7B73
	DB 0e5h			; save add position after identifier
				; for connection
         DB 0cdh
	DW  L6D75                 ; add DE to id table, # different types
         DB 0cdh
	DW  L6D75                 ; add DE to id table, proc/func address
         DB 0cdh
	DW  L6D75                 ; add DE to id table, function type def.
         DB 0cdh
	DW  L6D75                 ; add DE to id table, addr function result
                                    ;                     variable

;         LD DE,(L7BDD)              ; save first block of current PROC/FUNC
;                                    ;Ok$$$$, make long word CodeFileStart
;         CALL L6D75                 ; add DE to id table

         DB 0edh,5bh
	DW CODEFILESTART+2
         DB 0cdh
	DW  L6D75                 ; save high-word of CodeFileStart
         DB 0edh,5bh
	DW CODEFILESTART
         DB 0cdh
	DW  L6D75                 ; save low-word of CodeFileStart

         DB 11h
	DW 0000                 ; length in bytes of procedure/function code
         DB 3ah
	DW L7B99
         DB 0b7h                       ; Zero = no overlay, NonZero = overlay
         DB 28h,(L4B45)-$-1
         DB 1bh                     ; init at -1, special meaning
L4B45:
;         LD DE,1
;         LD DE,0000                 ; length in blocks of 128 bytes of
;                                    ; the largest overlay part
;                                    ;Ok$$$$, becomes length in bytes
	DB 0cdh
	DW  L6D75		; add DE to id table

	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 06h,0			; assume no dest. type --> procedure
	DB 20h,(L4BDA)-$-1		; jump if no '(', thus no var list

	; start loop for different types
L4B88:	DB 0c5h			; push number of different types

	DB 02ah
	DW L7B73
	DB 0e5h			; save position for number of vars with
				; same type
	DB 0cdh
	DW  L6D75		; add DE to id table, count + var/no var.
	DB 0cdh
	DW  L6D75		; add DE to id table, address type defs.

	DB 0cdh
	DW  L6E76
	DW L7595 		; start of reserved word: VAR

	DB 01h
	DW 0000		; B = 0, zero identifiers using same type
				; C = 0, assume no VAR
	DB 20h,(L4B9E)-$-1		; jump if no VAR found

	DB 0dh			; C = 255, VAR before definition

L4B9E:
	DB 0c5h
	DB 0cdh
	DW  L6D87		; add identifier to id table

	DB 0c1h
	DB 04h			; one more identifier using same type
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L4B9E)-$-1		; jump if ',' matched, repeat

	DB 0c5h			; save count and VAR flag

	DB 0cdh
	DW  L6F0B		; match(':'), if present
	DB 20h,(L4BB8)-$-1		; jump if ':' not matched
	DB 79h
	DB 32h
	DW L7B8F		; 0 = no VAR, 255 = VAR parsed
	DB 0cdh
	DW  L4F18		; L7B5C..L7B63 filled in with type info
	DB 18h,( L4BC3)-$-1

L4BB8:	DB 0ch

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2			; error 2: ':' expected

	DB 21h
	DW L7512
	DB 22h
	DW L7B5A

L4BC3:	; add count and VAR/NO VAR flag
	DB 0c1h			; pop count and VAR flag

	DB 0e1h
         DB 70h                  ; save count
	DB 2bh
         DB 71h                  ; save VAR flag

	DB 0edh,5bh
	DW L7B5A		; DE = address of type definition info
	DB 2bh
	DB 72h
	DB 2bh
	DB 73h

	DB 0c1h			; restore number of different types
	DB 04h			; one more different types
	DB 0cdh
	DW  L6F0F		; match(';'), if present
	DB 28h,(L4B88)-$-1		; jump if ';' matched, repeat for next var

	DB 0cdh
	DW  L6F6E		; match(')')

L4BDA:	DB 0c5h			; save number of different types
	DB 3ah
	DW L7B97		; 0 = proc, 1 = func
	DB 0b7h
	DB 28h,(L4C07)-$-1		; if proc skip function type

	DB 0cdh
	DW  L6F40		; match(':')
	DB 0afh
	DB 32h
	DW L7B8F		; 0 = no VAR, 255 = VAR
	DB 0cdh
	DW  L4F18		; L7B5C..L7B63 filled in with type info		  ; parse type
	DB 3ah
	DW L7B5C
	DB 0feh, 8			; type = STRING, REAL, INT, BOOL or CHAR ?
	DB 30h,(L4BF8)-$-1		; yes, jump
	DB 0feh, 4

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 30H			; error 48: Invalid result type

L4BF8:	DB 0c1h			; restore number of different types

         DB 0e1h                     ; HL = address after PROC/FUNC identifier
         DB 0e5h

         DB 0c5h

         DB 11h
	DW -4
	DB 019h
	DB 0edh,5bh
	DW L7B5A		; address of type definition info
	DB 72h
	DB 2bh
	DB 73h

L4C07:	DB 0c1h			; restore number of different types
	DB 0d1h			; DE = position after declared
				; procedure/function name
	DB 0e1h
	DB 22h
	DW L7B7B		; restore

	DB 0d5h
	DB 0c5h			; save type
	DB 0cdh
	DW  L6DC6		; add length of proc/func definition
	DB 0cdh
	DW  L6F48		; match(';')
	DB 3ah
	DW L7B99		; 0 = no overlay, 255 = overlay
	DB 0b7h
	DB 20h,(L4C44)-$-1		; jump if overlay

	DB 0cdh
	DW  L6E76		; FORWARD next ?
	DW L7533 		; start of reserved word: FORWARD
	DB 20h,(L4C2C)-$-1		; no, skip

	DB 0fdh,0e5h
	DB 0d1h			; DE = address of 'JP' opcode

	DB 0cdh
	DW  O_JPHL		; output forward jump

         DB 3eh,0FFH                  ; flag for update, update necessary
	DB 18h,( L4C38)-$-1

L4C2C:	DB 0cdh
	DW  L6E76		; EXTERNAL next ?
	DW L753A 		; start of reserved word: EXTERNAL
	DB 20h,(PF_INL)-$-1		; jump if not EXTERNAL

IFNDEF NEWEXT
	DB 0cdh
	DW  L69F2		; parse integer constant
	DB 0ebh 		; DE = start address for external routine
	DB 0afh			; no update necessary
ELSE
	DB 0fdh,0e5h			; save current code address

	DB 0cdh
	DW  L5E97		; parse integer expression

	DB 3eh,0E9H
	DB 0cdh
	DW  O_BYTE		; opcode: JP (HL)

	DB 0afh			; no update necessary

	DB 0d1h			; start address for external routine
ENDIF

L4C38:	DB 0c1h			; pop type

         DB 0e1h                     ; HL = address after PROC/FUNC identifier
	DB 77h		; save update flag
	DB 2bh
	DB 70h		; save number of different types
	DB 2bh
	DB 72h		; save proc/func call address
	DB 2bh
	DB 73h
	DB 0c3h
	DW  L6F48 		; match(';')

PF_INL:	DB 0cdh
	DW  L6E76		; INLINE next ?
	DW L75EC 		; start of reserved word: INLINE
	DB 20h,(L4C44)-$-1		; jump if not INLINE

	DB 0fdh,0e5h			; save current code address

	DB 0cdh
	DW  L5698		; parse complete INLINE statement

	DB 0afh			; no update necessary
	DB 0d1h			; start address for external routine
	DB 0c3h
	DW  L4C38

L4C44:	DB 0c1h			; B = number of different types
	DB 0e1h			; HL = position after declared name

	DB 0e5h			; save position after declared name
	DB 36h,0		; update flag, 0 = no update
	DB 2bh
	DB 70h		; save number of different types
	DB 2bh

	DB 0fdh,0e5h			; IY = current address in code
	DB 0d1h			; DE = start address of procedure/function

         DB 3ah
	DW L7B99               ; 0 = no overlay, 255 = overlay
	DB 0b7h
         DB 28h,(L4C5B)-$-1                 ; skip if no overlay

	DB 0ebh 		; adjust start address of an overlay

;         LD BC,-16                  ; 16 bytes before address of code generation
;                                    ;Ok$$$$, propably to 20
;         LD BC,-20                  ; overlay-info block length
         DB 01h
	DW -24                  ; minus overlay-info block length

         DB 09h
	DB 0ebh

L4C5B:	DB 72h		; save start address of proc or func
	DB 2bh
	DB 73h
	DB 0e1h			; HL = position after declared name
	DB 18h,( L4C76)-$-1

L4C61:	DB 7eh
	DB 0b7h

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 2BH			; error 43: Duplicate identifier or label

	DB 3ah
	DW L7B99		; 0 = no overlay, 255 = overlay
	DB 0b7h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 4CH			; error 76: Overlay cannot be forward

	DB 0cdh
	DW  L6E96
	DB 0d1h
	DB 0cdh
	DW  L6F48		; match(';')

L4C76:	DB 0ebh 		; DE = position after declared name

	DB 3ah
	DW L7B9D
	DB 02ah
	DW L7908		; HL = data start address

	DB 0cbh,057h			; 1 = Absolute Code on
         DB 28h,(L4C84)-$-1                 ; jump if not on

         DB 21h
	DW 0000                 ; absolute code on
                                    ; remember for this procedure/function

L4C84:   DB 22h
	DW L7B83              ; set data start address

	DB 02ah
	DW L7B7B
	DB 0e5h

	DB 02ah
	DW L7B73
	DB 22h
	DW L7B7B
	DB 0e5h

	DB 0ebh 		; HL = position after declared name
	DB 7eh
	DB 36h,0		; update flag, 0 = no update
	DB 2bh
	DB 46h		; B = number of different types
	DB 2bh
	DB 56h		; DE = procedure/function address
	DB 2bh
	DB 5eh
	DB 2bh
	DB 0b7h
	DB 28h,(L4CA7)-$-1		; jump if no update necessary

	DB 0e5h
	DB 0ebh
	DB 23h
         DB 0cdh
	DW  L6C3F                 ; update address at HL with current address
	DB 0e1h

L4CA7:	DB 3ah
	DW L7B97		; 0 = proc, 1 =func
	DB 0b7h
	DB 28h,(L4CD2)-$-1		; jump if procedure

	DB 56h		; DE = address of function result type
	DB 2bh
	DB 5eh
	DB 2bh
	DB 0e5h
	DB 0ebh
         DB 0cdh
	DW  L5287                 ; 8 bytes from HL (down) to 7B5C (up)
				; get all information on this type
	DB 3ah
	DW L7B5C
	DB 32h
	DW L7B87
	DB 02ah
	DW L7B62		; HL = size of the type
	DB 7dh
	DB 32h
	DW L7B88
	DB 0ebh
	DB 0cdh
	DW  L6C30		; allocate DE bytes of data for this type
	DB 22h
	DW L7B89
	DB 0ebh
	DB 0e1h
	DB 72h
	DB 2bh
	DB 73h
	DB 2bh
	DB 18h,( L4CD6)-$-1

L4CD2:   DB 11h
	DW -4                   ; skip function type definition and
                                    ; function result variable address
	DB 019h

L4CD6:   DB 11h
	DW -6                   ; -4
	DB 019h
	DB 0e5h

         DB 0eh,0                     ; start at variable 0

         DB 78h
	DB 0b7h
         DB 28h,(L4D2B)-$-1                 ; quit if 0 different types

         ; loop for variables with different type
L4CE1:   DB 7eh                  ; A = count, # variables with same type
	DB 081h
	DB 4fh
	DB 0c5h

         DB 46h                  ; B = count, # variables with same type
	DB 2bh

         DB 7eh
	DB 32h
	DW L7B8F		; 0 = no VAR, 255 = VAR
	DB 2bh

         DB 56h                  ; DE = address of type definition info
	DB 2bh
	DB 5eh
	DB 2bh

         DB 0e5h

         DB 0ebh
         DB 22h
	DW L7B5A              ; HL = address of type definition info

         DB 0cdh
	DW  L5287                 ; 8 bytes from HL (down) to 7B5C (up)

         DB 02ah
	DW L7B73

         DB 0e3h

         DB 0c5h

         ; loop for variables with same type
L4CFD:   DB 0c5h
	DB 11h
	DW 400H
	DB 0cdh
	DW  L6D75		; add DE to id table

L4D04:	DB 7eh

         DB 0cdh
	DW  L6D7A                 ; add byte to id table

	DB 0cbh,07eh
;!	pushf
	DB 2bh
;!	popf
         DB 28h,(L4D04)-$-1                 ; until end of identifier

	DB 0e5h
	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6DC6		; add length
	DB 0e1h
	DB 0c1h
         DB 10h,( L4CFD)-$-1                 ; repeat for variables with same type

         DB 0c1h

         DB 0e3h

         DB 0afh
	DB 32h
	DW L7B90		; 0 = not absolute, 255 = absolute

         DB 0cdh
	DW  L4F52

         DB 0e1h
	DB 0c1h

         DB 10h,( L4CE1)-$-1                 ; repeat for variables with different type

L4D2B:
         DB 41h                     ; B = total number of variables

         DB 0c5h

	DB 02ah
	DW L7B73
	DB 0e5h

         DB 02ah
	DW L7B83              ; save data start address
         DB 0e5h                    ; equals 0 if it is absolute code

	DB 02ah
	DW L7B89
	DB 0e5h

	DB 3ah
	DW L7B87
	DB 0f5h

	DB 3ah
	DW L7B88
	DB 0f5h

         DB 3ah
	DW L7B99               ; 0 = no overlay, 255 = overlay
         DB 0f5h

	DB 3ah
	DW L7B97		; 0 = proc, 1 = func
	DB 0f5h

	DB 21h
	DW L7B94
         DB 034h                   ; increase level

         DB 0cdh
	DW  L469E

	DB 0f1h
	DB 32h
	DW L7B97		; restore: 0 = proc, 1 = func

         DB 0f1h
         DB 32h
	DW L7B99               ; 0 = no overlay, 255 = overlay

	DB 0f1h
	DB 32h
	DW L7B88

	DB 0f1h
	DB 32h
	DW L7B87

	DB 0e1h
	DB 22h
	DW L7B89

	DB 0e1h
         DB 22h
	DW L7B83              ; restore data start address
	DW 53edh,L7B85

	DB 7ch
	DB 0b5h
	DB 28h,(L4D79)-$-1

	DB 0EDH,052h
	DB 28h,(L4D79)-$-1

	DB 0cdh
	DW  O_LDBC

	DB 0ebh
	DB 0cdh
	DW  O_LDHL

	DB 21h
	DW _L0508		; LIB, heap alloc, clear
	DB 0cdh
	DW  O_CALHL

L4D79:	DB 0e1h
	DB 0c1h
	DB 04h
	DB 05h
         DB 0cah
	DW L4DF3                 ; jump if no variables

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0FDH,0E1H		; POP IY

L4D86:	DB 0c5h
	DB 23h
	DB 5eh
	DB 23h
	DB 56h
	DB 019h
	DB 0e5h
	DB 2bh
	DB 2bh
L4D8F:	DB 0cbh,07eh
;!	pushf
	DB 2bh
;!	popf
	DB 28h,(L4D8F)-$-1
	DB 0cdh
	DW  L5276		; id info at 7B5C
	DB 3ah
	DW L7B57
	DB 0b7h
	DB 20h,(L4DD4)-$-1

	DB 3ah
	DW L7B5C
	DB 0feh, 3
	DB 38h,(L4DBD)-$-1
	DB 28h,(L4DE6)-$-1

	DB 0feh, 4			; type = POINTER ?
	DB 28h,(L4DE3)-$-1

	DB 0feh, 8
	DB 38h,(L4DBD)-$-1
	DB 28h,(L4DE6)-$-1

	DB 0feh, 0EH			; type = LONGINT ?
	DB 28h,(POPLONG)-$-1		; jump to generate code for it

	DB 0feh, 0AH
	DB 30h,(L4DE3)-$-1

	; output code to pop REAL
	DB 0cdh
	DW  O_CODE
	DB 3
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC

	DB 18h,( L4DE6)-$-1

POPLONG: DB 0cdh
	DW  O_CODE
	DB 2
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE

	DB 18h,( L4DE6)-$-1

L4DBD:	DB 0cdh
	DW  O_POPHL
	DB 02ah
	DW L7B58		; HL = lvalue of current id
	DB 0cdh
	DW  O_LDDE		; output: 'LD DE,value HL'
	DB 02ah
	DW L7B62
	DB 0cdh
	DW  O_LDBC

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0EDH,0B0H		; LDIR

	DB 18h,( L4DE9)-$-1

L4DD4:	DB 0afh
	DB 32h
	DW L7B57
	DB 3eh,4
	DB 32h
	DW L7B5C		; type = pointer
	DB 21h
	DW 0002
	DB 22h
	DW L7B62		; lenght = 2

L4DE3:	DB 0cdh
	DW  O_POPHL

L4DE6:	DB 0cdh
	DW  L661B
L4DE9:	DB 0e1h
	DB 0c1h
	DB 10h,( L4D86)-$-1

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0FDH,0E5H		; PUSH IY

L4DF3:
         DB 0cdh
	DW  L52FC                 ; start begin end part

         DB 21h
	DW L7B94
         DB 035h                   ; decrease level

         DB 3ah
	DW L7B97               ; 0 = proc, 1 = func
	DB 0b7h
         DB 28h,(L4E46)-$-1                 ; jump if proc

         DB 02ah
	DW L7B89
	DB 3ah
	DW L7B87
	DB 0feh, 8			; type = STRING ?
	DB 20h,(L4E24)-$-1		; jump if not STRING

	DB 47h

	DB 0cdh
	DW  O_CODE
	DB 2
         DB 0FDH,0E1H               ; POP IY, save return address

	DB 3eh,21H
	DB 0cdh
	DW  O_OPHL		; LD HL, HL

	DB 21h
	DW _L053A		; LIB, clear
	DB 0cdh
	DW  O_CALHL

	DB 0cdh
	DW  O_CODE
	DB 2
         DB 0FDH,0E5H               ; PUSH IY, restore return address

         ; stack: STRING
         ;        return address

	DB 18h,( L4E46)-$-1

L4E24:	DB 0feh, 9
	DB 20h,(L4E35)-$-1

	DB 3eh,21H
	DB 0cdh
	DW  O_OPHL		; LD HL, HL

	DB 21h
	DW _L052C		; LIB, GETFLT
	DB 0cdh
	DW  O_CALHL		; CALL _L052C
	DB 18h,( L4E46)-$-1

L4E35:	DB 3eh,2AH
	DB 0cdh
	DW  O_OPHL		; LD HL,( HL )

	DB 3ah
	DW L7B88
	DB 3dh
	DB 20h,(L4E46)-$-1

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 26H,00H		; LD H,0

L4E46:   DB 02ah
	DW L7B83
	DB 7ch
	DB 0b5h
         DB 28h,(L4E78)-$-1                 ; jump if absolute code

         ; HL = data start address

         DB 0edh,5bh
	DW L7B85
	DB 0EDH,052h
	DB 28h,(L4E74)-$-1

         DB 3ah
	DW L7B97               ; 0 = proc, 1 = func
	DB 0b7h
	DB 28h,(L4E65)-$-1		; no EXX if a procedure call

	DB 3ah
	DW L7B87
         DB 0feh, 8                       ; type = STRING ?

         DB 3eh,0D9H                  ; opcode: EXX
         DB 0c4h
	DW O_BYTE             ; yes, output EXX

L4E65:	DB 0cdh
	DW  O_LDBC
	DB 0ebh
	DB 0cdh
	DW  O_LDDE		; output: 'LD DE,value HL'

         DB 21h
	DW _L0522               ; LIB, heap de-alloc
         DB 0cdh
	DW  O_CALHL

;         JR L4E79

L4E74:   ; recursive code

         DB 3ah
	DW L7B97               ; 0 = proc, 1 = func
	DB 0b7h
         DB 28h,(L4E76)-$-1                 ; no EXX if a procedure call

	DB 3ah
	DW L7B87
         DB 0feh, 8                       ; type = STRING ?

         DB 3eh,0D9H                  ; opcode: EXX
         DB 0c4h
	DW O_BYTE             ; yes, output EXX

L4E76:
         DB 3ah
	DW L7B99
         DB 0b7h
         DB 28h,(L4E78)-$-1                 ; jump if no overlay

         DB 0d1h                     ; DE = address of high byte of PROC/FUNC
                                    ; struct length
         DB 0d5h

         DB 21h
	DW 12
         DB 019h
         DB 7eh
         DB 2bh
         DB 6eh
         DB 67h                     ; HL = address of overlay proc

         DB 23h                     ; skip CALL instruction
         DB 23h
         DB 23h

         DB 0cdh
	DW  O_LDHL                ; output: 'LD HL,value HL'

         DB 21h
	DW _OVERLAYREC1         ; LIB, Load only overlay code
	DB 0cdh
	DW  O_JPHL

         DB 18h,( L4E79)-$-1

L4E78:   DB 0cdh
	DW  O_CODE                ; output: ret
	DB 1
	DB 0C9H			; RET

L4E79:   DB 0cdh
	DW  L6F48                 ; match(';')

         DB 0d1h                     ; DE = address of high byte of PROC/FUNC
                                    ; struct length

         DB 0e1h
         DB 22h
	DW L7B73              ; HL = address after PROC/FUNC struct length
	DB 22h
	DW L7B75

         DB 0e1h
         DB 22h
	DW L7B7B              ; HL = position after declared PROC/FUNC
                                    ;      name
         DB 0ebh
         ; HL = high byte of struct length
         ; DE = position after declared PROC/FUNC name
	DB 0c9h

L4E8A:	DB 02ah
	DW L7B73		; HL = address to add an identifier
L4E8D:	DB 0edh,5bh
	DW L7B7B		; HL = start of identifier list
	DB 0b7h
	DB 0EDH,052h
;!	pushf
	DB 019h
;!	popf
	DB 0c8h			; quit if no identifiers
	DB 23h
	DB 5eh		; DE = offset
	DB 23h
	DB 56h
	DB 019h
	DB 7eh
	DB 0feh, 6
	DB 28h,(L4EA4)-$-1
	DB 0feh, 5
	DB 20h,(L4E8D)-$-1
L4EA4:	DB 0e5h
	DB 2bh
	DB 2bh
L4EA7:	DB 0cbh,07eh
;!	pushf
	DB 2bh
;!	popf
	DB 28h,(L4EA7)-$-1
	DB 7eh		; A = byte after name
	DB 0b7h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 49H			; error 73: Undefined FORWARD procedure(s)

	DB 0e1h
	DB 18h,( L4E8D)-$-1

L4EB5:	; in:	-
	; out:	HL = top of stack before variable name declarations
	;	 B = number of variable name declarations
	DB 02ah
	DW L7B73
	DB 0e5h
	DB 06h,0
L4EBB:	DB 0c5h
	DB 16h,4
	DB 3ah
	DW L7B91
	DB 5fh
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6D87		; add identifier to id table
	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6DC6		; add length
	DB 0c1h
	DB 04h
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L4EBB)-$-1		; yes, an other declaration
	DB 0e1h
	DB 0c9h

L4EDD:	DB 02ah
	DW L7B73
	DB 0e5h
	DB 0cdh
	DW  L4F9B		; parse every possible type

	DB 0e1h			; address where to stop reference search
	DB 0cdh
	DW  L5295		; update pointer references

	DB 0cdh
	DW  L6E76		; followed by 'ABSOLUTE'?
	DW L7562 		; start of reserved word: ABSOLUTE

	DB 3eh,0			; assume no 'absolute'
	DB 20h,(L4F14)-$-1		; no, continue

	DB 3ah
	DW L7B91
	DB 0b7h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 4BH			; error 75: Illegal use of ABSOLUTE

	DB 01h
	DW 400H		; variable identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
	DB 20h,(L4F0C)-$-1		; no variable identifier, try address

	DB 7eh
	DB 32h
	DW L7B8F		; 0 = no VAR, 255 = VAR
	DB 2bh
	DB 56h		; DE = lvalue of variable
	DB 2bh
	DB 5eh
	DB 0ebh
	DB 18h,( L4F0F)-$-1

L4F0C:	DB 0cdh
	DW  L69F2		; parse integer constant

L4F0F:	DB 22h
	DW L7B7F
	DB 3eh,0FFH		; absolute anyway

L4F14:	DB 32h
	DW L7B90		; 0 = not absolute, 255 = absolute
	DB 0c9h

L4F18:
	; L7B5C..L7B63 filled in with type info
	DB 0cdh
	DW  L4FC8		; find type identifier
				; and fill L7B5C..L7B63
	DB 28h,(L4F181)-$-1		; jump if type identifier found

	DB 0cdh
	DW  L6E76
	DW L754D 		; start of reserved word: FILE

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 24H			; error 36: Type identifier expected

	DB 21h
	DW FILEDEF		; address of definition of type
	DB 22h
	DW L7B5A		; save address to definition info
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)

L4F181:
	DB 0afh
	DB 32h
	DW L7B90		; 0 = not absolute, 255 = absolute

	DB 3ah
	DW L7B8F		; 0 = no VAR, 255 = VAR
	DB 0b7h
	DB 0c0h			; return if VAR
	DB 3ah
	DW L7B5C
	DB 0feh, 5
	DB 0d8h
	DB 0feh, 8
	DB 0d0h

	; error: 5 (typed file), 6 (text) and 7 (untyped file)
	DB 0cdh
	DW  L72E1		; no condition
	DB 43H			; error 67: Files must be variable parameters

L4F35:	DB 0cdh
	DW  L4EB5		; parse variable names
	DB 0e5h			; save variable position
	DB 0c5h			; save number of names parsed
	DB 0cdh
	DW  L6F40		; match(':')
	DB 0afh
	DB 32h
	DW L7B8F		; 0 = no VAR, 255 = VAR
	DB 0cdh
	DW  L4EDD
	DB 0c1h
	DB 3ah
	DW L7B90		; 0 = not absolute, 255 = absolute
	DB 0b7h			; absolute?
	DB 28h,(L4F51)-$-1		; no, continue
	DB 78h
	DB 3dh

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 4BH			; error 75: Illegal use of ABSOLUTE

L4F51:	DB 0e1h

L4F52:	; in:	B = number of variable names parsed before the type
	DB 0c5h
	DB 0e5h
	DB 3ah
	DW L7B8F		; 0 = no VAR, 255 = VAR
	DB 21h
	DW 0002		; assume size = 2 if VAR
	DB 0b7h
	DB 20h,(L4F60)-$-1		; jump if VAR
	DB 02ah
	DW L7B62		; get real size

L4F60:	DB 0ebh
	DB 3ah
	DW L7B91
	DB 0b7h
	DB 20h,(L4F72)-$-1
	DB 3ah
	DW L7B90		; 0 = not absolute, 255 = absolute
	DB 0b7h			; variable at absolute address ?
	DB 20h,(L4F72)-$-1		; yes, no allocation

	DB 0cdh
	DW  L6C30		; allocate data space, HL = address
	DB 18h,( L4F7B)-$-1

L4F72:	DB 02ah
	DW L7B7F
	DB 0e5h
	DB 019h
	DB 22h
	DW L7B7F
	DB 0e1h
L4F7B:	DB 0ebh 		; DE = address of variable space
	DB 0e1h			; HL = start of declaration
	DB 2bh
L4F7E:	DB 2bh
	DB 0cbh,07eh
	DB 28h,(L4F7E)-$-1
	DB 2bh			; HL = points to byte after name
	DB 3ah
	DW L7B8F		; 0 = no VAR, 255 = VAR
	DB 77h		; place on byte after name
	DB 2bh
	DB 72h		; high byte of variable space address
	DB 2bh
	DB 73h		; put low byte
	DB 2bh
	DB 0edh,5bh
	DW L7B5A		; type info address
	DB 72h
	DB 2bh
	DB 73h
	DB 2bh			; point to high byte of offset
	DB 2bh			; point to low byte of offset
	DB 2bh			; address of next possible declaration
	DB 0c1h
	DB 10h,( L4F52)-$-1		; repeat for the next variable
				; of the same type
	DB 0c9h

L4F9B:	; in:	HL = start of identifier list
	; out:	-
	DB 0cdh
	DW  L4FC8		; find type identifier
	DB 0c8h			; quit if found

	DB 0cdh
	DW  L6E76
	DW L7542 		; start of reserved word: PACKED
				; just reads(eats) it away

	DB 0cdh
	DW  L4FDB		; parses an ARRAY
	DB 0c8h			; quit if an ARRAY was parsed

	DB 0cdh
	DW  L5039		; parses a RECORD
	DB 0c8h			; quit if a RECORD was parsed

	DB 0cdh
	DW  L5106		; parses a SET
	DB 0c8h			; quit if a SET was parsed

	DB 0cdh
	DW  L5140
	DB 0c8h

	DB 0cdh
	DW  L516B		; parses a FILE
	DB 0c8h			; quit if a FILE was parsed

	DB 0cdh
	DW  L51A5		; parses a STRING type
	DB 0c8h			; quit if a STRING was parsed

	DB 0cdh
	DW  L51C5		; parses a SCALAR type
	DB 0c8h			; quit if a SCALAR type was parsed

	DB 0cdh
	DW  L5210		; parses a subrange-type
	DB 0c8h			; quit if a <m>..<n> parsed

	DB 0cdh
	DW  L72E1		; no condition
	DB 24H			; error 36: Type identifier expected

L4FC8:	; SYNTAX: type-identifier ::= identifier
	; in:	IX = address of current type identifier in text
	; out:	Z = 0, type identifier found and L7B5C..L7B63 filled in
	DB 01h
	DW 300H		; type identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list, types
				; HL = address of info
	DB 0c0h			; quit if type identifier not found

	; HL = address of pointer to definition of type
	DB 56h		; DE = address of type definition
	DB 2bh
	DB 5eh
	DB 0ebh
	DB 22h
	DW L7B5A		; save address to definition info
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)
	DB 0afh
	DB 0c9h

L4FDB:	; parses a complete ARRAY type
	DB 0cdh
	DW  L6E76
	DW L7548 		; start of reserved word: ARRAY
	DB 0c0h

	DB 0cdh
	DW  L6F30		; match('[')

	DB 06h,0			; 0 indices

L4FE6:	DB 0c5h
	DB 0cdh
	DW  L523B		; parse a simple-type = index-type
	DB 0c1h

	DB 02ah
	DW L7B5A		; HL = address of type info
	DB 0e5h

	DB 02ah
	DW L7B60		; HL = maximum value
	DB 0edh,5bh
	DW L7B5E		; DE = minimum value
	DB 0b7h
	DB 0EDH,052h
	DB 23h
	DB 7ch
	DB 0b5h

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 62H			; error 98: Memory overflow

	DB 0e5h			; push range size

	DB 04h			; increase # indices
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L4FE6)-$-1		; jump if ',' matched

	DB 0c5h

	DB 0cdh
	DW  L6F38		; match(']')
	DB 0cdh
	DW  L6F88		; match('OF')
	DB 0cdh
	DW  L4F9B		; parse every possible type

	DB 0c1h			; B = # indices

	; parsed: 0..15 , 15..32
	; stack: 	<type info>	info of 0..15
	;		<range size>	16
	;		<type info>	info of 15..32
	;		<range size>	18

L5012:	DB 02ah
	DW L7B5A		; HL = address of last type info
	DB 22h
	DW L7B5E

	DB 02ah
	DW L7B62		; HL = total size of array declaration

	DB 0d1h			; DE = range size of last

	DB 0c5h			; save count
	DB 0cdh
	DW  L729A		; multiply HL = HL * DE

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 62H			; error 98: Memory overflow
	DB 0c1h			; restore count

	DB 22h
	DW L7B62		; set new size of array declaration

	DB 0e1h
	DB 22h
	DW L7B60		; HL = address to info about index-type
	DB 3eh,1
	DB 32h
	DW L7B5C
	DB 0c5h
	DB 0cdh
	DW  L5254		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct
	DB 0c1h
	DB 10h,( L5012)-$-1
	DB 0c9h

L5039:	; parses a complete RECORD type
	DB 0cdh
	DW  L6E76
	DW L7554 		; start of reserved word: RECORD
	DB 0c0h
	DB 3ah
	DW L7B9A
	DB 0f5h
	DB 3ah
	DW L7B91
	DB 0f5h
	DB 21h
	DW L7B92
	DB 034h 		; increase depth within record ?
	DB 7eh
	DB 32h
	DW L7B91
	DB 02ah
	DW L7B7F
	DB 0e5h
	DB 02ah
	DW L7B81
	DB 0e5h
	DB 21h
	DW 0000
	DB 22h
	DW L7B7F
	DB 22h
	DW L7B81
	DB 0afh
	DB 32h
	DW L7B9A
	DB 0cdh
	DW  L508B
	DB 02ah
	DW L7B81
	DB 22h
	DW L7B62
	DB 0e1h
	DB 22h
	DW L7B81
	DB 0e1h
	DB 22h
	DW L7B7F
	DB 3ah
	DW L7B91
	DB 32h
	DW L7B5D
	DB 0f1h
	DB 32h
	DW L7B91
	DB 0f1h
	DB 32h
	DW L7B9A
	DB 3eh,2
	DB 32h
	DW L7B5C
	DB 0c3h
	DW  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L508B:	DB 0cdh
	DW  L50F9
	DB 0c8h
	DB 0cdh
	DW  L6E76
	DW L75DA 		; start of reserved word: CASE
	DB 28h,(L50B0)-$-1
	DB 0cdh
	DW  L4F35
	DB 02ah
	DW L7B7F
	DB 0edh,5bh
	DW L7B81
	DB 0b7h
	DB 0EDH,052h
	DB 38h,(L50A9)-$-1
	DB 019h
	DB 22h
	DW L7B81
L50A9:	DB 0cdh
	DW  L6F0F		; match(';'), if present
	DB 28h,(L508B)-$-1		; jump if ';' matched
	DB 18h,( L50E8)-$-1

L50B0:	DB 0cdh
	DW  L4FC8		; find type identifier
	DB 0c4h
	DW L4F35

	DB 0cdh
	DW  L6F88		; match('OF')

L50B9:	DB 0cdh
	DW  L50F9
	DB 0c8h

	DB 02ah
	DW L7B7F
	DB 0e5h

L50C1:	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L50C1)-$-1		; jump if ',' matched
	DB 0cdh
	DW  L6F40		; match(':')
	DB 0cdh
	DW  L6F66		; match('(')
	DB 3ah
	DW L7B9A
	DB 0f5h
	DB 3eh,0FFH
	DB 32h
	DW L7B9A
	DB 0cdh
	DW  L508B
	DB 0f1h
	DB 32h
	DW L7B9A
	DB 0e1h
	DB 22h
	DW L7B7F
	DB 0cdh
	DW  L6F0F		; match(';'), if present
	DB 28h,(L50B9)-$-1		; jump if ';' matched
L50E8:	DB 3ah
	DW L7B9A
	DB 0b7h
	DB 0c2h
	DW L6F6E		 ; match(')')
	DB 0cdh
	DW  L6E76
	DW L7530 		; start of reserved word: END
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 0EH			; error 14: END expected

L50F9:	DB 3ah
	DW L7B9A
	DB 0b7h
	DB 0c2h
	DW L6F1F		; match(')'), if present
				; and return
	DB 0cdh
	DW  L6E76
	DW L7530 		; start of reserved word: END
	DB 0c9h

L5106:	; parses a complete SET type
	DB 0cdh
	DW  L6E76
	DW L7551 		; start of reserved word: SET
	DB 0c0h
	DB 0cdh
	DW  L6F88		; match('OF')
	DB 0cdh
	DW  L523B		; parse a simple-type = base-type
	DB 02ah
	DW L7B60
	DB 0edh,5bh
	DW L7B5E
	DB 7ch
	DB 0b2h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 46H			; error 70: Set base type out of range

	DB 0cbh,3dh
	DB 0cbh,3dh
	DB 0cbh,3dh
	DB 0cbh,3bh
	DB 0cbh,3bh
	DB 0cbh,3bh
	DB 7dh
	DB 3ch
	DB 093h
	DB 6fh
	DB 22h
	DW L7B62
	DB 02ah
	DW L7B5A
	DB 22h
	DW L7B5E
	DB 3eh,3
	DB 32h
	DW L7B5C		; type = SET
	DB 0c3h
	DW  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L5140:	DB 0cdh
	DW  L6F27		; match('^')
	DB 0c0h
	DB 11h
	DW 0000
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 02ah
	DW L7B73
	DB 0e5h
	DB 0cdh
	DW  L6DBA
	DB 0cdh
	DW  L6DC6		; add length
	DB 0e1h
	DB 22h
	DW L7B5E
	DB 3eh,4			; type = POINTER
	DB 32h
	DW L7B5C
	DB 3eh,0FFH
	DB 32h
	DW L7B5D
	DB 21h
	DW 0002
	DB 22h
	DW L7B62		; length = 2 bytes
	DB 0c3h
	DW  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L516B:	; parses a complete FILE type
	DB 0cdh
	DW  L6E76
	DW L754D 		; start of reserved word: FILE
	DB 0c0h			; return if no FILE found

	DB 0cdh
	DW  L6E76
	DW L7560 		; start of reserved word: OF
	DB 20h,(L5197)-$-1		; jump if no OF found, untyped file found

	DB 0cdh
	DW  L4F9B		; parse every possible type

	DB 3ah
	DW L7B5C
	DB 0feh, 5
	DB 38h,(L518A)-$-1		; < 5, a typed file
	DB 0feh, 8
	DB 30h,(L518A)-$-1		; jump if >= 8

	DB 0cdh
	DW  L72E1		; no condition
	DB 44H			; error 68: File components can not be files

L518A:	DB 02ah
	DW L7B5A
	DB 22h
	DW L7B5E
	DB 3eh,5			; typed file does have a sector buffer
         DB 21h
	DW DOS_LEN-128          ; 33e bug ????? ; length of FIB with sector buffer
	DB 18h,( L519C)-$-1

L5197:	DB 3eh,7			; untyped file has no sector buffer
         DB 21h
	DW DOS_LEN-128          ; length of FIB without sector buffer

L519C:	DB 32h
	DW L7B5C		; save type (5, 6 or 7)
	DB 22h
	DW L7B62		; save length
	DB 0c3h
	DW  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L51A5:	; parses a complete STRING type
	DB 0cdh
	DW  L6E76
	DW L755A 		; start of reserved word: STRING
	DB 0c0h

	DB 0cdh
	DW  L6F30		; match('[')

	DB 0cdh
	DW  L69F2		; parse integer constant

	DB 24h			; length >= 256 ?
	DB 25h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 31H			; error 49: Invalid String length

	DB 2ch			; length = 0 ?
	DB 2dh

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 31H			; error 49: Invalid String length

	DB 0cdh
	DW  L6F38		; match(']')
	DB 23h			; length + 1 = string + count byte
	DB 3eh,8			; type = STRING
	DB 18h,( L519C)-$-1

L51C5:	; SYNTAX: scalar-type ::= ( identifier {, identifier } )
	; parses a complete SCALAR type
	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 0c0h			; return if '(' not matched

	DB 21h
	DW -1 		; HL = upper bound = -1

	; (Maandag,Dinsdag,Woensdag,Donderdag,Vrijdag)
	; (0,	  1,	 2,	 3,	  4	)

L51CC:	DB 0e5h
	DB 11h
	DW 200H		; constant
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0cdh
	DW  L6D87		; add identifier to id table
	DB 3ah
	DW L7B93
	DB 0cdh
	DW  L6D7A		; add byte to id table

	DB 0d1h
	DB 13h			; increase upper bound, value of constant
	DB 0d5h

	DB 0cdh
	DW  L6D75		; add DE to id table, value of constant
	DB 0cdh
	DW  L6DC6		; add length

	DB 0e1h			; HL = upper bound

	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L51CC)-$-1		; jump if ',' matched

	DB 0cdh
	DW  L6F6E		; match(')')

	DB 0e5h

	DB 21h
	DW L7B93
	DB 7eh
	DB 034h 		; increase type for next SCALAR

	DB 0e1h			; HL = upper bound

	DB 11h
	DW 0000		; SCALAR lower bound = 0

L51F8:	DB 32h
	DW L7B5C		; save type
	DW 53edh,L7B5E		; save lower bound
	DB 22h
	DW L7B60		; save upper bound
	DB 7ah			; difference >= 256 ?
	DB 0b4h
	DB 21h
	DW 0001		; assume one byte
	DB 28h,(L520A)-$-1		; jump if only one byte needed

	DB 23h			; no, two bytes needed

L520A:	DB 22h
	DW L7B62		; save size
	DB 0c3h
	DW  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L5210:	; SYNTAX: subrange-type ::= constant .. constant
	; parses a complete <m>..<n> type
	DB 3eh,0AH 		; default type = INTEGER
	DB 32h
	DW DEF_TYPE

	DB 0cdh
	DW  L6A0D		; parse a constant of any type
	DB 0c0h			; return if not succeeded

	DB 78h
	DB 0f5h

	DB 0feh, 0AH			; type = INTEGER, BOOLEAN or CHAR ?
	DB 0cdh
	DW  L72C8		; carry set --> error (type < 0AH)
	DB 33H			; error 51: Invalid subrange base type

	DB 0feh, 0EH			; type = LONGINT ?
	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 33H			; error 51: Invalid subrange base type

	DB 0e5h			; save value of <m>

	DB 0cdh
	DW  L6E76
	DW L7580 		; start of reserved word: ..

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 0BH			; error 11: '..' expected

	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found

	DB 0d1h			; HL = value of <n>
				; DE = value of <m>
	DB 0f1h			; A = type of <m>
	DB 0f5h
	DB 0b8h			; <m> type = <n> type ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0cdh
	DW  L728D		; check if lower bound <= upper bound

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 34H			; error 52: Lower bound > upper bound

	DB 0f1h			; A = type of <m>
	DB 18h,( L51F8)-$-1

L523B:	; SYNTAX: base-type   ::=
	;	 index-type  ::=
	;	 simple-type ::= scalar-type | subrange-type | type-identifier
	DB 0cdh
	DW  L5210		; parses a subrange-type
	DB 0c8h			; quit if a <m>..<n> parsed

	DB 0cdh
	DW  L51C5		; parses a SCALAR type
	DB 0c8h			; quit if a SCALAR type was parsed

	DB 0cdh
	DW  L4FC8		; find type identifier

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 1EH			; error 30: Simple type expected

	DB 3ah
	DW L7B5C
	DB 0feh, 0AH
	DB 0d0h			; return if type = INTEGER, BOOLEAN or CHAR

	DB 0cdh
	DW  L72E1		; no condition
	DB 1EH			; error 30: Simple type expected

L5254:	; add L7B5C .. L7B63
	; out:	A = 0, NonCarry, Z-flag = 1
	;	L7B5A points to last added type
	DB 11h
	DW 800H
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 02ah
	DW L7B73
	DB 22h
	DW L7B5A		; save for connection with last added type

	DB 21h
	DW L7B5C
	DB 06h,8

L5265:	DB 7eh
	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 23h
	DB 10h,( L5265)-$-1

	DB 0cdh
	DW  L6DC6		; add length
	DB 0afh
	DB 0c9h

L5271:	; 8 bytes from HL (down) to 7B69 (up)
	DB 11h
	DW L7B69
	DB 18h,( L528A)-$-1

L5276:	; in:	HL = address after word in id table
	; out:	byte at (HL) moved to L7B57
	;	address at (HL-1), (HL-2) move to L7B58
	;	8 bytes from address (HL-3), (HL-4) to L7B5C
	DB 7eh		; A = 1e byte after word
	DB 2bh
	DB 32h
	DW L7B57
	DB 56h
	DB 2bh
	DB 5eh
	DB 2bh
	DW 53edh,L7B58		; save lvalue of id
	DB 56h
	DB 2bh
	DB 5eh
	DB 0ebh

L5287:	; 8 bytes from HL (down) to 7B5C (up)
	DB 11h
	DW L7B5C

L528A:	DB 0c5h
	; copy from HL to DE in the opposite directions
	DB 06h,8
L528D:	DB 7eh
	DB 12h
	DB 2bh
	DB 13h
	DB 10h,( L528D)-$-1
	DB 0c1h
	DB 0c9h

L5295:	; update pointer references
	; in:	HL = top of symbol table
	DB 22h
	DW L7B79		; address where to stop reference search
	DB 02ah
	DW L7B73

L529B:	DB 0edh,4bh
	DW L7B79
	DB 0b7h
	DB 0EDH,042h
;!	pushf
	DB 09h
;!	popf
	DB 0c8h			; quit if equal (end of struct reached)
	DB 23h
	DB 4eh		; BC = length of added struct
	DB 23h
	DB 46h
	DB 09h
	DB 7eh		; highest byte of struct = 8 ?
	DB 0feh, 8
	DB 20h,(L529B)-$-1		; search for next while not 8

	DB 36h,0		; yes, make 0 ?!?
	DB 0e5h
	DB 2bh
	DB 2bh
	DB 7eh
	DB 0feh, 4			; type of struct = POINTER ?
	DB 20h,(L52F8)-$-1		; jump if not a POINTER, continue loop

	DB 2bh
	DB 7eh
	DB 0b7h
	DB 28h,(L52F8)-$-1		; jump if zero, no update necessary

	DB 36h,0
	DB 2bh
	DB 0e5h
	DB 5eh
	DB 2bh
	DB 56h

	DB 02ah
	DW L7B73

L52C7:	DB 0edh,4bh
	DW L7B77		; BC = absolute top of id list
	DB 0b7h
	DB 0EDH,042h
;!	pushf
	DB 09h
;!	popf

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 2AH			; error 42: Undefined pointer type in
				;	   preceding type definitions
	DB 23h
	DB 4eh
	DB 23h
	DB 46h
	DB 09h
	DB 7eh
	DB 0feh, 3
	DB 20h,(L52C7)-$-1

	DB 0e5h
	DB 0d5h
	DB 2bh
	DB 2bh
L52E1:	DB 1ah
	DB 0beh
	DB 28h,(L52E9)-$-1
	DB 0d1h
	DB 0e1h
	DB 18h,( L52C7)-$-1

L52E9:	DB 0cbh,07eh
;!	pushf
	DB 2bh
	DB 1bh
;!	popf
	DB 28h,(L52E1)-$-1
	DB 0c1h
	DB 0c1h
	DB 46h
	DB 2bh
	DB 4eh
	DB 0e1h
	DB 71h
	DB 2bh
	DB 70h
L52F8:	DB 0e1h
	DB 0c3h
	DW  L529B

L52FC:	DB 0afh
	DB 32h
	DW L7B95
	DB 32h
	DW L7BC9

         DB 0cdh
	DW  L5377                 ; statements ended by 'END'

	DW 22fdh,L7BA4
	DB 0cdh
	DW  O_JPHL

         DB 02ah
	DW L7B73

L5310:	DB 0edh,5bh
	DW L7B75
	DB 0b7h
	DB 0EDH,052h
	DB 019h
	DB 30h,(L5363)-$-1
	DB 23h
	DB 4eh
	DB 23h
	DB 46h
	DB 23h
	DB 7eh
	DB 23h
	DB 5eh
	DB 23h
	DB 56h
	DB 0e5h
	DB 0c5h
	DB 47h
	DB 7ah
	DB 0b3h
	DB 28h,(L533A)-$-1
	DB 0ebh
	DB 2bh
	DB 7eh
	DB 4fh
	DB 3ch

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 28H			; error 40: Undefined label

	DB 2bh
	DB 56h
	DB 2bh
	DB 5eh
	DB 18h,( L5340)-$-1

L533A:	DB 0edh,5bh
	DW L7BA4
	DB 0eh,0
L5340:	DB 0e1h
	DB 78h
	DB 091h
	DB 20h,(L534A)-$-1

         DB 0cdh
	DW  L6C42                 ; update address at HL with contents of DE

	DB 18h,( L5360)-$-1

L534A:	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 47H			; error 71: Invalid GOTO

	DB 0d5h
	DB 0f5h
         DB 0cdh
	DW  L6C3F                 ; update address at HL with current address
	DB 0f1h
	DB 47h

L5355:	DB 0cdh
	DW  O_POPHL
	DB 10h,( L5355)-$-1

	DB 3eh,0C3H		; opcode: JP
	DB 0e1h
	DB 0cdh
	DW  O_OPHL		; JP HL

L5360:	DB 0e1h
	DB 18h,( L5310)-$-1

L5363:	DB 02ah
	DW L7BA4
	DB 23h
	DB 0fdh,0e5h
	DB 0d1h
	DB 1bh
	DB 1bh
	DB 0b7h
	DB 0EDH,052h
;!	pushf
	DB 019h
;!	popf
         DB 0c2h
	DW L6C3F                ; update address at HL with current address
	DB 2bh
	DB 0c3h
	DW  L6CC2

L5377:   ; statement { ; statement } end
	DB 0cdh
	DW  L5385		; statement

	DB 0cdh
	DW  L6E76		; next word is END ?
	DW L7530 		; start of reserved word: END
	DB 0c8h			; yes, return

	DB 0cdh
	DW  L6F50		; match(';')
	DB 18h,( L5377)-$-1 		; repeat for next statement

L5385:	DB 3eh,0AH 		; default type = INTEGER
	DB 32h
	DW DEF_TYPE
	DB 3eh,0FFH
	DB 32h
	DW L7B98
	DB 3ah
	DW L7B9D		; compiler directives
	DB 32h
	DW L7B9E		; save them
	DB 0cbh,05fh			; 1 = User Interrupt on
	DB 28h,(L539C)-$-1		; jump if off

	DB 3eh,0CFH		; 0CFH = RST 0008H, patch
				; 0FFH = RST 0038H
	DB 32h
	DW L7BA0

	DB 0cdh
	DW  O_BYTE

L539C:	DB 0cdh
	DW  L6E5A
	DB 2			; 2 bytes following
	DW L75BB 		; start of reserved word list:
				; BEGIN, IF, WHILE, REPEAT, FOR
				; CASE, GOTO, WITH, INLINE
	DB 28h,(L53CB)-$-1		; start code of found reserved word

	DB 0cdh
	DW  L67B2
	DB 0cah
	DW L57EA

	DB 01h
	DW 500H		; procedure identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
         DB 0cah
	DW L573D                 ; jump if procedure

	DB 01h
	DW 100H		; label identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
	DB 28h,(L53D0)-$-1		; jump if label

	DB 01h
	DW 600H		; function identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
         DB 0cah
	DW L591F

	DB 0cdh
	DW  L6E5A
	DB 2			; 2 byte following
	DW L7638 		; start of reserved word list:
				; standard library procedure's
				; WRITELN .. BIOS, 47
	DB 0c0h

L53CB:	; jumps to the address at hl
	; in:	HL = address of an address
	; out:	-
	DB 5eh
	DB 23h
	DB 56h
	DB 0ebh
	DB 0e9h

L53D0:	DB 0cdh
	DW  L6F40		; match(':')
	DB 3ah
	DW L7B94
	DB 0beh

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 48H			; error 72: Label not within current block

	DB 2bh
	DB 7eh
	DB 3ch

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2BH			; error 43: Duplicate identifier or label

	DB 3ah
	DW L7B95
	DB 77h
	DB 0fdh,0e5h
	DB 0d1h
	DB 2bh
	DB 72h
	DB 2bh
	DB 73h
	DB 18h,( L5385)-$-1 		; next statement

L53EF:	DB 0cdh
	DW  L5EB0		; parse boolean expression

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 0CBH,45H		; BIT 0,L
	DB 0CAH			; opcode of 'JP Z,'

	DB 0fdh,0e5h
	DB 0cdh
	DW  O_HL		; out: address for 'JP Z,'

	DB 0cdh
	DW  L6E76
	DW L756A 		; start of reserved word: THEN

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 11H			; error 17: THEN expected

	DB 0cdh
	DW  L5385		; statement

         DB 0cdh
	DW  L6E76
	DW L756E 		; start of reserved word: ELSE
	DB 20h,(L5420)-$-1

         DB 0cdh
	DW  O_C3

         DB 0e1h
	DB 0fdh,0e5h
	DB 0cdh
	DW  O_HL

         DB 0cdh
	DW  L6C3F                 ; update address at HL with current address
	DB 0cdh
	DW  L5385		; statement

L5420:   DB 0e1h
         DB 0c3h
	DW  L6C3F                   ; update address at HL with current address

BOOLOPER:DB 0			; Zero = lowest level
BOOLOPTIM:DB 0			; Zero = no optimization in code
				; NonZero = optimize code for boolean
				;	   evaluation

L5424:	; while-statement ::= WHILE expression do statement
	DB 0afh
	DB 32h
	DW BOOLOPER		; default no operator
	DB 3dh
	DB 32h
	DW BOOLOPTIM		; boolean optimize on
	DB 0fdh,0e5h
	DB 0cdh
	DW  L5EB0		; parse boolean expression
	DB 0cdh
	DW  L6E76
	DW L7572 		; start of reserved word: DO

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 0DH			; error 13: DO expected

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 0CBH,45H		; BIT 0,L
	DB 0CAH			; opcode of 'JP Z,'

	DB 0fdh,0e5h
	DB 0cdh
	DW  O_HL

	DB 0cdh
	DW  L5385		; statement

	DB 0d1h
	DB 0e1h

	DB 3eh,0C3H		; opcode: JP
	DB 0cdh
	DW  O_OPHL		; JP HL

	DB 0ebh
         DB 0c3h
	DW  L6C3F                   ; update address at HL with current address

L544C:	; repeat-statement ::= REPEAT statement {; statement} UNTIL expression
	DB 0fdh,0e5h

L544E:	DB 0cdh
	DW  L5385		; statement

	DB 0cdh
	DW  L6E76
	DW L7574 		; start of reserved word: UNTIL
	DB 28h,(L545D)-$-1

	DB 0cdh
	DW  L6F50		; match(';')
	DB 18h,( L544E)-$-1

L545D:	DB 0cdh
	DW  L5EB0		; parse boolean expression

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 0CBH,45H		; BIT 0,L
	DB 0CAH			; opcode for 'JP Z,'

	DB 0e1h
	DB 0c3h
	DW  O_HL

L546B:	; for-statement::=for control-variable:=for-list do statement
	DB 01h
	DW 400H		; variable identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax error

	DB 0cdh
	DW  L5276		; id info at 7B5C
	DB 3ah
	DW L7B57
	DB 0b7h
	DB 20h,(L5485)-$-1

	DB 3ah
	DW L7B5C
	DB 0feh, 0AH
	DB 30h,(L5489)-$-1

L5485:	DB 0cdh
	DW  L72E1		; no condition
	DB 1EH			; error 30: Simple type expected

L5489:	DB 0cdh
	DW  L6D2A		; push 13, L7B57
	DB 3ah
	DW L7B5C
	DB 0f5h			; save type before assignment

	DB 0cdh
	DW  L6F7E		; match(':=')

	DB 0f1h
	DB 0f5h
	; A = type of before assignment
	DB 0cdh
	DW  L5EE8		; parse expression

	DB 0cdh
	DW  O_PSHHL		; generate code to push initial value

	DB 0f1h
	DB 0f5h
	DB 0b8h			; types are equal ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following
	DW L75F5 		; start of reserved word list:
				; TO, DOWNTO

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 12H			; error 18: TO or DOWNTO expected

	DB 5eh		; E = opcode for INC HL or DEC HL
	DB 0d5h

	DB 3eh,0AH 		; default type = INTEGER
	DB 0cdh
	DW  L5EE8		; parse expression

	DB 0d1h
	DB 0f1h
	DB 0d5h
	DB 0b8h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0cdh
	DW  L6E76
	DW L7572 		; start of reserved word: DO

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 0DH			; error 13: DO expected

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 0D1H			; POP DE

	DB 0d1h			; E = opcode: INC HL or DEC HL

	DB 0cdh
	DW  L6D63		; move 13, L7B57

	DB 0d5h			; E = opcode: INC HL or DEC HL
	DB 7bh
	DB 21h
	DW _L0666		; LIB, FOR xx:=start TO end
	DB 0feh, 23H			; opcode: INC HL ?
	DB 28h,(L54D5)-$-1

	; opcode: DEC HL
	DB 21h
	DW _L0676		; LIB, FOR xx:=start DOWNTO end

L54D5:	DB 0cdh
	DW  O_CALHL
	DB 0fdh,0e5h			; save current code address

	DB 0cdh
	DW  O_CODE
	DB 6
	DB 7AH			; LD A,D
	DB 0B3H			; OR E
	DB 0CAH,0,0		; JP Z,0000H
	DB 0D5H			; PUSH DE

	DB 0cdh
	DW  L661B
	DB 21h
	DW L7B95
	DB 034h

	DB 0cdh
	DW  L5385		; statement

	DB 21h
	DW L7B95
	DB 035h
	DB 0e1h			; address of 'LD A,D'

	DB 0d1h			; E = opcode: INC HL or DEC HL
	DB 0cdh
	DW  L6D49		; pop 13, L7B57

	DB 0e5h			; address of 'LD A,D'

	DB 02ah
	DW L7B58		; hl = lvalue of current id
	DB 3eh,2AH
	DB 0cdh
	DW  O_OPHL		; LD HL,( HL )

	DB 3ah
	DW L7B62
	DB 3dh			; size = 2 bytes ?
	DB 20h,(L550C)-$-1		; jump if size = 2, INTEGER

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 26H,0 		; LD H,0

L550C:	DB 7bh
	DB 0cdh
	DW  O_BYTE		; out: INC HL or DEC HL

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 0D1H			; POP DE
	DB 01BH			; DEC DE
	DB 0C3H			; opcode 'JP'

	DB 0e1h
	DB 0cdh
	DW  O_HL		; out: address of 'LD A,D'
	DB 23h
	DB 23h
	DB 23h
         DB 0c3h
	DW  L6C3F                   ; update address at HL with current address

L5521:	; case-statement ::=
	;   case expression of case-element { ; case-element } end
	; | case expression of case-element { ; case-element }
	;   otherwise statement { ; statement } end
	DB 3eh,0AH 		; A = default type = INTEGER
	DB 0cdh
	DW  L5EBB		; parse simple expression
	DB 32h
	DW L7B9C
	DB 0afh
	DB 32h
	DW L7B9B
	DB 0cdh
	DW  L6F88		; match('OF')
	DB 06h,0
	DB 0c5h
L5531:	DB 06h,1
L5533:	DB 0c5h
	DB 21h
	DW L7B9B
	DB 0cbh,07eh
	DB 28h,(L5549)-$-1

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 19H			; ADD HL,DE

	DB 0cbh,066h
	DB 28h,(L5549)-$-1

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 09H			; ADD HL,BC

L5549:	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 3ah
	DW L7B9C
	DB 0b8h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2EH			; error 46: constant and CASE selector type
				;	    does not match

	DB 0cdh
	DW  O_LDDE		; output: 'LD DE,value HL'
	DB 0e5h
	DB 0cdh
	DW  L6E76
	DW L7580 		; start of reserved word: ..
	DB 0e1h
	DB 20h,(L5582)-$-1
	DB 0e5h
	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 3ah
	DW L7B9C
	DB 0b8h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2EH			; error 46: constant and CASE seletector type
				;	    does not match

	DB 0d1h
	DB 0b7h
	DB 0EDH,052h
	DB 23h
	DB 0cdh
	DW  O_LDBC

	DB 0cdh
	DW  O_CODE
	DB 6
	DB 0B7H			; OR A
	DB 0EDH,52H		; SBC HL,DE
	DB 0B7H			; OR A
	DB 0EDH,42H		; SBC HL,BC

	DB 3eh,0DAH
	DB 18h,( L558B)-$-1

L5582:	DB 0cdh
	DW  O_CODE
	DB 3
	DB 0B7H			; OR A
	DB 0EDH,52H		; SBC HL,DE

	DB 3eh,0CAH
L558B:	DB 32h
	DW L7B9B
	DB 0cdh
	DW  L6F0B		; match(':'), if present
	DB 0c1h
	DB 28h,(L55A5)-$-1		; jump if ':' matched
	DB 3ah
	DW L7B9B
	DB 0cdh
	DW  O_BYTE
	DB 0fdh,0e5h
	DB 0cdh
	DW  O_HL
	DB 0cdh
	DW  L6F5E		; match(',')
	DB 04h
	DB 18h,( L5533)-$-1

L55A5:	DB 0fdh,0e5h
	DB 0d1h
	DB 13h
	DB 13h
	DB 13h
L55AB:	DB 05h
	DB 28h,(L55B4)-$-1
	DB 0e1h

         DB 0cdh
	DW  L6C42                 ; update address at HL with contents of DE

	DB 18h,( L55AB)-$-1
L55B4:	DB 3ah
	DW L7B9B
	DB 0cbh,09fh
	DB 0cdh
	DW  O_BYTE
	DB 0c1h
	DB 0fdh,0e5h
	DB 04h
	DB 0c5h
	DB 0cdh
	DW  O_HL
	DB 3ah
	DW L7B9B
	DB 0f5h
	DB 3ah
	DW L7B9C
	DB 0f5h

	DB 0cdh
	DW  L5385		; statement

	DB 0f1h
	DB 32h
	DW L7B9C
	DB 0f1h
	DB 32h
	DW L7B9B
	DB 0cdh
	DW  L6F0F		; match(';'), if present
	DB 1eh,1
	DB 28h,(L55DF)-$-1		; jump if ';' matched
	DB 1dh
L55DF:	DB 0d5h
	DB 0cdh
	DW  L6E76
	DW L7530 		; start of reserved word: END
	DB 0d1h
	DB 28h,(L561E)-$-1
	DB 0cdh
	DW  O_C3
	DB 0c1h
	DB 0e1h
	DB 0fdh,0e5h
	DB 0c5h
	DB 0d5h
	DB 0cdh
	DW  O_HL

         DB 0cdh
	DW  L6C3F                 ; update address at HL with current address

	DB 0cdh
	DW  L6E76
	DW L756E 		; start of reserved word: ELSE
	DB 0d1h
	DB 28h,(L560F)-$-1
	DB 1dh
	DB 0cah
	DW L5531
	DB 3ah
	DW L7B98
	DB 0b7h

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 0EH			; error 14: END expected

	DB 0cdh
	DW  L72E1		; no condition
	DB 29H			; error 41: Unknown identifier or syntax error

L560F:	DB 0cdh
	DW  L5385		; statement

	DB 0cdh
	DW  L6E76
	DW L7530 		; start of reserved word: END
	DB 28h,(L561E)-$-1

	DB 0cdh
	DW  L6F50		; match(';')
	DB 18h,( L560F)-$-1

L561E:	DB 0c1h
L561F:	DB 0e1h

         DB 0cdh
	DW  L6C3F                 ; update address at HL with current address

         DB 10h,( L561F)-$-1
	DB 0c9h

L5626:	DB 01h
	DW 100H		; label identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 28H			; error 40: Undefined label

	DB 3ah
	DW L7B94
	DB 0beh

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 48H			; error 72: Label not within current block

	DB 0ebh

L5639:	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 3ah
	DW L7B95
	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 0cdh
	DW  O_C3
	DB 0fdh,0e5h
	DB 0d1h
	DB 0cdh
	DW  L6D75		; add DE to id table
	DB 0c3h
	DW  O_HL

L564E:	DB 3ah
	DW L7BC9
	DB 0f5h
L5652:	DB 3ah
	DW L7BC6
	DB 21h
	DW L7BC9
	DB 0beh

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 61H			; error 97: Too many nested WITH's

	DB 0cdh
	DW  L677F		; parse VAR parameter
	DB 3ah
	DW L7B5C
	DB 0feh, 2			; record identifier ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 1DH			; error 29: Record variable expected

	DB 21h
	DW L7BC9
	DB 5eh
	DB 16h,0
	DB 034h
	DB 21h
	DW L7BCC
	DB 019h
	DB 3ah
	DW L7B5D
	DB 77h
	DB 02ah
	DW L7BCA
	DB 019h
	DB 019h

	DB 3eh,22H
	DB 0cdh
	DW  O_OPHL		; LD ( HL ),HL

	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L5652)-$-1		; jump if ',' matched

	DB 0cdh
	DW  L6E76
	DW L7572 		; start of reserved word: DO

L568C:	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 0DH			; error 13: DO expected

	DB 0cdh
	DW  L5385		; statement

	DB 0f1h
	DB 32h
	DW L7BC9
	DB 0c9h

L5698:	; statement inline
	DB 0cdh
	DW  L6F66		; match('(')

L569B:	DB 3eh,3EH
	DB 0cdh
	DW  L6F29		; match('>')
	DB 3eh,2			; 16 bits
	DB 28h,(L56AE)-$-1		; jump if matched

	DB 3eh,3CH
	DB 0cdh
	DW  L6F29		; match('<')
	DB 3eh,1			; 8 bits
	DB 28h,(L56AE)-$-1		; jump if matched

	DB 0afh

L56AE:	DB 32h
	DW L7BA6		; 0 = automatic
				; 1 = always 8 bits
				; 2 = always 16 bits
	DB 0afh
	DB 67h
	DB 6fh
	DB 47h

L56B5:	DB 0c5h
	DB 0e5h
	DB 0cdh
	DW  L6A0D		; parse a constant of any type
	DB 20h,(L56C5)-$-1		; jump if no constant parsed

	DB 78h
	DB 0feh, 0AH			; constant type = INTEGER ?
	DB 28h,(L5702)-$-1

	DB 0cdh
	DW  L72E1		; no condition
	DB 16H			; error 22: Integer constant expected

L56C5:	DB 21h
	DW L7BA6
	DB 7eh
	DB 0b7h
	DB 20h,(L56CE)-$-1
	DB 36h,2

L56CE:	DB 3eh,2AH
	DB 0cdh
	DW  L6F29		; match('*')
	DB 20h,(L56DA)-$-1		; jump if not matched

	DB 0fdh,0e5h			; IY = current position in code
	DB 0e1h
	DB 18h,( L5702)-$-1

L56DA:	DB 01h
	DW 400H		; variable identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list, pointer
				; HL = address of info
	DB 20h,(L56EA)-$-1

	DB 0cdh
	DW  L5276		; id info at 7B5C
	DB 02ah
	DW L7B58		; hl = lvalue of current id
	DB 18h,( L5702)-$-1

L56EA:	DB 01h
	DW 500H		; procedure identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
         DB 28h,(L56FC)-$-1

	DB 01h
	DW 600H		; function identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 4AH			; error 74: INLINE error

L56FC:	DB 2bh
	DB 2bh
	DB 56h
	DB 2bh
	DB 5eh
	DB 0ebh

L5702:	DB 0d1h
	DB 0c1h
	DB 05h
	DB 20h,(L570A)-$-1
	DB 0cdh
	DW  L6A30

L570A:	DB 019h
	DB 06h,0
	DB 3eh,2BH
	DB 0cdh
	DW  L6F29		; match('+')
	DB 28h,(L56B5)-$-1		; jump if matched

	DB 04h
	DB 3eh,2DH 		; match('-')
	DB 0cdh
	DW  L6F29		; jump if matched
	DB 28h,(L56B5)-$-1

	DB 3ah
	DW L7BA6
	DB 0feh, 1			; 8 bits ?
	DB 28h,(L5729)-$-1		; jump if 8 bits

	DB 30h,(L572F)-$-1		; jump if A = 2, output 16 bits value

	DB 24h
	DB 25h
	DB 20h,(L572F)-$-1		; jump if HL >= 256, output HL

L5729:	; output 8 bits value
	DB 7dh
	DB 0cdh
	DW  O_BYTE
	DB 18h,( L5732)-$-1

L572F:	; output 16 bits value
	DB 0cdh
	DW  O_HL

L5732:	DB 3eh,2FH
	DB 0cdh
	DW  L6F29		; match('/')
	DB 0cah
	DW L569B		; repeat while '/' matched

	DB 0c3h
	DW  L6F6E 		; match(')')

L573D:   ; procedure
         DB 2bh                     ; skip update flag

         DB 46h                  ; B = # of different types
	DB 2bh

         DB 56h                  ; address of procedure/function
	DB 2bh
	DB 5eh
	DB 2bh
         DB 0d5h                    ; save start address of procedure/function

         DB 56h                  ; DE = function type definition address
	DB 2bh
	DB 5eh
	DB 2bh
	DB 0d5h

         DB 2bh                     ; skip address of function result variable
	DB 2bh


         DB 56h                  ; DE = first 128 byte block number of
                                    ; function/procedure in overlay
                                    ;Ok$$$$, will become long
                                    ;        push long !!
	DB 2bh
	DB 5eh
	DB 2bh
         DB 0d5h                    ; push high-word

         DB 56h                  ; push low-word
         DB 2bh
         DB 5eh
         DB 2bh
         DB 0d5h


         DB 56h                  ; DE = length in blocks of 128 bytes of
                                    ; the largest overlay part
                                    ;Ok$$$$, will become length in bytes
	DB 2bh
	DB 5eh
	DB 2bh
	DB 0d5h

         DB 04h                      ; # different type = 0, no variables ?
	DB 05h
         DB 0cah
	DW L57D6                 ; jump if no variables

	DB 0cdh
	DW  L6F66		; match('(')

L575E:	DB 0c5h
	DB 46h
	DB 2bh
	DB 7eh
	DB 2bh
	DB 32h
	DW L7B57
	DB 56h
	DB 2bh
	DB 5eh
	DB 2bh
	DB 48h
L576B:	DB 0cbh,07eh
;!	pushf
	DB 2bh
;!	popf
	DB 28h,(L576B)-$-1
	DB 10h,( L576B)-$-1
	DB 41h
	DB 0e5h
	DB 0ebh
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)

L5778:	DB 0c5h
	DB 3ah
	DW L7B57
	DB 0b7h
	DB 20h,(L57A9)-$-1
	DB 3ah
	DW L7B5C
	DB 0feh, 3
	DB 38h,(L57A1)-$-1

	; A = default type
	DB 0cdh
	DW  L5E84		; parse a sub expression
	DB 0cdh
	DW  L5864		; make type casts

	DB 3ah
	DW L7B5C
	DB 0feh, 4
	DB 28h,(L57BD)-$-1

	DB 0feh, 0EH			; type = LONGINT ?
	DB 28h,(L57781)-$-1

	DB 0feh, 9
	DB 38h,(L57C0)-$-1

	DB 20h,(L57BD)-$-1		; jump to O_PSHHL if type = INTEGER,
				; BOOLEAN or CHAR

	; generate code to push rest of a REAL, HL is always pushed
	DB 3eh,0C5H
	DB 0cdh
	DW  O_BYTE		; out: 'PUSH BC'

L57781:	DB 3eh,0D5H
	DB 0cdh
	DW  O_BYTE		; out: 'PUSH DE'
	DB 18h,( L57BD)-$-1

L57A1:	DB 0cdh
	DW  L6D2A		; push 13, L7B57
	DB 0cdh
	DW  L6749
	DB 18h,( L57AF)-$-1

L57A9:	DB 0cdh
	DW  L6D2A		; push 13, L7B57
	DB 0cdh
	DW  L677F		; parse VAR parameter

L57AF:	DB 0cdh
	DW  L6D5D		; move 13, L7B64
	DB 3ah
	DW L7B69
	DB 0feh, 0
	DB 0c4h
	DW L58C5		; NonZero --> perform type checking
	DB 0cdh
	DW  L6D49		; pop 13, L7B57

L57BD:	DB 0cdh
	DW  O_PSHHL

L57C0:	DB 0c1h
	DB 05h
	DB 28h,(L57C9)-$-1
	DB 0cdh
	DW  L6F5E		; match(',')
	DB 18h,( L5778)-$-1

L57C9:	DB 0e1h
	DB 0c1h
	DB 05h
	DB 28h,(L57D3)-$-1
	DB 0cdh
	DW  L6F5E		; match(',')
	DB 18h,( L575E)-$-1

L57D3:	DB 0cdh
	DW  L6F6E		; match(')')


L57D6:
         DB 0c1h                     ; length of data to read from overlay
                                    ;Ok$$$$, must be in BC in bytes

         DB 0e1h                     ; first block of data where to read from
                                    ; in overlay
                                    ;Ok$$$$, must be a long
                                    ;       pop long !!
         DB 0d1h

         DB 78h                     ; length = 0 ?
         DB 0b1h
         DB 28h,(L57E3)-$-1                 ; jump if procedure/function is no overlay

         DB 78h
         DB 0a1h
         DB 3ch
         DB 20h,(L57E0)-$-1                ; jump if not -1

         DB 0cdh
	DW  O_CODE
         DB 2
         DB 16h,40H                 ; LD D,40H

         DB 18h,( L57E3)-$-1

L57E0:
         DB 0c5h

         DB 0ebh
         DB 0cdh
	DW  O_LDDE                ; high-word of position
         DB 0ebh
         DB 0cdh
	DW  O_LDHL                ; low-word of position

         DB 0e1h
         DB 0cdh
	DW  O_LDBC                ; length of data block to read from overlay

;         CALL O_LDHL
;         EX DE,HL
;         CALL O_LDDE                ; output: 'LD DE,value HL'


L57E3:
         DB 0d1h                     ; DE = function type definition address

         DB 0e1h                     ; HL = start address of procedure/function

	DB 3eh,0CDH
	DB 0c3h
	DW  O_OPHL		; CALL HL

L57EA:	DB 3ah
	DW L7B5C
	DB 0feh, 0			; 0 ?
	DB 28h,(L57F9)-$-1		; yes --> illegal assignment
	DB 0feh, 5			; < 5 ?
	DB 38h,(L57FD)-$-1		; yes --> correct assignment
	DB 0feh, 8			;>= 8 ?
	DB 30h,(L57FD)-$-1		; yes --> correct assignment

	; illegal assignment with:
	; 0, 5 (typed file), 6 (text) and 7 (untyped file)
L57F9:	DB 0cdh
	DW  L72E1		; no condition
	DB 36H			; error 54: Illegal assignment

L57FD:	DB 3ah
	DW L7BBD
	DB 0cbh,04fh
	DB 20h,(L5812)-$-1

	DB 0cbh,047h
	DB 28h,(L580A)-$-1		; jump if L7BBD = 0

	DB 3eh,0FFH
L580A:	DB 02ah
	DW L7BBE
	DB 22h
	DW L7B58		; new lvalue of id
	DB 18h,( L581A)-$-1

L5812:	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 0cdh
	DW  O_PSHHL
	DB 3eh,1

L581A:	DB 32h
	DW L7B57		; = 1	   if bit 1,(L7BBD) = '1'
				; = 255	   if bit 1,0,(L7BBD) = '0','1'
				; = (L7BBD) if bit 1,0,(L7BBD) = '0','0'
	DB 0cdh
	DW  L6F7E		; match(':=')
	DB 3ah
	DW L7B5C
	DB 0feh, 3			; >= 3 ?
	DB 0d2h
	DW L593A

	DB 0cdh
	DW  L6D2A		; push 13, L7B57

	DB 0cdh
	DW  L6749

	DB 0cdh
	DW  L6D43		; pop 13, L7B64

	DB 0cdh
	DW  L58C5		; perform type checking

	DB 3ah
	DW L7B64
	DB 3dh
	DB 28h,(L5852)-$-1
	DB 3ch
	DB 28h,(L5845)-$-1

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0EDH,05BH		; opcode: 'LD DE,()'

	DB 18h,( L584A)-$-1

L5845:	DB 0cdh
	DW  O_CODE
	DB 1
	DB 11H			; opcode: 'LD DE,'

L584A:	DB 02ah
	DW L7B65
	DB 0cdh
	DW  O_HL
	DB 18h,( L5857)-$-1

L5852:	DB 0cdh
	DW  O_CODE
	DB 1
	DB 0D1H			; POP DE

L5857:	DB 02ah
	DW L7B6F		; length of structured type
	DB 0cdh
	DW  O_LDBC

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0EDH,0B0H		; LDIR

	DB 0c9h

L5864:	; ---------------------------------------------------------
	; make necessary type casts
	; ---------------------------------------------------------
	; in:	(L7B5C) = type of lvalue
	;	B = type of rvalue
	DB 3ah
	DW L7B5C
	DB 0feh, 9			; lvalue type = REAL ?
	DB 20h,(L5877)-$-1

	; lvalue type = REAL
	DB 78h
	DB 0feh, 0AH			; type rvalue = INTEGER ?
	DB 20h,(L58641)-$-1

	; lvalue type = REAL, rvalue type = INTEGER
	DB 06h,9			; new rvalue type = REAL
	DB 21h
	DW _L1008		; LIB, convert integer HL to REAL HLDEBC
	DB 18h,( L589A)-$-1

L58641:	DB 0feh, 0EH			; type rvalue = LONGINT ?
	DB 20h,(L589D)-$-1

	; lvalue type = REAL, rvalue type = LONGINT
	DB 06h,9			; new rvalue type = REAL
	DB 21h
	DW _L_R		; LIB, convert LONGINT DE:HL to REAL HLDEBC
	DB 18h,( L589A)-$-1

L5877:	DB 0feh, 8			; lvalue type = STRING ?
	DB 20h,(L588C)-$-1		; jump if not

	; lvalue type = STRING
	DB 78h
	DB 0feh, 0CH			; rvalue type = CHAR ?
	DB 20h,(L589D)-$-1

	; lvalue type = STRING, rvalue type = CHAR
	DB 06h,8			; new rvalue type = CHAR

	DB 0cdh
	DW  O_CODE
	DB 4
	DB 65H			; LD H,L  = character data
	DB 2EH,01H		; LD L,1  = length
	DB 0E5H			; PUSH HL, push string on stack

	DB 18h,( L589D)-$-1

L588C:	DB 0feh, 0CH			; lvalue type = CHAR ?
	DB 20h,(L588C1)-$-1		; jump if not

	; lvalue type = CHAR
	DB 78h
	DB 0feh, 8			; STRING ?
	DB 20h,(L589D)-$-1

	; lvalue = CHAR, rvalue = STRING
	DB 06h,0CH 		; CHAR
	DB 21h
	DW _L0996		; LIB, convert STRING to CHAR, clear
	DB 18h,( L589A)-$-1

L588C1:	DB 0feh, 0EH			; lvalue type = LONGINT ?
	DB 20h,(L588C3)-$-1		; jump if not

	; lvalue type = LONGINT
	DB 78h
	DB 0feh, 0AH			; rvalue type = INTEGER ?
	DB 20h,(L588C2)-$-1		; jump if not

	; lvalue type = LONGINT, rvalue = INTEGER
	DB 06h,0EH 		; new rvalue type = LONGINT
	DB 0cdh
	DW  OP_L_I		; code to convert INTEGER to LONGINT with
				; sign extension
	DB 18h,( L589D)-$-1

L588C2:	DB 0feh, 9			; rvalue type = REAL ?
	DB 20h,(L589D)-$-1

	; lvalue type = LONGINT, rvalue type = REAL
	DB 06h,0EH 		; new rvalue type = LONGINT
	DB 21h
	DW _R_L		; LIB, convert REAL HLDEBC to LONGINT
	DB 18h,( L589A)-$-1

L588C3:	DB 0feh, 0AH			; lvalue type = INTEGER ?
	DB 20h,(L589D)-$-1		; jump if not

	; lvalue type = INTEGER
	DB 78h
	DB 0feh, 0EH			; rvalue type = LONGINT ?
	DB 20h,(L589D)-$-1		; jump if not

	DB 06h,0AH 		; new rvalue type = INTEGER
	DB 18h,( L589D)-$-1

L589A:	DB 0cdh
	DW  O_CALHL

L589D:	; all possible casts have been made now
	DB 3ah
	DW L7B5C
	DB 0b8h			; lvalue and expression have same type ?
	DB 20h,(L58C1)-$-1		; jump for Type mismatch

	DB 0feh, 3			; lvalue type = 3 ?
	DB 20h,(L58B1)-$-1

	DB 79h
	DB 0b7h
	DB 0c8h
	DB 02ah
	DW L7B5E
	DB 0beh
	DB 0c8h
	DB 18h,( L58C1)-$-1 		; jump for Type mismatch

L58B1:	DB 0feh, 4			; lvalue type = 4 ?
	DB 0c0h
	DB 02ah
	DW L7B8B
	DB 7ch
	DB 0b5h
	DB 0c8h
	DB 0edh,5bh
	DW L7B5E
	DB 0EDH,052h
	DB 0c8h

L58C1:	DB 0cdh
	DW  L72E1		; no condition
	DB 2CH			; error 44: Type mismatch



	; ----------------------------------------------------------
	; perform type checking
	; ----------------------------------------------------------
	; in:	(L7B5C) = current type
	;
L58C5:	DB 3ah
	DW L7B5C
	DB 0feh, 0			; lvalue type = 0 ?
	DB 28h,(L591B)-$-1		; jump, type mismatch

	DB 0eh,0BFH		; 10111111
	DB 0feh, 0AH			; lvalue type = INTEGER,BOOLEAN,CHAR
				;	       or LONGINT ?
	DB 30h,(L5906)-$-1

	DB 0eh,83H 		; 10000011
	DB 0feh, 8			; lvalue type = STRING ?
	DB 20h,(L58E3)-$-1

	; check if Var-parameter checking is ON for strings
	DB 3ah
	DW L7B9E		; compiler directives
	DB 0cbh,06fh			; 1 = Var-parameter Type Checking on
	DB 20h,(L5906)-$-1		; jump if on

	DB 0eh,80H 		; 10000000
				; when bit 0,1 are zero the length will
				; not be checked, checks only the type
	DB 18h,( L5906)-$-1

L58E3:	DB 0feh, 6			; lvalue type = TEXT,UNTYPED F.,STRING,REAL
	DB 30h,(L5906)-$-1

	DB 0eh,0B3H		; 10110011
	DB 0feh, 3
	DB 30h,(L5906)-$-1

	DB 0eh,0C3H		; 11000011
	DB 0feh, 2
	DB 30h,(L5906)-$-1

	DB 02ah
	DW L7B60
	DB 7ch
	DB 0b5h
	DB 0eh,0BFH		; 10111111
	DB 20h,(L5906)-$-1

	DB 02ah
	DW L7B6D
	DB 7eh
	DB 0feh, 0AH
	DB 20h,(L591B)-$-1

	DB 0eh,0B3H		; 10110011

L5906:	DB 21h
	DW L7B5C
	DB 11h
	DW L7B69
	DB 06h,8
L590E:	DB 0cbh,11h
	DB 30h,(L5916)-$-1		; jump if byte not to compare

	DB 1ah
	DB 0beh
	DB 20h,(L591B)-$-1		; jump if not equal, type mismatch

L5916:	DB 23h
	DB 13h
	DB 10h,( L590E)-$-1
	DB 0c9h

L591B:	DB 0cdh
	DW  L72E1		; no condition
	DB 2CH			; error 44: Type mismatch


L591F:	DB 11h
	DW -4
	DB 019h
	DB 56h
	DB 2bh
	DB 5eh
	DB 2bh
	DB 0d5h
	DB 56h
	DB 2bh
	DB 5eh
	DW 53edh,L7B58		; save lvalue of id
	DB 0e1h
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)
	DB 0afh
	DB 32h
	DW L7B57
	DB 0cdh
	DW  L6F7E		; match(':=')

	DB 3ah
	DW L7B5C		; A = default type

L593A:	DB 0cdh
	DW  L5E84		; parse a sub expression
	DB 0cdh
	DW  L5864		; make type casts
	DB 0c3h
	DW  L661B

L59E9:	; generate a CALL according to the type in L7B5C
	; in:	HL = address of table with three routine addresses
	;	1e word = typed file,	L7B5C = 5
	;	2e word = text file,	L7B5C = 6
	;	3e word = untyped file,	L7B5C = 7
	DB 3ah
	DW L7B5C
	DB 0d6h, 5
	DB 0cdh
	DW  TABLEINDEX2

;	 ADD A,A
;	 LD E,A
;	 LD D,0
;	 ADD HL,DE
;	 LD E,(HL)
;	 INC HL
;	 LD D,(HL)
;	 EX DE,HL

	DB 0c3h
	DW  O_CALHL

L5A0C:	; parse '(' and file parameter
	DB 0cdh
	DW  L6F66		; match('(')
	DB 0cdh
	DW  L5A17		; parse file parameter
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 15H			; error 21: File variable expected

L5A17:	; parses a file parameter
	; out:	NonZero and Carry, no name parsed
	;	NonZero and NonCarry, name parsed but it is not a file
	;			    parameter
	;	Zero and NonCarry, file parameter parsed
	;	A = type of file parameter
	DB 0cdh
	DW  L67B2		; parse var parameter
	DB 37h
	DB 0c0h			; return with NonZero and Carry

	DB 3ah
	DW L7B5C
	DB 0feh, 5
	DB 38h,(L5A2F)-$-1		; type < 5, not a file type
	DB 0feh, 8
	DB 30h,(L5A2F)-$-1		; type > 7, not a file type

	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 0afh			; return NonCarry and Zero
	DB 3ah
	DW L7B5C		; return type
	DB 0c9h

L5A2F:	DB 0afh			; no carry
	DB 3dh			; return with NonZero, A = 255
	DB 0c9h

L5CAD:	; parses a VAR string variable
	DB 0cdh
	DW  L677F		; parse VAR parameter
	DB 3ah
	DW L7B5C
	DB 0feh, 8			; string var ?
	DB 0c8h			; return if string var

	DB 0cdh
	DW  L72E1		; no condition
	DB 22H			; error 34: String variable expected

L5D76:	DB 0e5h
	DB 0cdh
	DW  O_PSHHL
	DB 0cdh
	DW  L6F5E		; match(',')
	DB 0cdh
	DW  L5E97		; parse integer expression
	DB 0e1h

L5960:	DB 0cdh
	DW  L6F6E		; match(')')
	DB 0c3h
	DW  O_CALHL

L5E84:	; parses a sub expression
	; in:	A = default type
	DB 0cdh
	DW  L6D2A		; push 13, L7B57
	DB 0cdh
	DW  L5EE8		; parse expression
	DB 0cdh
	DW  L6D49		; pop 13, L7B57
	DB 0c9h

L5E8E:	; parses an array index, ':=' and integer expression
	DB 0cdh
	DW  L65D5		; parse an array index
	DB 0cdh
	DW  L6F7E		; match(':=')
	DB 0cdh
	DW  O_PSHHL		; push index result

L5E97:	; parses an integer expression
	DB 3eh,0AH 		; default type = INTEGER
	DB 0cdh
	DW  L5EE8		; parse expression
	DB 78h
	DB 0feh, 00AH			; expression type = integer ?
	DB 0c8h			; yes, ok

	DB 0cdh
	DW  L72E1		; no condition
	DB 17H			; error 23: Integer expression expected

L5EA2:	; parses an integer, longint or real expression
	; in:	A = default expression
	DB 0cdh
	DW  L5EE8		; parse expression
	DB 78h
	DB 0feh, 00AH
	DB 0c8h			; return if type = INTEGER
	DB 0feh, 9
	DB 0c8h			; return if type = REAL
	DB 0feh, 00EH
	DB 0c8h			; return if type = LONGINT

	DB 0cdh
	DW  L72E1		; no condition
	DB 1AH			; error 26: Integer or real expression expected

L5EB0:	; parses a boolean expression
	DB 3eh,0BH 		; default boolean
	DB 0cdh
	DW  L5EE8		; parse expression
	DB 78h
	DB 0feh, 00BH
	DB 0c8h			; return if type = BOOLEAN

	DB 0cdh
	DW  L72E1		; no condition
	DB 14H			; error 20: Boolean expression expected

L5EBB:	; parses a simple expression
	DB 0cdh
	DW  L5EE8		; parse expression

L5EBE:	DB 78h
	DB 0feh, 00AH			; return if type = INTEGER, BOOLEAN or CHAR
				;	       or LONGINT
	DB 0d0h
	DB 0feh, 8

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 1FH			; error 31: Simple expression expected

	DB 06h,00CH
	DB 21h
	DW _L0996		; LIB, convert STRING to CHAR, clear
	DB 0c3h
	DW  O_CALHL

L5ED0:	; parse a string expression
	DB 3eh,8			; default type = STRING
	DB 0cdh
	DW  L5EE8		; parse expression
	DB 78h
	DB 0feh, 8
	DB 0c8h
	DB 0feh, 00CH

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 21H			; error 33: String expression expected

L5EDD:	; generate code to push CHAR in L as STRING with length = 1
	; out:	type = STRING, B = 8
	DB 06h,8

	DB 0cdh
	DW  O_CODE
	DB 4
	DB 65H			; LD H,L
	DB 2EH,01H		; LD L,1
	DB 0E5H			; PUSH HL

	DB 0c9h

DEF_TYPE:DB 0AH

SETDFT:	; set new default type
	; in:	A = type,
	; out:	A = type,
	; changes: F
	DB 0feh, 0FFH
	DB 28h,(SETDF1)-$-1
	DB 0feh, 0AH
	DB 28h,(SETDF1)-$-1
	DB 0feh, 0EH
	DB 28h,(SETDF1)-$-1
	DB 0feh, 09H
	DB 0c0h			; leave old value if not INTEGER or LONGINT

	DB 3eh,0FFH

SETDF1:	DB 32h
	DW DEF_TYPE
	DB 0c9h

L5EE8:	; parse a complete expression
	; SYNTAX: expression ::= simple-expression
	;		       { relational-operator simple-expression }

	DB 0cdh
	DW  SETDFT

	DB 21h
	DW BOOLOPER
	DB 034h 		; increase one level
				; 1 = the FIRST level

	DB 0cdh
	DW  L5F98		; simple-expression
				; B = type
	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

L5EEB:	; { relational-operator simple-expression }
	DB 0c5h
	DB 0cdh
	DW  L6E5A		; is '=' the next word
	DB 1			; 1 byte following
	DW L7625 		; list of reserved words:
				; =, <>, >=, <=, >, <, IN
	DB 0c1h
	DB 0c0h			; return if no relational-operator

	DB 7eh		; 0 = =, 1 = <>, 2 = >=, 3 = <=
				; 4 = >, 5 = <,  ffh = IN
	DB 3ch
	DB 28h,(L5F34)-$-1		; jump if 'IN'

	DB 3dh
	DB 0f5h			; save relational-operator
	DB 0c5h			; save type

	DB 0cdh
	DW  L6148		; generate code to push REAL, INTEGER,
				; BOOLEAN, CHAR, POINTER or LONGINT
				; on the stack

	DB 02ah
	DW L7B8B
	DB 0e5h
	DB 0cdh
	DW  L5F98		; simple-expression
				; B = type
	DB 0e1h
	DB 22h
	DW L7B8D
	DB 0d1h			; D = type of previous simple-expression
	DB 0cdh
	DW  L6160		; convert previous and current to same type

	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

	DB 0f1h			; restore relational-operator

	DB 087h			; * 2
	DB 087h			; * 4
	DB 087h			; * 8
	DB 087h			; * 16
	DB 5fh			; DE = 16 * A
	DB 16h,0
	DB 21h
	DW L5F68
	DB 019h		;+0  = =,+16 = <>,+32 = >=,+48 = <=
				;+64 = >,+80 = <
	DB 78h
	DB 0feh, 3			; operator type = SET ?
	DB 28h,(L5F28)-$-1		; jump if operator at SET

	DB 23h
	DB 23h
	DB 0feh, 9			; operator type = REAL ?
	DB 28h,(L5F28)-$-1		; jump if operator at REAL

	DB 23h
	DB 23h
	DB 0feh, 8			; operator type = STRING ?
	DB 28h,(L5F28)-$-1		; jump if operator at STRING

	DB 23h
	DB 23h
	DB 0feh, 0EH			; operator type = LONGINT ?
	DB 28h,(L5F28)-$-1		; jump if LONGINT

	DB 23h
	DB 23h
	DB 0feh, 0AH			; operator type = INTEGER ?
	DB 28h,(L5F28)-$-1		; jump if INTEGER

	DB 23h
	DB 23h
	DB 0feh, 0BH			; operator type = BOOLEAN ?
	DB 28h,(L5F28)-$-1		; jump if BOOLEAN

	DB 23h
	DB 23h
	; operator type = CHARACTER

L5F28:	DB 5eh
	DB 23h
	DB 56h
	DB 7ah
	DB 0b3h

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator
	DB 0ebh
	DB 18h,( L5F62)-$-1

L5F34:	; operator = 'IN'
	DB 78h
	DB 0feh, 00AH
	DB 30h,(L5F47)-$-1		; jump if type = INTEGER, BOOLEAN or CHAR

	DB 0feh, 8			; type = STRING ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 21h
	DW _L0996		; LIB, convert STRING to CHAR, clear
	DB 0cdh
	DW  O_CALHL
	DB 06h,00CH		; result type = CHAR

L5F47:	DB 0c5h

	; generate code to save the value to search in the 'SET'
	DB 0cdh
	DW  O_PSHHL

	DB 0cdh
	DW  L5F98		; simple-expression
				; B = type
	DB 0d1h
	DB 78h
	DB 0feh, 3			; type = SET ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 79h
	DB 0b7h
	DB 28h,(L5F5F)-$-1
	DB 0bah

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

L5F5F:	DB 21h
	DW _L134F		; LIB, clear

L5F62:	DB 0cdh
	DW  O_CALHL
	DB 06h,00BH		; return type = boolean
	DB 0c9h

L5F68:	DW _L12E1		; LIB, clear, =  SET
	DW _L0688		; LIB, clear, =  REAL
	DW _L068D		; LIB, clear, =  STRING
	DW _L_EQ 		; LIB,	     =  LONGINT
	DW _L067F		; LIB, clear, =  INTEGER
	DW _L067F		; LIB, clear, =  BOOLEAN
	DW _L067F		; LIB, clear, =  CHAR
	DW 0

	DW _L12DD		; LIB, clear, <> SET
	DW _L069B		; LIB, clear, <> REAL
	DW _L06A0		; LIB, clear, <> STRING
	DW _L_NEQ		; LIB,	     <> LONGINT
	DW _L0692		; LIB, clear, <> INTEGER
	DW _L0692		; LIB, clear, <> BOOLEAN
	DW _L0692		; LIB, clear, <> CHAR
	DW 0

	DW _L1300		; LIB, clear, >= SET
	DW _L06AE		; LIB, clear, >= REAL
	DW _L06B3		; LIB, clear, >= STRING
	DW _L_GTE		; LIB,	     >= LONGINT
	DW _L06A5		; LIB, clear, >= INTEGER
	DW _L06A5		; LIB, clear, >= BOOLEAN
	DW _L06A5		; LIB, clear, >= CHAR
	DW 0

	DW _L12FC		; LIB, clear, <= SET
	DW _L06C2		; LIB, clear, <= REAL
	DW _L06C7		; LIB, clear, <= STRING
	DW _L_LSE		; LIB,	     <= LONGINT
	DW _L06B8		; LIB, clear, <= INTEGER
	DW _L06B8		; LIB, clear, <= BOOLEAN
	DW _L06B8		; LIB, clear, <= CHAR
	DW 0

	DW 0			; ----	   , >  SET
	DW _L06D6		; LIB, clear, >  REAL
	DW _L06DB		; LIB, clear, >  STRING
	DW _L_GT 		; LIB,	     >  LONGINT
	DW _L06CC		; LIB, clear, >  INTEGER
	DW _L06CC		; LIB, clear, >  BOOLEAN
	DW _L06CC		; LIB, clear, >  CHAR
	DW 0

	DW 0			; ----	   , <  SET
	DW _L06E9		; LIB, clear, <  REAL
	DW _L06EE		; LIB, clear, <  STRING
	DW _L_LS 		; LIB,	     <  LONGINT
	DW _L06E0		; LIB, clear, <  INTEGER
	DW _L06E0		; LIB, clear, <  BOOLEAN
	DW _L06E0		; LIB, clear, <  CHAR
	DW 0

L5F98:	; SYNTAX: simple-expression ::= term { adding-operator term }
	; out:	B = type

	DB 0cdh
	DW  L6054		; term
				; B = type

	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

L5F9B:	; { adding-operator term }
	DB 0c5h			; save type
	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following
	DW L7619 		; start of reserved word list:
				; +, -, OR, XOR
	DB 0c1h			; restore type
	DB 0c0h			; return if no adding-operator

	; pointer types do not match with an adding-operator
	DB 78h
	DB 0feh, 4			; type = POINTER ?
	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 7eh		; 0 = +,  1 = -,
				; 2 = OR  3 = XOR
	DB 0f5h			; save operator

	DB 0c5h			; save type of previous term
	DB 0cdh
	DW  L6148		; generate code to push REAL, INTEGER,
				; BOOLEAN, CHAR, POINTER or LONGINT
				; on the stack

	DB 0cdh
	DW  L6054		; term
				; B = type of term

	DB 0d1h			; D = type of previous term

	DB 0f1h			; A = operator
				; 0 = +,  1 = -,
				; 2 = OR  3 = XOR
	DB 0f5h			; save operator
	DB 0b7h
	DB 20h,(L5FC9)-$-1		; jump if operator = 1, 2 or 3


	DB 78h
	DB 0feh, 00CH			; current type = CHAR ?
	DB 20h,(L5FC9)-$-1		; jump if not

	; generate code to concatenate two strings

	; generate code to convert HL (CHAR) in to a string
	DB 0cdh
	DW  O_CODE
	DB 4
	DB 65H			; LD H,L
	DB 2EH,01H		; LD L,1
	DB 0E5H			; PUSH HL

	DB 06h,8			; current type = STRING

L5FC9:	DB 0cdh
	DW  L6160		; convert previous and current to same type

	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

	DB 0f1h			; A = operator
	DB 0feh, 2
	DB 30h,(L601B)-$-1		; jump if 'OR' or 'XOR'

	; operator = '+' or '-'
	DB 0f5h
	DB 78h
	DB 21h
	DW _L1318		; LIB, SET + SET
	DB 11h
	DW _L1326		; LIB, SET - SET
	DB 0feh, 3			; type = SET ?
	DB 28h,(L6006)-$-1		; jump if type = SET

	DB 21h
	DW _L09E9		; LIB, REAL + REAL
	DB 11h
	DW _L09F2		; LIB, REAL - REAL
	DB 0feh, 9			; type = REAL ?
	DB 28h,(L6006)-$-1		; jump if type = REAL

	DB 21h
	DW _L_ADD
	DB 11h
	DW _L_SUB
	DB 0feh, 00EH			; type = LONGINT ?
	DB 28h,(L6006)-$-1		; jump if type = LONGINT

	DB 0feh, 8			; type = STRING ?
	DB 28h,(L6010)-$-1		; jump if type = STRING

	DB 0feh, 00AH			; type = INTEGER ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 0f1h
	DB 3dh			; type = '-'
	DB 28h,(L5FFC)-$-1		; jump if type = '-'

	; generate code to add two INTEGERS
	DB 0cdh
	DW  O_CODE
	DB 1
	DB 19H			; ADD HL,DE

	DB 0c3h
	DW  L5F9B 		; repeat { adding-operator term }

L5FFC:	; generate code to subtract two INTEGERS
	DB 0cdh
	DW  O_CODE
	DB 4
	DB 0EBH			; EX DE,HL
	DB 0B7H			; OR A
	DB 0EDH,52H		; SBC HL,DE

	DB 0c3h
	DW  L5F9B

L6006:	DB 0f1h
	DB 3dh
	DB 20h,(L600B)-$-1		; jump if operator = '+'

	DB 0ebh
	; HL = address of '-' routine

L600B:	DB 0cdh
	DW  O_CALHL
	DB 0c3h
	DW  L5F9B

L6010:	DB 0f1h
	DB 3dh			; operator = '-' ?

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 21h
	DW _L083D		; LIB, STRING + STRING
	DB 18h,( L600B)-$-1

L601B:	; generate code for 'OR' and 'XOR' operators
	DB 78h
	DB 20h,(L6039)-$-1		; jump if operator = 'XOR'

	; operator = 'OR'

	DB 0feh, 00BH			; type = BOOLEAN ?
	DB 28h,(L602F)-$-1		; jump if boolean

	DB 21h
	DW _L_OR
	DB 0feh, 00EH			; type = LONGINT ?
	DB 28h,(L600B)-$-1

	DB 0feh, 00AH			; type = INTEGER ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 7CH			; LD A,H
	DB 0B2H			; OR D
	DB 67H			; LD H,A

L602F:	DB 0cdh
	DW  O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 0B3H			; OR E
	DB 6FH			; LD L,A

	DB 0c3h
	DW  L5F9B

L6039:	; operator = 'XOR'

	DB 0feh, 00BH			; type = BOOLEAN ?
	DB 28h,(L604A)-$-1		; jump if type = BOOLEAN

	DB 21h
	DW _L_XOR
	DB 0feh, 00EH			; type = LONGINT ?
	DB 28h,(L600B)-$-1		; jump if type = LONGINT

	DB 0feh, 00AH			; type = INTEGER ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 7CH			; LD A,H
	DB 0AAH			; XOR D
	DB 67H			; LD H,A

L604A:	DB 0cdh
	DW  O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 0ABH			; XOR E
	DB 6FH			; LD L,A

	DB 0c3h
	DW  L5F9B

L6054:	; SYNTAX: term ::= complemented factor |
	;		 { multiplying-operator complemented-factor }
	; out:	B = type

	DB 0cdh
	DW  L60E9		; complemented factor
				; B = type

	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

L6057:	DB 0c5h
	DB 0cdh
	DW  L6E5A
	DB 1			; 1 byte following
	DW L7600 		; start of reserved word list:
				; *, /, AND, DIV, MOD, SHL, SHR
	DB 0c1h
	DB 0c0h			; return if no multiplying operator

	; pointer types do not match with an multiplying-operator
	DB 78h
	DB 0feh, 4			; type = POINTER ?
	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 7eh		; 0 = *,   1 = /, 2 = AND,
				; 3 = DIV, 4 = MOD,
				; 5 = SHL, 6 = SHR
	DB 0f5h
	DB 0c5h
	DB 0cdh
	DW  L6148		; generate code to push REAL, INTEGER,
				; BOOLEAN, CHAR, POINTER or LONGINT
				; on the stack

	DB 0cdh
	DW  L60E9		; complemented factor
				; B = type

	DB 0d1h
	DB 0f1h			; A = multiplying-operator
	DB 0f5h
	DB 3dh
	DB 20h,(L6083)-$-1		; jump if operator 0, 2, 3, 4, 5 or 6

	DB 78h
	DB 0feh, 00AH			; current type = INTEGER ?
	DB 20h,(L6083)-$-1

	DB 21h
	DW _L1008		; LIB, convert integer HL to REAL HLDEBC
	DB 0cdh
	DW  O_CALHL
	DB 06h,9			; current type = REAL

L6083:	DB 0cdh
	DW  L6160		; convert previous and current to same type

	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

	DB 0f1h
	DB 5fh			; E = multiplying-operator

	DB 78h
	DB 1ch
	DB 1dh
	DB 20h,(L60A9)-$-1

	; multiplying-operator = 0, *
	DB 21h
	DW _L1333		; LIB, multiply two SETS
	DB 0feh, 3
	DB 28h,(L60A4)-$-1

	DB 21h
	DW _L06F5		; LIB, multiply two INTEGERS
	DB 0feh, 00AH
	DB 28h,(L60A4)-$-1

	DB 21h
	DW _L_MUL		; LIB, multiply two LONGS
	DB 0feh, 00EH			; LONG ?
	DB 28h,(L60A4)-$-1

	DB 21h
	DW _L09FA		; LIB, multiply two REALS

L609E:	DB 0feh, 9			; REAL ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	   operator

L60A4:	DB 0cdh
	DW  O_CALHL
	DB 0c3h
	DW  L6057 		; repeat {
				;    multiplying-operator
				;    complemented-factor
				; }

L60A9:	DB 21h
	DW _L09FF		; LIB, divide two REALS
	DB 1dh			; multiplying-operator = '/' = 1
	DB 28h,(L609E)-$-1

	DB 1dh
	DB 20h,(L60CC)-$-1		; jump if >= 2, DIV, MOD, SHL, SHR

	; multiplying-operator = 'AND'
	DB 21h
	DW _L_AND		; LIB, LONGINT AND LONGINT
	DB 0feh, 00EH			; type = LONGINT ?
	DB 28h,(L60A4)-$-1		; jump if type = LONGINT ?

	DB 0feh, 00BH			; type = BOOLEAN ?
	DB 28h,(L60C3)-$-1		; jump if BOOLEAN

	DB 0feh, 00AH			; type = INTEGER ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 7CH			; LD A,H
	DB 0A2H			; AND D
	DB 67H			; LD H,A

L60C3:	DB 0cdh
	DW  O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 0A3H			; AND E
	DB 6FH			; LD L,A

	DB 0c3h
	DW  L6057

L60CC:	DB 0feh, 00AH			; operator type = INTEGER ?
	DB 20h,(L60CC1)-$-1		; jump if not

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 21h
	DW _L070F		; LIB, X div Y, INTEGER
	DB 1dh
	DB 28h,(L60A4)-$-1
	DB 21h
	DW _L0745		; LIB, X mod Y, INTEGER
	DB 1dh
	DB 28h,(L60A4)-$-1
	DB 21h
	DW _L074E		; LIB, X shl Y, INTEGER
	DB 1dh
	DB 28h,(L60A4)-$-1
	DB 21h
	DW _L0756		; LIB, X shr Y, INTEGER
	DB 18h,( L60A4)-$-1

L60CC1:	DB 0feh, 00EH			; operator type = LONGINT ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	DB 21h
	DW _L_DIV		; LIB, X div Y, LONGINT
	DB 1dh
	DB 28h,(L60A4)-$-1
	DB 21h
	DW _L_MOD		; LIB, X mod Y, LONGINT
	DB 1dh
	DB 28h,(L60A4)-$-1
	DB 21h
	DW _L_SHL		; LIB, X shl Y, INTEGER
	DB 1dh
	DB 28h,(L60A4)-$-1
	DB 21h
	DW _L_SHR		; LIB, X shr Y, LONGINT
	DB 18h,( L60A4)-$-1

	DB 0cdh
	DW  L72E1		; no condition
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

L60E9:	; SYNTAX: complemented factor ::= signed-factor | not signed-factor
	; out:	B = type
	DB 0cdh
	DW  L6E76
	DW L7579 		; start of reserved word: NOT
	DB 20h,(L6112)-$-1		; jump if no NOT, signed-factor

	; NOT found in the text

	DB 0cdh
	DW  L6112		; signed-factor
				; out: B = type
	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

	DB 0feh, 00AH			; type = INTEGER ?
	DB 28h,(L6107)-$-1		; jump if type = INTEGER

	DB 0feh, 00EH			; type = LONGINT ?
	DB 28h,(L61071)-$-1		; jump if type = LONGINT

	DB 0feh, 00BH			; type = BOOLEAN;

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	; generate code for a NOT <BOOLEAN>
	DB 0cdh
	DW  O_CODE
	DB 4
	DB 7DH			; LD A,L
	DB 0EEH,01H		; XOR 1
	DB 6FH			; LD L,A

	DB 0c9h

L6107:	; generate code for a NOT <integer>
	DB 0cdh
	DW  O_CODE
	DB 6
	DB 7DH			; LD A,L
	DB 2FH			; CPL
	DB 6FH			; LD L,A
	DB 7CH			; LD A,H
	DB 2FH			; CPL
	DB 67H			; LD H,A

	DB 0c9h

L61071:	; generate code for a NOT <longint>
	DB 21h
	DW _L_NOT
	DB 0c3h
	DW  O_CALHL

L6112:	; SYNTAX: signed-factor ::= factor | sign factor
	; out:	B = type
	DB 3ah
	DW L7BA1		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign
	DB 0f5h			; save old sign

	DB 0cdh
	DW  L6A39		; get current sign, E = 0 if no sign
	DB 7bh
	DB 32h
	DW L7BA1		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

	DB 0cdh
	DW  L621D		; factor
				; B = type

	DB 78h
	DB 0cdh
	DW  SETDFT		; set new default type

	DB 3ah
	DW L7BA1
	DB 5fh			; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

	DB 0cdh
	DW  L6A4A		; sign = '-' ?
	DB 28h,(L6143)-$-1		; jump if no minus sign

	DB 78h
	DB 0feh, 00AH			; type = INTEGER ?
	DB 20h,(L61121)-$-1		; jump if not

	; generate code for integer negation
;	 PUSH HL
;	 LD HL,_L0783
;	 CALL O_CALHL		; a call is shorter, but slower !!
;	 POP HL
	DB 0cdh
	DW  O_CODE		; out: code for negation of HL
	DB 7
	DB 7DH			; LD A,L
	DB 2FH			; CPL
	DB 6FH			; LD L,A
	DB 7CH			; LD A,H
	DB 2FH			; CPL
	DB 67H			; LD H,A
	DB 23H			; INC HL

	DB 18h,( L6143)-$-1

L61121:	DB 0feh, 00EH			; type = LONGINT ?
	DB 20h,(L613B)-$-1		; jump if not

	; generate code for LONGINT negation
	DB 0e5h
	DB 21h
	DW _L_NEG
	DB 0cdh
	DW  O_CALHL
	DB 0e1h
	DB 18h,( L6143)-$-1

L613B:	; generate code for REAL negation
	DB 0cdh
	DW  O_CODE
	DB 4
	DB 78H			; LD A,B
	DB 0EEH,80H		; XOR 80H
	DB 47H			; LD B,A

L6143:	DB 0f1h			; restore old sign
	DB 32h
	DW L7BA1		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign
	DB 0c9h

L6148:	; generates code to PUSH a REAL, INTEGER, BOOLEAN, CHAR,
	;			POINTER or LONGINT on the stack
	; on the stack
	; in:	B = type
	; out:	-
	; changes: AF
	DB 78h
	DB 0feh, 00EH
	DB 28h,(O_PSHLONG)-$-1

	DB 0feh, 00AH
	DB 30h,(L615D)-$-1		; jump if type = INTEGER, BOOLEAN or CHAR

	DB 0feh, 4
	DB 28h,(L615D)-$-1		; jump if type = POINTER

	DB 0feh, 8
	DB 0c8h			; return if type = STRING
				; strings are already on the stack

	DB 0feh, 3
	DB 0c8h			; return if type = SET
				; sets are already on the stack

	DB 3eh,0C5H
	DB 0cdh
	DW  O_BYTE		; output: PUSH BC

O_PSHLONG:
	DB 3eh,0D5H
	DB 0cdh
	DW  O_BYTE		; output: PUSH DE

L615D:	DB 0c3h
	DW  O_PSHHL		; output: PUSH HL

L6160:	; in:	D = previous type, data is already pushed onto the stack
	;	E = type of SET, if previous type = SET
	;	B = current type,  data is in registers
	;	C = type of SET, if current type = SET

;	 LD A,D
;	 CP B
;	 JR Z,OP_TYPES_EQ

	DB 0d5h
	DB 7ah
	DB 087h
	DB 087h
	DB 087h
	DB 087h
	DB 0b0h			; A = ppppcccc, combination of operands

	DB 21h
	DW OP_CNVTAB
OP_CNV_SRCH:
	DB 034h 		; end of table ?
	DB 035h
	DB 0cah
	DW OP_CNV_END		; jump to quit search

	DB 0beh			; operand combination found ?
	DB 28h,(OP_CNV_FOUND)-$-1

	DB 23h
	DB 23h
	DB 23h
	DB 0c3h
	DW  OP_CNV_SRCH

OP_CNV_FOUND:
	DB 23h
	DB 7eh
	DB 23h
	DB 66h
	DB 6fh

	DB 0ebh
	DB 21h
	DW L61D3
	DB 0e3h		; push return address L61D3 and
				; restore pushed DE
	DB 0ebh

	DB 0e9h

OP_R_R:	DB 0cdh
	DW  O_CODE
	DB 4
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC       ; HLDEBC = previous
	DB 0c9h

OP_R_I:	DB 0cdh
	DW  O_CODE
	DB 7
	DB 0CDH			; CALL _L1008  ; convert HL to REAL HLDEBC
	DW _L1008
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC       ; HLDEBC = previous

	DB 06h,9			; previous type = REAL
	DB 0c9h

OP_R_L:	DB 0cdh
	DW  O_CODE
	DB 7
	DB 0CDH			; CALL _L_R    ; convert DE:HL to REAL
	DW _L_R
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC       ; HLDEBC = previous

	DB 06h,9			; previous type = REAL
	DB 0c9h

OP_I_R:	DB 0cdh
	DW  O_CODE
	DB 5
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL       ; HL = value of previous
	DB 0CDH			; CALL _L1008  ; convert HL to REAL
	DW _L1008

	DB 16h,9			; previous type = REAL
	DB 0c9h

OP_L_R:	DB 0cdh
	DW  O_CODE
	DB 6
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL       ; DE:HL = value of previous
	DB 0D1H			; POP DE       ;
	DB 0CDH			; CALL _L_R    ; convert DE:HL to REAL
	DW _L_R

	DB 16h,9			; previous type = REAL
	DB 0c9h

OP_SCALAR:
OP_B_B:
OP_C_C:
OP_I_I:	; DE = previous, HL = current
	DB 3eh,0D1H		; opcode: 'POP DE'
	DB 0c3h
	DW  O_BYTE

OP_S_C:	; generate code to convert CHAR to STRING (on the stack)

	DB 0cdh
	DW  O_CODE
	DB 4
	DB 65H			; LD H,L
	DB 2EH,01H		; LD L,1
	DB 0E5H			; PUSH HL

	DB 06h,8			; current type = STRING
	DB 0c9h

OP_C_S:	DB 21h
	DW _L09A2		; LIB, clear
	DB 0cdh
	DW  O_CALHL		; convert the previous type to a STRING

	DB 16h,8			; previous type = STRING
	DB 0c9h

OP_L_I:  ; previous LONGINT DE:HL on stack
	; current  INTEGER in HL --> LONGINT DE:HL
	DB 0cdh
	DW  O_CODE
	DB 8
	DB 11H,0,0		;	LD DE,0
	DB 0CBH,7CH		;	BIT 7,H
	DB 28H,1 		;	JR Z,continue
	DB 1BH			;	DEC DE
				; continue:

	DB 06h,0EH 		; current type = LONGINT
	DB 0c9h

OP_I_L:	; previous INTEGER on stack --> LONGINT DE:HL on stack
	; current  LONGINT in DE:HL
	DB 0cdh
	DW  O_CODE
	DB 13
	DB 0D9H			;	EXX
	DB 0E1H			;	POP HL
	DB 11H,0,0		;	LD DE,0
	DB 0CBH,7CH		;	BIT 7,H
	DB 28H,1 		;	JR Z,continue
	DB 1BH			;	DEC DE
				; continue:

	DB 0D5H			;	PUSH DE
	DB 0E5H			;	PUSH HL
	DB 0D9H			;	EXX

	DB 16h,0EH 		; previous type = LONGINT
	DB 0c9h

OP_CNV_END:
	DB 0d1h

	DB 7ah
	DB 0feh, 10H
	DB 0d4h
	DW OP_SCALAR 	; SCALAR type ?

L61D3:	DB 78h
	DB 0bah			; types are equal ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

L61D31:	; types equal
	DB 0feh, 3			; type = SET ?
	DB 20h,(L61EA)-$-1		; jump if not

	; type = SET
	DB 7bh
	DB 0b9h
				; SET types compatible ?
	DB 0c8h			; yes, return

	DB 0b7h			; previous SET = empty SET ?
	DB 0c8h			; return C = type of current SET

	DB 79h
	DB 4bh			; C = previous SET type
	DB 0b7h			; current SET = empty SET ?
	DB 0c8h			; return C = type of previous SET

	DB 0cdh
	DW  L72E1		; no condition
	DB 2CH			; error 44: Type mismatch

L61EA:	DB 0feh, 4			; type = POINTER ?
	DB 0c0h			; return if not

	DB 02ah
	DW L7B8B
	DB 7ch
	DB 0b5h
	DB 0c8h

	DB 0edh,5bh
	DW L7B8D
	DB 7ah
	DB 0b3h
	DB 0c8h
	DB 0EDH,052h
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 2CH			; error 44: Type mismatch

OP_CNVTAB:
	DB 0AAH			; integer   integer
	DW OP_I_I

	DB 0BBH			; boolean   boolean
	DW OP_B_B

	DB 0CCH			; character character
	DW OP_C_C

         DB 044H                    ; 33e, pointer   pointer
         DW OP_I_I                  ; 33e

	DB 99H			; real	   real
	DW OP_R_R

	DB 9AH			; real	   integer
	DW OP_R_I

	DB 9EH			; real	   long
	DW OP_R_L

	DB 0A9H			; integer   real
	DW OP_I_R

	DB 0E9H			; long	   real
	DW OP_L_R

	DB 8CH			; string    character
	DW OP_S_C

	DB 0C8H			; character string
	DW OP_C_S

	DB 0EAH			; long	   integer
	DW OP_L_I

	DB 0AEH			; integer   long
	DW OP_I_L

	DB 0			; end of table

L6201:	DB 11h
	DW L5EEB		; { relational-operator simple-expression }
	DB 0d5h
	DB 11h
	DW L5F9B		; { adding-operator term }
	DB 0d5h
	DB 11h
	DW L6057		; { multiplying-operator complemented-factor }
	DB 0d5h
	DB 18h,( L622D)-$-1 		; after parsing of an unsigned-constant

L620F:	DB 11h
	DW L5EEB		; { relational-operator simple-expression }
	DB 0d5h
	DB 11h
	DW L5F9B		; { adding-operator term }
	DB 0d5h
	DB 11h
	DW L6057		; { multiplying-operator complemented-factor }
	DB 0d5h
	DB 18h,( L6276)-$-1

L621D:	; SYNTAX: factor ::= variable | unsigned-constant | (expression) |
	;		   function-designator | set
	; in:	E = sign (0 = no sign, 255 = minus, 1 = plus)
	; out:	B = type
	DB 0cdh
	DW  L6A5C		; unsigned-constant
				; parse constant or constant identifier
	DB 20h,(L6257)-$-1		; jump if no constant parsed

	; constant parsed
	DB 3ah
	DW L7BA1
	DB 5fh			; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

	DB 0cdh
	DW  L6A1F		; negate REAL or INTEGER constant if there
				; is a '-' sign

	DB 0afh
	DB 32h
	DW L7BA1		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

L622D:	; continue just parsing an unsigned-constant
	DB 78h
	DB 0feh, 9
	DB 20h,(L6249)-$-1		; type = real ?, no skip

	; generate code for real constant:
	; 'LD HL,'
	; 'LD DE,'
	; 'LD BC,'
	DB 0d9h
	DB 0c5h			; push real on compiler stack
	DB 0d5h
	DB 0e5h
	DB 01h
	DW 331H		; B = 3 times, C = 21H + 10H
L6239:	DB 79h
	DB 0d6h, 010H
	DB 4fh
	DB 0cdh
	DW  O_BYTE		; output opcode 'LD HL,' or
				;	       'LD DE,' or
				;	       'LD BC,'
	DB 0e1h			; get 16 bits value
	DB 0cdh
	DW  O_HL
	DB 10h,( L6239)-$-1
	DB 06h,9			; return type = real
	DB 0c9h

L6249:	DB 0feh, 8			; type = STRING ?
	DB 0c2h
	DW L62491		; jump if not

	DB 21h
	DW _L054D		; LIB, clear
	DB 0cdh
	DW  O_CALHL
	DB 0c3h
	DW  L6B5E 		; output length (C) and data at L7A57

L62491:	DB 0feh, 0EH			; type = LONGINT ?
	DB 0c2h
	DW O_LDHL		; jump if not, assume INTEGER, CHAR, BOOL

	; generate code for LONGINT constant
	DB 0d9h
	DB 0cdh
	DW  O_LDHL
	DB 0ebh
	DB 0cdh
	DW  O_LDDE
	DB 0ebh
	DB 06h,0EH 		; return type = LONGINT
	DB 0c9h

L6257:	DB 01h
	DW 600H		; function identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
	DB 20h,(L6271)-$-1		; jump if no function identifier

	; function identifer
	DB 0cdh
	DW  L573D
	DB 0ebh
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)
	DB 02ah
	DW L7B5E		; HL = address of functions type definition
	DB 22h
	DW L7B8B		; save type definition
	DB 3ah
	DW L7B5C
	DB 47h			; B = result type of function
	DB 0c3h
	DW  SETDFT		; set new default type

L6271:	DB 0cdh
	DW  L67B2
	DB 20h,(L62D2)-$-1

L6276:	DB 3ah
	DW L7B5C
	DB 0feh, 8
	DB 30h,(L6285)-$-1
	DB 0feh, 3
	DB 28h,(L6285)-$-1
	DB 0feh, 4
	DB 20h,(L629D)-$-1

L6285:	DB 0cdh
	DW  L66DA
	DB 02ah
	DW L7B5E
	DB 22h
	DW L7B8B
	DB 3ah
	DW L7B5C
	DB 47h
	DB 0feh, 3			; type = SET ?
	DB 0c0h			; return if not SET

	; type = SET
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)
	DB 3ah
	DW L7B5C
	DB 4fh
	DB 0c9h

L629D:	DB 0feh, 1

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 02ah
	DW L7B5E
	DB 7eh
	DB 0feh, 00CH

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	DB 02ah
	DW L7B60
	DB 7eh
	DB 0feh, 00AH

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	DB 02ah
	DW L7B62		; HL = length
	DB 7ch			; length >= 256 ?
	DB 0b7h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	DB 65h			; H = length, operand
	DB 2eh,6			; L = opcode 'LD B,'
	DB 0cdh
	DW  O_HL

	DB 21h
	DW _L0638		; LIB, clear
	DB 0cdh
	DW  O_CALHL

	DB 06h,8			; result type = STRING
	DB 0c9h

L62D2:	DB 0cdh
	DW  L6EE0		; match('[') or match('(.')
	DB 20h,(L631C)-$-1		; jump if not matched

	DB 21h
	DW _L0581		; LIB, push new empty SET on stack
	DB 0cdh
	DW  O_CALHL
	DB 0cdh
	DW  L6EF7		; match(']') or match('.)')
	DB 01h
	DW 300H		; C = 0, no first time yet
				; B = 3, type = SET
	DB 0c8h			; return if matched

L62E4:	DB 0c5h
	DB 3eh,0AH 		; A = default type = INTEGER
	DB 0cdh
	DW  L5EBB		; parse simple expression
	DB 78h
	DB 0c1h
	DB 0ch			; already filled yet ?
	DB 0dh
	DB 20h,(L62EF)-$-1		; jump if already filled

	DB 4fh

L62EF:	DB 0b9h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0c5h

	DB 0cdh
	DW  L6E76
	DW L7580 		; start of reserved word: ..

	DB 21h
	DW _L0591		; LIB, done
	DB 20h,(L6310)-$-1		; jump if no '..' found

	DB 0cdh
	DW  O_PSHHL

	DB 3eh,0AH 		; A = default type = INTEGER
	DB 0cdh
	DW  L5EBB		; parse simple expression
	DB 78h
	DB 0c1h
	DB 0c5h
	DB 0b9h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 21h
	DW _L059B		; LIB, done

L6310:	DB 0cdh
	DW  O_CALHL
	DB 0c1h
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 28h,(L62E4)-$-1		; jump if ',' matched

	DB 0c3h
	DW  L6F38 		; match(']')

L631C:	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 20h,(L6327)-$-1		; jump if '(' not matched

	DB 0cdh
	DW  L5EE8		; parse expression
	DB 0c3h
	DW  L6F6E 		; match(')')

L6327:	DB 0cdh
	DW  L6E5A
	DB 2			; 2 bytes following
	DW L77B1 		; start of reserved word list:
				; standard library functions
				; CHR .. BIOS, 47
	DB 20h,(L6335)-$-1
	DB 5eh
	DB 23h
	DB 56h
	DB 0ebh
	DB 0afh
	DB 0e9h

L6335:	DB 0cdh
	DW  L6E76
	DW L757C 		; start of reserved word: NIL
	DB 20h,(L6345)-$-1		; jump if NIL not parsed

	; generate code for the NIL value
	DB 21h
	DW 0000
	DB 0cdh
	DW  O_LDHL

	DB 21h
	DW 0000
	DB 22h
	DW L7B8B
	DB 06h,4			; type = pointer
	DB 0c9h

L6345:	DB 01h
	DW 300H		; type identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list, types
				; HL = address of info

;	 CALL Print_ABC

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax error

	DB 56h
	DB 2bh
	DB 5eh
	DB 1ah
	DB 0feh, 00AH

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 1EH			; error 30: Simple type expected

	DB 0f5h
	; A = default type
	DB 0cdh
	DW  L65EF
	DB 0f1h
	DB 47h
	DB 0c9h

L6540:	DB 0cdh
	DW  L6F6E		; match(')')

	DB 0cdh
	DW  O_CALHL

	DB 0f1h			; pop flag
	DB 06h,00AH		; set result type = INTEGER
	DB 0b7h
	DB 0c0h			; return if called as PROCEDURE

	; code to convert A in HL to return as function result
	DB 0cdh
	DW  O_CODE
	DB 3
	DB 6FH			; LD L,A
	DB 26H,00H		; LD H,0

	DB 0c9h

L65D5:	; parses an array index
	DB 0cdh
	DW  L6F30		; match('[')
	DB 0cdh
	DW  L5E97		; parse integer expression
	DB 0c3h
	DW  L6F38 		; match(']')

L65DE:	; parses a '(' integer expr. ')'
	DB 0cdh
	DW  L6F66		; match('(')
	DB 0cdh
	DW  L5E97		; parse integer expression
L65E4:	DB 0c3h
	DW  L6F6E 		; match(')')

L65E7:	DB 0f5h
	DB 0cdh
	DW  L6F66		; match('(')
	DB 0f1h
	DB 0cdh
	DW  L5EA2		; parse integer, longint or real expression
	DB 0c3h
	DW  L6F6E 		; match(')')

PARSE_O_IL_C:
	DB 0f5h
	DB 0cdh
	DW  L6F66		; match('(')
	DB 0f1h
	DB 0cdh
	DW  L5EA2		; parse integer, longint or real expression

	DB 0feh, 0EH			; type = LONGINT ?
	DB 0cah
	DW L6F6E		; match(')') if type = LONGINT

	DB 0feh, 0AH

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 0c3h
	DW  L6F6E 		; match(')')

L65EF:	DB 0f5h
	DB 0cdh
	DW  L6F66		; match('(')
	DB 0f1h
	DB 0cdh
	DW  L5EBB		; parse simple expression
	DB 18h,( L65E4)-$-1 		; match(')')

L65F7:	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 28h,(L6608)-$-1		; jump if '(' matched
	DB 21h
	DW _OUTPUT		; LIB
	DB 0cdh
	DW  O_LDHL

	DB 3eh,6			; type = text
	DB 32h
	DW L7B5C
	DB 0c9h

L6608:	DB 0cdh
	DW  L5A17		; parse a file parameter

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 15H			; error 21: File variable expected

	DB 0f5h
	DB 0cdh
	DW  L6F6E		; match(')')
	DB 0f1h
	DB 0c9h

L661B:	; generate code to store a SET, STRING, REAL, POINTER, INTEGER,
	; BOOLEAN, CHAR, LONGINT
	;
	; in:	(L7B57) = 0, store direct
	;	(L7B57) = 1, store at pushed address
	;	(L7B57) = 2, store at indirect address
	DB 3ah
	DW L7B57
	DB 4fh

	DB 02ah
	DW L7B58		; HL = lvalue of id
	DB 3ah
	DW L7B5C
	DB 0feh, 3			; type = SET ?
	DB 20h,(L6634)-$-1		; jump if not

	; type is SET

	; generate 'LD BC,offset * 256 + length'
	DB 0cdh
	DW  L6734

	DB 21h
	DW _L0623		; LIB, save SET at pushed HL
	DB 11h
	DW _L0612		; LIB, save SET at HL
	DB 18h,( L6648)-$-1

L6634:	DB 0feh, 8			; type = STRING ?
	DB 20h,(L665E)-$-1		; jump if not

	; type is STRING
	DB 3ah
	DW L7B62
	DB 3dh
	DB 67h
	DB 2eh,6
	DB 0cdh
	DW  O_HL		; output: 'LD B,max length of string'

	DB 21h
	DW _L0601		; LIB, save string at pushed HL
	DB 11h
	DW _L05E2		; LIB, save string at HL

L6648:	DB 0dh
	DB 28h,(L665B)-$-1		; jump if C = 1, used pushed version

	DB 0ebh 		; use call with destination directly in HL

L664C:	DB 3eh,021H		; LD HL,
	DB 0ch
	DB 28h,(L6653)-$-1		; jump if C = 0

	; C = 2
	DB 3eh,02AH		; LD HL,()

L6653:	DB 0e5h
	DB 02ah
	DW L7B58		; HL = lvalue of id
	DB 0cdh
	DW  O_OPHL
	DB 0e1h

L665B:	DB 0c3h
	DW  O_CALHL

L665E:	DB 0feh, 9			; type = REAL ?
	DB 20h,(L6672)-$-1		; jump if not

	; type is REAL

	; CODE: HLDEBC = current REAL
	DB 0cdh
	DW  O_CODE
	DB 1
	DB 0D9H			; opcode: EXX

	DB 21h
	DW _L05D1		; LIB, PUTFLT, save HLDEBC' at HL
	DB 0dh
	DB 20h,(L664C)-$-1		; jump if C = 0 or C = 2

	; C = 1, destination address is pushed at stack
	DB 0cdh
	DW  O_POPHL
	DB 0c3h
	DW  O_CALHL		; generate call PUTFLT

L6672:	DB 0feh, 0EH			; type = LONGINT ?
	DB 28h,(ST_LONG)-$-1		; generate code to store a LONGINT

	DB 0feh, 4			; type = POINTER ?
	DB 28h,(L669D)-$-1		; jump if POINTER

	DB 3ah
	DW L7B9E		; compiler directives
	DB 0cbh,04fh			; 1 = Index Range Checking on
	DB 28h,(L669D)-$-1		; jump if off

	DB 02ah
	DW L7B5E		; start address of variable
	DB 0edh,5bh
	DW L7B60
	DB 13h
	DB 0b7h
	DB 0EDH,052h
;!	pushf
	DB 019h
;!	popf
	DB 28h,(L669D)-$-1		; no checking if base = 0
	DB 1bh
	DB 0cdh
	DW  O_LDDE		; output: LD DE,base=HL
	DB 0ebh
	DB 0b7h
	DB 0EDH,052h
	DB 23h
	DB 0cdh
	DW  O_LDBC		; output: LD BC,length
	DB 21h
	DW _L0656		; LIB, clear
	DB 0cdh
	DW  O_CALHL		; output call for range checking

L669D:	DB 0dh
	DB 20h,(L66B7)-$-1		; jump if C = 0 or C = 2

	; C = 1, use pushed version
	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0EBH			; EX DE,HL
	DB 0E1H			; POP HL 	; HL = destination address

L66A6:	DB 0cdh
	DW  O_CODE
	DB 1
	DB 73H			; LD (HL),E

	DB 3ah
	DW L7B62
	DB 3dh
	DB 0c8h

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 23H			; INC HL
	DB 72H			; LD (HL),D

	DB 0c9h

L66B7:	DB 02ah
	DW L7B58		; HL = lvalue of id
	DB 0ch
	DB 20h,(L66CF)-$-1

	; C = 0, store direct
	; generates code to save a byte size expression or an integer size
	; expression
	DB 3ah
	DW L7B62		; A = low byte of length of lvalue
	DB 3dh			; expression is word or byte?

	DB 3eh,22H 		; assume: opcode 'LD (),HL'
	DB 20h,(L66CC)-$-1

	; expression is byte
	DB 0cdh
	DW  O_CODE
	DB 1
	DB 7DH			; LD A,L

	DB 3eh,32H 		; opcode 'LD (),A'

L66CC:	DB 0c3h
	DW  O_OPHL		; out: LD (LVALUE),A or LD (LVALUE),HL

L66CF:	; C = 2, store indirect
	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0EBH			; EX DE,HL
	DB 2AH			; opcode: 'LD HL,()'

	DB 0cdh
	DW  O_HL		; output destination address
	DB 18h,( L66A6)-$-1

ST_LONG: DB 0dh
	DB 20h,(ST_LONG02)-$-1		; jump if C = 0 or C = 2

	; C = 1, use pushed version
	DB 0cdh
	DW  O_CODE
	DB 3
	DB 4DH			; LD C,L
	DB 44H			; LD B,H
	DB 0E1H			; POP HL 	; HL = destination address

ST_LONG_HL:
	DB 0cdh
	DW  O_CODE
	DB 7
	DB 71H			; LD (HL),C	; store low-word
	DB 23H			; INC HL
	DB 70H			; LD (HL),B
	DB 23H			; INC HL
	DB 73H			; LD (HL),E	; store high-word
	DB 23H			; INC HL
	DB 72H			; LD (HL),D

	DB 0c9h

ST_LONG02:
	DB 02ah
	DW L7B58		; HL = lvalue of id
	DB 0ch
	DB 20h,(ST_LONG_INDIRECT)-$-1	; jump if C = 2

	; C = 0
	DB 3eh,22H
	DB 0cdh
	DW  O_OPHL		; LD (lvalue),HL

	DB 23h
	DB 23h
	DB 3eh,0EDH
	DB 0cdh
	DW  O_BYTE
	DB 3eh,53H
	DB 0c3h
	DW  O_OPHL		; LD (lvalue+2),DE

ST_LONG_INDIRECT:
	; C = 2, store indirect
	DB 0cdh
	DW  O_CODE
	DB 3
	DB 4DH			; LD C,L
	DB 44H			; LD B,H
	DB 2AH			; opcode: 'LD HL,()'

	DB 0cdh
	DW  O_HL		; output loading of destination address
	DB 18h,( ST_LONG_HL)-$-1

L66DA:	; generate code to load a REAL, STRING, SET, INTEGER, BOOLEAN,
	; CHAR or LONGINT
	DB 3ah
	DW L7B5C
	DB 0feh, 00AH
	DB 30h,(L6701)-$-1		; jump if INTEGER, BOOLEAN, CHAR or LONGINT

	DB 0feh, 4
	DB 28h,(L6701)-$-1		; jump if pointer

	DB 0f5h
	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 0f1h

	DB 21h
	DW _L052C		; LIB, GETFLT, clear
	DB 0feh, 9
	DB 28h,(L66FE)-$-1		; jump if REAL

	DB 21h
	DW _L053A		; LIB, clear
	DB 0feh, 8
	DB 28h,(L66FE)-$-1		; jump if STRING

	; generate 'LD BC,offset * 256 + length'
	DB 0cdh
	DW  L6734
	DB 21h
	DW _L055D		; LIB, push a set on to a stack

L66FE:	DB 0c3h
	DW  O_CALHL

L6701:	DB 3ah
	DW L7BBD
	DB 0b7h			; indexed or VAR ?
	DB 20h,(L671B)-$-1

	; normal addressing of variable
	DB 3eh,02AH
	DB 02ah
	DW L7BBE
	DB 0cdh
	DW  O_OPHL		; LD HL,( HL )

	DB 3ah
	DW L7B5C
	DB 0feh, 00EH			; type = LONGINT ?
	DB 20h,(L67011)-$-1		; jump if not

	; output code to load high-word of longint
	DB 3eh,0EDH		; opcode: LD DE,()
	DB 0cdh
	DW  O_BYTE
	DB 3eh,5BH
	DB 23h
	DB 23h
	DB 0c3h
	DW  O_OPHL		; LD DE,( L7BBE+2 )

L67011:	DB 3ah
	DW L7B62
	DB 3dh			; size = 1 ?
	DB 0c0h			; return if size > 1

L6714:	DB 0cdh
	DW  O_CODE
	DB 2
	DB 26H,00H		; LD H,0

	DB 0c9h

L671B:	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 3ah
	DW L7B62
	DB 0feh, 4			; size = 4 ?
	DB 28h,(O_LDLONG)-$-1		; output load indirect long

	DB 3dh			; size = 1 ?
	DB 20h,(L672B)-$-1		; jump if size > 1

	; size = 1
	DB 0cdh
	DW  O_CODE
	DB 1
	DB 6EH			; LD L,(HL)

	DB 18h,( L6714)-$-1 		; LD H,0

O_LDLONG:DB 0cdh
	DW  O_CODE
	DB 9
	DB 5EH			; LD E,(HL)	; DE = low-word
	DB 23H			; INC HL
	DB 56H			; LD D,(HL)
	DB 23H			; INC HL
	DB 7EH			; LD A,(HL)
	DB 23H			; INC HL
	DB 66H			; LD H,(HL)	; HL = high-word
	DB 6FH			; LD L,A
	DB 0EBH			; EX DE,HL	; complete LONGINT DE:HL

	DB 0c9h

L672B:	DB 0cdh
	DW  O_CODE
	DB 4
	DB 5EH			; LD E,(HL)
	DB 23H			; INC HL
	DB 56H			; LD D,(HL)
	DB 0EBH			; EX DE,HL

	DB 0c9h

L6734:	; generate 'LD BC,offset * 256 + length'
	DB 02ah
	DW L7B5E		; HL = address of type definition
	DB 0cdh
	DW  L5271		; 8 bytes from HL (down) to 7B69 (up)

	DB 02ah
	DW L7B62		; L = lenght of SET in bytes
	DB 3ah
	DW L7B6B		; A = low byte of lower bound
	DB 1fh
	DB 1fh
	DB 1fh
	DB 0e6h, 01FH
	DB 67h			; H = byte offset in SET

	DB 0c3h
	DW  O_LDBC		; B = offset, C = length

L6749:	DB 0cdh
	DW  L6A0D		; parse a constant of any type
	DB 20h,(L677F)-$-1		; jump to parse var parameter

	DB 78h
	DB 0feh, 8			; type = STRING ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 3CH			; error 60: Constants are not allowed here

	DB 2eh,018H		; opcode: JR
	DB 61h			; H = length of STRING constant
	DB 0cdh
	DW  O_HL		; jump over constant 'JR length'

	DW 22fdh,L7B58		; save address of STRING constant
	DB 3eh,1
	DB 32h
	DW L7B5C
	DB 21h
	DW L74E2		; definition of a char
	DB 22h
	DW L7B5E
	DB 21h
	DW 0000
	DB 22h
	DW L7B60
	DB 69h
	DB 22h
	DW L7B62		; size of constant
	DB 0cdh
	DW  L6B62
	DB 3eh,021H		; opcode: LD HL,
	DB 02ah
	DW L7B58		; HL = address of STRING constant
	DB 0c3h
	DW  O_OPHL		; LD HL, HL

;Print_ABC:
;	 PUSH AF
;	 LD A,13
;	 CALL L03C9
;	 LD A,10
;	 CALL L03C9
;	 LD A,'A'
;	 CALL L03C9
;	 LD A,'B'
;	 CALL L03C9
;	 LD A,'C'
;	 CALL L03C9
;	 LD A,13
;	 CALL L03C9
;	 LD A,10
;	 CALL L03C9
;	 POP AF
;	 RET

L677F:	; parses a var parameter
	; out:	A = type of parsed var parameter
	DB 0cdh
	DW  L6787
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 29H			; error 41: Unknown identifier or syntax error

L6787:	DB 0cdh
	DW  L67B2
	DB 0c0h

L678B:	; bit 0,1 of (L7BBD)
	; 00 = LD HL, value in L7BBE
	; 01 = LD HL,(value in L7BBE)
	; 10 = LD DE, value in L7BBE
	;      ADD HL,DE
	; 11 = no output
	; out:

	DB 3ah
	DW L7BBD
	DB 02ah
	DW L7BBE		; HL = address or normal value
	DB 0cbh,04fh
	DB 20h,(L67A2)-$-1
	DB 0cbh,047h
	DB 3eh,021H		; LD HL,
	DB 28h,(L679D)-$-1
	DB 3eh,02AH		; LD HL,()

L679D:	DB 0cdh
	DW  O_OPHL
	DB 0afh			; return carry = 0, A = 0
	DB 0c9h

L67A2:	DB 0cbh,047h
	DB 20h,(L67B0)-$-1		; jump if no output, return carry=0, A = 0

	DB 3eh,011H		; LD DE,
	DB 0cdh
	DW  O_OPHL

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 19H			; ADD HL,DE

L67B0:	DB 0afh			; return carry = 0, A = 0
	DB 0c9h

L67B2:	DB 0cdh
	DW  L680C
	DB 28h,(L67D9)-$-1

	DB 01h
	DW 400H		; variable identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
	DB 20h,(L67ED)-$-1		; jump if no variable identifier

	; variable identifier found
	DB 0cdh
	DW  L5276		; id info at 7B5C
	DB 3ah
	DW L7B57
	DB 0b7h			; 0?, 0 = no VAR, 1 = VAR
	DB 3eh,021H		; opcode 'ld hl,'
	DB 06h,0
	DB 28h,(L67CF)-$-1		; jump if no VAR

	DB 3eh,02AH		; opcode 'ld hl,()'
	DB 04h			; B = 1

L67CF:	DB 21h
	DW L7BBD
	DB 70h		; B = 0: 'LD HL,'
				; B = 1: 'LD HL,()'

	DB 02ah
	DW L7B58		; HL = lvalue of id
	DB 22h
	DW L7BBE		; current address of variable

L67D9:	DB 0cdh
	DW  L683A
	DB 28h,(L67D9)-$-1

	DB 0cdh
	DW  L6931		; '.' variablename ?
	DB 28h,(L67D9)-$-1		; yes, repeat for next

	DB 0cdh
	DW  L6974		; variablename '^' ?
	DB 28h,(L67D9)-$-1		; yes, repeat for next

	DB 0cdh
	DW  L699F
	DB 0afh
	DB 0c9h

L67ED:	DB 0cdh
	DW  L6E76		; MEM is following ?
	DW L78FA 		; start of reserved word: MEM
	DB 0c0h			; quit if not

	DB 0cdh
	DW  L65D5		; parses an array index

	DB 3eh,00AH
	DB 32h
	DW L7B5C		; type = byte / integer
	DB 21h
	DW 1
	DB 22h
	DW L7B62		; size = 2
	DB 2dh
	DB 22h
	DW L7B5E		; = 0	  , min value
	DB 2dh
	DB 22h
	DW L7B60		; = 0FFFFH , max value
	DB 0c3h
	DW  L6903

L680C:	DB 3ah
	DW L7BC9
	DB 47h

L6810:	DB 05h
	DB 0f8h			; quit if < 0
	DB 0c5h
	DB 58h
	DB 16h,0
	DB 21h
	DW L7BCC
	DB 019h
	DB 7eh
	DB 4fh
	DB 06h,4			; variable identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
	DB 0c1h
	DB 20h,(L6810)-$-1

	DB 0e5h
	DB 78h
	DB 087h
	DB 5fh
	DB 16h,0
	DB 02ah
	DW L7BCA
	DB 019h
	DB 22h
	DW L7BBE
	DB 21h
	DW L7BBD
	DB 36h,1
	DB 0e1h
	DB 0c3h
	DW  L6948

L683A:	DB 3ah
	DW L7B5C
	DB 0feh, 1
	DB 0c0h

	DB 0cdh
	DW  L6EE0		; match('[') or match('(.')
	DB 0c0h			; quit if no '[' or '(.' matched

	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output

L6847:	DB 0cdh
	DW  O_PSHHL

	DB 3ah
	DW L7B5C		; A = default type
	DB 0cdh
	DW  L5E84		; parse a sub expression

	DB 02ah
	DW L7B60
	DB 0cdh
	DW  L5271		; 8 bytes from HL (down) to 7B69 (up)
	DB 3ah
	DW L7B69
	DB 0b8h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	DB 02ah
	DW L7B6B
	DB 7ch
	DB 0b7h
	DB 20h,(L6874)-$-1
	DB 7dh
	DB 0feh, 4
	DB 30h,(L6888)-$-1

L6867:	DB 0b7h
	DB 28h,(L6893)-$-1
	DB 0f5h

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 2BH			; DEC HL

	DB 0f1h
	DB 3dh
	DB 18h,( L6867)-$-1

L6874:	DB 3ch
	DB 20h,(L6888)-$-1
	DB 7dh
	DB 0feh, 0FDH
	DB 38h,(L6888)-$-1

L687C:	DB 0f5h

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 23H			; INC HL

	DB 0f1h
	DB 3ch
	DB 20h,(L687C)-$-1
	DB 18h,( L6893)-$-1

L6888:	DB 0cdh
	DW  L6A30
	DB 0cdh
	DW  O_LDDE		; output: 'LD DE,value HL'

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 19H			; ADD HL,DE

L6893:	DB 3ah
	DW L7B9E		; compiler directives
	DB 0cbh,04fh			; 1 = Index Range Checking on
	DB 28h,(L68AE)-$-1		; jump if off

	DB 02ah
	DW L7B6D
	DB 0edh,5bh
	DW L7B6B
	DB 0b7h
	DB 0EDH,052h
	DB 23h
	DB 0cdh
	DW  O_LDDE		; output: 'LD DE,value HL'
	DB 21h
	DW _L064C		; LIB
	DB 0cdh
	DW  O_CALHL

L68AE:	DB 02ah
	DW L7B5E
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)

	DB 02ah
	DW L7B62		; HL = variable size
	DB 7ch
	DB 0b7h
	DB 20h,(L68D8)-$-1		; jump if size >= 256

	DB 7dh
	DB 3dh			; size = 1 ?
	DB 28h,(L68ED)-$-1		; jump if size = 1

	DB 3dh			; size = 2 ?
	DB 20h,(L68AE1)-$-1		; jump if not

	; size = 2
	DB 0cdh
	DW  O_CODE
	DB 1
	DB 29H			; ADD HL,HL

	DB 18h,( L68ED)-$-1 		; add base

L68AE1:	DB 0feh, 2			; size = 4 ?, already 2 subtracted
	DB 20h,(L68C9)-$-1

	; size = 4
	DB 0cdh
	DW  O_CODE
	DB 2
	DB 29H			; ADD HL,HL
	DB 29H			; ADD HL,HL

	DB 18h,( L68ED)-$-1 		; add base

L68C9:	DB 0feh, 4			; size = 6 ?, already 2 subtracted
	DB 20h,(L68D8)-$-1

	; generate code for HL * 6, size = 6
	DB 0cdh
	DW  O_CODE
	DB 5
	DB 29H			; ADD HL,HL   , * 2
	DB 5DH			; LD E,L
	DB 54H			; LD D,H
	DB 29H			; ADD HL,HL   , * 4
	DB 19H			; ADD HL,DE   , * 2 + * 4

	DB 18h,( L68ED)-$-1 		; add base

L68D8:	DB 3ah
	DW L7B9E		; compiler directives
	DB 0cbh,067h			; 1 = Array Optimization on
	DB 20h,(L68EA)-$-1		; jump if on

	DB 0cdh
	DW  O_LDDE		; output: 'LD DE,value HL'
	DB 21h
	DW _L06F5		; LIB
	DB 0cdh
	DW  O_CALHL
	DB 18h,( L68ED)-$-1

L68EA:	DB 0cdh
	DW  L690A

L68ED:	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0D1H			; POP DE
	DB 19H			; ADD HL,DE

	DB 3ah
	DW L7B5C
	DB 0feh, 1
	DB 20h,(L6900)-$-1
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 0cah
	DW L6847		; jump if ',' matched
L6900:	DB 0cdh
	DW  L6F38		; match(']')

L6903:	DB 3eh,3
	DB 32h
	DW L7BBD
	DB 0afh
	DB 0c9h

L690A:	DB 06h,1

L690C:	DB 7ch
	DB 0b7h
	DB 20h,(L6914)-$-1		; HL non-zero

	DB 7dh
	DB 3dh
	DB 28h,(L6927)-$-1

L6914:	DB 0cbh,045h			; bit 0 = '0' ?
	DB 28h,(L691C)-$-1		; jump if '0', generate 'ADD HL,HL'

	; save current value to be added later
	DB 0cdh
	DW  O_PSHHL
	DB 04h

L691C:	DB 0cdh
	DW  O_CODE
	DB 1
	DB 29H			; ADD HL,HL

	DB 0cbh,3ch			; HL = HL / 2
	DB 0cbh,1dh
	DB 18h,( L690C)-$-1

L6927:	DB 05h
	DB 0c8h

	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0D1H			; POP DE
	DB 19H			; ADD HL,DE

	DB 18h,( L6927)-$-1

L6931:	DB 3ah
	DW L7B5C
	DB 0feh, 2			; record type ?
	DB 0c0h			; return if not

	DB 0cdh
	DW  L6F17		; match('.'), if present
	DB 0c0h			; return if '.' not matched

	DB 3ah
	DW L7B5D
	DB 4fh			; level within record
	DB 06h,4			; variable identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax error

L6948:	DB 0cdh
	DW  L5276		; id info at 7B5C
	DB 02ah
	DW L7B58		; HL = lvalue of id or offset of base of id
	DB 7ch
	DB 0b5h
	DB 0c8h			; quit if lvalue of id == 0
				; can only be 0 if it is an offset which
				; is zero (first variable in a record),
				; it generates no code

	DB 21h
	DW L7BBD
	DB 0cbh,046h
	DB 28h,(L6967)-$-1		; jump if LD HL, value in L7BBE
				;      or LD DE, value in L7BBE
				;	 ADD HL,DE

	DB 0e5h
	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 0e1h
	DB 36h,2
	DB 02ah
	DW L7B58		; HL = lvalue of id
	DB 22h
	DW L7BBE		; set new current address of variable

	DB 0afh			; return Zero
	DB 0c9h

L6967:	DB 02ah
	DW L7BBE
	DB 0edh,5bh
	DW L7B58		; HL = offset to field id
	DB 019h
	DB 22h
	DW L7BBE		; set new current address of variable

	DB 0afh			; return Zero
	DB 0c9h

L6974:	; variablename '^'
	DB 3ah
	DW L7B5C
	DB 0feh, 4			; type = POINTER ?
	DB 0c0h			; return if not a pointer

	DB 0cdh
	DW  L6F27		; match('^')
	DB 0c0h

	DB 21h
	DW L7BBD
	DB 7eh
	DB 0b7h
	DB 20h,(L6988)-$-1

	; direct value --> make indirect
	DB 034h 		; 01 = LD HL,(value in L7BBE)
	DB 18h,( L6997)-$-1

L6988:	DB 0e5h
	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 0e1h
	DB 36h,3		; no output next time

	DB 0cdh
	DW  O_CODE
	DB 4
	DB 5EH			; LD E,(HL)
	DB 23H			; INC HL
	DB 56H			; LD D,(HL)
	DB 0EBH			; EX DE,HL

L6997:	DB 02ah
	DW L7B5E
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)

	DB 0afh			; return Zero
	DB 0c9h

L699F:	DB 3ah
	DW L7B5C
	DB 0feh, 8			; type = STRING ?
	DB 0c0h

	DB 0cdh
	DW  L6EE0		; match('[') or match('(.')
	DB 0c0h			; quit if no '[' or '(.' matched

	DB 0cdh
	DW  L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	DB 0cdh
	DW  O_PSHHL
	DB 02ah
	DW L7B62
	DB 0e5h
	DB 0cdh
	DW  L5E97		; parse integer expression
	DB 0e1h
	DB 3ah
	DW L7B9E		; compiler directives
	DB 0cbh,04fh			; 1 = Index Range Checking on
	DB 28h,(L69C7)-$-1		; jump if off
	DB 0cdh
	DW  O_LDDE		; output: 'LD DE,value HL'
	DB 21h
	DW _L064C		; LIB
	DB 0cdh
	DW  O_CALHL

L69C7:	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0D1H			; POP DE
	DB 19H			; ADD HL,DE

	DB 0cdh
	DW  L6F38		; match(']')
	DB 3eh,00CH
	DB 32h
	DW L7B5C
	DB 21h
	DW 0001
	DB 22h
	DW L7B62
	DB 2bh
	DB 22h
	DW L7B5E
	DB 2dh
	DB 22h
	DW L7B60
	DB 3eh,3
	DB 32h
	DW L7BBD
	DB 0afh
	DB 0c9h

L69EA:	DB 0cdh
	DW  L6A0D		; parse a constant of any type
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 29H			; error 41: Unknown identifier or syntax error

L69F2:	; parses an integer constant
	DB 3eh,0AH
	DB 32h
	DW DEF_TYPE		; default type = INTEGER
	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 78h
	DB 0feh, 00AH
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 16H			; error 22: Integer constant expected

L69FD:	; parses a string constant
	; out:	B = 8, character constant will be casted to string constant
	;	C = length of string constant
	DB 0cdh
	DW  L69EA		; parse a constant of any type
				; error if not found
	DB 78h
	DB 0feh, 8			; STRING constant ?
	DB 0c8h			; return if STRING constant

	DB 0feh, 00CH			; CHAR constant ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 20H			; error 32: String constant expected

	DB 06h,8			; return as STRING constant
	DB 0c9h

L6A0D:	; parses a constant of any type
	DB 0cdh
	DW  L6A39		; get current sign, E = 0 if no sign
	DB 0d5h

	DB 0cdh
	DW  L6A5C		; unsigned-constant
				; parse constant or constant identifier
	DB 0d1h
	DB 28h,(L6A1F)-$-1		; jump to negate constant if the sign = '-'

	DB 1ch			; sign before constant ?
	DB 1dh

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 19H			; error 25: Integer or real constant expected

	DB 1dh			; return E = 255
	DB 0c9h

L6A1F:	; negates the REAL, LONGINT or INTEGER constant if there is a '-' sign ?
	DB 0cdh
	DW  L6A4A		; sign = '-' ?
	DB 0c8h			; return if no minus sign

	DB 78h
	DB 0feh, 9			; type = REAL ?
	DB 20h,(L6A1F1)-$-1		; jump if not

	; negate REAL constant internally
	DB 0d9h
	DB 78h
	DB 0eeh, 080H
	DB 47h
	DB 0d9h
	DB 0afh
	DB 0c9h

L6A1F1:	DB 0feh, 0AH			; type = INTEGER ?
	DB 20h,(L6A31)-$-1		; jump if not

L6A30:	DB 0cdh
	DW  L0783		; negate INTEGER constant internally
	DB 0afh
	DB 0c9h

L6A31:	; negate LONGINT constant internally
	DB 0d9h
	DB 0cdh
	DW  L_NEG
	DB 0d9h
	DB 0afh
	DB 0c9h

L6A39:	; SYNTAX: sign ::= + | -
	; in:	IX = current text pointer
	; out:	E = 255, if current character  = '-'
	;	E =   0, if current character != '+', no sign
	;	E =   1, if current character  = '+'
	DB 1eh,0FFH
	DB 0ddh,7eh,+0
	DB 0feh, '-'                     ; '-' ?
	DB 28h,(L6A47)-$-1		; next non-blank if '-' found

	DB 1ch			; E = 0
	DB 0feh, '+'                     ; '+' ?
	DB 0c0h			; quit if no '-' nor '+'

	DB 1ch			; E = 1
L6A47:	DB 0c3h
	DW  L6F92 		; to next non-blank

L6A4A:	; in:	E = sign, 255 = '-', 0 = no sign, 1 = '+'
	;	B = type
	DB 1ch
	DB 1dh
	DB 0c8h			; return if no sign
	DB 78h
	DB 0feh, 00AH			; type = INTEGER ?
	DB 28h,(L6A56)-$-1

	DB 0feh, 9			; type = REAL ?
	DB 28h,(L6A56)-$-1

	DB 0feh, 0EH			; type = LONGINT ?
	DB 20h,(L6A58)-$-1		; jump if error

L6A56:	DB 1dh			; return NZ if sign = '-'
	DB 0c9h

L6A58:	DB 0cdh
	DW  L72E1		; no condition
	DB 19H			; error 25: Integer, longint or real constant expected

L6A5C_SIGN:
	DB 0

L6A5C:	; SYNTAX: unsigned-constant ::= unsigned-number | string |
	;			     constant-identifier
	; in:	IX = current text pointer
	;	E = sign (0 = no sign, 255 = minus, 1 = plus)
	; out:	B = 08h, type = string, C = length, L7A57 filled with value
	;	B = 0Ch, type = char,   C = 1, HL character value
	;	B = 09h, type = real,   HLDEBC' = real value
	;	B = 0Ah, type = integer, HL = integer value
	;	E = 0Eh, type = longint, DEHL' = longint value
	;	Z-flag = 1, succeeded
	;	Z-flag = 0, not a constant nor a constant variable identifier
	DB 7bh
	DB 32h
	DW L6A5C_SIGN
	DB 0cdh
	DW  L6A99		; check for an unsigned-constant | string
	DB 0c8h			; return if a constant found

	DB 01h
	DW 200H		; constant identifier ?
	DB 0cdh
	DW  L6E54		; check if current in id list
				; HL = address of info
	DB 0c0h			; return if not in id list

	DB 46h		; B = type of constant name
	DB 78h
	DB 2bh

	DB 0feh, 00EH			; type = LONGINT ?
	DB 28h,(L6A741)-$-1		; jump if type = LONGINT

	DB 0feh, 00AH			; not an INTEGER, BYTE, CHAR nor BOOLEAN
	DB 38h,(L6A74)-$-1		; jump if type < 10

	; return INTEGER, BYTE, CHAR or BOOLEAN constant in HL
	DB 56h
	DB 2bh
	DB 5eh
	DB 0ebh

	DB 0afh			; return with Zero
	DB 0c9h

L6A74:	DB 0feh, 9
	DB 20h,(L6A88)-$-1		; jump if type not REAL

	; return REAL value in HLDEBC'
	DB 0c5h

	DB 46h
	DB 2bh
	DB 4eh
	DB 2bh

L6A742:	DB 56h
	DB 2bh
	DB 5eh
	DB 2bh
	DB 7eh
	DB 2bh
	DB 6eh
	DB 67h
	DB 0d9h

	DB 0afh			; return with Zero
	DB 0c1h
	DB 0c9h

L6A741:	; return LONGINT constant in DEHL'
	DB 0c5h
	DB 18h,( L6A742)-$-1

L6A88:	DB 4eh		; C = length
	DB 11h
	DW L7A57
	DB 0c5h
	DB 0ch

L6A8E:	DB 0dh
	DB 28h,(L6A97)-$-1		; jump and return with Zero

	DB 2bh
	DB 7eh
	DB 12h
	DB 13h
	DB 18h,( L6A8E)-$-1

L6A97:	DB 0c1h
	DB 0c9h

L6A99:	; in:	IX = current text position
	; out:	B = 08h, type = string, C = length, L7A57 filled with value
	;	B = 0Ch, type = char,   C = 1, HL character value
	;	B = 09h, type = real,   HLDEBC' = real value
	;	B = 0Ah, type = integer, HL = integer value
	;	B = 0Eh, type = longint, DE'HL' = longint value
	;	Z-flag = 1, succeeded
	DB 0ddh,7eh,+0
	DB 0feh, 27H			; ', start of string constant ?
	DB 28h,(L6AA8)-$-1		; jump if true

	DB 0feh, '^'                     ; start of CTRL-<character> constant ?
	DB 28h,(L6AA8)-$-1		; jump if true

	DB 0feh, '#'                     ; start of #<num> constant ?
	DB 20h,(L6B0E)-$-1		; jump if not string nor character constant

L6AA8:	; read multiple <string>, <num> or CTRL-<character> constants
	DB 21h
	DW L7A57
	DB 0eh,0
L6AAD:	DB 0ddh,7eh,+0
	DB 0feh, '^'
	DB 28h,(L6AD8)-$-1		; jump for CTRL-<character> constant

	DB 0feh, '#'
	DB 28h,(L6AEE)-$-1		; jump for #<num> constant

	DB 0feh, 27H			; ', start of string constant ?
	DB 20h,(L6AFE)-$-1		; quit if none of these constants

	; read <string> constant
L6ABC:	DB 0ddh,23h
	DB 0ddh,7eh,+0
	DB 0b7h

	DB 28h,(L6AD31)-$-1
;	 CALL L72D4		 ; Zero --> error
;	 DB 37H			 ; error 55: String constant exceeds line

	DB 0feh, 027H			; last character = ' ?
	DB 20h,(L6AD3)-$-1		; jump and store character if not

	DB 0ddh,23h
	DB 0ddh,7eh,+0
	DB 0feh, 027H			; two '-characters in a row ?
	DB 20h,(L6AAD)-$-1		; if not, jump to end string

	; store a '-character

L6AD3:	DB 77h		; store character
	DB 23h
	DB 0ch			; increase string length
	DB 18h,( L6ABC)-$-1 		; repeat

L6AD31:	DB 0cdh
	DW  L72E1		; Zero --> error
	DB 37H			; error 55: String constant exceeds line

L6AD8:	; read CTRL-<character> constant
	DB 0ddh,23h
	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L04A6		; upcase
	DB 0b7h

	DB 28h,(L6AD31)-$-1
;	 CALL L72D4		 ; Zero --> error
;	 DB 37H			 ; error 55: String constant exceeds line

	DB 0eeh, 040H 		; ^A = #1, ^B = #2 etc.
	DB 0ddh,23h

L6AE9:	DB 77h
	DB 23h
	DB 0ch
	DB 18h,( L6AAD)-$-1 		; repeat for next string constant

L6AEE:	; read #<num> constant
	DB 0ddh,23h
	DB 0c5h
	DB 0e5h
	DB 0cdh
	DW  L07F7		; convert hexadecimal or decimal to HL
	DB 7dh
	DB 0e1h
	DB 0c1h

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 38H			; error 56: Error in integer constant

	DB 18h,( L6AE9)-$-1

L6AFE:	DB 06h,8			; assume type = STRING
	DB 79h
	DB 3dh
	DB 20h,(L6B0B)-$-1		; STRING if length > 1

	DB 67h			; H = 0
	DB 3ah
	DW L7A57
	DB 6fh			; HL = character
	DB 06h,00CH		; type = CHAR

L6B0B:	DB 0c3h
	DW  L6F95 		; get non-blank

L6B0E:	DB 0feh, '$'                     ; hexadecimal constant ?
	DB 28h,(L6B45)-$-1

	DB 0cdh
	DW  L7286		; carry reset if A = digit
L6B15:	DB 30h,(L6B1A)-$-1		; jump for start of REAL or integer
	DB 0afh
	DB 3dh			; return A = 255, and NonZero
	DB 0c9h

L6B1A:	DB 0ddh,0e5h
	DB 0d1h
L6B1D:	DB 13h
	DB 1ah
	DB 0cdh
	DW  L7286		; carry reset if A = digit
	DB 30h,(L6B1D)-$-1		; yes, check next character

	DB 0cdh
	DW  L04A6		; upcase
	DB 0feh, 'E'                     ; 'E' from exponent ?
	DB 28h,(L6B39)-$-1		; make REAL conversion to HLDEBC'
	DB 0feh, '.'                     ; comma ?
	DB 20h,(L6B45)-$-1		; make integer conversion to HL

	DB 13h
	DB 1ah
	DB 0feh, '.'                     ; <num>.. ?
	DB 28h,(L6B45)-$-1		; make integer conversion to HL
	DB 0feh, ')'                     ; <num>)
	DB 28h,(L6B45)-$-1		; make integer conversion to HL

L6B39:	; converts ascii REAL to HLDEBC
	; out:	HLDEBC' = binary REAL
	;	B = 9, type = real
	DB 0cdh
	DW  L11A3		; convert ascii REAL to binary REAL HLDEBC

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 39H			; error 57: Error in real constant

	DB 0d9h
	DB 06h,9			; type of real
	DB 18h,( L6B0B)-$-1 		; to next non-blank

L6B45:	; converts integer to HL or longint to DE'HL'
	; out:	HL = integer value
	;	B = 0Ah, type = INTEGER
	;	DE'HL' = longint value
	;	B = 0Eh, type = LONGINT
	DB 0cdh
	DW  A2L 		; convert hexadecimal or decimal to DE:HL

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 38H			; error 56: Error in integer constant

	DB 4fh			; C = 0 if hexadecimal parsed

	DB 3ah
	DW DEF_TYPE
	DB 0feh, 0FFH
	DB 28h,(SMART_CONST)-$-1

	DB 0feh, 0AH
	DB 28h,(L6B46)-$-1		; check on integer

SMART_CONST_LONGINT:
	; check on longint
	DB 0ch			; hexadecimal parsed ?
	DB 0dh
	DB 28h,(L6B451)-$-1		; yes, don't check sign

	; DE = 0
	DB 0cbh,07ah			; DE negative ?
	DB 0cah
	DW L6B451		; jump if not, OK

	DB 3ah
	DW L6A5C_SIGN
	DB 3ch			; 255 ?, a minus sign present ?
	DB 0c2h
	DW L4AE7		; error: constant out of range

	DB 7ah			; long > MAXLONGINT + 1
	DB 0e6h, 7FH
	DB 0b3h
	DB 0b4h
	DB 0b5h
	DB 0c2h
	DW L4AE7		; error: constant out of range

L6B451:	DB 0d9h			; save in DE'HL'
	DB 06h,0EH
	DB 0c3h
	DW  L6B0B

L6B46:	; constant must be integer
	DB 7ah
	DB 0b3h
	DB 0c2h
	DW L4AE7		; error: constant out of range

SMART_CONST_INTEGER:
	DB 0ch			; hexadecimal parsed ?
	DB 0dh
	DB 28h,(L6B461)-$-1		; jump if hexadecimal

	DB 0cbh,07ch			; HL >= 0 and HL <= 32767 ?
	DB 0cah
	DW L6B461		; jump if OK

	DB 3ah
	DW L6A5C_SIGN
	DB 3ch			; 255 ?, a minus sign present ?
	DB 0c2h
	DW L4AE7		; error: constant out of range

	DB 7ch
	DB 0e6h, 7FH
	DB 0b5h
	DB 0c2h
	DW L4AE7		; error: constant out of range

L6B461:	DB 06h,0AH 		; type integer
	DB 0c3h
	DW  L6B0B 		; to next non-blank

SMART_CONST:
	DB 7ah
	DB 0b3h
	DB 20h,(SMART_CONST_LONGINT)-$-1

	DB 0ch			; hexadecimal parsed ?
	DB 0dh
	DB 28h,(L6B461)-$-1		; return type = INTEGER

	DB 0cbh,07ch			; HL >= 32768 and HL <= 65535 ?
	DB 28h,(L6B461)-$-1		; jump if within INTEGER positive range

	DB 3ah
	DW L6A5C_SIGN
	DB 3ch			; 255 ?, a minus sign present ?
	DB 0c2h
	DW L6B451		; no sign but out of range >> LONGINT

	DB 7ch
	DB 0e6h, 7FH
	DB 0b5h
	DB 0cah
	DW L6B461		; if 8000h then return type = INTEGER

	DB 0c3h
	DW  L6B451		; return type = LONGINT

;	 JR NZ,L6B451		 ; INTEGER out of range >> LONGINT
;
;	 JR L6B461		 ; return type = INTEGER

O_CODE:	; in:	first byte after call-instruction is non-zero length
	;	followed by 'length' data byte outputted by 'O_BYTE'
	; changes: HL, BC unchanged
	DB 0e3h
	DB 0c5h
	DB 46h		; B = length
L6B53:	DB 23h
L6B54:	DB 7eh
	DB 0cdh
	DW  O_BYTE
	DB 23h
	DB 10h,( L6B54)-$-1
	DB 0c1h
	DB 0e3h		; jump to byte after last data byte
	DB 0c9h

L6B5E:	; outputs length byte (C) and data at L7A57
	; in:	C = length of data
	; out:	C = 0
	;	Z-flag = 1
	;	B = unchanged !
	DB 79h			; output first 'C' bytes from L7A57
	DB 0cdh
	DW  O_BYTE

L6B62:	DB 21h
	DW L7A57
	DB 0ch
L6B66:	DB 0dh
	DB 0c8h

	DB 7eh
	DB 23h
	DB 0cdh
	DW  O_BYTE

	DB 18h,( L6B66)-$-1

O_PSHHL: DB 3eh,0E5H		 ; out: push hl
	DB 18h,( O_BYTE)-$-1

O_POPHL: DB 3eh,0E1H		 ; out: pop hl
	DB 18h,( O_BYTE)-$-1

O_C3:	DB 3eh,0C3H		; out: 'jp' opcode
	DB 18h,( O_BYTE)-$-1

O_DE:	DB 7bh			; out: value of de
	DB 0cdh
	DW  O_BYTE
	DB 7ah
	DB 18h,( O_BYTE)-$-1

O_JPHL:	DB 3eh,0C3H		; out: 'jp' opcode + value of hl
	DB 18h,( O_OPHL)-$-1

O_CALHL: DB 3eh,0CDH                  ; out: 'call' opcode + value of hl
	DB 18h,( O_OPHL)-$-1

O_LDBC:	DB 3eh,1			; out: 'ld bc,' opcode + value of hl
	DB 18h,( O_OPHL)-$-1

O_LDDE:	DB 3eh,11H 		; out: 'ld de,' opcode + value of hl
	DB 18h,( O_OPHL)-$-1

O_LDHL:	DB 3eh,21H 		; out: 'ld hl,' opcode + value of hl

O_OPHL:	DB 0cdh
	DW  O_BYTE

O_HL:	DB 7dh			; out: value of hl
	DB 0cdh
	DW  O_BYTE
	DB 7ch

O_BYTE:				; out: value of a
	DB 0c5h
	DB 47h
	DB 3ah
	DW L7900		; 0 = compile to memory
				; 1 = code generation to disk
				; 2 = search address

;	 OR A
;	 JR NZ,L6BA7		 ; jump if not compiling to memory
;
;	 LD (IY+0),B
;
;L6BA7:
	DB 0fdh,23h
;	 OR A
;	 JR Z,L6BC6		 ; jump if compiling to memory

	DB 0e5h
	DB 0d5h

	DB 3dh			; A = 1 ?
	DB 28h,(L6BC1)-$-1		; jump if compiling to disk

	DB 0fdh,0e5h
	DB 0d1h
	DB 1bh
	DB 02ah
	DW L00CE
	DB 0b7h
	DB 0EDH,052h

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 0C8H			; error 200: run-time error address found

	DB 18h,( L6BC4)-$-1

L6BC1:	DB 0cdh
	DW  L6C02		; write B in record to update

L6BC4:	DB 0d1h
	DB 0e1h
L6BC6:	DB 0c1h

L6BC7:	; check compiler/memory overflow
	; in:	-
	; out:	-
	DB 0e5h
	DB 0d5h

	DB 0edh,5bh
	DW L7BE1		; start of free area + 1024

	; DE = lowest address that is still free

	DW 53edh,COMPCUR		; current compiler address
	DB 02ah
	DW L7B73		; top of variable table
	DB 25h			; 256 bytes tolerance
	DB 37h
	DB 0EDH,052h
	DB 38h,(ERR63)-$-1

;	 CALL L72C8		 ; carry set --> error
;	 DB 63H			 ; error 99: Compiler overflow

	DB 0fdh,0e5h
	DB 0d1h			; DE = destination address for code

	DB 02ah
	DW L7908		; HL = data start address
	DB 25h			; minus 512 bytes tolerance
	DB 25h
	DB 0EDH,052h

	DB 38h,(ERR62)-$-1

	DB 0d1h
	DB 0e1h
	DB 0c9h

	; these are used for printing more info during compilation about
	; the amount of free compiler memory and free space for code
COMPCUR: DW 0
EMCUR:  DW 0


ERR62:	DB 0cdh
	DW  L72E1		; no condition
	DB 62H			; error 98: Memory overflow

ERR63:	DB 0cdh
	DW  L72E1		; no condition
	DB 63H			; error 99: Compiler overflow


L6C02:	; With this routine a previous written block can be updated.
	; Used by FORWARD ?
	; in:	B = data byte to write in 128 byte buffer L7957
	;
	DB 21h
	DW L7BDB
	DB 0cbh,0ceh		; block is dirty

	DB 0cbh,046h		; already read ?
	DB 28h,(L6C12)-$-1		; jump if block already read

	DB 0cbh,086h		; make already read

	DB 0c5h
         DB 0cdh
	DW  L6CF9                 ; read record to update in buffer L7957
	DB 0c1h


L6C12:	; in:	B = data byte to write in 128 byte buffer L7957
	; out:	L7BDC increased to next byte in block
	;	reset if 0 if it became equal to block size

         ; CodeFileBufferPos
;         LD A,(L7BDC)               ; A = index to 128 byte buffer
;         LD E,A
;         LD D,0
;         LD HL,L7957                ; start of block buffer
         DB 0edh,5bh
	DW CODEFILEBUFFERPOS
         DB 21h
	DW CODEFILEBUFFER
	DB 019h

         DB 70h                  ; write data byte to buffer

;         INC A
;         JP P,L6C2C                 ; jump if index <= 127

         DB 13h
         DB 0cbh,052h                    ; test tenth bit, equals 1024 ?
         DB 0cah
	DW L6C2C                 ; jump if < 1024

         DB 0cdh
	DW  L6CFD                 ; write to file

         DB 0e5h
         DB 02ah
	DW CODEFILEPOS
         DB 2eh,0
         DB 7ch
         DB 0e6h, 0FCH
         DB 67h
;         LD A,L
;         AND 80H                    ; CodeFileBufferSize
;         LD L,A

;         LD DE,128                  ; CodeFileBufferSize
         DB 11h
	DW CODEFILEBUFFERSIZE
         DB 019h
         DB 22h
	DW CODEFILEPOS
         DB 0e1h

         DB 30h,(L6C2B)-$-1

         DB 02ah
	DW CODEFILEPOS+2
         DB 23h
         DB 22h
	DW CODEFILEPOS+2

L6C2B:
;         LD HL,(L7954)              ; increase file block count
;         INC HL                     ; because RANDOM READ/WRITE don't update
;         LD (L7954),HL              ; the block count

;         XOR A                      ; start all over with index = 0
         DB 11h
	DW 0                    ; start over at byte 0 of buffer

L6C2C:
         DW 53edh,CODEFILEBUFFERPOS
;         LD (L7BDC),A               ; save for next byte
	DB 0c9h

L6C30:	;
	; in:	DE = number of data bytes to allocate
	; out:	-
	DB 02ah
	DW L7908		; HL = data start address
	DB 0b7h
	DB 0EDH,052h		; carry set if (L7908) < DE

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 62H			; error 98: Memory overflow

	DB 22h
	DW L7908		; set new data start address
         DB 0c3h
	DW  L6BC7                   ; check compiler, memory overflow

L6C3F:   ; update address at HL with current address in IY
         ; in:    HL = address to update
         DB 0fdh,0e5h
	DB 0d1h

L6C42:   ; in:    HL = address to update
	;	DE = data to update address HL with
	DB 3ah
	DW L7900
	DB 3dh
	DB 28h,(L6C53)-$-1		; jump if compiling to disk

	; update directly in RAM
	DB 0fdh,0e5h			; save old code address

	DB 0e5h
	DB 0fdh,0e1h			; set destination address for data
	DB 0cdh
	DW  O_DE		; update data

	DB 0fdh,0e1h			; restore code address
	DB 0c9h

L6C53:	DB 0c5h
	DB 0d5h			; save update data
	DB 0e5h			; save address to update

	DB 02ah
	DW L7BDF		; start address of update table

	DB 3ah
	DW L7BE3
	DB 47h			; B = number of update entries in table
	DB 04h

	; insert an entry in the update table
	; table is sorted from high to low
	; 7FFFH, 7865H, 7600H, 75FEH etc.
L6C5E:	DB 05h
	DB 28h,(L6C84)-$-1		; jump if end of table reached

	DB 5eh
	DB 23h
	DB 56h

         DB 0e3h                 ; push update table pointer
				; pop address to update in HL
	DB 0b7h
	DB 0EDH,052h		; update address - DE
	DB 019h

         DB 0e3h                 ; pop update table pointer
				; push address to update

	DB 38h,(L6C71)-$-1		; jump if update address < DE
				; in range

	DB 23h			; next entry in update table
	DB 23h
	DB 23h
	DB 18h,( L6C5E)-$-1

L6C71:	; DE = address read from update table
	DB 2bh

	DB 0ebh 		; DE = pointer to first byte of entry
				; in update table
	DB 68h
	DB 26h,0
	DB 029h		; HL = 4 * entries left in update table
	DB 029h
	DB 44h			; BC = size of entries left
	DB 4dh
	DB 019h
	DB 54h
	DB 5dh
	DB 2bh			; HL = address last byte of lastused entry

	DB 13h
	DB 13h
	DB 13h			; DE =
	DB 0edh,0b8h

	DB 23h
	; HL = address of new free inserted entry

L6C84:   DB 0d1h                     ; pop address to update
	DB 73h
	DB 23h
	DB 72h
	DB 23h
         DB 0d1h                     ; pop update data
	DB 73h
	DB 23h
	DB 72h
	DB 0c1h
	DB 21h
	DW L7BE3		; increase number to update ?
	DB 034h
	DB 0c0h

	DB 0afh			; write 256 updates
	DB 18h,( L6C9B)-$-1

L6C96:	DB 3ah
	DW L7BE3
	DB 0b7h
	DB 0c8h			; return if no updates

L6C9B:	DB 0c5h
	DB 0d5h
	DB 0fdh,0e5h
	DB 47h
	DB 02ah
	DW L7BDF

L6CA3:	DB 0c5h			; save number of updates left

	DB 5eh
	DB 23h
	DB 56h
	DB 23h

	DB 0e5h
	DB 0ebh
	DB 0cdh
	DW  L6CC2
	DB 0e1h

	DB 46h
	DB 23h

	DB 0e5h
	DB 0cdh
	DW  L6C02		; write B in record to update
	DB 0e1h

	DB 46h
	DB 23h
	DB 0e5h

         DB 0cdh
	DW  L6C02                 ; write B in record to update

         DB 0e1h

	DB 0c1h			; B = number of updates left
	DB 10h,( L6CA3)-$-1

	DB 0e1h
	DB 0d1h
	DB 0c1h

L6CC2:   ; in:    HL = addres to update
	; out:	IY = HL
	; unchanged: BC, DE
	DB 0e5h
	DB 0fdh,0e1h			; init IY with code address

	DB 3ah
	DW L7900
	DB 3dh
	DB 0c0h			; return if searching

	DB 0d5h
	DB 0c5h

	; calculate from current address in HL the
	; block position and
	; relative block number
	DB 0edh,5bh
	DW L7902
	DB 0b7h
	DB 0EDH,052h		; HL = relative address to start of code

;         LD A,L
;         AND 07FH
;         LD (L7BDC),A               ; set position within block

;         LD A,L
;         AND 80H
;         LD L,A

         DB 0edh,5bh
	DW CODEFILESTART
         DB 019h

         DB 0edh,5bh
	DW CODEFILESTART+2
         DB 30h,(L6CC3)-$-1

         DB 13h
L6CC3:

;         LD A,L
;         AND 07FH
;         LD (L7BDC),A               ; set position within block
         DB 7dh
         DB 32h
	DW CODEFILEBUFFERPOS
         DB 7ch
         DB 0e6h, 3
         DB 32h
	DW CODEFILEBUFFERPOS+1 ; mask for CodeFileBufferSize = 1024

;         LD A,L
;         AND 80H
;         LD C,A

;         ADD HL,HL
;         LD L,H
;         RLA
;         AND 1
;         LD H,A                     ; HL = relative block number
;
;         LD DE,(L7BDD)              ; DE = first block of current part
;         ADD HL,DE

;         LD A,(CodeFilePos)
;         AND 80H
;         CP C
;         JR NZ,L6CC4

         DB 7ch
         DB 0e6h, 0FCH                   ; mask for CodeFileBufferSize = 1024
         DB 4fh

         DB 3ah
	DW CODEFILEPOS+1
         DB 0e6h, 0FCH                   ; mask for CodeFileBufferSize = 1024
         DB 0b9h
         DB 20h,(L6CC4)-$-1

         DB 3ah
	DW CODEFILEPOS+2
         DB 0bbh
         DB 20h,(L6CC4)-$-1

         DB 3ah
	DW CODEFILEPOS+3
         DB 0bah
         DB 28h,(L6CF6)-$-1

;         LD DE,(L7954)              ; DE = current block
;         OR A
;         SBC HL,DE
;;!       pushf
;         ADD HL,DE
;;!       popf
;         JR Z,L6CF6                 ; jump if equal to current block

L6CC4:
         DB 0d5h
         DB 0e5h
	DB 0cdh
	DW  L6CFD		; write 128 bytes to file
	DB 0e1h
         DB 0d1h

         DB 22h
	DW CODEFILEPOS
         DW 53edh,CODEFILEPOS+2
;         LD (L7954),HL

L6CF6:	DB 0c1h
	DB 0d1h
	DB 0c9h

L6CF9:   ; in:    FCB at L7933 filled in
	; out:	read 128 bytes from FCB to buffer at L7957
	; changes: HL, DE, BC
	; unchanged: IY

         DB 0fdh,0e5h

         DB 02ah
	DW CODEFILEPOS
         DB 2eh,0
         DB 7ch
         DB 0e6h, 0FCH                   ; mask for CodeFileBufferSize == 1024
         DB 67h
;         LD A,L
;         AND 80H                    ; CodeFileBufferSize
;         LD L,A
         DB 0edh,5bh
	DW CODEFILEPOS+2
         DB 01h
	DW CODEFILE
         DB 0cdh
	DW  FILESEEK              ; set to current position

         DB 21h
	DW CODEFILEBUFFERSIZE   ; read 128 bytes from file
                                    ; CodeFileBufferSize
         DB 11h
	DW CODEFILEBUFFER       ; L7957
         DB 0cdh
	DW  READFILE              ; read from file

         DB 0fdh,0e1h

         DB 0b7h
         DB 0c8h                      ; quit if no errors

	DB 0cdh
	DW  L72E1		; no condition
	DB 0FAH			; error 250: Disk or directory full

;         LD C,021H                  ; random record read 128 bytes
;         JR L6D09

L6CFD:
	; in:	FCB at L7933 filled in
	; out:	writes 128 byte buffer at L7957 to file
	;	no errors
	; changes: HL, DE, BC
	; unchanged: IY
	DB 21h
	DW L7BDB
	DB 0cbh,0c6h		; 1 = no record read to update

	DB 0cbh,04eh
	DB 0c8h			; return if not busy updating

	DB 0cbh,08eh		; 0 = updating finished
;         LD C,022H                  ; random record write 128 bytes

L6D09:	; in:	C = 21H, read
	;	C = 22H, write
	; unchanged: IY

         DB 0fdh,0e5h
         DB 02ah
	DW CODEFILEPOS
         DB 2eh,0
         DB 7ch
         DB 0e6h, 0FCH                   ; mask for CodeFileBufferSize == 1024
         DB 67h
;         LD A,L
;         AND 80H                    ; CodeFileBufferSize
;         LD L,A
         DB 0edh,5bh
	DW CODEFILEPOS+2
         DB 01h
	DW CODEFILE
         DB 0cdh
	DW  FILESEEK              ; set to current position

         DB 21h
	DW CODEFILEBUFFERSIZE   ; read 128 bytes from file
                                    ; CodeFileBufferSize
         DB 11h
	DW CODEFILEBUFFER
         DB 0cdh
	DW  WRITEFILE             ; read to file
         DB 0fdh,0e1h

         DB 0b7h

;         PUSH BC
;         LD DE,L7957                ; buffer
;         LD C,01AH
;         CALL DOSIXIY               ; set dma address
;         POP BC
;         LD DE,L7933
;         CALL DOSIXIY               ; random record read/write 128 bytes
;         OR A
;         RET Z                      ; return if no error
;         DEC A
;         RET Z                      ; return if end of file or disk full error
;         CP 3
         DB 0c8h                      ; return if ???

	DB 0cdh
	DW  L72E1		; no condition
	DB 0FAH			; error 250: Disk or directory full

L6D24:	; pushes 13 bytes starting at L7B64 to the stack
	; changes: HL',DE',BC'
	DB 0d9h
	DB 11h
	DW L7B64
	DB 18h,( L6D2E)-$-1

L6D2A:	; pushes 13 bytes starting at L7B57 to the stack
	; changes: HL',DE',BC'
	DB 0d9h
	DB 11h
	DW L7B57
L6D2E:	DB 0e1h
	DB 22h
	DW L7BD5		; temporary save return address
	DB 21h
	DW -13
	DB 039h
	DB 0f9h
	DB 0ebh
	DB 01h
	DW 13
	DB 0edh,0b0h
L6D3D:	DB 02ah
	DW L7BD5		; restore return address
	DB 0e5h
	DB 0d9h
	DB 0c9h

L6D43:	; pops 13 bytes to L7B64
	; changes: HL',DE',BC'
	DB 0d9h
	DB 11h
	DW L7B64
	DB 18h,( L6D4D)-$-1

L6D49:	; pops 13 bytes to L7B57
	; changes: HL',DE',BC'
	DB 0d9h
	DB 11h
	DW L7B57
L6D4D:	DB 0e1h
	DB 22h
	DW L7BD5
	DB 21h
	DW 0
	DB 039h
	DB 01h
	DW 13
	DB 0edh,0b0h
	DB 0f9h
	DB 18h,( L6D3D)-$-1

L6D5D:	; moves 13 bytes from stack+2 to L7B64
	; changes: HL',DE',BC'
	DB 0d9h
	DB 11h
	DW L7B64
	DB 18h,( L6D67)-$-1

L6D63:	; moves 13 bytes from stack+2 to L7B57
	; changes: HL',DE',BC'
	DB 0d9h
	DB 11h
	DW L7B57
L6D67:	DB 21h
	DW 2
	DB 039h
	DB 01h
	DW 13
	DB 0edh,0b0h
	DB 0d9h
	DB 0c9h

L6D72:	; add IY to id table
	DB 0fdh,0e5h
	DB 0d1h

L6D75:	; add DE to id table
;	 LD A,D
;	 CALL L6D7A		 ; add byte to id table
;	 LD A,E
	DB 0e5h
	DB 02ah
	DW L7B73
	DB 72h
	DB 2bh			; decrease bottom of the table
	DB 73h
	DB 2bh			; decrease bottom of the table
	DB 22h
	DW L7B73
	DB 0e1h
	DB 0c3h
	DW  L6BC7 		; check compiler, memory overflow

L6D7A:	; in:	A = data byte to be added to the identifier table
	; out:	-
	DB 0e5h
	DB 02ah
	DW L7B73
	DB 77h
	DB 2bh			; decrease bottom of the table
	DB 22h
	DW L7B73
	DB 0e1h
	DB 0c3h
	DW  L6BC7 		; check compiler, memory overflow

L6D87:	; add the identifier at address IX to the identifier table
	; in:	-
	; out:	-
	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L7271		; letter or underscore?

L6D8D:	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 3AH			; error 58: Illegal character in identifier

	DB 0cdh
	DW  L6ED0		; check if already in identifier table

L6D94:	DB 0cdh
	DW  L6EB8		; test if reserved word
				; gives error 53 if word is reserved
	DB 0ddh,7eh,+0		; A = first letter
L6D9A:	DB 0feh, 'a'
	DB 38h,(L6DA4)-$-1
	DB 0feh, 'z'+1
	DB 30h,(L6DA4)-$-1
	DB 0d6h, 'a'-'A'
L6DA4:	DB 0cdh
	DW  L6D7A		; add byte to id table
	DB 0ddh,23h
	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L7282		; letter, underscore or decimal
	DB 30h,(L6D9A)-$-1
	DB 02ah
	DW L7B73
	DB 23h
	DB 0cbh,0feh		; mark end of added identifier
	DB 0c3h
	DW  L6F95 		; get to next non-blank

L6DBA:	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L7271		; letter or underscore?

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 3AH			; error 58: Illegal character in identifier

	DB 18h,( L6D94)-$-1

L6DC6:	; calculates and adds the length of the newly defined struct
	; as a word to the id table
	; in:	(L7B75), (L7B73)
	; out:	added (L7B75) - (L7B73)
	;	(L7B75) = (L7B73)
	DB 02ah
	DW L7B75		; HL = top of id table before
	DB 0edh,5bh
	DW L7B73		; DE = top of id table after
	DB 0b7h
	DB 0EDH,052h		; calculate the difference
	DB 0ebh
	DB 0cdh
	DW  L6D75		; add the length of the variable declaration
	DB 02ah
	DW L7B73
	DB 22h
	DW L7B75		; equal top before and top after
	DB 0c9h

L6DDB:	; in:	B =
	;	C =
	DB 02ah
	DW L7B7B		; HL = start of identifier list
	DB 18h,( L6DE3)-$-1

L6DE0:	; out:	-
	DB 02ah
	DW L7B77		; HL = absolute top of id list

L6DE3:	; in:	HL = end of list to search
	;	B = 1 = LABEL,	2 = CONSTANT
	;	    3 = TYPE,	4 = VARIABLE
	;	    5 = PROCEDURE 6 = FUNCTION
	DB 22h
	DW L7B7D
	DB 3ah
	DW L7BC0
	DB 0b9h
	DB 0cah
	DW L6E48
	DB 79h
	DB 32h
	DW L7BC0
	DB 02ah
	DW L7B75
L6DF3:
	DB 0edh,5bh
	DW L7B7D

	DB 7bh
	DB 0bdh
	DB 0c2h
	DW L6E03
	DB 7ah
	DB 0bch
	DB 20h,(L6E03)-$-1

;	 XOR A
;	 SBC HL,DE		 ; tabel is empty if HL = DE
;;!	 pushf
;	 ADD HL,DE
;;!	 popf
;	 JR NZ,L6E03		 ; no, tabel is not empty
	DB 0afh
	DB 32h
	DW L7BC1
	DB 3dh			; return with 255 and NonZero
				; not found
	DB 0c9h

L6E03:	DB 23h
	DB 5eh		; DE = offset, # bytes of struct
	DB 23h
	DB 56h
	DB 019h
	DB 7eh
	DB 0b7h			; first byte zero, does not contain a name
	DB 28h,(L6DF3)-$-1		; yes, search next
	DB 2bh
	DB 7eh
	DB 23h
	DB 0b9h			; gelijk C?
	DB 20h,(L6DF3)-$-1		; no, search next

	DB 0c5h
	DB 0e5h
	DB 11h
	DW TEMPID
	DB 2bh
	DB 2bh			; HL = address of first letter of ID

	DB 0cdh
	DW  FASTCMPR
	DB 0cah
	DW L6E3B		; jump if equal

;L6E19:	 LD A,(DE)		 ; A = byte from text
;	 INC DE
;	 CP (HL)
;	 JR NZ,L6E37		 ; quit if not equal
;	 DEC HL
;	 BIT 7,A
;	 JR Z,L6E19		 ; repeat until end of string

;	 JP L6E3B		 ; jump if equal

;L6E19:	 LD B,(HL)
;	 LD A,(DE)		 ; A = byte from text
;	 DEC HL			 ; next from id tab
;	 INC DE			 ; next from text
;	 LD C,B
;	 RES 7,B
;	 CP 'a'                     ; >= 'a' ?
;	 JR C,L6E2A
;	 CP 'z'+1                   ; < 'z'+1 ?
;	 JR NC,L6E2A
;	 SUB 'a'-'A'                ; up case
;L6E2A:	 CP B
;	 JR NZ,L6E37
;	 BIT 7,C 		 ; end of this string?
;	 JR Z,L6E19		 ; no, compare next
;	 LD A,(DE)		 ; A = next letter to compare from DE string
;	 CALL L7282		 ; test if this character did not belong to
;				 ; the compared word
;	 JR C,L6E3B		 ; carry set if this string was terminated too
L6E37:	DB 0e1h
	DB 0c1h
	DB 18h,( L6DF3)-$-1 		; search next

FASTCMPR:; in:	HL = address of identifier from id table, downwards
	;	DE = address of upcased text identifier, upwards
	; out:	HL = position below last keyword character
	;	Z-flag = 1, found
	;	Z-flag = 0, not found
	DB 1ah		; A = byte from text
	DB 13h
	DB 0beh
	DB 0c0h			; quit if not equal
	DB 2bh
	DB 0cbh,07fh
	DB 28h,(FASTCMPR)-$-1		; repeat until end of string
	DB 0afh
	DB 0c9h

FASTCMP: ; in:	HL = address keyword, upwards
	;	DE = address of upcased text identifier, upwards
	; out:	HL = position after last keyword character
	;	DE = position after identifier in text
	;	Z-flag = 1, found
	;	Z-flag = 0, not found
	DB 0c5h
	DB 11h
	DW TEMPID
FASTCMPL:DB 1ah		; A = byte from text
	DB 13h
	DB 0beh
;!	pushf
	DB 23h
;!	popf
	DB 20h,(FASTCMPQ)-$-1
	DB 0c0h			; quit if not equal
	DB 0b7h
	DB 0f2h
	DW FASTCMPL		; repeat until end of string
	DB 0edh,5bh
	DW TEMPPTR
	DB 0afh
FASTCMPQ:DB 0c1h
	DB 0c9h

BUILDID: ; out:	IX = current text pointer
	;	TEMPPTR = position after word in text
	DB 0d5h
	DB 0ddh,0e5h
	DB 0d1h
	DB 21h
	DW TEMPID-1
	DB 1ah		; A = first byte from text
	DB 0cdh
	DW  L04A6		; up case
	DB 13h
	DB 23h
	DB 77h
	DB 0cdh
	DW  L7282
	DB 38h,(BUILDI2)-$-1		; quit if no character of word

BUILDI1: DB 1ah
	DB 0cdh
	DW  L7282		; legal character ?
	DB 38h,(BUILDI2)-$-1

	DB 0cdh
	DW  L04A6		; up case
	DB 13h			; next from text
	DB 23h
	DB 77h		; save character
	DB 18h,( BUILDI1)-$-1

BUILDI2:
	DB 0cbh,0feh
	DW 53edh,TEMPPTR
	DB 0d1h
	DB 0c9h

;	 LD A,(DE)
;BUILDI1: INC DE			 ; next from text
;	 CALL L04A6		 ; up case
;	 INC HL
;	 LD (HL),A		 ; save character
;	 LD A,(DE)
;	 CALL L7282		 ; test if this character did not belong to
;				 ; the compared word
;	 JR NC,BUILDI1		 ; carry set if this string was terminated too
;	 SET 7,(HL)
;	 LD (TEMPPTR),DE
;	 POP DE
;	 RET

TEMPPTR: DW 0
TEMPID:	db 128 dup (0)

L6E3B:	DB 22h
	DW L7BC2		; save position before known word
	DB 0edh,5bh
	DW TEMPPTR
	DW 53edh,L7BC4		; save position after word in text
	DB 0e1h			; HL = start of known word declaration
	DB 0c1h			; BC = (300H for type identifier or
				;       200H for constant identifier)
	DB 7eh		; A = type of known word
	DB 32h
	DW L7BC1

L6E48:	; in:	B =
	;	C =
	; out:	Z-flag set if B = (L7BC1)
	;	HL = position before known word
	;	DE = position after word in text
	DB 02ah
	DW L7BC2
	DB 0edh,5bh
	DW L7BC4
	DB 3ah
	DW L7BC1
	DB 0b8h			; identical types?
	DB 0c9h

L6E54:	; searches if current word is an identifier list
	; in:	B = 1 = LABEL,	 2 = CONSTANT
	;	    3 = TYPE,	 4 = VARIABLE
	;	    5 = PROCEDURE, 6 = FUNCTION
	;	C =
	; out:	Z-flag = NonZero if not found
	;		Zero if found
	DB 0cdh
	DW  L6DE0
	DB 0c0h			; return if not found
	DB 18h,( L6E96)-$-1 		; go to next non-blank

L6E5A:	; in:	first byte after call instruction is #bytes following the name
	;	second two byte form an address of a reserved word list
	; out:	Z-flag set if a reserved word is found that equals the word
	;	at position IX. HL then contains the address of the byte
	;	directly after the reserved word
	DB 0e3h
	DB 4eh
	DB 23h
	DB 5eh
	DB 23h
	DB 56h
	DB 23h
	DB 0e3h
	DB 0ebh

L6E63:	DB 0cdh
	DW  L6E7D
	DB 0c8h			; quit if okay

	DB 2bh			; go back to last character tested
L6E68:	DB 0cbh,07eh		; was this the last character?
;!	pushf
	DB 23h
;!	popf
	DB 28h,(L6E68)-$-1		; no, try again
	DB 06h,0
	DB 09h
	DB 7eh
	DB 0b7h			; last word of this table checked?
	DB 20h,(L6E63)-$-1		; no, continue searching
	DB 3dh			; return with A = 255 and NonZero
				; for not found
	DB 0c9h

L6E76:	; searches for the word in the text at IX in the given list
	;
	DB 0e3h
	DB 5eh		; DE = address of reserved word
	DB 23h
	DB 56h
	DB 23h
	DB 0e3h		; new return address after 2 data bytes
	DB 0ebh 		; HL = address of reserved word

L6E7D:	DB 0ddh,0e5h
	DB 0d1h
	DB 7eh		; get first character
	DB 0cdh
	DW  L7271		; check if letter or underscore
	DB 38h,(L6E92)-$-1		; carry set if error
	DB 0cdh
	DW  L6E9C		; compare strings
	DB 0c0h			; quit if not equal

	; at this point the strings are equal
	DB 1ah
	DB 0cdh
	DW  L7282		; letter, underscore or decimal
	DB 38h,(L6E96)-$-1		; jump if not letter, underscore or decimal

	DB 0b7h
	DB 0c9h

L6E92:	DB 0cdh
	DW  L6E9C1		; compare strings
	DB 0c0h			; quit if not equal

L6E96:	; in:	DE = current text pointer
	; out:	IX = updated text pointer to next non-blank
	DB 0d5h
	DB 0ddh,0e1h			; update text pointer to text buffer 79D7
	DB 0c3h
	DW  L6F95 		; moves IX to the next non-blank

L6E9C	EQU FASTCMP
	; compares string at HL with string at DE
	; stops if string at HL has bit 7 set or the current character
	; does not match
	; characters from DE are UPCASEed if necessary
	; in:	HL = string terminated by setting bit 7 of the last byte
	;	DE = string to compare with
	; out:	BC unchanged
	;	NonZero if the strings where not the same
	;	Zero if the strings are the same
	;	HL = first byte after the string
	;	DE = first byte after the string to compare with
;	 LD DE,TEMPID
;	 PUSH BC
;	 CALL FASTCMP
;	 POP BC
;	 RET

L6E9C1:	DB 0c5h
L6E9D:	DB 46h
	DB 1ah
	DB 23h
	DB 13h
	DB 48h
	DB 0cbh,0b8h
	DB 0feh, 'a'                     ; < 'a'?
	DB 38h,(L6EAE)-$-1		; yes, continue
	DB 0feh, 'z'+1                   ; > 'z'?
	DB 30h,(L6EAE)-$-1		; yes, continue
	DB 0d6h, 'a'-'A'
L6EAE:	DB 0b8h			; equal characters?
	DB 20h,(L6EB6)-$-1		; no, return with NonZero
	DB 0cbh,079h			; last character of string in HL tested ?
	DB 28h,(L6E9D)-$-1		; no, go for then next
	DB 0afh			; found, return with Zero
L6EB6:	DB 0c1h
	DB 0c9h

L6EB8:	; tests if the current name is a reserved word, slow!!!
	DB 21h
	DW L7513
L6EBB:	DB 4eh
	DB 0ch
	DB 0c8h			; quit if C was 255
	DB 0dh
	DB 23h
	DB 5eh		; DE = address to table of reserved words
	DB 23h
	DB 56h
	DB 23h
	DB 0e5h
	DB 0ebh
	DB 0cdh
	DW  L6E63
	DB 0e1h
	DB 20h,(L6EBB)-$-1

	DB 0cdh
	DW  L72E1		; no condition
	DB 35H			; error 53: Reserved word

L6ED0:	DB 3ah
	DW L7B91
	DB 4fh
	DB 0cdh
	DW  L6DDB

L6ED7:	DB 3ah
	DW L7BC1
	DB 0b7h
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 2BH			; error 43: Duplicate identifier or label

L6EE0:	; in:	-
	; out:	Zero if '[' parsed
	;	Zero if '(.' parsed
	DB 3eh,'['
	DB 0cdh
	DW  L6F29		; match('[')
	DB 0c8h			; return if matched

	DB 0ddh,7eh,+0
	DB 0feh, '('                     ; match('(')
	DB 0c0h			; return if not '(' matched

	DB 0ddh,7eh,+1
	DB 0feh, '.'
	DB 0c0h			; return if not '(.' matched

L6EF2:	DB 0ddh,23h
	DB 0c3h
	DW  L6F92 		; to next non-blank

L6EF7:	; in:	-
	; out:	Zero if ']' parsed
	;	Zero if '.)' parsed
	DB 3eh,']'
	DB 0cdh
	DW  L6F29		; match(']')
	DB 0c8h
	DB 0ddh,7eh,+0
	DB 0feh, '.'
	DB 0c0h
	DB 0ddh,7eh,+1
	DB 0feh, ')'
	DB 0c0h
	DB 18h,( L6EF2)-$-1

L6F0B:	; matches ':', if present
	; returns NZ if not matched
	DB 3eh,':'
	DB 18h,( L6F29)-$-1

L6F0F:	; matches ';', if present
	; returns NZ if not matched
	DB 3eh,';'
	DB 18h,( L6F29)-$-1

L6F13:	; matches ',', if present
	; returns NZ if not matched
	DB 3eh,','                   ; checkes if ',' is the next symbol
	DB 18h,( L6F29)-$-1

L6F17:	; matches '.', if present
	; returns NZ if not matched
	DB 3eh,'.'
	DB 18h,( L6F29)-$-1

L6F1B:	; matches '(', if present
	; returns NZ if not matched
	DB 3eh,'('
	DB 18h,( L6F29)-$-1

L6F1F:	; matches ')', if present
	; returns NZ if not matched
	DB 3eh,')'
	DB 18h,( L6F29)-$-1

L6F23:	; matches '=', if present
	; returns NZ if not matched
	DB 3eh,'='
	DB 18h,( L6F29)-$-1

L6F27:	; matches '^', if present
	; returns NZ if not matched
	DB 3eh,'^'

L6F29:	; matches character in A, if this is the next character
	; returns NZ if this is not the next character
	DB 0ddh,0beh,+0
	DB 0c0h			; quit if not equal
	DB 0c3h
	DW  L6F92 		; get next non-blank character if equal

L6F30:	; matches a '[' or '(.' and gives error 8 otherwise
	DB 0cdh
	DW  L6EE0		; match('[') or match('(.')
	DB 0c8h			; quit if '[' or '(.' matched

	DB 0cdh
	DW  L72E1		; no condition
	DB 8			; error 8: '[' expected

L6F38:	; matches a ']' and gives error 9 otherwise
	DB 0cdh
	DW  L6EF7		; match(']') or match('.)')
	DB 0c8h			; return if matched

	DB 0cdh
	DW  L72E1		; no condition
	DB 9			; error 9: ']' expected

L6F40:	; matches a ':' and gives error 2 otherwise
	DB 0cdh
	DW  L6F0B		; match(':'), if present
	DB 0c8h			; return if ':' matched

	DB 0cdh
	DW  L72E1		; no condition
	DB 2			; error 2: ':' expected

L6F48:	; matches a ';' and gives error 1 otherwise
	; match(';')
	; in:	-
	; out:	-
	DB 0cdh
	DW  L6F0F		; match(';'), if present
	DB 0c8h			; return if ';' matched

L6F4C:	DB 0cdh
	DW  L72E1		; no condition
	DB 1			; error 1: ';' expected

L6F50:	; matches a ';' and gives error 1 or 41 otherwise
	DB 0cdh
	DW  L6F0F		; match(';'), if present
	DB 0c8h			; return if ';' matched
	DB 3ah
	DW L7B98
	DB 0b7h
	DB 28h,(L6F4C)-$-1		; generate error 1 if (L7B98)=0

	DB 0cdh
	DW  L72E1		; no condition
	DB 29H			; error 41: unknown identifier or syntax error

L6F5E:	; matches a ',' and gives error 3 otherwise
	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 0c8h			; return if ',' matched

	DB 0cdh
	DW  L72E1		; no condition
	DB 3			; error 3: ',' expected

L6F66:	; matches a '(' and gives error 4 otherwise
	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 0c8h			; return if '(' matched

	DB 0cdh
	DW  L72E1		; no condition
	DB 4			; error 4: '(' expected

L6F6E:	; matches a ')' and gives error 5 otherwise
	DB 0cdh
	DW  L6F1F		; match(')'), if present
	DB 0c8h			; return if ')' matched

	DB 0cdh
	DW  L72E1		; no condition
	DB 5			; error 5: ')' expected

L6F76:	; matches a '=' and gives error 6 otherwise
	DB 0cdh
	DW  L6F23		; match('='), if present
	DB 0c8h			; return if '=' matched

	DB 0cdh
	DW  L72E1		; no condition
	DB 6			; error 6: '=' expected

L6F7E:	; matches a ':=' and gives error 7 if this is not present
	; in:	-
	; out:	-
	DB 0cdh
	DW  L6E76
	DW L7582 		; start of reserved word: :=
	DB 0c8h			; return if ':=' parsed

	DB 0cdh
	DW  L72E1		; no condition
	DB 7			; error 7: ':=' expected

L6F88:	; matches OF and gives error 15 if this is not present
	DB 0cdh
	DW  L6E76
	DW L7560 		; start of reserved word: OF
	DB 0c8h

	DB 0cdh
	DW  L72E1		; no condition
	DB 0FH			; error 15: OF expected

L6F92:	; moves to next non-blank
	DB 0cdh
	DW  L7124		; read next character from input

L6F95:	; moves IX to the next non-blank character
	; out:	Zero on succes
	DB 0afh
	DB 32h
	DW L7B98
	DB 3dh
	DB 32h
	DW L7BC0
	DB 0ddh,7eh,+0
	DB 0b7h			; end of text line buffer?
	DB 28h,(L6F92)-$-1		; read next line and next non blank
	DB 0feh, 20H			; start with space ?
	DB 28h,(L6F92)-$-1
	DB 0feh, 9			; start with TAB ?
	DB 28h,(L6F92)-$-1
	DB 0feh, '('                     ; first character of comment '(*   *)'
	DB 28h,(L6FB5)-$-1
	DB 0feh, '{'                     ; compiler option or comment
	DB 28h,(L6FBF)-$-1

L6FB3:	DW 22ddh,FILEBUFFERLASTPOS
	DB 0c5h
	DB 0e5h
	DB 0cdh
	DW  BUILDID
	DB 0e1h
	DB 0c1h
	DB 0afh
	DB 0c9h

L6FB5:	DB 0ddh,7eh,+1
	DB 0feh, '*'
	DB 20h,(L6FB3)-$-1
	DB 0cdh
	DW  L7124		; read next character from input
L6FBF:	DB 0c5h
	DB 0ddh,46h,+0
	DB 0ddh,7eh,+1
	DB 0feh, '$'                     ; '{' followed by a '$'
	DB 28h,(L6FEB)-$-1

L6FCA:	DB 0cdh
	DW  L7124		; read next character from input

L6FCD:	DB 78h
	DB 0feh, '*'
	DB 0ddh,7eh,+0
	DB 20h,(L6FE4)-$-1
	DB 0b8h
	DB 20h,(L6FCA)-$-1
	DB 0ddh,7eh,+1
	DB 0feh, ')'
	DB 20h,(L6FCA)-$-1
	DB 0cdh
	DW  L7124		; read next character from input
	DB 18h,( L6FE8)-$-1

L6FE4:	DB 0feh, '}'
	DB 20h,(L6FCA)-$-1

L6FE8:	DB 0c1h
	DB 18h,( L6F92)-$-1 		; move to next non blank

L6FEB:	; found: '{$'
	DB 0c5h
	DB 0d5h
	DB 0e5h
	DB 0cdh
	DW  L7124		; read '{' away
L6FF1:	DB 0cdh
	DW  L7124		; read '$' away
	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L04A6		; upcase
	DB 0feh, 'I'                     ; I  = include or i/o checking ?
				; I+ = I/O Error Handling on
	DB 06h,1			; bit 0
	DB 28h,(L704D)-$-1

	DB 0feh, 'R'                     ; R+ = Index Range Check on
	DB 06h,2			; bit 1
	DB 28h,(L704D)-$-1

	DB 0feh, 'A'                     ; A+ = Absolute code on
	DB 06h,4			; bit 2
	DB 28h,(L704D)-$-1

	DB 0feh, 'U'                     ; U+ = User Interrupt on
	DB 06h,8			; bit 3
	DB 28h,(L704D)-$-1

	DB 0feh, 'X'                     ; X+ = Array Optimization
	DB 06h,10H 		; bit 4
	DB 28h,(L704D)-$-1

	DB 0feh, 'V'                     ; V+ = Var-parameter Type Checking on
	DB 06h,20H 		; bit 5
	DB 28h,(L704D)-$-1

	DB 0feh, 'B'                     ; B+ = I/O Mode Selection
	DB 06h,40H 		; bit 6
	DB 28h,(L704D)-$-1

	DB 0feh, 'C'                     ; C+ = Control C and S interpretation on
	DB 06h,80H 		; bit 7
	DB 28h,(L704D)-$-1

	DB 0feh, 'W'                     ; W# = # levels of nesting With statements
	DB 28h,(L707A)-$-1
	DB 06h,0

	DB 0feh, 'K'                     ; n.a.
	DB 28h,(L704D)-$-1
	DB 0feh, 'D'                     ; n.a.
	DB 28h,(L704D)-$-1
	DB 0feh, 'F'                     ; n.a.
	DB 28h,(L708E)-$-1
	DB 0feh, 'G'                     ; n.a.
	DB 28h,(L708E)-$-1
	DB 0feh, 'P'                     ; n.a.
	DB 28h,(L708E)-$-1

	DB 0cdh
	DW  L72E1		; no condition
	DB 5DH			; error 93: Invalid compiler directive

L7048:	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 18h,( L6FCD)-$-1

L704D:	DB 0cdh
	DW  L7124		; read letter away
	DB 0ddh,7eh,+0
	DB 0eh,0
	DB 0feh, '+'
	DB 28h,(L7065)-$-1
	DB 0dh			; C = 255
	DB 0feh, '-'
	DB 28h,(L7065)-$-1
	DB 05h			; B = 1 (include command) ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 5DH			; error 93: Invalid compiler directive

	DB 18h,( L709B)-$-1 		; yes, {$i filename}

L7065:	DB 21h
	DW L7B9D
	DB 7eh
	DB 0a9h			; XOR 0 = +, XOR 255 = -
	DB 0b0h			; set corresponding bit
	DB 0a9h			; XOR 0 = +, XOR 255 = -
	DB 77h

L706D:	DB 0cdh
	DW  L7124		; read next character from input
L7070:	DB 0ddh,7eh,+0
	DB 0feh, 02CH
	DB 0cah
	DW L6FF1
	DB 18h,( L7048)-$-1

L707A:	DB 0cdh
	DW  L7124		; read letter 'W'
	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L7286		; carry reset if A = digit

	DB 0cdh
	DW  L72C8		; carry set --> error
	DB 5DH			; error 93: Invalid compiler directive

	DB 0d6h, '0'
         DB 32h
	DW WITHDEPTH           ; new WITHDEPTH
	DB 18h,( L706D)-$-1

L708E:	DB 0cdh
	DW  L7124		; read next character from input
	DB 0ddh,7eh,+0
	DB 0cdh
	DW  L7286		; carry reset if A = digit
	DB 30h,(L708E)-$-1
	DB 18h,( L7070)-$-1

L709B:	; parse spaces and then the include file name
	DB 0feh, ' '                     ; followed by a space ?
	DB 20h,(L70A7)-$-1		; no, end
	DB 0cdh
	DW  L7124		; read next character from input
	DB 0ddh,7eh,+0
	DB 18h,( L709B)-$-1

L70A7:
;	 LD A,(L790E)
;	 OR A			 ; already reading from a secondary file ?
;				 ; (an include file)
;
	DB 3ah
	DW FILELEVEL
	DB 0feh, MAXFILELEVELS
	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 60H			; error 96: No nesting of include files

	DB 0ddh,0e5h
	DB 0e1h			; HL = compiler source text pointer

	DB 0e5h

         DB 11h
	DW TEMPFILEDATA
	DB 3eh,'P'
	DB 01h
	DW 'A'*256+'S'
	DB 0cdh
	DW  PARSENAME

	DB 0d1h			; DE = start of filename

;	 CALL L2D2A		 ; parse filename at DE with no wildcards and
;				 ; a default extension of '.PAS'

	DB 0e5h			; save current compiler source text pointer
	DB 0ebh

         DB 0cdh
	DW  GONEXTFILELEVEL

	DB 0ddh,0e1h			; IX = new compiler source text pointer

;	 LD DE,L005C
;	 PUSH DE
;	 LD C,00FH
;	 CALL DOSIXIY		 ; open file
;	 POP HL
;	 INC A			 ; A was 0FFH if error occurred
;
;	 CALL L72D4		 ; Zero --> error
;	 DB 5AH			 ; error 90: File not found
;
;	 LD DE,L790F
;	 LD BC,FCB_LEN
;	 LDIR			 ; copy opened FCB at L005C to FCB at L790F
;
;	 LD A,(L7900)
;	 DEC A
;	 JR Z,L70E2		 ; jump if compiling to disk
;				 ; that is calculate a buffer to read more
;				 ; text at once for more efficiency
;
;	 LD HL,L7957		 ; start address buffer
;	 LD (L7BE4),HL
;	 LD HL,L79D7		 ; end address buffer
;	 LD A,1			 ; read from file = NonZero
;	 JR L7103
;
;L70E2:	 LD HL,(L7B73)		 ; bottom of variable table
;	 LD DE,(L7BE1)		 ; start address of free area
;	 LD (L7BE4),DE		 ; save start of text buffer
;	 OR A
;	 SBC HL,DE		 ; HL = total space that is still free
;
;	 SRL H			 ; divide by 2
;	 RR L
;;	  SRL H
;;	  RR L			  ; divide by 4
;
;	 LD A,H			 ; check if >= 256
;	 OR A
;
;	 CALL L72D4		 ; Zero --> error
;	 DB 63H			 ; error 99: Compiler overflow
;
;	 LD A,L			 ; round off to 128 bytes
;	 AND 128
;	 LD L,A
;	 PUSH HL
;	 ADD HL,HL
;	 LD A,H			 ; A = number of blocks of
;
;	 POP HL
;	 ADD HL,DE
;
;L7103:
;	 LD (L7BE6),HL
;	 LD (L7BE9),HL
;	 LD (L7BE8),A		 ; save number of records of 128 bytes
;	 LD (L790E),A		 ; set: read from file = non-zero
;
;	 LD HL,0
;	 LD (L7BEB),HL		 ; init current position in include file
;	 LD HL,0
;	 LD (INCLINE),HL		 ; restart line number

	DB 0cdh
	DW  L718F		; print current line number

	DB 3ah
	DW L7B9D		; compiler directives
	DB 32h
	DW L7B9F		; save them
	DB 3ah
	DW WITHDEPTH
	DB 32h
	DW L7BC8		; save ?
	DB 0c3h
	DW  L7048

L7124:   ; -----------------------------------------------------------
	; ReadLine
	; -----------------------------------------------------------

	; read next character from input buffer
	DB 0ddh,7eh,+0
	DB 0ddh,23h
	DB 0b7h			; begins with a zero?
	DB 0c0h			; no, buffer is not empty,
				; quit with character

	; read a new line from the input buffer
	DB 0c5h
	DB 0d5h
	DB 0e5h

	DB 3ah
	DW L7BA2
	DB 0b7h			; end of file found ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 5BH			; error 91: Unexpected end of source

;	 LD HL,(L7BD7)		 ; current text pointer
;	 LD (L7BD9),HL		 ; save start of line of text in memory

;	 LD HL,(L7BEB)		 ; HL = character position in include file
;	 LD (L7BED),HL		 ; save start of line in include file

	DB 21h
	DW L79D7
	DB 0e5h
	DB 0ddh,0e1h			; set IX at start of text line buffer again

	DB 06h,07FH		; maximum number of characters is 127
L714A:	DB 0e5h
	DB 0c5h
	DB 0cdh
	DW  L71F3		; read character from input
	DB 0c1h
	DB 0e1h
	DB 0feh, 0DH			; carriage return?
	DB 28h,(L7175)-$-1
	DB 0feh, 1AH			; end of text?
	DB 28h,(L716A)-$-1
	DB 0feh, 9			; TAB?, exception on characters < 20H
	DB 28h,(L7161)-$-1
	DB 0feh, ' '                     ; < 20H, < space
	DB 38h,(L714A)-$-1		; yes, read next character
L7161:	DB 10h,( L7166)-$-1

	; skip rest of line until return, end of text, tab or space
	DB 04h
	DB 18h,( L714A)-$-1

L7166:	DB 77h		; store character in buffer
	DB 23h
	DB 18h,( L714A)-$-1 		; next character

L716A:	DB 32h
	DW L7BA2		; set to non-zero, end of file found = true

	DB 0cdh
	DW  L717E		; increase and print line number
	DB 0cdh
	DW  L718F		; print line number
	DB 18h,( L7178)-$-1

L7175:	DB 0cdh
	DW  L717E		; increase and print line number

L7178:	DB 36h,0
	DB 0e1h
	DB 0d1h
	DB 0c1h
	DB 0c9h

L717E:	; increases and prints the current line number each time
	; line number and 3fh = 0
	; and gives an 'abort compilation' message if a key is pressed
	; in:	-
	; out:	-
	DB 0f5h
	DB 0e5h

	DB 02ah
	DW FILEBUFFERLINE
	DB 23h
	DB 22h
	DW FILEBUFFERLINE

	DB 02ah
	DW TOTALLINES
	DB 23h
	DB 22h
	DW TOTALLINES

	DB 7dh
	DB 0e6h, 3FH			; line number mod 64 = 0?
	DB 28h,(L7191)-$-1		; yes, print this number and skip PUSH AF,HL
	DB 0e1h
	DB 0f1h
	DB 0c9h

PRINTFILENAME:
         ; in:    DE = handle/FCB block

	DB 13h
	DB 0ebh

PRINTASCIIZUPCASED:
	DB 7eh
	DB 0b7h
	DB 0c8h
	DB 0cdh
	DW  UPCASE
	DB 0cdh
	DW  L03C9
	DB 23h
	DB 18h,( PRINTASCIIZUPCASED)-$-1

PRINTASCIIZ:
	DB 7eh
	DB 0b7h
	DB 0c8h
	DB 0cdh
	DW  L03C9
	DB 23h
	DB 18h,( PRINTASCIIZ)-$-1

L718F:	; prints current line number and tests keypressing during compilation
	; changes: -
	DB 0f5h
	DB 0e5h

L7191:	DB 0c5h
	DB 0d5h
	DB 0ddh,0e5h
	DB 0fdh,0e5h

IFDEF MSX
;	 LD HL,(0FC9EH)
;	 PUSH HL
ENDIF	; MSX

	DB 3eh,13
	DB 0cdh
	DW  L03C9		; print carriage return

;	 LD A,(L7BE3)
;	 CALL L04B4		 ; print update count
;
;	 LD A,' '
;	 CALL L03C9

	DB 02ah
	DW L7B73
	DB 0edh,5bh
	DW COMPCUR
	DB 0b7h
	DB 0EDH,052h
	DB 0cdh
	DW  L2E5C		; print free memory in compiler
				; print in decimals, always 5 characters

;	 LD HL,(COMPCUR)		 ; current compiler address
;	 CALL L04AF		 ; print HL hexadecimal
;	 LD A,'-'
;	 CALL L03C9		 ; print '-'
;	 LD HL,(L7B73)		 ; bottom of variable table
;	 CALL L04AF

	DB 3eh,' '
	DB 0cdh
	DW  L03C9
	DB 0cdh
	DW  L03C9

;	 LD HL,(MEMCUR)		 ; current address for new code
;	 CALL L04AF		 ; print
;	 LD A,'-'
;	 CALL L03C9
;	 LD HL,(L7908)		 ; highest possible address for generated code
;	 DEC H			 ; minus 512
;	 DEC H
;	 CALL L04AF
;
;	 LD A,' '
;	 CALL L03C9

	DB 02ah
	DW TOTALLINES
	DB 0cdh
	DW  L2E5C		; print total compiled pascal lines

	DB 3eh,' '
	DB 0cdh
	DW  L03C9

	DB 02ah
	DW FILEBUFFERLINE
	DB 0cdh
	DW  L2E5C		; print current line number in file

	DB 3eh,' '
	DB 0cdh
	DW  L03C9
	DB 0cdh
	DW  L03C9

	DB 3ah
	DW FILELEVEL
	DB 0c6h,'0'
	DB 0feh, '0'
	DB 20h,(L7192)-$-1		; jump to print include level

	DB 3eh,' '

L7192:	DB 0cdh
	DW  L03C9		; print include level or space

	DB 3eh,' '
	DB 0cdh
	DW  L03C9		; space between level and filename

;	 LD A,(L790E)		 ; reading from include file?
;	 OR A
;	 JR Z,L71A6		 ; jump if reading from memory
;
;	 LD HL,(INCLINE)
;	 LD DE,L790F		 ; HL = address of include file FCB
;	 LD A,'I'                   ; print 'I' if reading from include file
;	 JR L71A8
;
;L71A6:

	DB 11h
	DW FILECURRENTINFO
         DB 0cdh
	DW  PRINTFILENAME

;         LD A,(DOS2Present)
;         OR A
;	 PUSH AF
;	 CALL Z,L2DF8		 ; print FCB if DOS 1
;	 INC DE
;	 POP AF
;	 EX DE,HL
;	 CALL NZ,PrintASCIIZ	 ; print drive/path/filename if DOS 2

;	 LD DE,L451D		 ; work filename FCB
;	 JR Z,L71A61
;
;	 LD DE,L44F9		 ; main filename FCB
;
;L71A61:  LD A,' '                   ; otherwise print space
;
;L71A8:	 PUSH DE 		 ; save FCB address
;	 PUSH HL
;
;	 CALL L03C9
;	 LD A,' '
;	 CALL L03C9		 ; print space
;
;	 POP HL			 ; current line number
;	 CALL L2E5C		 ; print in decimals, always 5 characters
;	 CALL L2E61		 ; print line number
;	 LD A,' '
;	 CALL L03C9		 ; print space
;
;	 POP DE			 ; DE = FCB address
;	 CALL L2DF8		 ; print file name in DE

	DB 3eh,27
	DB 0cdh
	DW  L03C9
	DB 3eh,'K'
	DB 0cdh
	DW  L03C9		; print ESC K, delete until end of line

;	 LD B,8
;L71A81:  LD A,' '
;	 CALL L03C9
;	 DJNZ L71A81

	DB 0cdh
	DW  CONSTPTR		; keypressed ?
	DB 0b7h
	DB 28h,(L71EA)-$-1
	DB 0cdh
	DW  L0200
	DB '   *** Abort compilation',0
	DB 0cdh
	DW  L2D01		; print ' (Y/N)? '

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 0CAH			; staat niet in Herman's boek(je)

	DB 06h,20H
L71E1:	DB 0cdh
	DW  L0200
	DB 8,' ',8,0               ; backspace, space, backspace
	DB 10h,( L71E1)-$-1

L71EA:

IFDEF MSX
;	 POP HL
;	 LD (0FC9EH),HL
ENDIF	; MSX

	DB 0fdh,0e1h
	DB 0ddh,0e1h
	DB 0d1h
L71EF:	DB 0c1h
	DB 0e1h
	DB 0f1h
	DB 0c9h

L71F3:   ; in:    -
	; out:	A = next character from text file, memory or include
	;	Z-flag set if A was 1AH, end of text
;	 LD HL,(FileBufferCount)
;	 DEC HL
;	 LD A,H
;	 OR L
;; ;!	   pushf
;	 DEC HL
;; ;!	   popf
;	 LD (FileBufferCount),HL
;
;	 CALL Z,FileReadBuffer	 ; read new buffer if count == 0

	DB 02ah
	DW FILEBUFFERPOS
	DB 7eh
;	 CALL L03C9
	DB 23h
	DB 22h
	DW FILEBUFFERPOS

	DB 0f5h

	DB 02ah
	DW FILEBUFFERCOUNT
	DB 2bh
	DB 7ch
	DB 0b5h
	DB 0cch
	DW FILEREADBUFFER	; read new buffer if count = 0
	DB 22h
	DW FILEBUFFERCOUNT

	DB 0f1h

	DB 0feh, 1AH			; end of file marker (^Z) ?
	DB 0c0h			; quit if it was not end of file
; 33e

         DB 01h
	DW FILECURRENTINFO      ; 33e TODO, 568A
         DB 0cdh
	DW  CLOSEFILE
         DB 0cdh
	DW  L72DA
         DB 85H

; 33e
	DB 3ah
	DW FILELEVEL
	DB 0b7h			; previous level = include file ?
	DB 3eh,1AH
	DB 0c8h			; return with end of file if end of all

	DB 0cdh
	DW  GOPREVIOUSFILELEVEL

	DB 0cdh
	DW  L718F		; update display status

	DB 18h,( L71F3)-$-1 		; read next character from this level

;	 LD A,(L790E)
;	 OR A
;	 JR NZ,L7205		 ; jump if reading from include file
;
;L71F9:	 LD HL,(L7BD7)		 ; HL = current text pointer
;	 LD A,(HL)
;	 CP 1AH			 ; end of text?
;	 RET Z
;	 INC HL			 ; next position
;	 LD (L7BD7),HL
;	 RET
;
;L7205:	 ; read from text file
;
;	 LD HL,(L7BE9)		 ; current text pointer for include file
;	 LD DE,(L7BE6)		 ; end address of include file data
;	 OR A
;	 SBC HL,DE
;	 ADD HL,DE
;	 JR C,L7242		 ; jump if current pointer < end address
;				 ; still data present
;
;	 LD DE,(L7BE4)		 ; destination address, start address for
;				 ; include file data
;	 LD A,(L7BE8)		 ; calculate number of records
;	 LD B,A			 ; 128 bytes to read
;L721A:	 PUSH BC
;	 PUSH DE
;	 LD C,1AH
;	 CALL DOSIXIY		 ; set DMA address
;
;	 LD DE,L790F		 ; include FCB
;	 LD C,14H
;	 CALL DOSIXIY		 ; sequential read 128 bytes
;	 POP DE
;	 POP BC
;	 OR A
;	 JR NZ,L7237		 ; truncate at last DMA address
;
;	 LD HL,128
;	 ADD HL,DE		 ; destination address for next block
;	 EX DE,HL
;	 DJNZ L721A
;	 JR L723F
;
;L7237:	 ; error occurred during loading of text place a CTRL-Z (end-of-text)
;	 ; error means a partially read last block of 128 bytes so the end
;	 ; address of the include file text must be adjusted
;	 LD A,1AH
;	 LD (DE),A
;	 INC DE
;	 LD (L7BE6),DE		 ; set new end address of include file
;
;L723F:	 ; init current pointer
;	 LD HL,(L7BE4)		 ; HL = start address of loaded text
;
;L7242:	 LD A,(HL)
;	 INC HL			 ; point to next character
;	 LD (L7BE9),HL		 ; set new current text pointer
;	 CP 1AH
;	 JR NZ,L725D
;
;	 XOR A
;	 LD (L790E),A		 ; set: read from memory
;
;	 LD A,(L7B9F)		 ; saved directives
;	 LD (L7B9D),A		 ; restore compiler directives
;
;	 LD A,(L7BC8)
;	 LD (WITHDEPTH),A 	 ; restore
;
;	 JR L71F9
;
;L725D:	 LD HL,(L7BEB)
;	 INC HL			 ; increase current file position
;				 ; in include file
;	 LD (L7BEB),HL
;	 RET

;DOSIXIY: PUSH IX
;         PUSH IY
;         CALL MSXDOS
;         POP IY
;         POP IX
;         RET

L7271:	; in:	A = testing character
	; out:	Carry Flag Reset if A in ['A'..'Z','a'..'z','_']
	;	Carry Flag Set if A is not a letter and not an underscore
	;	A unchanged
	DB 0feh, 'A'
	DB 0d8h
	DB 0feh, 'Z'+1
	DB 3fh
	DB 0d0h
	DB 0feh, '_'
	DB 0c8h
	DB 0feh, 'a'
	DB 0d8h
	DB 0feh, 'z'+1
	DB 3fh
	DB 0c9h

L7282:	; in:	A = testing character
	; out:	Carry Flag Reset if see condition at L7271 and if
	;	A in ['0'..'9']
	;	Carry Flag Set if not an letter, underscore or decimal
	DB 0cdh
	DW  L7271		; letter or underscore
	DB 0d0h

L7286:	; in:	A = testing character
	; out:	Carry Flag Reset if A in ['0'..'9']
	;	Carry Flag Set otherwise
	DB 0feh, '0'                     ; < '0' ?
	DB 0d8h
	DB 0feh, '9'+1                   ; > '9' ?
	DB 3fh
	DB 0c9h

L728D:	; checks if the lower bound <= upper bound
	; in:	HL = <n>, upper bound
	;	DE = <m>, lower bound
	; out:	Carry = 1, if HL < DE
	DB 7ch
	DB 0aah

	DB 7ch
	DB 0fah
	DW L7298		; jump if one bound is negative
	DB 0bah
	DB 0c0h
	DB 7dh
	DB 0bbh
	DB 0c9h

L7298:	DB 17h			; return Carry = 1, if upper bound < 0
	DB 0c9h

L729A:	; in:	HL, DE
	; out:	HL = HL * DE
	DB 44h
	DB 4dh
	DB 21h
	DW 0			; sum = 0
	DB 3eh,16

L72A1:	DB 029h
	DB 0d8h			; quit if overflow

	DB 0ebh
	DB 029h
	DB 0ebh
	DB 30h,(L72AA)-$-1

	DB 09h
	DB 0d8h
L72AA:	DB 3dh
	DB 20h,(L72A1)-$-1
	DB 0c9h

;	 divide ?
;	 LD B,D
;	 LD C,E
;	 EX DE,HL
;	 XOR A
;	 LD H,A
;	 LD L,A
;	 LD A,011H
;L72B6:	 ADC HL,HL
;	 SBC HL,BC
;	 JR NC,L72BE
;	 ADD HL,BC
;	 SCF
;L72BE:	 CCF
;	 RL E
;	 RL D
;	 DEC A
;	 JR NZ,L72B6
;	 EX DE,HL
;	 RET

L72C8:	DB 0e3h		; error if carry set
	DB 23h
	DB 0e3h
	DB 0d0h
	DB 18h,( L72DE)-$-1

L72CE:	DB 0e3h		; error if carry reset ; unused ???
	DB 23h
	DB 0e3h
	DB 0d8h
	DB 18h,( L72DE)-$-1

L72D4:	DB 0e3h		; error if zero flag set
;!	pushf
	DB 23h
;!	popf
	DB 0e3h
	DB 0c0h
	DB 18h,( L72DE)-$-1

L72DA:	DB 0e3h		; error if zero flag reset
;!	pushf
	DB 23h
;!	popf
	DB 0e3h
	DB 0c8h
L72DE:	DB 0e1h
	DB 2bh
	DB 0e5h

L72E1:	DB 0e1h
	DB 7eh		; A = error code

L72E3:	DB 0cdh
	DW  L718F		; make update of current line

	DB 32h
	DW L7901		; save error code
	DB 0b7h
	DB 28h,(L730C)-$-1

	DB 0ddh,0e5h
	DB 0e1h
	DB 11h
	DW L79D7		; DE = start of line buffer
	; NonCarry
	DB 0EDH,052h		; HL = zero-based column

;	 LD DE,(L7BED)		 ; text position in include file
;	 LD A,(L790E)
;	 OR A
;	 JR NZ,L7308		 ; jump if reading from include file
;
;	 LD DE,(L4544)		 ; HL = start of text area
;	 SBC HL,DE
;	 LD DE,(L7BD9)		 ; DE = start of line of text in memory
;
;L7308:	 ADD HL,DE
;	 LD (L790C),HL

L730C:	DB 3ah
	DW L7900
	DB 3dh
	DB 20h,(L731A)-$-1		; jump if searching

         DB 01h
	DW CODEFILE
         DB 0cdh
	DW  CLOSEFILE

;         LD DE,L7933
;         LD C,010H
;         CALL DOSIXIY               ; close

L731A:	DB 0edh,7bh
	DW L7B71
	DB 0c9h

L731F:	DW 0BH
	DW LONGDEF		; definition of a longint
	DB 'T' + 80H
	DB 'NIGNOL'                ; LONGINT
	DB 0,3			; type

	DW 0BH			; length
	DW L74DA 		; definition of an integer
	DB 0D2H,'EGETNI'           ; INTEGER
	DB 0,3			; type

	DW 8			; length
	DW L74E2 		; definition of a char
	DB 0D2H,'AHC'              ; CHAR
	DB 0,3			; type

	DW 8			; length
	DW L74EA 		; definition of a real
	DB 0CCH,'AER'              ; REAL
	DB 0,3			; type

	DW 0BH			; length
	DW L74F2 		; definition of a boolean
	DB 0CEH,'AELOOB'           ; BOOLEAN
	DB 0,3			; type

;	 DW 8
;	 DW FILEDEF
;	 DB 0C5H,'LIF'              ; FILE
;	 DB 0,3			 ; type

	DW 8			; length
	DW L74FA 		; definition of text
	DB 0D4H,'XET'              ; TEXT
	DB 0,3			; type

	DW 8			; length
	DW L7502 		; definition of a byte
	DB 0C5H,'TYB'              ; BYTE
	DB 0,3			; type


	DW 9			; length
	DW 0001H 		; value of true
	DB 0BH			; type: boolean
	DB 0C5H,'URT'              ; TRUE
	DB 0,2			; constant

	DW 0AH			; length
	DW 0000H 		; value of false
	DB 0BH			; type: boolean
	DB 0C5H,'SLAF'             ; FALSE
	DB 0,2			; constant

	DW 0BH			; length
	DW 7FFFH 		; value of MAXINT
	DB 0AH			; type: integer
	DB 0D4H,'NIXAM'            ; MAXINT
	DB 0,2			; constant

	DW 11H			  ; length
	DW 0FFFFH
	DW 07FFFH
	DB 0EH			; type: longint
	DB 0D4H,'NIGNOLXAM'        ; MAXLONGINT
	DB 0,2			; constant

	DW 0BH			; length
	DB 82H,21H,0A2H,0DAH,0FH,49H ; REAL value of PI
	DB 9			; type: real
	DB 0C9H,'P'                ; PI
	DB 0,2			; constant

	DW 0DH			; length
	DW L74FA 		; definition of a text
	DW _OUTPUT		; LIB, value
	DB 0
	DB 0D4H,'UPTUO'            ; OUTPUT
	DB 0,4			; var absolute

	DW 0CH			; length
	DW L74FA 		; definition of a text
	DW _OUTPUT		; LIB
	DB 0
	DB 0D4H,'UPNI'             ; INPUT
	DB 0,4			; var absolute

	DW 0AH			; length
	DW L74FA 		; definition of a text
	DW _L00B8		; LIB
	DB 0
	DB 0CEH,'OC'               ; CON
	DB 0,4

	DW 0AH			; length
	DW L74FA 		; definition of a text
	DW _L00B8		; LIB
	DB 0
	DB 0CDH,'RT'               ; TRM
	DB 0,4

	DW 0AH			; length
	DW L74FA 		; definition of a text
	DW _L00BA		; LIB
	DB 0
	DB 0C4H,'BK'               ; KBD
	DB 0,4

	DW 0AH			; length
	DW L74FA 		; definition of a text
	DW _LST			; LIB
	DB 0
	DB 0D4H,'SL'               ; LST
	DB 0,4

	DW 0AH			; length
	DW L74FA 		; definition of a text
	DW _L00BE		; LIB
	DB 0
	DB 0D8H,'UA'               ; AUX
	DB 0,4

	DW 0AH			; length
	DW L74FA 		; definition of a text
	DW _L00C0		; LIB
	DB 0
	DB 0D2H,'SU'               ; USR
	DB 0,4

	DW 0DH			; length
	DW L7502 		; definition of a byte
	DW _BUFLEN		; LIB
	DB 0
	DB 0CEH,'ELFUB'            ; BUFLEN
	DB 0,4

	DW 0EH			; length
	DW L74DA 		; definition of an integer
	DW _HEAPPTR		; LIB
	DB 0
	DB 0D2H,'TPPAEH'           ; HEAPPTR
	DB 0,4

	DW 0FH			; length
	DW L74DA 		; definition of an integer
	DW _RECURPTR		; LIB
	DB 0
	DB 0D2H,'TPRUCER'          ; RECURPTR
	DB 0,4

	DW 0FH			; length
	DW L74DA 		; definition of an integer
	DW _CONSTPTR+1		; LIB
	DB 0
	DB 0D2H,'TPTSNOC'          ; CONSTPTR
	DB 0,4

	DW 0FH			; length
	DW L74DA 		; definition of an integer
	DW _CONINPTR+1		; LIB
	DB 0
	DB 0D2H,'TPNINOC'          ; CONINPTR
	DB 0,4

	DW 10H			; length
	DW L74DA 		; definition of an integer
	DW _CONOUTPTR+1		; LIB
	DB 0
	DB 0D2H,'TPTUONOC'         ; CONOUTPTR
	DB 0,4

	DW 10H			; length
	DW L74DA 		; definition of an integer
	DW _LSTOUTPTR+1		; LIB
	DB 0
	DB 0D2H,'TPTUOTSL'         ; LSTOUTPTR
	DB 0,4

	DW 0FH			; length
	DW L74DA 		; definition of an integer
	DW _AUXINPTR+1		; LIB
	DB 0
	DB 0D2H,'TPNIXUA'          ; AUXINPTR
	DB 0,4

	DW 10H			; length
	DW L74DA 		; definition of an integer
	DW _AUXOUTPTR+1		; LIB
	DB 0
	DB 0D2H,'TPTUOXUA'         ; AUXOUTPTR
	DB 0,4

	DW 0FH			; length
	DW L74DA 		; definition of an integer
	DW _USRINPTR+1		; LIB
	DB 0
	DB 0D2H,'TPNIRSU'          ; USRINPTR
	DB 0,4

	DW 10H			; length
	DW L74DA 		; definition of an integer
	DW _USROUTPTR+1		; LIB
	DB 0
	DB 0D2H,'TPTUORSU'         ; USROUTPTR
	DB 0,4

	DW 11H
	DW L74DA 		; definition of an integer
         DW _OVERLAYLOADPTR+1       ; LIB
	DB 0
	DB 0D2H,'TPYALREVO'        ; OVERLAYPTR
	DB 0,4

	DW 0FH			; length
	DW L74DA 		; definition of an integer
	DW _ERRORPTR+1		; LIB
	DB 0
	DB 0D2H,'TPRORRE'          ; ERRORPTR
	DB 0,4

	DW 0EH			; length
	DW L7502 		; definition of a byte
	DW 0FAF6H		; byte absolute $FAF6
	DB 0
	DB 'E'+80H,'GAPTCA'        ; ACTPAGE
	DB 0,4

	DW 0DH			; length
	DW L7502 		; definition of a byte
	DW 0FB02H		; byte absolute $FB02
	DB 0
	DB 'R'+80H,'POGOL'         ; LOGOPR
	DB 0,4

	DW 0DH			; length
	DW L7502 		; definition of a byte
	DW 0F3F2H		; byte absolute $F3F2
	DB 0
	DB 'T'+80H,'YBRTA'         ; ATRBYT
	DB 0,4

	DW 0DH			; length
	DW L7502 		; definition of a byte
	DW 0F3EBH		; byte absolute $F3EB
	DB 0
	DB 'R'+80H,'EDROB'         ; BORDER
	DB 0,4

	DW 14H			; length
	DW L74DA 		; definition of an integer
	DW _MEMMNVER		; LIB
	DB 0
	DB 'N'+80H,'OISREVNAMMEM'  ; MemManVersion
	DB 0,4

	DW 0EH			; length
	DW L74DA 		; definition of an integer
	DW _RUNGIOS+1
	DB 0
	DB 'S'+80H,'OIGNUR'        ; RunGIOS
	DB 0,4

	DW 12H			; length
	DW L74DA 		; definition of an integer
	DW _GIOSVER		; LIB
	DB 0
	DB 'N'+80H,'OISREVSOIG'    ; GIOSVersion
	DB 0,4

	DW 12H			; length
	DW L74F2 		; definition of a boolean
	DW _GIOSOK
	DB 0
	DB 'T'+80H,'NESERPSOIG'    ; GIOSPresent
	DB 0,4

	DW 14H			; length
	DW L74F2 		; definition of a boolean
	DW _MEMMAN
	DB 0
	DB 'T'+80H,'NESERPNAMMEM'  ; MemManPresent
	DB 0,4

	DW 0DH			; length
	DW L74F2 		; definition of a boolean
	DW _CBREAK		; LIB
	DB 0
	DB 0CBH,'AERBC'            ; CBREAK
	DB 0
L74D2:	DB 4			; start of variable table, going downwards

	; basic types
	;  5  = typed file
	;  6  = text
	;  7  = untyped file
	;  8  = string
	;  9  = real
	; 0AH = integer, byte --> differences in range and length only
	; 0BH = boolean
	; 0CH = char
	; 0EH = longint

	; definition of a longint
	DB 0
	DB 4			; length of a longint
	DB 0,0			; max value, ignored
	DB 0,0			; min value, ignored
	DB 0
LONGDEF: DB 0EH			; type = LONGINT

	; definition of an integer
	DB 0
	DB 2			; length of an integer
	DB 7FH,0FFH		; max value
	DB 80H,000H		; min value
	DB 0
L74DA:	DB 0AH			; type = integer

	; definition of a char
	DB 0
	DB 1			; length of a character
	DB 0,0FFH		; max value
	DB 0,0			; min value
	DB 0
L74E2:	DB 0CH			; type = char

	; definition of a real
	DB 0
	DB 6			; length of a real
	DB 0,0			; max value, ignored
	DB 0,0			; min value, ignored
	DB 0
L74EA:	DB 9			; type = real

	; definition of a boolean
	DB 0
	DB 1			; length of a boolean
	DB 0,1			; max value
	DB 0,0			; min value
	DB 0
L74F2:	DB 0BH			; type = boolean

	; definition of an untyped file
	DB 0
         DB DOS_LEN-128
	DB 0,0
	DB 0,0
	DB 0
FILEDEF: DB 7			; type = untyped file

	; definition of a text
	DB 0
         DB DOS_LEN                 ; length of a file info block, FIB
	DB 0,0			; max value, ignored
	DB 0,0			; min value, ignored
	DB 0
L74FA:	DB 6			; type = text

	; definition of a byte
	DB 0
	DB 1			; length of a byte
	DB 0,0FFH		; max value
	DB 0,0			; min value
	DB 0
L7502:	DB 0AH			; type = byte

	DB 0
	DB 9			; length
	DB 0,0
	DB 0,0
	DB 0
L750A:	DB 8			; type = string

	DB 0
	DB 0			; length
	DB 0,0
	DB 0,0
	DB 0
L7512:	DB 0			; type

L7513:	DB 0			; 0 indicates 0 bytes following the name
	DW L7529 		; start of reserved word list:
				; PROGRAM, END, FORWARD,
				; EXTERNAL, PACKED, ARRAY, FILE,
				; SET, RECORD, STRING, OF, ABSOLUTE,
				; THEN, ELSE, DO, UNTIL, NOT, NIL

	DB 1			; 1 byte following
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	DB 2			; 2 bytes following
	DW L75BB 		; start of reserved word list:
				; BEGIN, IF, WHILE, REPEAT, FOR
				; CASE, GOTO, WITH, INLINE

	DB 1			; 1 byte following
	DW L75F5

	DB 1			; 1 byte following
	DW L7604

	DB 1			; 1 byte following
	DW L761D

	DB 1			; 1 byte following
	DW L7634

	DB 0FFH			; end of this table

L7529:	DC 'PROGRAM'
L7530:	DC 'END'
L7533:	DC 'FORWARD'
L753A:	DC 'EXTERNAL'
L7542:	DC 'PACKED'
L7548:	DC 'ARRAY'
L754D:	DC 'FILE'
L7551:	DC 'SET'
L7554:	DC 'RECORD'
L755A:	DC 'STRING'
L7560:	DC 'OF'
L7562:	DC 'ABSOLUTE'
L756A:	DC 'THEN'
L756E:	DC 'ELSE'
L7572:	DC 'DO'
L7574:	DC 'UNTIL'

L7579:	DC 'NOT'
L757C:	DC 'NIL'
	DB 0			; end of this table

L7580:	DC '..'

L7582:	DC ':='                    ; assign

L7584:	DC 'LABEL'                 ; 4x list
	DB 1
	DC 'CONST'
	DB 2
	DC 'TYPE'
	DB 3
L7595:	DC 'VAR'
	DB 4
	DC 'BEGIN'
	DB 8
L759F:	DC 'OVERLAY'
	DB 7
L75A7:	DC 'PROCEDURE'             ; 1x list
	DB 5
	DC 'FUNCTION'
	DB 6
	DB 0

L75BB:	DC 'BEGIN'                 ; 1x list
	DW L5377 		; statements ended by 'END'

	DC 'IF'
         DW L53EF

	DC 'WHILE'
	DW L5424

	DC 'REPEAT'
	DW L544C

	DC 'FOR'
	DW L546B

L75DA:	DC 'CASE'
	DW L5521

	DC 'GOTO'
	DW L5626
	DC 'WITH'
	DW L564E
L75EC:	DC 'INLINE'
	DW L5698
	DB 0			; end of this table

L75F5:	DC 'TO'                    ; 1x list
	DB 23H			; opcode: INC HL
	DC 'DOWNTO'
	DB 2BH			; opcode: DEC HL
	DB 0			; end of this table

L7600:	DC '*'                     ; 0, *
	DB 0
L7602:	DC '/'                     ; 1, /
	DB 1

L7604:	DC 'AND'                   ; 2, AND
	DB 2
	DC 'DIV'                   ; 3, DIV
	DB 3
	DC 'MOD'                   ; 4, MOD
	DB 4
	DC 'SHL'                   ; 5, SHL
	DB 5
	DC 'SHR'                   ; 6, SHR
	DB 6
	DB 0			; end of this table

L7619:	DC '+'                     ; 0, +
	DB 0
	DC '-'                     ; 1, -
	DB 1

L761D:	DC 'OR'                    ; 2, OR
	DB 2
	DC 'XOR'                   ; 3, XOR
	DB 3
	DB 0			; end of this table

L7625:	DB '=' + 80H               ;  0, =
	DB 0
L7627:	DB '<','>' + 80H           ;  1, <>
	DB 1
L762A:	DB '>','=' + 80H           ;  2, >=
	DB 2
L762D:	DB '<','=' + 80H           ;  3, <=
	DB 3
L7630:	DB '>' + 80H               ;  4, >
	DB 4
L7632:	DB '<' + 80H               ;  5, <
	DB 5
L7634:	DC 'IN'                    ; ffh, IN
	DB 0FFH
	DB 0			; end of list

L78FA:	DC 'MEM'
	DB 0,0,0

L7900:	DB 0			; 0 = compilation to memory
				; 1 = compilation to disk
				; 2 = searching for address while compiling

L7901:	DB 0			; contains error from abort compilation

L7902:	DW 0
L7904:	DW 0			; code start address
L7906:	DW 0			; code end address
L7908:	DW 0			; data start address
L790A:	DW 0			; data end address
L790C:	DB 0
	DB 0

;L790E:	 DB 0			 ; 0 = read text from memory
;				 ;NZ = read text from include file

;	 ; FCB
;L790F:	 DB 0,'DUMMY   FCB'
;	 DS 36			 ; used as FCB

CODEFILE:
         db 1 + 64 dup (0)

CODEFILEPOS:
         DW 0
         DW 0

CODEFILESTART:
         DW 0
         DW 0

	; FCB
L7933:   DB 0                       ; used as FCB
L7934:	db 8 dup (0)			; file name
L793C:	DB 0
L793D:	DB 0
	DB 0
	db 21 dup (0)
L7954:   DW 0                       ; block count
	DB 0

L7961    EQU $+10


CODEFILEBUFFERSIZE         EQU 1024

CODEFILEBUFFERPOS:         DW 0
CODEFILEBUFFER:            db CODEFILEBUFFERSIZE dup (0)

CODEFILECREATED:           DB 0     ; 0 = no code file created
                                    ;NZ = code file created


;L7957:   DS 128                     ; used as FCB or 128 byte text buffer
;
L79D7:	db 128 dup (0)			; buffer, line buffer

L7A57:	db 128 dup (0)

L7AD7:	db 128 dup (0)

	; buffer of 13 bytes that is placed on the stack
L7B57:	DB 0
L7B58:	DB 0
L7B59:	DB 0
L7B5A:	DB 0
	DB 0
	; buffer of 8 bytes where id info is placed
L7B5C:	DB 0			; type
L7B5D:	DB 0
L7B5E:	DB 0
	DB 0
L7B60:	DB 0
	DB 0
L7B62:	DB 0			; length
	DB 0

L7B64:	DB 0
L7B65:	DB 0
	DB 0
	DB 0
	DB 0
L7B69:	DB 0
	DB 0
L7B6B:	DB 0
	DB 0
L7B6D:	DB 0
	DB 0
L7B6F:	DB 0
	DB 0
L7B71:	DB 0			; stack pointer saved at entering the compiler
L7B72:	DB 0
L7B73:	DB 0
L7B74:	DB 0
L7B75:	DB 0
	DB 0
L7B77:	DW 0
L7B79:	DW 0
L7B7B:	DB 0
	DB 0

L7B7D:	DB 0
	DB 0
L7B7F:	DB 0
	DB 0
L7B81:	DB 0
	DB 0
L7B83:	DB 0
	DB 0
L7B85:	DB 0
	DB 0
L7B87:	DB 0
L7B88:	DB 0
L7B89:	DB 0
	DB 0

L7B8B:	DW 0

L7B8D:	DB 0
	DB 0
L7B8F:	DB 0			; 0 = no VAR, 255 = VAR
L7B90:	DB 0			; 0 = not absolute, 255 = absolute
L7B91:	DB 0
L7B92:	DB 0
L7B93:	DB 0			; current type used by SCALARS
				; starts at 16
L7B94:	DB 0
L7B95:	DB 0

L7B96:	DB 0			; number of the overlay file
				; FILE.001
				; FILE.002
				; etc.

L7B97:   DB 0                       ; 0 = procedure, 1 = function
L7B98:	DB 0
L7B99:	DB 0
L7B9A:	DB 0
L7B9B:	DB 0
L7B9C:	DB 0

L7B9D:	DB 0			; compiler directive flags
				; bit 0: 1 = I/O Error Handling
				; bit 1: 1 = Index Range Check
				; bit 2: 1 = Absolute Code
				; bit 3: 1 = User Interrupt
				; bit 4: 1 = Array Optimization
				; bit 5: 1 = Var-parameter Type Checking
				; bit 6: 1 = I/O Mode Selection
				; bit 7: 1 = Control C and S interpretation
L7B9E:	DB 0			; saved compiler directives
L7B9F:	DB 0			; saved compiler directives

L7BA0:	DB 0
L7BA1:	DB 0			; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign
L7BA2:	DB 0			; end of file found flag
L7BA3:	DB 0
L7BA4:	DB 0
	DB 0
L7BA6:	DB 0
L7BA7:	DB 0
	DB 0
L7BA9:	DW 0			; used to save current text pointer
				; because library call that uses IX
L7BAB:	DB 0
	DB 0
	DB 0
	DB 0
	DB 0

L7BB0:   DB 0                       ; length of largest part
	DB 0

L7BB2:	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
L7BBD:	DB 0
L7BBE:	DB 0
	DB 0
L7BC0:	DB 0

L7BC1:	DB 0
L7BC2:	DB 0
	DB 0
L7BC4:	DB 0
	DB 0
L7BC6:	DB 0
WITHDEPTH:DB 0			; initial value at 4
L7BC8:	DB 0
L7BC9:	DB 0
L7BCA:	DB 0
	DB 0

L7BCC:	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
L7BD5:	DB 0
	DB 0

;L7BD7:	 DW 0			 ; text pointer of text in memory
;L7BD9:	 DB 0
;	 DB 0

L7BDB:	DB 0			; bit 0 = '0': block already read
				; bit 1 = '0': block is not dirty

;L7BDC:   DB 0                       ; index to current block

L7BDD:	DW 0			; first block of current part

L7BDF:	DW 0			; start of free area
L7BE1:	DW 0			; start of free area + 1024
L7BE3:	DB 0

L7BF1:	DB 0
L7BF2:	DB 0
L7BF3:	DW 0

TABLEINDEX2:
	; HL = tablename[index]
	; maximum of 128 indexes, 0 .. 127
	; in:	HL = table base address
	;	 A = table index, zero based
	; out:	HL = contents of index, word
	; changes: AF
	DB 087h

	DB 085h
	DB 30h,(TABLEINDEX2_1)-$-1
	DB 24h
TABLEINDEX2_1:
	DB 6fh

	DB 7eh
	DB 23h
	DB 66h
	DB 6fh
	DB 0c9h

COMPAREHL_DE:
	; compares HL with DE, by subtraction HL - DE
	; in:	HL, DE
	; out:	Carry, if HL < DE
	;	Zero, if HL == DE
	;	Zero and NonCarry, if HL >= DE
	; changes: AF
	DB 7ch
	DB 092h
	DB 0c0h
	DB 7dh
	DB 093h
	DB 0c9h

MINIMUMHL_DE:
	; in:	HL, DE
	; out:	HL = minimum value, DE = maximum value
	DB 0cdh
	DW  COMPAREHL_DE
	DB 0d8h			; quit if HL = minimum (HL < DE)

	DB 0ebh 		; swap values
	DB 0c9h

FILEINFOENTRYADDRESS:
	; in:	A = include level, 0 .. FileLevels - 1
	; out:	HL = address of info within FileInfo table
	DB 11h
	DW FILEINFOENTRYSIZE

	DB 21h
	DW FILEINFO

FILEINFOENTRYADDRESS1:
	DB 0b7h
	DB 0c8h
	DB 3dh
	DB 019h
	DB 18h,( FILEINFOENTRYADDRESS1)-$-1

GONEXTFILELEVEL:
	; in:	HL = address of filename of text file

	; push default extension 'INC'
	DB 3eh,'I'
	DB 01h
	DW 'N'*256+'C'
	DB 0f5h
	DB 0c5h

	DB 0e5h

	DB 02ah
	DW FILEBUFFERCOUNT
	DB 11h
	DW FILELEVELMINIMUM
	DB 0b7h
	DB 0EDH,052h		; HL = number of lost bytes
	DB 28h,(GONEXTFILELEVELNOLOSS)-$-1 ; jump if Count = 0
	DB 38h,(GONEXTFILELEVELNOLOSS)-$-1 ; jump if Count < 1024

	DB 44h			; BC = number of lost bytes
	DB 4dh

	DB 0c5h
	DB 01h
	DW FILECURRENTINFO
	DB 0cdh
	DW  FILEPOS
	DB 0c1h

	DB 0b7h
	DB 0EDH,042h		; subtract loss from low-word
	DB 30h,(GONEXTFILELEVEL0)-$-1

	DB 1bh			; decrease high-word

GONEXTFILELEVEL0:
	DB 01h
	DW FILECURRENTINFO
	DB 0cdh
	DW  FILESEEK		; set file position back with the number
				; of lost bytes

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 84H			; error 132: error seeking file

GONEXTFILELEVELNOLOSS:

	DB 02ah
	DW FILEBUFFERCOUNT
	DB 11h
	DW FILELEVELMINIMUM	; 1024 = minimum size used by a file
	DB 0cdh
	DW  MINIMUMHL_DE
	; LD (FileBufferSize),HL	  ; set new size
	DB 22h
	DW FILEBUFFERCOUNT	; set new count

	DB 44h			; BC = HL = count
	DB 4dh
	DB 02ah
	DW FILEBUFFERPOS
	DB 0edh,5bh
	DW FILEBUFFERSTART
	DB 0d5h

	DB 0edh,0b0h			; move to start of buffer

	DB 0e1h
	DB 22h
	DW FILEBUFFERPOS	; buffer pos = buffer start

	DB 0d5h			; save buffer start for next level

	DB 3ah
	DW FILELEVEL
	DB 0cdh
	DW  FILEINFOENTRYADDRESS
	DB 0ebh 		; DE = address where to save current info
	DB 21h
	DW FILEINFOENTRYSTART
	DB 01h
	DW FILEINFOENTRYSIZE
	DB 0edh,0b0h			; save current entry in table

	DB 21h
	DW FILELEVEL
	DB 034h 		; go to next include level

GONEXTFILELEVEL1:
	DB 0e1h
	DB 22h
	DW FILEBUFFERSTART	; set new buffer start
	DB 22h
	DW FILEBUFFERPOS	; set new buffer pos

	DB 0ebh
	DB 21h
	DW FILEBUFFEREND
	DB 0b7h
	DB 0EDH,052h		; HL = size for new buffer
	DB 22h
	DW FILEBUFFERSIZE

	DB 11h
	DW FILECURRENTINFO

	DB 0e1h			; DE = address of filename to parse

	DB 0c1h
	DB 0f1h
	DB 0cdh
	DW  OPENFILE

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 5AH			; error 90: File not found

	DB 21h
	DW 0
	DB 22h
	DW FILEBUFFERLINE	; start at line 0

	DB 0cdh
	DW  FILEREADBUFFER

	DB 7ch
	DB 0b5h
	DB 0c0h			; quit if some bytes read

GOPREVIOUSFILELEVEL:
; 33e    LD BC,FileCurrentInfo
; 33e    CALL CloseFile             ; close the current file

; 33e    CALL L72DA                 ; NonZero --> error
; 33e    DB 85H                     ; error 133: error closing file

	DB 21h
	DW FILELEVEL
	DB 035h 		; decrease level
	DB 7eh
	DB 0cdh
	DW  FILEINFOENTRYADDRESS
	DB 11h
	DW FILEINFOENTRYSTART
	DB 01h
	DW FILEINFOENTRYSIZE
	DB 0edh,0b0h			; restore to previous level
	DB 0c9h

FILEREADBUFFER:
	; in:	-
	; out:	HL = bytes read from file

	DB 02ah
	DW FILEBUFFERSIZE
	DB 0edh,5bh
	DW FILEBUFFERSTART
	DW 53edh,FILEBUFFERPOS
	DB 01h
	DW FILECURRENTINFO	; handle/FCB address
         DB 0cdh
	DW  READFILE
	DB 22h
	DW FILEBUFFERCOUNT

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 83H			; error 131: error reading file

	DB 7ch
	DB 0b5h
	DB 0c0h			; quit if something was read

	DB 02ah
	DW FILEBUFFERSTART
	DB 36h,1AH		; place end of file marker (^Z)
	DB 21h
	DW 1
	DB 22h
	DW FILEBUFFERCOUNT	; count = 1

	DB 0c9h

FILEINIT:
	; in:	HL = address of filename of text file

	; push default extension 'PAS'
	DB 3eh,'P'
	DB 01h
	DW 'A'*256+'S'
	DB 0f5h
	DB 0c5h

	DB 0e5h
	DB 0afh
	DB 32h
	DW FILELEVEL
	DB 21h
	DW FILEBUFFER
	DB 0e5h
	DB 0c3h
	DW  GONEXTFILELEVEL1

TOTALFILEBUFFERSIZE EQU 8192        ; 8 KByte
FILELEVELMINIMUM  EQU 1024
MAXFILELEVELS	EQU 4		; levels 0 - 3

TEMPFILEDATA:     db 1 + 64 dup (0)

TOTALLINES:	DW 0
FILELEVEL:	DB 0		; current include level, 0 default

FILEINFOENTRYSTART:

FILECURRENTINFO:  db 1 + 64 dup (0)         ; DOS 1: 37 byte FCB
				; DOS 2: handle, 63 bytes name, '\0'
FILEBUFFERLINE:	DW 0		; current line number in text file
FILEBUFFERLASTPOS:DW 0		; starting position of last read item
FILEBUFFERSTART:	DW FILEBUFFER	; start of current file buffer, address
FILEBUFFERPOS:	DW FILEBUFFER	; address of next byte to read
FILEBUFFERCOUNT:	DW 0		; bytes left in current buffer
FILEBUFFERSIZE:	DW TOTALFILEBUFFERSIZE ; size in bytes of current buffer

FILEINFOENTRYSIZE EQU $-FILEINFOENTRYSTART ; size never greater than 128 !!

FILEINFO:
	db FILEINFOENTRYSIZE * MAXFILELEVELS dup (0)

FILEBUFFER:
	db TOTALFILEBUFFERSIZE dup (0)
FILEBUFFEREND:

;         DB 'EXTRA'
; L90FC:   DW 0                       ; 33e TODO, L90FC

         END

