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

         JMP near ptr  L215E

;File1:   DB 'TEST.',0,0,0,0,0,0,0,0,0,0
;File2:   DB '\E',0,0,0,0,0,0,0,0,0,0
;File3:   DB 'E\E',0,0,0,0,0,0,0,0,0,0
;File4:   DB 'DIR.PAS',0,0,0,0,0,0,0,0,0,0
;File5:   DB 'TEST.PAS',0,0,0,0,0,0,0,0,0,0

PRINT_SYNTAX:
	CALL near ptr L0200
         DB 'Syntax: TURBO <filename> [/C|/H] [/Sxxxx] [/Exxxx] [/Fxxxx]'
; 33e         DB ' [/R[-|<file>]]'
         DB 13,10
	DB '/C            compiles <filename> to COM-file',13,10
	DB '/H            compiles <filename> to CHAIN-file',13,10
	DB '/Sxxxx        code start address (hexadecimal), min. ',0

	MOV bx,offset _L20E2
	CALL near ptr L04AF

	CALL near ptr L0200
	DB 13,10
	DB '/Exxxx        data end address (hexadecimal), max. ',0

IFDEF MSX
	MOV bx,word ptr 0006H
ELSE
	MOV bx,word ptr L0006
ENDIF
	MOV cx,-708
	ADD bx,cx
	CALL near ptr L04AF

	CALL near ptr L0200
	DB 13,10
	DB '/Fxxxx        find runtime error at address xxxx (hexadecimal)',13,10
	DB '/R<file>      generates this error file with a compiler error',13,10
	DB '/R-           generates no error file'
	DB 13,10
	DB 0			; end of string

	MOV cl,0
	CALL near ptr MSXDOS		; quit program


GETPARAMERRORFILENAME:
	CALL near ptr L0200
	DB 10,'commandline: wrong error file name',13,10,10,0
	JMP near ptr  PRINT_SYNTAX

GETPARAMHEXNUMBER:
	CALL near ptr L0200
	DB 10,'commandline: error in hexadecimal number',13,10,10,0
	JMP near ptr  PRINT_SYNTAX

GETPARAMUNKNOWNOPTION:
	CALL near ptr L0200
	DB 10,'commandline: illegal option',13,10,10,0
	JMP near ptr  PRINT_SYNTAX

GETPARAM:; in:    -
	; out:	DE = destination for file name
	;	Carry set if error occurred
	;	BC = position of error
	PUSH dx

         MOV bx,offset L0080
	MOV dl,byte ptr [bx]
	INC dl
	MOV dh,0
	ADD bx,dx

         XOR al, al
	MOV byte ptr [bx],al		; quit command-line with a '\0'

	MOV al,dl
	DEC al			; was it 1 ?
	STC

	POP dx

	RETZ 			; quit with Carry if command-line = empty

	MOV bx,offset L0080+1		; start of command-line
	MOV al,'P'
	MOV cx,'A'*256+'S'
	CALL near ptr PARSENAME		; parse with default extension 'PAS'

         OR al, al
         STC
         RETNZ                      ; quit with carry if error occurred

         PUSH bx

	MOV bx,offset L0080+1
	MOV dx,offset ERRORFILENAME-1
	MOV al,'E'
	MOV cx,'R'*256+'R'
	CALL near ptr PARSENAME		; parse with default extension 'ERR'

         POP bx

	OR al, al
	STC
         RETNZ                      ; quit with carry if error occurred

	DEC bx
	MOV ch,bh
	MOV cl,bl

	MOV bx,offset ERRORFILENAME
GETPAR_A:
	INC bx
	MOV al,byte ptr [bx]
	OR al, al
	JNZ near ptr GETPAR_A		; repeat while not end of string

GETPAR_B:
	DEC bx
	MOV al,byte ptr [bx]
	CMP al, '.'
	JNZ near ptr GETPAR_B

	INC bx

	; add '.ERR'
	MOV byte ptr [bx],'E'
	INC bx
	MOV byte ptr [bx],'R'
	INC bx
	MOV byte ptr [bx],'R'
	INC bx
	MOV byte ptr [bx],0

GETPARLP:INC cx
	xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
	OR al, al
	RETZ 			; quit with NonCarry if zero found

	CMP al, '/'
	JNZ near ptr GETPARLP

GETPAR1:
	INC cx
	xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
	CALL near ptr UPCASE

	CMP al, 'C'                     ; '/C' ?
	JNZ near ptr GETPAR2		; no, next

	; set COM file = TRUE
	MOV al,2			; compile to Com-file
	MOV byte ptr L44F3,al
	JMP near ptr  GETPARLP

GETPAR2:
	CMP al, 'H'                     ; '/H' ?
	JNZ near ptr GETPAR3		; no, next

	; set CHAIN file = TRUE
	MOV al,3			; compile to cHn-file
	MOV byte ptr L44F3,al
	JMP near ptr  GETPARLP

GETPAR3:
	CMP al, 'S'                     ; '/S' ?
	JNZ near ptr GETPAR4		; no, next

	CALL near ptr GETHEX		; parse hexadecimal number
	JC near ptr GETPARAMHEXNUMBER

	; set start address = HL
	MOV word ptr L44F4,bx
	DEC cx
	JMP near ptr  GETPARLP

GETPAR4:
	CMP al, 'E'                     ; '/E' ?
	JNZ near ptr GETPAR5		; no, next

	CALL near ptr GETHEX		; parse hexadecimal number
	JC near ptr GETPARAMHEXNUMBER

	; set end address = HL
	MOV word ptr L44F6,bx
	DEC cx
	JMP near ptr  GETPARLP

GETPAR5:
	CMP al, 'R'                     ; '/R' ?
	JNZ near ptr GETPAR6

	; parse filename or '-'
	INC cx
	xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
	CMP al, '-'                     ; '/R-' ?
	JZ near ptr GETPAR51		; jump for no error file

	; file name is given
	; set to string after '/R'
	PUSH cx			; save start address

	MOV bh,ch			; HL = BC = start of new file name
	MOV bl,cl
	MOV dx,offset ERRORFILEINFO
	MOV al,'E'
	MOV cx,'R'*256+'R'
	CALL near ptr PARSENAME

	POP dx			; DE = start address
	JC near ptr GETPARAMERRORFILENAME

	PUSH bx

	OR al, al
	SBB bx,dx		; HL - DE, end - start
	MOV ch,bh			; BC = length
	MOV cl,bl
	MOV bx,offset ERRORFILENAME
	XCHG dx,bx 		; HL = source
				; DE = destination
	CALL __LDIR			; fill ErrorFileName with new name

	XOR al, al
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx		; mark end of destination file name

	POP bx			; HL = address after file name

	MOV ch,bh			; BC = address after file name
	MOV cl,bl
	JMP near ptr  GETPARLP

GETPAR51:; no error file
	; set file name to ""
	MOV bx,offset ERRORFILENAME
	MOV byte ptr [bx],0		; clear file name
	JMP near ptr  GETPARLP

GETPAR6:
	CMP al, 'F'                     ; '/F' ?
	STC
         JNZ near ptr GETPARAMUNKNOWNOPTION

	CALL near ptr GETHEX		; parse hexadecimal number
	JC near ptr GETPARAMHEXNUMBER

	; set search address = HL
	MOV word ptr L00CE,bx
	MOV al,2
	MOV byte ptr L7900,al		; compilation with search
	DEC cx
	JMP near ptr  GETPARLP

GETHEX:
	MOV bx,0

GETHEX1:
	INC cx
	xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
	OR al, al
	RETZ 			; quit with NonCarry
	CMP al, ' '
	RETZ 			; quit with NonCarry

	DEC cx
	CMP al, '/'
	RETZ 			; quit with NonCarry
	INC cx

	CALL near ptr UPCASE

	SUB al, '0'
	RETC 			; error, no digit
	CMP al, 10
	CMC
	JNC near ptr GETHEX2		; jump if '0'-'9'

	SUB al, 7
	RETC 			; error, no digit and < 'A'
	CMP al, 16
	CMC
	RETC 			; return with Carry if >= 16

GETHEX2:
	ADD bx,bx
	ADD bx,bx
	ADD bx,bx
	ADD bx,bx
	OR al, bl
	MOV bl,al

	JMP near ptr  GETHEX1

L20E5:
IFDEF MSX
	MOV bx,word ptr 0006H
ELSE
	MOV bx,word ptr L0006
ENDIF
	POP cx
	MOV sp,bx
	PUSH cx

	MOV dx,-1024
	ADD bx,dx
         MOV word ptr L4548,bx              ; highest free address 1Kbyte below call 5

L20F2:	MOV bx,offset L7AD7		; address of temp buffer (L00D2)
	MOV cx,0000
         CALL near ptr L0364                 ; LIB

	RET

L215E:
IFDEF MSX
	MOV bx,word ptr 0006H
ELSE
	MOV bx,word ptr L0006
ENDIF
	MOV cx,-708
	ADD bx,cx

	MOV word ptr L44F6,bx		; compile end address

         CALL near ptr INITFILEIO

	CALL near ptr L0200
IFDEF MSX
         DB 'Z80 TURBO Pascal compiler,             Version 3.3f (DOS 1/2) ',13,10
ELSE
         DB 'Z80 TURBO Pascal cross-compiler,       Version 3.3f ',13,10
ENDIF
         DB 'Copyright (C) MSX computer club Enschede, ''1993-''2000',13,10
	DB 0

	MOV dx,offset L7AD7		; address of temp buffer
	XOR al, al
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         CALL near ptr GETPARAM              ; get command line parameters
	JC near ptr PRINT_SYNTAX 	; print syntax if error and quit program

	MOV cl,19H
	CALL near ptr MSXDOS		; get logged drive
	INC al
	MOV byte ptr LOGDRV,al		; 1 = A:, 2 = B: etc.
         CALL near ptr L20E5

         MOV al,'P'
         MOV cx,'A'*256+'S'
         MOV bx,offset L7AD7+1
         OR al, al
         CALL near ptr SETEXTENSION

         MOV bx,offset L7AD7+1              ; address of filename
         MOV dx,offset L451D                ; DE = handle/FCB address
         MOV al,'P'
         MOV cx,'A'*256+'S'
         CALL near ptr PARSENAME             ; parse filename

         CALL near ptr L2827                 ; Compile

L223B:	CALL near ptr L01E1		; print CR, LF

	MOV cl,0
	CALL near ptr MSXDOS


L232E:	CALL near ptr L0200
	DB 'Free: ',0

L2338:	PUSH bx
	PUSH dx
	OR al, al
	SBB bx,dx
	CALL near ptr L2E5C		; print HL in decimal
	CALL near ptr L0200
	DB ' bytes (',0
	POP bx
	CALL near ptr L04AF
	MOV al,'-'
	CALL near ptr L03C9		; print '-'
	POP bx
	CALL near ptr L04AF
	MOV al,')'
	CALL near ptr L03C9		; print ')'
	JMP near ptr  L01E1 		; print CR, LF

ENVTPOUT:DB 'TPOUT',0

L27D7:

;         LD HL,L451D                ; assume work filename FCB
;         LD DE,CodeFile
;         LD BC,65                   ; handle/FCB length
;         LDIR

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JZ near ptr TPOUT_OLD_STYLE       ; jump if DOS 1

         ; DOS 2

         MOV al,byte ptr L451D
         MOV byte ptr CODEFILE,al

         MOV bx,offset ENVTPOUT
         MOV dx,offset CODEFILE + 1
         MOV ch,64
         MOV cl,6Bh
         CALL near ptr MSXDOS                ; retrieve TPOUT environment item value
         OR al, al
         JNZ near ptr TPOUT_OLD_STYLE      ; switch to the old style if error occurred

TPOUT_SCAN:
         xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
         OR al, al
         JZ near ptr TPOUT_SCAN_END

         INC dx
         JMP near ptr  TPOUT_SCAN

TPOUT_SCAN_END:
         MOV bx,offset L451D + 1

TPOUT_COPY:
         MOV al,byte ptr [bx]
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         INC bx
         INC dx
         OR al, al
         JNZ near ptr TPOUT_COPY

         JMP near ptr  L27D9                   ; ready

TPOUT_OLD_STYLE:
         MOV bx,offset L451D                ; assume work filename FCB

         MOV dx,offset CODEFILE

         MOV cx,65                   ; handle/FCB length
         CALL __LDIR

L27D9:
IFDEF MSX
	MOV bx,word ptr 0006H
ELSE
	MOV bx,word ptr L0006
ENDIF
	MOV word ptr L790A,bx		; HL = end of data area

	MOV bx,word ptr L4546		; HL = start of free area
	MOV word ptr L7904,bx		; code start address
	RET

L2827:   ; Compile
         CALL near ptr L27D7

	MOV al,byte ptr L44F3
	SUB al, 2			; to com-file ? (= 2)
;	 DEC A			 ; to memory?
;	 JP Z,L28AA		 ; jump if to memory

;	 DEC A			 ; to com-file?
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	JNZ near ptr L283C		; jump if chain-file

	; to com-file
	MOV al,'C'                   ; AHL = 'COM' extension
         MOV cx,'O'*256+'M'
	JMP near ptr  L2841

L283C:	; to chain-file
	MOV al,'C'                   ; AHL = 'CHN' extension
         MOV cx,'H'*256+'N'

L2841:   MOV bx,offset CODEFILE+1
         STC                        ; overrule
         CALL near ptr SETEXTENSION

;         LD (L793C),A
;         LD (L793D),HL

	MOV al,byte ptr L7900
	OR al, al
	JNZ near ptr L2842		; skip if already filled in for search

	MOV al,1
	MOV byte ptr L7900,al		; code generation to disk
L2842:

	MOV bx,word ptr L44F4		; compile start address
	MOV word ptr L7904,bx		; new code start address
	MOV bx,word ptr L44F6		; compile end address
	MOV word ptr L790A,bx		; new data end address
         MOV bx,word ptr L44F4              ; 33e
         MOV word ptr L7BF5+1,bx            ; 33e TODO

         XOR al, al
         MOV byte ptr CODEFILECREATED,al

         MOV al,byte ptr L7900
         DEC al
         JNZ near ptr L2850                ; skip CodeFile creation if searching

         MOV dx,offset CODEFILE+1
         CALL near ptr DELETEFILE            ; delete old file

         MOV bx,offset CODEFILE+1
         MOV dx,offset CODEFILE
         MOV al,' '
         MOV cx,' '*256+' '
         CALL near ptr CREATEFILE
         OR al, al
         JNZ near ptr L2A5A                ; jump if error
                                    ; error: Disk or directory full

         MOV al,255
         MOV byte ptr CODEFILECREATED,al     ; CodeFile correct created

L2850:

;         LD HL,L7933+FCB_RECSIZE
;         LD (HL),80H                ; record size = 128
;         INC HL
;         LD (HL),0

	POP ax
	xchg ah,al
	sahf			; NonZero if chain-file
	MOV bx,offset L0100
	JZ near ptr L2877		; jump if com-file

	MOV bx,word ptr L7904		; HL = code start address

L2877:	MOV word ptr L7902,bx
	XCHG dx,bx

L287B:	MOV bx,word ptr L7904		; HL = code start address
         OR al, al
         SBB bx,dx                  ; HL - DE
         JC near ptr L28A9                 ; jump if DE > HL

         MOV al,byte ptr L7900
         DEC al
         JNZ near ptr L28A9                ; jump if searching
                                    ; don't write runtime library

         MOV cx,offset CODEFILE

;         LD HL,(L7904)              ; HL = compile start address
;         LD (L0101),HL              ; init start jump at 100H

;         PUSH BC

         PUSH bx                    ; DE = start address of data
         MOV bx,offset L7BF5-100H           ; !!!
	ADD bx,dx
	XCHG dx,bx
         POP bx

         CALL near ptr WRITEFILE

         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALLNZ CLEANUPCODEFILE
         POP ax
	xchg ah,al
	sahf
         OR al, al
         JNZ near ptr L2A5A                ; jump if error
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
	CALL near ptr L0200
	DB 0DH,0AH,'Compiling ',0

;         LD DE,L7933

         MOV dx,offset L451D                ; 33e TODO
         CALL near ptr PRINTFILENAME

         MOV al,byte ptr L7900
         DEC al
         JNZ near ptr L28D0                ; jump if searching
                                    ; don't print '--> <filename>'

         CALL near ptr L0200
	DB ' --> ',0

         MOV dx,offset CODEFILE
         CALL near ptr PRINTFILENAME
;         CALL L2DF8                 ; print file name in DE

L28D0:	CALL near ptr L01E1		; print CR, LF

IFDEF MSX
	MOV bx,0
	MOV word ptr 0FC9EH,bx
ENDIF
         CALL near ptr L454A                 ; enter the real compiler

IFDEF MSX
IFDEF USETIMER
         MOV bx,word ptr 0FC9EH
         PUSH bx
ENDIF    ; USETIMER
ENDIF    ; MSX

	MOV al,byte ptr L7901
	CMP al, 0CAH			; abort compilation error, keypressed
         JNZ near ptr L28FA                ; no, continue

         MOV al,byte ptr L7900
         DEC al

         CALLZ CLEANUPCODEFILE     ; clean mess up if a '.COM' file
                                    ; was generated, if no search was performed


         CALL near ptr L0200
	DB 0DH,0AH,0AH,'Compilation aborted',0
	JMP near ptr  L223B 		; print CR, LF and go to DOS

CLEANUPCODEFILE:
         MOV al,byte ptr CODEFILECREATED
         OR al, al
         RETZ                       ; quit if no CodeFile created

         MOV cx,offset CODEFILE
         CALL near ptr CLOSEFILE             ; try to close the file first

         MOV dx,offset CODEFILE+1
         JMP near ptr  DELETEFILE

L28FA:
         CALL near ptr L0200
	DB 0DH,0AH,0

IFDEF MSX
IFDEF USETIMER
         CALL near ptr L0200
         DB 'Time: ',0

         POP bx
         CALL near ptr L2E5C                 ; print HL in 5 decimals

         CALL near ptr L0200
         DB 0DH,0AH,0
ENDIF    ; USETIMER
ENDIF    ; MSX

	MOV al,byte ptr L7901
	OR al, al
	JNZ near ptr L2970		; jump if error occurred during compiling

         MOV al,byte ptr L7900
	CMP al, 2			; searching while compiling?
         JNZ near ptr L292A                ; no, skip checking

	CALL near ptr L2A7A		; print 'Run-time error position '

	CALL near ptr L0200
	DB 'not found',0DH,0AH,0
	JMP near ptr  L223B 		; print CR, LF and go to DOS

L292A:
	MOV bx,word ptr L7904		; HL = code start address
	MOV dx,offset _L20E2		; DE = first available address
	OR al, al
	SBB bx,dx
	pushf
	ADD bx,dx
	popf
	CALLNZ L232E		; print free memory between
				; _L20E2 and compile start address
				; if it is there
         CALL near ptr L0200
	DB 'Code: ',0
	MOV dx,word ptr L7904		; DE = code start address
	MOV bx,word ptr L7906		; HL = code end address
	PUSH bx
	DEC bx
	CALL near ptr L2338
	POP dx
	MOV bx,word ptr L7908		; HL = data start address
	PUSH bx
	CALL near ptr L232E
	POP dx
	INC dx			; DE = data start address
	MOV bx,word ptr L790A		; HL = data end address
	CALL near ptr L0200
	DB 'Data: ',0
         CALL near ptr L2338

	MOV al,0FFH
	MOV byte ptr COMPILED,al		; compilation completed
	RET

	DB 0			; hoort bij ErrorFileName
ERRORFILENAME:
	DB 'TURBO.ERR',0           ; 10 bytes
	db 65-10 dup (0)

ERRORFILEPTR:
	DW L7A57
ERRORFILEINFO:
	db 65 dup (0)

ERRORFILEWRITE:
	POP si			; HL = return address
	POP cx			;  C = character to print
	MOV bx,word ptr ERRORFILEPTR
	MOV byte ptr [bx],cl
	INC bx
	MOV word ptr ERRORFILEPTR,bx
	JMP si

ERRORFILEMAKE:
	MOV bx,word ptr CON1OUTPTR
	PUSH bx			; save old routine
	MOV bx,offset ERRORFILEWRITE
	MOV word ptr CON1OUTPTR,bx

	MOV bx,offset ERRORFILENAME
	MOV dx,offset ERRORFILEINFO
	MOV al,' '
	MOV cx,' '*256+' '
	CALL near ptr CREATEFILE
	JNZ near ptr ERRORFILEMAKE1

	MOV dx,offset FILECURRENTINFO
         CALL near ptr PRINTFILENAME
	CALL near ptr L01E1		; print CR, LF

	MOV bx,word ptr FILEBUFFERLINE
	CALL near ptr L2E61		; print line number
	CALL near ptr L01E1		; print CR, LF

	CALL near ptr GETCOLUMNNUMBER
	MOV bl,ch
	MOV bh,0
	CALL near ptr L2E61		; print column number
	CALL near ptr L01E1		; print CR, LF

	MOV bx,word ptr L7901
	MOV bh,0
	CALL near ptr L2E61		; print error number
	CALL near ptr L01E1		; print CR, LF

	MOV al,byte ptr L7901
	MOV ch,al
	CALL near ptr PRINTERRORMESSAGE
	CALL near ptr L01E1		; print CR, LF

	MOV al,1AH
	CALL near ptr L03C9

	MOV bx,word ptr ERRORFILEPTR
	MOV cx,offset L7A57
	OR al, al
	SBB bx,cx		; HL = length of data to write

	MOV cx,offset ERRORFILEINFO
	MOV dx,offset L7A57
	CALL near ptr WRITEFILE		; write to error file
	JNZ near ptr ERRORFILEMAKE1

	MOV cx,offset ERRORFILEINFO
	CALL near ptr CLOSEFILE

ERRORFILEMAKE1:
	POP bx
	MOV word ptr CON1OUTPTR,bx	; restore old routine
	RET

GETCOLUMNNUMBER:
	MOV ch,1			; start at column 1
	MOV bx,offset L79D7		; start of line buffer
	MOV dx,word ptr FILEBUFFERLASTPOS

GETCOLUMNNUMBER1:
	CALL near ptr COMPAREHL_DE
	RETNC 			; quit if end found

	MOV al,byte ptr [bx]
	INC bx
	CMP al, 9
	JZ near ptr GETCOLUMNNUMBERTAB	; TAB stop found

	DEC ch
	CMP al, 8
	JZ near ptr GETCOLUMNNUMBER1	; BackSpace found
	INC ch

	INC ch
	JMP near ptr  GETCOLUMNNUMBER1

GETCOLUMNNUMBERTAB:
	MOV al,ch
	DEC al
	AND al, 7
	NEG al
	ADD al,8
	ADD al,ch
	MOV ch,al
	JMP near ptr  GETCOLUMNNUMBER1

EXPANDLINE:
	; in:	DE = destination for expanded line buffer
	MOV bx,offset L79D7		; start of line buffer
	MOV ch,1			; start at column 1

EXPANDLINE1:
	MOV al,byte ptr [bx]
	INC bx

	OR al, al
	JZ near ptr ENDOFLINE

	CMP al, 9
	JNZ near ptr EXPANDLINE2

	CALL near ptr PRINTTAB		; print spaces
	JMP near ptr  EXPANDLINE1

EXPANDLINE2:
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	INC dx

	INC ch			; next column
	JMP near ptr  EXPANDLINE1

ENDOFLINE:
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	RET


PRINTTAB:; in:	DE = address where to put spaces
	;	B = current column, 1 .. 80
	; out:	DE = address after the new spaces
	;	B = new column
	MOV al,ch
	DEC al
	AND al, 7
	NEG al
	ADD al,8
	MOV cl,al
	ADD al,ch
	MOV ch,al

PRINTTAB1:
	MOV al,' '
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	INC dx

	DEC cl
	JNZ near ptr PRINTTAB1

	RET

SCANLEFTRIGHT:
	; in:	D = left column >= 1
	;	E = total size
	;	B = total chars permitted to the left
	;	C = total chars left
	MOV al,dh
	CMP al, 1
	JZ near ptr SCANLEFTRIGHT1

	MOV al,ch
	OR al, al
	JZ near ptr SCANLEFTRIGHT1
	DEC ch			; decrease maximum before

	DEC dh			; one more to the left
	INC dl
	DEC cl			; decrease chars left
	RETZ 

	JMP near ptr  SCANLEFTRIGHT2

SCANLEFTRIGHT1:
	MOV al,dl
	CMP al, 79
	RETZ 			; quit if both at the border

SCANLEFTRIGHT2:
	MOV al,dl
	CMP al, 79
	JZ near ptr SCANLEFTRIGHT	; continue with other side

	INC dl			; one more to the right
	DEC cl			; decrease chars left
	RETZ 

	JMP near ptr  SCANLEFTRIGHT

L2970:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr CLEANUPCODEFILE       ; clean mess up if a '.COM' file
                                    ; was generated, if no search was performed
         POP ax
	xchg ah,al
	sahf

         CMP al, 0FAH                    ; error 250: Disk or directory full
         JNC near ptr L2A5A
	CMP al, 0C8H			; error 200: run-time error address found
	JNC near ptr L29EC

	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	MOV dx,offset FILECURRENTINFO
	CALL near ptr PRINTFILENAME

	CALL near ptr L0200
	DB ', line ',0

	MOV bx,word ptr FILEBUFFERLINE
	CALL near ptr L2E61		; print current line number

	CALL near ptr L0200
	DB ', column ',0

	CALL near ptr GETCOLUMNNUMBER
	MOV bh,0
	MOV bl,ch
	CALL near ptr L2E61		; print column number

	CALL near ptr L01E1		; print CR, LF

	CALL near ptr PRINTCURRENTLINE

	POP ax
	xchg ah,al
	sahf

	MOV ch,al
	CALL near ptr L0200
	DB 'Error ',0
	MOV bh,0
	MOV bl,ch
	PUSH cx
	CALL near ptr L2E61		; print error number
	POP cx

	CALL near ptr L0200
	DB ': ',0

	CALL near ptr PRINTERRORMESSAGE
	JMP near ptr  L29F8

PRINTERRORMESSAGE:
	; in:	B = error code

	MOV bx,offset TURBOERRORMESSAGES

L2995:	MOV al,byte ptr [bx]
	CMP al, 1AH
	RETZ 			; quit if at end of messages

	CMP al, 20H
	JC near ptr L29AD

	SUB al, 30H
	MOV cl,al
	ADD al,al			; * 2
	ADD al,al			; * 4
	ADD al,cl			; * 5
	ADD al,al			; * 10
	INC bx
	ADD al,byte ptr [bx]
	SUB al, 30H
	INC bx
	CMP al, ch
	JZ near ptr L29B6

L29AD:	MOV al,byte ptr [bx]
	INC bx
	CMP al, 0DH
	JNZ near ptr L29AD
	INC bx			; skip LF (0Ah) code
	JMP near ptr  L2995

L29B6:

L29BC:	MOV al,byte ptr [bx]
	CMP al, 0DH
	RETZ 			; quit if the end was found

	CMP al, 20H			; < 32 ?
	JNC near ptr L29E6		; jump if it is printable

	MOV dx,offset TURBOERRORMESSAGES

L29C9:	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	INC dx
	CMP al, 20H
	JNC near ptr L29DD

	CMP al, byte ptr [bx]
	JNZ near ptr L29DD

L29D2:	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, 0DH
	JZ near ptr L29E9
	CALL near ptr L03C9		; print character
	INC dx
	JMP near ptr  L29D2

L29DD:	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	INC dx
	CMP al, 0DH
	JNZ near ptr L29DD
	INC dx
	JMP near ptr  L29C9

L29E6:	CALL near ptr L03C9		; print character

L29E9:	INC bx
	JMP near ptr  L29BC

L29EC:	CALL near ptr L2A7A
	CALL near ptr L0200
	DB 'found',0

L29F8:
	MOV al,'.'
	CALL near ptr L03C9		; print '.'

	MOV bx,offset ERRORFILENAME
	MOV al,byte ptr [bx]
	OR al, al
	CALLNZ ERRORFILEMAKE	; create error file if wanted

         JMP near ptr  L223B

PRINTCURRENTLINE:
	MOV dx,offset FILEBUFFER
	CALL near ptr EXPANDLINE		; expand all TABS in command line

	CALL near ptr GETCOLUMNNUMBER

	MOV dh,ch			; D = left column number
	MOV dl,0			; E = starting at a size of 0
	MOV cx,40*256+79
	CALL near ptr SCANLEFTRIGHT

	MOV al,dl
	OR al, al
	RETZ 			; quit if size = 0

	MOV ch,al			; B = length of chars to print

	PUSH dx
	MOV bl,dh
	MOV bh,0
	MOV dx,offset FILEBUFFER-1
	ADD bx,dx		; HL = start of first character

PRINTCURRENTLINE1:
	MOV al,byte ptr [bx]
	OR al, al
	JZ near ptr PRINTCURRENTLINE2	; quit if end of chars found

	CALL near ptr L03C9		; print char

	INC bx
	DEC ch
	JNZ near ptr PRINTCURRENTLINE1

PRINTCURRENTLINE2:
	CALL near ptr L01E1		; print CR, LF

	CALL near ptr GETCOLUMNNUMBER
	POP dx
	MOV al,ch
	SUB al, dh
	MOV ch,al
	INC ch

PRINTCURRENTLINE3:
	DEC ch
	JZ near ptr PRINTCURRENTLINE4

	MOV al,' '
	CALL near ptr L03C9		; print char

	JMP near ptr  PRINTCURRENTLINE3

PRINTCURRENTLINE4:
	MOV al,'^'
	CALL near ptr L03C9
	JMP near ptr  L01E1 	       ; print CR, LF

L2A5A:	CALL near ptr L0200
	DB 'Disk or directory full',0

         CALL near ptr L2E76                 ; wait for escape
	JMP near ptr  L223B

L2A7A:	CALL near ptr L0200
	DB 'Run-time error position ',0
L2A96:	RET


L2D01:   ; asks for Yes or No
	; out: NonZero if 'Y' or 'y' pressed
	;	 Zero if 'n' or 'n' pressed
	CALL near ptr L0200
	DB ' (Y/N)? ',0

L2D0D:   CALL near ptr L03E1                 ; readkey
	CALL near ptr L04A6		; upcase A
	CMP al, 'Y'
	JZ near ptr L2D1B
	CMP al, 'N'
	JNZ near ptr L2D0D

L2D1B:   CALL near ptr L03C9                 ; print character, choice
	SUB al, 'N'
	RET

L2D21:	CALL near ptr L2D01
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L01E1		; print CR, LF
	POP ax
	xchg ah,al
	sahf
	RET

L2E5C:   MOV dx,-5
	JMP near ptr  L2E64

L2E61:   MOV dx,-1

L2E64:	PUSH si
	PUSH di
	PUSH bx
	PUSH dx
	CALL near ptr L149B		; set and check for output
	POP bx
	CALL near ptr L1726
	POP di
	POP si
	RET

L2E76:   ; wait for escape
	; changes: -
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L0200
	DB '. Press <ESC>',0

L2E88:   CALL near ptr L03E1                 ; A = character from console
	CMP al, 1BH			; ESC pressed ?
	JNZ near ptr L2E88		; no, repeat until ESC pressed
	POP ax
	xchg ah,al
	sahf
	RET

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

L454A:   MOV word ptr L7B71,sp              ; save stack pointer to return after an error

	MOV bx,offset L7AD7+1
	CALL near ptr FILEINIT

	MOV bx,word ptr L4546		; HL = start of free area
	INC bx

	MOV word ptr L7BDF,bx		; set start address of 1024 bytes
				; update table
	INC bh
	INC bh
	INC bh
	INC bh
	MOV word ptr L7BE1,bx		; start of free area + 1024

	MOV bx,word ptr L790A		; HL = data end address
	MOV word ptr L7908,bx		; start of free data area, growing downwards
	XOR al, al
	MOV bh,al
	MOV bl,al
	MOV byte ptr L7B91,al		; = 0
	MOV byte ptr L7B92,al		; = 0
	MOV byte ptr L7B94,al		; = 0
	MOV byte ptr L7BA2,al		; = 0, no end of file found
	MOV byte ptr L7BA0,al		; = 0
	MOV byte ptr L7BE3,al		; = 0, no updates

	MOV byte ptr L7B96,al		; = 0, number of the overlay file

	MOV byte ptr L7BDB,al		; = 0, already read and not dirty

         MOV word ptr L7BDD,bx              ; = 0, first block of the file
				; or first block of current overlay part
         MOV word ptr CODEFILESTART,bx
         MOV word ptr CODEFILESTART+2,bx

	CALL near ptr L718F		; print current line number

	DEC bx
         MOV word ptr L7954,bx              ; init at block 65535, no block read yet

         MOV word ptr CODEFILEPOS,bx
         MOV word ptr CODEFILEPOS+2,bx

	MOV al,10H
	MOV byte ptr L7B93,al		; first free type number
				; use by scalar types

	MOV al,0F5H
	MOV byte ptr L7B9D,al		; default:
				; 0, 1 I/O Error Handling on
				; 1, 0 Index Range Checking off
				; 2, 1 Absolute Code on
				; 3, 0 User Interrupt off
				; 4, 1 Array Optimization on
				; 5, 1 Var-parameter Type Checking on
				; 6, 1 I/O Mode Selection on
				; 7, 1 Control S and C interpretation on
         MOV al,4
         MOV byte ptr WITHDEPTH,al           ; init number of 'with' levels

	MOV bx,word ptr L4544		; HL = start of text area
;	 LD (L7BD7),HL		 ; init current position of text in memory
;	 LD (L7BD9),HL		 ; init start of line of text in memory

	MOV si,offset L79D7		; init line buffer as empty, terminated by 0
	MOV byte ptr [si+0],0

	MOV bx,word ptr L7904		; HL = code start address
         CALL near ptr L6CC2

	MOV bx,word ptr L4548		; HL = end of free area
	DEC bx
	MOV word ptr L7B77,bx		; address of the first declared id (CBREAK)
	MOV dh,bh
	MOV dl,bl
	MOV cx,offset L74D2-L731F+1	; length of variable table
				; grows down wards
	OR al, al
	SBB bx,cx
	MOV word ptr L7B73,bx		; bottom of variable table
	MOV word ptr L7B75,bx		; same
	MOV word ptr L7B7B,bx		; same

;	 CALL SETCHK

	CALL near ptr L6BC7		; check compiler overflow, memory overflow
	MOV bx,offset L74D2
	CALL __LDDR			; copy standard variable definitions

         CALL near ptr L45EA

	MOV al,byte ptr L7900
	DEC al
	JNZ near ptr L45E2		; jump if search (= 2)

	CALL near ptr L6C96

         CALL near ptr L6CFD                 ; write 128 bytes to file
				; flush last buffer

         PUSH di
         MOV cx,offset CODEFILE
         CALL near ptr CLOSEFILE
         POP di

L45E2:   MOV word ptr L7906,di              ; new code end address
	XOR al, al
         JMP near ptr  L72E3

L45EA:	CALL near ptr L6F95		; get non-blank
	CALL near ptr L6E76		; start with PROGRAM?
	DW L7529 		; start of reserved word: PROGRAM
	JNZ near ptr L460A		; no, skip PROGRAM stuff

	; PROGRAM identifier ( identifier list )
	CALL near ptr L4692		; add identifier at IX

	CALL near ptr L6F1B		; match('('), if present
	JNZ near ptr L4607		; jump if '(' not matched

