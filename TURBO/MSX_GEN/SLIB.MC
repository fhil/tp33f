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
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter
         DB 21h
	DW _L1370               ; LIB, assume file type = untyped or typed
	DB 0feh, 6
	DB 20h,(L5955)-$-1		; jump if not text file

	DB 21h
	DW _L136F		; LIB, file type = text
	DB 0cdh
	DW  L5955
         DB 0c3h
	DW  L5ABE                   ; add call for I/O checking, if on

L5955:	DB 0e5h
	DB 0cdh
	DW  O_PSHHL		; push for first parameter, FIB address
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
	DB 0e1h
         DB 0c3h
	DW  L5960                   ; match(')', CALL HL

L5966:   ; PROCEDURE Rename(VAR F: FILE; Name: STRING);
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter
	DB 21h
	DW _L1BA5		; LIB, rename
	DB 0cdh
	DW  L5955
         DB 0c3h
	DW  L5ABE                   ; add call for I/O checking, if on

P_RENAMEFILE:
         ; PROCEDURE RenameFile(OldName: STRING; NewName: STRING);
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
         DB 21h
	DW _RENAMEFILE_LIB
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5971:	; PROCEDURE Erase(VAR F: FILE);
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter
	DB 21h
	DW _L1B93		; LIB
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5979:	; PROCEDURE Chain(VAR F: FILE);
         DB 21h
	DW _L1BEB               ; LIB
         DB 18h,( L5981)-$-1

L597E:	; PROCEDURE Execute(VAR F: FILE);
         DB 21h
	DW _L1BEA               ; LIB
L5981:	DB 0e5h
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter

L5985:   DB 0e1h
L5986:   DB 0cdh
	DW  L5960                 ; match(')'), CALL HL

         DB 0c3h
	DW  L5ABE                   ; add call for I/O checking, if on

L598C:	; PROCEDURE Seek(VAR F: FILE OF TYPE; Pos: INTEGER);
         ; PROCEDURE Seek(VAR F: FILE; Pos: INTEGER);
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter
	DB 0feh, 6

	DB 0cdh
	DW  L72D4		; Zero --> error
         DB 3FH                     ; error 63: Textfiles are not allowed here

         DB 21h
	DW _L19D5               ; LIB, seek typed
	DB 0feh, 5
         DB 28h,(L599F)-$-1                 ; jump if typed

         DB 21h
	DW _L1B6F               ; LIB, seek untyped
L599F:	DB 0e5h
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
;         CALL L5E97                 ; parse integer expression
         DB 0cdh
	DW  PARSELONG             ; parse integer/long expression
	DB 18h,( L5985)-$-1

L59AB:   ; PROCEDURE Flush(VAR F: FILE OF TYPE);
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter
	DB 0feh, 5

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 40H			; error 64: Textfiles and untyped files
				;	    are not allowed here

         DB 21h
	DW _L19A5               ; LIB, flush typed file
	DB 18h,( L5986)-$-1

L59B9:	; PROCEDURE Reset(VAR F: FILE);
         DB 21h
	DW L59FA
	DB 18h,( L59C1)-$-1

L59BE:	; PROCEDURE Rewrite(VAR F: FILE);
	DB 21h
	DW L5A00
L59C1:	DB 0e5h
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter
         DB 3ah
	DW L7B5C               ; 33e, 54C8
         DB 0feh, 7
         DB 28h,(L78CD)-$-1
         DB 0feh, 5                       ; jump if not a typed file
         DB 20h,(L59D8)-$-1

         ; typed file
         DB 02ah
	DW L7B5E
	DB 0cdh
	DW  L5271

	DB 02ah
	DW L7B6F
	DB 0cdh
	DW  O_LDDE

L59D8:	DB 0e1h
	DB 18h,( L59E1)-$-1

; 33e
L78CD:
         DB 0cdh
	DW  O_PSHHL               ; L427D
         DB 0cdh
	DW  L6F13                 ; match(','), if present
         DB 20h,(L78E3)-$-1                ; jump if no size given

         DB 3ah
	DW L7B5C
         DB 0f5h
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0f1h
         DB 32h
	DW L7B5C
         DB 0e1h
         DB 18h,( L59E1)-$-1

L78E3:
         DB 21h
	DW 0080H                ; default block size
         DB 0cdh
	DW  O_LDHL
         DB 0e1h
         DB 18h,( L59E1)-$-1
; 33e

L59DB:	; PROCEDURE Close(VAR F: FILE);
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter

         DB 21h
	DW L5A06                ; HL = address of table for closing types
L59E1:   DB 0cdh
	DW  L6F6E                 ; match(')')

         DB 0cdh
	DW  L59E9                 ; generate call for file I/O
         DB 0c3h
	DW  L5ABE                   ; add call for I/O checking, if on


L5A32:   ; PROCEDURE Readln(VAR F: TEXT);
	DB 3eh,0AFH		; NZ = 'LN' after read
         DB 18h,( L5A34)-$-1

L5A33:	; PROCEDURE Read(VAR F: FILE OF TYPE; VAR F: TYPE);
	; PROCEDURE Read(VAR F: TEXT; VAR I: INTEGER);
         ; PROCEDURE Read(VAR F: TEXT; VAR L: LONGINT);
	; PROCEDURE Read(VAR F: TEXT; VAR R: REAL);
	; PROCEDURE Read(VAR F: TEXT; VAR C: CHAR);
	; PROCEDURE Read(VAR F: TEXT; VAR S: STRING);
	DB 0afh
L5A34:   DB 32h
	DW L7BA3               ; 0 = no 'LN' after read
	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 28h,(L5A41)-$-1		; jump if '(' matched

	; PROCEDURE Read;
	DB 0cdh
	DW  L5ACA
	DB 18h,( L5AB4)-$-1

L5A41:   DB 0cdh
	DW  L5A17                 ; parse file parameter
	DB 38h,(L5A63)-$-1
	DB 20h,(L5A5B)-$-1

         DB 0feh, 5                       ; typed file ?
	DB 0cah
	DW L5BD8		; jump if typed file

         DB 0feh, 6                       ; no typed file and no text file ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 41H			; error 65: Untyped files are not allowed here

	; read from text file
	DB 21h
	DW _L14A9		; LIB
	DB 0cdh
	DW  O_CALHL
	DB 18h,( L5AAC)-$-1

L5A5B:	DB 0cdh
	DW  L678B
	DB 0cdh
	DW  L5ACA
	DB 18h,( L5A69)-$-1

L5A63:	DB 0cdh
	DW  L5ACA
L5A66:   DB 0cdh
	DW  L677F                 ; parse var parameter

L5A69:	DB 3ah
	DW L7B5C
	DB 0feh, 8
         DB 38h,(L5A78)-$-1                 ; no STRING, REAL, INTEGER, BOOLEAN,
                                    ; CHAR or LONGINT

         DB 0feh, 0BH                     ; type = BOOLEAN ?
         DB 28h,(L5A78)-$-1                 ; jump for error 66

         DB 0feh, 0EH+1
	DB 38h,(L5A7C)-$-1

L5A78:	DB 0cdh
	DW  L72E1		; no condition
	DB 42H			; error 66: I/O are not allowed

L5A7C:	DB 0feh, 8
	DB 20h,(L5A8F)-$-1

         ; printed type = STRING
         DB 3ah
	DW L7B62
	DB 3dh
	DB 67h
	DB 2eh,6
	DB 0cdh
	DW  O_HL

         DB 3eh,8
         DB 18h,( L5A90)-$-1

L5A8F:
         DB 0feh, 0AH
         DB 20h,(L5A90)-$-1                ; jump if not INTEGER

         DB 3ah
	DW L7B62
         DB 3dh

         DB 3eh,0AH                   ; assume INTEGER
         DB 20h,(L5A90)-$-1

         DB 3eh,0DH                   ; no, BYTE type

L5A90:
         DB 21h
	DW READTYPESTABLE - 8*2
         DB 0cdh
	DW  TABLEINDEX2

         DB 0cdh
	DW  O_CALHL

L5AAC:   DB 0cdh
	DW  L6F13                 ; match(','), if present
	DB 28h,(L5A66)-$-1		; jump if ',' matched

	DB 0cdh
	DW  L6F6E		; match(')')

L5AB4:   DB 21h
	DW _L16AB               ; LIB, 'LN' after Read

L5AB7:   DB 3ah
	DW L7BA3               ; 0 = no 'LN' after read/write
	DB 0b7h
	DB 0c4h
	DW O_CALHL		; call if LN is needed

L5ABE:   DB 3ah
	DW L7B9E               ; compiler directives
	DB 0cbh,047h			; 1 = I/O Error Handling on
	DB 0c8h			; return if off
	DB 21h
	DW _L201B		; LIB, I/O Error function
	DB 0c3h
	DW  O_CALHL

READTYPESTABLE:
         DW _L168E                  ; 08, read STRING
         DW _L1672                  ; 09, read REAL
         DW _L164E                  ; 0A, read INTEGER
         DW 0                       ; 0B
         DW _L1644                  ; 0C, read CHAR
         DW _L164D                  ; 0D, read BYTE
         DW _L1671                  ; 0E, read LONGINT

L5ACA:   DB 21h
	DW _L149B               ; LIB, assume normal output
	DB 3ah
	DW L7B9E		; compiler directives
	DB 0cbh,077h			; 1 = I/O Mode selection on
	DB 28h,(L5AE4)-$-1		; jump if off

         DB 21h
	DW _L14CC               ; LIB, read from console

         DB 3ah
	DW L7BA3
	DB 0b7h
	DB 28h,(L5AE4)-$-1

         DB 21h
	DW _L14CB               ; LIB, readln from console
	DB 0afh
	DB 32h
	DW L7BA3
L5AE4:	DB 0c3h
	DW  O_CALHL

L5AE7:   ; FastWriteln
         DB 3eh,1
         DB 18h,( L5AE72)-$-1

L5AE71:  ; normal Writeln
         DB 0afh

L5AE72:  DB 32h
	DW FASTWRITE

         ; PROCEDURE Writeln(VAR F: TEXT);
         DB 3eh,0AFH                  ; NZ = 'LN' after write
	DB 18h,( L5AE9)-$-1

L5AE8:   ; FastWrite
         DB 3eh,1
         DB 18h,( L5AE82)-$-1

L5AE81:  ; normal Write
         DB 0afh

L5AE82:  DB 32h
	DW FASTWRITE
         ; PROCEDURE Write(VAR F: FILE OF TYPE; VAR V: TYPE);
	; PROCEDURE Write(VAR F: TEXT; I: INTEGER);
         ; PROCEDURE Write(VAR F: TEXT; L: LONGINT);
         ; PROCEDURE Write(VAR F: TEXT; R: REAL);
	; PROCEDURE Write(VAR F: TEXT; B: BOOLEAN);
	; PROCEDURE Write(VAR F: TEXT; C: CHAR);
	; PROCEDURE Write(VAR F: TEXT; S: STRING);
	DB 0afh

L5AE9:   DB 32h
	DW L7BA3               ; 0 = no 'LN' after write

         DB 0cdh
	DW  L6F1B                 ; match('('), if present
         DB 28h,(L5AFA)-$-1                 ; jump if '(' matched

	DB 21h
	DW _L149B		; LIB
         DB 0cdh
	DW  O_CALHL               ; set FIB address at standard output

         DB 0c3h
	DW  L5BD2                   ; output CALL for CR, LF codes

L5AFA:   ; '(' parsed
         DB 0cdh
	DW  L5A17                 ; parse file parameter
         DB 38h,(L5B20)-$-1                 ; jump if no file variable present
                                    ; output CALL for standard output
         DB 20h,(L5B15)-$-1

         DB 0feh, 5                       ; typed file ?
         DB 0cah
	DW L5BDD                 ; jump if typed file

         DB 0feh, 6                       ; text file

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 41H			; error 65: Untyped files are not allowed here

	DB 21h
	DW _L14BA		; LIB
	DB 0cdh
	DW  O_CALHL

	DB 0c3h
	DW  L5BC9

L5B15:   DB 0cdh
	DW  L620F

         DB 21h
	DW _L149B               ; LIB
         DB 0cdh
	DW  O_CALHL               ; set FIB address at standard output
	DB 18h,( L5B4F)-$-1

L5B20:   DB 21h
	DW _L149B               ; LIB
         DB 0cdh
	DW  O_CALHL               ; set FIB address at standard output

L5B26:   DB 3eh,0FFH
         DB 32h
	DW DEF_TYPE            ; default type = SMART
         DB 1eh,0                     ; no sign
         DB 0cdh
	DW  L6A5C                 ; parse unsigned-constant
         DB 20h,(L5B4C)-$-1                ; jump if no constant parsed

         DB 78h
	DB 0feh, 8
	DB 20h,(L5B47)-$-1
	DB 0ddh,7eh,+0
         DB 0feh, ','
	DB 28h,(L5B3B)-$-1
         DB 0feh, ')'
	DB 20h,(L5B47)-$-1

L5B3B:	DB 21h
	DW _L17BA		; LIB
	DB 0cdh
	DW  O_CALHL
         DB 0cdh
	DW  L6B5E                 ; output length (C) and data at L7A57
	DB 0c3h
	DW  L5BC9

L5B47:   DB 0cdh
	DW  L6201
	DB 18h,( L5B4F)-$-1

L5B4C:
         DB 3eh,0FFH                  ; default type = smart
         DB 0cdh
	DW  L5EE8                 ; parse expression

L5B4F:   DB 78h
;         CP 0EH                     ; type = LONGINT ?
;         JR Z,L5B5C

         DB 0feh, 8
	DB 38h,(L5B58)-$-1

         DB 0feh, 0EH+1
	DB 38h,(L5B5C)-$-1

L5B58:	DB 0cdh
	DW  L72E1		; no condition
	DB 42H			; error 66: I/O are not allowed

L5B5C:   DB 0feh, 0CH                     ; type = CHAR ?
         DB 20h,(L5B6A)-$-1                ; jump if not

         ; type = CHAR
         DB 0cdh
	DW  L6F0B                 ; match(':'), if present
	DB 20h,(L5BA6)-$-1		; jump if ':' not matched

         DB 0cdh
	DW  L5EDD                 ; code to push CHAR as STRING
	DB 18h,( L5B72)-$-1

L5B6A:   DB 0cdh
	DW  L6148                 ; generate code to push REAL, INTEGER,
                                    ; BOOLEAN, CHAR, POINTER or LONGINT
                                    ; on the stack
	DB 0cdh
	DW  L6F0B		; match(':'), if present
	DB 20h,(L5B8B)-$-1		; jump if ':' not matched

L5B72:   ; ':' parsed, size number expected
         DB 0c5h                    ; save type of expression before ':'

         DB 0cdh
	DW  L5E97                 ; parse integer expression

         DB 0c1h
	DB 78h
         DB 0feh, 9                       ; type REAL ?
         DB 20h,(L5BA6)-$-1                ; jump if not

         ; type = REAL
         ; second ':', number of digits after '.'
         DB 0cdh
	DW  L6F0B                 ; match(':'), if present
	DB 20h,(L5B9D)-$-1		; jump if ':' not matched

         ; second ':' parsed
         DB 0c5h
         DB 0cdh
	DW  O_PSHHL               ; code: push size on stack

         DB 0cdh
	DW  L5E97                 ; parse integer expression

         DB 0c1h
	DB 18h,( L5BA6)-$-1

L5B8B:   ; <expression>
         DB 21h
	DW 0000
	DB 78h
	DB 0feh, 9
	DB 20h,(L5B95)-$-1

         ; type = REAL
         DB 2eh,12H                   ; default for first ':'

L5B95:   DB 0cdh
	DW  O_LDHL
	DB 78h
	DB 0feh, 9
	DB 20h,(L5BA6)-$-1

L5B9D:   ; type = REAL
         DB 0cdh
	DW  O_PSHHL
	DB 21h
	DW -1
	DB 0cdh
	DW  O_LDHL

L5BA6:	DB 78h
         DB 21h
	DW WRITETYPESTABLE - 8*2
         DB 0cdh
	DW  TABLEINDEX2

         DB 0cdh
	DW  O_CALHL

L5BC9:   DB 0cdh
	DW  L6F13                 ; match(','), if present
	DB 0cah
	DW L5B26		; jump if ',' matched
	DB 0cdh
	DW  L6F6E		; match(')')

L5BD2:   DB 21h
	DW _L17CD               ; LIB, print CR LF codes
         DB 0c3h
	DW  L5AB7

WRITETYPESTABLE:
         DW _L17AA                  ; 08, write STRING
         DW _L1779                  ; 09, write REAL
         DW _L1726                  ; 0A, write INTEGER
         DW _L178B                  ; 0B, write BOOLEAN
         DW _L1722                  ; 0C, write CHAR
         DW 0                       ; 0D, write .., reserved for BYTE
         DW _PRT_LONG               ; 0E, write LONGINT

L5BD8:   DB 21h
	DW _L18B6               ; LIB, read from typed file
	DB 18h,( L5BE0)-$-1

L5BDD:   DB 21h
	DW _L18DC               ; LIB, write to typed file

L5BE0:   DB 22h
	DW L7BA7
	DB 3ah
	DW L7BA3
	DB 0b7h

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 23H			; error 35: Textfile expected

         DB 21h
	DW _L18A4               ; LIB, save FIB address and check
                                    ; if the file is open
	DB 0cdh
	DW  O_CALHL

         DB 02ah
	DW L7B5E
	DB 0cdh
	DW  L5271

L5BF7:	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 20h,(L5C10)-$-1		; jump if ',' not matched

	DB 0cdh
	DW  L6D24		; push 13, L7B64
         DB 0cdh
	DW  L677F                 ; parse var parameter
	DB 0cdh
	DW  L6D43		; pop 13, L7B64

         DB 0cdh
	DW  L58C5                 ; perform type checking
	DB 02ah
	DW L7BA7
	DB 0cdh
	DW  O_CALHL
	DB 18h,( L5BF7)-$-1

L5C10:	DB 0cdh
	DW  L6F6E		; match(')')
	DB 0c3h
	DW  L5ABE

L5C16:   ; PROCEDURE BlockRead(VAR F: FILE; VAR Dest: Type;
         ;                     Num: INTEGER [; VAR Result: INTEGER]);
         DB 21h
	DW _L1AF1               ; LIB, with result
         DB 11h
	DW _L1ABE               ; LIB, without result
	DB 18h,( L5C24)-$-1

L5C1E:   ; PROCEDURE BlockWrite(VAR F: FILE; VAR Dest: Type;
         ;                      Num: INTEGER [; VAR Result: INTEGER]);
         DB 21h
	DW _L1AED               ; LIB, with result
         DB 11h
	DW _L1ABA               ; LIB, without result

L5C24:	DB 0e5h
	DB 0d5h
         DB 0cdh
	DW  L5A0C                 ; parse '(' and file parameter
	DB 0feh, 7			; untyped file ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 25H			; error 37: Untyped file expected

         DB 0cdh
	DW  O_PSHHL               ; push address FIB
         DB 0cdh
	DW  L6F5E                 ; match(',')

         DB 0cdh
	DW  L677F                 ; parse VAR parameter
         DB 0cdh
	DW  O_PSHHL               ; push address of untyped variable
         DB 0cdh
	DW  L6F5E                 ; match(',')

         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0cdh
	DW  L6F13		; match(','), if present

	DB 0d1h
	DB 0e1h
         DB 28h,(L5C4B)-$-1                 ; jump if ',' matched = 'result' parameter

         DB 0d5h                    ; address LIB routine without result
	DB 18h,( L5C63)-$-1

L5C4B:   DB 0e5h                    ; address LIB routine with result

         DB 0cdh
	DW  O_PSHHL               ; push Num parameter on stack

;         CALL ParseIntVar           ; parse VAR integer parameter
         DB 0cdh
	DW  L677F                 ; parse VAR parameter

         DB 3ah
	DW L7B5C
         DB 0feh, 0AH                     ; type = integer ?
         DB 20h,(L5C5F)-$-1                ; jump if not integer

         DB 3ah
	DW L7B62               ; A = sizeof var parameter (BYTE/INTEGER)
         DB 3dh
         DB 20h,(L5C63)-$-1                ; jump if size = 2 --> real INTEGER

L5C5F:   DB 0cdh
	DW  L72E1                 ; no condition
         DB 18H                     ; error 24: Integer variable expected

L5C63:
         DB 0c3h
	DW  L5985

L5C66:   ; PROCEDURE Delete(VAR S: STRING; Pos, Len: INTEGER);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5CAD                 ; parse VAR string variable
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 21h
	DW _L08F3		; LIB
L5C81:   DB 0cdh
	DW  L6F6E                 ; match(')')
	DB 0c3h
	DW  O_CALHL

L5C87:	; PROCEDURE Insert(S: STRING; VAR D: STRING; Pos: INTEGER);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5CAD                 ; parse VAR string variable
	DB 0cdh
	DW  O_PSHHL
	DB 3ah
	DW L7B62
	DB 3dh
	DB 67h
	DB 2eh,6
	DB 0e5h
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0e1h
	DB 0cdh
	DW  O_HL
	DB 21h
	DW _L0920		; LIB
	DB 18h,( L5C81)-$-1

L5CBA:   ; PROCEDURE Str(I: INTEGER; VAR S: STRING);
         ; PROCEDURE Str(L: LONGINT; VAR S: STRING);
         ; PROCEDURE Str(R: REAL; VAR S: STRING);
         ; (INTEGER [: INTEGER],
         ; (LONGINT [: INTEGER],
         ; (REAL [: INTEGER [: INTEGER] ],
	DB 0cdh
	DW  L6F66		; match('(')
         DB 3eh,0FFH                  ; A = default type = smart
         DB 0cdh
	DW  L5EA2                 ; parse integer, longint or real expression
         DB 0cdh
	DW  L6148                 ; generate code to push REAL, INTEGER,
                                    ; BOOLEAN, CHAR or POINTER on the stack
	DB 0cdh
	DW  L6F0B		; match(':'), if present
	DB 20h,(L5CE4)-$-1		; jump if ':' not matched

         DB 0c5h                    ; save type of expression

         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0cdh
	DW  O_PSHHL

         DB 0c1h                     ; B = type of expression

         DB 78h
	DB 0feh, 00AH
         DB 28h,(L5D02)-$-1                 ; INTEGER has no second ':'
         DB 0feh, 00EH
         DB 28h,(L5D02)-$-1                 ; LONGINT has no second ':'

	DB 0cdh
	DW  L6F0B		; match(':'), if present
	DB 20h,(L5CF9)-$-1		; jump if ':' not matched

	DB 0c5h
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0cdh
	DW  O_PSHHL
	DB 0c1h
	DB 18h,( L5D02)-$-1

L5CE4:   ; (INTEGER
         ; (LONGINT
         ; (REAL
         DB 21h
	DW 0                    ; assume ': 0' for an integer or longint
	DB 78h
         DB 0feh, 00AH                    ; integer ?
	DB 28h,(L5CEE)-$-1
         DB 0feh, 00EH
         DB 28h,(L5CEE)-$-1                 ; longint ?

         DB 2eh,012H                  ; default ': 18' for a real

L5CEE:   DB 0cdh
	DW  O_LDHL
	DB 0cdh
	DW  O_PSHHL
	DB 78h
         DB 0feh, 00AH                    ; integer ?
         DB 28h,(L5D02)-$-1                 ; an integer does not have a second ': x'
         DB 0feh, 00EH                    ; longint ?
         DB 28h,(L5D02)-$-1                 ; a longint does not have a second ': x'

L5CF9:   DB 21h
	DW -1                   ; default second ': -1' for real
	DB 0cdh
	DW  O_LDHL
	DB 0cdh
	DW  O_PSHHL

L5D02:   DB 0cdh
	DW  L6F5E                 ; match(',')

         DB 0c5h

         DB 0cdh
	DW  L5CAD                 ; parse VAR string variable
	DB 3ah
	DW L7B62
	DB 3dh
	DB 67h
	DB 2eh,6
         DB 0cdh
	DW  O_HL                  ; output: LD B,length of string variable

         DB 0c1h                     ; B = type of first expression

         DB 21h
	DW _L1EBE               ; LIB, print INTEGER
	DB 78h
	DB 0feh, 00AH
	DB 28h,(L5D1F)-$-1

         DB 21h
	DW _L1EBC               ; LIB, print LONGINT
         DB 0feh, 00EH
         DB 28h,(L5D1F)-$-1

         DB 21h
	DW _L1EBD               ; LIB, print REAL
L5D1F:	DB 0c3h
	DW  L5C81

L5D22:   ; PROCEDURE Val(S: STRING; VAR R: REAL; VAR P: INTEGER);
         ; PROCEDURE Val(S: STRING; VAR L: LONGINT; P: INTEGER);
	; PROCEDURE Val(S: STRING; VAR I,P: INTEGER);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
	DB 3ah
	DW L7B5C

         DB 0feh, 9                       ; type = REAL ?
         DB 28h,(L5D45)-$-1                 ; jump if type = REAL

         DB 0feh, 00EH                    ; type = LONGINT ?
         DB 28h,(L5D45)-$-1                 ; jump if type = LONGINT

         DB 0feh, 00AH                    ; type = INTEGER ?
         DB 20h,(L5D41)-$-1                ; jump if not

         DB 3ah
	DW L7B62
	DB 3dh
	DB 3eh,00AH
	DB 20h,(L5D45)-$-1

L5D41:   DB 0cdh
	DW  L72E1                 ; no condition
         DB 1BH                     ; error 27: Integer, longint or
                                    ; real variable expected

L5D45:   DB 0f5h
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
	DB 3ah
	DW L7B5C
         DB 0feh, 00AH                    ; type = integer ?
	DB 20h,(L5D5C)-$-1		; jump if type <> integer

	DB 3ah
	DW L7B62
	DB 3dh
	DB 20h,(L5D60)-$-1

L5D5C:   DB 0cdh
	DW  L72E1                 ; no condition
	DB 18H			; error 24: Integer variable expected

L5D60:   DB 0f1h                     ; A = type
	DB 21h
	DW _L1EF4		; LIB, val(string,integer,integer)
         DB 0feh, 00AH                    ; type = INTEGER ?
	DB 28h,(L5D1F)-$-1

         DB 21h
	DW _L1EF2               ; LIB, val(string,longint,integer)
         DB 0feh, 00EH                    ; type = LONGINT ?
         DB 28h,(L5D1F)-$-1

         DB 21h
	DW _L1EF3               ; LIB, val(string,real,integer)
	DB 18h,( L5D1F)-$-1

L5D6D:   ; PROCEDURE GotoXY(X, Y: INTEGER);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 21h
	DW _L1FDB		; LIB
         DB 0c3h
	DW  L5D76

L5D83:   ; PROCEDURE Randomize;
	DB 21h
	DW _L1F48		; LIB
	DB 0c3h
	DW  O_CALHL

L5D89:   ; PROCEDURE Delay(mS: INTEGER);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 21h
	DW _L021D		; LIB
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5E05:   ; PROCEDURE Move(VAR Source,Dest: TYPE; Length: INTEGER);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
	DB 21h
	DW _L1F64		; LIB, clear
	DB 0c3h
	DW  L5D76

L5E1A:   ; PROCEDURE FillChar(var Dest; Length: INTEGER; Data: CHAR);
	; PROCEDURE FillChar(var Dest; Length: INTEGER; Data: BYTE);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 3eh,0AH                   ; A = default type = INTEGER
         DB 0cdh
	DW  L5EBB                 ; parse simple expression
	DB 21h
	DW _L1F4E		; LIB, clear
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5D94:   ; PROCEDURE GetMem(VAR P: POINTER; I: INTEGER);
         DB 0cdh
	DW  L5DE3                 ; parse '(', VAR pointer and O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 18h,( L5DAE)-$-1

L5D9F:	; PROCEDURE New(VAR P: POINTER);
         DB 0cdh
	DW  L5DE3                 ; parse '(', VAR pointer and O_PSHHL
	DB 02ah
	DW L7B5E
	DB 0cdh
	DW  L5271
	DB 02ah
	DW L7B6F
	DB 0cdh
	DW  O_LDHL

L5DAE:	DB 21h
	DW _L1CE5		; LIB, clear
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5DB4:	; PROCEDURE FreeMem(VAR P: POINTER; I: INTEGER);
         DB 0cdh
	DW  L5DE3                 ; parse '(', VAR pointer and O_PSHHL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 18h,( L5DCE)-$-1

L5DBF:	; PROCEDURE Dispose(VAR P: POINTER);
         DB 0cdh
	DW  L5DE3                 ; parse '(', VAR pointer and O_PSHHL
	DB 02ah
	DW L7B5E
	DB 0cdh
	DW  L5271
	DB 02ah
	DW L7B6F
	DB 0cdh
	DW  O_LDHL

L5DCE:	DB 21h
	DW _L1D7A		; LIB, clear
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5DD4:	; PROCEDURE Mark(VAR P: POINTER);
	DB 21h
	DW _L1EA3		; LIB, clear
	DB 18h,( L5DDC)-$-1

L5DD9:	; PROCEDURE Release(VAR P: POINTER);
	DB 21h
	DW _L1EAB		; LIB, clear

L5DDC:   DB 0e5h
         DB 0cdh
	DW  L5DE9                 ; parse '(' and VAR pointer
	DB 0e1h
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5DE3:   ; parses a '(', VAR pointer and O_PSHHL
         DB 0cdh
	DW  L5DE9                 ; parse '(' and VAR pointer

	DB 0c3h
	DW  O_PSHHL

L5DE9:   ; parses a '(' and VAR pointer
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
	DB 3ah
	DW L7B5C
         DB 0feh, 4                       ; pointer variable parsed ?
         DB 0c8h                      ; return if yes

	DB 0cdh
	DW  L72E1		; no condition
	DB 1CH			; error 28: Pointer variable expected

L5DF9:   ; PROCEDURE OvrDrive(Drive: INTEGER);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 21h
	DW _L1CDB		; LIB, clear
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

L5E38:   ; PROCEDURE CrtInit;
	DB 21h
	DW _L030A		; LIB, done
         DB 18h,( L5E45)-$-1                   ; CALL HL

L5E3D:	; PROCEDURE CrtExit;
	DB 21h
	DW _L0310		; LIB, done
         DB 18h,( L5E45)-$-1                   ; CALL HL

L5E42:	; PROCEDURE ClrScr;
	DB 21h
	DW _L023E		; LIB, done

L5E45:   DB 0c3h
	DW  O_CALHL

L5E48:	; PROCEDURE ClrEol;
	DB 21h
	DW _L0299		; LIB, done
         DB 18h,( L5E45)-$-1                   ; CALL HL

L5E4D:	; PROCEDURE NormVideo;
	; PROCEDURE HighVideo;
	DB 21h
	DW _L0284		; LIB, done
         DB 18h,( L5E45)-$-1                   ; CALL HL

L5E52:	; PROCEDURE LowVideo;
	DB 21h
	DW _L026B		; LIB, done
         DB 18h,( L5E45)-$-1                   ; CALL HL

L5E57:	; PROCEDURE InsLine;
	DB 21h
	DW _L0262		; LIB, done
         DB 18h,( L5E45)-$-1                   ; CALL HL

L5E5C:	; PROCEDURE DelLine;
         DB 21h
	DW _L0259               ; LIB, done
         DB 18h,( L5E45)-$-1                   ; CALL HL

P_ERROREXIT:
         ; PROCEDURE ErrorExit;

         DB 0cdh
	DW  L6F1B                 ; match('('), if present
         DB 20h,(P_ERROREXIT1)-$-1         ; jump if '(' not matched

         DB 0cdh
	DW  L5EA2                 ; parse integer, longint or real expression

         DB 0cdh
	DW  L6F6E                 ; match(')')

P_ERROREXIT1:
         DB 21h
	DW _ERROREXIT
         DB 0c3h
	DW  O_CALHL

L5E61:   ; PROCEDURE Exit;
         DB 11h
	DW 0000                 ;
         DB 0c3h
	DW  L5639

L5E67:	; PROCEDURE Halt;
	DB 21h
	DW _L20D4		; LIB, done
	DB 0c3h
	DW  O_JPHL

L5E6D:   ; PROCEDURE Port(Port: INTEGER);
         DB 0cdh
	DW  L5E8E                 ; parse array index, ':=', integer expr.

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 0C1H			; POP BC
	DB 0EDH,69H		; OUT (C),L

	DB 0c9h

L5E78:   ; StackPtr:= INTEGER;
	DB 0cdh
	DW  L6F7E		; match(':=')
         DB 0cdh
	DW  L5E97                 ; parse integer expression

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 0F9H			; LD SP,HL

	DB 0c9h

L6360:   ; FUNCTION Sqr(I: INTEGER): INTEGER;
         ; FUNCTION Sqr(L: LONGINT): LONGINT;
	; FUNCTION Sqr(R: REAL): REAL;
         DB 0cdh
	DW  L65E7                 ; parse integer, longint or real expression

	DB 21h
	DW _L06F3		; LIB, Sqr(I: INTEGER): INTEGER;
	DB 78h
         DB 0feh, 00AH                    ; type = INTEGER ?
         DB 28h,(L636E)-$-1                 ; jump if type = INTEGER

         DB 21h
	DW _L_SQR
         DB 0feh, 00EH                    ; type = LONGINT ?
         DB 28h,(L636E)-$-1                 ; jump if type = LONGINT

	DB 21h
	DW _L09F7		; LIB, Sqr(R: REAL): REAL;

L636E:	DB 0c3h
	DW  O_CALHL

L6371:   ; FUNCTION Abs(I: INTEGER): INTEGER;
	; FUNCTION Abs(R: REAL): REAL;
         ; FUNCTION Abs(L: LONGINT): LONGINT;
         DB 0cdh
	DW  L65E7                 ; parse integer, longint or real expression
	DB 78h
         DB 0feh, 00AH                    ; type = INTEGER ?
	DB 28h,(L6380)-$-1

         DB 0feh, 00EH                    ; type = LONGINT ?
         DB 28h,(L63801)-$-1

         ; code for REAL
	DB 0cdh
	DW  O_CODE
	DB 2
	DB 0CBH,0B8H		; RES 7,B

	DB 0c9h

L6380:	; FUNCTION Abs(I: INTEGER): INTEGER;
	DB 21h
	DW _L0780		; LIB, absolute HL, done
	DB 18h,( L63CF)-$-1

L63801:  ; FUNCTION Abs(L: LONGINT): LONGINT;
         DB 21h
	DW _L_ABS
         DB 06h,0EH                   ; return type = LONGINT
         DB 0c3h
	DW  O_CALHL

L6385:   ; FUNCTION Sqrt(R: REAL): REAL;
	DB 21h
	DW _L0C46		; LIB, clear
         DB 18h,( L63AB)-$-1

L638A:   ; FUNCTION Sin(R: REAL): REAL;
	DB 21h
	DW _L0C87		; LIB, clear
	DB 18h,( L63AB)-$-1

L638F:   ; FUNCTION Cos(R: REAL): REAL;
	DB 21h
	DW _L0C7F		; LIB, clear
	DB 18h,( L63AB)-$-1

L6394:   ; FUNCTION ArcTan(R: REAL): REAL;
	DB 21h
	DW _L0E46		; LIB, clear
	DB 18h,( L63AB)-$-1

L6399:   ; FUNCTION Ln(R: REAL): REAL;
	DB 21h
	DW _L0D2B		; LIB, clear
	DB 18h,( L63AB)-$-1

L639E:   ; FUNCTION Exp(R: REAL): REAL;
	DB 21h
	DW _L0DB6		; LIB, clear
	DB 18h,( L63AB)-$-1

L63A3:   ; FUNCTION Int(R: REAL): REAL;
	DB 21h
	DW _L0BFD		; LIB, clear
	DB 18h,( L63AB)-$-1

L63A8:   ; FUNCTION Frac(R: REAL): REAL;
	DB 21h
	DW _L0C34		; LIB, clear

L63AB:	DB 0e5h
         DB 0cdh
	DW  L65E7                 ; parse integer, longint or real expression

	DB 78h
         DB 0feh, 009H                    ; type = REAL ?
         DB 28h,(L63AD)-$-1                 ; jump if type = REAL

	DB 21h
	DW _L1008		; LIB, convert integer HL to float HLDEBC
         DB 0feh, 00AH                    ; type = INTEGER ?
         DB 28h,(L63AC)-$-1                 ; jump if type = INTEGER

         DB 21h
	DW _L_R                 ; LONGINT to REAL conversion

L63AC:   DB 0cdh
	DW  O_CALHL

L63AD:
	DB 0e1h
	DB 06h,9
	DB 0c3h
	DW  O_CALHL

L63BE:   ; FUNCTION Trunc(R: REAL): INTEGER;
	DB 21h
	DW _L0FDE		; LIB, float HLDEBC to int HL, clear
	DB 18h,( L63C6)-$-1

L63C3:   ; FUNCTION Round(R: REAL): INTEGER;
	DB 21h
	DW _L0FD0		; LIB, clear

L63C6:   DB 0e5h
         DB 0cdh
	DW  L65E7                 ; parse integer, longint or real expression
	DB 0e1h
	DB 78h
	DB 0feh, 00AH			; integer ?
         DB 0c8h                      ; yes, return

         DB 0feh, 00EH                    ; longint ?
         DB 0c8h                      ; yes, return

L63CF:	DB 06h,00AH
	DB 0c3h
	DW  O_CALHL

L63D4:   ; FUNCTION Succ(X: SCALAR): SCALAR;
         DB 3eh,0FFH                  ; type = smart
         DB 0cdh
	DW  L65EF                 ; match('('), simple expression, match(')')

         DB 78h
         DB 0feh, 0EH                     ; type = LONGINT ?
         DB 20h,(L63D5)-$-1                ; jump if not

         DB 21h
	DW _L_SUCC
         DB 0c3h
	DW  O_CALHL

L63D5:
         DB 3eh,023H                  ; opcode: INC HL
         DB 0c3h
	DW  O_BYTE

L63D7:   ; FUNCTION Pred(X: SCALAR) : SCALAR;
         DB 3eh,0FFH                  ; type = smart
         DB 0cdh
	DW  L65EF                 ; match('('), simple expression, match(')')

         DB 78h
         DB 0feh, 0EH                     ; type = LONGINT ?
         DB 20h,(L63D8)-$-1                ; jump if not

         DB 21h
	DW _L_PRED
         DB 0c3h
	DW  O_CALHL

L63D8:
         DB 3eh,2BH                   ; opcode: DEC HL
	DB 0c3h
	DW  O_BYTE

L63E1:   ; FUNCTION Low(I: INTEGER): INTEGER;
         ; FUNCTION Low(L: LONGINT): INTEGER;
         DB 3eh,0FFH                  ; type = smart
         DB 0cdh
	DW  PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         DB 78h
         DB 0feh, 0EH                     ; type = LONGINT ?

         DB 20h,(L63E2)-$-1                ; jump if not LONGINT

         DB 06h,0AH                   ; no code generation
                                    ; return type = INTEGER
         DB 0c9h

L63E2:
         DB 0cdh
	DW  O_CODE
	DB 2
	DB 26H,00H		; LD H,0

         ; return same type
         DB 0c9h

L63EB:	; FUNCTION Hi(I: INTEGER): INTEGER;
         ; FUNCTION Hi(L: LONGINT): INTEGER;
         DB 3eh,0FFH                  ; type = smart
         DB 0cdh
	DW  PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         DB 78h
         DB 0feh, 0EH                     ; type = LONGINT ?

         DB 20h,(L63EC)-$-1                ; jump if not LONGINT

         DB 06h,0AH                   ; return type = INTEGER
         DB 3eh,0EBH                  ; opcode: EX DE,HL
         DB 0c3h
	DW  O_BYTE

L63EC:
	DB 0cdh
	DW  O_CODE
	DB 3
	DB 6CH			; LD L,H
	DB 26H,00H		; LD H,0

         ; return same type
	DB 0c9h

L63F6:	; FUNCTION Swap(I: INTEGER): INTEGER;
         DB 3eh,0FFH                  ; type = smart
         DB 0cdh
	DW  PARSE_O_IL_C

         DB 78h
         DB 0feh, 0EH                     ; type = LONGINT ?

         DB 20h,(L63F7)-$-1                ; jump if not LONGINT

         DB 3eh,0EBH                  ; opcode: EX DE,HL
         DB 0c3h
	DW  O_BYTE                  ; output code and return same type

L63F7:
	DB 0cdh
	DW  O_CODE
	DB 3
	DB 7DH			; LD A,L
	DB 6CH			; LD L,H
	DB 67H			; LD H,A

	DB 0c9h

L6401:   ; FUNCTION Odd(I: INTEGER): BOOLEAN;
         DB 3eh,0FFH                  ; type = smart
         DB 0cdh
	DW  PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         DB 21h
	DW _L078B               ; LIB, make integer HL a boolean, clear

L6407:   DB 06h,00BH
         DB 0c3h
	DW  O_CALHL

L640C:   ; FUNCTION KeyPressed: BOOLEAN;
         DB 21h
	DW _CONSTPTR            ; LIB
	DB 18h,( L6407)-$-1

L6411:   ; Function Ord(X: SCALAR): INTEGER;
	DB 0cdh
	DW  L6F66		; match('(')
         DB 3eh,0AH                   ; A = default type = INTEGER
         DB 0cdh
	DW  L5EE8                 ; parse expression
	DB 0cdh
	DW  L6F6E		; match(')')
	DB 78h
         DB 0feh, 4                       ; POINTER type ?
         DB 28h,(L6422)-$-1                 ; jump if POINTER type

         DB 0cdh
	DW  L5EBE                 ; check for a simple type expression

L6422:   DB 06h,00AH
	DB 0c9h

L6425:   ; FUNCTION Chr(I: INTEGER): CHAR;
         ; FUNCTION Chr(L: LONGINT): CHAR;
         DB 3eh,0FFH                  ; type = smart
         DB 0cdh
	DW  PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

	DB 06h,00CH
	DB 0c9h

L642B:   ; Function Ptr(I: INTEGER): POINTER;
         DB 0cdh
	DW  PARSE_O_IL_C
;         CALL L65DE                 ; parse '(', integer expression and ')'

         DB 21h
	DW 0000
	DB 22h
	DW L7B8B
         DB 06h,4                     ; return POINTER type
	DB 0c9h

L6437:   ; FUNCTION UpCase(Ch: CHAR): CHAR;
         DB 3eh,0CH                   ; A = default expression = CHARC
	DB 0cdh
	DW  L65EF
	DB 06h,00CH
	DB 21h
	DW _L1FE4		; LIB, clear
         DB 0c3h
	DW  O_CALHL

L6441:   ; FUNCTION Length(S: STRING): INTEGER;
	DB 0cdh
	DW  L6F66		; match('(')
	DB 21h
	DW _L08A3		; LIB, clear

L6447:   DB 0e5h
         DB 0cdh
	DW  L5ED0                 ; parse string expression
	DB 0cdh
	DW  L6F6E		; match(')')
	DB 0e1h
	DB 0c3h
	DW  L63CF

L6452:   ; FUNCTION Pos(Pattern, Source: STRING): INTEGER;
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
         DB 0cdh
	DW  L6F5E                 ; match(',')
	DB 21h
	DW _L08B2		; LIB, clear
	DB 18h,( L6447)-$-1

L6460:   ; FUNCTION Copy(S: STRING; Pos, Len: INTEGER): STRING;
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0cdh
	DW  L6F5E                 ; match(',')
	DB 0cdh
	DW  O_PSHHL
         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0cdh
	DW  L6F6E		; match(')')
	DB 21h
	DW _L086B		; LIB, clear
	DB 0cdh
	DW  O_CALHL

L647E:	DB 06h,8
	DB 0c9h

L6481:   ; FUNCTION Concat(S1,S2,...,Sn: STRING);
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
L6487:	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 20h,(L6497)-$-1		; jump if ',' not matched
         DB 0cdh
	DW  L5ED0                 ; parse string expression
	DB 21h
	DW _L083D		; LIB, clear
	DB 0cdh
	DW  O_CALHL
	DB 18h,( L6487)-$-1

L6497:	DB 0cdh
	DW  L6F6E		; match(')')
	DB 18h,( L647E)-$-1

L649C:   ; FUNCTION ParamCount: INTEGER;
	DB 21h
	DW _L1F9B		; LIB, clear
	DB 18h,( L64BF)-$-1

L64A1:   ; FUNCTION ParamStr(N: INTEGER): STRING;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'

	DB 21h
	DW _L1F7D		; LIB, clear
	DB 06h,8
	DB 0c3h
	DW  O_CALHL

L64AC:   ; FUNCTION Random(Range: INTEGER): INTEGER;
	; FUNCTION Random: REAL;
	DB 0cdh
	DW  L6F1B		; match('('), if present
	DB 21h
	DW _L0FB4		; LIB, clear
	DB 06h,9			; assume REAL type
	DB 20h,(L64C1)-$-1		; jump if '(' not matched

         DB 0cdh
	DW  L5E97                 ; parse integer expression
	DB 0cdh
	DW  L6F6E		; match(')')
	DB 21h
	DW _L073B		; LIB, clear

L64BF:	DB 06h,00AH		; INTEGER type

L64C1:	DB 0c3h
	DW  O_CALHL

L64C4:   ; FUNCTION IOresult: BYTE (BOOLEAN in manual ?)
	DB 21h
	DW _L1FF1		; LIB, clear
	DB 18h,( L64BF)-$-1

L64C9:   ; FUNCTION Eof(VAR F: FILE): BOOLEAN;
	DB 0cdh
	DW  L65F7

	DB 21h
	DW L6615		; table of three file types
	DB 0cdh
	DW  L59E9		; generate call for file IO
L64D2:   DB 06h,00BH                  ; returns BOOLEAN type
	DB 0c9h

L6615:   DW _L1A49                  ; LIB, Eof, typed file,   type 5
         DW _L17E6                  ; LIB, Eof, text,         type 6
	DW _L1A49		; LIB, Eof, untyped file, type 7

L64D5:   ; FUNCTION SeekEof(VAR F: TEXT): BOOLEAN;
	DB 21h
	DW _L17E1		; LIB, clear
	DB 18h,( L64E2)-$-1

L64DA:   ; FUNCTION SeekEoln(VAR F: TEXT): BOOLEAN;
	DB 21h
	DW _L17D7		; LIB, clear
	DB 18h,( L64E2)-$-1

L64DF:   ; FUNCTION Eoln(VAR F: TEXT): BOOLEAN;
	DB 21h
	DW _L17DC		; LIB, clear

L64E2:	DB 0e5h
	DB 0cdh
	DW  L65F7

	DB 0feh, 6			; text file ?

	DB 0cdh
	DW  L72DA		; NonZero --> error
	DB 23H			; error 35: Textfile expected

	DB 0e1h
	DB 0cdh
	DW  O_CALHL
	DB 18h,( L64D2)-$-1

L64F2:   ; FUNCTION FilePos(VAR F: FILE OF TYPE): INTEGER;
	; FUNCTION FilePos(VAR F: FILE): INTEGER;
	DB 21h
	DW _L1A55		; LIB, clear
	DB 11h
	DW _L1A55		; LIB, clear
         DB 18h,( L6500)-$-1

L64FA:   ; FUNCTION FileSize(VAR F: FILE OF TYPE): INTEGER;
	; FUNCTION FileSize(var F: FILE): INTEGER;
	DB 21h
	DW _L1A5D		; LIB, clear
	DB 11h
	DW _L1A5D		; LIB, clear

L6500:	DB 0e5h
	DB 0d5h
         DB 0cdh
	DW  L65F7
	DB 0d1h
	DB 0e1h
	DB 0feh, 6			; text file ?

	DB 0cdh
	DW  L72D4		; Zero --> error
	DB 3FH			; error 63: Textfiles are not allowed here

	DB 0feh, 5			; typed file ?
         DB 28h,(L7FA9)-$-1 ; 33e,L 64BF                 ; jump if typed file
	DB 0ebh
         DB 18h,( L7FA9)-$-1 ; 33e, L64BF

; 33e
L7FA9:
         DB 06h,0EH                   ; LONGINT type
         DB 0c3h
	DW  O_CALHL
; 33e

L6514:   ; FUNCTION MemAvail: INTEGER;
	DB 21h
	DW _L1E3D		; LIB, clear
	DB 18h,( L64BF)-$-1

L6519:   ; FUNCTION MaxAvail: INTEGER;
	DB 21h
	DW _L1E44		; LIB, clear
	DB 18h,( L64BF)-$-1

L651E:   ; PROCEDURE Bios(Func,Param: INTEGER);
	DB 3eh,0AFH		; LD A,XOR A
	DB 18h,( L6520)-$-1

L651F:	; FUNCTION Bios(Func,Param: INTEGER): BYTE;
	DB 0afh
L6520:	DB 0f5h			; save flag for FUNCTION/PROCEDURE
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression

	DB 0cdh
	DW  O_PSHHL		; push Func

	DB 0cdh
	DW  L6F13		; match(','), if present
         DB 20h,(L6538)-$-1                ; jump if ',' not matched

         DB 0cdh
	DW  L5E97                 ; parse integer expression

	; BC = Param
	DB 0cdh
	DW  O_CODE
	DB 2
	DB 44H			; LD B,H
	DB 4DH			; LD C,L

L6538:	DB 0cdh
	DW  O_CODE
	DB 1
	DB 0D1H			; POP DE, E = Func

	DB 21h
	DW _L1FEA		; LIB, clear
         DB 0c3h
	DW  L6540

L6553:   ; PROCEDURE Bdos(Func,Param: INTEGER);
	DB 3eh,0AFH		; LD A,XOR A
	DB 18h,( L6555)-$-1

L6554:	; FUNCTION Bdos(Func,Param: INTEGER): BYTE;
	DB 0afh
L6555:	DB 0f5h			; save flag for FUNCTION/PROCEDURE
	DB 0cdh
	DW  L6F66		; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression

	DB 0cdh
	DW  O_PSHHL		; push function number in L

	DB 0cdh
	DW  L6F13		; match(','), if present
	DB 20h,(L656C)-$-1		; jump if ',' not matched
         DB 0cdh
	DW  L5E97                 ; parse integer expression

	DB 0cdh
	DW  O_CODE
	DB 1
	DB 0EBH			; EX DE,HL

L656C:	DB 0cdh
	DW  O_CODE
	DB 1
	DB 0C1H			; POP BC, restore function number in C

	DB 21h
	DW 0005H
         DB 0c3h
	DW  L6540                   ; output: CALL 0005H

L6576:   ; FUNCTION ADDR(VAR Variable): INTEGER;
	DB 0cdh
	DW  L6F66		; match('(')
	DB 01h
	DW 500H
	DB 0cdh
	DW  L6E54		; check if current in id list
	DB 28h,(L6589)-$-1
	DB 01h
	DW 600H
	DB 0cdh
	DW  L6E54		; check if current in id list
	DB 20h,(L6594)-$-1

L6589:   DB 2bh
	DB 2bh
	DB 56h
	DB 2bh
	DB 5eh
	DB 0ebh

L658F:   DB 0cdh
	DW  O_LDHL
	DB 18h,( L6597)-$-1

L6594:   DB 0cdh
	DW  L677F                 ; parse var parameter
L6597:	DB 0cdh
	DW  L6F6E		; match(')')
	DB 06h,00AH
	DB 0c9h

L659D:	; FUNCTION SizeOf(VAR Variable): INTEGER;
	DB 0cdh
	DW  L6F66		; match('(')
	DB 01h
	DW 300H
	DB 0cdh
	DW  L6E54		; check if current in id list, types
	DB 20h,(L65B1)-$-1
	DB 56h
	DB 2bh
	DB 5eh
	DB 0ebh
	DB 0cdh
	DW  L5287		; 8 bytes from HL (down) to 7B5C (up)
	DB 18h,( L65BA)-$-1

L65B1:   DB 0fdh,0e5h
         DB 0cdh
	DW  L677F                 ; parse var parameter
	DB 0e1h
	DB 0cdh
	DW  L6CC2

L65BA:   DB 02ah
	DW L7B62              ; HL = size of variable
	DB 18h,( L658F)-$-1

L65BF:   ; FUNCTION Port(N: INTEGER): BYTE;
         DB 0cdh
	DW  L65D5                 ; parse an array index

	DB 0cdh
	DW  O_CODE
	DB 3
	DB 4DH			; LD C,L
	DB 0EDH,68H		; IN L,(C)

	DB 0c9h

L65CA:	; FUNCTION StackPtr: INTEGER
	; returns stackptr value

	DB 0cdh
	DW  O_CODE
	DB 4
	DB 21H,00H,00H		; LD HL,0000
	DB 39H			; ADD HL,SP

	DB 06h,00AH		; result = integer
	DB 0c9h

P_DOSERRORHANDLERON:
         DB 21h
	DW _DOSERRORHANDLERON
         DB 0c3h
	DW  O_CALHL

P_DOSERRORHANDLEROFF:
         DB 21h
	DW _DOSERRORHANDLEROFF
         DB 0c3h
	DW  O_CALHL

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

         END

