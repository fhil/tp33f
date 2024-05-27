IFNDEF MAKEPC
MSX:
ENDIF

IFDEF MSX
MSXDOS   EQU 5
ENDIF

         INCLUDE STDIO.INC

         INCLUDE LIBDEFS.INC

         INCLUDE LIBCONST.INC

         EXTRN L5960                ; match(')') and gen. 'CALL HL'
         EXTRN L5E97                ; parse integer expression
         EXTRN L5EB0                ; parse boolean expression
         EXTRN L5ED0                ; parse string expression
         EXTRN L5EE8                ; parse expression, B = expresson type res.
         EXTRN L65DE                ; parse '(', integer expression and ')'
         EXTRN L5CAD                ; parse VAR string variable
         EXTRN L6148                ; generates code to push a variable of
                                    ; type given in B
         EXTRN L677F                ; parse VAR parameter
         EXTRN L6F13                ; match(','), if present
         EXTRN L6F5E                ; match(',')
         EXTRN L6F66                ; match('(')
         EXTRN L6F6E                ; match(')')
         EXTRN OP_L_I               ; generate code to convert HL to
                                    ; LONGINT with sign extension
         PUBLIC PARSELONG

;         DB 'GIOS Library'

GENGIOS_BOOLEAN:
         ; generate GIOS CALL and return BOOLEAN type
         ; in:    A = entry
         DB 06h,0BH                   ; return BOOLEAN type

GENGIOS:
         DB 67h
         DB 2eh,3EH                   ; opcode: LD A,
         DB 0cdh
	DW  O_HL
         DB 21h
	DW _RUNGIOS
         DB 0c3h
	DW  O_CALHL

PARSEBYTEVAR:
         ; parses a VAR byte variable, not a VAR integer variable !!
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
         DB 0cdh
	DW  O_PSHHL
         DB 3ah
	DW L7B5C
         DB 0feh, 0AH                     ; type = integer ?
         DB 20h,(PARSEBYTEERROR)-$-1       ; jump if not integer

         DB 3ah
	DW L7B62               ; A = sizeof var parameter (BYTE/INTEGER)
         DB 3dh
         DB 0c8h                      ; return if size = 1

PARSEBYTEERROR:
         DB 0cdh
	DW  L72E1                 ; no condition
         DB 13H                     ; error 24: Byte variable expected

PARSEINTVAR:
         ; parses a VAR integer variable, not a VAR byte variable !!
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
         DB 0cdh
	DW  O_PSHHL
         DB 3ah
	DW L7B5C
         DB 0feh, 0AH                     ; type = integer ?
         DB 20h,(PARSEINTERROR)-$-1        ; jump if not integer

         DB 3ah
	DW L7B62               ; A = sizeof var parameter (BYTE/INTEGER)
         DB 3dh
         DB 0c0h                     ; return if size >= 2, can only be 2

PARSEINTERROR:
         DB 0cdh
	DW  L72E1                 ; no condition
         DB 18H                     ; error 24: Integer variable expected

PARSESTRVAR64:
         ; parses a VAR string variable of length 63 + 1
         DB 0cdh
	DW  L5CAD                 ; parse VAR string variable

PARSEVAR64_L:
         DB 3ah
	DW L7B62
         DB 0feh, 63 + 1                  ; STRING[63] ?
         DB 0c8h

TYPEMISMATCH:
         DB 0cdh
	DW  L72E1                 ; NonZero --> error
         DB 2CH                     ; error 44: Type mismatch

PARSEVAR64:
         ; parse a VAR parameter of length 64
         DB 0cdh
	DW  L677F                 ; parse VAR parameter
         DB 18h,( PARSEVAR64_L)-$-1

PARSELONG:
         ; parse a LONGINT and REAL with conversion to a LONGINT
         DB 3eh,0EH                   ; default type = LONGINT
         DB 0cdh
	DW  L5EE8                 ; parse expression
         DB 78h                     ; A = expression type

         DB 21h
	DW _R_L                 ; REAL to LONGINT conversion
         DB 0feh, 09H
         DB 28h,(PARSELONG1)-$-1            ; jump to convert REAL to LONG

         DB 0feh, 0EH
         DB 28h,(PARSELONG2)-$-1            ; jump if LONGINT

         DB 0feh, 0AH
         DB 28h,(PARSELONG3)-$-1            ; jump to convert INTEGER to LONG
                                    ; unsigned conversion

         DB 0c3h
	DW  TYPEMISMATCH