L45FC:	CALL near ptr L4692		; add identifier at IX
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L45FC		; yes, add next identifier

	CALL near ptr L6F6E		; match(')')

L4607:	CALL near ptr L6F48		; match(';')

L460A:	MOV al,31H 		; opcode 'LD SP,'
	MOV bx,100H
	CALL near ptr O_OPHL		; out: 'LD SP,100H'

	MOV bx,offset L79D7
	MOV al,byte ptr L7900
	OR al, al			; compile to memory?
	JZ near ptr L4621		; yes, output L79D7

	MOV dx,0100H
	CALL near ptr L6C30		; allocate 256 bytes of data area

L4621:	CALL near ptr O_LDHL		; out: 'LD HL,L79D7'
				;   or 'LD HL,allocated data address'
	MOV al,byte ptr L7B9D
	TEST al,128			; 1 = Control S and C interpretation on
	MOV dh,0			; assume no interpretation
	JZ near ptr L462E		; jump if off
	DEC dh			; D = 255
L462E:	PUSH dx
	MOV al,1
	CALL near ptr O_BYTE		; opcode: 'LD BC,'
				; B = 255 if Control S and C interpretation on
				; C = 255 if User Interrupt on

	PUSH di			; save code pointer
	CALL near ptr O_HL		; out: dummy, reserve 2 bytes
	MOV bx,offset _L0364		; LIB, done
	CALL near ptr O_CALHL		; out: 'CALL L0364'

	MOV al,21H
	CALL near ptr O_BYTE		; opcode: 'LD HL,'
	PUSH di			; save code pointer (1st)

	CALL near ptr O_HL		; out: dummy, reserve 2 bytes
	MOV al,11H
	CALL near ptr O_BYTE		; opcode: 'LD DE,'
	PUSH di			; save code pointer (2nd)

	CALL near ptr O_HL		; out: dummy, reserve 2 bytes

	MOV bx,word ptr L790A		; HL = data end address
	CALL near ptr O_LDBC		; out: 'LD BC,data end address

	MOV al,byte ptr L7900		; 0 = compiled in memory
				; 1 = compiled to disk
				; 2 = compiled while searching
	MOV bh,al
	MOV bl,3EH
	CALL near ptr O_HL		; out: 'LD A,value (L7900)'

	MOV bx,offset _L04D4		; LIB, clear
	CALL near ptr O_CALHL		; out: 'CALL L04D4'
	CALL near ptr L469E

         CALL near ptr L52FC                 ; start main program

         MOV al,byte ptr [si+0]
	CMP al, '.'                     ; '.' ?, needed for 'END.'

	CALL near ptr L72DA		; NonZero --> error
	DB 0AH			; error 10: '.' expected

	MOV bx,offset _L20D4		; LIB, done
	CALL near ptr O_JPHL		; out: JP L20D4

	POP bx
	MOV dx,word ptr L7908		; DE = data start address
         CALL near ptr L6C42                 ; update address at HL with contents of DE

	POP bx
         CALL near ptr L6C3F                 ; update address at HL with current address

	POP bx
	POP dx
	MOV al,byte ptr L7BA0
	MOV dl,al
         JMP near ptr  L6C42                   ; update address at HL with contents of DE

L4692:	; add identifier at address IX
	; in:	IX = address of identifier
	; out:	-
	MOV bx,word ptr L7B73		; HL = address to add a identifier
	PUSH bx
	CALL near ptr L6D87		; add identifier at address IX
	POP bx
	MOV word ptr L7B73,bx
	RET

L469E:	; in:	-
	; out:	-
	MOV al,byte ptr WITHDEPTH
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	ADD al,al
	MOV dl,al			; DE = 2 * value (WITHDEPTH) bytes to allocate
	MOV dh,0
         CALL near ptr L6C30                 ; HL = address newly allocated data
	PUSH bx
	CALL near ptr O_C3		; opcode: 'JP'
	PUSH di
	PUSH bx
	CALL near ptr O_HL		; out: address of allocated data

L46B3:	CALL near ptr L6E5A
	DB 1			; 1 byte following every reserved word
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	CALL near ptr L72DA		; NonZero --> error
	DB 0CH			; error 12: BEGIN expected

	MOV al,byte ptr [bx]		; A = byte following the found word

L46BE:	CMP al, 1			; word is 'LABEL' ?
	JNZ near ptr L46C7		; no, continue


	CALL near ptr L488E		; label-declaration-part
	JMP near ptr  L46B3 		; repeat

L46C7:	CMP al, 2			; word is 'CONST' ?
	JNZ near ptr L46D0		; no, continue

	CALL near ptr L48B7
	JMP near ptr  L46BE

L46D0:	CMP al, 3			; word is 'TYPE' ?
	JNZ near ptr L46D9		; no, continue
	CALL near ptr L4AEB
	JMP near ptr  L46BE

L46D9:	CMP al, 4			; word is 'VAR' ?
	JNZ near ptr L46E6		; no, continue
	CALL near ptr L4B2A
	MOV bx,word ptr L7908		; HL = data start address
	mov bp,sp
	XCHG [bp],bx
	JMP near ptr  L46BE

L46E6:	CMP al, 7			; word is 'OVERLAY' ?
         JNZ near ptr L485E                ; no, continue

	; start of overlay procedure
	MOV al,byte ptr L7900
	OR al, al			; only overlays when compiling to disk

	CALL near ptr L72D4		; Zero --> error
	DB 4DH			; error 77: Overlays not allowed in direct mode

         MOV bx,offset CODEFILE+1
         MOV dx,offset TEMPFILEDATA
         MOV al,' '
         MOV ch,al
         MOV cl,al
         CALL near ptr PARSENAME             ; parse name to get last item

         PUSH cx                    ; save address of last item

;         LD HL,L7934
;         LD DE,L7BB2
;         LD BC,0008
;         LDIR                       ; fill name of overlay file

	; create 0xy
	MOV bx,offset L7B96

         MOV al,byte ptr [bx]
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al                    ; save number to put in overlay-info block

         INC byte ptr [bx]

;         EX DE,HL

;         LD (HL),'0'
;         INC HL

         MOV ch,'0'-1

L4709:	INC ch
	SUB al, 10
	JNC near ptr L4709
;         LD (HL),B
;         INC HL

         ADD al,'0' + 10             ; + 10 to compensate for SUB 10
         MOV cl,al

;         LD (HL),A

         MOV al,'0'

         MOV bx,offset TEMPFILEDATA+1
         STC                        ; overrule current extension
         CALL near ptr SETEXTENSION

	MOV al,byte ptr L7B9D
         MOV bx,offset _LOADRUNOVERLAYREC

	TEST al,4			; 1 = Absolute Code on
         JZ near ptr L470D                 ; jump if not on

         MOV bx,offset _LOADRUNOVERLAY      ; LIB, overlay system call

L470D:
	CALL near ptr O_CALHL

         MOV bx,-1                   ; initial ID number, nothing loaded
         CALL near ptr O_HL                  ;Ok$$$$, will be long with file position
                                    ; as id of loaded overlay
         MOV bx,-1
         CALL near ptr O_HL

         MOV bx,-1
         CALL near ptr O_HL                  ; output overlay data length
                                    ; default not present

         POP bx
         MOV al,bh
         CALL near ptr O_BYTE                ; output overlay number

         POP bx                     ; HL = address of last item
                                    ; drive/path/name drive/name
                                    ;            ^          ^
         PUSH bx

         XOR al, al                      ; lenght of overlay file name = 0
L4723:
         INC al

         DEC byte ptr [bx]
         INC byte ptr [bx]

         INC bx

         JNZ near ptr L4723

         DEC al

         CALL near ptr O_BYTE                ; output length of overlay file name

         POP bx

;         LD HL,L7BB2                ; source address overlay file name
         MOV ch,13                    ; file name is 13 bytes long
                                    ;Ok$$$$, will be ASCIIZ string of 12 bytes
                                    ; + '\0'

L4724:	MOV al,byte ptr [bx]
	CALL near ptr O_BYTE
	INC bx
	DEC ch
	JNZ near ptr L4724

	MOV al,byte ptr L7900
	DEC al
	JNZ near ptr L473B		; jump if searching

	CALL near ptr L6C96		; jump dates

         XOR al, al
         MOV byte ptr L7BE3,al               ; no updates

	CALL near ptr L6CFD		; write 128 bytes to file, updated record

L473B:
         ;LD HL,(L7BDD)              ; save first block of current part
         ;PUSH HL                    ;Ok$$$$, must be long
                                    ; CodeFileStart
         MOV bx,word ptr CODEFILESTART+2
         PUSH bx                    ; save high-word
         MOV bx,word ptr CODEFILESTART
         PUSH bx                    ; save low-word

	MOV bx,word ptr L7902		; save first address of current part
	PUSH bx

         MOV bx,word ptr L7BB0              ; save length of largest part
         PUSH bx                    ;Ok$$$$, must be in bytes
                                    ;       now in 128 byte blocks

         MOV word ptr L7902,di              ; set first address of current part

         MOV bx,0                    ; #### 0000
         MOV word ptr L7BB0,bx              ; set length of largest part = 0

         MOV bx,-65                  ; size of handle/FCB
         ADD bx,sp

;         LD HL,-FCB_LEN             ; -36
;         ADD HL,SP                  ; allocate space for a new FCB

	MOV sp,bx
	XCHG dx,bx
         MOV bx,offset CODEFILE ; L7933
         MOV cx,65 ; FCB_LEN
	CALL __LDIR			; copy current FCB to this new space

	MOV al,byte ptr L7900
	DEC al
         JNZ near ptr L478C                ; jump if searching

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

         MOV bx,offset TEMPFILEDATA
         MOV dx,offset CODEFILE
         MOV cx,65
         CALL __LDIR

         MOV dx,offset CODEFILE+1
         CALL near ptr DELETEFILE

         MOV bx,offset CODEFILE+1
         MOV dx,offset CODEFILE
         MOV al,' '
         MOV ch,al
         MOV cl,al
         CALL near ptr CREATEFILE

;         LD DE,L7933
;         PUSH DE
;         LD C,13H                   ; delete file
;         CALL DOSIXIY
;         POP DE
;         LD C,16H                   ; create file
;         CALL DOSIXIY
;         INC A

         CALL near ptr L72DA                 ; NonZero --> error
	DB 5CH			; error 92: Unable to create overlay file

         MOV bx,0
         MOV word ptr CODEFILESTART,bx
         MOV word ptr CODEFILESTART+2,bx

L478C:
         MOV bx,0
         MOV word ptr CODEFILEBUFFERPOS,bx  ; start at byte 0 of buffer
         XOR al, al
	MOV byte ptr L7BDB,al		; already read and not dirty
;         LD (L7BDC),A               ; start at byte 0 of current block

	MOV bx,word ptr L7908		; HL = data start address
	MOV word ptr L7BAB,bx		; save data start address
				; all overlay functions and procedures in
				; the same overlay have the same data
				; start address

L4799:	CALL near ptr L6E5A
	DB 1			; 1 byte following
	DW L75A7 		; start of reserved word list:
				; PROCEDURE, FUNCTION

	CALL near ptr L72DA		; NonZero --> error
	DB 10H			; error 16: PROCEDURE or FUNCTION expected

         MOV al,byte ptr [bx]                  ; A = 5, PROCEDURE
                                    ; A = 6, FUNCTION

         PUSH di                    ; save start of overlay code
                                    ; just after the filename

         MOV bx,word ptr CODEFILESTART
         MOV word ptr CODEFILEPOS,bx
         MOV bx,word ptr CODEFILESTART+2
         MOV word ptr CODEFILEPOS+2,bx

;         LD HL,(L7954)              ; HL = current file position
;                                    ;Ok$$$$, must be long
;         LD (L7BDD),HL              ; save current file position
;                                    ; set start of new part
;                                    ;Ok$$$$, must be long CodeFileStart

	MOV bx,word ptr L7908		; HL = data start address
	PUSH bx			; save old data start address

	MOV bx,word ptr L7BAB
	PUSH bx

	MOV dl,0FFH		; this procedure, function is an overlay
         CALL near ptr L4B3A

         ; HL = address of high byte of struct length
         MOV ch,bh
         MOV cl,bl

	POP dx

	MOV bx,word ptr L7908		; HL = new data start address
	OR al, al
	SBB bx,dx		; used data of last proc/func >
				;	   biggest data of proc/func
         ADD bx,dx
	JC near ptr L47C6		; jump not bigger

	XCHG dx,bx 		; data of last proc/func is largest data

L47C6:	MOV word ptr L7BAB,bx		; save biggest data area

	POP bx			; restore old data start address
	MOV word ptr L7908,bx		; set new data start address

	POP dx			; DE = start of overlay code


         PUSH cx                    ; address of high byte of struct length

	PUSH dx			; DE = start of overlay code

	MOV al,byte ptr L7900
	DEC al
	CALLZ L6C96		; call if compiling to disk

	XOR al, al
	MOV byte ptr L7BE3,al		; 0 = no updates

	POP dx			; DE = start of overlay code
	PUSH dx

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

         PUSH di
         POP bx

         OR al, al
         SBB bx,dx                  ; HL = length of current part in bytes

         XCHG dx,bx
;         ;Ok$$$$, must be length in bytes
;         ADD HL,HL                  ; length in bytes * 2
;         LD E,H                     ; E = number of 128 byte blocks
;         LD D,0
;         RL D

         MOV bx,word ptr L7BB0              ; HL = largest part
	SBB bx,dx
	JNC near ptr L47FF		; jump largest part > length current part

         MOV word ptr L7BB0,dx              ; largest part = length current part
                                    ;Ok$$$$, must be in length in bytes

L47FF:
	POP di			; IY = start of overlay code

         ;Ok$$$$, DE = must become length of function/procedure in bytes
         POP bx                     ; HL = address of high byte of struct length
	INC bx
	MOV byte ptr [bx],dl		; set size of function/procedure code
	INC bx			; to number of 128 byte blocks
	MOV byte ptr [bx],dh

         MOV bx,word ptr CODEFILESTART
         ADD bx,dx
         MOV word ptr CODEFILESTART,bx
         MOV bx,word ptr CODEFILESTART+2
         MOV dx,0
         ADC bx,dx
         MOV word ptr CODEFILESTART+2,bx

	CALL near ptr L6E76
	DW L759F 		; start of reserved word: OVERLAY
         JZ near ptr L4799                 ; jump if 'OVERLAY'
				; this jump repeats the LOOP

	MOV bx,word ptr L7BAB		; HL = lowest address with data in overlay
	MOV word ptr L7908,bx		; continue the with the rest

	MOV al,byte ptr L7900
	DEC al
	JNZ near ptr L4821		; jump if searching

         CALL near ptr L6CFD                 ; write 128 bytes to file
				; flush last buffer

         MOV cx,offset CODEFILE
         CALL near ptr CLOSEFILE

;         LD DE,L7933
;         LD C,10H                   ; close file with generated code
;         CALL DOSIXIY

L4821:	; pop old FCB block (previous overlay or com or chain file)
	MOV bx,0000
	ADD bx,sp

;         LD DE,L7933
;         LD BC,FCB_LEN
;         LDIR

         MOV dx,offset CODEFILE
         MOV cx,65
         CALL __LDIR

         MOV sp,bx

	MOV dx,word ptr L7BB0		; number of blocks of largest part

	POP bx
         MOV word ptr L7BB0,bx              ; restore length of largest part
	POP bx
	MOV word ptr L7902,bx		; restore first address of previous part

;         POP HL
;         LD (L7BDD),HL              ; restore first block of previous part
;                                    ;Ok$$$$, CodeFileStart
         POP bx
         MOV word ptr CODEFILESTART,bx      ; low-word
         POP bx
         MOV word ptr CODEFILESTART+2,bx    ; high-word

	XOR al, al
	MOV byte ptr L7BDB,al		; already read and not dirty

	MOV bx,-1
         MOV word ptr L7954,bx              ; init, no block read yet
         MOV word ptr CODEFILEPOS,bx
         MOV word ptr CODEFILEPOS+2,bx

	PUSH di
	POP bx
         CALL near ptr L6CC2

         ; create empty area in code file where the overlay is to be loaded
L484E:   MOV ch,1 ; 80H

L4850:   XOR al, al
	CALL near ptr O_BYTE
	DEC ch
	JNZ near ptr L4850
	DEC dx
	MOV al,dh
	OR al, dl
         JNZ near ptr L484E                ; until no more to go

         JMP near ptr  L46B3

L485E:	CMP al, 8			; word is 'BEGIN' ?
	JZ near ptr L486A

	; A = 5, PROCEDURE found
	; A = 6, FUNCTION found
	MOV dl,0			; this procedure, function is not an overlay
	CALL near ptr L4B3A
	JMP near ptr  L46B3

L486A:	; parses the word BEGIN
	CALL near ptr L4E8A
	POP dx			; DE = address of allocated memory
	POP bx			; HL = address after 'JP' opcode
	PUSH dx			; save address of allocated memory

	PUSH di
	POP dx			; DE = IY

	DEC dx
	DEC dx			; DE - 2

	OR al, al
	SBB bx,dx		; set flags at HL - DE
	pushf
	ADD bx,dx		; restore HL
	popf
	JZ near ptr L4880		; no more code generated ?

         CALL near ptr L6C3F                 ; update address at HL with current address
	JMP near ptr  L4884

L4880:	DEC bx			; dispose 'JP' opcode

         CALL near ptr L6CC2


L4884:	POP dx			; DE = address of allocated memory
	POP bx			; HL = address of allocated memory
	MOV word ptr L7BCA,bx
	POP ax
	xchg ah,al
	sahf			; A = pushed value of (WITHDEPTH)
	MOV byte ptr L7BC6,al
	RET

L488E:	; SYNTAX: label-declaration-part ::= LABEL label {, label } ;
	; reserved word LABEL already parsed
	MOV dx,100H
         CALL near ptr L6D75                 ; add DE to id table

	MOV al,byte ptr [si+0]
	CALL near ptr L7282		; letter, underscore or decimal ?

	CALL near ptr L6D8D		; carry set --> error
				; error 58: Illegal character in identifier
	MOV al,byte ptr L7B94
	CALL near ptr L6D7A		; add byte to id table

	MOV ch,3
L48A5:	MOV al,0FFH
	CALL near ptr L6D7A		; add byte to id table
	DEC ch
	JNZ near ptr L48A5

	CALL near ptr L6DC6		; add length
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L488E		; yes, add next id

	JMP near ptr  L6F48 		; match(';')

L48B7:	MOV bx,word ptr L7B73
	PUSH bx			; push for later setting of type

	MOV dx,0000
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6D87		; add identifier to id table
	CALL near ptr L6F23		; match('='), if present
	JNZ near ptr L4901		; jump if '=' not matched

	MOV al,0FFH		; default type = INTEGER / LONGINT
	MOV byte ptr DEF_TYPE,al
	CALL near ptr L6A0D		; parse a constant of any type

	MOV al,ch			; A = type
	CALL near ptr L6D7A		; add type (byte) to id table
	MOV al,ch
	CMP al, 9			; constant type = REAL ?
	JNZ near ptr L48DB1		; jump if not

	; add real value (6 bytes) to id table
	CALL __EXX
	PUSH bx
	PUSH dx
	PUSH cx
	MOV ch,3

L48DB:	POP dx
	CALL near ptr L6D75		; add DE to id table
	DEC ch
	JNZ near ptr L48DB
	JMP near ptr  L48FA

L48DB1:	CMP al, 0EH			; type = LONGINT ?
	JNZ near ptr L48E3		; jump if not

	; add longint value (4 bytes) to id table
	CALL __EXX
	PUSH bx
	PUSH dx
	MOV ch,2			; add 2 words
	JMP near ptr  L48DB

L48E3:	CMP al, 8			; type = STRING ?
	JNZ near ptr L48F6		; jump if not

	MOV bx,offset L7A57
	MOV al,cl
	INC cl

L48EC:	CALL near ptr L6D7A		; add byte to id table
	MOV al,byte ptr [bx]
	INC bx
	DEC cl
	JNZ near ptr L48EC
	JMP near ptr  L48FA

L48F6:	XCHG dx,bx
	CALL near ptr L6D75		; add DE to id table

L48FA:	CALL near ptr L6DC6		; add length
	MOV dh,2			; id type = constant
	JMP near ptr  L4928

L4901:	CALL near ptr L6F40		; match(':')
	XOR al, al
	CALL near ptr L6D7A		; add byte to id table
	CALL near ptr L6D72		; add IY to id table
				; start of constant address

	MOV bx,word ptr L7B73
	PUSH bx			; push for later setting of type

	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6DC6		; add length

	CALL near ptr L4F9B		; parse every possible type

	POP bx
	MOV dx,word ptr L7B5A
	MOV byte ptr [bx],dh
	DEC bx
	MOV byte ptr [bx],dl
	CALL near ptr L6F76		; match('=')

	CALL near ptr L4937
	MOV dh,4

L4928:	POP bx
	MOV byte ptr [bx],dh
	CALL near ptr L6F48		; match(';')
	CALL near ptr L6E5A
	DB 1			; 1 byte following
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	JNZ near ptr L48B7		; jump if none of these reserved words
				; repeat for next constant

	MOV al,byte ptr [bx]
	RET

L4937:	MOV al,byte ptr L7B5C		; A = type
	MOV byte ptr DEF_TYPE,al
	CMP al, 4
	JC near ptr L4946		; jump if type = 0, 1, 2 or 3 (SET)

	CMP al, 8
	JNC near ptr L4946		; jump if STRING, REAL, INTEGER, BOOLEAN,
				;	 CHAR, LONGINT

	CALL near ptr L72E1		; no condition
	DB 3DH			; error 61: Files and pointers are
				;	    not allowed here
L4946:	CMP al, 1
	JNZ near ptr L49A1

	; type = 1
	CALL near ptr L6D2A		; push 13, L7B57

	MOV bx,word ptr L7B60
	CALL near ptr L5271		; 8 bytes from HL (down) to 7B69 (up)

	MOV bx,word ptr L7B6D
	MOV dx,word ptr L7B6B
	OR al, al
	SBB bx,dx
	INC bx
	PUSH bx
	MOV bx,word ptr L7B5E		; HL = address of type definition
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)
				; get all information from this type
	POP dx
	MOV al,byte ptr L7B5C
	CMP al, 0CH
	JNZ near ptr L4978
	MOV al,dh
	OR al, al
	JNZ near ptr L4978
	CALL near ptr L6F1B		; match('('), if present
	JNZ near ptr L498A		; jump if '(' not matched
	JMP near ptr  L497B

L4978:	CALL near ptr L6F66		; match('(')
L497B:	PUSH dx

	CALL near ptr L4937

	POP dx
	DEC dx
	MOV al,dh
	OR al, dl
	JZ near ptr L499A
	CALL near ptr L6F5E		; match(',')
	JMP near ptr  L497B

L498A:	PUSH dx
	CALL near ptr L69FD		; parse string constant
	POP dx
	MOV al,cl
	CMP al, dl

	CALL near ptr L72DA		; NonZero --> error
	DB 32H			; error 50: String constant length does not
				;	    match type
	CALL near ptr L6B62
	JMP near ptr  L499D

L499A:	CALL near ptr L6F6E		; match(')')
L499D:	CALL near ptr L6D49		; pop 13, L7B57
	RET

L49A1:	CMP al, 2
	JNZ near ptr L49FA

	; type = 2
	CALL near ptr L6D2A		; push 13, L7B57
	CALL near ptr L6F66		; match('(')
	MOV al,byte ptr L7B5D
	MOV cl,al
	MOV bx,word ptr L7B62		; HL = length
	PUSH bx
	MOV bx,0000
L49B6:	PUSH cx
	PUSH bx
	MOV ch,4			; variable identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info

	CALL near ptr L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax
				;	   error

	CALL near ptr L5276		; id info at 7B5C
	POP dx
	MOV bx,word ptr L7B58		; HL = lvalue of current id
	OR al, al
	SBB bx,dx
	pushf
	ADD bx,dx
	popf

	CALL near ptr L72DA		; NonZero --> error
	DB 45H			; error 69: Invalid ordering of fields

	MOV dx,word ptr L7B62		; DE = length
	ADD bx,dx
	PUSH bx
	CALL near ptr L6F40		; match(':')

	CALL near ptr L4937

	POP bx
	POP cx
	CALL near ptr L6F0F		; match(';'), if present
	JZ near ptr L49B6		; jump if ';' matched
	CALL near ptr L6F6E		; match(')')
	POP dx
	XCHG dx,bx
	OR al, al
	SBB bx,dx
L49EB:	MOV al,bh
	OR al, bl
	JZ near ptr L49F6
	XOR al, al
	CALL near ptr O_BYTE
	DEC bx
	JMP near ptr  L49EB
L49F6:	CALL near ptr L6D49		; pop 13, L7B57
	RET

L49FA:	CMP al, 3			; type = SET ?
	JNZ near ptr L4A7A		; jump if not

	; type = SET
	CALL near ptr L6D2A		; push 13, L7B57
	MOV bx,word ptr L7B62		; HL = length
	MOV word ptr L7B6F,bx
	MOV bx,word ptr L7B5E		; HL = address of type definition
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)
	CALL near ptr L6F30		; match('[')

	MOV word ptr L7BA9,si		; save temporary
	CALL near ptr L0581		; LIB, push new empty SET on stack
	MOV si,word ptr L7BA9		; restore text pointer

	CALL near ptr L6EF7		; match(']') or match('.)')
	JZ near ptr L4A4B		; jump if matched

L4A20:	CALL near ptr L4ACA
	PUSH bx

	CALL near ptr L6E76
	DW L7580 		; start of reserved word: ..
	JNZ near ptr L4A37		; jump if no '..'

	CALL near ptr L4ACA

	MOV word ptr L7BA9,si		; save temporary
	CALL near ptr L059B		; LIB
	JMP near ptr  L4A3F

L4A37:	POP bx
	MOV word ptr L7BA9,si		; save temporary

	CALL near ptr L0591		; LIB

L4A3F:	MOV si,word ptr L7BA9		; restore text pointer
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L4A20		; jump if ',' matched
	CALL near ptr L6F38		; match(']')

L4A4B:	MOV bx,offset L7A57
	MOV cx,0020H

	MOV word ptr L7BA9,si		; save temporary
	CALL near ptr L0612		; LIB, copy pushed set to the address in HL
	MOV si,word ptr L7BA9		; restore text pointer

	MOV bx,offset L7A57
	MOV al,byte ptr L7B5E
	RCR al,1
	RCR al,1
	RCR al,1
	AND al, 1FH
	MOV dl,al
	MOV dh,0
	ADD bx,dx
	MOV al,byte ptr L7B6F
	MOV ch,al
L4A6F:	MOV al,byte ptr [bx]
	CALL near ptr O_BYTE
	INC bx
	DEC ch
	JNZ near ptr L4A6F
	CALL near ptr L6D49		; pop 13, L7B57
	RET

L4A7A:	CMP al, 8			; type = STRING ?
	JNZ near ptr L4A99

	; type = STRING
	; typed string constant
	CALL near ptr L69FD		; parse string constant

	MOV al,byte ptr L7B62		; A = length of constant type
	DEC al			; minus 1 for length byte

	SUB al, cl			; - string constant length
	MOV ch,al

	JNC near ptr L4A8D

	; constant type < string constant
	ADD al,cl			; restore type length - 1
	MOV cl,al			; copy constant type bytes
	MOV ch,0			; no padding at the end

L4A8D:	CALL near ptr L6B5E		; output length (C) and data at L7A57
	INC ch
L4A91:	DEC ch
	RETZ 
	XOR al, al
	CALL near ptr O_BYTE
	JMP near ptr  L4A91

L4A99:	CMP al, 9			; type = REAL ?
	JNZ near ptr L4ABC

	; type = REAL
	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	MOV al,ch
	CMP al, 9			; type = REAL ?
	JZ near ptr L4AAF		; jump if type = REAL, no conversion

	CMP al, 0EH			; type = LONGINT ?
	JZ near ptr L4AAF1		; jump if type = LONGINT, L_R

	CMP al, 0AH			; type = INTEGER ?

	CALL near ptr L72DA		; NonZero --> error
	DB 19H			; error 25: Integer, real or longint
				;	   constant expected

	CALL near ptr L1008		; convert integer HL to REAL HLDEBC
	CALL __EXX

L4AAF:	; output data for REAL constant
	CALL __EXX
	PUSH cx
	PUSH dx
	PUSH bx
	MOV ch,3			; output 3 words

L4AB5:	POP bx
	CALL near ptr O_HL
	DEC ch
	JNZ near ptr L4AB5
	RET

L4AAF1:	; output data for LONGINT constant
	CALL __EXX
	CALL near ptr L_R 		; convert longint DEHL to REAL HLDEBC
	CALL __EXX
	JMP near ptr  L4AAF

L4ABC:	CMP al, 0EH			; type = LONGINT ?
	JNZ near ptr L4ABC1

	; type = LONGINT
	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	MOV al,ch
	CMP al, 9			; type = REAL ?
	CALL near ptr L72D4		; Zero --> error
	DB 2CH			; error 44: Type mismatch

	CALL __EXX			; DEHL = value
	CMP al, 0EH			; type = LONGINT ?
	JZ near ptr OUT_LONG
	CALL __EXX			; HL = integer value

	CMP al, 0AH			; type = INTEGER ?
	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	CALL near ptr I_L 		; convert integer HL to longint DEHL

OUT_LONG:
	CALL near ptr O_HL
	XCHG dx,bx
	CALL near ptr O_HL
	XCHG dx,bx
	RET

I_L:	; in:	HL = INTEGER, signed
	; out:	DEHL = LONGINT, signed
	MOV dx,0
	TEST bh,128
	RETZ 			; return if integer is positive

	DEC dx			; make long negative
	RET

L4ABC1:	CALL near ptr L4ACA		; make constant range check
	MOV al,byte ptr L7B62
	DEC al			; length = 1 ?
	MOV al,bl
	JZ near ptr O_BYTE		; output data
	JMP near ptr  O_HL

L4ACA:	; make constant range check
	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	MOV al,byte ptr L7B5C
	CMP al, ch			; equal types ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	CMP al, 0EH			; type = LONGINT ?
	RETZ 			; no range check

	MOV dx,word ptr L7B5E		; DE = minimum value
	CALL near ptr L728D		; check if lower bound <= upper bound

	JC near ptr L4AE7		; jump if lower bound > upper bound

	MOV dx,word ptr L7B60		; DE = maximum value
	CALL near ptr L728D		; check if lower bound <= upper bound
	RETC 			; return if HL < maximum value
	RETZ 			; return if HL = maximum value

L4AE7:	CALL near ptr L72E1		; no condition
	DB 2DH			; error 45: constant out of range

L4AEB:	MOV bx,word ptr L7B73
	PUSH bx
L4AEF:	MOV bx,word ptr L7B73
	PUSH bx
	MOV dx,0000
	CALL near ptr L6D75		; add DE to id table
				; represents the type
	CALL near ptr L6D87		; add identifier to id table

	MOV bx,word ptr L7B73
	PUSH bx
	CALL near ptr L6D75		; add DE to id table
				; will be filled in later with pointer to
				; the type
	CALL near ptr L6DC6		; add length, length is calculated
	CALL near ptr L6F76		; match('=')
	CALL near ptr L4F9B		; parse every possible type
	POP bx
	MOV dx,word ptr L7B5A
	MOV byte ptr [bx],dh
	DEC bx
	MOV byte ptr [bx],dl
	POP bx
	MOV byte ptr [bx],3
	CALL near ptr L6F48		; match(';')

	CALL near ptr L6E5A
	DB 1			; 1 byte following
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	JNZ near ptr L4AEF
	MOV al,byte ptr [bx]

	POP bx			; address where to stop reference search
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L5295		; update pointer references
	POP ax
	xchg ah,al
	sahf
	RET

	; name1, name2 : type_name;
L4B2A:	CALL near ptr L4F35		; parse variable declarations
	CALL near ptr L6F48		; match(';')

	CALL near ptr L6E5A
	DB 1			; 1 byte following
	DW L7584 		; start of reserved word list:
				; LABEL, CONST, TYPE, VAR, BEGIN, OVERLAY
				; PROCEDURE, FUNCTION

	JNZ near ptr L4B2A		; no reserved found, parse more names
	MOV al,byte ptr [bx]		; A = number of one of the reserved words
	RET

L4B3A:   MOV ch,al                     ; B = 5 if procedure
				; B = 6 if function
	MOV cl,0
	SUB al, 5
	MOV byte ptr L7B97,al		; 0 = procedure, 1 = function

L4B42:	MOV al,dl
         MOV byte ptr L7B99,al               ; 0 = no overlay, 255 = overlay

	MOV al,byte ptr L7B9D		; compiler directives
	MOV byte ptr L7B9E,al		; save them

	PUSH cx
	CALL near ptr L6DDB		; ID at current position double defined ?
	JZ near ptr L4C61		; jump if double defined

	POP dx			; DE = type
				; D = 5, PROCEDURE
				; D = 6, FUNCTION
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6D87		; add identifier to id table

	MOV bx,word ptr L7B7B
	PUSH bx			; save add position of first added struct

	MOV bx,word ptr L7B75		; HL = start of added PROC/FUNC struct
	MOV word ptr L7B7B,bx
	MOV bx,word ptr L7B73
	PUSH bx			; save add position after identifier
				; for connection
         CALL near ptr L6D75                 ; add DE to id table, # different types
         CALL near ptr L6D75                 ; add DE to id table, proc/func address
         CALL near ptr L6D75                 ; add DE to id table, function type def.
         CALL near ptr L6D75                 ; add DE to id table, addr function result
                                    ;                     variable

;         LD DE,(L7BDD)              ; save first block of current PROC/FUNC
;                                    ;Ok$$$$, make long word CodeFileStart
;         CALL L6D75                 ; add DE to id table

         MOV dx,word ptr CODEFILESTART+2
         CALL near ptr L6D75                 ; save high-word of CodeFileStart
         MOV dx,word ptr CODEFILESTART
         CALL near ptr L6D75                 ; save low-word of CodeFileStart

         MOV dx,0000                 ; length in bytes of procedure/function code
         MOV al,byte ptr L7B99
         OR al, al                       ; Zero = no overlay, NonZero = overlay
         JZ near ptr L4B45
         DEC dx                     ; init at -1, special meaning
L4B45:
;         LD DE,1
;         LD DE,0000                 ; length in blocks of 128 bytes of
;                                    ; the largest overlay part
;                                    ;Ok$$$$, becomes length in bytes
	CALL near ptr L6D75		; add DE to id table

	CALL near ptr L6F1B		; match('('), if present
	MOV ch,0			; assume no dest. type --> procedure
	JNZ near ptr L4BDA		; jump if no '(', thus no var list

	; start loop for different types
