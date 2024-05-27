;         .Z80

IFNDEF MAKEPC
MSX:
ENDIF

IFDEF MSX
MSXDOS   EQU 5
ENDIF

FASTWRITE:
         DB 0

         INCLUDE STDIO.INC

         INCLUDE LIBDEFS.INC

         INCLUDE LIBCONST.INC

         ; defined in compiler.mac
         EXTRN L5271,L5287,L5639,L58C5,L5960,L59E9,L5A0C,L5A17,L5CAD
         EXTRN L5D76,L5E8E,L5E97,L5EA2,L5EBB,L5EBE,L5ED0,L5EDD,L5EE8

         EXTRN L6148,L6201,L620F,L6540,L65D5,L65DE,L65E7,L65EF,L65F7,L677F
         EXTRN PARSE_O_IL_C
         EXTRN PARSELONG
         EXTRN L678B,L6A5C
         EXTRN L6B5E                ; output length (C) and data at L7A57
         EXTRN L6CC2,L6D24,L6D43,L6E54
         EXTRN L6F0B,L6F13,L6F1B,L6F5E,L6F66,L6F6E,L6F7E
         EXTRN L72D4,L72DA
         EXTRN L7B5E,L7B6F,L7B8B,L7B9E,L7BA3,L7BA7

;         PUBLIC L5ABE
         PUBLIC L7638,L77B1

L59FA:   DW _L1811                  ; LIB, reset typed file
         DW _L13FF                  ; LIB, reset text file
         DW _L1A70                  ; LIB, reset untyped file

L5A00:   DW _L1810                  ; LIB, rewrite typed file
         DW _L13FE                  ; LIB, rewrite text file
         DW _L1A6F                  ; LIB, rewrite untyped file

L5A06:   DW _L187A                  ; LIB, close typed file
         DW _L1469                  ; LIB, close text file
         DW _L1AB0                  ; LIB, close untyped file

L5943:	; PROCEDURE Assign(VAR F: FILE; Name: STRING);
         CALL near ptr L5A0C                 ; parse '(' and file parameter
         MOV bx,offset _L1370               ; LIB, assume file type = untyped or typed
	CMP al, 6
	JNZ near ptr L5955		; jump if not text file

	MOV bx,offset _L136F		; LIB, file type = text
	CALL near ptr L5955
         JMP near ptr  L5ABE                   ; add call for I/O checking, if on