PARSELONG1:
         DB 0cdh
	DW  O_CALHL               ; generate conversion CALL

PARSELONG2:
         DB 06h,0Eh
         DB 0c9h                        ; 33e
;         JP L6148                   ; generate code to PUSH a LONGINT

PARSELONG3:
         DB 0c3h
	DW  OP_L_I                  ; 33e convert signed INTEGER TO LONGINT
;         CALL OP_L_I                ; convert signed INTEGER to LONGINT
;         JP L6148                   ; generate code to PUSH a LONGINT

PARSEREAL:
         ; parse an INTEGER, LONGINT and REAL with conversions to a REAL
         DB 3eh,0FFH                  ; default type = smart
         DB 0cdh
	DW  L5EE8                 ; parse expression
         DB 78h                     ; A = expression type

         DB 21h
	DW _L_R                 ; LONGINT to REAL conversion
         DB 0feh, 0EH                     ; type = LONGINT ?
         DB 28h,(PARSEREAL1)-$-1

         DB 21h
	DW _L1008               ; INTEGER to REAL conversion
         DB 0feh, 0AH                     ; type = INTEGER ?
         DB 28h,(PARSEREAL1)-$-1

         DB 0feh, 09H
         DB 28h,(PARSEREAL2)-$-1            ; jump if no conversion needed

         DB 0c3h
	DW  TYPEMISMATCH

PARSEREAL1:
         DB 0cdh
	DW  O_CALHL               ; generate conversion CALL

PARSEREAL2:
         DB 06h,9
         DB 0c3h
	DW  L6148                   ; generate code to PUSH a REAL

         ; --------------
         ; GIOS Functions
         ; --------------

F_TSRPRESENT:
         ; FUNCTION TsrPresent(Str: STRING): BOOLEAN;
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression
         DB 21h
	DW _TSRPRESENT          ; LIB entry
         DB 06h,0BH                   ; return boolean type
         DB 0c3h
	DW  L5960                   ; match(')'), CALL HL

F_GETCLIPPING:
         ; FUNCTION GetClipping: BOOLEAN;
         DB 3eh,56                    ; GetClipping entry
         DB 0c3h
	DW  GENGIOS_BOOLEAN

F_SIMULATEDDISK:
         ; FUNCTION SimulatedDisk(disk: BYTE): BOOLEAN;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,85                    ; SimulatedDisk entry
         DB 0c3h
	DW  GENGIOS_BOOLEAN         ; GIOS CALL and return BOOLEAN type

F_FINDFIRST:
         ; FUNCTION FindFirst(SearchPathAdres: STRING;
         ;                    VAR InfoBlock: Type[64]; { 64 bytes length }
         ;                    VAR Attributes: BYTE;
         ;                    VAR Name: STR63): BOOLEAN;
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5ED0                 ; parse string expression

         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 3eh,69
         DB 0f5h

F_FINDFIRST1:
         DB 0cdh
	DW  PARSEVAR64            ; parse VAR of 64 bytes length
         DB 0cdh
	DW  O_PSHHL               ; push address of InfoBlock

         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  PARSEBYTEVAR          ; parse VAR byte variable

         DB 0cdh
	DW  L6F5E                 ; match(',')

         DB 0cdh
	DW  L5CAD                 ; parse VAR string variable

         DB 3ah
	DW L7B62
         DB 0feh, 12 + 1                  ; STRING[12] or greater ?
         DB 0dah
	DW TYPEMISMATCH          ; no, Type Mismatch

         DB 0cdh
	DW  O_PSHHL               ; push address of Name

         DB 0f1h

GENGIOS_CL_BOOLEAN:
         ; match(')'), generate GIOS CALL and return BOOLEAN type
         ; in:    A = entry
         DB 0f5h