L4B88:	PUSH cx			; push number of different types

	MOV bx,word ptr L7B73
	PUSH bx			; save position for number of vars with
				; same type
	CALL near ptr L6D75		; add DE to id table, count + var/no var.
	CALL near ptr L6D75		; add DE to id table, address type defs.

	CALL near ptr L6E76
	DW L7595 		; start of reserved word: VAR

	MOV cx,0000		; B = 0, zero identifiers using same type
				; C = 0, assume no VAR
	JNZ near ptr L4B9E		; jump if no VAR found

	DEC cl			; C = 255, VAR before definition

L4B9E:
	PUSH cx
	CALL near ptr L6D87		; add identifier to id table

	POP cx
	INC ch			; one more identifier using same type
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L4B9E		; jump if ',' matched, repeat

	PUSH cx			; save count and VAR flag

	CALL near ptr L6F0B		; match(':'), if present
	JNZ near ptr L4BB8		; jump if ':' not matched
	MOV al,cl
	MOV byte ptr L7B8F,al		; 0 = no VAR, 255 = VAR parsed
	CALL near ptr L4F18		; L7B5C..L7B63 filled in with type info
	JMP near ptr  L4BC3

L4BB8:	INC cl

	CALL near ptr L72DA		; NonZero --> error
	DB 2			; error 2: ':' expected

	MOV bx,offset L7512
	MOV word ptr L7B5A,bx

L4BC3:	; add count and VAR/NO VAR flag
	POP cx			; pop count and VAR flag

	POP bx
         MOV byte ptr [bx],ch                  ; save count
	DEC bx
         MOV byte ptr [bx],cl                  ; save VAR flag

	MOV dx,word ptr L7B5A		; DE = address of type definition info
	DEC bx
	MOV byte ptr [bx],dh
	DEC bx
	MOV byte ptr [bx],dl

	POP cx			; restore number of different types
	INC ch			; one more different types
	CALL near ptr L6F0F		; match(';'), if present
	JZ near ptr L4B88		; jump if ';' matched, repeat for next var

	CALL near ptr L6F6E		; match(')')

L4BDA:	PUSH cx			; save number of different types
	MOV al,byte ptr L7B97		; 0 = proc, 1 = func
	OR al, al
	JZ near ptr L4C07		; if proc skip function type

	CALL near ptr L6F40		; match(':')
	XOR al, al
	MOV byte ptr L7B8F,al		; 0 = no VAR, 255 = VAR
	CALL near ptr L4F18		; L7B5C..L7B63 filled in with type info		  ; parse type
	MOV al,byte ptr L7B5C
	CMP al, 8			; type = STRING, REAL, INT, BOOL or CHAR ?
	JNC near ptr L4BF8		; yes, jump
	CMP al, 4

	CALL near ptr L72DA		; NonZero --> error
	DB 30H			; error 48: Invalid result type

L4BF8:	POP cx			; restore number of different types

         POP bx                     ; HL = address after PROC/FUNC identifier
         PUSH bx

         PUSH cx

         MOV dx,-4
	ADD bx,dx
	MOV dx,word ptr L7B5A		; address of type definition info
	MOV byte ptr [bx],dh
	DEC bx
	MOV byte ptr [bx],dl

L4C07:	POP cx			; restore number of different types
	POP dx			; DE = position after declared
				; procedure/function name
	POP bx
	MOV word ptr L7B7B,bx		; restore

	PUSH dx
	PUSH cx			; save type
	CALL near ptr L6DC6		; add length of proc/func definition
	CALL near ptr L6F48		; match(';')
	MOV al,byte ptr L7B99		; 0 = no overlay, 255 = overlay
	OR al, al
	JNZ near ptr L4C44		; jump if overlay

	CALL near ptr L6E76		; FORWARD next ?
	DW L7533 		; start of reserved word: FORWARD
	JNZ near ptr L4C2C		; no, skip

	PUSH di
	POP dx			; DE = address of 'JP' opcode

	CALL near ptr O_JPHL		; output forward jump

         MOV al,0FFH                  ; flag for update, update necessary
	JMP near ptr  L4C38

L4C2C:	CALL near ptr L6E76		; EXTERNAL next ?
	DW L753A 		; start of reserved word: EXTERNAL
	JNZ near ptr PF_INL		; jump if not EXTERNAL

IFNDEF NEWEXT
	CALL near ptr L69F2		; parse integer constant
	XCHG dx,bx 		; DE = start address for external routine
	XOR al, al			; no update necessary
ELSE
	PUSH di			; save current code address

	CALL near ptr L5E97		; parse integer expression

	MOV al,0E9H
	CALL near ptr O_BYTE		; opcode: JP (HL)

	XOR al, al			; no update necessary

	POP dx			; start address for external routine
ENDIF

L4C38:	POP cx			; pop type

         POP bx                     ; HL = address after PROC/FUNC identifier
	MOV byte ptr [bx],al		; save update flag
	DEC bx
	MOV byte ptr [bx],ch		; save number of different types
	DEC bx
	MOV byte ptr [bx],dh		; save proc/func call address
	DEC bx
	MOV byte ptr [bx],dl
	JMP near ptr  L6F48 		; match(';')

PF_INL:	CALL near ptr L6E76		; INLINE next ?
	DW L75EC 		; start of reserved word: INLINE
	JNZ near ptr L4C44		; jump if not INLINE

	PUSH di			; save current code address

	CALL near ptr L5698		; parse complete INLINE statement

	XOR al, al			; no update necessary
	POP dx			; start address for external routine
	JMP near ptr  L4C38

L4C44:	POP cx			; B = number of different types
	POP bx			; HL = position after declared name

	PUSH bx			; save position after declared name
	MOV byte ptr [bx],0		; update flag, 0 = no update
	DEC bx
	MOV byte ptr [bx],ch		; save number of different types
	DEC bx

	PUSH di			; IY = current address in code
	POP dx			; DE = start address of procedure/function

         MOV al,byte ptr L7B99               ; 0 = no overlay, 255 = overlay
	OR al, al
         JZ near ptr L4C5B                 ; skip if no overlay

	XCHG dx,bx 		; adjust start address of an overlay

;         LD BC,-16                  ; 16 bytes before address of code generation
;                                    ;Ok$$$$, propably to 20
;         LD BC,-20                  ; overlay-info block length
         MOV cx,-24                  ; minus overlay-info block length

         ADD bx,cx
	XCHG dx,bx

L4C5B:	MOV byte ptr [bx],dh		; save start address of proc or func
	DEC bx
	MOV byte ptr [bx],dl
	POP bx			; HL = position after declared name
	JMP near ptr  L4C76

L4C61:	MOV al,byte ptr [bx]
	OR al, al

	CALL near ptr L72D4		; Zero --> error
	DB 2BH			; error 43: Duplicate identifier or label

	MOV al,byte ptr L7B99		; 0 = no overlay, 255 = overlay
	OR al, al

	CALL near ptr L72DA		; NonZero --> error
	DB 4CH			; error 76: Overlay cannot be forward

	CALL near ptr L6E96
	POP dx
	CALL near ptr L6F48		; match(';')

L4C76:	XCHG dx,bx 		; DE = position after declared name

	MOV al,byte ptr L7B9D
	MOV bx,word ptr L7908		; HL = data start address

	TEST al,4			; 1 = Absolute Code on
         JZ near ptr L4C84                 ; jump if not on

         MOV bx,0000                 ; absolute code on
                                    ; remember for this procedure/function

L4C84:   MOV word ptr L7B83,bx              ; set data start address

	MOV bx,word ptr L7B7B
	PUSH bx

	MOV bx,word ptr L7B73
	MOV word ptr L7B7B,bx
	PUSH bx

	XCHG dx,bx 		; HL = position after declared name
	MOV al,byte ptr [bx]
	MOV byte ptr [bx],0		; update flag, 0 = no update
	DEC bx
	MOV ch,byte ptr [bx]		; B = number of different types
	DEC bx
	MOV dh,byte ptr [bx]		; DE = procedure/function address
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	OR al, al
	JZ near ptr L4CA7		; jump if no update necessary

	PUSH bx
	XCHG dx,bx
	INC bx
         CALL near ptr L6C3F                 ; update address at HL with current address
	POP bx

L4CA7:	MOV al,byte ptr L7B97		; 0 = proc, 1 =func
	OR al, al
	JZ near ptr L4CD2		; jump if procedure

	MOV dh,byte ptr [bx]		; DE = address of function result type
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	PUSH bx
	XCHG dx,bx
         CALL near ptr L5287                 ; 8 bytes from HL (down) to 7B5C (up)
				; get all information on this type
	MOV al,byte ptr L7B5C
	MOV byte ptr L7B87,al
	MOV bx,word ptr L7B62		; HL = size of the type
	MOV al,bl
	MOV byte ptr L7B88,al
	XCHG dx,bx
	CALL near ptr L6C30		; allocate DE bytes of data for this type
	MOV word ptr L7B89,bx
	XCHG dx,bx
	POP bx
	MOV byte ptr [bx],dh
	DEC bx
	MOV byte ptr [bx],dl
	DEC bx
	JMP near ptr  L4CD6

L4CD2:   MOV dx,-4                   ; skip function type definition and
                                    ; function result variable address
	ADD bx,dx

L4CD6:   MOV dx,-6                   ; -4
	ADD bx,dx
	PUSH bx

         MOV cl,0                     ; start at variable 0

         MOV al,ch
	OR al, al
         JZ near ptr L4D2B                 ; quit if 0 different types

         ; loop for variables with different type
L4CE1:   MOV al,byte ptr [bx]                  ; A = count, # variables with same type
	ADD al,cl
	MOV cl,al
	PUSH cx

         MOV ch,byte ptr [bx]                  ; B = count, # variables with same type
	DEC bx

         MOV al,byte ptr [bx]
	MOV byte ptr L7B8F,al		; 0 = no VAR, 255 = VAR
	DEC bx

         MOV dh,byte ptr [bx]                  ; DE = address of type definition info
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx

         PUSH bx

         XCHG dx,bx
         MOV word ptr L7B5A,bx              ; HL = address of type definition info

         CALL near ptr L5287                 ; 8 bytes from HL (down) to 7B5C (up)

         MOV bx,word ptr L7B73

         mov bp,sp
	XCHG [bp],bx

         PUSH cx

         ; loop for variables with same type
L4CFD:   PUSH cx
	MOV dx,400H
	CALL near ptr L6D75		; add DE to id table

L4D04:	MOV al,byte ptr [bx]

         CALL near ptr L6D7A                 ; add byte to id table

	TEST byte ptr [bx],128
	pushf
	DEC bx
	popf
         JZ near ptr L4D04                 ; until end of identifier

	PUSH bx
	CALL near ptr L6D7A		; add byte to id table
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6DC6		; add length
	POP bx
	POP cx
         DEC ch
	JNZ near ptr L4CFD                 ; repeat for variables with same type

         POP cx

         mov bp,sp
	XCHG [bp],bx

         XOR al, al
	MOV byte ptr L7B90,al		; 0 = not absolute, 255 = absolute

         CALL near ptr L4F52

         POP bx
	POP cx

         DEC ch
	JNZ near ptr L4CE1                 ; repeat for variables with different type

L4D2B:
         MOV ch,cl                     ; B = total number of variables

         PUSH cx

	MOV bx,word ptr L7B73
	PUSH bx

         MOV bx,word ptr L7B83              ; save data start address
         PUSH bx                    ; equals 0 if it is absolute code

	MOV bx,word ptr L7B89
	PUSH bx

	MOV al,byte ptr L7B87
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	MOV al,byte ptr L7B88
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

         MOV al,byte ptr L7B99               ; 0 = no overlay, 255 = overlay
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	MOV al,byte ptr L7B97		; 0 = proc, 1 = func
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	MOV bx,offset L7B94
         INC byte ptr [bx]                   ; increase level

         CALL near ptr L469E

	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B97,al		; restore: 0 = proc, 1 = func

         POP ax
	xchg ah,al
	sahf
         MOV byte ptr L7B99,al               ; 0 = no overlay, 255 = overlay

	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B88,al

	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B87,al

	POP bx
	MOV word ptr L7B89,bx

	POP bx
         MOV word ptr L7B83,bx              ; restore data start address
	MOV word ptr L7B85,dx

	MOV al,bh
	OR al, bl
	JZ near ptr L4D79

	SBB bx,dx
	JZ near ptr L4D79

	CALL near ptr O_LDBC

	XCHG dx,bx
	CALL near ptr O_LDHL

	MOV bx,offset _L0508		; LIB, heap alloc, clear
	CALL near ptr O_CALHL

L4D79:	POP bx
	POP cx
	INC ch
	DEC ch
         JZ near ptr L4DF3                 ; jump if no variables

	CALL near ptr O_CODE
	DB 2
	DB 0FDH,0E1H		; POP IY

L4D86:	PUSH cx
	INC bx
	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]
	ADD bx,dx
	PUSH bx
	DEC bx
	DEC bx
L4D8F:	TEST byte ptr [bx],128
	pushf
	DEC bx
	popf
	JZ near ptr L4D8F
	CALL near ptr L5276		; id info at 7B5C
	MOV al,byte ptr L7B57
	OR al, al
	JNZ near ptr L4DD4

	MOV al,byte ptr L7B5C
	CMP al, 3
	JC near ptr L4DBD
	JZ near ptr L4DE6

	CMP al, 4			; type = POINTER ?
	JZ near ptr L4DE3

	CMP al, 8
	JC near ptr L4DBD
	JZ near ptr L4DE6

	CMP al, 0EH			; type = LONGINT ?
	JZ near ptr POPLONG		; jump to generate code for it

	CMP al, 0AH
	JNC near ptr L4DE3

	; output code to pop REAL
	CALL near ptr O_CODE
	DB 3
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC

	JMP near ptr  L4DE6

POPLONG: CALL near ptr O_CODE
	DB 2
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE

	JMP near ptr  L4DE6

L4DBD:	CALL near ptr O_POPHL
	MOV bx,word ptr L7B58		; HL = lvalue of current id
	CALL near ptr O_LDDE		; output: 'LD DE,value HL'
	MOV bx,word ptr L7B62
	CALL near ptr O_LDBC

	CALL near ptr O_CODE
	DB 2
	DB 0EDH,0B0H		; LDIR

	JMP near ptr  L4DE9

L4DD4:	XOR al, al
	MOV byte ptr L7B57,al
	MOV al,4
	MOV byte ptr L7B5C,al		; type = pointer
	MOV bx,0002
	MOV word ptr L7B62,bx		; lenght = 2

L4DE3:	CALL near ptr O_POPHL

L4DE6:	CALL near ptr L661B
L4DE9:	POP bx
	POP cx
	DEC ch
	JNZ near ptr L4D86

	CALL near ptr O_CODE
	DB 2
	DB 0FDH,0E5H		; PUSH IY

L4DF3:
         CALL near ptr L52FC                 ; start begin end part

         MOV bx,offset L7B94
         DEC byte ptr [bx]                   ; decrease level

         MOV al,byte ptr L7B97               ; 0 = proc, 1 = func
	OR al, al
         JZ near ptr L4E46                 ; jump if proc

         MOV bx,word ptr L7B89
	MOV al,byte ptr L7B87
	CMP al, 8			; type = STRING ?
	JNZ near ptr L4E24		; jump if not STRING

	MOV ch,al

	CALL near ptr O_CODE
	DB 2
         DB 0FDH,0E1H               ; POP IY, save return address

	MOV al,21H
	CALL near ptr O_OPHL		; LD HL, HL

	MOV bx,offset _L053A		; LIB, clear
	CALL near ptr O_CALHL

	CALL near ptr O_CODE
	DB 2
         DB 0FDH,0E5H               ; PUSH IY, restore return address

         ; stack: STRING
         ;        return address

	JMP near ptr  L4E46

L4E24:	CMP al, 9
	JNZ near ptr L4E35

	MOV al,21H
	CALL near ptr O_OPHL		; LD HL, HL

	MOV bx,offset _L052C		; LIB, GETFLT
	CALL near ptr O_CALHL		; CALL _L052C
	JMP near ptr  L4E46

L4E35:	MOV al,2AH
	CALL near ptr O_OPHL		; LD HL,( HL )

	MOV al,byte ptr L7B88
	DEC al
	JNZ near ptr L4E46

	CALL near ptr O_CODE
	DB 2
	DB 26H,00H		; LD H,0

L4E46:   MOV bx,word ptr L7B83
	MOV al,bh
	OR al, bl
         JZ near ptr L4E78                 ; jump if absolute code

         ; HL = data start address

         MOV dx,word ptr L7B85
	SBB bx,dx
	JZ near ptr L4E74

         MOV al,byte ptr L7B97               ; 0 = proc, 1 = func
	OR al, al
	JZ near ptr L4E65		; no EXX if a procedure call

	MOV al,byte ptr L7B87
         CMP al, 8                       ; type = STRING ?

         MOV al,0D9H                  ; opcode: EXX
         CALLNZ O_BYTE             ; yes, output EXX

L4E65:	CALL near ptr O_LDBC
	XCHG dx,bx
	CALL near ptr O_LDDE		; output: 'LD DE,value HL'

         MOV bx,offset _L0522               ; LIB, heap de-alloc
         CALL near ptr O_CALHL

;         JR L4E79

L4E74:   ; recursive code

         MOV al,byte ptr L7B97               ; 0 = proc, 1 = func
	OR al, al
         JZ near ptr L4E76                 ; no EXX if a procedure call

	MOV al,byte ptr L7B87
         CMP al, 8                       ; type = STRING ?

         MOV al,0D9H                  ; opcode: EXX
         CALLNZ O_BYTE             ; yes, output EXX

L4E76:
         MOV al,byte ptr L7B99
         OR al, al
         JZ near ptr L4E78                 ; jump if no overlay

         POP dx                     ; DE = address of high byte of PROC/FUNC
                                    ; struct length
         PUSH dx

         MOV bx,12
         ADD bx,dx
         MOV al,byte ptr [bx]
         DEC bx
         MOV bl,byte ptr [bx]
         MOV bh,al                     ; HL = address of overlay proc

         INC bx                     ; skip CALL instruction
         INC bx
         INC bx

         CALL near ptr O_LDHL                ; output: 'LD HL,value HL'

         MOV bx,offset _OVERLAYREC1         ; LIB, Load only overlay code
	CALL near ptr O_JPHL

         JMP near ptr  L4E79

L4E78:   CALL near ptr O_CODE                ; output: ret
	DB 1
	DB 0C9H			; RET

L4E79:   CALL near ptr L6F48                 ; match(';')

         POP dx                     ; DE = address of high byte of PROC/FUNC
                                    ; struct length

         POP bx
         MOV word ptr L7B73,bx              ; HL = address after PROC/FUNC struct length
	MOV word ptr L7B75,bx

         POP bx
         MOV word ptr L7B7B,bx              ; HL = position after declared PROC/FUNC
                                    ;      name
         XCHG dx,bx
         ; HL = high byte of struct length
         ; DE = position after declared PROC/FUNC name
	RET

L4E8A:	MOV bx,word ptr L7B73		; HL = address to add an identifier
L4E8D:	MOV dx,word ptr L7B7B		; HL = start of identifier list
	OR al, al
	SBB bx,dx
	pushf
	ADD bx,dx
	popf
	RETZ 			; quit if no identifiers
	INC bx
	MOV dl,byte ptr [bx]		; DE = offset
	INC bx
	MOV dh,byte ptr [bx]
	ADD bx,dx
	MOV al,byte ptr [bx]
	CMP al, 6
	JZ near ptr L4EA4
	CMP al, 5
	JNZ near ptr L4E8D
L4EA4:	PUSH bx
	DEC bx
	DEC bx
L4EA7:	TEST byte ptr [bx],128
	pushf
	DEC bx
	popf
	JZ near ptr L4EA7
	MOV al,byte ptr [bx]		; A = byte after name
	OR al, al

	CALL near ptr L72DA		; NonZero --> error
	DB 49H			; error 73: Undefined FORWARD procedure(s)

	POP bx
	JMP near ptr  L4E8D

L4EB5:	; in:	-
	; out:	HL = top of stack before variable name declarations
	;	 B = number of variable name declarations
	MOV bx,word ptr L7B73
	PUSH bx
	MOV ch,0
L4EBB:	PUSH cx
	MOV dh,4
	MOV al,byte ptr L7B91
	MOV dl,al
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6D87		; add identifier to id table
	CALL near ptr L6D7A		; add byte to id table
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6DC6		; add length
	POP cx
	INC ch
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L4EBB		; yes, an other declaration
	POP bx
	RET

L4EDD:	MOV bx,word ptr L7B73
	PUSH bx
	CALL near ptr L4F9B		; parse every possible type

	POP bx			; address where to stop reference search
	CALL near ptr L5295		; update pointer references

	CALL near ptr L6E76		; followed by 'ABSOLUTE'?
	DW L7562 		; start of reserved word: ABSOLUTE

	MOV al,0			; assume no 'absolute'
	JNZ near ptr L4F14		; no, continue

	MOV al,byte ptr L7B91
	OR al, al

	CALL near ptr L72DA		; NonZero --> error
	DB 4BH			; error 75: Illegal use of ABSOLUTE

	MOV cx,400H		; variable identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
	JNZ near ptr L4F0C		; no variable identifier, try address

	MOV al,byte ptr [bx]
	MOV byte ptr L7B8F,al		; 0 = no VAR, 255 = VAR
	DEC bx
	MOV dh,byte ptr [bx]		; DE = lvalue of variable
	DEC bx
	MOV dl,byte ptr [bx]
	XCHG dx,bx
	JMP near ptr  L4F0F

L4F0C:	CALL near ptr L69F2		; parse integer constant

L4F0F:	MOV word ptr L7B7F,bx
	MOV al,0FFH		; absolute anyway

L4F14:	MOV byte ptr L7B90,al		; 0 = not absolute, 255 = absolute
	RET

L4F18:
	; L7B5C..L7B63 filled in with type info
	CALL near ptr L4FC8		; find type identifier
				; and fill L7B5C..L7B63
	JZ near ptr L4F181		; jump if type identifier found

	CALL near ptr L6E76
	DW L754D 		; start of reserved word: FILE

	CALL near ptr L72DA		; NonZero --> error
	DB 24H			; error 36: Type identifier expected

	MOV bx,offset FILEDEF		; address of definition of type
	MOV word ptr L7B5A,bx		; save address to definition info
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)

L4F181:
	XOR al, al
	MOV byte ptr L7B90,al		; 0 = not absolute, 255 = absolute

	MOV al,byte ptr L7B8F		; 0 = no VAR, 255 = VAR
	OR al, al
	RETNZ 			; return if VAR
	MOV al,byte ptr L7B5C
	CMP al, 5
	RETC 
	CMP al, 8
	RETNC 

	; error: 5 (typed file), 6 (text) and 7 (untyped file)
	CALL near ptr L72E1		; no condition
	DB 43H			; error 67: Files must be variable parameters

L4F35:	CALL near ptr L4EB5		; parse variable names
	PUSH bx			; save variable position
	PUSH cx			; save number of names parsed
	CALL near ptr L6F40		; match(':')
	XOR al, al
	MOV byte ptr L7B8F,al		; 0 = no VAR, 255 = VAR
	CALL near ptr L4EDD
	POP cx
	MOV al,byte ptr L7B90		; 0 = not absolute, 255 = absolute
	OR al, al			; absolute?
	JZ near ptr L4F51		; no, continue
	MOV al,ch
	DEC al

	CALL near ptr L72DA		; NonZero --> error
	DB 4BH			; error 75: Illegal use of ABSOLUTE

L4F51:	POP bx

L4F52:	; in:	B = number of variable names parsed before the type
	PUSH cx
	PUSH bx
	MOV al,byte ptr L7B8F		; 0 = no VAR, 255 = VAR
	MOV bx,0002		; assume size = 2 if VAR
	OR al, al
	JNZ near ptr L4F60		; jump if VAR
	MOV bx,word ptr L7B62		; get real size

L4F60:	XCHG dx,bx
	MOV al,byte ptr L7B91
	OR al, al
	JNZ near ptr L4F72
	MOV al,byte ptr L7B90		; 0 = not absolute, 255 = absolute
	OR al, al			; variable at absolute address ?
	JNZ near ptr L4F72		; yes, no allocation

	CALL near ptr L6C30		; allocate data space, HL = address
	JMP near ptr  L4F7B

L4F72:	MOV bx,word ptr L7B7F
	PUSH bx
	ADD bx,dx
	MOV word ptr L7B7F,bx
	POP bx
L4F7B:	XCHG dx,bx 		; DE = address of variable space
	POP bx			; HL = start of declaration
	DEC bx
L4F7E:	DEC bx
	TEST byte ptr [bx],128
	JZ near ptr L4F7E
	DEC bx			; HL = points to byte after name
	MOV al,byte ptr L7B8F		; 0 = no VAR, 255 = VAR
	MOV byte ptr [bx],al		; place on byte after name
	DEC bx
	MOV byte ptr [bx],dh		; high byte of variable space address
	DEC bx
	MOV byte ptr [bx],dl		; put low byte
	DEC bx
	MOV dx,word ptr L7B5A		; type info address
	MOV byte ptr [bx],dh
	DEC bx
	MOV byte ptr [bx],dl
	DEC bx			; point to high byte of offset
	DEC bx			; point to low byte of offset
	DEC bx			; address of next possible declaration
	POP cx
	DEC ch
	JNZ near ptr L4F52		; repeat for the next variable
				; of the same type
	RET

L4F9B:	; in:	HL = start of identifier list
	; out:	-
	CALL near ptr L4FC8		; find type identifier
	RETZ 			; quit if found

	CALL near ptr L6E76
	DW L7542 		; start of reserved word: PACKED
				; just reads(eats) it away

	CALL near ptr L4FDB		; parses an ARRAY
	RETZ 			; quit if an ARRAY was parsed

	CALL near ptr L5039		; parses a RECORD
	RETZ 			; quit if a RECORD was parsed

	CALL near ptr L5106		; parses a SET
	RETZ 			; quit if a SET was parsed

	CALL near ptr L5140
	RETZ 

	CALL near ptr L516B		; parses a FILE
	RETZ 			; quit if a FILE was parsed

	CALL near ptr L51A5		; parses a STRING type
	RETZ 			; quit if a STRING was parsed

	CALL near ptr L51C5		; parses a SCALAR type
	RETZ 			; quit if a SCALAR type was parsed

	CALL near ptr L5210		; parses a subrange-type
	RETZ 			; quit if a <m>..<n> parsed

	CALL near ptr L72E1		; no condition
	DB 24H			; error 36: Type identifier expected

L4FC8:	; SYNTAX: type-identifier ::= identifier
	; in:	IX = address of current type identifier in text
	; out:	Z = 0, type identifier found and L7B5C..L7B63 filled in
	MOV cx,300H		; type identifier ?
	CALL near ptr L6E54		; check if current in id list, types
				; HL = address of info
	RETNZ 			; quit if type identifier not found

	; HL = address of pointer to definition of type
	MOV dh,byte ptr [bx]		; DE = address of type definition
	DEC bx
	MOV dl,byte ptr [bx]
	XCHG dx,bx
	MOV word ptr L7B5A,bx		; save address to definition info
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)
	XOR al, al
	RET

L4FDB:	; parses a complete ARRAY type
	CALL near ptr L6E76
	DW L7548 		; start of reserved word: ARRAY
	RETNZ 

	CALL near ptr L6F30		; match('[')

	MOV ch,0			; 0 indices

L4FE6:	PUSH cx
	CALL near ptr L523B		; parse a simple-type = index-type
	POP cx

	MOV bx,word ptr L7B5A		; HL = address of type info
	PUSH bx

	MOV bx,word ptr L7B60		; HL = maximum value
	MOV dx,word ptr L7B5E		; DE = minimum value
	OR al, al
	SBB bx,dx
	INC bx
	MOV al,bh
	OR al, bl

	CALL near ptr L72D4		; Zero --> error
	DB 62H			; error 98: Memory overflow

	PUSH bx			; push range size

	INC ch			; increase # indices
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L4FE6		; jump if ',' matched

	PUSH cx

	CALL near ptr L6F38		; match(']')
	CALL near ptr L6F88		; match('OF')
	CALL near ptr L4F9B		; parse every possible type

	POP cx			; B = # indices

	; parsed: 0..15 , 15..32
	; stack: 	<type info>	info of 0..15
	;		<range size>	16
	;		<type info>	info of 15..32
	;		<range size>	18

L5012:	MOV bx,word ptr L7B5A		; HL = address of last type info
	MOV word ptr L7B5E,bx

	MOV bx,word ptr L7B62		; HL = total size of array declaration

	POP dx			; DE = range size of last

	PUSH cx			; save count
	CALL near ptr L729A		; multiply HL = HL * DE

	CALL near ptr L72C8		; carry set --> error
	DB 62H			; error 98: Memory overflow
	POP cx			; restore count

	MOV word ptr L7B62,bx		; set new size of array declaration

	POP bx
	MOV word ptr L7B60,bx		; HL = address to info about index-type
	MOV al,1
	MOV byte ptr L7B5C,al
	PUSH cx
	CALL near ptr L5254		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct
	POP cx
	DEC ch
	JNZ near ptr L5012
	RET

L5039:	; parses a complete RECORD type
	CALL near ptr L6E76
	DW L7554 		; start of reserved word: RECORD
	RETNZ 
	MOV al,byte ptr L7B9A
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,byte ptr L7B91
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV bx,offset L7B92
	INC byte ptr [bx] 		; increase depth within record ?
	MOV al,byte ptr [bx]
	MOV byte ptr L7B91,al
	MOV bx,word ptr L7B7F
	PUSH bx
	MOV bx,word ptr L7B81
	PUSH bx
	MOV bx,0000
	MOV word ptr L7B7F,bx
	MOV word ptr L7B81,bx
	XOR al, al
	MOV byte ptr L7B9A,al
	CALL near ptr L508B
	MOV bx,word ptr L7B81
	MOV word ptr L7B62,bx
	POP bx
	MOV word ptr L7B81,bx
	POP bx
	MOV word ptr L7B7F,bx
	MOV al,byte ptr L7B91
	MOV byte ptr L7B5D,al
	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B91,al
	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B9A,al
	MOV al,2
	MOV byte ptr L7B5C,al
	JMP near ptr  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L508B:	CALL near ptr L50F9
	RETZ 
	CALL near ptr L6E76
	DW L75DA 		; start of reserved word: CASE
	JZ near ptr L50B0
	CALL near ptr L4F35
	MOV bx,word ptr L7B7F
	MOV dx,word ptr L7B81
	OR al, al
	SBB bx,dx
	JC near ptr L50A9
	ADD bx,dx
	MOV word ptr L7B81,bx
L50A9:	CALL near ptr L6F0F		; match(';'), if present
	JZ near ptr L508B		; jump if ';' matched
	JMP near ptr  L50E8

L50B0:	CALL near ptr L4FC8		; find type identifier
	CALLNZ L4F35

	CALL near ptr L6F88		; match('OF')

L50B9:	CALL near ptr L50F9
	RETZ 

	MOV bx,word ptr L7B7F
	PUSH bx

L50C1:	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L50C1		; jump if ',' matched
	CALL near ptr L6F40		; match(':')
	CALL near ptr L6F66		; match('(')
	MOV al,byte ptr L7B9A
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,0FFH
	MOV byte ptr L7B9A,al
	CALL near ptr L508B
	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B9A,al
	POP bx
	MOV word ptr L7B7F,bx
	CALL near ptr L6F0F		; match(';'), if present
	JZ near ptr L50B9		; jump if ';' matched
L50E8:	MOV al,byte ptr L7B9A
	OR al, al
	JNZ near ptr L6F6E		 ; match(')')
	CALL near ptr L6E76
	DW L7530 		; start of reserved word: END
	RETZ 

	CALL near ptr L72E1		; no condition
	DB 0EH			; error 14: END expected

L50F9:	MOV al,byte ptr L7B9A
	OR al, al
	JNZ near ptr L6F1F		; match(')'), if present
				; and return
	CALL near ptr L6E76
	DW L7530 		; start of reserved word: END
	RET

L5106:	; parses a complete SET type
	CALL near ptr L6E76
	DW L7551 		; start of reserved word: SET
	RETNZ 
	CALL near ptr L6F88		; match('OF')
	CALL near ptr L523B		; parse a simple-type = base-type
	MOV bx,word ptr L7B60
	MOV dx,word ptr L7B5E
	MOV al,bh
	OR al, dh

	CALL near ptr L72DA		; NonZero --> error
	DB 46H			; error 70: Set base type out of range

	SHR bl,1
	SHR bl,1
	SHR bl,1
	SHR dl,1
	SHR dl,1
	SHR dl,1
	MOV al,bl
	INC al
	SUB al, dl
	MOV bl,al
	MOV word ptr L7B62,bx
	MOV bx,word ptr L7B5A
	MOV word ptr L7B5E,bx
	MOV al,3
	MOV byte ptr L7B5C,al		; type = SET
	JMP near ptr  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L5140:	CALL near ptr L6F27		; match('^')
	RETNZ 
	MOV dx,0000
	CALL near ptr L6D75		; add DE to id table
	MOV bx,word ptr L7B73
	PUSH bx
	CALL near ptr L6DBA
	CALL near ptr L6DC6		; add length
	POP bx
	MOV word ptr L7B5E,bx
	MOV al,4			; type = POINTER
	MOV byte ptr L7B5C,al
	MOV al,0FFH
	MOV byte ptr L7B5D,al
	MOV bx,0002
	MOV word ptr L7B62,bx		; length = 2 bytes
	JMP near ptr  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L516B:	; parses a complete FILE type
	CALL near ptr L6E76
	DW L754D 		; start of reserved word: FILE
	RETNZ 			; return if no FILE found

	CALL near ptr L6E76
	DW L7560 		; start of reserved word: OF
	JNZ near ptr L5197		; jump if no OF found, untyped file found

	CALL near ptr L4F9B		; parse every possible type

	MOV al,byte ptr L7B5C
	CMP al, 5
	JC near ptr L518A		; < 5, a typed file
	CMP al, 8
	JNC near ptr L518A		; jump if >= 8

	CALL near ptr L72E1		; no condition
	DB 44H			; error 68: File components can not be files

L518A:	MOV bx,word ptr L7B5A
	MOV word ptr L7B5E,bx
	MOV al,5			; typed file does have a sector buffer
         MOV bx,offset DOS_LEN-128          ; 33e bug ????? ; length of FIB with sector buffer
	JMP near ptr  L519C

L5197:	MOV al,7			; untyped file has no sector buffer
         MOV bx,offset DOS_LEN-128          ; length of FIB without sector buffer

L519C:	MOV byte ptr L7B5C,al		; save type (5, 6 or 7)
	MOV word ptr L7B62,bx		; save length
	JMP near ptr  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L51A5:	; parses a complete STRING type
	CALL near ptr L6E76
	DW L755A 		; start of reserved word: STRING
	RETNZ 

	CALL near ptr L6F30		; match('[')

	CALL near ptr L69F2		; parse integer constant

	INC bh			; length >= 256 ?
	DEC bh

	CALL near ptr L72DA		; NonZero --> error
	DB 31H			; error 49: Invalid String length

	INC bl			; length = 0 ?
	DEC bl

	CALL near ptr L72D4		; Zero --> error
	DB 31H			; error 49: Invalid String length

	CALL near ptr L6F38		; match(']')
	INC bx			; length + 1 = string + count byte
	MOV al,8			; type = STRING
	JMP near ptr  L519C