L5955:	PUSH bx
	CALL near ptr O_PSHHL		; push for first parameter, FIB address
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5ED0                 ; parse string expression
	POP bx
         JMP near ptr  L5960                   ; match(')', CALL HL

L5966:   ; PROCEDURE Rename(VAR F: FILE; Name: STRING);
         CALL near ptr L5A0C                 ; parse '(' and file parameter
	MOV bx,offset _L1BA5		; LIB, rename
	CALL near ptr L5955
         JMP near ptr  L5ABE                   ; add call for I/O checking, if on

P_RENAMEFILE:
         ; PROCEDURE RenameFile(OldName: STRING; NewName: STRING);
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5ED0                 ; parse string expression
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5ED0                 ; parse string expression
         MOV bx,offset _RENAMEFILE_LIB
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5971:	; PROCEDURE Erase(VAR F: FILE);
         CALL near ptr L5A0C                 ; parse '(' and file parameter
	MOV bx,offset _L1B93		; LIB
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5979:	; PROCEDURE Chain(VAR F: FILE);
         MOV bx,offset _L1BEB               ; LIB
         JMP near ptr  L5981

L597E:	; PROCEDURE Execute(VAR F: FILE);
         MOV bx,offset _L1BEA               ; LIB
L5981:	PUSH bx
         CALL near ptr L5A0C                 ; parse '(' and file parameter

L5985:   POP bx
L5986:   CALL near ptr L5960                 ; match(')'), CALL HL

         JMP near ptr  L5ABE                   ; add call for I/O checking, if on

L598C:	; PROCEDURE Seek(VAR F: FILE OF TYPE; Pos: INTEGER);
         ; PROCEDURE Seek(VAR F: FILE; Pos: INTEGER);
         CALL near ptr L5A0C                 ; parse '(' and file parameter
	CMP al, 6

	CALL near ptr L72D4		; Zero --> error
         DB 3FH                     ; error 63: Textfiles are not allowed here

         MOV bx,offset _L19D5               ; LIB, seek typed
	CMP al, 5
         JZ near ptr L599F                 ; jump if typed

         MOV bx,offset _L1B6F               ; LIB, seek untyped
L599F:	PUSH bx
	CALL near ptr O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
;         CALL L5E97                 ; parse integer expression
         CALL near ptr PARSELONG             ; parse integer/long expression
	JMP near ptr  L5985

L59AB:   ; PROCEDURE Flush(VAR F: FILE OF TYPE);
         CALL near ptr L5A0C                 ; parse '(' and file parameter
	CMP al, 5

	CALL near ptr L72DA		; NonZero --> error
	DB 40H			; error 64: Textfiles and untyped files
				;	    are not allowed here

         MOV bx,offset _L19A5               ; LIB, flush typed file
	JMP near ptr  L5986

L59B9:	; PROCEDURE Reset(VAR F: FILE);
         MOV bx,offset L59FA
	JMP near ptr  L59C1

L59BE:	; PROCEDURE Rewrite(VAR F: FILE);
	MOV bx,offset L5A00
L59C1:	PUSH bx
         CALL near ptr L5A0C                 ; parse '(' and file parameter
         MOV al,byte ptr L7B5C               ; 33e, 54C8
         CMP al, 7
         JZ near ptr L78CD
         CMP al, 5                       ; jump if not a typed file
         JNZ near ptr L59D8

         ; typed file
         MOV bx,word ptr L7B5E
	CALL near ptr L5271

	MOV bx,word ptr L7B6F
	CALL near ptr O_LDDE

L59D8:	POP bx
	JMP near ptr  L59E1

; 33e
L78CD:
         CALL near ptr O_PSHHL               ; L427D
         CALL near ptr L6F13                 ; match(','), if present
         JNZ near ptr L78E3                ; jump if no size given

         MOV al,byte ptr L7B5C
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L5E97                 ; parse integer expression
         POP ax
	xchg ah,al
	sahf
         MOV byte ptr L7B5C,al
         POP bx
         JMP near ptr  L59E1

L78E3:
         MOV bx,0080H                ; default block size
         CALL near ptr O_LDHL
         POP bx
         JMP near ptr  L59E1
; 33e

L59DB:	; PROCEDURE Close(VAR F: FILE);
         CALL near ptr L5A0C                 ; parse '(' and file parameter

         MOV bx,offset L5A06                ; HL = address of table for closing types
L59E1:   CALL near ptr L6F6E                 ; match(')')

         CALL near ptr L59E9                 ; generate call for file I/O
         JMP near ptr  L5ABE                   ; add call for I/O checking, if on


L5A32:   ; PROCEDURE Readln(VAR F: TEXT);
	MOV al,0AFH		; NZ = 'LN' after read
         JMP near ptr  L5A34

L5A33:	; PROCEDURE Read(VAR F: FILE OF TYPE; VAR F: TYPE);
	; PROCEDURE Read(VAR F: TEXT; VAR I: INTEGER);
         ; PROCEDURE Read(VAR F: TEXT; VAR L: LONGINT);
	; PROCEDURE Read(VAR F: TEXT; VAR R: REAL);
	; PROCEDURE Read(VAR F: TEXT; VAR C: CHAR);
	; PROCEDURE Read(VAR F: TEXT; VAR S: STRING);
	XOR al, al
L5A34:   MOV byte ptr L7BA3,al               ; 0 = no 'LN' after read
	CALL near ptr L6F1B		; match('('), if present
	JZ near ptr L5A41		; jump if '(' matched

	; PROCEDURE Read;
	CALL near ptr L5ACA
	JMP near ptr  L5AB4

L5A41:   CALL near ptr L5A17                 ; parse file parameter
	JC near ptr L5A63
	JNZ near ptr L5A5B

         CMP al, 5                       ; typed file ?
	JZ near ptr L5BD8		; jump if typed file

         CMP al, 6                       ; no typed file and no text file ?

	CALL near ptr L72DA		; NonZero --> error
	DB 41H			; error 65: Untyped files are not allowed here

	; read from text file
	MOV bx,offset _L14A9		; LIB
	CALL near ptr O_CALHL
	JMP near ptr  L5AAC

L5A5B:	CALL near ptr L678B
	CALL near ptr L5ACA
	JMP near ptr  L5A69

L5A63:	CALL near ptr L5ACA
L5A66:   CALL near ptr L677F                 ; parse var parameter

L5A69:	MOV al,byte ptr L7B5C
	CMP al, 8
         JC near ptr L5A78                 ; no STRING, REAL, INTEGER, BOOLEAN,
                                    ; CHAR or LONGINT

         CMP al, 0BH                     ; type = BOOLEAN ?
         JZ near ptr L5A78                 ; jump for error 66

         CMP al, 0EH+1
	JC near ptr L5A7C

L5A78:	CALL near ptr L72E1		; no condition
	DB 42H			; error 66: I/O are not allowed

L5A7C:	CMP al, 8
	JNZ near ptr L5A8F

         ; printed type = STRING
         MOV al,byte ptr L7B62
	DEC al
	MOV bh,al
	MOV bl,6
	CALL near ptr O_HL

         MOV al,8
         JMP near ptr  L5A90

L5A8F:
         CMP al, 0AH
         JNZ near ptr L5A90                ; jump if not INTEGER

         MOV al,byte ptr L7B62
         DEC al

         MOV al,0AH                   ; assume INTEGER
         JNZ near ptr L5A90

         MOV al,0DH                   ; no, BYTE type

L5A90:
         MOV bx,offset READTYPESTABLE - 8*2
         CALL near ptr TABLEINDEX2

         CALL near ptr O_CALHL

L5AAC:   CALL near ptr L6F13                 ; match(','), if present
	JZ near ptr L5A66		; jump if ',' matched

	CALL near ptr L6F6E		; match(')')

L5AB4:   MOV bx,offset _L16AB               ; LIB, 'LN' after Read

L5AB7:   MOV al,byte ptr L7BA3               ; 0 = no 'LN' after read/write
	OR al, al
	CALLNZ O_CALHL		; call if LN is needed

L5ABE:   MOV al,byte ptr L7B9E               ; compiler directives
	TEST al,1			; 1 = I/O Error Handling on
	RETZ 			; return if off
	MOV bx,offset _L201B		; LIB, I/O Error function
	JMP near ptr  O_CALHL

READTYPESTABLE:
         DW _L168E                  ; 08, read STRING
         DW _L1672                  ; 09, read REAL
         DW _L164E                  ; 0A, read INTEGER
         DW 0                       ; 0B
         DW _L1644                  ; 0C, read CHAR
         DW _L164D                  ; 0D, read BYTE
         DW _L1671                  ; 0E, read LONGINT

L5ACA:   MOV bx,offset _L149B               ; LIB, assume normal output
	MOV al,byte ptr L7B9E		; compiler directives
	TEST al,64			; 1 = I/O Mode selection on
	JZ near ptr L5AE4		; jump if off

         MOV bx,offset _L14CC               ; LIB, read from console

         MOV al,byte ptr L7BA3
	OR al, al
	JZ near ptr L5AE4

         MOV bx,offset _L14CB               ; LIB, readln from console
	XOR al, al
	MOV byte ptr L7BA3,al
L5AE4:	JMP near ptr  O_CALHL

L5AE7:   ; FastWriteln
         MOV al,1
         JMP near ptr  L5AE72

L5AE71:  ; normal Writeln
         XOR al, al

L5AE72:  MOV byte ptr FASTWRITE,al

         ; PROCEDURE Writeln(VAR F: TEXT);
         MOV al,0AFH                  ; NZ = 'LN' after write
	JMP near ptr  L5AE9

L5AE8:   ; FastWrite
         MOV al,1
         JMP near ptr  L5AE82

L5AE81:  ; normal Write
         XOR al, al

L5AE82:  MOV byte ptr FASTWRITE,al
         ; PROCEDURE Write(VAR F: FILE OF TYPE; VAR V: TYPE);
	; PROCEDURE Write(VAR F: TEXT; I: INTEGER);
         ; PROCEDURE Write(VAR F: TEXT; L: LONGINT);
         ; PROCEDURE Write(VAR F: TEXT; R: REAL);
	; PROCEDURE Write(VAR F: TEXT; B: BOOLEAN);
	; PROCEDURE Write(VAR F: TEXT; C: CHAR);
	; PROCEDURE Write(VAR F: TEXT; S: STRING);
	XOR al, al

L5AE9:   MOV byte ptr L7BA3,al               ; 0 = no 'LN' after write

         CALL near ptr L6F1B                 ; match('('), if present
         JZ near ptr L5AFA                 ; jump if '(' matched

	MOV bx,offset _L149B		; LIB
         CALL near ptr O_CALHL               ; set FIB address at standard output

         JMP near ptr  L5BD2                   ; output CALL for CR, LF codes

L5AFA:   ; '(' parsed
         CALL near ptr L5A17                 ; parse file parameter
         JC near ptr L5B20                 ; jump if no file variable present
                                    ; output CALL for standard output
         JNZ near ptr L5B15

         CMP al, 5                       ; typed file ?
         JZ near ptr L5BDD                 ; jump if typed file

         CMP al, 6                       ; text file

	CALL near ptr L72DA		; NonZero --> error
	DB 41H			; error 65: Untyped files are not allowed here

	MOV bx,offset _L14BA		; LIB
	CALL near ptr O_CALHL

	JMP near ptr  L5BC9

L5B15:   CALL near ptr L620F

         MOV bx,offset _L149B               ; LIB
         CALL near ptr O_CALHL               ; set FIB address at standard output
	JMP near ptr  L5B4F

L5B20:   MOV bx,offset _L149B               ; LIB
         CALL near ptr O_CALHL               ; set FIB address at standard output

L5B26:   MOV al,0FFH
         MOV byte ptr DEF_TYPE,al            ; default type = SMART
         MOV dl,0                     ; no sign
         CALL near ptr L6A5C                 ; parse unsigned-constant
         JNZ near ptr L5B4C                ; jump if no constant parsed

         MOV al,ch
	CMP al, 8
	JNZ near ptr L5B47
	MOV al,byte ptr [si+0]
         CMP al, ','
	JZ near ptr L5B3B
         CMP al, ')'
	JNZ near ptr L5B47

L5B3B:	MOV bx,offset _L17BA		; LIB
	CALL near ptr O_CALHL
         CALL near ptr L6B5E                 ; output length (C) and data at L7A57
	JMP near ptr  L5BC9

L5B47:   CALL near ptr L6201
	JMP near ptr  L5B4F

L5B4C:
         MOV al,0FFH                  ; default type = smart
         CALL near ptr L5EE8                 ; parse expression

L5B4F:   MOV al,ch
;         CP 0EH                     ; type = LONGINT ?
;         JR Z,L5B5C

         CMP al, 8
	JC near ptr L5B58

         CMP al, 0EH+1
	JC near ptr L5B5C

L5B58:	CALL near ptr L72E1		; no condition
	DB 42H			; error 66: I/O are not allowed

L5B5C:   CMP al, 0CH                     ; type = CHAR ?
         JNZ near ptr L5B6A                ; jump if not

         ; type = CHAR
         CALL near ptr L6F0B                 ; match(':'), if present
	JNZ near ptr L5BA6		; jump if ':' not matched

         CALL near ptr L5EDD                 ; code to push CHAR as STRING
	JMP near ptr  L5B72

L5B6A:   CALL near ptr L6148                 ; generate code to push REAL, INTEGER,
                                    ; BOOLEAN, CHAR, POINTER or LONGINT
                                    ; on the stack
	CALL near ptr L6F0B		; match(':'), if present
	JNZ near ptr L5B8B		; jump if ':' not matched

L5B72:   ; ':' parsed, size number expected
         PUSH cx                    ; save type of expression before ':'

         CALL near ptr L5E97                 ; parse integer expression

         POP cx
	MOV al,ch
         CMP al, 9                       ; type REAL ?
         JNZ near ptr L5BA6                ; jump if not

         ; type = REAL
         ; second ':', number of digits after '.'
         CALL near ptr L6F0B                 ; match(':'), if present
	JNZ near ptr L5B9D		; jump if ':' not matched

         ; second ':' parsed
         PUSH cx
         CALL near ptr O_PSHHL               ; code: push size on stack

         CALL near ptr L5E97                 ; parse integer expression

         POP cx
	JMP near ptr  L5BA6

L5B8B:   ; <expression>
         MOV bx,0000
	MOV al,ch
	CMP al, 9
	JNZ near ptr L5B95

         ; type = REAL
         MOV bl,12H                   ; default for first ':'

L5B95:   CALL near ptr O_LDHL
	MOV al,ch
	CMP al, 9
	JNZ near ptr L5BA6

L5B9D:   ; type = REAL
         CALL near ptr O_PSHHL
	MOV bx,-1
	CALL near ptr O_LDHL

L5BA6:	MOV al,ch
         MOV bx,offset WRITETYPESTABLE - 8*2
         CALL near ptr TABLEINDEX2

         CALL near ptr O_CALHL

L5BC9:   CALL near ptr L6F13                 ; match(','), if present
	JZ near ptr L5B26		; jump if ',' matched
	CALL near ptr L6F6E		; match(')')

L5BD2:   MOV bx,offset _L17CD               ; LIB, print CR LF codes
         JMP near ptr  L5AB7

WRITETYPESTABLE:
         DW _L17AA                  ; 08, write STRING
         DW _L1779                  ; 09, write REAL
         DW _L1726                  ; 0A, write INTEGER
         DW _L178B                  ; 0B, write BOOLEAN
         DW _L1722                  ; 0C, write CHAR
         DW 0                       ; 0D, write .., reserved for BYTE
         DW _PRT_LONG               ; 0E, write LONGINT

L5BD8:   MOV bx,offset _L18B6               ; LIB, read from typed file
	JMP near ptr  L5BE0

L5BDD:   MOV bx,offset _L18DC               ; LIB, write to typed file

L5BE0:   MOV word ptr L7BA7,bx
	MOV al,byte ptr L7BA3
	OR al, al

	CALL near ptr L72DA		; NonZero --> error
	DB 23H			; error 35: Textfile expected

         MOV bx,offset _L18A4               ; LIB, save FIB address and check
                                    ; if the file is open
	CALL near ptr O_CALHL

         MOV bx,word ptr L7B5E
	CALL near ptr L5271

L5BF7:	CALL near ptr L6F13		; match(','), if present
	JNZ near ptr L5C10		; jump if ',' not matched

	CALL near ptr L6D24		; push 13, L7B64
         CALL near ptr L677F                 ; parse var parameter
	CALL near ptr L6D43		; pop 13, L7B64

         CALL near ptr L58C5                 ; perform type checking
	MOV bx,word ptr L7BA7
	CALL near ptr O_CALHL
	JMP near ptr  L5BF7

L5C10:	CALL near ptr L6F6E		; match(')')
	JMP near ptr  L5ABE

L5C16:   ; PROCEDURE BlockRead(VAR F: FILE; VAR Dest: Type;
         ;                     Num: INTEGER [; VAR Result: INTEGER]);
         MOV bx,offset _L1AF1               ; LIB, with result
         MOV dx,offset _L1ABE               ; LIB, without result
	JMP near ptr  L5C24

L5C1E:   ; PROCEDURE BlockWrite(VAR F: FILE; VAR Dest: Type;
         ;                      Num: INTEGER [; VAR Result: INTEGER]);
         MOV bx,offset _L1AED               ; LIB, with result
         MOV dx,offset _L1ABA               ; LIB, without result

L5C24:	PUSH bx
	PUSH dx
         CALL near ptr L5A0C                 ; parse '(' and file parameter
	CMP al, 7			; untyped file ?

	CALL near ptr L72DA		; NonZero --> error
	DB 25H			; error 37: Untyped file expected

         CALL near ptr O_PSHHL               ; push address FIB
         CALL near ptr L6F5E                 ; match(',')

         CALL near ptr L677F                 ; parse VAR parameter
         CALL near ptr O_PSHHL               ; push address of untyped variable
         CALL near ptr L6F5E                 ; match(',')

         CALL near ptr L5E97                 ; parse integer expression
	CALL near ptr L6F13		; match(','), if present

	POP dx
	POP bx
         JZ near ptr L5C4B                 ; jump if ',' matched = 'result' parameter

         PUSH dx                    ; address LIB routine without result
	JMP near ptr  L5C63

L5C4B:   PUSH bx                    ; address LIB routine with result

         CALL near ptr O_PSHHL               ; push Num parameter on stack

;         CALL ParseIntVar           ; parse VAR integer parameter
         CALL near ptr L677F                 ; parse VAR parameter

         MOV al,byte ptr L7B5C
         CMP al, 0AH                     ; type = integer ?
         JNZ near ptr L5C5F                ; jump if not integer

         MOV al,byte ptr L7B62               ; A = sizeof var parameter (BYTE/INTEGER)
         DEC al
         JNZ near ptr L5C63                ; jump if size = 2 --> real INTEGER

L5C5F:   CALL near ptr L72E1                 ; no condition
         DB 18H                     ; error 24: Integer variable expected

L5C63:
         JMP near ptr  L5985

L5C66:   ; PROCEDURE Delete(VAR S: STRING; Pos, Len: INTEGER);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5CAD                 ; parse VAR string variable
	CALL near ptr O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
	CALL near ptr O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
	MOV bx,offset _L08F3		; LIB
L5C81:   CALL near ptr L6F6E                 ; match(')')
	JMP near ptr  O_CALHL

L5C87:	; PROCEDURE Insert(S: STRING; VAR D: STRING; Pos: INTEGER);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5ED0                 ; parse string expression
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5CAD                 ; parse VAR string variable
	CALL near ptr O_PSHHL
	MOV al,byte ptr L7B62
	DEC al
	MOV bh,al
	MOV bl,6
	PUSH bx
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
	POP bx
	CALL near ptr O_HL
	MOV bx,offset _L0920		; LIB
	JMP near ptr  L5C81

L5CBA:   ; PROCEDURE Str(I: INTEGER; VAR S: STRING);
         ; PROCEDURE Str(L: LONGINT; VAR S: STRING);
         ; PROCEDURE Str(R: REAL; VAR S: STRING);
         ; (INTEGER [: INTEGER],
         ; (LONGINT [: INTEGER],
         ; (REAL [: INTEGER [: INTEGER] ],
	CALL near ptr L6F66		; match('(')
         MOV al,0FFH                  ; A = default type = smart
         CALL near ptr L5EA2                 ; parse integer, longint or real expression
         CALL near ptr L6148                 ; generate code to push REAL, INTEGER,
                                    ; BOOLEAN, CHAR or POINTER on the stack
	CALL near ptr L6F0B		; match(':'), if present
	JNZ near ptr L5CE4		; jump if ':' not matched

         PUSH cx                    ; save type of expression

         CALL near ptr L5E97                 ; parse integer expression
	CALL near ptr O_PSHHL

         POP cx                     ; B = type of expression

         MOV al,ch
	CMP al, 00AH
         JZ near ptr L5D02                 ; INTEGER has no second ':'
         CMP al, 00EH
         JZ near ptr L5D02                 ; LONGINT has no second ':'

	CALL near ptr L6F0B		; match(':'), if present
	JNZ near ptr L5CF9		; jump if ':' not matched

	PUSH cx
         CALL near ptr L5E97                 ; parse integer expression
	CALL near ptr O_PSHHL
	POP cx
	JMP near ptr  L5D02

L5CE4:   ; (INTEGER
         ; (LONGINT
         ; (REAL
         MOV bx,0                    ; assume ': 0' for an integer or longint
	MOV al,ch
         CMP al, 00AH                    ; integer ?
	JZ near ptr L5CEE
         CMP al, 00EH
         JZ near ptr L5CEE                 ; longint ?

         MOV bl,012H                  ; default ': 18' for a real

L5CEE:   CALL near ptr O_LDHL
	CALL near ptr O_PSHHL
	MOV al,ch
         CMP al, 00AH                    ; integer ?
         JZ near ptr L5D02                 ; an integer does not have a second ': x'
         CMP al, 00EH                    ; longint ?
         JZ near ptr L5D02                 ; a longint does not have a second ': x'

L5CF9:   MOV bx,-1                   ; default second ': -1' for real
	CALL near ptr O_LDHL
	CALL near ptr O_PSHHL

L5D02:   CALL near ptr L6F5E                 ; match(',')

         PUSH cx

         CALL near ptr L5CAD                 ; parse VAR string variable
	MOV al,byte ptr L7B62
	DEC al
	MOV bh,al
	MOV bl,6
         CALL near ptr O_HL                  ; output: LD B,length of string variable

         POP cx                     ; B = type of first expression

         MOV bx,offset _L1EBE               ; LIB, print INTEGER
	MOV al,ch
	CMP al, 00AH
	JZ near ptr L5D1F

         MOV bx,offset _L1EBC               ; LIB, print LONGINT
         CMP al, 00EH
         JZ near ptr L5D1F

         MOV bx,offset _L1EBD               ; LIB, print REAL
L5D1F:	JMP near ptr  L5C81

L5D22:   ; PROCEDURE Val(S: STRING; VAR R: REAL; VAR P: INTEGER);
         ; PROCEDURE Val(S: STRING; VAR L: LONGINT; P: INTEGER);
	; PROCEDURE Val(S: STRING; VAR I,P: INTEGER);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5ED0                 ; parse string expression
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L677F                 ; parse VAR parameter
	MOV al,byte ptr L7B5C

         CMP al, 9                       ; type = REAL ?
         JZ near ptr L5D45                 ; jump if type = REAL

         CMP al, 00EH                    ; type = LONGINT ?
         JZ near ptr L5D45                 ; jump if type = LONGINT

         CMP al, 00AH                    ; type = INTEGER ?
         JNZ near ptr L5D41                ; jump if not

         MOV al,byte ptr L7B62
	DEC al
	MOV al,00AH
	JNZ near ptr L5D45

L5D41:   CALL near ptr L72E1                 ; no condition
         DB 1BH                     ; error 27: Integer, longint or
                                    ; real variable expected

L5D45:   lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	CALL near ptr O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L677F                 ; parse VAR parameter
	MOV al,byte ptr L7B5C
         CMP al, 00AH                    ; type = integer ?
	JNZ near ptr L5D5C		; jump if type <> integer

	MOV al,byte ptr L7B62
	DEC al
	JNZ near ptr L5D60

L5D5C:   CALL near ptr L72E1                 ; no condition
	DB 18H			; error 24: Integer variable expected

L5D60:   POP ax
	xchg ah,al
	sahf                     ; A = type
	MOV bx,offset _L1EF4		; LIB, val(string,integer,integer)
         CMP al, 00AH                    ; type = INTEGER ?
	JZ near ptr L5D1F

         MOV bx,offset _L1EF2               ; LIB, val(string,longint,integer)
         CMP al, 00EH                    ; type = LONGINT ?
         JZ near ptr L5D1F

         MOV bx,offset _L1EF3               ; LIB, val(string,real,integer)
	JMP near ptr  L5D1F

L5D6D:   ; PROCEDURE GotoXY(X, Y: INTEGER);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5E97                 ; parse integer expression
	MOV bx,offset _L1FDB		; LIB
         JMP near ptr  L5D76

L5D83:   ; PROCEDURE Randomize;
	MOV bx,offset _L1F48		; LIB
	JMP near ptr  O_CALHL

L5D89:   ; PROCEDURE Delay(mS: INTEGER);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5E97                 ; parse integer expression
	MOV bx,offset _L021D		; LIB
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5E05:   ; PROCEDURE Move(VAR Source,Dest: TYPE; Length: INTEGER);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L677F                 ; parse VAR parameter
	CALL near ptr O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L677F                 ; parse VAR parameter
	MOV bx,offset _L1F64		; LIB, clear
	JMP near ptr  L5D76

L5E1A:   ; PROCEDURE FillChar(var Dest; Length: INTEGER; Data: CHAR);
	; PROCEDURE FillChar(var Dest; Length: INTEGER; Data: BYTE);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L677F                 ; parse VAR parameter
	CALL near ptr O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
	CALL near ptr O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         MOV al,0AH                   ; A = default type = INTEGER
         CALL near ptr L5EBB                 ; parse simple expression
	MOV bx,offset _L1F4E		; LIB, clear
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5D94:   ; PROCEDURE GetMem(VAR P: POINTER; I: INTEGER);
         CALL near ptr L5DE3                 ; parse '(', VAR pointer and O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
	JMP near ptr  L5DAE

L5D9F:	; PROCEDURE New(VAR P: POINTER);
         CALL near ptr L5DE3                 ; parse '(', VAR pointer and O_PSHHL
	MOV bx,word ptr L7B5E
	CALL near ptr L5271
	MOV bx,word ptr L7B6F
	CALL near ptr O_LDHL

L5DAE:	MOV bx,offset _L1CE5		; LIB, clear
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5DB4:	; PROCEDURE FreeMem(VAR P: POINTER; I: INTEGER);
         CALL near ptr L5DE3                 ; parse '(', VAR pointer and O_PSHHL
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
	JMP near ptr  L5DCE

L5DBF:	; PROCEDURE Dispose(VAR P: POINTER);
         CALL near ptr L5DE3                 ; parse '(', VAR pointer and O_PSHHL
	MOV bx,word ptr L7B5E
	CALL near ptr L5271
	MOV bx,word ptr L7B6F
	CALL near ptr O_LDHL

L5DCE:	MOV bx,offset _L1D7A		; LIB, clear
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5DD4:	; PROCEDURE Mark(VAR P: POINTER);
	MOV bx,offset _L1EA3		; LIB, clear
	JMP near ptr  L5DDC

L5DD9:	; PROCEDURE Release(VAR P: POINTER);
	MOV bx,offset _L1EAB		; LIB, clear

L5DDC:   PUSH bx
         CALL near ptr L5DE9                 ; parse '(' and VAR pointer
	POP bx
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5DE3:   ; parses a '(', VAR pointer and O_PSHHL
         CALL near ptr L5DE9                 ; parse '(' and VAR pointer

	JMP near ptr  O_PSHHL

L5DE9:   ; parses a '(' and VAR pointer
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L677F                 ; parse VAR parameter
	MOV al,byte ptr L7B5C
         CMP al, 4                       ; pointer variable parsed ?
         RETZ                       ; return if yes

	CALL near ptr L72E1		; no condition
	DB 1CH			; error 28: Pointer variable expected

L5DF9:   ; PROCEDURE OvrDrive(Drive: INTEGER);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5E97                 ; parse integer expression
	MOV bx,offset _L1CDB		; LIB, clear
         JMP near ptr  L5960                   ; match(')'), CALL HL

L5E38:   ; PROCEDURE CrtInit;
	MOV bx,offset _L030A		; LIB, done
         JMP near ptr  L5E45                   ; CALL HL

L5E3D:	; PROCEDURE CrtExit;
	MOV bx,offset _L0310		; LIB, done
         JMP near ptr  L5E45                   ; CALL HL

L5E42:	; PROCEDURE ClrScr;
	MOV bx,offset _L023E		; LIB, done

L5E45:   JMP near ptr  O_CALHL

L5E48:	; PROCEDURE ClrEol;
	MOV bx,offset _L0299		; LIB, done
         JMP near ptr  L5E45                   ; CALL HL

L5E4D:	; PROCEDURE NormVideo;
	; PROCEDURE HighVideo;
	MOV bx,offset _L0284		; LIB, done
         JMP near ptr  L5E45                   ; CALL HL

L5E52:	; PROCEDURE LowVideo;
	MOV bx,offset _L026B		; LIB, done
         JMP near ptr  L5E45                   ; CALL HL

L5E57:	; PROCEDURE InsLine;
	MOV bx,offset _L0262		; LIB, done
         JMP near ptr  L5E45                   ; CALL HL

L5E5C:	; PROCEDURE DelLine;
         MOV bx,offset _L0259               ; LIB, done
         JMP near ptr  L5E45                   ; CALL HL

P_ERROREXIT:
         ; PROCEDURE ErrorExit;

         CALL near ptr L6F1B                 ; match('('), if present
         JNZ near ptr P_ERROREXIT1         ; jump if '(' not matched

         CALL near ptr L5EA2                 ; parse integer, longint or real expression

         CALL near ptr L6F6E                 ; match(')')

P_ERROREXIT1:
         MOV bx,offset _ERROREXIT
         JMP near ptr  O_CALHL

L5E61:   ; PROCEDURE Exit;
         MOV dx,0000                 ;
         JMP near ptr  L5639

L5E67:	; PROCEDURE Halt;
	MOV bx,offset _L20D4		; LIB, done
	JMP near ptr  O_JPHL

L5E6D:   ; PROCEDURE Port(Port: INTEGER);
         CALL near ptr L5E8E                 ; parse array index, ':=', integer expr.

	CALL near ptr O_CODE
	DB 3
	DB 0C1H			; POP BC
	DB 0EDH,69H		; OUT (C),L

	RET

L5E78:   ; StackPtr:= INTEGER;
	CALL near ptr L6F7E		; match(':=')
         CALL near ptr L5E97                 ; parse integer expression

	CALL near ptr O_CODE
	DB 1
	DB 0F9H			; LD SP,HL

	RET

L6360:   ; FUNCTION Sqr(I: INTEGER): INTEGER;
         ; FUNCTION Sqr(L: LONGINT): LONGINT;
	; FUNCTION Sqr(R: REAL): REAL;
         CALL near ptr L65E7                 ; parse integer, longint or real expression

	MOV bx,offset _L06F3		; LIB, Sqr(I: INTEGER): INTEGER;
	MOV al,ch
         CMP al, 00AH                    ; type = INTEGER ?
         JZ near ptr L636E                 ; jump if type = INTEGER

         MOV bx,offset _L_SQR
         CMP al, 00EH                    ; type = LONGINT ?
         JZ near ptr L636E                 ; jump if type = LONGINT

	MOV bx,offset _L09F7		; LIB, Sqr(R: REAL): REAL;

L636E:	JMP near ptr  O_CALHL

L6371:   ; FUNCTION Abs(I: INTEGER): INTEGER;
	; FUNCTION Abs(R: REAL): REAL;
         ; FUNCTION Abs(L: LONGINT): LONGINT;
         CALL near ptr L65E7                 ; parse integer, longint or real expression
	MOV al,ch
         CMP al, 00AH                    ; type = INTEGER ?
	JZ near ptr L6380

         CMP al, 00EH                    ; type = LONGINT ?
         JZ near ptr L63801

         ; code for REAL
	CALL near ptr O_CODE
	DB 2
	DB 0CBH,0B8H		; RES 7,B

	RET

L6380:	; FUNCTION Abs(I: INTEGER): INTEGER;
	MOV bx,offset _L0780		; LIB, absolute HL, done
	JMP near ptr  L63CF

L63801:  ; FUNCTION Abs(L: LONGINT): LONGINT;
         MOV bx,offset _L_ABS
         MOV ch,0EH                   ; return type = LONGINT
         JMP near ptr  O_CALHL

L6385:   ; FUNCTION Sqrt(R: REAL): REAL;
	MOV bx,offset _L0C46		; LIB, clear
         JMP near ptr  L63AB

L638A:   ; FUNCTION Sin(R: REAL): REAL;
	MOV bx,offset _L0C87		; LIB, clear
	JMP near ptr  L63AB

L638F:   ; FUNCTION Cos(R: REAL): REAL;
	MOV bx,offset _L0C7F		; LIB, clear
	JMP near ptr  L63AB

L6394:   ; FUNCTION ArcTan(R: REAL): REAL;
	MOV bx,offset _L0E46		; LIB, clear
	JMP near ptr  L63AB

L6399:   ; FUNCTION Ln(R: REAL): REAL;
	MOV bx,offset _L0D2B		; LIB, clear
	JMP near ptr  L63AB

L639E:   ; FUNCTION Exp(R: REAL): REAL;
	MOV bx,offset _L0DB6		; LIB, clear
	JMP near ptr  L63AB

L63A3:   ; FUNCTION Int(R: REAL): REAL;
	MOV bx,offset _L0BFD		; LIB, clear
	JMP near ptr  L63AB

L63A8:   ; FUNCTION Frac(R: REAL): REAL;
	MOV bx,offset _L0C34		; LIB, clear

L63AB:	PUSH bx
         CALL near ptr L65E7                 ; parse integer, longint or real expression

	MOV al,ch
         CMP al, 009H                    ; type = REAL ?
         JZ near ptr L63AD                 ; jump if type = REAL

	MOV bx,offset _L1008		; LIB, convert integer HL to float HLDEBC
         CMP al, 00AH                    ; type = INTEGER ?
         JZ near ptr L63AC                 ; jump if type = INTEGER

         MOV bx,offset _L_R                 ; LONGINT to REAL conversion

L63AC:   CALL near ptr O_CALHL

L63AD:
	POP bx
	MOV ch,9
	JMP near ptr  O_CALHL

L63BE:   ; FUNCTION Trunc(R: REAL): INTEGER;
	MOV bx,offset _L0FDE		; LIB, float HLDEBC to int HL, clear
	JMP near ptr  L63C6

L63C3:   ; FUNCTION Round(R: REAL): INTEGER;
	MOV bx,offset _L0FD0		; LIB, clear

L63C6:   PUSH bx
         CALL near ptr L65E7                 ; parse integer, longint or real expression
	POP bx
	MOV al,ch
	CMP al, 00AH			; integer ?
         RETZ                       ; yes, return

         CMP al, 00EH                    ; longint ?
         RETZ                       ; yes, return

L63CF:	MOV ch,00AH
	JMP near ptr  O_CALHL

L63D4:   ; FUNCTION Succ(X: SCALAR): SCALAR;
         MOV al,0FFH                  ; type = smart
         CALL near ptr L65EF                 ; match('('), simple expression, match(')')

         MOV al,ch
         CMP al, 0EH                     ; type = LONGINT ?
         JNZ near ptr L63D5                ; jump if not

         MOV bx,offset _L_SUCC
         JMP near ptr  O_CALHL

L63D5:
         MOV al,023H                  ; opcode: INC HL
         JMP near ptr  O_BYTE

L63D7:   ; FUNCTION Pred(X: SCALAR) : SCALAR;
         MOV al,0FFH                  ; type = smart
         CALL near ptr L65EF                 ; match('('), simple expression, match(')')

         MOV al,ch
         CMP al, 0EH                     ; type = LONGINT ?
         JNZ near ptr L63D8                ; jump if not

         MOV bx,offset _L_PRED
         JMP near ptr  O_CALHL

L63D8:
         MOV al,2BH                   ; opcode: DEC HL
	JMP near ptr  O_BYTE

L63E1:   ; FUNCTION Low(I: INTEGER): INTEGER;
         ; FUNCTION Low(L: LONGINT): INTEGER;
         MOV al,0FFH                  ; type = smart
         CALL near ptr PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         MOV al,ch
         CMP al, 0EH                     ; type = LONGINT ?

         JNZ near ptr L63E2                ; jump if not LONGINT

         MOV ch,0AH                   ; no code generation
                                    ; return type = INTEGER
         RET

L63E2:
         CALL near ptr O_CODE
	DB 2
	DB 26H,00H		; LD H,0

         ; return same type
         RET

L63EB:	; FUNCTION Hi(I: INTEGER): INTEGER;
         ; FUNCTION Hi(L: LONGINT): INTEGER;
         MOV al,0FFH                  ; type = smart
         CALL near ptr PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         MOV al,ch
         CMP al, 0EH                     ; type = LONGINT ?

         JNZ near ptr L63EC                ; jump if not LONGINT

         MOV ch,0AH                   ; return type = INTEGER
         MOV al,0EBH                  ; opcode: EX DE,HL
         JMP near ptr  O_BYTE

L63EC:
	CALL near ptr O_CODE
	DB 3
	DB 6CH			; LD L,H
	DB 26H,00H		; LD H,0

         ; return same type
	RET

L63F6:	; FUNCTION Swap(I: INTEGER): INTEGER;
         MOV al,0FFH                  ; type = smart
         CALL near ptr PARSE_O_IL_C

         MOV al,ch
         CMP al, 0EH                     ; type = LONGINT ?

         JNZ near ptr L63F7                ; jump if not LONGINT

         MOV al,0EBH                  ; opcode: EX DE,HL
         JMP near ptr  O_BYTE                  ; output code and return same type

L63F7:
	CALL near ptr O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 6CH			; LD L,H
	DB 67H			; LD H,A

	RET

L6401:   ; FUNCTION Odd(I: INTEGER): BOOLEAN;
         MOV al,0FFH                  ; type = smart
         CALL near ptr PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         MOV bx,offset _L078B               ; LIB, make integer HL a boolean, clear

L6407:   MOV ch,00BH
         JMP near ptr  O_CALHL

L640C:   ; FUNCTION KeyPressed: BOOLEAN;
         MOV bx,offset _CONSTPTR            ; LIB
	JMP near ptr  L6407

L6411:   ; Function Ord(X: SCALAR): INTEGER;
	CALL near ptr L6F66		; match('(')
         MOV al,0AH                   ; A = default type = INTEGER
         CALL near ptr L5EE8                 ; parse expression
	CALL near ptr L6F6E		; match(')')
	MOV al,ch
         CMP al, 4                       ; POINTER type ?
         JZ near ptr L6422                 ; jump if POINTER type

         CALL near ptr L5EBE                 ; check for a simple type expression

L6422:   MOV ch,00AH
	RET

L6425:   ; FUNCTION Chr(I: INTEGER): CHAR;
         ; FUNCTION Chr(L: LONGINT): CHAR;
         MOV al,0FFH                  ; type = smart
         CALL near ptr PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

	MOV ch,00CH
	RET

L642B:   ; Function Ptr(I: INTEGER): POINTER;
         CALL near ptr PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         MOV bx,0000
	MOV word ptr L7B8B,bx
         MOV ch,4                     ; return POINTER type
	RET

L6437:   ; FUNCTION UpCase(Ch: CHAR): CHAR;
         MOV al,0CH                   ; A = default expression = CHARC
	CALL near ptr L65EF
	MOV ch,00CH
	MOV bx,offset _L1FE4		; LIB, clear
         JMP near ptr  O_CALHL

L6441:   ; FUNCTION Length(S: STRING): INTEGER;
	CALL near ptr L6F66		; match('(')
	MOV bx,offset _L08A3		; LIB, clear

L6447:   PUSH bx
         CALL near ptr L5ED0                 ; parse string expression
	CALL near ptr L6F6E		; match(')')
	POP bx
	JMP near ptr  L63CF

L6452:   ; FUNCTION Pos(Pattern, Source: STRING): INTEGER;
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5ED0                 ; parse string expression
         CALL near ptr L6F5E                 ; match(',')
	MOV bx,offset _L08B2		; LIB, clear
	JMP near ptr  L6447

L6460:   ; FUNCTION Copy(S: STRING; Pos, Len: INTEGER): STRING;
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5ED0                 ; parse string expression
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr L6F5E                 ; match(',')
	CALL near ptr O_PSHHL
         CALL near ptr L5E97                 ; parse integer expression
	CALL near ptr L6F6E		; match(')')
	MOV bx,offset _L086B		; LIB, clear
	CALL near ptr O_CALHL

L647E:	MOV ch,8
	RET

L6481:   ; FUNCTION Concat(S1,S2,...,Sn: STRING);
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5ED0                 ; parse string expression
L6487:	CALL near ptr L6F13		; match(','), if present
	JNZ near ptr L6497		; jump if ',' not matched
         CALL near ptr L5ED0                 ; parse string expression
	MOV bx,offset _L083D		; LIB, clear
	CALL near ptr O_CALHL
	JMP near ptr  L6487

L6497:	CALL near ptr L6F6E		; match(')')
	JMP near ptr  L647E

L649C:   ; FUNCTION ParamCount: INTEGER;
	MOV bx,offset _L1F9B		; LIB, clear
	JMP near ptr  L64BF

L64A1:   ; FUNCTION ParamStr(N: INTEGER): STRING;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'

	MOV bx,offset _L1F7D		; LIB, clear
	MOV ch,8
	JMP near ptr  O_CALHL

L64AC:   ; FUNCTION Random(Range: INTEGER): INTEGER;
	; FUNCTION Random: REAL;
	CALL near ptr L6F1B		; match('('), if present
	MOV bx,offset _L0FB4		; LIB, clear
	MOV ch,9			; assume REAL type
	JNZ near ptr L64C1		; jump if '(' not matched

         CALL near ptr L5E97                 ; parse integer expression
	CALL near ptr L6F6E		; match(')')
	MOV bx,offset _L073B		; LIB, clear

L64BF:	MOV ch,00AH		; INTEGER type

L64C1:	JMP near ptr  O_CALHL

L64C4:   ; FUNCTION IOresult: BYTE (BOOLEAN in manual ?)
	MOV bx,offset _L1FF1		; LIB, clear
	JMP near ptr  L64BF

L64C9:   ; FUNCTION Eof(VAR F: FILE): BOOLEAN;
	CALL near ptr L65F7

	MOV bx,offset L6615		; table of three file types
	CALL near ptr L59E9		; generate call for file IO
L64D2:   MOV ch,00BH                  ; returns BOOLEAN type
	RET

L6615:   DW _L1A49                  ; LIB, Eof, typed file,   type 5
         DW _L17E6                  ; LIB, Eof, text,         type 6
	DW _L1A49		; LIB, Eof, untyped file, type 7

L64D5:   ; FUNCTION SeekEof(VAR F: TEXT): BOOLEAN;
	MOV bx,offset _L17E1		; LIB, clear
	JMP near ptr  L64E2

L64DA:   ; FUNCTION SeekEoln(VAR F: TEXT): BOOLEAN;
	MOV bx,offset _L17D7		; LIB, clear
	JMP near ptr  L64E2

L64DF:   ; FUNCTION Eoln(VAR F: TEXT): BOOLEAN;
	MOV bx,offset _L17DC		; LIB, clear

L64E2:	PUSH bx
	CALL near ptr L65F7

	CMP al, 6			; text file ?

	CALL near ptr L72DA		; NonZero --> error
	DB 23H			; error 35: Textfile expected

	POP bx
	CALL near ptr O_CALHL
	JMP near ptr  L64D2

L64F2:   ; FUNCTION FilePos(VAR F: FILE OF TYPE): INTEGER;
	; FUNCTION FilePos(VAR F: FILE): INTEGER;
	MOV bx,offset _L1A55		; LIB, clear
	MOV dx,offset _L1A55		; LIB, clear
         JMP near ptr  L6500

L64FA:   ; FUNCTION FileSize(VAR F: FILE OF TYPE): INTEGER;
	; FUNCTION FileSize(var F: FILE): INTEGER;
	MOV bx,offset _L1A5D		; LIB, clear
	MOV dx,offset _L1A5D		; LIB, clear

L6500:	PUSH bx
	PUSH dx
         CALL near ptr L65F7
	POP dx
	POP bx
	CMP al, 6			; text file ?

	CALL near ptr L72D4		; Zero --> error
	DB 3FH			; error 63: Textfiles are not allowed here

	CMP al, 5			; typed file ?
         JZ near ptr L7FA9 ; 33e,L 64BF                 ; jump if typed file
	XCHG dx,bx
         JMP near ptr  L7FA9 ; 33e, L64BF

; 33e
L7FA9:
         MOV ch,0EH                   ; LONGINT type
         JMP near ptr  O_CALHL
; 33e

L6514:   ; FUNCTION MemAvail: INTEGER;
	MOV bx,offset _L1E3D		; LIB, clear
	JMP near ptr  L64BF

L6519:   ; FUNCTION MaxAvail: INTEGER;
	MOV bx,offset _L1E44		; LIB, clear
	JMP near ptr  L64BF

L651E:   ; PROCEDURE Bios(Func,Param: INTEGER);
	MOV al,0AFH		; LD A,XOR A
	JMP near ptr  L6520

L651F:	; FUNCTION Bios(Func,Param: INTEGER): BYTE;
	XOR al, al
L6520:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save flag for FUNCTION/PROCEDURE
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5E97                 ; parse integer expression

	CALL near ptr O_PSHHL		; push Func

	CALL near ptr L6F13		; match(','), if present
         JNZ near ptr L6538                ; jump if ',' not matched

         CALL near ptr L5E97                 ; parse integer expression

	; BC = Param
	CALL near ptr O_CODE
	DB 2
	DB 44H			; LD B,H
	DB 4DH			; LD C,L

L6538:	CALL near ptr O_CODE
	DB 1
	DB 0D1H			; POP DE, E = Func

	MOV bx,offset _L1FEA		; LIB, clear
         JMP near ptr  L6540

L6553:   ; PROCEDURE Bdos(Func,Param: INTEGER);
	MOV al,0AFH		; LD A,XOR A
	JMP near ptr  L6555

L6554:	; FUNCTION Bdos(Func,Param: INTEGER): BYTE;
	XOR al, al
L6555:	lahf
	xchg ah,al
	PUSH ax
	xchg ah,al			; save flag for FUNCTION/PROCEDURE
	CALL near ptr L6F66		; match('(')
         CALL near ptr L5E97                 ; parse integer expression

	CALL near ptr O_PSHHL		; push function number in L

	CALL near ptr L6F13		; match(','), if present
	JNZ near ptr L656C		; jump if ',' not matched
         CALL near ptr L5E97                 ; parse integer expression

	CALL near ptr O_CODE
	DB 1
	DB 0EBH			; EX DE,HL

L656C:	CALL near ptr O_CODE
	DB 1
	DB 0C1H			; POP BC, restore function number in C

	MOV bx,0005H
         JMP near ptr  L6540                   ; output: CALL 0005H

L6576:   ; FUNCTION ADDR(VAR Variable): INTEGER;
	CALL near ptr L6F66		; match('(')
	MOV cx,500H
	CALL near ptr L6E54		; check if current in id list
	JZ near ptr L6589
	MOV cx,600H
	CALL near ptr L6E54		; check if current in id list
	JNZ near ptr L6594

L6589:   DEC bx
	DEC bx
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	XCHG dx,bx

L658F:   CALL near ptr O_LDHL
	JMP near ptr  L6597

L6594:   CALL near ptr L677F                 ; parse var parameter
L6597:	CALL near ptr L6F6E		; match(')')
	MOV ch,00AH
	RET

L659D:	; FUNCTION SizeOf(VAR Variable): INTEGER;
	CALL near ptr L6F66		; match('(')
	MOV cx,300H
	CALL near ptr L6E54		; check if current in id list, types
	JNZ near ptr L65B1
	MOV dh,byte ptr [bx]
	DEC bx
	MOV dl,byte ptr [bx]
	XCHG dx,bx
	CALL near ptr L5287		; 8 bytes from HL (down) to 7B5C (up)
	JMP near ptr  L65BA

L65B1:   PUSH di
         CALL near ptr L677F                 ; parse var parameter
	POP bx
	CALL near ptr L6CC2

L65BA:   MOV bx,word ptr L7B62              ; HL = size of variable
	JMP near ptr  L658F

L65BF:   ; FUNCTION Port(N: INTEGER): BYTE;
         CALL near ptr L65D5                 ; parse an array index

	CALL near ptr O_CODE
	DB 3
	DB 4DH			; LD C,L
	DB 0EDH,68H		; IN L,(C)

	RET

L65CA:	; FUNCTION StackPtr: INTEGER
	; returns stackptr value

	CALL near ptr O_CODE
	DB 4
	DB 21H,00H,00H		; LD HL,0000
	DB 39H			; ADD HL,SP

	MOV ch,00AH		; result = integer
	RET

P_DOSERRORHANDLERON:
         MOV bx,offset _DOSERRORHANDLERON
         JMP near ptr  O_CALHL

P_DOSERRORHANDLEROFF:
         MOV bx,offset _DOSERRORHANDLEROFF
         JMP near ptr  O_CALHL

L7638:   ; Procedure's
         DC 'FWRITELN'
         DW L5AE7                   ; Fast WRITELN

         DC 'WRITELN'               ; 1x list
         DW L5AE71

         DC 'FWRITE'
         DW L5AE8                   ; Fast WRITE

         DC 'WRITE'
         DW L5AE81

	DC 'READLN'
         DW L5A32

	DC 'READ'
         DW L5A33

	DC 'DELETE'
         DW L5C66                   ; OK

	DC 'INSERT'
         DW L5C87

	DC 'ASSIGN'                ; OK
         DW L5943

	DC 'RESET'
         DW L59B9                   ; OK

	DC 'REWRITE'
         DW L59BE                   ; OK

	DC 'CLOSE'
         DW L59DB                   ; OK

	DC 'ERASE'
         DW L5971                   ; OK

	DC 'RENAME'
         DW L5966                   ; OK

         DC 'RENAMEFILE'            ; OK
         DW P_RENAMEFILE

	DC 'SEEK'
         DW L598C                   ; OK

         DC 'GETMEM'
         DW L5D94                   ; OK

	DC 'NEW'
         DW L5D9F                   ; OK

	DC 'FREEMEM'
         DW L5DB4                   ; OK

         DC 'DISPOSE'
         DW L5DBF                   ; OK

         DC 'MARK'
         DW L5DD4                   ; OK

         DC 'RELEASE'
         DW L5DD9                   ; OK

	DC 'OVRDRIVE'
         DW L5DF9                   ; OK

	DC 'CRTINIT'
         DW L5E38                   ; OK

	DC 'CRTEXIT'
         DW L5E3D                   ; OK

	DC 'GOTOXY'
         DW L5D6D                   ; OK

	DC 'CLRSCR'
         DW L5E42                   ; OK

	DC 'CLREOL'
         DW L5E48                   ; OK

	DC 'NORMVIDEO'
         DW L5E4D                   ; OK

	DC 'HIGHVIDEO'
         DW L5E4D                   ; OK

	DC 'LOWVIDEO'
         DW L5E52                   ; OK

	DC 'INSLINE'
         DW L5E57                   ; OK

	DC 'DELLINE'
         DW L5E5C                   ; OK

	DC 'DELAY'
         DW L5D89                   ; OK

	DC 'BLOCKREAD'
         DW L5C16                   ; OK

	DC 'BLOCKWRITE'
         DW L5C1E                   ; OK

	DC 'RANDOMIZE'
         DW L5D83                   ; OK

	DC 'MOVE'
         DW L5E05                   ; OK

	DC 'FILLCHAR'
         DW L5E1A                   ; OK

         DC 'ERROREXIT'
         DW P_ERROREXIT             ; ??

	DC 'EXIT'
         DW L5E61                   ; OK

	DC 'HALT'
         DW L5E67                   ; OK

         DC 'PORT'
         DW L5E6D                   ; OK

	DC 'STACKPTR'              ; stackptr assignment
         DW L5E78                   ; OK

	DC 'FLUSH'
         DW L59AB                   ; OK

	DC 'EXECUTE'
         DW L597E                   ; OK

	DC 'CHAIN'
         DW L5979                   ; OK

	DC 'STR'
         DW L5CBA                   ; OK

	DC 'VAL'
         DW L5D22                   ; OK

	DC 'BDOS'
         DW L6553                   ; OK

	DC 'BIOS'
         DW L651E                   ; OK

         DC 'DOSERRORHANDLERON'
         DW P_DOSERRORHANDLERON

         DC 'DOSERRORHANDLEROFF'
         DW P_DOSERRORHANDLEROFF

         ; GIOS Procedures
         DC 'DELETEFILE'
         DW P_DELETEFILE

         DC 'DEFINEPICTURE'
         DW P_DEFINEPICTURE

         DC 'PFILLSHAPE'
         DW P_PFILLSHAPE

         DC 'PPAINT'
         DW P_PPAINT

         DC 'MEMEXPAND'
         DW P_MEMEXPAND

         DC 'MEMTOVRAM'
         DW P_MEMTOVRAM

         DC 'MEMLOADPICTURE'
         DW P_MEMLOADPICTURE

;         DC 'MEMUNCRUNCH'
;         DW P_MEMUNCRUNCH

         DC 'MEMSAVEPICTURE'
         DW P_MEMSAVEPICTURE

         DC 'SETCLIPPING'
         DW P_SETCLIPPING

         DC 'SETVIEWPORT'
         DW P_SETVIEWPORT

         DC 'GETVIEWPORT'
         DW P_GETVIEWPORT

         DC 'MEMCOPY'
         DW P_MEMCOPY

         DC 'BLOAD'
         DW P_BLOAD

         DC 'BSAVE'
         DW P_BSAVE

         DC 'CHANGECOLOR'
         DW P_CHANGECOLOR

         DC 'CHANGESCREEN'
         DW P_CHANGESCREEN

         DC 'CIRCLE'
         DW P_CIRCLE

         DC 'CLEARMEM'
         DW P_CLEARMEM

         DC 'DATE'
         DW P_DATE

         DC 'DISPLAYPAGE'
         DW P_DISPLAYPAGE

         DC 'ELLIPSE'                ; name not completely English !
         DW P_ELLIPSE

         DC 'EXPAND'
         DW P_EXPAND

         DC 'FASTBOX'
         DW P_FASTBOX

         DC 'FASTCOPY'
         DW P_FASTCOPY

         DC 'FILLBOX'
         DW P_FILLBOX

         DC 'FILLSHAPE'
         DW P_FILLSHAPE

         DC 'FILLSPRITE'
         DW P_FILLSPRITE

         DC 'GCOPY'
         DW P_GCOPY

         DC 'GETDOSVERSION'
         DW P_GETDOSVERSION

         DC 'LINE'
         DW P_LINE

         DC 'LOADPICTURE'
         DW P_LOADPICTURE

         DC 'LOADVRAM'
         DW P_LOADVRAM

         DC 'MEMREADFILE'
         DW P_MEMREADFILE

         DC 'MEMWRITEFILE'
         DW P_MEMWRITEFILE

         DC 'MEMAPPENDFILE'
         DW P_MEMAPPENDFILE

         DC 'MOVEVRAM'
         DW P_MOVEVRAM

         DC 'PAINT'
         DW P_PAINT

         DC 'PSET'
         DW P_PSET

         DC 'PUTSPRITE'
         DW P_PUTSPRITE

         DC 'READMEM'
         DW P_READMEM

         DC 'READSECTOR'
         DW P_READSECTOR

         DC 'SAVEPICTURE'
         DW P_SAVEPICTURE

;         DC 'SAVEVRAM'
;         DW P_SAVEVRAM

         DC 'SCREEN'
         DW P_SCREEN

         DC 'SCREENOFF'
         DW P_SCREENOFF

         DC 'SCREENON'
         DW P_SCREENON

         DC 'SETCHANNEL'
         DW P_SETCHANNEL

         DC 'SOUND'
         DW P_SOUND

         DC 'SPRITEATTRIBUTEADDRESS'
         DW P_SPRITEATTRIBUTEADDRESS

         DC 'SPRITECOLOR'
         DW P_SPRITECOLOR

         DC 'SPRITEPATTERN'
         DW P_SPRITEPATTERN

         DC 'SPRITEPATTERNADDRESS'
         DW P_SPRITEPATTERNADDRESS

         DC 'SPRITESIZE'
         DW P_SPRITESIZE

         DC 'SPRITESOFF'
         DW P_SPRITESOFF

         DC 'SPRITESON'
         DW P_SPRITESON

         DC 'TIME'
         DW P_TIME

;         DC 'UNCRUNCH'
;         DW P_UNCRUNCH

         DC 'VPOKE'
         DW P_VPOKE

         DC 'WAITVDP'
         DW P_WAITVDP

         DC 'WRITEMEM'
         DW P_WRITEMEM

         DC 'WRITESECTOR'
         DW P_WRITESECTOR

         DC 'WRITEVDP'
         DW P_WRITEVDP

         DB 0                       ; end of this table


L77B1:   ; Functions
         DC 'CHR'                   ; 1x list
         DW L6425                   ; OK

	DC 'ORD'
         DW L6411                   ; OK

	DC 'COPY'
         DW L6460                   ; OK

	DC 'LENGTH'
         DW L6441                   ; OK

	DC 'POS'
         DW L6452                   ; OK

	DC 'CONCAT'
         DW L6481                   ; OK

	DC 'SUCC'
         DW L63D4                   ; OK

	DC 'PRED'
         DW L63D7                   ; OK

	DC 'UPCASE'
         DW L6437                   ; OK

	DC 'TRUNC'
         DW L63BE                   ; OK

	DC 'ROUND'
         DW L63C3                   ; OK

	DC 'ODD'
         DW L6401                   ; OK

         DC 'ABS'
         DW L6371                   ; OK

	DC 'SQR'
         DW L6360                   ; OK

	DC 'SQRT'
         DW L6385                   ; OK

	DC 'SIN'
         DW L638A                   ; OK

	DC 'COS'
         DW L638F                   ; OK

	DC 'ARCTAN'
         DW L6394                   ; OK

	DC 'LN'
         DW L6399                   ; OK

	DC 'EXP'
         DW L639E                   ; OK

         DC 'INT'
         DW L63A3                   ; OK

         DC 'FRAC'
         DW L63A8                   ; OK

	DC 'RANDOM'
         DW L64AC                   ; OK

	DC 'PARAMCOUNT'
         DW L649C                   ; OK

	DC 'PARAMSTR'
         DW L64A1                   ; OK

	DC 'LO'
         DW L63E1                   ; OK

	DC 'HI'
         DW L63EB                   ; OK

         DC 'SWAP'
         DW L63F6                   ; OK

	DC 'PTR'
         DW L642B                   ; OK

	DC 'IORESULT'
         DW L64C4                   ; OK

	DC 'EOF'
         DW L64C9                   ; OK

	DC 'EOLN'
         DW L64DF                   ; OK

	DC 'SEEKEOF'
         DW L64D5                   ; OK

	DC 'SEEKEOLN'
         DW L64DA                   ; OK

	DC 'FILESIZE'
         DW L64FA                   ; OK

	DC 'FILEPOS'
         DW L64F2                   ; OK

	DC 'KEYPRESSED'
         DW L640C                   ; OK

	DC 'MEMAVAIL'
         DW L6514                   ; OK

	DC 'MAXAVAIL'
         DW L6519                   ; OK

	DC 'PORT'
         DW L65BF                   ; OK

	DC 'STACKPTR'              ; stackptr value
         DW L65CA                   ; OK

	DC 'ADDR'
         DW L6576                   ; OK

	DC 'SIZEOF'                ; OK
         DW L659D

	DC 'BDOSHL'
         DW L6553                   ; OK

	DC 'BDOS'
         DW L6554                   ; OK

	DC 'BIOSHL'
         DW L651E                   ; OK

	DC 'BIOS'
         DW L651F                   ; OK

         ; GIOS Functions
         DC 'TSRPRESENT'
         DW F_TSRPRESENT            ; OK

         DC 'GETCLIPPING'
         DW F_GETCLIPPING

         DC 'SIMULATEDDISK'
         DW F_SIMULATEDDISK

         DC 'FINDFIRST'
         DW F_FINDFIRST             ; OK

         DC 'FINDNEXT'
         DW F_FINDNEXT              ; OK

         DC 'GETDRIVE'
         DW F_GETDRIVE              ; OK

         DC 'TESTDRIVE'
         DW F_TESTDRIVE             ; OK

         DC 'GETERROR'
         DW F_GETERROR              ; OK

         DC 'GETFKEY'
         DW F_GETFKEY               ; OK

         DC 'GETPAD'
         DW F_GETPAD                ; OK

         DC 'GETPDL'
         DW F_GETPDL                ; OK

         DC 'GETCHANNEL'
         DW F_GETCHANNEL            ; OK

         DC 'GETPAGEID'
         DW F_GETPAGEID             ; OK

         DC 'POINT'
         DW F_POINT                 ; OK

         DC 'READPSG'
         DW F_READPSG               ; OK

         DC 'READSTATUS'
         DW F_READSTATUS            ; OK

         DC 'READVDP'
         DW F_READVDP               ; OK

         DC 'SEARCH'
         DW F_SEARCH

         DC 'SETDATE'
         DW F_SETDATE

         DC 'SETMEM'
         DW F_SETMEM                ; OK

         DC 'SETTIME'
         DW F_SETTIME

         DC 'STICK'
         DW F_STICK                 ; OK

         DC 'STRIG'
         DW F_STRIG                 ; OK

         DC 'VPEEK'
         DW F_VPEEK

         DB 0                       ; end of this table