GENGIOS_CL_BOOLEAN1:
         DB 0cdh
	DW  L6F6E                 ; match(')')
         DB 0f1h
         DB 0c3h
	DW  GENGIOS_BOOLEAN

F_FINDNEXT:
         ; FUNCTION FindNext(VAR InfoBlok: Type[64];  { 64 bytes length }
         ;                   VAR Attributes: BYTE;
         ;                   VAR Name: STR63): BOOLEAN;
         DB 0cdh
	DW  L6F66                 ; match('(')

         DB 3eh,70                    ; FindNext entry
         DB 0f5h

         DB 0c3h
	DW  F_FINDFIRST1

F_GETDRIVE:
         ; FUNCTION GetDrive: INTEGER;
         DB 3eh,80                    ; GetDrive entry
         DB 06h,0AH                   ; return INTEGER type
         DB 0c3h
	DW  GENGIOS

F_TESTDRIVE:
         ; FUNCTION TestDrive(Drive: INTEGER): BOOLEAN;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,81                    ; TestDrive entry
         DB 06h,0BH                   ; return BOOLEAN type
         DB 0c3h
	DW  GENGIOS_BOOLEAN

F_GETERROR:
         ; FUNCTION GetError: INTEGER;
         DB 21h
	DW _GETERROR_LIB
         DB 06h,0AH                   ; return INTEGER type
         DB 0c3h
	DW  O_CALHL

;         LD A,75                    ; GetError entry
;
GENGIOS_INTEGER:
         DB 06h,0AH                   ; return INTEGER type
         DB 0c3h
	DW  GENGIOS

F_GETFKEY:
         ; FUNCTION GetFKey: INTEGER;
         DB 3eh,46                    ; GetFKey entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_GETPAD:
         ; FUNCTION GetPad(N: INTEGER): INTEGER;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,53                    ; GetPad entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_GETPDL:
         ; FUNCTION GetPdl(N: INTEGER): INTEGER;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,12                    ; GetPdl entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_GETCHANNEL:
         ; FUNCTION GetChannel(Channel: INTEGER): REAL;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,65                    ; GetChannel entry

GENGIOS_REAL:
         DB 06h,9
         DB 0c3h
	DW  GENGIOS

F_GETPAGEID:
         ; FUNCTION GetPageID(Channel: INTEGER): INTEGER;
         DB 0cdh
	DW  L65DE                 ;  parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,64                    ; GetPageID entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_POINT:
         ; FUNCTION Point(X: INTEGER; Y: BYTE): BYTE;
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0cdh
	DW  O_PSHHL

         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0cdh
	DW  O_PSHHL

         DB 0cdh
	DW  L6F6E                 ; match(')')
         DB 3eh,14                    ; Point entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_READPSG:
         ; FUNCTION ReadPSG(Register: BYTE): BYTE;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,52                    ; ReadPSG entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_READSTATUS:
         ; FUNCTION ReadStatus(Register: BYTE): BYTE;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,3                     ; ReadStatus entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_READVDP:
         ; FUNCTION ReadVDP(Register: BYTE): BYTE;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,7                     ; ReadVDP entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_SEARCH:
         ; FUNCTION Search(X,Y,Color,Condition: INTEGER): INTEGER;
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0cdh
	DW  O_PSHHL               ; push X

         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0cdh
	DW  O_PSHHL               ; push Y

         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0cdh
	DW  O_PSHHL               ; push Color

         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0cdh
	DW  O_PSHHL               ; push Condition

         DB 0cdh
	DW  L6F6E                 ; match(')')
         DB 3eh,47
         DB 0c3h
	DW  GENGIOS_INTEGER

F_SETDATE:
         ; FUNCTION SetDate(Year: INTEGER; Month,Day: BYTE): BOOLEAN;
         DB 3eh,59

O_INT_INT_INT_C:
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
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
         DB 0cdh
	DW  O_PSHHL

         DB 0cdh
	DW  L6F6E                 ; match(')')

         DB 0f1h
         DB 0c3h
	DW  GENGIOS_BOOLEAN