L51C5:	; SYNTAX: scalar-type ::= ( identifier {, identifier } )
	; parses a complete SCALAR type
	CALL near ptr L6F1B		; match('('), if present
	RETNZ 			; return if '(' not matched

	MOV bx,-1 		; HL = upper bound = -1

	; (Maandag,Dinsdag,Woensdag,Donderdag,Vrijdag)
	; (0,	  1,	 2,	 3,	  4	)

L51CC:	PUSH bx
	MOV dx,200H		; constant
	CALL near ptr L6D75		; add DE to id table
	CALL near ptr L6D87		; add identifier to id table
	MOV al,byte ptr L7B93
	CALL near ptr L6D7A		; add byte to id table

	POP dx
	INC dx			; increase upper bound, value of constant
	PUSH dx

	CALL near ptr L6D75		; add DE to id table, value of constant
	CALL near ptr L6DC6		; add length

	POP bx			; HL = upper bound

	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L51CC		; jump if ',' matched

	CALL near ptr L6F6E		; match(')')

	PUSH bx

	MOV bx,offset L7B93
	MOV al,byte ptr [bx]
	INC byte ptr [bx] 		; increase type for next SCALAR

	POP bx			; HL = upper bound

	MOV dx,0000		; SCALAR lower bound = 0

L51F8:	MOV byte ptr L7B5C,al		; save type
	MOV word ptr L7B5E,dx		; save lower bound
	MOV word ptr L7B60,bx		; save upper bound
	MOV al,dh			; difference >= 256 ?
	OR al, bh
	MOV bx,0001		; assume one byte
	JZ near ptr L520A		; jump if only one byte needed

	INC bx			; no, two bytes needed

L520A:	MOV word ptr L7B62,bx		; save size
	JMP near ptr  L5254 		; add L7B5C..L7B63 as new struct
				; L7B5A = address of this struct

L5210:	; SYNTAX: subrange-type ::= constant .. constant
	; parses a complete <m>..<n> type
	MOV al,0AH 		; default type = INTEGER
	MOV byte ptr DEF_TYPE,al

	CALL near ptr L6A0D		; parse a constant of any type
	RETNZ 			; return if not succeeded

	MOV al,ch
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	CMP al, 0AH			; type = INTEGER, BOOLEAN or CHAR ?
	CALL near ptr L72C8		; carry set --> error (type < 0AH)
	DB 33H			; error 51: Invalid subrange base type

	CMP al, 0EH			; type = LONGINT ?
	CALL near ptr L72D4		; Zero --> error
	DB 33H			; error 51: Invalid subrange base type

	PUSH bx			; save value of <m>

	CALL near ptr L6E76
	DW L7580 		; start of reserved word: ..

	CALL near ptr L72DA		; NonZero --> error
	DB 0BH			; error 11: '..' expected

	CALL near ptr L69EA		; parse a constant of any type
				; error if not found

	POP dx			; HL = value of <n>
				; DE = value of <m>
	POP ax
	xchg ah,al
	sahf			; A = type of <m>
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CMP al, ch			; <m> type = <n> type ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	CALL near ptr L728D		; check if lower bound <= upper bound

	CALL near ptr L72C8		; carry set --> error
	DB 34H			; error 52: Lower bound > upper bound

	POP ax
	xchg ah,al
	sahf			; A = type of <m>
	JMP near ptr  L51F8

L523B:	; SYNTAX: base-type   ::=
	;	 index-type  ::=
	;	 simple-type ::= scalar-type | subrange-type | type-identifier
	CALL near ptr L5210		; parses a subrange-type
	RETZ 			; quit if a <m>..<n> parsed

	CALL near ptr L51C5		; parses a SCALAR type
	RETZ 			; quit if a SCALAR type was parsed

	CALL near ptr L4FC8		; find type identifier

	CALL near ptr L72DA		; NonZero --> error
	DB 1EH			; error 30: Simple type expected

	MOV al,byte ptr L7B5C
	CMP al, 0AH
	RETNC 			; return if type = INTEGER, BOOLEAN or CHAR

	CALL near ptr L72E1		; no condition
	DB 1EH			; error 30: Simple type expected

L5254:	; add L7B5C .. L7B63
	; out:	A = 0, NonCarry, Z-flag = 1
	;	L7B5A points to last added type
	MOV dx,800H
	CALL near ptr L6D75		; add DE to id table
	MOV bx,word ptr L7B73
	MOV word ptr L7B5A,bx		; save for connection with last added type

	MOV bx,offset L7B5C
	MOV ch,8

L5265:	MOV al,byte ptr [bx]
	CALL near ptr L6D7A		; add byte to id table
	INC bx
	DEC ch
	JNZ near ptr L5265

	CALL near ptr L6DC6		; add length
	XOR al, al
	RET

L5271:	; 8 bytes from HL (down) to 7B69 (up)
	MOV dx,offset L7B69
	JMP near ptr  L528A

L5276:	; in:	HL = address after word in id table
	; out:	byte at (HL) moved to L7B57
	;	address at (HL-1), (HL-2) move to L7B58
	;	8 bytes from address (HL-3), (HL-4) to L7B5C
	MOV al,byte ptr [bx]		; A = 1e byte after word
	DEC bx
	MOV byte ptr L7B57,al
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	MOV word ptr L7B58,dx		; save lvalue of id
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	XCHG dx,bx

L5287:	; 8 bytes from HL (down) to 7B5C (up)
	MOV dx,offset L7B5C

L528A:	PUSH cx
	; copy from HL to DE in the opposite directions
	MOV ch,8
L528D:	MOV al,byte ptr [bx]
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	DEC bx
	INC dx
	DEC ch
	JNZ near ptr L528D
	POP cx
	RET

L5295:	; update pointer references
	; in:	HL = top of symbol table
	MOV word ptr L7B79,bx		; address where to stop reference search
	MOV bx,word ptr L7B73

L529B:	MOV cx,word ptr L7B79
	OR al, al
	SBB bx,cx
	pushf
	ADD bx,cx
	popf
	RETZ 			; quit if equal (end of struct reached)
	INC bx
	MOV cl,byte ptr [bx]		; BC = length of added struct
	INC bx
	MOV ch,byte ptr [bx]
	ADD bx,cx
	MOV al,byte ptr [bx]		; highest byte of struct = 8 ?
	CMP al, 8
	JNZ near ptr L529B		; search for next while not 8

	MOV byte ptr [bx],0		; yes, make 0 ?!?
	PUSH bx
	DEC bx
	DEC bx
	MOV al,byte ptr [bx]
	CMP al, 4			; type of struct = POINTER ?
	JNZ near ptr L52F8		; jump if not a POINTER, continue loop

	DEC bx
	MOV al,byte ptr [bx]
	OR al, al
	JZ near ptr L52F8		; jump if zero, no update necessary

	MOV byte ptr [bx],0
	DEC bx
	PUSH bx
	MOV dl,byte ptr [bx]
	DEC bx
	MOV dh,byte ptr [bx]

	MOV bx,word ptr L7B73

L52C7:	MOV cx,word ptr L7B77		; BC = absolute top of id list
	OR al, al
	SBB bx,cx
	pushf
	ADD bx,cx
	popf

	CALL near ptr L72D4		; Zero --> error
	DB 2AH			; error 42: Undefined pointer type in
				;	   preceding type definitions
	INC bx
	MOV cl,byte ptr [bx]
	INC bx
	MOV ch,byte ptr [bx]
	ADD bx,cx
	MOV al,byte ptr [bx]
	CMP al, 3
	JNZ near ptr L52C7

	PUSH bx
	PUSH dx
	DEC bx
	DEC bx
L52E1:	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, byte ptr [bx]
	JZ near ptr L52E9
	POP dx
	POP bx
	JMP near ptr  L52C7

L52E9:	TEST byte ptr [bx],128
	pushf
	DEC bx
	DEC dx
	popf
	JZ near ptr L52E1
	POP cx
	POP cx
	MOV ch,byte ptr [bx]
	DEC bx
	MOV cl,byte ptr [bx]
	POP bx
	MOV byte ptr [bx],cl
	DEC bx
	MOV byte ptr [bx],ch
L52F8:	POP bx
	JMP near ptr  L529B

L52FC:	XOR al, al
	MOV byte ptr L7B95,al
	MOV byte ptr L7BC9,al

         CALL near ptr L5377                 ; statements ended by 'END'

	MOV word ptr L7BA4,di
	CALL near ptr O_JPHL

         MOV bx,word ptr L7B73

L5310:	MOV dx,word ptr L7B75
	OR al, al
	SBB bx,dx
	ADD bx,dx
	JNC near ptr L5363
	INC bx
	MOV cl,byte ptr [bx]
	INC bx
	MOV ch,byte ptr [bx]
	INC bx
	MOV al,byte ptr [bx]
	INC bx
	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]
	PUSH bx
	PUSH cx
	MOV ch,al
	MOV al,dh
	OR al, dl
	JZ near ptr L533A
	XCHG dx,bx
	DEC bx
	MOV al,byte ptr [bx]
	MOV cl,al
	INC al

	CALL near ptr L72D4		; Zero --> error
	DB 28H			; error 40: Undefined label

	DEC bx
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	JMP near ptr  L5340

L533A:	MOV dx,word ptr L7BA4
	MOV cl,0
L5340:	POP bx
	MOV al,ch
	SUB al, cl
	JNZ near ptr L534A

         CALL near ptr L6C42                 ; update address at HL with contents of DE

	JMP near ptr  L5360

L534A:	CALL near ptr L72C8		; carry set --> error
	DB 47H			; error 71: Invalid GOTO

	PUSH dx
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6C3F                 ; update address at HL with current address
	POP ax
	xchg ah,al
	sahf
	MOV ch,al

L5355:	CALL near ptr O_POPHL
	DEC ch
	JNZ near ptr L5355

	MOV al,0C3H		; opcode: JP
	POP bx
	CALL near ptr O_OPHL		; JP HL

L5360:	POP bx
	JMP near ptr  L5310

L5363:	MOV bx,word ptr L7BA4
	INC bx
	PUSH di
	POP dx
	DEC dx
	DEC dx
	OR al, al
	SBB bx,dx
	pushf
	ADD bx,dx
	popf
         JNZ near ptr L6C3F                ; update address at HL with current address
	DEC bx
	JMP near ptr  L6CC2

L5377:   ; statement { ; statement } end
	CALL near ptr L5385		; statement

	CALL near ptr L6E76		; next word is END ?
	DW L7530 		; start of reserved word: END
	RETZ 			; yes, return

	CALL near ptr L6F50		; match(';')
	JMP near ptr  L5377 		; repeat for next statement

L5385:	MOV al,0AH 		; default type = INTEGER
	MOV byte ptr DEF_TYPE,al
	MOV al,0FFH
	MOV byte ptr L7B98,al
	MOV al,byte ptr L7B9D		; compiler directives
	MOV byte ptr L7B9E,al		; save them
	TEST al,8			; 1 = User Interrupt on
	JZ near ptr L539C		; jump if off

	MOV al,0CFH		; 0CFH = RST 0008H, patch
				; 0FFH = RST 0038H
	MOV byte ptr L7BA0,al

	CALL near ptr O_BYTE

L539C:	CALL near ptr L6E5A
	DB 2			; 2 bytes following
	DW L75BB 		; start of reserved word list:
				; BEGIN, IF, WHILE, REPEAT, FOR
				; CASE, GOTO, WITH, INLINE
	JZ near ptr L53CB		; start code of found reserved word

	CALL near ptr L67B2
	JZ near ptr L57EA

	MOV cx,500H		; procedure identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
         JZ near ptr L573D                 ; jump if procedure

	MOV cx,100H		; label identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
	JZ near ptr L53D0		; jump if label

	MOV cx,600H		; function identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
         JZ near ptr L591F

	CALL near ptr L6E5A
	DB 2			; 2 byte following
	DW L7638 		; start of reserved word list:
				; standard library procedure's
				; WRITELN .. BIOS, 47
	RETNZ 

L53CB:	; jumps to the address at hl
	; in:	HL = address of an address
	; out:	-
	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]
	XCHG dx,bx
	JMP bx

L53D0:	CALL near ptr L6F40		; match(':')
	MOV al,byte ptr L7B94
	CMP al, byte ptr [bx]

	CALL near ptr L72DA		; NonZero --> error
	DB 48H			; error 72: Label not within current block

	DEC bx
	MOV al,byte ptr [bx]
	INC al

	CALL near ptr L72DA		; NonZero --> error
	DB 2BH			; error 43: Duplicate identifier or label

	MOV al,byte ptr L7B95
	MOV byte ptr [bx],al
	PUSH di
	POP dx
	DEC bx
	MOV byte ptr [bx],dh
	DEC bx
	MOV byte ptr [bx],dl
	JMP near ptr  L5385 		; next statement

L53EF:	CALL near ptr L5EB0		; parse boolean expression

	CALL near ptr O_CODE
	DB 3
	DB 0CBH,45H		; BIT 0,L
	DB 0CAH			; opcode of 'JP Z,'

	PUSH di
	CALL near ptr O_HL		; out: address for 'JP Z,'

	CALL near ptr L6E76
	DW L756A 		; start of reserved word: THEN

	CALL near ptr L72DA		; NonZero --> error
	DB 11H			; error 17: THEN expected

	CALL near ptr L5385		; statement

         CALL near ptr L6E76
	DW L756E 		; start of reserved word: ELSE
	JNZ near ptr L5420

         CALL near ptr O_C3

         POP bx
	PUSH di
	CALL near ptr O_HL

         CALL near ptr L6C3F                 ; update address at HL with current address
	CALL near ptr L5385		; statement

L5420:   POP bx
         JMP near ptr  L6C3F                   ; update address at HL with current address

BOOLOPER:DB 0			; Zero = lowest level
BOOLOPTIM:DB 0			; Zero = no optimization in code
				; NonZero = optimize code for boolean
				;	   evaluation

L5424:	; while-statement ::= WHILE expression do statement
	XOR al, al
	MOV byte ptr BOOLOPER,al		; default no operator
	DEC al
	MOV byte ptr BOOLOPTIM,al		; boolean optimize on
	PUSH di
	CALL near ptr L5EB0		; parse boolean expression
	CALL near ptr L6E76
	DW L7572 		; start of reserved word: DO

	CALL near ptr L72DA		; NonZero --> error
	DB 0DH			; error 13: DO expected

	CALL near ptr O_CODE
	DB 3
	DB 0CBH,45H		; BIT 0,L
	DB 0CAH			; opcode of 'JP Z,'

	PUSH di
	CALL near ptr O_HL

	CALL near ptr L5385		; statement

	POP dx
	POP bx

	MOV al,0C3H		; opcode: JP
	CALL near ptr O_OPHL		; JP HL

	XCHG dx,bx
         JMP near ptr  L6C3F                   ; update address at HL with current address

L544C:	; repeat-statement ::= REPEAT statement {; statement} UNTIL expression
	PUSH di

L544E:	CALL near ptr L5385		; statement

	CALL near ptr L6E76
	DW L7574 		; start of reserved word: UNTIL
	JZ near ptr L545D

	CALL near ptr L6F50		; match(';')
	JMP near ptr  L544E

L545D:	CALL near ptr L5EB0		; parse boolean expression

	CALL near ptr O_CODE
	DB 3
	DB 0CBH,45H		; BIT 0,L
	DB 0CAH			; opcode for 'JP Z,'

	POP bx
	JMP near ptr  O_HL

L546B:	; for-statement::=for control-variable:=for-list do statement
	MOV cx,400H		; variable identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info

	CALL near ptr L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax error

	CALL near ptr L5276		; id info at 7B5C
	MOV al,byte ptr L7B57
	OR al, al
	JNZ near ptr L5485

	MOV al,byte ptr L7B5C
	CMP al, 0AH
	JNC near ptr L5489

L5485:	CALL near ptr L72E1		; no condition
	DB 1EH			; error 30: Simple type expected

L5489:	CALL near ptr L6D2A		; push 13, L7B57
	MOV al,byte ptr L7B5C
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save type before assignment

	CALL near ptr L6F7E		; match(':=')

	POP ax
	xchg ah,al
	sahf
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	; A = type of before assignment
	CALL near ptr L5EE8		; parse expression

	CALL near ptr O_PSHHL		; generate code to push initial value

	POP ax
	xchg ah,al
	sahf
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CMP al, ch			; types are equal ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	CALL near ptr L6E5A
	DB 1			; 1 byte following
	DW L75F5 		; start of reserved word list:
				; TO, DOWNTO

	CALL near ptr L72DA		; NonZero --> error
	DB 12H			; error 18: TO or DOWNTO expected

	MOV dl,byte ptr [bx]		; E = opcode for INC HL or DEC HL
	PUSH dx

	MOV al,0AH 		; default type = INTEGER
	CALL near ptr L5EE8		; parse expression

	POP dx
	POP ax
	xchg ah,al
	sahf
	PUSH dx
	CMP al, ch

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	CALL near ptr L6E76
	DW L7572 		; start of reserved word: DO

	CALL near ptr L72DA		; NonZero --> error
	DB 0DH			; error 13: DO expected

	CALL near ptr O_CODE
	DB 1
	DB 0D1H			; POP DE

	POP dx			; E = opcode: INC HL or DEC HL

	CALL near ptr L6D63		; move 13, L7B57

	PUSH dx			; E = opcode: INC HL or DEC HL
	MOV al,dl
	MOV bx,offset _L0666		; LIB, FOR xx:=start TO end
	CMP al, 23H			; opcode: INC HL ?
	JZ near ptr L54D5

	; opcode: DEC HL
	MOV bx,offset _L0676		; LIB, FOR xx:=start DOWNTO end

L54D5:	CALL near ptr O_CALHL
	PUSH di			; save current code address

	CALL near ptr O_CODE
	DB 6
	DB 7AH			; LD A,D
	DB 0B3H			; OR E
	DB 0CAH,0,0		; JP Z,0000H
	DB 0D5H			; PUSH DE

	CALL near ptr L661B
	MOV bx,offset L7B95
	INC byte ptr [bx]

	CALL near ptr L5385		; statement

	MOV bx,offset L7B95
	DEC byte ptr [bx]
	POP bx			; address of 'LD A,D'

	POP dx			; E = opcode: INC HL or DEC HL
	CALL near ptr L6D49		; pop 13, L7B57

	PUSH bx			; address of 'LD A,D'

	MOV bx,word ptr L7B58		; hl = lvalue of current id
	MOV al,2AH
	CALL near ptr O_OPHL		; LD HL,( HL )

	MOV al,byte ptr L7B62
	DEC al			; size = 2 bytes ?
	JNZ near ptr L550C		; jump if size = 2, INTEGER

	CALL near ptr O_CODE
	DB 2
	DB 26H,0 		; LD H,0

L550C:	MOV al,dl
	CALL near ptr O_BYTE		; out: INC HL or DEC HL

	CALL near ptr O_CODE
	DB 3
	DB 0D1H			; POP DE
	DB 01BH			; DEC DE
	DB 0C3H			; opcode 'JP'

	POP bx
	CALL near ptr O_HL		; out: address of 'LD A,D'
	INC bx
	INC bx
	INC bx
         JMP near ptr  L6C3F                   ; update address at HL with current address

L5521:	; case-statement ::=
	;   case expression of case-element { ; case-element } end
	; | case expression of case-element { ; case-element }
	;   otherwise statement { ; statement } end
	MOV al,0AH 		; A = default type = INTEGER
	CALL near ptr L5EBB		; parse simple expression
	MOV byte ptr L7B9C,al
	XOR al, al
	MOV byte ptr L7B9B,al
	CALL near ptr L6F88		; match('OF')
	MOV ch,0
	PUSH cx
L5531:	MOV ch,1
L5533:	PUSH cx
	MOV bx,offset L7B9B
	TEST byte ptr [bx],128
	JZ near ptr L5549

	CALL near ptr O_CODE
	DB 1
	DB 19H			; ADD HL,DE

	TEST byte ptr [bx],16
	JZ near ptr L5549

	CALL near ptr O_CODE
	DB 1
	DB 09H			; ADD HL,BC

L5549:	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	MOV al,byte ptr L7B9C
	CMP al, ch

	CALL near ptr L72DA		; NonZero --> error
	DB 2EH			; error 46: constant and CASE selector type
				;	    does not match

	CALL near ptr O_LDDE		; output: 'LD DE,value HL'
	PUSH bx
	CALL near ptr L6E76
	DW L7580 		; start of reserved word: ..
	POP bx
	JNZ near ptr L5582
	PUSH bx
	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	MOV al,byte ptr L7B9C
	CMP al, ch

	CALL near ptr L72DA		; NonZero --> error
	DB 2EH			; error 46: constant and CASE seletector type
				;	    does not match

	POP dx
	OR al, al
	SBB bx,dx
	INC bx
	CALL near ptr O_LDBC

	CALL near ptr O_CODE
	DB 6
	DB 0B7H			; OR A
	DB 0EDH,52H		; SBC HL,DE
	DB 0B7H			; OR A
	DB 0EDH,42H		; SBC HL,BC

	MOV al,0DAH
	JMP near ptr  L558B

L5582:	CALL near ptr O_CODE
	DB 3
	DB 0B7H			; OR A
	DB 0EDH,52H		; SBC HL,DE

	MOV al,0CAH
L558B:	MOV byte ptr L7B9B,al
	CALL near ptr L6F0B		; match(':'), if present
	POP cx
	JZ near ptr L55A5		; jump if ':' matched
	MOV al,byte ptr L7B9B
	CALL near ptr O_BYTE
	PUSH di
	CALL near ptr O_HL
	CALL near ptr L6F5E		; match(',')
	INC ch
	JMP near ptr  L5533

L55A5:	PUSH di
	POP dx
	INC dx
	INC dx
	INC dx
L55AB:	DEC ch
	JZ near ptr L55B4
	POP bx

         CALL near ptr L6C42                 ; update address at HL with contents of DE

	JMP near ptr  L55AB
L55B4:	MOV al,byte ptr L7B9B
	pushf
	AND al,11110111b
	popf
	CALL near ptr O_BYTE
	POP cx
	PUSH di
	INC ch
	PUSH cx
	CALL near ptr O_HL
	MOV al,byte ptr L7B9B
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,byte ptr L7B9C
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	CALL near ptr L5385		; statement

	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B9C,al
	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7B9B,al
	CALL near ptr L6F0F		; match(';'), if present
	MOV dl,1
	JZ near ptr L55DF		; jump if ';' matched
	DEC dl
L55DF:	PUSH dx
	CALL near ptr L6E76
	DW L7530 		; start of reserved word: END
	POP dx
	JZ near ptr L561E
	CALL near ptr O_C3
	POP cx
	POP bx
	PUSH di
	PUSH cx
	PUSH dx
	CALL near ptr O_HL

         CALL near ptr L6C3F                 ; update address at HL with current address

	CALL near ptr L6E76
	DW L756E 		; start of reserved word: ELSE
	POP dx
	JZ near ptr L560F
	DEC dl
	JZ near ptr L5531
	MOV al,byte ptr L7B98
	OR al, al

	CALL near ptr L72D4		; Zero --> error
	DB 0EH			; error 14: END expected

	CALL near ptr L72E1		; no condition
	DB 29H			; error 41: Unknown identifier or syntax error

L560F:	CALL near ptr L5385		; statement

	CALL near ptr L6E76
	DW L7530 		; start of reserved word: END
	JZ near ptr L561E

	CALL near ptr L6F50		; match(';')
	JMP near ptr  L560F

L561E:	POP cx
L561F:	POP bx

         CALL near ptr L6C3F                 ; update address at HL with current address

         DEC ch
	JNZ near ptr L561F
	RET

L5626:	MOV cx,100H		; label identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info

	CALL near ptr L72DA		; NonZero --> error
	DB 28H			; error 40: Undefined label

	MOV al,byte ptr L7B94
	CMP al, byte ptr [bx]

	CALL near ptr L72DA		; NonZero --> error
	DB 48H			; error 72: Label not within current block

	XCHG dx,bx

L5639:	CALL near ptr L6D75		; add DE to id table
	MOV al,byte ptr L7B95
	CALL near ptr L6D7A		; add byte to id table
	CALL near ptr O_C3
	PUSH di
	POP dx
	CALL near ptr L6D75		; add DE to id table
	JMP near ptr  O_HL

L564E:	MOV al,byte ptr L7BC9
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
L5652:	MOV al,byte ptr L7BC6
	MOV bx,offset L7BC9
	CMP al, byte ptr [bx]

	CALL near ptr L72D4		; Zero --> error
	DB 61H			; error 97: Too many nested WITH's

	CALL near ptr L677F		; parse VAR parameter
	MOV al,byte ptr L7B5C
	CMP al, 2			; record identifier ?

	CALL near ptr L72DA		; NonZero --> error
	DB 1DH			; error 29: Record variable expected

	MOV bx,offset L7BC9
	MOV dl,byte ptr [bx]
	MOV dh,0
	INC byte ptr [bx]
	MOV bx,offset L7BCC
	ADD bx,dx
	MOV al,byte ptr L7B5D
	MOV byte ptr [bx],al
	MOV bx,word ptr L7BCA
	ADD bx,dx
	ADD bx,dx

	MOV al,22H
	CALL near ptr O_OPHL		; LD ( HL ),HL

	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L5652		; jump if ',' matched

	CALL near ptr L6E76
	DW L7572 		; start of reserved word: DO

L568C:	CALL near ptr L72DA		; NonZero --> error
	DB 0DH			; error 13: DO expected

	CALL near ptr L5385		; statement

	POP ax
	xchg ah,al
	sahf
	MOV byte ptr L7BC9,al
	RET

L5698:	; statement inline
	CALL near ptr L6F66		; match('(')

L569B:	MOV al,3EH
	CALL near ptr L6F29		; match('>')
	MOV al,2			; 16 bits
	JZ near ptr L56AE		; jump if matched

	MOV al,3CH
	CALL near ptr L6F29		; match('<')
	MOV al,1			; 8 bits
	JZ near ptr L56AE		; jump if matched

	XOR al, al

L56AE:	MOV byte ptr L7BA6,al		; 0 = automatic
				; 1 = always 8 bits
				; 2 = always 16 bits
	XOR al, al
	MOV bh,al
	MOV bl,al
	MOV ch,al

L56B5:	PUSH cx
	PUSH bx
	CALL near ptr L6A0D		; parse a constant of any type
	JNZ near ptr L56C5		; jump if no constant parsed

	MOV al,ch
	CMP al, 0AH			; constant type = INTEGER ?
	JZ near ptr L5702

	CALL near ptr L72E1		; no condition
	DB 16H			; error 22: Integer constant expected

L56C5:	MOV bx,offset L7BA6
	MOV al,byte ptr [bx]
	OR al, al
	JNZ near ptr L56CE
	MOV byte ptr [bx],2

L56CE:	MOV al,2AH
	CALL near ptr L6F29		; match('*')
	JNZ near ptr L56DA		; jump if not matched

	PUSH di			; IY = current position in code
	POP bx
	JMP near ptr  L5702

L56DA:	MOV cx,400H		; variable identifier ?
	CALL near ptr L6E54		; check if current in id list, pointer
				; HL = address of info
	JNZ near ptr L56EA

	CALL near ptr L5276		; id info at 7B5C
	MOV bx,word ptr L7B58		; hl = lvalue of current id
	JMP near ptr  L5702

L56EA:	MOV cx,500H		; procedure identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
         JZ near ptr L56FC

	MOV cx,600H		; function identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info

	CALL near ptr L72DA		; NonZero --> error
	DB 4AH			; error 74: INLINE error

L56FC:	DEC bx
	DEC bx
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	XCHG dx,bx

L5702:	POP dx
	POP cx
	DEC ch
	JNZ near ptr L570A
	CALL near ptr L6A30

L570A:	ADD bx,dx
	MOV ch,0
	MOV al,2BH
	CALL near ptr L6F29		; match('+')
	JZ near ptr L56B5		; jump if matched

	INC ch
	MOV al,2DH 		; match('-')
	CALL near ptr L6F29		; jump if matched
	JZ near ptr L56B5

	MOV al,byte ptr L7BA6
	CMP al, 1			; 8 bits ?
	JZ near ptr L5729		; jump if 8 bits

	JNC near ptr L572F		; jump if A = 2, output 16 bits value

	INC bh
	DEC bh
	JNZ near ptr L572F		; jump if HL >= 256, output HL

L5729:	; output 8 bits value
	MOV al,bl
	CALL near ptr O_BYTE
	JMP near ptr  L5732

L572F:	; output 16 bits value
	CALL near ptr O_HL

L5732:	MOV al,2FH
	CALL near ptr L6F29		; match('/')
	JZ near ptr L569B		; repeat while '/' matched

	JMP near ptr  L6F6E 		; match(')')

L573D:   ; procedure
         DEC bx                     ; skip update flag

         MOV ch,byte ptr [bx]                  ; B = # of different types
	DEC bx

         MOV dh,byte ptr [bx]                  ; address of procedure/function
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
         PUSH dx                    ; save start address of procedure/function

         MOV dh,byte ptr [bx]                  ; DE = function type definition address
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	PUSH dx

         DEC bx                     ; skip address of function result variable
	DEC bx


         MOV dh,byte ptr [bx]                  ; DE = first 128 byte block number of
                                    ; function/procedure in overlay
                                    ;Ok$$$$, will become long
                                    ;        push long !!
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
         PUSH dx                    ; push high-word

         MOV dh,byte ptr [bx]                  ; push low-word
         DEC bx
         MOV dl,byte ptr [bx]
         DEC bx
         PUSH dx


         MOV dh,byte ptr [bx]                  ; DE = length in blocks of 128 bytes of
                                    ; the largest overlay part
                                    ;Ok$$$$, will become length in bytes
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	PUSH dx

         INC ch                      ; # different type = 0, no variables ?
	DEC ch
         JZ near ptr L57D6                 ; jump if no variables

	CALL near ptr L6F66		; match('(')

L575E:	PUSH cx
	MOV ch,byte ptr [bx]
	DEC bx
	MOV al,byte ptr [bx]
	DEC bx
	MOV byte ptr L7B57,al
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	MOV cl,ch
L576B:	TEST byte ptr [bx],128
	pushf
	DEC bx
	popf
	JZ near ptr L576B
	DEC ch
	JNZ near ptr L576B
	MOV ch,cl
	PUSH bx
	XCHG dx,bx
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)

L5778:	PUSH cx
	MOV al,byte ptr L7B57
	OR al, al
	JNZ near ptr L57A9
	MOV al,byte ptr L7B5C
	CMP al, 3
	JC near ptr L57A1

	; A = default type
	CALL near ptr L5E84		; parse a sub expression
	CALL near ptr L5864		; make type casts

	MOV al,byte ptr L7B5C
	CMP al, 4
	JZ near ptr L57BD

	CMP al, 0EH			; type = LONGINT ?
	JZ near ptr L57781

	CMP al, 9
	JC near ptr L57C0

	JNZ near ptr L57BD		; jump to O_PSHHL if type = INTEGER,
				; BOOLEAN or CHAR

	; generate code to push rest of a REAL, HL is always pushed
	MOV al,0C5H
	CALL near ptr O_BYTE		; out: 'PUSH BC'

L57781:	MOV al,0D5H
	CALL near ptr O_BYTE		; out: 'PUSH DE'
	JMP near ptr  L57BD

L57A1:	CALL near ptr L6D2A		; push 13, L7B57
	CALL near ptr L6749
	JMP near ptr  L57AF

L57A9:	CALL near ptr L6D2A		; push 13, L7B57
	CALL near ptr L677F		; parse VAR parameter

L57AF:	CALL near ptr L6D5D		; move 13, L7B64
	MOV al,byte ptr L7B69
	CMP al, 0
	CALLNZ L58C5		; NonZero --> perform type checking
	CALL near ptr L6D49		; pop 13, L7B57

L57BD:	CALL near ptr O_PSHHL

L57C0:	POP cx
	DEC ch
	JZ near ptr L57C9
	CALL near ptr L6F5E		; match(',')
	JMP near ptr  L5778

L57C9:	POP bx
	POP cx
	DEC ch
	JZ near ptr L57D3
	CALL near ptr L6F5E		; match(',')
	JMP near ptr  L575E

L57D3:	CALL near ptr L6F6E		; match(')')


L57D6:
         POP cx                     ; length of data to read from overlay
                                    ;Ok$$$$, must be in BC in bytes

         POP bx                     ; first block of data where to read from
                                    ; in overlay
                                    ;Ok$$$$, must be a long
                                    ;       pop long !!
         POP dx

         MOV al,ch                     ; length = 0 ?
         OR al, cl
         JZ near ptr L57E3                 ; jump if procedure/function is no overlay

         MOV al,ch
         AND al, cl
         INC al
         JNZ near ptr L57E0                ; jump if not -1

         CALL near ptr O_CODE
         DB 2
         DB 16h,40H                 ; LD D,40H

         JMP near ptr  L57E3

L57E0:
         PUSH cx

         XCHG dx,bx
         CALL near ptr O_LDDE                ; high-word of position
         XCHG dx,bx
         CALL near ptr O_LDHL                ; low-word of position

         POP bx
         CALL near ptr O_LDBC                ; length of data block to read from overlay

;         CALL O_LDHL
;         EX DE,HL
;         CALL O_LDDE                ; output: 'LD DE,value HL'


L57E3:
         POP dx                     ; DE = function type definition address

         POP bx                     ; HL = start address of procedure/function

	MOV al,0CDH
	JMP near ptr  O_OPHL		; CALL HL

L57EA:	MOV al,byte ptr L7B5C
	CMP al, 0			; 0 ?
	JZ near ptr L57F9		; yes --> illegal assignment
	CMP al, 5			; < 5 ?
	JC near ptr L57FD		; yes --> correct assignment
	CMP al, 8			;>= 8 ?
	JNC near ptr L57FD		; yes --> correct assignment

	; illegal assignment with:
	; 0, 5 (typed file), 6 (text) and 7 (untyped file)
L57F9:	CALL near ptr L72E1		; no condition
	DB 36H			; error 54: Illegal assignment

L57FD:	MOV al,byte ptr L7BBD
	TEST al,2
	JNZ near ptr L5812

	TEST al,1
	JZ near ptr L580A		; jump if L7BBD = 0

	MOV al,0FFH
L580A:	MOV bx,word ptr L7BBE
	MOV word ptr L7B58,bx		; new lvalue of id
	JMP near ptr  L581A

L5812:	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	CALL near ptr O_PSHHL
	MOV al,1

L581A:	MOV byte ptr L7B57,al		; = 1	   if bit 1,(L7BBD) = '1'
				; = 255	   if bit 1,0,(L7BBD) = '0','1'
				; = (L7BBD) if bit 1,0,(L7BBD) = '0','0'
	CALL near ptr L6F7E		; match(':=')
	MOV al,byte ptr L7B5C
	CMP al, 3			; >= 3 ?
	JNC near ptr L593A

	CALL near ptr L6D2A		; push 13, L7B57

	CALL near ptr L6749

	CALL near ptr L6D43		; pop 13, L7B64

	CALL near ptr L58C5		; perform type checking

	MOV al,byte ptr L7B64
	DEC al
	JZ near ptr L5852
	INC al
	JZ near ptr L5845

	CALL near ptr O_CODE
	DB 2
	DB 0EDH,05BH		; opcode: 'LD DE,()'

	JMP near ptr  L584A

L5845:	CALL near ptr O_CODE
	DB 1
	DB 11H			; opcode: 'LD DE,'

L584A:	MOV bx,word ptr L7B65
	CALL near ptr O_HL
	JMP near ptr  L5857

L5852:	CALL near ptr O_CODE
	DB 1
	DB 0D1H			; POP DE

L5857:	MOV bx,word ptr L7B6F		; length of structured type
	CALL near ptr O_LDBC

	CALL near ptr O_CODE
	DB 2
	DB 0EDH,0B0H		; LDIR

	RET

L5864:	; ---------------------------------------------------------
	; make necessary type casts
	; ---------------------------------------------------------
	; in:	(L7B5C) = type of lvalue
	;	B = type of rvalue
	MOV al,byte ptr L7B5C
	CMP al, 9			; lvalue type = REAL ?
	JNZ near ptr L5877

	; lvalue type = REAL
	MOV al,ch
	CMP al, 0AH			; type rvalue = INTEGER ?
	JNZ near ptr L58641

	; lvalue type = REAL, rvalue type = INTEGER
	MOV ch,9			; new rvalue type = REAL
	MOV bx,offset _L1008		; LIB, convert integer HL to REAL HLDEBC
	JMP near ptr  L589A

L58641:	CMP al, 0EH			; type rvalue = LONGINT ?
	JNZ near ptr L589D

	; lvalue type = REAL, rvalue type = LONGINT
	MOV ch,9			; new rvalue type = REAL
	MOV bx,offset _L_R		; LIB, convert LONGINT DE:HL to REAL HLDEBC
	JMP near ptr  L589A

L5877:	CMP al, 8			; lvalue type = STRING ?
	JNZ near ptr L588C		; jump if not

	; lvalue type = STRING
	MOV al,ch
	CMP al, 0CH			; rvalue type = CHAR ?
	JNZ near ptr L589D

	; lvalue type = STRING, rvalue type = CHAR
	MOV ch,8			; new rvalue type = CHAR

	CALL near ptr O_CODE
	DB 4
	DB 65H			; LD H,L  = character data
	DB 2EH,01H		; LD L,1  = length
	DB 0E5H			; PUSH HL, push string on stack

	JMP near ptr  L589D

L588C:	CMP al, 0CH			; lvalue type = CHAR ?
	JNZ near ptr L588C1		; jump if not

	; lvalue type = CHAR
	MOV al,ch
	CMP al, 8			; STRING ?
	JNZ near ptr L589D

	; lvalue = CHAR, rvalue = STRING
	MOV ch,0CH 		; CHAR
	MOV bx,offset _L0996		; LIB, convert STRING to CHAR, clear
	JMP near ptr  L589A

L588C1:	CMP al, 0EH			; lvalue type = LONGINT ?
	JNZ near ptr L588C3		; jump if not

	; lvalue type = LONGINT
	MOV al,ch
	CMP al, 0AH			; rvalue type = INTEGER ?
	JNZ near ptr L588C2		; jump if not

	; lvalue type = LONGINT, rvalue = INTEGER
	MOV ch,0EH 		; new rvalue type = LONGINT
	CALL near ptr OP_L_I		; code to convert INTEGER to LONGINT with
				; sign extension
	JMP near ptr  L589D

L588C2:	CMP al, 9			; rvalue type = REAL ?
	JNZ near ptr L589D

	; lvalue type = LONGINT, rvalue type = REAL
	MOV ch,0EH 		; new rvalue type = LONGINT
	MOV bx,offset _R_L		; LIB, convert REAL HLDEBC to LONGINT
	JMP near ptr  L589A

L588C3:	CMP al, 0AH			; lvalue type = INTEGER ?
	JNZ near ptr L589D		; jump if not

	; lvalue type = INTEGER
	MOV al,ch
	CMP al, 0EH			; rvalue type = LONGINT ?
	JNZ near ptr L589D		; jump if not

	MOV ch,0AH 		; new rvalue type = INTEGER
	JMP near ptr  L589D

L589A:	CALL near ptr O_CALHL

L589D:	; all possible casts have been made now
	MOV al,byte ptr L7B5C
	CMP al, ch			; lvalue and expression have same type ?
	JNZ near ptr L58C1		; jump for Type mismatch

	CMP al, 3			; lvalue type = 3 ?
	JNZ near ptr L58B1

	MOV al,cl
	OR al, al
	RETZ 
	MOV bx,word ptr L7B5E
	CMP al, byte ptr [bx]
	RETZ 
	JMP near ptr  L58C1 		; jump for Type mismatch

L58B1:	CMP al, 4			; lvalue type = 4 ?
	RETNZ 
	MOV bx,word ptr L7B8B
	MOV al,bh
	OR al, bl
	RETZ 
	MOV dx,word ptr L7B5E
	SBB bx,dx
	RETZ 

L58C1:	CALL near ptr L72E1		; no condition
	DB 2CH			; error 44: Type mismatch



	; ----------------------------------------------------------
	; perform type checking
	; ----------------------------------------------------------
	; in:	(L7B5C) = current type
	;
L58C5:	MOV al,byte ptr L7B5C
	CMP al, 0			; lvalue type = 0 ?
	JZ near ptr L591B		; jump, type mismatch

	MOV cl,0BFH		; 10111111
	CMP al, 0AH			; lvalue type = INTEGER,BOOLEAN,CHAR
				;	       or LONGINT ?
	JNC near ptr L5906

	MOV cl,83H 		; 10000011
	CMP al, 8			; lvalue type = STRING ?
	JNZ near ptr L58E3

	; check if Var-parameter checking is ON for strings
	MOV al,byte ptr L7B9E		; compiler directives
	TEST al,32			; 1 = Var-parameter Type Checking on
	JNZ near ptr L5906		; jump if on

	MOV cl,80H 		; 10000000
				; when bit 0,1 are zero the length will
				; not be checked, checks only the type
	JMP near ptr  L5906

L58E3:	CMP al, 6			; lvalue type = TEXT,UNTYPED F.,STRING,REAL
	JNC near ptr L5906

	MOV cl,0B3H		; 10110011
	CMP al, 3
	JNC near ptr L5906

	MOV cl,0C3H		; 11000011
	CMP al, 2
	JNC near ptr L5906

	MOV bx,word ptr L7B60
	MOV al,bh
	OR al, bl
	MOV cl,0BFH		; 10111111
	JNZ near ptr L5906

	MOV bx,word ptr L7B6D
	MOV al,byte ptr [bx]
	CMP al, 0AH
	JNZ near ptr L591B

	MOV cl,0B3H		; 10110011

L5906:	MOV bx,offset L7B5C
	MOV dx,offset L7B69
	MOV ch,8
L590E:	RCL cl,1
	JNC near ptr L5916		; jump if byte not to compare

	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, byte ptr [bx]
	JNZ near ptr L591B		; jump if not equal, type mismatch

L5916:	INC bx
	INC dx
	DEC ch
	JNZ near ptr L590E
	RET

L591B:	CALL near ptr L72E1		; no condition
	DB 2CH			; error 44: Type mismatch


L591F:	MOV dx,-4
	ADD bx,dx
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	PUSH dx
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	MOV word ptr L7B58,dx		; save lvalue of id
	POP bx
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)
	XOR al, al
	MOV byte ptr L7B57,al
	CALL near ptr L6F7E		; match(':=')

	MOV al,byte ptr L7B5C		; A = default type

L593A:	CALL near ptr L5E84		; parse a sub expression
	CALL near ptr L5864		; make type casts
	JMP near ptr  L661B

L59E9:	; generate a CALL according to the type in L7B5C
	; in:	HL = address of table with three routine addresses
	;	1e word = typed file,	L7B5C = 5
	;	2e word = text file,	L7B5C = 6
	;	3e word = untyped file,	L7B5C = 7
	MOV al,byte ptr L7B5C
	SUB al, 5
	CALL near ptr TABLEINDEX2

;	 ADD A,A
;	 LD E,A
;	 LD D,0
;	 ADD HL,DE
;	 LD E,(HL)
;	 INC HL
;	 LD D,(HL)
;	 EX DE,HL

	JMP near ptr  O_CALHL

L5A0C:	; parse '(' and file parameter
	CALL near ptr L6F66		; match('(')
	CALL near ptr L5A17		; parse file parameter
	RETZ 

	CALL near ptr L72E1		; no condition
	DB 15H			; error 21: File variable expected

L5A17:	; parses a file parameter
	; out:	NonZero and Carry, no name parsed
	;	NonZero and NonCarry, name parsed but it is not a file
	;			    parameter
	;	Zero and NonCarry, file parameter parsed
	;	A = type of file parameter
	CALL near ptr L67B2		; parse var parameter
	STC
	RETNZ 			; return with NonZero and Carry

	MOV al,byte ptr L7B5C
	CMP al, 5
	JC near ptr L5A2F		; type < 5, not a file type
	CMP al, 8
	JNC near ptr L5A2F		; type > 7, not a file type

	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	XOR al, al			; return NonCarry and Zero
	MOV al,byte ptr L7B5C		; return type
	RET

L5A2F:	XOR al, al			; no carry
	DEC al			; return with NonZero, A = 255
	RET

L5CAD:	; parses a VAR string variable
	CALL near ptr L677F		; parse VAR parameter
	MOV al,byte ptr L7B5C
	CMP al, 8			; string var ?
	RETZ 			; return if string var

	CALL near ptr L72E1		; no condition
	DB 22H			; error 34: String variable expected

L5D76:	PUSH bx
	CALL near ptr O_PSHHL
	CALL near ptr L6F5E		; match(',')
	CALL near ptr L5E97		; parse integer expression
	POP bx

L5960:	CALL near ptr L6F6E		; match(')')
	JMP near ptr  O_CALHL

L5E84:	; parses a sub expression
	; in:	A = default type
	CALL near ptr L6D2A		; push 13, L7B57
	CALL near ptr L5EE8		; parse expression
	CALL near ptr L6D49		; pop 13, L7B57
	RET

L5E8E:	; parses an array index, ':=' and integer expression
	CALL near ptr L65D5		; parse an array index
	CALL near ptr L6F7E		; match(':=')
	CALL near ptr O_PSHHL		; push index result

L5E97:	; parses an integer expression
	MOV al,0AH 		; default type = INTEGER
	CALL near ptr L5EE8		; parse expression
	MOV al,ch
	CMP al, 00AH			; expression type = integer ?
	RETZ 			; yes, ok

	CALL near ptr L72E1		; no condition
	DB 17H			; error 23: Integer expression expected

L5EA2:	; parses an integer, longint or real expression
	; in:	A = default expression
	CALL near ptr L5EE8		; parse expression
	MOV al,ch
	CMP al, 00AH
	RETZ 			; return if type = INTEGER
	CMP al, 9
	RETZ 			; return if type = REAL
	CMP al, 00EH
	RETZ 			; return if type = LONGINT

	CALL near ptr L72E1		; no condition
	DB 1AH			; error 26: Integer or real expression expected

L5EB0:	; parses a boolean expression
	MOV al,0BH 		; default boolean
	CALL near ptr L5EE8		; parse expression
	MOV al,ch
	CMP al, 00BH
	RETZ 			; return if type = BOOLEAN

	CALL near ptr L72E1		; no condition
	DB 14H			; error 20: Boolean expression expected

L5EBB:	; parses a simple expression
	CALL near ptr L5EE8		; parse expression

L5EBE:	MOV al,ch
	CMP al, 00AH			; return if type = INTEGER, BOOLEAN or CHAR
				;	       or LONGINT
	RETNC 
	CMP al, 8

	CALL near ptr L72DA		; NonZero --> error
	DB 1FH			; error 31: Simple expression expected

	MOV ch,00CH
	MOV bx,offset _L0996		; LIB, convert STRING to CHAR, clear
	JMP near ptr  O_CALHL

L5ED0:	; parse a string expression
	MOV al,8			; default type = STRING
	CALL near ptr L5EE8		; parse expression
	MOV al,ch
	CMP al, 8
	RETZ 
	CMP al, 00CH

	CALL near ptr L72DA		; NonZero --> error
	DB 21H			; error 33: String expression expected

L5EDD:	; generate code to push CHAR in L as STRING with length = 1
	; out:	type = STRING, B = 8
	MOV ch,8

	CALL near ptr O_CODE
	DB 4
	DB 65H			; LD H,L
	DB 2EH,01H		; LD L,1
	DB 0E5H			; PUSH HL

	RET

DEF_TYPE:DB 0AH

SETDFT:	; set new default type
	; in:	A = type,
	; out:	A = type,
	; changes: F
	CMP al, 0FFH
	JZ near ptr SETDF1
	CMP al, 0AH
	JZ near ptr SETDF1
	CMP al, 0EH
	JZ near ptr SETDF1
	CMP al, 09H
	RETNZ 			; leave old value if not INTEGER or LONGINT

	MOV al,0FFH

SETDF1:	MOV byte ptr DEF_TYPE,al
	RET

L5EE8:	; parse a complete expression
	; SYNTAX: expression ::= simple-expression
	;		       { relational-operator simple-expression }

	CALL near ptr SETDFT

	MOV bx,offset BOOLOPER
	INC byte ptr [bx] 		; increase one level
				; 1 = the FIRST level

	CALL near ptr L5F98		; simple-expression
				; B = type
	MOV al,ch
	CALL near ptr SETDFT		; set new default type

L5EEB:	; { relational-operator simple-expression }
	PUSH cx
	CALL near ptr L6E5A		; is '=' the next word
	DB 1			; 1 byte following
	DW L7625 		; list of reserved words:
				; =, <>, >=, <=, >, <, IN
	POP cx
	RETNZ 			; return if no relational-operator

	MOV al,byte ptr [bx]		; 0 = =, 1 = <>, 2 = >=, 3 = <=
				; 4 = >, 5 = <,  ffh = IN
	INC al
	JZ near ptr L5F34		; jump if 'IN'

	DEC al
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save relational-operator
	PUSH cx			; save type

	CALL near ptr L6148		; generate code to push REAL, INTEGER,
				; BOOLEAN, CHAR, POINTER or LONGINT
				; on the stack

	MOV bx,word ptr L7B8B
	PUSH bx
	CALL near ptr L5F98		; simple-expression
				; B = type
	POP bx
	MOV word ptr L7B8D,bx
	POP dx			; D = type of previous simple-expression
	CALL near ptr L6160		; convert previous and current to same type

	MOV al,ch
	CALL near ptr SETDFT		; set new default type

	POP ax
	xchg ah,al
	sahf			; restore relational-operator

	ADD al,al			; * 2
	ADD al,al			; * 4
	ADD al,al			; * 8
	ADD al,al			; * 16
	MOV dl,al			; DE = 16 * A
	MOV dh,0
	MOV bx,offset L5F68
	ADD bx,dx		;+0  = =,+16 = <>,+32 = >=,+48 = <=
				;+64 = >,+80 = <
	MOV al,ch
	CMP al, 3			; operator type = SET ?
	JZ near ptr L5F28		; jump if operator at SET

	INC bx
	INC bx
	CMP al, 9			; operator type = REAL ?
	JZ near ptr L5F28		; jump if operator at REAL

	INC bx
	INC bx
	CMP al, 8			; operator type = STRING ?
	JZ near ptr L5F28		; jump if operator at STRING

	INC bx
	INC bx
	CMP al, 0EH			; operator type = LONGINT ?
	JZ near ptr L5F28		; jump if LONGINT

	INC bx
	INC bx
	CMP al, 0AH			; operator type = INTEGER ?
	JZ near ptr L5F28		; jump if INTEGER

	INC bx
	INC bx
	CMP al, 0BH			; operator type = BOOLEAN ?
	JZ near ptr L5F28		; jump if BOOLEAN

	INC bx
	INC bx
	; operator type = CHARACTER

L5F28:	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]
	MOV al,dh
	OR al, dl

	CALL near ptr L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator
	XCHG dx,bx
	JMP near ptr  L5F62

L5F34:	; operator = 'IN'
	MOV al,ch
	CMP al, 00AH
	JNC near ptr L5F47		; jump if type = INTEGER, BOOLEAN or CHAR

	CMP al, 8			; type = STRING ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	MOV bx,offset _L0996		; LIB, convert STRING to CHAR, clear
	CALL near ptr O_CALHL
	MOV ch,00CH		; result type = CHAR

L5F47:	PUSH cx

	; generate code to save the value to search in the 'SET'
	CALL near ptr O_PSHHL

	CALL near ptr L5F98		; simple-expression
				; B = type
	POP dx
	MOV al,ch
	CMP al, 3			; type = SET ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	MOV al,cl
	OR al, al
	JZ near ptr L5F5F
	CMP al, dh

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

L5F5F:	MOV bx,offset _L134F		; LIB, clear

L5F62:	CALL near ptr O_CALHL
	MOV ch,00BH		; return type = boolean
	RET

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

	CALL near ptr L6054		; term
				; B = type

	MOV al,ch
	CALL near ptr SETDFT		; set new default type

L5F9B:	; { adding-operator term }
	PUSH cx			; save type
	CALL near ptr L6E5A
	DB 1			; 1 byte following
	DW L7619 		; start of reserved word list:
				; +, -, OR, XOR
	POP cx			; restore type
	RETNZ 			; return if no adding-operator

	; pointer types do not match with an adding-operator
	MOV al,ch
	CMP al, 4			; type = POINTER ?
	CALL near ptr L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	MOV al,byte ptr [bx]		; 0 = +,  1 = -,
				; 2 = OR  3 = XOR
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save operator

	PUSH cx			; save type of previous term
	CALL near ptr L6148		; generate code to push REAL, INTEGER,
				; BOOLEAN, CHAR, POINTER or LONGINT
				; on the stack

	CALL near ptr L6054		; term
				; B = type of term

	POP dx			; D = type of previous term

	POP ax
	xchg ah,al
	sahf			; A = operator
				; 0 = +,  1 = -,
				; 2 = OR  3 = XOR
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save operator
	OR al, al
	JNZ near ptr L5FC9		; jump if operator = 1, 2 or 3


	MOV al,ch
	CMP al, 00CH			; current type = CHAR ?
	JNZ near ptr L5FC9		; jump if not

	; generate code to concatenate two strings

	; generate code to convert HL (CHAR) in to a string
	CALL near ptr O_CODE
	DB 4
	DB 65H			; LD H,L
	DB 2EH,01H		; LD L,1
	DB 0E5H			; PUSH HL

	MOV ch,8			; current type = STRING

L5FC9:	CALL near ptr L6160		; convert previous and current to same type

	MOV al,ch
	CALL near ptr SETDFT		; set new default type

	POP ax
	xchg ah,al
	sahf			; A = operator
	CMP al, 2
	JNC near ptr L601B		; jump if 'OR' or 'XOR'

	; operator = '+' or '-'
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV al,ch
	MOV bx,offset _L1318		; LIB, SET + SET
	MOV dx,offset _L1326		; LIB, SET - SET
	CMP al, 3			; type = SET ?
	JZ near ptr L6006		; jump if type = SET

	MOV bx,offset _L09E9		; LIB, REAL + REAL
	MOV dx,offset _L09F2		; LIB, REAL - REAL
	CMP al, 9			; type = REAL ?
	JZ near ptr L6006		; jump if type = REAL

	MOV bx,offset _L_ADD
	MOV dx,offset _L_SUB
	CMP al, 00EH			; type = LONGINT ?
	JZ near ptr L6006		; jump if type = LONGINT

	CMP al, 8			; type = STRING ?
	JZ near ptr L6010		; jump if type = STRING

	CMP al, 00AH			; type = INTEGER ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	POP ax
	xchg ah,al
	sahf
	DEC al			; type = '-'
	JZ near ptr L5FFC		; jump if type = '-'

	; generate code to add two INTEGERS
	CALL near ptr O_CODE
	DB 1
	DB 19H			; ADD HL,DE

	JMP near ptr  L5F9B 		; repeat { adding-operator term }

L5FFC:	; generate code to subtract two INTEGERS
	CALL near ptr O_CODE
	DB 4
	DB 0EBH			; EX DE,HL
	DB 0B7H			; OR A
	DB 0EDH,52H		; SBC HL,DE

	JMP near ptr  L5F9B

L6006:	POP ax
	xchg ah,al
	sahf
	DEC al
	JNZ near ptr L600B		; jump if operator = '+'

	XCHG dx,bx
	; HL = address of '-' routine

L600B:	CALL near ptr O_CALHL
	JMP near ptr  L5F9B

L6010:	POP ax
	xchg ah,al
	sahf
	DEC al			; operator = '-' ?

	CALL near ptr L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	MOV bx,offset _L083D		; LIB, STRING + STRING
	JMP near ptr  L600B

L601B:	; generate code for 'OR' and 'XOR' operators
	MOV al,ch
	JNZ near ptr L6039		; jump if operator = 'XOR'

	; operator = 'OR'

	CMP al, 00BH			; type = BOOLEAN ?
	JZ near ptr L602F		; jump if boolean

	MOV bx,offset _L_OR
	CMP al, 00EH			; type = LONGINT ?
	JZ near ptr L600B

	CMP al, 00AH			; type = INTEGER ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	CALL near ptr O_CODE
	DB 3
	DB 7CH			; LD A,H
	DB 0B2H			; OR D
	DB 67H			; LD H,A

L602F:	CALL near ptr O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 0B3H			; OR E
	DB 6FH			; LD L,A

	JMP near ptr  L5F9B

L6039:	; operator = 'XOR'

	CMP al, 00BH			; type = BOOLEAN ?
	JZ near ptr L604A		; jump if type = BOOLEAN

	MOV bx,offset _L_XOR
	CMP al, 00EH			; type = LONGINT ?
	JZ near ptr L600B		; jump if type = LONGINT

	CMP al, 00AH			; type = INTEGER ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	CALL near ptr O_CODE
	DB 3
	DB 7CH			; LD A,H
	DB 0AAH			; XOR D
	DB 67H			; LD H,A

L604A:	CALL near ptr O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 0ABH			; XOR E
	DB 6FH			; LD L,A

	JMP near ptr  L5F9B

L6054:	; SYNTAX: term ::= complemented factor |
	;		 { multiplying-operator complemented-factor }
	; out:	B = type

	CALL near ptr L60E9		; complemented factor
				; B = type

	MOV al,ch
	CALL near ptr SETDFT		; set new default type

L6057:	PUSH cx
	CALL near ptr L6E5A
	DB 1			; 1 byte following
	DW L7600 		; start of reserved word list:
				; *, /, AND, DIV, MOD, SHL, SHR
	POP cx
	RETNZ 			; return if no multiplying operator

	; pointer types do not match with an multiplying-operator
	MOV al,ch
	CMP al, 4			; type = POINTER ?
	CALL near ptr L72D4		; Zero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	MOV al,byte ptr [bx]		; 0 = *,   1 = /, 2 = AND,
				; 3 = DIV, 4 = MOD,
				; 5 = SHL, 6 = SHR
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx
	CALL near ptr L6148		; generate code to push REAL, INTEGER,
				; BOOLEAN, CHAR, POINTER or LONGINT
				; on the stack

	CALL near ptr L60E9		; complemented factor
				; B = type

	POP dx
	POP ax
	xchg ah,al
	sahf			; A = multiplying-operator
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	DEC al
	JNZ near ptr L6083		; jump if operator 0, 2, 3, 4, 5 or 6

	MOV al,ch
	CMP al, 00AH			; current type = INTEGER ?
	JNZ near ptr L6083

	MOV bx,offset _L1008		; LIB, convert integer HL to REAL HLDEBC
	CALL near ptr O_CALHL
	MOV ch,9			; current type = REAL

L6083:	CALL near ptr L6160		; convert previous and current to same type

	MOV al,ch
	CALL near ptr SETDFT		; set new default type

	POP ax
	xchg ah,al
	sahf
	MOV dl,al			; E = multiplying-operator

	MOV al,ch
	INC dl
	DEC dl
	JNZ near ptr L60A9

	; multiplying-operator = 0, *
	MOV bx,offset _L1333		; LIB, multiply two SETS
	CMP al, 3
	JZ near ptr L60A4

	MOV bx,offset _L06F5		; LIB, multiply two INTEGERS
	CMP al, 00AH
	JZ near ptr L60A4

	MOV bx,offset _L_MUL		; LIB, multiply two LONGS
	CMP al, 00EH			; LONG ?
	JZ near ptr L60A4

	MOV bx,offset _L09FA		; LIB, multiply two REALS

L609E:	CMP al, 9			; REAL ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	   operator

L60A4:	CALL near ptr O_CALHL
	JMP near ptr  L6057 		; repeat {
				;    multiplying-operator
				;    complemented-factor
				; }

L60A9:	MOV bx,offset _L09FF		; LIB, divide two REALS
	DEC dl			; multiplying-operator = '/' = 1
	JZ near ptr L609E

	DEC dl
	JNZ near ptr L60CC		; jump if >= 2, DIV, MOD, SHL, SHR

	; multiplying-operator = 'AND'
	MOV bx,offset _L_AND		; LIB, LONGINT AND LONGINT
	CMP al, 00EH			; type = LONGINT ?
	JZ near ptr L60A4		; jump if type = LONGINT ?

	CMP al, 00BH			; type = BOOLEAN ?
	JZ near ptr L60C3		; jump if BOOLEAN

	CMP al, 00AH			; type = INTEGER ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	CALL near ptr O_CODE
	DB 3
	DB 7CH			; LD A,H
	DB 0A2H			; AND D
	DB 67H			; LD H,A

L60C3:	CALL near ptr O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 0A3H			; AND E
	DB 6FH			; LD L,A

	JMP near ptr  L6057

L60CC:	CMP al, 00AH			; operator type = INTEGER ?
	JNZ near ptr L60CC1		; jump if not

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	MOV bx,offset _L070F		; LIB, X div Y, INTEGER
	DEC dl
	JZ near ptr L60A4
	MOV bx,offset _L0745		; LIB, X mod Y, INTEGER
	DEC dl
	JZ near ptr L60A4
	MOV bx,offset _L074E		; LIB, X shl Y, INTEGER
	DEC dl
	JZ near ptr L60A4
	MOV bx,offset _L0756		; LIB, X shr Y, INTEGER
	JMP near ptr  L60A4

L60CC1:	CMP al, 00EH			; operator type = LONGINT ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	MOV bx,offset _L_DIV		; LIB, X div Y, LONGINT
	DEC dl
	JZ near ptr L60A4
	MOV bx,offset _L_MOD		; LIB, X mod Y, LONGINT
	DEC dl
	JZ near ptr L60A4
	MOV bx,offset _L_SHL		; LIB, X shl Y, INTEGER
	DEC dl
	JZ near ptr L60A4
	MOV bx,offset _L_SHR		; LIB, X shr Y, LONGINT
	JMP near ptr  L60A4

	CALL near ptr L72E1		; no condition
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

L60E9:	; SYNTAX: complemented factor ::= signed-factor | not signed-factor
	; out:	B = type
	CALL near ptr L6E76
	DW L7579 		; start of reserved word: NOT
	JNZ near ptr L6112		; jump if no NOT, signed-factor

	; NOT found in the text

	CALL near ptr L6112		; signed-factor
				; out: B = type
	MOV al,ch
	CALL near ptr SETDFT		; set new default type

	CMP al, 00AH			; type = INTEGER ?
	JZ near ptr L6107		; jump if type = INTEGER

	CMP al, 00EH			; type = LONGINT ?
	JZ near ptr L61071		; jump if type = LONGINT

	CMP al, 00BH			; type = BOOLEAN;

	CALL near ptr L72DA		; NonZero --> error
	DB 2FH			; error 47: Operand type(s) does not match
				;	    operator

	; generate code for a NOT <BOOLEAN>
	CALL near ptr O_CODE
	DB 4
	DB 7DH			; LD A,L
	DB 0EEH,01H		; XOR 1
	DB 6FH			; LD L,A

	RET

L6107:	; generate code for a NOT <integer>
	CALL near ptr O_CODE
	DB 6
	DB 7DH			; LD A,L
	DB 2FH			; CPL
	DB 6FH			; LD L,A
	DB 7CH			; LD A,H
	DB 2FH			; CPL
	DB 67H			; LD H,A

	RET

L61071:	; generate code for a NOT <longint>
	MOV bx,offset _L_NOT
	JMP near ptr  O_CALHL

L6112:	; SYNTAX: signed-factor ::= factor | sign factor
	; out:	B = type
	MOV al,byte ptr L7BA1		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save old sign

	CALL near ptr L6A39		; get current sign, E = 0 if no sign
	MOV al,dl
	MOV byte ptr L7BA1,al		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

	CALL near ptr L621D		; factor
				; B = type

	MOV al,ch
	CALL near ptr SETDFT		; set new default type

	MOV al,byte ptr L7BA1
	MOV dl,al			; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

	CALL near ptr L6A4A		; sign = '-' ?
	JZ near ptr L6143		; jump if no minus sign

	MOV al,ch
	CMP al, 00AH			; type = INTEGER ?
	JNZ near ptr L61121		; jump if not

	; generate code for integer negation
;	 PUSH HL
;	 LD HL,_L0783
;	 CALL O_CALHL		; a call is shorter, but slower !!
;	 POP HL
	CALL near ptr O_CODE		; out: code for negation of HL
	DB 7
	DB 7DH			; LD A,L
	DB 2FH			; CPL
	DB 6FH			; LD L,A
	DB 7CH			; LD A,H
	DB 2FH			; CPL
	DB 67H			; LD H,A
	DB 23H			; INC HL

	JMP near ptr  L6143

L61121:	CMP al, 00EH			; type = LONGINT ?
	JNZ near ptr L613B		; jump if not

	; generate code for LONGINT negation
	PUSH bx
	MOV bx,offset _L_NEG
	CALL near ptr O_CALHL
	POP bx
	JMP near ptr  L6143

L613B:	; generate code for REAL negation
	CALL near ptr O_CODE
	DB 4
	DB 78H			; LD A,B
	DB 0EEH,80H		; XOR 80H
	DB 47H			; LD B,A

L6143:	POP ax
	xchg ah,al
	sahf			; restore old sign
	MOV byte ptr L7BA1,al		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign
	RET

L6148:	; generates code to PUSH a REAL, INTEGER, BOOLEAN, CHAR,
	;			POINTER or LONGINT on the stack
	; on the stack
	; in:	B = type
	; out:	-
	; changes: AF
	MOV al,ch
	CMP al, 00EH
	JZ near ptr O_PSHLONG

	CMP al, 00AH
	JNC near ptr L615D		; jump if type = INTEGER, BOOLEAN or CHAR

	CMP al, 4
	JZ near ptr L615D		; jump if type = POINTER

	CMP al, 8
	RETZ 			; return if type = STRING
				; strings are already on the stack

	CMP al, 3
	RETZ 			; return if type = SET
				; sets are already on the stack

	MOV al,0C5H
	CALL near ptr O_BYTE		; output: PUSH BC

O_PSHLONG:
	MOV al,0D5H
	CALL near ptr O_BYTE		; output: PUSH DE

L615D:	JMP near ptr  O_PSHHL		; output: PUSH HL

L6160:	; in:	D = previous type, data is already pushed onto the stack
	;	E = type of SET, if previous type = SET
	;	B = current type,  data is in registers
	;	C = type of SET, if current type = SET

;	 LD A,D
;	 CP B
;	 JR Z,OP_TYPES_EQ

	PUSH dx
	MOV al,dh
	ADD al,al
	ADD al,al
	ADD al,al
	ADD al,al
	OR al, ch			; A = ppppcccc, combination of operands

	MOV bx,offset OP_CNVTAB
OP_CNV_SRCH:
	INC byte ptr [bx] 		; end of table ?
	DEC byte ptr [bx]
	JZ near ptr OP_CNV_END		; jump to quit search

	CMP al, byte ptr [bx]			; operand combination found ?
	JZ near ptr OP_CNV_FOUND

	INC bx
	INC bx
	INC bx
	JMP near ptr  OP_CNV_SRCH

OP_CNV_FOUND:
	INC bx
	MOV al,byte ptr [bx]
	INC bx
	MOV bh,byte ptr [bx]
	MOV bl,al

	XCHG dx,bx
	MOV bx,offset L61D3
	mov bp,sp
	XCHG [bp],bx		; push return address L61D3 and
				; restore pushed DE
	XCHG dx,bx

	JMP bx

OP_R_R:	CALL near ptr O_CODE
	DB 4
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC       ; HLDEBC = previous
	RET

OP_R_I:	CALL near ptr O_CODE
	DB 7
	DB 0CDH			; CALL _L1008  ; convert HL to REAL HLDEBC
	DW _L1008
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC       ; HLDEBC = previous

	MOV ch,9			; previous type = REAL
	RET

OP_R_L:	CALL near ptr O_CODE
	DB 7
	DB 0CDH			; CALL _L_R    ; convert DE:HL to REAL
	DW _L_R
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL
	DB 0D1H			; POP DE
	DB 0C1H			; POP BC       ; HLDEBC = previous

	MOV ch,9			; previous type = REAL
	RET

OP_I_R:	CALL near ptr O_CODE
	DB 5
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL       ; HL = value of previous
	DB 0CDH			; CALL _L1008  ; convert HL to REAL
	DW _L1008

	MOV dh,9			; previous type = REAL
	RET

OP_L_R:	CALL near ptr O_CODE
	DB 6
	DB 0D9H			; EXX	      ; HLDEBC' = current
	DB 0E1H			; POP HL       ; DE:HL = value of previous
	DB 0D1H			; POP DE       ;
	DB 0CDH			; CALL _L_R    ; convert DE:HL to REAL
	DW _L_R

	MOV dh,9			; previous type = REAL
	RET

OP_SCALAR:
OP_B_B:
OP_C_C:
OP_I_I:	; DE = previous, HL = current
	MOV al,0D1H		; opcode: 'POP DE'
	JMP near ptr  O_BYTE

OP_S_C:	; generate code to convert CHAR to STRING (on the stack)

	CALL near ptr O_CODE
	DB 4
	DB 65H			; LD H,L
	DB 2EH,01H		; LD L,1
	DB 0E5H			; PUSH HL

	MOV ch,8			; current type = STRING
	RET

OP_C_S:	MOV bx,offset _L09A2		; LIB, clear
	CALL near ptr O_CALHL		; convert the previous type to a STRING

	MOV dh,8			; previous type = STRING
	RET

OP_L_I:  ; previous LONGINT DE:HL on stack
	; current  INTEGER in HL --> LONGINT DE:HL
	CALL near ptr O_CODE
	DB 8
	DB 11H,0,0		;	LD DE,0
	DB 0CBH,7CH		;	BIT 7,H
	DB 28H,1 		;	JR Z,continue
	DB 1BH			;	DEC DE
				; continue:

	MOV ch,0EH 		; current type = LONGINT
	RET

OP_I_L:	; previous INTEGER on stack --> LONGINT DE:HL on stack
	; current  LONGINT in DE:HL
	CALL near ptr O_CODE
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

	MOV dh,0EH 		; previous type = LONGINT
	RET

OP_CNV_END:
	POP dx

	MOV al,dh
	CMP al, 10H
	CALLNC OP_SCALAR 	; SCALAR type ?