F_SETMEM:
         ; FUNCTION SetMem(Block: INTEGER): INTEGER;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,41                    ; ReadVDP entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_SETTIME:
         ; FUNCTION SetTime(Hour,Minute,Second: BYTE): BOOLEAN;
         DB 3eh,60
         DB 0c3h
	DW  O_INT_INT_INT_C         ; ( INT , INT , INT )

F_STICK:
         ; FUNCTION Stick(StickNum: BYTE): BYTE;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,25                    ; Stick entry
         DB 0c3h
	DW  GENGIOS_INTEGER

F_STRIG:
         ; FUNCTION Strig(StrigNum: BYTE): BOOLEAN;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,32                    ; Strig entry
         DB 0c3h
	DW  GENGIOS_BOOLEAN

F_VPEEK:
         ; FUNCTION VPeek(Address: INTEGER): BYTE;
         DB 0cdh
	DW  L65DE                 ; parse '(', integer expression and ')'
         DB 0cdh
	DW  O_PSHHL
         DB 3eh,6                     ; VPeek entry
         DB 0c3h
	DW  GENGIOS_INTEGER

STRING_C_GIOS:
         ; parses: STRING ')'
         ; in:    GIOS entry number pushed at stack
         DB 0cdh
	DW  L5ED0                 ; parse string expression

C_GIOS:  DB 0cdh
	DW  L6F6E                 ; match(')')
         DB 0f1h
         DB 0c3h
	DW  GENGIOS

O_INT:   ; parses: '(' INTEGER
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0c3h
	DW  O_PSHHL

COMMA_6_INT:
         DB 0cdh
	DW  COMMA_INT

COMMA_5_INT:
         DB 0cdh
	DW  COMMA_INT

COMMA_4_INT:
         DB 0cdh
	DW  COMMA_INT

COMMA_3_INT:
         DB 0cdh
	DW  COMMA_INT

COMMA_2_INT:
         DB 0cdh
	DW  COMMA_INT

COMMA_INT:
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0cdh
	DW  L5E97                 ; parse integer expression
         DB 0c3h
	DW  O_PSHHL

COMMA_V_INT:
         ; parses: ',' VAR INTEGER
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0c3h
	DW  PARSEINTVAR

COMMA_V_BYTE:
         ; parses: ',' VAR BYTE
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0c3h
	DW  PARSEBYTEVAR

COMMA_REAL:
         ; parses: ',' REAL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0c3h
	DW  PARSEREAL

O_7_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_6_INT           ; 6x ',' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

O_5_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_4_INT           ; 3x ',' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

O_4_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_3_INT           ; 3x ',' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

O_3_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_2_INT           ; ',' INT ',' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

O_2_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_INT             ; ',' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

O_3_V_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  PARSEINTVAR           ; VAR INT
         DB 18h,( O_4_V_INT_C_GIOS1)-$-1

O_4_V_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  PARSEINTVAR           ; VAR INT
         DB 0cdh
	DW  COMMA_V_INT           ; ',' VAR INT

O_4_V_INT_C_GIOS1:
         DB 0cdh
	DW  COMMA_V_INT           ; ',' VAR_INT
         DB 0cdh
	DW  COMMA_V_INT           ; ',' VAR_INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

         ; ---------------
         ; GIOS Procedures
         ; ---------------
P_DELETEFILE:
         ; PROCEDURE DeleteFile(FileName: Str63);
         DB 3eh,97                    ; DeleteFile entry
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0c3h
	DW  STRING_C_GIOS           ; STRING ')' GENGIOS


P_DEFINEPICTURE:
         ; PROCEDURE DefinePicture(X1,Y1,X2,Y2,OX,OY,Page: INTEGER);
         DB 3eh,91                    ; DefinePicture entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_6_INT           ; 6 x ',' INT
         DB 0c3h
	DW  C_GIOS

P_PFILLSHAPE:
         ; PROCEDURE PFillShape(X,Y: INTEGER);
         DB 3eh,92                    ; PFillShape entry
         DB 0c3h
	DW  O_2_INT_C_GIOS

P_PPAINT:
         ; PROCEDURE PPaint(X,Y,Border: INTEGER);
         DB 3eh,93                    ; PPaint entry
         DB 0c3h
	DW  O_3_INT_C_GIOS

P_MEMEXPAND:
         ; PROCEDURE MemExpand(DX: INTEGER; DY,Page,Channel: BYTE);
         DB 3eh,86                    ; MemExpand entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_MEMTOVRAM:
         ; PROCEDURE MemtoVRAM(Offset: INTEGER; Page,Channel: BYTE);
         DB 0c9h

P_MEMLOADPICTURE:
         ; PROCEDURE MemLoadPicture(X: INTEGER; Y,Page,Channel: BYTE);
         DB 3eh,88                    ; MemLoadPicture entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

;P_MEMUNCRUNCH:
;         ; PROCEDURE MemUnCrunch(X: INTEGER; Y,Page,Channel: BYTE);
;         LD A,89                    ; MemUnCrunch entry
;         JP O_4_INT_C_GIOS

P_MEMSAVEPICTURE:
         ; PROCEDURE MemSavePicture(X1,Y1,X2,Y2: INTEGER; Page,Channel: BYTE);
         DB 3eh,90                    ; MemSavePicture entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_5_INT           ; 5 x ',' INT
         DB 0c3h
	DW  C_GIOS

P_SETCLIPPING:
         ; PROCEDURE SetClipping(Clipping: BOOLEAN);
         DB 3eh,55                    ; SetClipping entry
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  L5EB0                 ; parse boolean expression
         DB 0cdh
	DW  O_PSHHL
         DB 0c3h
	DW  C_GIOS

P_SETVIEWPORT:
         ; PROCEDURE SetViewPort(X1,Y1,X2,Y2: INTEGER);
         DB 3eh,22                    ; SetViewPort entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_GETVIEWPORT:
         ; PROCEDURE GetViewPort(VAR X1,Y1,X2,Y2: INTEGER);
         DB 3eh,23                    ; GetViewPort entry
         DB 0c3h
	DW  O_4_V_INT_C_GIOS

P_MEMCOPY:
         ; PROCEDURE MemCopy(Source,Destination: INTEGER; Length: REAL);
         DB 3eh,84                    ; MemCopy entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_INT             ; ',' INT
         DB 0cdh
	DW  COMMA_REAL            ; ',' REAL
         DB 0c3h
	DW  C_GIOS

P_BLOAD:
         ; PROCEDURE BLoad(Offset: INTEGER; Page: BYTE; FileName: Str63);
         DB 3eh,73                    ; BLoad entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_INT             ; ',' INT
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0c3h
	DW  STRING_C_GIOS           ; STRING ')' GENGIOS

P_BSAVE:
         ; PROCEDURE BSave(Address1,Page1,Address2,Page2: INTEGER;
         ;                 FileName: Str63);
         DB 3eh,76                    ; BSave entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_3_INT           ; 3x ',' INT
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0c3h
	DW  STRING_C_GIOS           ; STRING ')' GENGIOS

P_CHANGECOLOR:
         ; PROCEDURE ChangeColor(ColorNr,R,G,B: BYTE):
         DB 3eh,9                     ; ChangeColor entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_CHANGESCREEN:
         ; PROCEDURE ChangeScreen(Screen: INTEGER);
         DB 3eh,10                    ; ChangeScreen entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

P_CIRCLE:
         ; PROCEDURE Circle(X,Y,Radius: INTEGER);
         DB 3eh,21                    ; Circle entry
         DB 0c3h
	DW  O_3_INT_C_GIOS

P_CLEARMEM:
         ; PROCEDURE ClearMem;
         DB 3eh,42                    ; ClearMem entry
         DB 0c3h
	DW  GENGIOS

P_DATE:
         ; PROCEDURE Date(VAR Year: INTEGER; VAR Month,Day,WeekDay: BYTE);
         DB 3eh,57                    ; Date entry (GetDate)

         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  PARSEINTVAR           ; VAR INT
         DB 0cdh
	DW  COMMA_V_BYTE          ; ',' VAR BYTE