L61D3:	MOV al,ch
	CMP al, dh			; types are equal ?

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

L61D31:	; types equal
	CMP al, 3			; type = SET ?
	JNZ near ptr L61EA		; jump if not

	; type = SET
	MOV al,dl
	CMP al, cl
				; SET types compatible ?
	RETZ 			; yes, return

	OR al, al			; previous SET = empty SET ?
	RETZ 			; return C = type of current SET

	MOV al,cl
	MOV cl,dl			; C = previous SET type
	OR al, al			; current SET = empty SET ?
	RETZ 			; return C = type of previous SET

	CALL near ptr L72E1		; no condition
	DB 2CH			; error 44: Type mismatch

L61EA:	CMP al, 4			; type = POINTER ?
	RETNZ 			; return if not

	MOV bx,word ptr L7B8B
	MOV al,bh
	OR al, bl
	RETZ 

	MOV dx,word ptr L7B8D
	MOV al,dh
	OR al, dl
	RETZ 
	SBB bx,dx
	RETZ 

	CALL near ptr L72E1		; no condition
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

L6201:	MOV dx,offset L5EEB		; { relational-operator simple-expression }
	PUSH dx
	MOV dx,offset L5F9B		; { adding-operator term }
	PUSH dx
	MOV dx,offset L6057		; { multiplying-operator complemented-factor }
	PUSH dx
	JMP near ptr  L622D 		; after parsing of an unsigned-constant

L620F:	MOV dx,offset L5EEB		; { relational-operator simple-expression }
	PUSH dx
	MOV dx,offset L5F9B		; { adding-operator term }
	PUSH dx
	MOV dx,offset L6057		; { multiplying-operator complemented-factor }
	PUSH dx
	JMP near ptr  L6276

L621D:	; SYNTAX: factor ::= variable | unsigned-constant | (expression) |
	;		   function-designator | set
	; in:	E = sign (0 = no sign, 255 = minus, 1 = plus)
	; out:	B = type
	CALL near ptr L6A5C		; unsigned-constant
				; parse constant or constant identifier
	JNZ near ptr L6257		; jump if no constant parsed

	; constant parsed
	MOV al,byte ptr L7BA1
	MOV dl,al			; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

	CALL near ptr L6A1F		; negate REAL or INTEGER constant if there
				; is a '-' sign

	XOR al, al
	MOV byte ptr L7BA1,al		; 255 = minus sign
				;   0 = no sign
				;   1 = plus sign

L622D:	; continue just parsing an unsigned-constant
	MOV al,ch
	CMP al, 9
	JNZ near ptr L6249		; type = real ?, no skip

	; generate code for real constant:
	; 'LD HL,'
	; 'LD DE,'
	; 'LD BC,'
	CALL __EXX
	PUSH cx			; push real on compiler stack
	PUSH dx
	PUSH bx
	MOV cx,331H		; B = 3 times, C = 21H + 10H
L6239:	MOV al,cl
	SUB al, 010H
	MOV cl,al
	CALL near ptr O_BYTE		; output opcode 'LD HL,' or
				;	       'LD DE,' or
				;	       'LD BC,'
	POP bx			; get 16 bits value
	CALL near ptr O_HL
	DEC ch
	JNZ near ptr L6239
	MOV ch,9			; return type = real
	RET

L6249:	CMP al, 8			; type = STRING ?
	JNZ near ptr L62491		; jump if not

	MOV bx,offset _L054D		; LIB, clear
	CALL near ptr O_CALHL
	JMP near ptr  L6B5E 		; output length (C) and data at L7A57

L62491:	CMP al, 0EH			; type = LONGINT ?
	JNZ near ptr O_LDHL		; jump if not, assume INTEGER, CHAR, BOOL

	; generate code for LONGINT constant
	CALL __EXX
	CALL near ptr O_LDHL
	XCHG dx,bx
	CALL near ptr O_LDDE
	XCHG dx,bx
	MOV ch,0EH 		; return type = LONGINT
	RET

L6257:	MOV cx,600H		; function identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
	JNZ near ptr L6271		; jump if no function identifier

	; function identifer
	CALL near ptr L573D
	XCHG dx,bx
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)
	MOV bx,word ptr L7B5E		; HL = address of functions type definition
	MOV word ptr L7B8B,bx		; save type definition
	MOV al,byte ptr L7B5C
	MOV ch,al			; B = result type of function
	JMP near ptr  SETDFT		; set new default type

L6271:	CALL near ptr L67B2
	JNZ near ptr L62D2

L6276:	MOV al,byte ptr L7B5C
	CMP al, 8
	JNC near ptr L6285
	CMP al, 3
	JZ near ptr L6285
	CMP al, 4
	JNZ near ptr L629D

L6285:	CALL near ptr L66DA
	MOV bx,word ptr L7B5E
	MOV word ptr L7B8B,bx
	MOV al,byte ptr L7B5C
	MOV ch,al
	CMP al, 3			; type = SET ?
	RETNZ 			; return if not SET

	; type = SET
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)
	MOV al,byte ptr L7B5C
	MOV cl,al
	RET

L629D:	CMP al, 1

	CALL near ptr L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	MOV bx,word ptr L7B5E
	MOV al,byte ptr [bx]
	CMP al, 00CH

	CALL near ptr L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	MOV bx,word ptr L7B60
	MOV al,byte ptr [bx]
	CMP al, 00AH

	CALL near ptr L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	MOV bx,word ptr L7B62		; HL = length
	MOV al,bh			; length >= 256 ?
	OR al, al

	CALL near ptr L72DA		; NonZero --> error
	DB 3EH			; error 62: Structured variables are not
				;	    allowed here

	MOV bh,bl			; H = length, operand
	MOV bl,6			; L = opcode 'LD B,'
	CALL near ptr O_HL

	MOV bx,offset _L0638		; LIB, clear
	CALL near ptr O_CALHL

	MOV ch,8			; result type = STRING
	RET

L62D2:	CALL near ptr L6EE0		; match('[') or match('(.')
	JNZ near ptr L631C		; jump if not matched

	MOV bx,offset _L0581		; LIB, push new empty SET on stack
	CALL near ptr O_CALHL
	CALL near ptr L6EF7		; match(']') or match('.)')
	MOV cx,300H		; C = 0, no first time yet
				; B = 3, type = SET
	RETZ 			; return if matched

L62E4:	PUSH cx
	MOV al,0AH 		; A = default type = INTEGER
	CALL near ptr L5EBB		; parse simple expression
	MOV al,ch
	POP cx
	INC cl			; already filled yet ?
	DEC cl
	JNZ near ptr L62EF		; jump if already filled

	MOV cl,al

L62EF:	CMP al, cl

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	PUSH cx

	CALL near ptr L6E76
	DW L7580 		; start of reserved word: ..

	MOV bx,offset _L0591		; LIB, done
	JNZ near ptr L6310		; jump if no '..' found

	CALL near ptr O_PSHHL

	MOV al,0AH 		; A = default type = INTEGER
	CALL near ptr L5EBB		; parse simple expression
	MOV al,ch
	POP cx
	PUSH cx
	CMP al, cl

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	MOV bx,offset _L059B		; LIB, done

L6310:	CALL near ptr O_CALHL
	POP cx
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L62E4		; jump if ',' matched

	JMP near ptr  L6F38 		; match(']')

L631C:	CALL near ptr L6F1B		; match('('), if present
	JNZ near ptr L6327		; jump if '(' not matched

	CALL near ptr L5EE8		; parse expression
	JMP near ptr  L6F6E 		; match(')')

L6327:	CALL near ptr L6E5A
	DB 2			; 2 bytes following
	DW L77B1 		; start of reserved word list:
				; standard library functions
				; CHR .. BIOS, 47
	JNZ near ptr L6335
	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]
	XCHG dx,bx
	XOR al, al
	JMP bx

L6335:	CALL near ptr L6E76
	DW L757C 		; start of reserved word: NIL
	JNZ near ptr L6345		; jump if NIL not parsed

	; generate code for the NIL value
	MOV bx,0000
	CALL near ptr O_LDHL

	MOV bx,0000
	MOV word ptr L7B8B,bx
	MOV ch,4			; type = pointer
	RET

L6345:	MOV cx,300H		; type identifier ?
	CALL near ptr L6E54		; check if current in id list, types
				; HL = address of info

;	 CALL Print_ABC

	CALL near ptr L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax error

	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, 00AH

	CALL near ptr L72C8		; carry set --> error
	DB 1EH			; error 30: Simple type expected

	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	; A = default type
	CALL near ptr L65EF
	POP ax
	xchg ah,al
	sahf
	MOV ch,al
	RET

L6540:	CALL near ptr L6F6E		; match(')')

	CALL near ptr O_CALHL

	POP ax
	xchg ah,al
	sahf			; pop flag
	MOV ch,00AH		; set result type = INTEGER
	OR al, al
	RETNZ 			; return if called as PROCEDURE

	; code to convert A in HL to return as function result
	CALL near ptr O_CODE
	DB 3
	DB 6FH			; LD L,A
	DB 26H,00H		; LD H,0

	RET

L65D5:	; parses an array index
	CALL near ptr L6F30		; match('[')
	CALL near ptr L5E97		; parse integer expression
	JMP near ptr  L6F38 		; match(']')

L65DE:	; parses a '(' integer expr. ')'
	CALL near ptr L6F66		; match('(')
	CALL near ptr L5E97		; parse integer expression
L65E4:	JMP near ptr  L6F6E 		; match(')')

L65E7:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L6F66		; match('(')
	POP ax
	xchg ah,al
	sahf
	CALL near ptr L5EA2		; parse integer, longint or real expression
	JMP near ptr  L6F6E 		; match(')')

PARSE_O_IL_C:
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L6F66		; match('(')
	POP ax
	xchg ah,al
	sahf
	CALL near ptr L5EA2		; parse integer, longint or real expression

	CMP al, 0EH			; type = LONGINT ?
	JZ near ptr L6F6E		; match(')') if type = LONGINT

	CMP al, 0AH

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	JMP near ptr  L6F6E 		; match(')')

L65EF:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L6F66		; match('(')
	POP ax
	xchg ah,al
	sahf
	CALL near ptr L5EBB		; parse simple expression
	JMP near ptr  L65E4 		; match(')')

L65F7:	CALL near ptr L6F1B		; match('('), if present
	JZ near ptr L6608		; jump if '(' matched
	MOV bx,offset _OUTPUT		; LIB
	CALL near ptr O_LDHL

	MOV al,6			; type = text
	MOV byte ptr L7B5C,al
	RET

L6608:	CALL near ptr L5A17		; parse a file parameter

	CALL near ptr L72DA		; NonZero --> error
	DB 15H			; error 21: File variable expected

	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L6F6E		; match(')')
	POP ax
	xchg ah,al
	sahf
	RET

L661B:	; generate code to store a SET, STRING, REAL, POINTER, INTEGER,
	; BOOLEAN, CHAR, LONGINT
	;
	; in:	(L7B57) = 0, store direct
	;	(L7B57) = 1, store at pushed address
	;	(L7B57) = 2, store at indirect address
	MOV al,byte ptr L7B57
	MOV cl,al

	MOV bx,word ptr L7B58		; HL = lvalue of id
	MOV al,byte ptr L7B5C
	CMP al, 3			; type = SET ?
	JNZ near ptr L6634		; jump if not

	; type is SET

	; generate 'LD BC,offset * 256 + length'
	CALL near ptr L6734

	MOV bx,offset _L0623		; LIB, save SET at pushed HL
	MOV dx,offset _L0612		; LIB, save SET at HL
	JMP near ptr  L6648

L6634:	CMP al, 8			; type = STRING ?
	JNZ near ptr L665E		; jump if not

	; type is STRING
	MOV al,byte ptr L7B62
	DEC al
	MOV bh,al
	MOV bl,6
	CALL near ptr O_HL		; output: 'LD B,max length of string'

	MOV bx,offset _L0601		; LIB, save string at pushed HL
	MOV dx,offset _L05E2		; LIB, save string at HL

L6648:	DEC cl
	JZ near ptr L665B		; jump if C = 1, used pushed version

	XCHG dx,bx 		; use call with destination directly in HL

L664C:	MOV al,021H		; LD HL,
	INC cl
	JZ near ptr L6653		; jump if C = 0

	; C = 2
	MOV al,02AH		; LD HL,()

L6653:	PUSH bx
	MOV bx,word ptr L7B58		; HL = lvalue of id
	CALL near ptr O_OPHL
	POP bx

L665B:	JMP near ptr  O_CALHL

L665E:	CMP al, 9			; type = REAL ?
	JNZ near ptr L6672		; jump if not

	; type is REAL

	; CODE: HLDEBC = current REAL
	CALL near ptr O_CODE
	DB 1
	DB 0D9H			; opcode: EXX

	MOV bx,offset _L05D1		; LIB, PUTFLT, save HLDEBC' at HL
	DEC cl
	JNZ near ptr L664C		; jump if C = 0 or C = 2

	; C = 1, destination address is pushed at stack
	CALL near ptr O_POPHL
	JMP near ptr  O_CALHL		; generate call PUTFLT

L6672:	CMP al, 0EH			; type = LONGINT ?
	JZ near ptr ST_LONG		; generate code to store a LONGINT

	CMP al, 4			; type = POINTER ?
	JZ near ptr L669D		; jump if POINTER

	MOV al,byte ptr L7B9E		; compiler directives
	TEST al,2			; 1 = Index Range Checking on
	JZ near ptr L669D		; jump if off

	MOV bx,word ptr L7B5E		; start address of variable
	MOV dx,word ptr L7B60
	INC dx
	OR al, al
	SBB bx,dx
	pushf
	ADD bx,dx
	popf
	JZ near ptr L669D		; no checking if base = 0
	DEC dx
	CALL near ptr O_LDDE		; output: LD DE,base=HL
	XCHG dx,bx
	OR al, al
	SBB bx,dx
	INC bx
	CALL near ptr O_LDBC		; output: LD BC,length
	MOV bx,offset _L0656		; LIB, clear
	CALL near ptr O_CALHL		; output call for range checking

L669D:	DEC cl
	JNZ near ptr L66B7		; jump if C = 0 or C = 2

	; C = 1, use pushed version
	CALL near ptr O_CODE
	DB 2
	DB 0EBH			; EX DE,HL
	DB 0E1H			; POP HL 	; HL = destination address

L66A6:	CALL near ptr O_CODE
	DB 1
	DB 73H			; LD (HL),E

	MOV al,byte ptr L7B62
	DEC al
	RETZ 

	CALL near ptr O_CODE
	DB 2
	DB 23H			; INC HL
	DB 72H			; LD (HL),D

	RET

L66B7:	MOV bx,word ptr L7B58		; HL = lvalue of id
	INC cl
	JNZ near ptr L66CF

	; C = 0, store direct
	; generates code to save a byte size expression or an integer size
	; expression
	MOV al,byte ptr L7B62		; A = low byte of length of lvalue
	DEC al			; expression is word or byte?

	MOV al,22H 		; assume: opcode 'LD (),HL'
	JNZ near ptr L66CC

	; expression is byte
	CALL near ptr O_CODE
	DB 1
	DB 7DH			; LD A,L

	MOV al,32H 		; opcode 'LD (),A'

L66CC:	JMP near ptr  O_OPHL		; out: LD (LVALUE),A or LD (LVALUE),HL

L66CF:	; C = 2, store indirect
	CALL near ptr O_CODE
	DB 2
	DB 0EBH			; EX DE,HL
	DB 2AH			; opcode: 'LD HL,()'

	CALL near ptr O_HL		; output destination address
	JMP near ptr  L66A6

ST_LONG: DEC cl
	JNZ near ptr ST_LONG02		; jump if C = 0 or C = 2

	; C = 1, use pushed version
	CALL near ptr O_CODE
	DB 3
	DB 4DH			; LD C,L
	DB 44H			; LD B,H
	DB 0E1H			; POP HL 	; HL = destination address

ST_LONG_HL:
	CALL near ptr O_CODE
	DB 7
	DB 71H			; LD (HL),C	; store low-word
	DB 23H			; INC HL
	DB 70H			; LD (HL),B
	DB 23H			; INC HL
	DB 73H			; LD (HL),E	; store high-word
	DB 23H			; INC HL
	DB 72H			; LD (HL),D

	RET

ST_LONG02:
	MOV bx,word ptr L7B58		; HL = lvalue of id
	INC cl
	JNZ near ptr ST_LONG_INDIRECT	; jump if C = 2

	; C = 0
	MOV al,22H
	CALL near ptr O_OPHL		; LD (lvalue),HL

	INC bx
	INC bx
	MOV al,0EDH
	CALL near ptr O_BYTE
	MOV al,53H
	JMP near ptr  O_OPHL		; LD (lvalue+2),DE

ST_LONG_INDIRECT:
	; C = 2, store indirect
	CALL near ptr O_CODE
	DB 3
	DB 4DH			; LD C,L
	DB 44H			; LD B,H
	DB 2AH			; opcode: 'LD HL,()'

	CALL near ptr O_HL		; output loading of destination address
	JMP near ptr  ST_LONG_HL

L66DA:	; generate code to load a REAL, STRING, SET, INTEGER, BOOLEAN,
	; CHAR or LONGINT
	MOV al,byte ptr L7B5C
	CMP al, 00AH
	JNC near ptr L6701		; jump if INTEGER, BOOLEAN, CHAR or LONGINT

	CMP al, 4
	JZ near ptr L6701		; jump if pointer

	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	POP ax
	xchg ah,al
	sahf

	MOV bx,offset _L052C		; LIB, GETFLT, clear
	CMP al, 9
	JZ near ptr L66FE		; jump if REAL

	MOV bx,offset _L053A		; LIB, clear
	CMP al, 8
	JZ near ptr L66FE		; jump if STRING

	; generate 'LD BC,offset * 256 + length'
	CALL near ptr L6734
	MOV bx,offset _L055D		; LIB, push a set on to a stack

L66FE:	JMP near ptr  O_CALHL

L6701:	MOV al,byte ptr L7BBD
	OR al, al			; indexed or VAR ?
	JNZ near ptr L671B

	; normal addressing of variable
	MOV al,02AH
	MOV bx,word ptr L7BBE
	CALL near ptr O_OPHL		; LD HL,( HL )

	MOV al,byte ptr L7B5C
	CMP al, 00EH			; type = LONGINT ?
	JNZ near ptr L67011		; jump if not

	; output code to load high-word of longint
	MOV al,0EDH		; opcode: LD DE,()
	CALL near ptr O_BYTE
	MOV al,5BH
	INC bx
	INC bx
	JMP near ptr  O_OPHL		; LD DE,( L7BBE+2 )

L67011:	MOV al,byte ptr L7B62
	DEC al			; size = 1 ?
	RETNZ 			; return if size > 1

L6714:	CALL near ptr O_CODE
	DB 2
	DB 26H,00H		; LD H,0

	RET

L671B:	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	MOV al,byte ptr L7B62
	CMP al, 4			; size = 4 ?
	JZ near ptr O_LDLONG		; output load indirect long

	DEC al			; size = 1 ?
	JNZ near ptr L672B		; jump if size > 1

	; size = 1
	CALL near ptr O_CODE
	DB 1
	DB 6EH			; LD L,(HL)

	JMP near ptr  L6714 		; LD H,0

O_LDLONG:CALL near ptr O_CODE
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

	RET

L672B:	CALL near ptr O_CODE
	DB 4
	DB 5EH			; LD E,(HL)
	DB 23H			; INC HL
	DB 56H			; LD D,(HL)
	DB 0EBH			; EX DE,HL

	RET

L6734:	; generate 'LD BC,offset * 256 + length'
	MOV bx,word ptr L7B5E		; HL = address of type definition
	CALL near ptr L5271		; 8 bytes from HL (down) to 7B69 (up)

	MOV bx,word ptr L7B62		; L = lenght of SET in bytes
	MOV al,byte ptr L7B6B		; A = low byte of lower bound
	RCR al,1
	RCR al,1
	RCR al,1
	AND al, 01FH
	MOV bh,al			; H = byte offset in SET

	JMP near ptr  O_LDBC		; B = offset, C = length

L6749:	CALL near ptr L6A0D		; parse a constant of any type
	JNZ near ptr L677F		; jump to parse var parameter

	MOV al,ch
	CMP al, 8			; type = STRING ?

	CALL near ptr L72DA		; NonZero --> error
	DB 3CH			; error 60: Constants are not allowed here

	MOV bl,018H		; opcode: JR
	MOV bh,cl			; H = length of STRING constant
	CALL near ptr O_HL		; jump over constant 'JR length'

	MOV word ptr L7B58,di		; save address of STRING constant
	MOV al,1
	MOV byte ptr L7B5C,al
	MOV bx,offset L74E2		; definition of a char
	MOV word ptr L7B5E,bx
	MOV bx,0000
	MOV word ptr L7B60,bx
	MOV bl,cl
	MOV word ptr L7B62,bx		; size of constant
	CALL near ptr L6B62
	MOV al,021H		; opcode: LD HL,
	MOV bx,word ptr L7B58		; HL = address of STRING constant
	JMP near ptr  O_OPHL		; LD HL, HL

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
	CALL near ptr L6787
	RETZ 

	CALL near ptr L72E1		; no condition
	DB 29H			; error 41: Unknown identifier or syntax error

L6787:	CALL near ptr L67B2
	RETNZ 

L678B:	; bit 0,1 of (L7BBD)
	; 00 = LD HL, value in L7BBE
	; 01 = LD HL,(value in L7BBE)
	; 10 = LD DE, value in L7BBE
	;      ADD HL,DE
	; 11 = no output
	; out:

	MOV al,byte ptr L7BBD
	MOV bx,word ptr L7BBE		; HL = address or normal value
	TEST al,2
	JNZ near ptr L67A2
	TEST al,1
	MOV al,021H		; LD HL,
	JZ near ptr L679D
	MOV al,02AH		; LD HL,()

L679D:	CALL near ptr O_OPHL
	XOR al, al			; return carry = 0, A = 0
	RET

L67A2:	TEST al,1
	JNZ near ptr L67B0		; jump if no output, return carry=0, A = 0

	MOV al,011H		; LD DE,
	CALL near ptr O_OPHL

	CALL near ptr O_CODE
	DB 1
	DB 19H			; ADD HL,DE

L67B0:	XOR al, al			; return carry = 0, A = 0
	RET

L67B2:	CALL near ptr L680C
	JZ near ptr L67D9

	MOV cx,400H		; variable identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
	JNZ near ptr L67ED		; jump if no variable identifier

	; variable identifier found
	CALL near ptr L5276		; id info at 7B5C
	MOV al,byte ptr L7B57
	OR al, al			; 0?, 0 = no VAR, 1 = VAR
	MOV al,021H		; opcode 'ld hl,'
	MOV ch,0
	JZ near ptr L67CF		; jump if no VAR

	MOV al,02AH		; opcode 'ld hl,()'
	INC ch			; B = 1

L67CF:	MOV bx,offset L7BBD
	MOV byte ptr [bx],ch		; B = 0: 'LD HL,'
				; B = 1: 'LD HL,()'

	MOV bx,word ptr L7B58		; HL = lvalue of id
	MOV word ptr L7BBE,bx		; current address of variable

L67D9:	CALL near ptr L683A
	JZ near ptr L67D9

	CALL near ptr L6931		; '.' variablename ?
	JZ near ptr L67D9		; yes, repeat for next

	CALL near ptr L6974		; variablename '^' ?
	JZ near ptr L67D9		; yes, repeat for next

	CALL near ptr L699F
	XOR al, al
	RET

L67ED:	CALL near ptr L6E76		; MEM is following ?
	DW L78FA 		; start of reserved word: MEM
	RETNZ 			; quit if not

	CALL near ptr L65D5		; parses an array index

	MOV al,00AH
	MOV byte ptr L7B5C,al		; type = byte / integer
	MOV bx,1
	MOV word ptr L7B62,bx		; size = 2
	DEC bl
	MOV word ptr L7B5E,bx		; = 0	  , min value
	DEC bl
	MOV word ptr L7B60,bx		; = 0FFFFH , max value
	JMP near ptr  L6903

L680C:	MOV al,byte ptr L7BC9
	MOV ch,al

L6810:	DEC ch
	RETM 			; quit if < 0
	PUSH cx
	MOV dl,ch
	MOV dh,0
	MOV bx,offset L7BCC
	ADD bx,dx
	MOV al,byte ptr [bx]
	MOV cl,al
	MOV ch,4			; variable identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
	POP cx
	JNZ near ptr L6810

	PUSH bx
	MOV al,ch
	ADD al,al
	MOV dl,al
	MOV dh,0
	MOV bx,word ptr L7BCA
	ADD bx,dx
	MOV word ptr L7BBE,bx
	MOV bx,offset L7BBD
	MOV byte ptr [bx],1
	POP bx
	JMP near ptr  L6948

L683A:	MOV al,byte ptr L7B5C
	CMP al, 1
	RETNZ 

	CALL near ptr L6EE0		; match('[') or match('(.')
	RETNZ 			; quit if no '[' or '(.' matched

	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output

L6847:	CALL near ptr O_PSHHL

	MOV al,byte ptr L7B5C		; A = default type
	CALL near ptr L5E84		; parse a sub expression

	MOV bx,word ptr L7B60
	CALL near ptr L5271		; 8 bytes from HL (down) to 7B69 (up)
	MOV al,byte ptr L7B69
	CMP al, ch

	CALL near ptr L72DA		; NonZero --> error
	DB 2CH			; error 44: Type mismatch

	MOV bx,word ptr L7B6B
	MOV al,bh
	OR al, al
	JNZ near ptr L6874
	MOV al,bl
	CMP al, 4
	JNC near ptr L6888

L6867:	OR al, al
	JZ near ptr L6893
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	CALL near ptr O_CODE
	DB 1
	DB 2BH			; DEC HL

	POP ax
	xchg ah,al
	sahf
	DEC al
	JMP near ptr  L6867

L6874:	INC al
	JNZ near ptr L6888
	MOV al,bl
	CMP al, 0FDH
	JC near ptr L6888

L687C:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	CALL near ptr O_CODE
	DB 1
	DB 23H			; INC HL

	POP ax
	xchg ah,al
	sahf
	INC al
	JNZ near ptr L687C
	JMP near ptr  L6893

L6888:	CALL near ptr L6A30
	CALL near ptr O_LDDE		; output: 'LD DE,value HL'

	CALL near ptr O_CODE
	DB 1
	DB 19H			; ADD HL,DE

L6893:	MOV al,byte ptr L7B9E		; compiler directives
	TEST al,2			; 1 = Index Range Checking on
	JZ near ptr L68AE		; jump if off

	MOV bx,word ptr L7B6D
	MOV dx,word ptr L7B6B
	OR al, al
	SBB bx,dx
	INC bx
	CALL near ptr O_LDDE		; output: 'LD DE,value HL'
	MOV bx,offset _L064C		; LIB
	CALL near ptr O_CALHL

L68AE:	MOV bx,word ptr L7B5E
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)

	MOV bx,word ptr L7B62		; HL = variable size
	MOV al,bh
	OR al, al
	JNZ near ptr L68D8		; jump if size >= 256

	MOV al,bl
	DEC al			; size = 1 ?
	JZ near ptr L68ED		; jump if size = 1

	DEC al			; size = 2 ?
	JNZ near ptr L68AE1		; jump if not

	; size = 2
	CALL near ptr O_CODE
	DB 1
	DB 29H			; ADD HL,HL

	JMP near ptr  L68ED 		; add base

L68AE1:	CMP al, 2			; size = 4 ?, already 2 subtracted
	JNZ near ptr L68C9

	; size = 4
	CALL near ptr O_CODE
	DB 2
	DB 29H			; ADD HL,HL
	DB 29H			; ADD HL,HL

	JMP near ptr  L68ED 		; add base

L68C9:	CMP al, 4			; size = 6 ?, already 2 subtracted
	JNZ near ptr L68D8

	; generate code for HL * 6, size = 6
	CALL near ptr O_CODE
	DB 5
	DB 29H			; ADD HL,HL   , * 2
	DB 5DH			; LD E,L
	DB 54H			; LD D,H
	DB 29H			; ADD HL,HL   , * 4
	DB 19H			; ADD HL,DE   , * 2 + * 4

	JMP near ptr  L68ED 		; add base

L68D8:	MOV al,byte ptr L7B9E		; compiler directives
	TEST al,16			; 1 = Array Optimization on
	JNZ near ptr L68EA		; jump if on

	CALL near ptr O_LDDE		; output: 'LD DE,value HL'
	MOV bx,offset _L06F5		; LIB
	CALL near ptr O_CALHL
	JMP near ptr  L68ED

L68EA:	CALL near ptr L690A

L68ED:	CALL near ptr O_CODE
	DB 2
	DB 0D1H			; POP DE
	DB 19H			; ADD HL,DE

	MOV al,byte ptr L7B5C
	CMP al, 1
	JNZ near ptr L6900
	CALL near ptr L6F13		; match(','), if present
	JZ near ptr L6847		; jump if ',' matched
L6900:	CALL near ptr L6F38		; match(']')

L6903:	MOV al,3
	MOV byte ptr L7BBD,al
	XOR al, al
	RET

L690A:	MOV ch,1

L690C:	MOV al,bh
	OR al, al
	JNZ near ptr L6914		; HL non-zero

	MOV al,bl
	DEC al
	JZ near ptr L6927

L6914:	TEST bl,1			; bit 0 = '0' ?
	JZ near ptr L691C		; jump if '0', generate 'ADD HL,HL'

	; save current value to be added later
	CALL near ptr O_PSHHL
	INC ch

L691C:	CALL near ptr O_CODE
	DB 1
	DB 29H			; ADD HL,HL

	SHR bh,1			; HL = HL / 2
	RCR bl,1
	JMP near ptr  L690C

L6927:	DEC ch
	RETZ 

	CALL near ptr O_CODE
	DB 2
	DB 0D1H			; POP DE
	DB 19H			; ADD HL,DE

	JMP near ptr  L6927

L6931:	MOV al,byte ptr L7B5C
	CMP al, 2			; record type ?
	RETNZ 			; return if not

	CALL near ptr L6F17		; match('.'), if present
	RETNZ 			; return if '.' not matched

	MOV al,byte ptr L7B5D
	MOV cl,al			; level within record
	MOV ch,4			; variable identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info

	CALL near ptr L72DA		; NonZero --> error
	DB 29H			; error 41: Unknown identifier or syntax error

L6948:	CALL near ptr L5276		; id info at 7B5C
	MOV bx,word ptr L7B58		; HL = lvalue of id or offset of base of id
	MOV al,bh
	OR al, bl
	RETZ 			; quit if lvalue of id == 0
				; can only be 0 if it is an offset which
				; is zero (first variable in a record),
				; it generates no code

	MOV bx,offset L7BBD
	TEST byte ptr [bx],1
	JZ near ptr L6967		; jump if LD HL, value in L7BBE
				;      or LD DE, value in L7BBE
				;	 ADD HL,DE

	PUSH bx
	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	POP bx
	MOV byte ptr [bx],2
	MOV bx,word ptr L7B58		; HL = lvalue of id
	MOV word ptr L7BBE,bx		; set new current address of variable

	XOR al, al			; return Zero
	RET

L6967:	MOV bx,word ptr L7BBE
	MOV dx,word ptr L7B58		; HL = offset to field id
	ADD bx,dx
	MOV word ptr L7BBE,bx		; set new current address of variable

	XOR al, al			; return Zero
	RET

L6974:	; variablename '^'
	MOV al,byte ptr L7B5C
	CMP al, 4			; type = POINTER ?
	RETNZ 			; return if not a pointer

	CALL near ptr L6F27		; match('^')
	RETNZ 

	MOV bx,offset L7BBD
	MOV al,byte ptr [bx]
	OR al, al
	JNZ near ptr L6988

	; direct value --> make indirect
	INC byte ptr [bx] 		; 01 = LD HL,(value in L7BBE)
	JMP near ptr  L6997

L6988:	PUSH bx
	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	POP bx
	MOV byte ptr [bx],3		; no output next time

	CALL near ptr O_CODE
	DB 4
	DB 5EH			; LD E,(HL)
	DB 23H			; INC HL
	DB 56H			; LD D,(HL)
	DB 0EBH			; EX DE,HL

L6997:	MOV bx,word ptr L7B5E
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)

	XOR al, al			; return Zero
	RET

L699F:	MOV al,byte ptr L7B5C
	CMP al, 8			; type = STRING ?
	RETNZ 

	CALL near ptr L6EE0		; match('[') or match('(.')
	RETNZ 			; quit if no '[' or '(.' matched

	CALL near ptr L678B		; bit 0,1 of (L7BBD)
				; 00 = LD HL, value in L7BBE
				; 01 = LD HL,(value in L7BBE)
				; 10 = LD DE, value in L7BBE
				;      ADD HL,DE
				; 11 = no output
	CALL near ptr O_PSHHL
	MOV bx,word ptr L7B62
	PUSH bx
	CALL near ptr L5E97		; parse integer expression
	POP bx
	MOV al,byte ptr L7B9E		; compiler directives
	TEST al,2			; 1 = Index Range Checking on
	JZ near ptr L69C7		; jump if off
	CALL near ptr O_LDDE		; output: 'LD DE,value HL'
	MOV bx,offset _L064C		; LIB
	CALL near ptr O_CALHL

L69C7:	CALL near ptr O_CODE
	DB 2
	DB 0D1H			; POP DE
	DB 19H			; ADD HL,DE

	CALL near ptr L6F38		; match(']')
	MOV al,00CH
	MOV byte ptr L7B5C,al
	MOV bx,0001
	MOV word ptr L7B62,bx
	DEC bx
	MOV word ptr L7B5E,bx
	DEC bl
	MOV word ptr L7B60,bx
	MOV al,3
	MOV byte ptr L7BBD,al
	XOR al, al
	RET

L69EA:	CALL near ptr L6A0D		; parse a constant of any type
	RETZ 

	CALL near ptr L72E1		; no condition
	DB 29H			; error 41: Unknown identifier or syntax error

L69F2:	; parses an integer constant
	MOV al,0AH
	MOV byte ptr DEF_TYPE,al		; default type = INTEGER
	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	MOV al,ch
	CMP al, 00AH
	RETZ 

	CALL near ptr L72E1		; no condition
	DB 16H			; error 22: Integer constant expected

L69FD:	; parses a string constant
	; out:	B = 8, character constant will be casted to string constant
	;	C = length of string constant
	CALL near ptr L69EA		; parse a constant of any type
				; error if not found
	MOV al,ch
	CMP al, 8			; STRING constant ?
	RETZ 			; return if STRING constant

	CMP al, 00CH			; CHAR constant ?

	CALL near ptr L72DA		; NonZero --> error
	DB 20H			; error 32: String constant expected

	MOV ch,8			; return as STRING constant
	RET

L6A0D:	; parses a constant of any type
	CALL near ptr L6A39		; get current sign, E = 0 if no sign
	PUSH dx

	CALL near ptr L6A5C		; unsigned-constant
				; parse constant or constant identifier
	POP dx
	JZ near ptr L6A1F		; jump to negate constant if the sign = '-'

	INC dl			; sign before constant ?
	DEC dl

	CALL near ptr L72DA		; NonZero --> error
	DB 19H			; error 25: Integer or real constant expected

	DEC dl			; return E = 255
	RET

L6A1F:	; negates the REAL, LONGINT or INTEGER constant if there is a '-' sign ?
	CALL near ptr L6A4A		; sign = '-' ?
	RETZ 			; return if no minus sign

	MOV al,ch
	CMP al, 9			; type = REAL ?
	JNZ near ptr L6A1F1		; jump if not

	; negate REAL constant internally
	CALL __EXX
	MOV al,ch
	XOR al, 080H
	MOV ch,al
	CALL __EXX
	XOR al, al
	RET

L6A1F1:	CMP al, 0AH			; type = INTEGER ?
	JNZ near ptr L6A31		; jump if not

L6A30:	CALL near ptr L0783		; negate INTEGER constant internally
	XOR al, al
	RET

L6A31:	; negate LONGINT constant internally
	CALL __EXX
	CALL near ptr L_NEG
	CALL __EXX
	XOR al, al
	RET

L6A39:	; SYNTAX: sign ::= + | -
	; in:	IX = current text pointer
	; out:	E = 255, if current character  = '-'
	;	E =   0, if current character != '+', no sign
	;	E =   1, if current character  = '+'
	MOV dl,0FFH
	MOV al,byte ptr [si+0]
	CMP al, '-'                     ; '-' ?
	JZ near ptr L6A47		; next non-blank if '-' found

	INC dl			; E = 0
	CMP al, '+'                     ; '+' ?
	RETNZ 			; quit if no '-' nor '+'

	INC dl			; E = 1
L6A47:	JMP near ptr  L6F92 		; to next non-blank

L6A4A:	; in:	E = sign, 255 = '-', 0 = no sign, 1 = '+'
	;	B = type
	INC dl
	DEC dl
	RETZ 			; return if no sign
	MOV al,ch
	CMP al, 00AH			; type = INTEGER ?
	JZ near ptr L6A56

	CMP al, 9			; type = REAL ?
	JZ near ptr L6A56

	CMP al, 0EH			; type = LONGINT ?
	JNZ near ptr L6A58		; jump if error

L6A56:	DEC dl			; return NZ if sign = '-'
	RET

L6A58:	CALL near ptr L72E1		; no condition
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
	MOV al,dl
	MOV byte ptr L6A5C_SIGN,al
	CALL near ptr L6A99		; check for an unsigned-constant | string
	RETZ 			; return if a constant found

	MOV cx,200H		; constant identifier ?
	CALL near ptr L6E54		; check if current in id list
				; HL = address of info
	RETNZ 			; return if not in id list

	MOV ch,byte ptr [bx]		; B = type of constant name
	MOV al,ch
	DEC bx

	CMP al, 00EH			; type = LONGINT ?
	JZ near ptr L6A741		; jump if type = LONGINT

	CMP al, 00AH			; not an INTEGER, BYTE, CHAR nor BOOLEAN
	JC near ptr L6A74		; jump if type < 10

	; return INTEGER, BYTE, CHAR or BOOLEAN constant in HL
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	XCHG dx,bx

	XOR al, al			; return with Zero
	RET

L6A74:	CMP al, 9
	JNZ near ptr L6A88		; jump if type not REAL

	; return REAL value in HLDEBC'
	PUSH cx

	MOV ch,byte ptr [bx]
	DEC bx
	MOV cl,byte ptr [bx]
	DEC bx

L6A742:	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	DEC bx
	MOV al,byte ptr [bx]
	DEC bx
	MOV bl,byte ptr [bx]
	MOV bh,al
	CALL __EXX

	XOR al, al			; return with Zero
	POP cx
	RET

L6A741:	; return LONGINT constant in DEHL'
	PUSH cx
	JMP near ptr  L6A742

L6A88:	MOV cl,byte ptr [bx]		; C = length
	MOV dx,offset L7A57
	PUSH cx
	INC cl

L6A8E:	DEC cl
	JZ near ptr L6A97		; jump and return with Zero

	DEC bx
	MOV al,byte ptr [bx]
	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	INC dx
	JMP near ptr  L6A8E

L6A97:	POP cx
	RET

L6A99:	; in:	IX = current text position
	; out:	B = 08h, type = string, C = length, L7A57 filled with value
	;	B = 0Ch, type = char,   C = 1, HL character value
	;	B = 09h, type = real,   HLDEBC' = real value
	;	B = 0Ah, type = integer, HL = integer value
	;	B = 0Eh, type = longint, DE'HL' = longint value
	;	Z-flag = 1, succeeded
	MOV al,byte ptr [si+0]
	CMP al, 27H			; ', start of string constant ?
	JZ near ptr L6AA8		; jump if true

	CMP al, '^'                     ; start of CTRL-<character> constant ?
	JZ near ptr L6AA8		; jump if true

	CMP al, '#'                     ; start of #<num> constant ?
	JNZ near ptr L6B0E		; jump if not string nor character constant

L6AA8:	; read multiple <string>, <num> or CTRL-<character> constants
	MOV bx,offset L7A57
	MOV cl,0
L6AAD:	MOV al,byte ptr [si+0]
	CMP al, '^'
	JZ near ptr L6AD8		; jump for CTRL-<character> constant

	CMP al, '#'
	JZ near ptr L6AEE		; jump for #<num> constant

	CMP al, 27H			; ', start of string constant ?
	JNZ near ptr L6AFE		; quit if none of these constants

	; read <string> constant
L6ABC:	INC si
	MOV al,byte ptr [si+0]
	OR al, al

	JZ near ptr L6AD31
;	 CALL L72D4		 ; Zero --> error
;	 DB 37H			 ; error 55: String constant exceeds line

	CMP al, 027H			; last character = ' ?
	JNZ near ptr L6AD3		; jump and store character if not

	INC si
	MOV al,byte ptr [si+0]
	CMP al, 027H			; two '-characters in a row ?
	JNZ near ptr L6AAD		; if not, jump to end string

	; store a '-character

L6AD3:	MOV byte ptr [bx],al		; store character
	INC bx
	INC cl			; increase string length
	JMP near ptr  L6ABC 		; repeat

L6AD31:	CALL near ptr L72E1		; Zero --> error
	DB 37H			; error 55: String constant exceeds line

L6AD8:	; read CTRL-<character> constant
	INC si
	MOV al,byte ptr [si+0]
	CALL near ptr L04A6		; upcase
	OR al, al

	JZ near ptr L6AD31
;	 CALL L72D4		 ; Zero --> error
;	 DB 37H			 ; error 55: String constant exceeds line

	XOR al, 040H 		; ^A = #1, ^B = #2 etc.
	INC si

L6AE9:	MOV byte ptr [bx],al
	INC bx
	INC cl
	JMP near ptr  L6AAD 		; repeat for next string constant

L6AEE:	; read #<num> constant
	INC si
	PUSH cx
	PUSH bx
	CALL near ptr L07F7		; convert hexadecimal or decimal to HL
	MOV al,bl
	POP bx
	POP cx

	CALL near ptr L72C8		; carry set --> error
	DB 38H			; error 56: Error in integer constant

	JMP near ptr  L6AE9

L6AFE:	MOV ch,8			; assume type = STRING
	MOV al,cl
	DEC al
	JNZ near ptr L6B0B		; STRING if length > 1

	MOV bh,al			; H = 0
	MOV al,byte ptr L7A57
	MOV bl,al			; HL = character
	MOV ch,00CH		; type = CHAR

L6B0B:	JMP near ptr  L6F95 		; get non-blank

L6B0E:	CMP al, '$'                     ; hexadecimal constant ?
	JZ near ptr L6B45

	CALL near ptr L7286		; carry reset if A = digit
L6B15:	JNC near ptr L6B1A		; jump for start of REAL or integer
	XOR al, al
	DEC al			; return A = 255, and NonZero
	RET

L6B1A:	PUSH si
	POP dx
L6B1D:	INC dx
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CALL near ptr L7286		; carry reset if A = digit
	JNC near ptr L6B1D		; yes, check next character

	CALL near ptr L04A6		; upcase
	CMP al, 'E'                     ; 'E' from exponent ?
	JZ near ptr L6B39		; make REAL conversion to HLDEBC'
	CMP al, '.'                     ; comma ?
	JNZ near ptr L6B45		; make integer conversion to HL

	INC dx
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CMP al, '.'                     ; <num>.. ?
	JZ near ptr L6B45		; make integer conversion to HL
	CMP al, ')'                     ; <num>)
	JZ near ptr L6B45		; make integer conversion to HL

L6B39:	; converts ascii REAL to HLDEBC
	; out:	HLDEBC' = binary REAL
	;	B = 9, type = real
	CALL near ptr L11A3		; convert ascii REAL to binary REAL HLDEBC

	CALL near ptr L72C8		; carry set --> error
	DB 39H			; error 57: Error in real constant

	CALL __EXX
	MOV ch,9			; type of real
	JMP near ptr  L6B0B 		; to next non-blank

L6B45:	; converts integer to HL or longint to DE'HL'
	; out:	HL = integer value
	;	B = 0Ah, type = INTEGER
	;	DE'HL' = longint value
	;	B = 0Eh, type = LONGINT
	CALL near ptr A2L 		; convert hexadecimal or decimal to DE:HL

	CALL near ptr L72C8		; carry set --> error
	DB 38H			; error 56: Error in integer constant

	MOV cl,al			; C = 0 if hexadecimal parsed

	MOV al,byte ptr DEF_TYPE
	CMP al, 0FFH
	JZ near ptr SMART_CONST

	CMP al, 0AH
	JZ near ptr L6B46		; check on integer

SMART_CONST_LONGINT:
	; check on longint
	INC cl			; hexadecimal parsed ?
	DEC cl
	JZ near ptr L6B451		; yes, don't check sign

	; DE = 0
	TEST dh,128			; DE negative ?
	JZ near ptr L6B451		; jump if not, OK

	MOV al,byte ptr L6A5C_SIGN
	INC al			; 255 ?, a minus sign present ?
	JNZ near ptr L4AE7		; error: constant out of range

	MOV al,dh			; long > MAXLONGINT + 1
	AND al, 7FH
	OR al, dl
	OR al, bh
	OR al, bl
	JNZ near ptr L4AE7		; error: constant out of range

L6B451:	CALL __EXX			; save in DE'HL'
	MOV ch,0EH
	JMP near ptr  L6B0B

L6B46:	; constant must be integer
	MOV al,dh
	OR al, dl
	JNZ near ptr L4AE7		; error: constant out of range

SMART_CONST_INTEGER:
	INC cl			; hexadecimal parsed ?
	DEC cl
	JZ near ptr L6B461		; jump if hexadecimal

	TEST bh,128			; HL >= 0 and HL <= 32767 ?
	JZ near ptr L6B461		; jump if OK

	MOV al,byte ptr L6A5C_SIGN
	INC al			; 255 ?, a minus sign present ?
	JNZ near ptr L4AE7		; error: constant out of range

	MOV al,bh
	AND al, 7FH
	OR al, bl
	JNZ near ptr L4AE7		; error: constant out of range

L6B461:	MOV ch,0AH 		; type integer
	JMP near ptr  L6B0B 		; to next non-blank

SMART_CONST:
	MOV al,dh
	OR al, dl
	JNZ near ptr SMART_CONST_LONGINT

	INC cl			; hexadecimal parsed ?
	DEC cl
	JZ near ptr L6B461		; return type = INTEGER

	TEST bh,128			; HL >= 32768 and HL <= 65535 ?
	JZ near ptr L6B461		; jump if within INTEGER positive range

	MOV al,byte ptr L6A5C_SIGN
	INC al			; 255 ?, a minus sign present ?
	JNZ near ptr L6B451		; no sign but out of range >> LONGINT

	MOV al,bh
	AND al, 7FH
	OR al, bl
	JZ near ptr L6B461		; if 8000h then return type = INTEGER

	JMP near ptr  L6B451		; return type = LONGINT

;	 JR NZ,L6B451		 ; INTEGER out of range >> LONGINT
;
;	 JR L6B461		 ; return type = INTEGER

O_CODE:	; in:	first byte after call-instruction is non-zero length
	;	followed by 'length' data byte outputted by 'O_BYTE'
	; changes: HL, BC unchanged
	mov bp,sp
	XCHG [bp],bx
	PUSH cx
	MOV ch,byte ptr [bx]		; B = length
L6B53:	INC bx
L6B54:	MOV al,byte ptr [bx]
	CALL near ptr O_BYTE
	INC bx
	DEC ch
	JNZ near ptr L6B54
	POP cx
	mov bp,sp
	XCHG [bp],bx		; jump to byte after last data byte
	RET

L6B5E:	; outputs length byte (C) and data at L7A57
	; in:	C = length of data
	; out:	C = 0
	;	Z-flag = 1
	;	B = unchanged !
	MOV al,cl			; output first 'C' bytes from L7A57
	CALL near ptr O_BYTE

L6B62:	MOV bx,offset L7A57
	INC cl
L6B66:	DEC cl
	RETZ 

	MOV al,byte ptr [bx]
	INC bx
	CALL near ptr O_BYTE

	JMP near ptr  L6B66

O_PSHHL: MOV al,0E5H		 ; out: push hl
	JMP near ptr  O_BYTE

O_POPHL: MOV al,0E1H		 ; out: pop hl
	JMP near ptr  O_BYTE

O_C3:	MOV al,0C3H		; out: 'jp' opcode
	JMP near ptr  O_BYTE

O_DE:	MOV al,dl			; out: value of de
	CALL near ptr O_BYTE
	MOV al,dh
	JMP near ptr  O_BYTE

O_JPHL:	MOV al,0C3H		; out: 'jp' opcode + value of hl
	JMP near ptr  O_OPHL

O_CALHL: MOV al,0CDH                  ; out: 'call' opcode + value of hl
	JMP near ptr  O_OPHL

O_LDBC:	MOV al,1			; out: 'ld bc,' opcode + value of hl
	JMP near ptr  O_OPHL

O_LDDE:	MOV al,11H 		; out: 'ld de,' opcode + value of hl
	JMP near ptr  O_OPHL

O_LDHL:	MOV al,21H 		; out: 'ld hl,' opcode + value of hl

O_OPHL:	CALL near ptr O_BYTE

O_HL:	MOV al,bl			; out: value of hl
	CALL near ptr O_BYTE
	MOV al,bh

O_BYTE:				; out: value of a
	PUSH cx
	MOV ch,al
	MOV al,byte ptr L7900		; 0 = compile to memory
				; 1 = code generation to disk
				; 2 = search address

;	 OR A
;	 JR NZ,L6BA7		 ; jump if not compiling to memory
;
;	 LD (IY+0),B
;
;L6BA7:
	INC di
;	 OR A
;	 JR Z,L6BC6		 ; jump if compiling to memory

	PUSH bx
	PUSH dx

	DEC al			; A = 1 ?
	JZ near ptr L6BC1		; jump if compiling to disk

	PUSH di
	POP dx
	DEC dx
	MOV bx,word ptr L00CE
	OR al, al
	SBB bx,dx

	CALL near ptr L72D4		; Zero --> error
	DB 0C8H			; error 200: run-time error address found

	JMP near ptr  L6BC4

L6BC1:	CALL near ptr L6C02		; write B in record to update

L6BC4:	POP dx
	POP bx
L6BC6:	POP cx

L6BC7:	; check compiler/memory overflow
	; in:	-
	; out:	-
	PUSH bx
	PUSH dx

	MOV dx,word ptr L7BE1		; start of free area + 1024

	; DE = lowest address that is still free

	MOV word ptr COMPCUR,dx		; current compiler address
	MOV bx,word ptr L7B73		; top of variable table
	DEC bh			; 256 bytes tolerance
	STC
	SBB bx,dx
	JC near ptr ERR63

;	 CALL L72C8		 ; carry set --> error
;	 DB 63H			 ; error 99: Compiler overflow

	PUSH di
	POP dx			; DE = destination address for code

	MOV bx,word ptr L7908		; HL = data start address
	DEC bh			; minus 512 bytes tolerance
	DEC bh
	SBB bx,dx

	JC near ptr ERR62

	POP dx
	POP bx
	RET

	; these are used for printing more info during compilation about
	; the amount of free compiler memory and free space for code
COMPCUR: DW 0
;MEMCUR:  DW 0


ERR62:	CALL near ptr L72E1		; no condition
	DB 62H			; error 98: Memory overflow

ERR63:	CALL near ptr L72E1		; no condition
	DB 63H			; error 99: Compiler overflow


L6C02:	; With this routine a previous written block can be updated.
	; Used by FORWARD ?
	; in:	B = data byte to write in 128 byte buffer L7957
	;
	MOV bx,offset L7BDB
	pushf
	OR byte ptr [bx],2
	popf		; block is dirty

	TEST byte ptr [bx],1		; already read ?
	JZ near ptr L6C12		; jump if block already read

	pushf
	AND byte ptr [bx],11111110b
	popf		; make already read

	PUSH cx
         CALL near ptr L6CF9                 ; read record to update in buffer L7957
	POP cx


L6C12:	; in:	B = data byte to write in 128 byte buffer L7957
	; out:	L7BDC increased to next byte in block
	;	reset if 0 if it became equal to block size

         ; CodeFileBufferPos
;         LD A,(L7BDC)               ; A = index to 128 byte buffer
;         LD E,A
;         LD D,0
;         LD HL,L7957                ; start of block buffer
         MOV dx,word ptr CODEFILEBUFFERPOS
         MOV bx,offset CODEFILEBUFFER
	ADD bx,dx

         MOV byte ptr [bx],ch                  ; write data byte to buffer

;         INC A
;         JP P,L6C2C                 ; jump if index <= 127

         INC dx
         TEST dh,4                    ; test tenth bit, equals 1024 ?
         JZ near ptr L6C2C                 ; jump if < 1024

         CALL near ptr L6CFD                 ; write to file

         PUSH bx
         MOV bx,word ptr CODEFILEPOS
         MOV bl,0
         MOV al,bh
         AND al, 0FCH
         MOV bh,al
;         LD A,L
;         AND 80H                    ; CodeFileBufferSize
;         LD L,A

;         LD DE,128                  ; CodeFileBufferSize
         MOV dx,offset CODEFILEBUFFERSIZE
         ADD bx,dx
         MOV word ptr CODEFILEPOS,bx
         POP bx

         JNC near ptr L6C2B

         MOV bx,word ptr CODEFILEPOS+2
         INC bx
         MOV word ptr CODEFILEPOS+2,bx

L6C2B:
;         LD HL,(L7954)              ; increase file block count
;         INC HL                     ; because RANDOM READ/WRITE don't update
;         LD (L7954),HL              ; the block count

;         XOR A                      ; start all over with index = 0
         MOV dx,0                    ; start over at byte 0 of buffer

L6C2C:
         MOV word ptr CODEFILEBUFFERPOS,dx
;         LD (L7BDC),A               ; save for next byte
	RET

L6C30:	;
	; in:	DE = number of data bytes to allocate
	; out:	-
	MOV bx,word ptr L7908		; HL = data start address
	OR al, al
	SBB bx,dx		; carry set if (L7908) < DE

	CALL near ptr L72C8		; carry set --> error
	DB 62H			; error 98: Memory overflow

	MOV word ptr L7908,bx		; set new data start address
         JMP near ptr  L6BC7                   ; check compiler, memory overflow

L6C3F:   ; update address at HL with current address in IY
         ; in:    HL = address to update
         PUSH di
	POP dx

L6C42:   ; in:    HL = address to update
	;	DE = data to update address HL with
	MOV al,byte ptr L7900
	DEC al
	JZ near ptr L6C53		; jump if compiling to disk

	; update directly in RAM
	PUSH di			; save old code address

	PUSH bx
	POP di			; set destination address for data
	CALL near ptr O_DE		; update data

	POP di			; restore code address
	RET

L6C53:	PUSH cx
	PUSH dx			; save update data
	PUSH bx			; save address to update

	MOV bx,word ptr L7BDF		; start address of update table

	MOV al,byte ptr L7BE3
	MOV ch,al			; B = number of update entries in table
	INC ch

	; insert an entry in the update table
	; table is sorted from high to low
	; 7FFFH, 7865H, 7600H, 75FEH etc.
L6C5E:	DEC ch
	JZ near ptr L6C84		; jump if end of table reached

	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]

         mov bp,sp
	XCHG [bp],bx                 ; push update table pointer
				; pop address to update in HL
	OR al, al
	SBB bx,dx		; update address - DE
	ADD bx,dx

         mov bp,sp
	XCHG [bp],bx                 ; pop update table pointer
				; push address to update

	JC near ptr L6C71		; jump if update address < DE
				; in range

	INC bx			; next entry in update table
	INC bx
	INC bx
	JMP near ptr  L6C5E

L6C71:	; DE = address read from update table
	DEC bx

	XCHG dx,bx 		; DE = pointer to first byte of entry
				; in update table
	MOV bl,ch
	MOV bh,0
	ADD bx,bx		; HL = 4 * entries left in update table
	ADD bx,bx
	MOV ch,bh			; BC = size of entries left
	MOV cl,bl
	ADD bx,dx
	MOV dh,bh
	MOV dl,bl
	DEC bx			; HL = address last byte of lastused entry

	INC dx
	INC dx
	INC dx			; DE =
	CALL __LDDR

	INC bx
	; HL = address of new free inserted entry

L6C84:   POP dx                     ; pop address to update
	MOV byte ptr [bx],dl
	INC bx
	MOV byte ptr [bx],dh
	INC bx
         POP dx                     ; pop update data
	MOV byte ptr [bx],dl
	INC bx
	MOV byte ptr [bx],dh
	POP cx
	MOV bx,offset L7BE3		; increase number to update ?
	INC byte ptr [bx]
	RETNZ 

	XOR al, al			; write 256 updates
	JMP near ptr  L6C9B

L6C96:	MOV al,byte ptr L7BE3
	OR al, al
	RETZ 			; return if no updates

L6C9B:	PUSH cx
	PUSH dx
	PUSH di
	MOV ch,al
	MOV bx,word ptr L7BDF

L6CA3:	PUSH cx			; save number of updates left

	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]
	INC bx

	PUSH bx
	XCHG dx,bx
	CALL near ptr L6CC2
	POP bx

	MOV ch,byte ptr [bx]
	INC bx

	PUSH bx
	CALL near ptr L6C02		; write B in record to update
	POP bx

	MOV ch,byte ptr [bx]
	INC bx
	PUSH bx

         CALL near ptr L6C02                 ; write B in record to update

         POP bx

	POP cx			; B = number of updates left
	DEC ch
	JNZ near ptr L6CA3

	POP bx
	POP dx
	POP cx

L6CC2:   ; in:    HL = addres to update
	; out:	IY = HL
	; unchanged: BC, DE
	PUSH bx
	POP di			; init IY with code address

	MOV al,byte ptr L7900
	DEC al
	RETNZ 			; return if searching

	PUSH dx
	PUSH cx

	; calculate from current address in HL the
	; block position and
	; relative block number
	MOV dx,word ptr L7902
	OR al, al
	SBB bx,dx		; HL = relative address to start of code

;         LD A,L
;         AND 07FH
;         LD (L7BDC),A               ; set position within block

;         LD A,L
;         AND 80H
;         LD L,A

         MOV dx,word ptr CODEFILESTART
         ADD bx,dx

         MOV dx,word ptr CODEFILESTART+2
         JNC near ptr L6CC3

         INC dx
L6CC3:

;         LD A,L
;         AND 07FH
;         LD (L7BDC),A               ; set position within block
         MOV al,bl
         MOV byte ptr CODEFILEBUFFERPOS,al
         MOV al,bh
         AND al, 3
         MOV byte ptr CODEFILEBUFFERPOS+1,al ; mask for CodeFileBufferSize = 1024

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

         MOV al,bh
         AND al, 0FCH                   ; mask for CodeFileBufferSize = 1024
         MOV cl,al

         MOV al,byte ptr CODEFILEPOS+1
         AND al, 0FCH                   ; mask for CodeFileBufferSize = 1024
         CMP al, cl
         JNZ near ptr L6CC4

         MOV al,byte ptr CODEFILEPOS+2
         CMP al, dl
         JNZ near ptr L6CC4

         MOV al,byte ptr CODEFILEPOS+3
         CMP al, dh
         JZ near ptr L6CF6

;         LD DE,(L7954)              ; DE = current block
;         OR A
;         SBC HL,DE
;;!       pushf
;         ADD HL,DE
;;!       popf
;         JR Z,L6CF6                 ; jump if equal to current block

L6CC4:
         PUSH dx
         PUSH bx
	CALL near ptr L6CFD		; write 128 bytes to file
	POP bx
         POP dx

         MOV word ptr CODEFILEPOS,bx
         MOV word ptr CODEFILEPOS+2,dx
;         LD (L7954),HL

L6CF6:	POP cx
	POP dx
	RET

L6CF9:   ; in:    FCB at L7933 filled in
	; out:	read 128 bytes from FCB to buffer at L7957
	; changes: HL, DE, BC
	; unchanged: IY

         PUSH di

         MOV bx,word ptr CODEFILEPOS
         MOV bl,0
         MOV al,bh
         AND al, 0FCH                   ; mask for CodeFileBufferSize == 1024
         MOV bh,al
;         LD A,L
;         AND 80H                    ; CodeFileBufferSize
;         LD L,A
         MOV dx,word ptr CODEFILEPOS+2
         MOV cx,offset CODEFILE
         CALL near ptr FILESEEK              ; set to current position

         MOV bx,offset CODEFILEBUFFERSIZE   ; read 128 bytes from file
                                    ; CodeFileBufferSize
         MOV dx,offset CODEFILEBUFFER       ; L7957
         CALL near ptr READFILE              ; read from file

         POP di

         OR al, al
         RETZ                       ; quit if no errors

	CALL near ptr L72E1		; no condition
	DB 0FAH			; error 250: Disk or directory full

;         LD C,021H                  ; random record read 128 bytes
;         JR L6D09

L6CFD:
	; in:	FCB at L7933 filled in
	; out:	writes 128 byte buffer at L7957 to file
	;	no errors
	; changes: HL, DE, BC
	; unchanged: IY
	MOV bx,offset L7BDB
	pushf
	OR byte ptr [bx],1
	popf		; 1 = no record read to update

	TEST byte ptr [bx],2
	RETZ 			; return if not busy updating

	pushf
	AND byte ptr [bx],11111101b
	popf		; 0 = updating finished
;         LD C,022H                  ; random record write 128 bytes

L6D09:	; in:	C = 21H, read
	;	C = 22H, write
	; unchanged: IY

         PUSH di
         MOV bx,word ptr CODEFILEPOS
         MOV bl,0
         MOV al,bh
         AND al, 0FCH                   ; mask for CodeFileBufferSize == 1024
         MOV bh,al
;         LD A,L
;         AND 80H                    ; CodeFileBufferSize
;         LD L,A
         MOV dx,word ptr CODEFILEPOS+2
         MOV cx,offset CODEFILE
         CALL near ptr FILESEEK              ; set to current position

         MOV bx,offset CODEFILEBUFFERSIZE   ; read 128 bytes from file
                                    ; CodeFileBufferSize
         MOV dx,offset CODEFILEBUFFER
         CALL near ptr WRITEFILE             ; read to file
         POP di

         OR al, al

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
         RETZ                       ; return if ???

	CALL near ptr L72E1		; no condition
	DB 0FAH			; error 250: Disk or directory full

L6D24:	; pushes 13 bytes starting at L7B64 to the stack
	; changes: HL',DE',BC'
	CALL __EXX
	MOV dx,offset L7B64
	JMP near ptr  L6D2E

L6D2A:	; pushes 13 bytes starting at L7B57 to the stack
	; changes: HL',DE',BC'
	CALL __EXX
	MOV dx,offset L7B57
L6D2E:	POP bx
	MOV word ptr L7BD5,bx		; temporary save return address
	MOV bx,-13
	ADD bx,sp
	MOV sp,bx
	XCHG dx,bx
	MOV cx,13
	CALL __LDIR
L6D3D:	MOV bx,word ptr L7BD5		; restore return address
	PUSH bx
	CALL __EXX
	RET

L6D43:	; pops 13 bytes to L7B64
	; changes: HL',DE',BC'
	CALL __EXX
	MOV dx,offset L7B64
	JMP near ptr  L6D4D

L6D49:	; pops 13 bytes to L7B57
	; changes: HL',DE',BC'
	CALL __EXX
	MOV dx,offset L7B57
L6D4D:	POP bx
	MOV word ptr L7BD5,bx
	MOV bx,0
	ADD bx,sp
	MOV cx,13
	CALL __LDIR
	MOV sp,bx
	JMP near ptr  L6D3D

L6D5D:	; moves 13 bytes from stack+2 to L7B64
	; changes: HL',DE',BC'
	CALL __EXX
	MOV dx,offset L7B64
	JMP near ptr  L6D67

L6D63:	; moves 13 bytes from stack+2 to L7B57
	; changes: HL',DE',BC'
	CALL __EXX
	MOV dx,offset L7B57
L6D67:	MOV bx,2
	ADD bx,sp
	MOV cx,13
	CALL __LDIR
	CALL __EXX
	RET

L6D72:	; add IY to id table
	PUSH di
	POP dx

L6D75:	; add DE to id table
;	 LD A,D
;	 CALL L6D7A		 ; add byte to id table
;	 LD A,E
	PUSH bx
	MOV bx,word ptr L7B73
	MOV byte ptr [bx],dh
	DEC bx			; decrease bottom of the table
	MOV byte ptr [bx],dl
	DEC bx			; decrease bottom of the table
	MOV word ptr L7B73,bx
	POP bx
	JMP near ptr  L6BC7 		; check compiler, memory overflow

L6D7A:	; in:	A = data byte to be added to the identifier table
	; out:	-
	PUSH bx
	MOV bx,word ptr L7B73
	MOV byte ptr [bx],al
	DEC bx			; decrease bottom of the table
	MOV word ptr L7B73,bx
	POP bx
	JMP near ptr  L6BC7 		; check compiler, memory overflow

L6D87:	; add the identifier at address IX to the identifier table
	; in:	-
	; out:	-
	MOV al,byte ptr [si+0]
	CALL near ptr L7271		; letter or underscore?

L6D8D:	CALL near ptr L72C8		; carry set --> error
	DB 3AH			; error 58: Illegal character in identifier

	CALL near ptr L6ED0		; check if already in identifier table

L6D94:	CALL near ptr L6EB8		; test if reserved word
				; gives error 53 if word is reserved
	MOV al,byte ptr [si+0]		; A = first letter
L6D9A:	CMP al, 'a'
	JC near ptr L6DA4
	CMP al, 'z'+1
	JNC near ptr L6DA4
	SUB al, 'a'-'A'
L6DA4:	CALL near ptr L6D7A		; add byte to id table
	INC si
	MOV al,byte ptr [si+0]
	CALL near ptr L7282		; letter, underscore or decimal
	JNC near ptr L6D9A
	MOV bx,word ptr L7B73
	INC bx
	pushf
	OR byte ptr [bx],128
	popf		; mark end of added identifier
	JMP near ptr  L6F95 		; get to next non-blank

L6DBA:	MOV al,byte ptr [si+0]
	CALL near ptr L7271		; letter or underscore?

	CALL near ptr L72C8		; carry set --> error
	DB 3AH			; error 58: Illegal character in identifier

	JMP near ptr  L6D94

L6DC6:	; calculates and adds the length of the newly defined struct
	; as a word to the id table
	; in:	(L7B75), (L7B73)
	; out:	added (L7B75) - (L7B73)
	;	(L7B75) = (L7B73)
	MOV bx,word ptr L7B75		; HL = top of id table before
	MOV dx,word ptr L7B73		; DE = top of id table after
	OR al, al
	SBB bx,dx		; calculate the difference
	XCHG dx,bx
	CALL near ptr L6D75		; add the length of the variable declaration
	MOV bx,word ptr L7B73
	MOV word ptr L7B75,bx		; equal top before and top after
	RET

L6DDB:	; in:	B =
	;	C =
	MOV bx,word ptr L7B7B		; HL = start of identifier list
	JMP near ptr  L6DE3

L6DE0:	; out:	-
	MOV bx,word ptr L7B77		; HL = absolute top of id list

L6DE3:	; in:	HL = end of list to search
	;	B = 1 = LABEL,	2 = CONSTANT
	;	    3 = TYPE,	4 = VARIABLE
	;	    5 = PROCEDURE 6 = FUNCTION
	MOV word ptr L7B7D,bx
	MOV al,byte ptr L7BC0
	CMP al, cl
	JZ near ptr L6E48
	MOV al,cl
	MOV byte ptr L7BC0,al
	MOV bx,word ptr L7B75
L6DF3:
	MOV dx,word ptr L7B7D

	MOV al,dl
	CMP al, bl
	JNZ near ptr L6E03
	MOV al,dh
	CMP al, bh
	JNZ near ptr L6E03

;	 XOR A
;	 SBC HL,DE		 ; tabel is empty if HL = DE
;;!	 pushf
;	 ADD HL,DE
;;!	 popf
;	 JR NZ,L6E03		 ; no, tabel is not empty
	XOR al, al
	MOV byte ptr L7BC1,al
	DEC al			; return with 255 and NonZero
				; not found
	RET

L6E03:	INC bx
	MOV dl,byte ptr [bx]		; DE = offset, # bytes of struct
	INC bx
	MOV dh,byte ptr [bx]
	ADD bx,dx
	MOV al,byte ptr [bx]
	OR al, al			; first byte zero, does not contain a name
	JZ near ptr L6DF3		; yes, search next
	DEC bx
	MOV al,byte ptr [bx]
	INC bx
	CMP al, cl			; gelijk C?
	JNZ near ptr L6DF3		; no, search next

	PUSH cx
	PUSH bx
	MOV dx,offset TEMPID
	DEC bx
	DEC bx			; HL = address of first letter of ID

	CALL near ptr FASTCMPR
	JZ near ptr L6E3B		; jump if equal

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
L6E37:	POP bx
	POP cx
	JMP near ptr  L6DF3 		; search next

FASTCMPR:; in:	HL = address of identifier from id table, downwards
	;	DE = address of upcased text identifier, upwards
	; out:	HL = position below last keyword character
	;	Z-flag = 1, found
	;	Z-flag = 0, not found
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx		; A = byte from text
	INC dx
	CMP al, byte ptr [bx]
	RETNZ 			; quit if not equal
	DEC bx
	TEST al,128
	JZ near ptr FASTCMPR		; repeat until end of string
	XOR al, al
	RET

FASTCMP: ; in:	HL = address keyword, upwards
	;	DE = address of upcased text identifier, upwards
	; out:	HL = position after last keyword character
	;	DE = position after identifier in text
	;	Z-flag = 1, found
	;	Z-flag = 0, not found
	PUSH cx
	MOV dx,offset TEMPID
FASTCMPL:xchg dx,bx
	MOV al,[bx]
	xchg dx,bx		; A = byte from text
	INC dx
	CMP al, byte ptr [bx]
	pushf
	INC bx
	popf
	JNZ near ptr FASTCMPQ
	RETNZ 			; quit if not equal
	OR al, al
	JNS near ptr FASTCMPL		; repeat until end of string
	MOV dx,word ptr TEMPPTR
	XOR al, al