V_2_BYTE_C_GIOS:
         DB 0cdh
	DW  COMMA_V_BYTE          ; ',' VAR BYTE
         DB 0cdh
	DW  COMMA_V_BYTE          ; ',' VAR BYTE
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

P_DISPLAYPAGE:
         ; PROCEDURE DisplayPage(PageNr: BYTE);
         DB 3eh,13                    ; DisplayPage

O_INT_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

P_ELLIPSE:
         ; PROCEDURE Ellipse(X,Y,RX,RY: INTEGER);
         DB 3eh,66                    ; Ellipse entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_EXPAND:
         ; PROCEDURE Expand(DX,DY,Page: INTEGER; FileName: Str63);
         DB 3eh,49                    ; Expand entry

O_3_INT_STRING_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_2_INT           ; 2x ',' INT
         DB 0cdh
	DW  L6F5E                 ; match(',')
;         JP STRING_C_GIOS           ; STRING ')' GENGIOS

         DB 0cdh
	DW  L5ED0                 ; parse string expression

         DB 0cdh
	DW  L6F13                 ; match(','), if present
         DB 0c2h
	DW C_GIOS               ; ')' GENGIOS if no ',' present

         ; PROCEDURE Expand(DX,DY,Page: INTEGER; FileName: Str63;
         ;                  StartPos: LONGINT); EXTERNAL $F9C8;
         DB 0f1h
         DB 3eh,72                    ; Expand entry with StartPos
         DB 0f5h

         DB 0cdh
	DW  PARSELONG
         DB 0cdh
	DW  L6148                 ; code: push LONG

         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

P_FASTBOX:
         ; PROCEDURE FastBox(X1,Y1,X2,Y2: INTEGER);
         DB 3eh,18                    ; FastBox entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_FASTCOPY:
         ; PROCEDURE FastCopy(X1,Y1,X2,Y2,DX,DY,DestPage: INTEGER);
         DB 3eh,20                    ; FastCopy entry
         DB 0c3h
	DW  O_7_INT_C_GIOS

P_FILLBOX:
         ; PROCEDURE FillBox(X1,Y1,X2,Y2: INTEGER);
         DB 3eh,17                    ; FillBox entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_FILLSHAPE:
         ; PROCEDURE FillShape(X,Y,Color: INTEGER);
         DB 3eh,54                    ; FillShape entry
         DB 0c3h
	DW  O_3_INT_C_GIOS

P_FILLSPRITE:
         ; PROCEDURE FillSprite(Plane,Color: BYTE);
         DB 3eh,36                    ; FillSprite entry
         DB 0c3h
	DW  O_2_INT_C_GIOS

P_GCOPY:
         ; PROCEDURE GCopy(X1,Y1,X2,Y2,DX,DY,DestPage: INTEGER);
         DB 3eh,19                    ; GCopy entry
         DB 0c3h
	DW  O_7_INT_C_GIOS

P_GETDOSVERSION:
         ; PROCEDURE GetDosVersion(VAR Kernel,System: INTEGER);
         DB 3eh,71                    ; GetDosVersion entry
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  PARSEINTVAR           ; VAR INT
         DB 0cdh
	DW  COMMA_V_INT           ; ',' VAR INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

P_LINE:
         ; PROCEDURE Line(X1,Y1,X2,Y2: INTEGER);
         DB 3eh,16                    ; Line entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_LOADPICTURE:
         ; PROCEDURE LoadPicture(DX,DY: INTEGER; Page: BYTE; FileName: Str63);
         DB 3eh,24                    ; LoadPicture entry
         DB 0c3h
	DW  O_3_INT_STRING_C_GIOS

P_LOADVRAM:
         ; PROCEDURE LoadVRAM(VRAMAddress: INTEGER; VRAMPage: BYTE;
         ;                    FileOffset: REAL; VRAMSize: REAL;
         ;                    FileName: Str63);
         DB 3eh,95                    ; LoadVRAM entry

O_2_INT_2_REAL_STRING_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_INT             ; ',' INT

REAL_REAL_STRING_C_GIOS:
         DB 0cdh
	DW  COMMA_REAL            ; ',' REAL
         DB 0cdh
	DW  COMMA_REAL            ; ',' REAL
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0c3h
	DW  STRING_C_GIOS           ; STRING ')' GENGIOS

P_MEMREADFILE:
         ; PROCEDURE MemReadFile(Channel: INTEGER; Position, Length: REAL;
         ;                       FileName: Str63);
         DB 3eh,74                    ; MemReadFile entry

O_INT_2_REAL_STRING_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0c3h
	DW  REAL_REAL_STRING_C_GIOS

P_MEMWRITEFILE:
         ; PROCEDURE MemWriteFile(Channel: INTEGER; Position, Length: REAL;
         ;                        FileName: Str63);
         DB 3eh,83                    ; MemWriteFile entry
         DB 0c3h
	DW  O_INT_2_REAL_STRING_C_GIOS

P_MEMAPPENDFILE:
         ; PROCEDURE MemAppendFile(Channel: INTEGER; Position, Length: REAL;
         ;                         FileName: Str63);
         DB 3eh,94                    ; MemAppendFile entry
         DB 0c3h
	DW  O_INT_2_REAL_STRING_C_GIOS

P_MOVEVRAM:
         ; PROCEDURE MoveVRAM(SourceAddress,SourcePage,
         ;                    DestinationAddress,DestinationPage,
         ;                    Length: INTEGER);
         DB 3eh,82                    ; MoveVRAM
         DB 0c3h
	DW  O_5_INT_C_GIOS

P_PAINT:
         ; PROCEDURE Paint(X,Y,Border: INTEGER);
         DB 3eh,63                    ; Paint entry (BASIC paint)
         DB 0c3h
	DW  O_3_INT_C_GIOS

P_PSET:
         ; PROCEDURE PSet(X,Y: INTEGER);
         DB 3eh,15                    ; PSet entry
         DB 0c3h
	DW  O_2_INT_C_GIOS

P_PUTSPRITE:
         ; PROCEDURE PutSprite(X,Y,SpriteNum,Plane: BYTE);
         DB 3eh,35                    ; PutSprite entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_READMEM:
         ; PROCEDURE ReadMem(Channel,Destination,Length: INTEGER);
         DB 3eh,44                    ; ReadMem entry
         DB 0c3h
	DW  O_3_INT_C_GIOS

P_READSECTOR:
         ; PROCEDURE ReadSector(Drive: BYTE; Sector, Address: INTEGER;
         ;                      SectorCount: BYTE);
         DB 3eh,61                    ; ReadSector entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_SAVEPICTURE:
         ; PROCEDURE SavePicture(X1,Y1,X2,Y2: INTEGER;
         ;                       Page: BYTE; FileName: Str63);
         DB 3eh,48                    ; SavePicture entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_4_INT           ; 4x ',' INT
         DB 0cdh
	DW  L6F5E                 ; match(',')
         DB 0c3h
	DW  STRING_C_GIOS           ; STRING ')' GENGIOS

;P_SAVEVRAM:
;         ; PROCEDURE SaveVRAM(VRAMAddress: INTEGER; VRAMPage: BYTE;
;         ;                    FileOffset: REAL; VRAMSize: REAL;
;         ;                    FileName: Str63);
;         LD A,96                    ; LoadVRAM entry
;         JP O_2_INT_2_REAL_STRING_C_GIOS

P_SCREEN:
         ; PROCEDURE Screen(Num: BYTE);
         DB 3eh,8                     ; Screen entry
         DB 0c3h
	DW  O_INT_C_GIOS

P_SCREENOFF:
         ; PROCEDURE ScreenOff;
         DB 3eh,29                    ; ScreenOff entry
         DB 0c3h
	DW  GENGIOS

P_SCREENON:
         ; PROCEDURE ScreenOn;
         DB 3eh,28                    ; ScreenOn entry
         DB 0c3h
	DW  GENGIOS