FASTCMPQ:POP cx
	RET

BUILDID: ; out:	IX = current text pointer
	;	TEMPPTR = position after word in text
	PUSH dx
	PUSH si
	POP dx
	MOV bx,offset TEMPID-1
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx		; A = first byte from text
	CALL near ptr L04A6		; up case
	INC dx
	INC bx
	MOV byte ptr [bx],al
	CALL near ptr L7282
	JC near ptr BUILDI2		; quit if no character of word

BUILDI1: xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CALL near ptr L7282		; legal character ?
	JC near ptr BUILDI2

	CALL near ptr L04A6		; up case
	INC dx			; next from text
	INC bx
	MOV byte ptr [bx],al		; save character
	JMP near ptr  BUILDI1

BUILDI2:
	pushf
	OR byte ptr [bx],128
	popf
	MOV word ptr TEMPPTR,dx
	POP dx
	RET

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

L6E3B:	MOV word ptr L7BC2,bx		; save position before known word
	MOV dx,word ptr TEMPPTR
	MOV word ptr L7BC4,dx		; save position after word in text
	POP bx			; HL = start of known word declaration
	POP cx			; BC = (300H for type identifier or
				;       200H for constant identifier)
	MOV al,byte ptr [bx]		; A = type of known word
	MOV byte ptr L7BC1,al

L6E48:	; in:	B =
	;	C =
	; out:	Z-flag set if B = (L7BC1)
	;	HL = position before known word
	;	DE = position after word in text
	MOV bx,word ptr L7BC2
	MOV dx,word ptr L7BC4
	MOV al,byte ptr L7BC1
	CMP al, ch			; identical types?
	RET

L6E54:	; searches if current word is an identifier list
	; in:	B = 1 = LABEL,	 2 = CONSTANT
	;	    3 = TYPE,	 4 = VARIABLE
	;	    5 = PROCEDURE, 6 = FUNCTION
	;	C =
	; out:	Z-flag = NonZero if not found
	;		Zero if found
	CALL near ptr L6DE0
	RETNZ 			; return if not found
	JMP near ptr  L6E96 		; go to next non-blank

L6E5A:	; in:	first byte after call instruction is #bytes following the name
	;	second two byte form an address of a reserved word list
	; out:	Z-flag set if a reserved word is found that equals the word
	;	at position IX. HL then contains the address of the byte
	;	directly after the reserved word
	mov bp,sp
	XCHG [bp],bx
	MOV cl,byte ptr [bx]
	INC bx
	MOV dl,byte ptr [bx]
	INC bx
	MOV dh,byte ptr [bx]
	INC bx
	mov bp,sp
	XCHG [bp],bx
	XCHG dx,bx

L6E63:	CALL near ptr L6E7D
	RETZ 			; quit if okay

	DEC bx			; go back to last character tested
L6E68:	TEST byte ptr [bx],128		; was this the last character?
	pushf
	INC bx
	popf
	JZ near ptr L6E68		; no, try again
	MOV ch,0
	ADD bx,cx
	MOV al,byte ptr [bx]
	OR al, al			; last word of this table checked?
	JNZ near ptr L6E63		; no, continue searching
	DEC al			; return with A = 255 and NonZero
				; for not found
	RET

L6E76:	; searches for the word in the text at IX in the given list
	;
	mov bp,sp
	XCHG [bp],bx
	MOV dl,byte ptr [bx]		; DE = address of reserved word
	INC bx
	MOV dh,byte ptr [bx]
	INC bx
	mov bp,sp
	XCHG [bp],bx		; new return address after 2 data bytes
	XCHG dx,bx 		; HL = address of reserved word

L6E7D:	PUSH si
	POP dx
	MOV al,byte ptr [bx]		; get first character
	CALL near ptr L7271		; check if letter or underscore
	JC near ptr L6E92		; carry set if error
	CALL near ptr L6E9C		; compare strings
	RETNZ 			; quit if not equal

	; at this point the strings are equal
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	CALL near ptr L7282		; letter, underscore or decimal
	JC near ptr L6E96		; jump if not letter, underscore or decimal

	OR al, al
	RET

L6E92:	CALL near ptr L6E9C1		; compare strings
	RETNZ 			; quit if not equal

L6E96:	; in:	DE = current text pointer
	; out:	IX = updated text pointer to next non-blank
	PUSH dx
	POP si			; update text pointer to text buffer 79D7
	JMP near ptr  L6F95 		; moves IX to the next non-blank

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

L6E9C1:	PUSH cx
L6E9D:	MOV ch,byte ptr [bx]
	xchg dx,bx
	MOV al,[bx]
	xchg dx,bx
	INC bx
	INC dx
	MOV cl,ch
	pushf
	AND ch,01111111b
	popf
	CMP al, 'a'                     ; < 'a'?
	JC near ptr L6EAE		; yes, continue
	CMP al, 'z'+1                   ; > 'z'?
	JNC near ptr L6EAE		; yes, continue
	SUB al, 'a'-'A'
L6EAE:	CMP al, ch			; equal characters?
	JNZ near ptr L6EB6		; no, return with NonZero
	TEST cl,128			; last character of string in HL tested ?
	JZ near ptr L6E9D		; no, go for then next
	XOR al, al			; found, return with Zero
L6EB6:	POP cx
	RET

L6EB8:	; tests if the current name is a reserved word, slow!!!
	MOV bx,offset L7513
L6EBB:	MOV cl,byte ptr [bx]
	INC cl
	RETZ 			; quit if C was 255
	DEC cl
	INC bx
	MOV dl,byte ptr [bx]		; DE = address to table of reserved words
	INC bx
	MOV dh,byte ptr [bx]
	INC bx
	PUSH bx
	XCHG dx,bx
	CALL near ptr L6E63
	POP bx
	JNZ near ptr L6EBB

	CALL near ptr L72E1		; no condition
	DB 35H			; error 53: Reserved word

L6ED0:	MOV al,byte ptr L7B91
	MOV cl,al
	CALL near ptr L6DDB

L6ED7:	MOV al,byte ptr L7BC1
	OR al, al
	RETZ 

	CALL near ptr L72E1		; no condition
	DB 2BH			; error 43: Duplicate identifier or label

L6EE0:	; in:	-
	; out:	Zero if '[' parsed
	;	Zero if '(.' parsed
	MOV al,'['
	CALL near ptr L6F29		; match('[')
	RETZ 			; return if matched

	MOV al,byte ptr [si+0]
	CMP al, '('                     ; match('(')
	RETNZ 			; return if not '(' matched

	MOV al,byte ptr [si+1]
	CMP al, '.'
	RETNZ 			; return if not '(.' matched

L6EF2:	INC si
	JMP near ptr  L6F92 		; to next non-blank

L6EF7:	; in:	-
	; out:	Zero if ']' parsed
	;	Zero if '.)' parsed
	MOV al,']'
	CALL near ptr L6F29		; match(']')
	RETZ 
	MOV al,byte ptr [si+0]
	CMP al, '.'
	RETNZ 
	MOV al,byte ptr [si+1]
	CMP al, ')'
	RETNZ 
	JMP near ptr  L6EF2

L6F0B:	; matches ':', if present
	; returns NZ if not matched
	MOV al,':'
	JMP near ptr  L6F29

L6F0F:	; matches ';', if present
	; returns NZ if not matched
	MOV al,';'
	JMP near ptr  L6F29

L6F13:	; matches ',', if present
	; returns NZ if not matched
	MOV al,','                   ; checkes if ',' is the next symbol
	JMP near ptr  L6F29

L6F17:	; matches '.', if present
	; returns NZ if not matched
	MOV al,'.'
	JMP near ptr  L6F29

L6F1B:	; matches '(', if present
	; returns NZ if not matched
	MOV al,'('
	JMP near ptr  L6F29

L6F1F:	; matches ')', if present
	; returns NZ if not matched
	MOV al,')'
	JMP near ptr  L6F29

L6F23:	; matches '=', if present
	; returns NZ if not matched
	MOV al,'='
	JMP near ptr  L6F29

L6F27:	; matches '^', if present
	; returns NZ if not matched
	MOV al,'^'

L6F29:	; matches character in A, if this is the next character
	; returns NZ if this is not the next character
	CMP al, byte ptr [si+0]
	RETNZ 			; quit if not equal
	JMP near ptr  L6F92 		; get next non-blank character if equal

L6F30:	; matches a '[' or '(.' and gives error 8 otherwise
	CALL near ptr L6EE0		; match('[') or match('(.')
	RETZ 			; quit if '[' or '(.' matched

	CALL near ptr L72E1		; no condition
	DB 8			; error 8: '[' expected

L6F38:	; matches a ']' and gives error 9 otherwise
	CALL near ptr L6EF7		; match(']') or match('.)')
	RETZ 			; return if matched

	CALL near ptr L72E1		; no condition
	DB 9			; error 9: ']' expected

L6F40:	; matches a ':' and gives error 2 otherwise
	CALL near ptr L6F0B		; match(':'), if present
	RETZ 			; return if ':' matched

	CALL near ptr L72E1		; no condition
	DB 2			; error 2: ':' expected

L6F48:	; matches a ';' and gives error 1 otherwise
	; match(';')
	; in:	-
	; out:	-
	CALL near ptr L6F0F		; match(';'), if present
	RETZ 			; return if ';' matched

L6F4C:	CALL near ptr L72E1		; no condition
	DB 1			; error 1: ';' expected

L6F50:	; matches a ';' and gives error 1 or 41 otherwise
	CALL near ptr L6F0F		; match(';'), if present
	RETZ 			; return if ';' matched
	MOV al,byte ptr L7B98
	OR al, al
	JZ near ptr L6F4C		; generate error 1 if (L7B98)=0

	CALL near ptr L72E1		; no condition
	DB 29H			; error 41: unknown identifier or syntax error

L6F5E:	; matches a ',' and gives error 3 otherwise
	CALL near ptr L6F13		; match(','), if present
	RETZ 			; return if ',' matched

	CALL near ptr L72E1		; no condition
	DB 3			; error 3: ',' expected

L6F66:	; matches a '(' and gives error 4 otherwise
	CALL near ptr L6F1B		; match('('), if present
	RETZ 			; return if '(' matched

	CALL near ptr L72E1		; no condition
	DB 4			; error 4: '(' expected

L6F6E:	; matches a ')' and gives error 5 otherwise
	CALL near ptr L6F1F		; match(')'), if present
	RETZ 			; return if ')' matched

	CALL near ptr L72E1		; no condition
	DB 5			; error 5: ')' expected

L6F76:	; matches a '=' and gives error 6 otherwise
	CALL near ptr L6F23		; match('='), if present
	RETZ 			; return if '=' matched

	CALL near ptr L72E1		; no condition
	DB 6			; error 6: '=' expected

L6F7E:	; matches a ':=' and gives error 7 if this is not present
	; in:	-
	; out:	-
	CALL near ptr L6E76
	DW L7582 		; start of reserved word: :=
	RETZ 			; return if ':=' parsed

	CALL near ptr L72E1		; no condition
	DB 7			; error 7: ':=' expected

L6F88:	; matches OF and gives error 15 if this is not present
	CALL near ptr L6E76
	DW L7560 		; start of reserved word: OF
	RETZ 

	CALL near ptr L72E1		; no condition
	DB 0FH			; error 15: OF expected

L6F92:	; moves to next non-blank
	CALL near ptr L7124		; read next character from input

L6F95:	; moves IX to the next non-blank character
	; out:	Zero on succes
	XOR al, al
	MOV byte ptr L7B98,al
	DEC al
	MOV byte ptr L7BC0,al
	MOV al,byte ptr [si+0]
	OR al, al			; end of text line buffer?
	JZ near ptr L6F92		; read next line and next non blank
	CMP al, 20H			; start with space ?
	JZ near ptr L6F92
	CMP al, 9			; start with TAB ?
	JZ near ptr L6F92
	CMP al, '('                     ; first character of comment '(*   *)'
	JZ near ptr L6FB5
	CMP al, '{'                     ; compiler option or comment
	JZ near ptr L6FBF

L6FB3:	MOV word ptr FILEBUFFERLASTPOS,si
	PUSH cx
	PUSH bx
	CALL near ptr BUILDID
	POP bx
	POP cx
	XOR al, al
	RET

L6FB5:	MOV al,byte ptr [si+1]
	CMP al, '*'
	JNZ near ptr L6FB3
	CALL near ptr L7124		; read next character from input
L6FBF:	PUSH cx
	MOV ch,byte ptr [si+0]
	MOV al,byte ptr [si+1]
	CMP al, '$'                     ; '{' followed by a '$'
	JZ near ptr L6FEB

L6FCA:	CALL near ptr L7124		; read next character from input

L6FCD:	MOV al,ch
	CMP al, '*'
	MOV al,byte ptr [si+0]
	JNZ near ptr L6FE4
	CMP al, ch
	JNZ near ptr L6FCA
	MOV al,byte ptr [si+1]
	CMP al, ')'
	JNZ near ptr L6FCA
	CALL near ptr L7124		; read next character from input
	JMP near ptr  L6FE8

L6FE4:	CMP al, '}'
	JNZ near ptr L6FCA

L6FE8:	POP cx
	JMP near ptr  L6F92 		; move to next non blank

L6FEB:	; found: '{$'
	PUSH cx
	PUSH dx
	PUSH bx
	CALL near ptr L7124		; read '{' away
L6FF1:	CALL near ptr L7124		; read '$' away
	MOV al,byte ptr [si+0]
	CALL near ptr L04A6		; upcase
	CMP al, 'I'                     ; I  = include or i/o checking ?
				; I+ = I/O Error Handling on
	MOV ch,1			; bit 0
	JZ near ptr L704D

	CMP al, 'R'                     ; R+ = Index Range Check on
	MOV ch,2			; bit 1
	JZ near ptr L704D

	CMP al, 'A'                     ; A+ = Absolute code on
	MOV ch,4			; bit 2
	JZ near ptr L704D

	CMP al, 'U'                     ; U+ = User Interrupt on
	MOV ch,8			; bit 3
	JZ near ptr L704D

	CMP al, 'X'                     ; X+ = Array Optimization
	MOV ch,10H 		; bit 4
	JZ near ptr L704D

	CMP al, 'V'                     ; V+ = Var-parameter Type Checking on
	MOV ch,20H 		; bit 5
	JZ near ptr L704D

	CMP al, 'B'                     ; B+ = I/O Mode Selection
	MOV ch,40H 		; bit 6
	JZ near ptr L704D

	CMP al, 'C'                     ; C+ = Control C and S interpretation on
	MOV ch,80H 		; bit 7
	JZ near ptr L704D

	CMP al, 'W'                     ; W# = # levels of nesting With statements
	JZ near ptr L707A
	MOV ch,0

	CMP al, 'K'                     ; n.a.
	JZ near ptr L704D
	CMP al, 'D'                     ; n.a.
	JZ near ptr L704D
	CMP al, 'F'                     ; n.a.
	JZ near ptr L708E
	CMP al, 'G'                     ; n.a.
	JZ near ptr L708E
	CMP al, 'P'                     ; n.a.
	JZ near ptr L708E

	CALL near ptr L72E1		; no condition
	DB 5DH			; error 93: Invalid compiler directive

L7048:	POP bx
	POP dx
	POP cx
	JMP near ptr  L6FCD

L704D:	CALL near ptr L7124		; read letter away
	MOV al,byte ptr [si+0]
	MOV cl,0
	CMP al, '+'
	JZ near ptr L7065
	DEC cl			; C = 255
	CMP al, '-'
	JZ near ptr L7065
	DEC ch			; B = 1 (include command) ?

	CALL near ptr L72DA		; NonZero --> error
	DB 5DH			; error 93: Invalid compiler directive

	JMP near ptr  L709B 		; yes, {$i filename}

L7065:	MOV bx,offset L7B9D
	MOV al,byte ptr [bx]
	XOR al, cl			; XOR 0 = +, XOR 255 = -
	OR al, ch			; set corresponding bit
	XOR al, cl			; XOR 0 = +, XOR 255 = -
	MOV byte ptr [bx],al

L706D:	CALL near ptr L7124		; read next character from input
L7070:	MOV al,byte ptr [si+0]
	CMP al, 02CH
	JZ near ptr L6FF1
	JMP near ptr  L7048

L707A:	CALL near ptr L7124		; read letter 'W'
	MOV al,byte ptr [si+0]
	CALL near ptr L7286		; carry reset if A = digit

	CALL near ptr L72C8		; carry set --> error
	DB 5DH			; error 93: Invalid compiler directive

	SUB al, '0'
         MOV byte ptr WITHDEPTH,al           ; new WITHDEPTH
	JMP near ptr  L706D

L708E:	CALL near ptr L7124		; read next character from input
	MOV al,byte ptr [si+0]
	CALL near ptr L7286		; carry reset if A = digit
	JNC near ptr L708E
	JMP near ptr  L7070

L709B:	; parse spaces and then the include file name
	CMP al, ' '                     ; followed by a space ?
	JNZ near ptr L70A7		; no, end
	CALL near ptr L7124		; read next character from input
	MOV al,byte ptr [si+0]
	JMP near ptr  L709B

L70A7:
;	 LD A,(L790E)
;	 OR A			 ; already reading from a secondary file ?
;				 ; (an include file)
;
	MOV al,byte ptr FILELEVEL
	CMP al, MAXFILELEVELS
	CALL near ptr L72D4		; Zero --> error
	DB 60H			; error 96: No nesting of include files

	PUSH si
	POP bx			; HL = compiler source text pointer

	PUSH bx

         MOV dx,offset TEMPFILEDATA
	MOV al,'P'
	MOV cx,'A'*256+'S'
	CALL near ptr PARSENAME

	POP dx			; DE = start of filename

;	 CALL L2D2A		 ; parse filename at DE with no wildcards and
;				 ; a default extension of '.PAS'

	PUSH bx			; save current compiler source text pointer
	XCHG dx,bx

         CALL near ptr GONEXTFILELEVEL

	POP si			; IX = new compiler source text pointer

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

	CALL near ptr L718F		; print current line number

	MOV al,byte ptr L7B9D		; compiler directives
	MOV byte ptr L7B9F,al		; save them
	MOV al,byte ptr WITHDEPTH
	MOV byte ptr L7BC8,al		; save ?
	JMP near ptr  L7048

L7124:   ; -----------------------------------------------------------
	; ReadLine
	; -----------------------------------------------------------

	; read next character from input buffer
	MOV al,byte ptr [si+0]
	INC si
	OR al, al			; begins with a zero?
	RETNZ 			; no, buffer is not empty,
				; quit with character

	; read a new line from the input buffer
	PUSH cx
	PUSH dx
	PUSH bx

	MOV al,byte ptr L7BA2
	OR al, al			; end of file found ?

	CALL near ptr L72DA		; NonZero --> error
	DB 5BH			; error 91: Unexpected end of source

;	 LD HL,(L7BD7)		 ; current text pointer
;	 LD (L7BD9),HL		 ; save start of line of text in memory

;	 LD HL,(L7BEB)		 ; HL = character position in include file
;	 LD (L7BED),HL		 ; save start of line in include file

	MOV bx,offset L79D7
	PUSH bx
	POP si			; set IX at start of text line buffer again

	MOV ch,07FH		; maximum number of characters is 127
L714A:	PUSH bx
	PUSH cx
	CALL near ptr L71F3		; read character from input
	POP cx
	POP bx
	CMP al, 0DH			; carriage return?
	JZ near ptr L7175
	CMP al, 1AH			; end of text?
	JZ near ptr L716A
	CMP al, 9			; TAB?, exception on characters < 20H
	JZ near ptr L7161
	CMP al, ' '                     ; < 20H, < space
	JC near ptr L714A		; yes, read next character
L7161:	DEC ch
	JNZ near ptr L7166

	; skip rest of line until return, end of text, tab or space
	INC ch
	JMP near ptr  L714A

L7166:	MOV byte ptr [bx],al		; store character in buffer
	INC bx
	JMP near ptr  L714A 		; next character

L716A:	MOV byte ptr L7BA2,al		; set to non-zero, end of file found = true

	CALL near ptr L717E		; increase and print line number
	CALL near ptr L718F		; print line number
	JMP near ptr  L7178

L7175:	CALL near ptr L717E		; increase and print line number

L7178:	MOV byte ptr [bx],0
	POP bx
	POP dx
	POP cx
	RET

L717E:	; increases and prints the current line number each time
	; line number and 3fh = 0
	; and gives an 'abort compilation' message if a key is pressed
	; in:	-
	; out:	-
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH bx

	MOV bx,word ptr FILEBUFFERLINE
	INC bx
	MOV word ptr FILEBUFFERLINE,bx

	MOV bx,word ptr TOTALLINES
	INC bx
	MOV word ptr TOTALLINES,bx

	MOV al,bl
	AND al, 3FH			; line number mod 64 = 0?
	JZ near ptr L7191		; yes, print this number and skip PUSH AF,HL
	POP bx
	POP ax
	xchg ah,al
	sahf
	RET

PRINTFILENAME:
         ; in:    DE = handle/FCB block

	INC dx
	XCHG dx,bx

PRINTASCIIZUPCASED:
	MOV al,byte ptr [bx]
	OR al, al
	RETZ 
	CALL near ptr UPCASE
	CALL near ptr L03C9
	INC bx
	JMP near ptr  PRINTASCIIZUPCASED

PRINTASCIIZ:
	MOV al,byte ptr [bx]
	OR al, al
	RETZ 
	CALL near ptr L03C9
	INC bx
	JMP near ptr  PRINTASCIIZ

L718F:	; prints current line number and tests keypressing during compilation
	; changes: -
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH bx

L7191:	PUSH cx
	PUSH dx
	PUSH si
	PUSH di

IFDEF MSX
;	 LD HL,(0FC9EH)
;	 PUSH HL
ENDIF	; MSX

	MOV al,13
	CALL near ptr L03C9		; print carriage return

;	 LD A,(L7BE3)
;	 CALL L04B4		 ; print update count
;
;	 LD A,' '
;	 CALL L03C9

	MOV bx,word ptr L7B73
	MOV dx,word ptr COMPCUR
	OR al, al
	SBB bx,dx
	CALL near ptr L2E5C		; print free memory in compiler
				; print in decimals, always 5 characters

;	 LD HL,(COMPCUR)		 ; current compiler address
;	 CALL L04AF		 ; print HL hexadecimal
;	 LD A,'-'
;	 CALL L03C9		 ; print '-'
;	 LD HL,(L7B73)		 ; bottom of variable table
;	 CALL L04AF

	MOV al,' '
	CALL near ptr L03C9
	CALL near ptr L03C9

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

	MOV bx,word ptr TOTALLINES
	CALL near ptr L2E5C		; print total compiled pascal lines

	MOV al,' '
	CALL near ptr L03C9

	MOV bx,word ptr FILEBUFFERLINE
	CALL near ptr L2E5C		; print current line number in file

	MOV al,' '
	CALL near ptr L03C9
	CALL near ptr L03C9

	MOV al,byte ptr FILELEVEL
	ADD al,'0'
	CMP al, '0'
	JNZ near ptr L7192		; jump to print include level

	MOV al,' '

L7192:	CALL near ptr L03C9		; print include level or space

	MOV al,' '
	CALL near ptr L03C9		; space between level and filename

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

	MOV dx,offset FILECURRENTINFO
         CALL near ptr PRINTFILENAME

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

	MOV al,27
	CALL near ptr L03C9
	MOV al,'K'
	CALL near ptr L03C9		; print ESC K, delete until end of line

;	 LD B,8
;L71A81:  LD A,' '
;	 CALL L03C9
;	 DJNZ L71A81

	CALL near ptr CONSTPTR		; keypressed ?
	OR al, al
	JZ near ptr L71EA
	CALL near ptr L0200
	DB '   *** Abort compilation',0
	CALL near ptr L2D01		; print ' (Y/N)? '

	CALL near ptr L72DA		; NonZero --> error
	DB 0CAH			; staat niet in Herman's boek(je)

	MOV ch,20H
L71E1:	CALL near ptr L0200
	DB 8,' ',8,0               ; backspace, space, backspace
	DEC ch
	JNZ near ptr L71E1

L71EA:

IFDEF MSX
;	 POP HL
;	 LD (0FC9EH),HL
ENDIF	; MSX

	POP di
	POP si
	POP dx
L71EF:	POP cx
	POP bx
	POP ax
	xchg ah,al
	sahf
	RET

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

	MOV bx,word ptr FILEBUFFERPOS
	MOV al,byte ptr [bx]
;	 CALL L03C9
	INC bx
	MOV word ptr FILEBUFFERPOS,bx

	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

	MOV bx,word ptr FILEBUFFERCOUNT
	DEC bx
	MOV al,bh
	OR al, bl
	CALLZ FILEREADBUFFER	; read new buffer if count = 0
	MOV word ptr FILEBUFFERCOUNT,bx

	POP ax
	xchg ah,al
	sahf

	CMP al, 1AH			; end of file marker (^Z) ?
	RETNZ 			; quit if it was not end of file
; 33e

         MOV cx,offset FILECURRENTINFO      ; 33e TODO, 568A
         CALL near ptr CLOSEFILE
         CALL near ptr L72DA
         DB 85H

; 33e
	MOV al,byte ptr FILELEVEL
	OR al, al			; previous level = include file ?
	MOV al,1AH
	RETZ 			; return with end of file if end of all

	CALL near ptr GOPREVIOUSFILELEVEL

	CALL near ptr L718F		; update display status

	JMP near ptr  L71F3 		; read next character from this level

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
	CMP al, 'A'
	RETC 
	CMP al, 'Z'+1
	CMC
	RETNC 
	CMP al, '_'
	RETZ 
	CMP al, 'a'
	RETC 
	CMP al, 'z'+1
	CMC
	RET

L7282:	; in:	A = testing character
	; out:	Carry Flag Reset if see condition at L7271 and if
	;	A in ['0'..'9']
	;	Carry Flag Set if not an letter, underscore or decimal
	CALL near ptr L7271		; letter or underscore
	RETNC 

L7286:	; in:	A = testing character
	; out:	Carry Flag Reset if A in ['0'..'9']
	;	Carry Flag Set otherwise
	CMP al, '0'                     ; < '0' ?
	RETC 
	CMP al, '9'+1                   ; > '9' ?
	CMC
	RET

L728D:	; checks if the lower bound <= upper bound
	; in:	HL = <n>, upper bound
	;	DE = <m>, lower bound
	; out:	Carry = 1, if HL < DE
	MOV al,bh
	XOR al, dh

	MOV al,bh
	JS near ptr L7298		; jump if one bound is negative
	CMP al, dh
	RETNZ 
	MOV al,bl
	CMP al, dl
	RET

L7298:	RCL al,1			; return Carry = 1, if upper bound < 0
	RET

L729A:	; in:	HL, DE
	; out:	HL = HL * DE
	MOV ch,bh
	MOV cl,bl
	MOV bx,0			; sum = 0
	MOV al,16

L72A1:	ADD bx,bx
	RETC 			; quit if overflow

	XCHG dx,bx
	ADD bx,bx
	XCHG dx,bx
	JNC near ptr L72AA

	ADD bx,cx
	RETC 
L72AA:	DEC al
	JNZ near ptr L72A1
	RET

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

L72C8:	mov bp,sp
	XCHG [bp],bx		; error if carry set
	INC bx
	mov bp,sp
	XCHG [bp],bx
	RETNC 
	JMP near ptr  L72DE

L72CE:	mov bp,sp
	XCHG [bp],bx		; error if carry reset ; unused ???
	INC bx
	mov bp,sp
	XCHG [bp],bx
	RETC 
	JMP near ptr  L72DE

L72D4:	mov bp,sp
	XCHG [bp],bx		; error if zero flag set
	pushf
	INC bx
	popf
	mov bp,sp
	XCHG [bp],bx
	RETNZ 
	JMP near ptr  L72DE

L72DA:	mov bp,sp
	XCHG [bp],bx		; error if zero flag reset
	pushf
	INC bx
	popf
	mov bp,sp
	XCHG [bp],bx
	RETZ 
L72DE:	POP bx
	DEC bx
	PUSH bx

L72E1:	POP bx
	MOV al,byte ptr [bx]		; A = error code

L72E3:	CALL near ptr L718F		; make update of current line

	MOV byte ptr L7901,al		; save error code
	OR al, al
	JZ near ptr L730C

	PUSH si
	POP bx
	MOV dx,offset L79D7		; DE = start of line buffer
	; NonCarry
	SBB bx,dx		; HL = zero-based column

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

L730C:	MOV al,byte ptr L7900
	DEC al
	JNZ near ptr L731A		; jump if searching

         MOV cx,offset CODEFILE
         CALL near ptr CLOSEFILE

;         LD DE,L7933
;         LD C,010H
;         CALL DOSIXIY               ; close

L731A:	MOV sp,word ptr L7B71
	RET

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
	ADD al,al

	ADD al,bl
	JNC near ptr TABLEINDEX2_1
	INC bh
TABLEINDEX2_1:
	MOV bl,al

	MOV al,byte ptr [bx]
	INC bx
	MOV bh,byte ptr [bx]
	MOV bl,al
	RET

COMPAREHL_DE:
	; compares HL with DE, by subtraction HL - DE
	; in:	HL, DE
	; out:	Carry, if HL < DE
	;	Zero, if HL == DE
	;	Zero and NonCarry, if HL >= DE
	; changes: AF
	MOV al,bh
	SUB al, dh
	RETNZ 
	MOV al,bl
	SUB al, dl
	RET

MINIMUMHL_DE:
	; in:	HL, DE
	; out:	HL = minimum value, DE = maximum value
	CALL near ptr COMPAREHL_DE
	RETC 			; quit if HL = minimum (HL < DE)

	XCHG dx,bx 		; swap values
	RET

FILEINFOENTRYADDRESS:
	; in:	A = include level, 0 .. FileLevels - 1
	; out:	HL = address of info within FileInfo table
	MOV dx,offset FILEINFOENTRYSIZE

	MOV bx,offset FILEINFO

FILEINFOENTRYADDRESS1:
	OR al, al
	RETZ 
	DEC al
	ADD bx,dx
	JMP near ptr  FILEINFOENTRYADDRESS1

GONEXTFILELEVEL:
	; in:	HL = address of filename of text file

	; push default extension 'INC'
	MOV al,'I'
	MOV cx,'N'*256+'C'
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx

	PUSH bx

	MOV bx,word ptr FILEBUFFERCOUNT
	MOV dx,offset FILELEVELMINIMUM
	OR al, al
	SBB bx,dx		; HL = number of lost bytes
	JZ near ptr GONEXTFILELEVELNOLOSS ; jump if Count = 0
	JC near ptr GONEXTFILELEVELNOLOSS ; jump if Count < 1024

	MOV ch,bh			; BC = number of lost bytes
	MOV cl,bl

	PUSH cx
	MOV cx,offset FILECURRENTINFO
	CALL near ptr FILEPOS
	POP cx

	OR al, al
	SBB bx,cx		; subtract loss from low-word
	JNC near ptr GONEXTFILELEVEL0

	DEC dx			; decrease high-word

GONEXTFILELEVEL0:
	MOV cx,offset FILECURRENTINFO
	CALL near ptr FILESEEK		; set file position back with the number
				; of lost bytes

	CALL near ptr L72DA		; NonZero --> error
	DB 84H			; error 132: error seeking file

GONEXTFILELEVELNOLOSS:

	MOV bx,word ptr FILEBUFFERCOUNT
	MOV dx,offset FILELEVELMINIMUM	; 1024 = minimum size used by a file
	CALL near ptr MINIMUMHL_DE
	; LD (FileBufferSize),HL	  ; set new size
	MOV word ptr FILEBUFFERCOUNT,bx	; set new count

	MOV ch,bh			; BC = HL = count
	MOV cl,bl
	MOV bx,word ptr FILEBUFFERPOS
	MOV dx,word ptr FILEBUFFERSTART
	PUSH dx

	CALL __LDIR			; move to start of buffer

	POP bx
	MOV word ptr FILEBUFFERPOS,bx	; buffer pos = buffer start

	PUSH dx			; save buffer start for next level

	MOV al,byte ptr FILELEVEL
	CALL near ptr FILEINFOENTRYADDRESS
	XCHG dx,bx 		; DE = address where to save current info
	MOV bx,offset FILEINFOENTRYSTART
	MOV cx,offset FILEINFOENTRYSIZE
	CALL __LDIR			; save current entry in table

	MOV bx,offset FILELEVEL
	INC byte ptr [bx] 		; go to next include level

GONEXTFILELEVEL1:
	POP bx
	MOV word ptr FILEBUFFERSTART,bx	; set new buffer start
	MOV word ptr FILEBUFFERPOS,bx	; set new buffer pos

	XCHG dx,bx
	MOV bx,offset FILEBUFFEREND
	OR al, al
	SBB bx,dx		; HL = size for new buffer
	MOV word ptr FILEBUFFERSIZE,bx

	MOV dx,offset FILECURRENTINFO

	POP bx			; DE = address of filename to parse

	POP cx
	POP ax
	xchg ah,al
	sahf
	CALL near ptr OPENFILE

	CALL near ptr L72DA		; NonZero --> error
	DB 5AH			; error 90: File not found

	MOV bx,0
	MOV word ptr FILEBUFFERLINE,bx	; start at line 0

	CALL near ptr FILEREADBUFFER

	MOV al,bh
	OR al, bl
	RETNZ 			; quit if some bytes read

GOPREVIOUSFILELEVEL:
; 33e    LD BC,FileCurrentInfo
; 33e    CALL CloseFile             ; close the current file

; 33e    CALL L72DA                 ; NonZero --> error
; 33e    DB 85H                     ; error 133: error closing file

	MOV bx,offset FILELEVEL
	DEC byte ptr [bx] 		; decrease level
	MOV al,byte ptr [bx]
	CALL near ptr FILEINFOENTRYADDRESS
	MOV dx,offset FILEINFOENTRYSTART
	MOV cx,offset FILEINFOENTRYSIZE
	CALL __LDIR			; restore to previous level
	RET

FILEREADBUFFER:
	; in:	-
	; out:	HL = bytes read from file

	MOV bx,word ptr FILEBUFFERSIZE
	MOV dx,word ptr FILEBUFFERSTART
	MOV word ptr FILEBUFFERPOS,dx
	MOV cx,offset FILECURRENTINFO	; handle/FCB address
         CALL near ptr READFILE
	MOV word ptr FILEBUFFERCOUNT,bx

	CALL near ptr L72DA		; NonZero --> error
	DB 83H			; error 131: error reading file

	MOV al,bh
	OR al, bl
	RETNZ 			; quit if something was read

	MOV bx,word ptr FILEBUFFERSTART
	MOV byte ptr [bx],1AH		; place end of file marker (^Z)
	MOV bx,1
	MOV word ptr FILEBUFFERCOUNT,bx	; count = 1

	RET

FILEINIT:
	; in:	HL = address of filename of text file

	; push default extension 'PAS'
	MOV al,'P'
	MOV cx,'A'*256+'S'
	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	PUSH cx

	PUSH bx
	XOR al, al
	MOV byte ptr FILELEVEL,al
	MOV bx,offset FILEBUFFER
	PUSH bx
	JMP near ptr  GONEXTFILELEVEL1

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