P_SETCHANNEL:
         ; PROCEDURE SetChannel(Channel: BYTE; Position: REAL);
         DB 3eh,45                    ; SetChannel entry
         DB 0f5h
         DB 0cdh
	DW  O_INT                 ; '(' INT
         DB 0cdh
	DW  COMMA_REAL            ; ',' REAL
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

P_SOUND:
         ; PROCEDURE Sound(Register,Data: BYTE);
         DB 3eh,51                    ; Sound entry (WritePSG)
         DB 0c3h
	DW  O_2_INT_C_GIOS

P_SPRITEATTRIBUTEADDRESS:
         ; PROCEDURE SpriteAttributeAddress(Address: LONGINT);
         DB 3eh,39                    ; SpriteAttributeAdres entry

O_LONG_C_GIOS:
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  PARSELONG
         DB 0cdh
	DW  L6148                 ; code: push LONG

;         CALL O_INT                 ; '(' INT
         DB 0c3h
	DW  C_GIOS                  ; ')' GENGIOS

P_SPRITECOLOR:
         ; PROCEDURE SpriteColor(Plane: BYTE; Address: INTEGER);
         DB 3eh,37                    ; SpriteColor entry
         DB 0c3h
	DW  O_2_INT_C_GIOS

P_SPRITEPATTERN:
         ; PROCEDURE SpritePattern(SpriteNum: BYTE; Address: INTEGER);
         DB 3eh,38                    ; SpritePattern entry
         DB 0c3h
	DW  O_2_INT_C_GIOS

P_SPRITEPATTERNADDRESS:
         ; PROCEDURE SpritePatternAddress(Address: LONGINT);
         DB 3eh,40                    ; SpritePatternAddress entry
         DB 0c3h
	DW  O_LONG_C_GIOS
;         JP O_INT_C_GIOS

P_SPRITESIZE:
         ; PROCEDURE SpriteSize(Size: BYTE);
         DB 3eh,34                    ; SpriteSize entry
         DB 0c3h
	DW  O_INT_C_GIOS

P_SPRITESOFF:
         ; PROCEDURE SpritesOff;
         DB 3eh,31                    ; SpritesOff entry
         DB 0c3h
	DW  GENGIOS

P_SPRITESON:
         ; PROCEDURE SpritesOn;
         DB 3eh,30                    ; SpritesOn entry
         DB 0c3h
	DW  GENGIOS

P_TIME:
         ; PROCEDURE Time(VAR Hour,Minute,Second: BYTE);
         DB 3eh,58                    ; Time entry (GetTime)
         DB 0f5h
         DB 0cdh
	DW  L6F66                 ; match('(')
         DB 0cdh
	DW  PARSEBYTEVAR          ; VAR Byte
         DB 0c3h
	DW  V_2_BYTE_C_GIOS         ; ',' VAR Byte ',' VAR Byte ')'

;P_UNCRUNCH:
;         ; PROCEDURE UnCrunch(DX,DY,Page,Address: INTEGER);
;         LD A,33                    ; UnCrunch entry
;         JP O_4_INT_C_GIOS

P_VPOKE:
         ; PROCEDURE VPoke(Address,Value: INTEGER);
         DB 3eh,5                     ; VPoke entry
         DB 0c3h
	DW  O_2_INT_C_GIOS

P_WAITVDP:
         ; PROCEDURE WaitVDP;
         DB 3eh,50                    ; WaitVDP entry
         DB 0c3h
	DW  GENGIOS

P_WRITEMEM:
         ; PROCEDURE WriteMem(Channel,Source,Length: INTEGER);
         DB 3eh,43                    ; WriteMem entry
         DB 0c3h
	DW  O_3_INT_C_GIOS

P_WRITESECTOR:
         ; PROCEDURE WriteSector(Drive: BYTE; Sector,SourceAddress: INTEGER;
         ;                       SectorCount: BYTE);
         DB 3eh,62                    ; WriteSector entry
         DB 0c3h
	DW  O_4_INT_C_GIOS

P_WRITEVDP:
         ; PROCEDURE WriteVDP(Register,Data: BYTE);
         DB 3eh,4                     ; WriteVDP entry
         DB 0c3h
	DW  O_2_INT_C_GIOS

         END

