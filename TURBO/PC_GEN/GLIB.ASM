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
         MOV ch,0BH                   ; return BOOLEAN type

GENGIOS:
         MOV bh,al
         MOV bl,3EH                   ; opcode: LD A,
         CALL near ptr O_HL
         MOV bx,offset _RUNGIOS
         JMP near ptr  O_CALHL

PARSEBYTEVAR:
         ; parses a VAR byte variable, not a VAR integer variable !!
         CALL near ptr L677F                 ; parse VAR parameter
         CALL near ptr O_PSHHL
         MOV al,byte ptr L7B5C
         CMP al, 0AH                     ; type = integer ?
         JNZ near ptr PARSEBYTEERROR       ; jump if not integer

         MOV al,byte ptr L7B62               ; A = sizeof var parameter (BYTE/INTEGER)
         DEC al
         RETZ                       ; return if size = 1

PARSEBYTEERROR:
         CALL near ptr L72E1                 ; no condition
         DB 13H                     ; error 24: Byte variable expected

PARSEINTVAR:
         ; parses a VAR integer variable, not a VAR byte variable !!
         CALL near ptr L677F                 ; parse VAR parameter
         CALL near ptr O_PSHHL
         MOV al,byte ptr L7B5C
         CMP al, 0AH                     ; type = integer ?
         JNZ near ptr PARSEINTERROR        ; jump if not integer

         MOV al,byte ptr L7B62               ; A = sizeof var parameter (BYTE/INTEGER)
         DEC al
         RETNZ                      ; return if size >= 2, can only be 2

PARSEINTERROR:
         CALL near ptr L72E1                 ; no condition
         DB 18H                     ; error 24: Integer variable expected

PARSESTRVAR64:
         ; parses a VAR string variable of length 63 + 1
         CALL near ptr L5CAD                 ; parse VAR string variable

PARSEVAR64_L:
         MOV al,byte ptr L7B62
         CMP al, 63 + 1                  ; STRING[63] ?
         RETZ 

TYPEMISMATCH:
         CALL near ptr L72E1                 ; NonZero --> error
         DB 2CH                     ; error 44: Type mismatch

PARSEVAR64:
         ; parse a VAR parameter of length 64
         CALL near ptr L677F                 ; parse VAR parameter
         JMP near ptr  PARSEVAR64_L

PARSELONG:
         ; parse a LONGINT and REAL with conversion to a LONGINT
         MOV al,0EH                   ; default type = LONGINT
         CALL near ptr L5EE8                 ; parse expression
         MOV al,ch                     ; A = expression type

         MOV bx,offset _R_L                 ; REAL to LONGINT conversion
         CMP al, 09H
         JZ near ptr PARSELONG1            ; jump to convert REAL to LONG

         CMP al, 0EH
         JZ near ptr PARSELONG2            ; jump if LONGINT

         CMP al, 0AH
         JZ near ptr PARSELONG3            ; jump to convert INTEGER to LONG
                                    ; unsigned conversion

         JMP near ptr  TYPEMISMATCH

PARSELONG1:
         CALL near ptr O_CALHL               ; generate conversion CALL

PARSELONG2:
         MOV ch,0Eh
         RET                        ; 33e
;         JP L6148                   ; generate code to PUSH a LONGINT

PARSELONG3:
         JMP near ptr  OP_L_I                  ; 33e convert signed INTEGER TO LONGINT
;         CALL OP_L_I                ; convert signed INTEGER to LONGINT
;         JP L6148                   ; generate code to PUSH a LONGINT

PARSEREAL:
         ; parse an INTEGER, LONGINT and REAL with conversions to a REAL
         MOV al,0FFH                  ; default type = smart
         CALL near ptr L5EE8                 ; parse expression
         MOV al,ch                     ; A = expression type

         MOV bx,offset _L_R                 ; LONGINT to REAL conversion
         CMP al, 0EH                     ; type = LONGINT ?
         JZ near ptr PARSEREAL1

         MOV bx,offset _L1008               ; INTEGER to REAL conversion
         CMP al, 0AH                     ; type = INTEGER ?
         JZ near ptr PARSEREAL1

         CMP al, 09H
         JZ near ptr PARSEREAL2            ; jump if no conversion needed

         JMP near ptr  TYPEMISMATCH

PARSEREAL1:
         CALL near ptr O_CALHL               ; generate conversion CALL

PARSEREAL2:
         MOV ch,9
         JMP near ptr  L6148                   ; generate code to PUSH a REAL

         ; --------------
         ; GIOS Functions
         ; --------------

F_TSRPRESENT:
         ; FUNCTION TsrPresent(Str: STRING): BOOLEAN;
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5ED0                 ; parse string expression
         MOV bx,offset _TSRPRESENT          ; LIB entry
         MOV ch,0BH                   ; return boolean type
         JMP near ptr  L5960                   ; match(')'), CALL HL

F_GETCLIPPING:
         ; FUNCTION GetClipping: BOOLEAN;
         MOV al,56                    ; GetClipping entry
         JMP near ptr  GENGIOS_BOOLEAN

F_SIMULATEDDISK:
         ; FUNCTION SimulatedDisk(disk: BYTE): BOOLEAN;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,85                    ; SimulatedDisk entry
         JMP near ptr  GENGIOS_BOOLEAN         ; GIOS CALL and return BOOLEAN type

F_FINDFIRST:
         ; FUNCTION FindFirst(SearchPathAdres: STRING;
         ;                    VAR InfoBlock: Type[64]; { 64 bytes length }
         ;                    VAR Attributes: BYTE;
         ;                    VAR Name: STR63): BOOLEAN;
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5ED0                 ; parse string expression

         CALL near ptr L6F5E                 ; match(',')
         MOV al,69
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

F_FINDFIRST1:
         CALL near ptr PARSEVAR64            ; parse VAR of 64 bytes length
         CALL near ptr O_PSHHL               ; push address of InfoBlock

         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr PARSEBYTEVAR          ; parse VAR byte variable

         CALL near ptr L6F5E                 ; match(',')

         CALL near ptr L5CAD                 ; parse VAR string variable

         MOV al,byte ptr L7B62
         CMP al, 12 + 1                  ; STRING[12] or greater ?
         JC near ptr TYPEMISMATCH          ; no, Type Mismatch

         CALL near ptr O_PSHHL               ; push address of Name

         POP ax
	xchg ah,al
	sahf

GENGIOS_CL_BOOLEAN:
         ; match(')'), generate GIOS CALL and return BOOLEAN type
         ; in:    A = entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

GENGIOS_CL_BOOLEAN1:
         CALL near ptr L6F6E                 ; match(')')
         POP ax
	xchg ah,al
	sahf
         JMP near ptr  GENGIOS_BOOLEAN

F_FINDNEXT:
         ; FUNCTION FindNext(VAR InfoBlok: Type[64];  { 64 bytes length }
         ;                   VAR Attributes: BYTE;
         ;                   VAR Name: STR63): BOOLEAN;
         CALL near ptr L6F66                 ; match('(')

         MOV al,70                    ; FindNext entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

         JMP near ptr  F_FINDFIRST1

F_GETDRIVE:
         ; FUNCTION GetDrive: INTEGER;
         MOV al,80                    ; GetDrive entry
         MOV ch,0AH                   ; return INTEGER type
         JMP near ptr  GENGIOS

F_TESTDRIVE:
         ; FUNCTION TestDrive(Drive: INTEGER): BOOLEAN;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,81                    ; TestDrive entry
         MOV ch,0BH                   ; return BOOLEAN type
         JMP near ptr  GENGIOS_BOOLEAN

F_GETERROR:
         ; FUNCTION GetError: INTEGER;
         MOV bx,offset _GETERROR_LIB
         MOV ch,0AH                   ; return INTEGER type
         JMP near ptr  O_CALHL

;         LD A,75                    ; GetError entry
;
GENGIOS_INTEGER:
         MOV ch,0AH                   ; return INTEGER type
         JMP near ptr  GENGIOS

F_GETFKEY:
         ; FUNCTION GetFKey: INTEGER;
         MOV al,46                    ; GetFKey entry
         JMP near ptr  GENGIOS_INTEGER

F_GETPAD:
         ; FUNCTION GetPad(N: INTEGER): INTEGER;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,53                    ; GetPad entry
         JMP near ptr  GENGIOS_INTEGER

F_GETPDL:
         ; FUNCTION GetPdl(N: INTEGER): INTEGER;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,12                    ; GetPdl entry
         JMP near ptr  GENGIOS_INTEGER

F_GETCHANNEL:
         ; FUNCTION GetChannel(Channel: INTEGER): REAL;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,65                    ; GetChannel entry

GENGIOS_REAL:
         MOV ch,9
         JMP near ptr  GENGIOS

F_GETPAGEID:
         ; FUNCTION GetPageID(Channel: INTEGER): INTEGER;
         CALL near ptr L65DE                 ;  parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,64                    ; GetPageID entry
         JMP near ptr  GENGIOS_INTEGER

F_POINT:
         ; FUNCTION Point(X: INTEGER; Y: BYTE): BYTE;
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL

         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL

         CALL near ptr L6F6E                 ; match(')')
         MOV al,14                    ; Point entry
         JMP near ptr  GENGIOS_INTEGER

F_READPSG:
         ; FUNCTION ReadPSG(Register: BYTE): BYTE;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,52                    ; ReadPSG entry
         JMP near ptr  GENGIOS_INTEGER

F_READSTATUS:
         ; FUNCTION ReadStatus(Register: BYTE): BYTE;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,3                     ; ReadStatus entry
         JMP near ptr  GENGIOS_INTEGER

F_READVDP:
         ; FUNCTION ReadVDP(Register: BYTE): BYTE;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,7                     ; ReadVDP entry
         JMP near ptr  GENGIOS_INTEGER

F_SEARCH:
         ; FUNCTION Search(X,Y,Color,Condition: INTEGER): INTEGER;
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL               ; push X

         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL               ; push Y

         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL               ; push Color

         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL               ; push Condition

         CALL near ptr L6F6E                 ; match(')')
         MOV al,47
         JMP near ptr  GENGIOS_INTEGER

F_SETDATE:
         ; FUNCTION SetDate(Year: INTEGER; Month,Day: BYTE): BOOLEAN;
         MOV al,59

O_INT_INT_INT_C:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL

         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL

         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         CALL near ptr O_PSHHL

         CALL near ptr L6F6E                 ; match(')')

         POP ax
	xchg ah,al
	sahf
         JMP near ptr  GENGIOS_BOOLEAN

F_SETMEM:
         ; FUNCTION SetMem(Block: INTEGER): INTEGER;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,41                    ; ReadVDP entry
         JMP near ptr  GENGIOS_INTEGER

F_SETTIME:
         ; FUNCTION SetTime(Hour,Minute,Second: BYTE): BOOLEAN;
         MOV al,60
         JMP near ptr  O_INT_INT_INT_C         ; ( INT , INT , INT )

F_STICK:
         ; FUNCTION Stick(StickNum: BYTE): BYTE;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,25                    ; Stick entry
         JMP near ptr  GENGIOS_INTEGER

F_STRIG:
         ; FUNCTION Strig(StrigNum: BYTE): BOOLEAN;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,32                    ; Strig entry
         JMP near ptr  GENGIOS_BOOLEAN

F_VPEEK:
         ; FUNCTION VPeek(Address: INTEGER): BYTE;
         CALL near ptr L65DE                 ; parse '(', integer expression and ')'
         CALL near ptr O_PSHHL
         MOV al,6                     ; VPeek entry
         JMP near ptr  GENGIOS_INTEGER

STRING_C_GIOS:
         ; parses: STRING ')'
         ; in:    GIOS entry number pushed at stack
         CALL near ptr L5ED0                 ; parse string expression

C_GIOS:  CALL near ptr L6F6E                 ; match(')')
         POP ax
	xchg ah,al
	sahf
         JMP near ptr  GENGIOS

O_INT:   ; parses: '(' INTEGER
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5E97                 ; parse integer expression
         JMP near ptr  O_PSHHL

COMMA_6_INT:
         CALL near ptr COMMA_INT

COMMA_5_INT:
         CALL near ptr COMMA_INT

COMMA_4_INT:
         CALL near ptr COMMA_INT

COMMA_3_INT:
         CALL near ptr COMMA_INT

COMMA_2_INT:
         CALL near ptr COMMA_INT

COMMA_INT:
         CALL near ptr L6F5E                 ; match(',')
         CALL near ptr L5E97                 ; parse integer expression
         JMP near ptr  O_PSHHL

COMMA_V_INT:
         ; parses: ',' VAR INTEGER
         CALL near ptr L6F5E                 ; match(',')
         JMP near ptr  PARSEINTVAR

COMMA_V_BYTE:
         ; parses: ',' VAR BYTE
         CALL near ptr L6F5E                 ; match(',')
         JMP near ptr  PARSEBYTEVAR

COMMA_REAL:
         ; parses: ',' REAL
         CALL near ptr L6F5E                 ; match(',')
         JMP near ptr  PARSEREAL

O_7_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_6_INT           ; 6x ',' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

O_5_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_4_INT           ; 3x ',' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

O_4_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_3_INT           ; 3x ',' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

O_3_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_2_INT           ; ',' INT ',' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

O_2_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_INT             ; ',' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

O_3_V_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr PARSEINTVAR           ; VAR INT
         JMP near ptr  O_4_V_INT_C_GIOS1

O_4_V_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr PARSEINTVAR           ; VAR INT
         CALL near ptr COMMA_V_INT           ; ',' VAR INT

O_4_V_INT_C_GIOS1:
         CALL near ptr COMMA_V_INT           ; ',' VAR_INT
         CALL near ptr COMMA_V_INT           ; ',' VAR_INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

         ; ---------------
         ; GIOS Procedures
         ; ---------------
P_DELETEFILE:
         ; PROCEDURE DeleteFile(FileName: Str63);
         MOV al,97                    ; DeleteFile entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         JMP near ptr  STRING_C_GIOS           ; STRING ')' GENGIOS


P_DEFINEPICTURE:
         ; PROCEDURE DefinePicture(X1,Y1,X2,Y2,OX,OY,Page: INTEGER);
         MOV al,91                    ; DefinePicture entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_6_INT           ; 6 x ',' INT
         JMP near ptr  C_GIOS

P_PFILLSHAPE:
         ; PROCEDURE PFillShape(X,Y: INTEGER);
         MOV al,92                    ; PFillShape entry
         JMP near ptr  O_2_INT_C_GIOS

P_PPAINT:
         ; PROCEDURE PPaint(X,Y,Border: INTEGER);
         MOV al,93                    ; PPaint entry
         JMP near ptr  O_3_INT_C_GIOS

P_MEMEXPAND:
         ; PROCEDURE MemExpand(DX: INTEGER; DY,Page,Channel: BYTE);
         MOV al,86                    ; MemExpand entry
         JMP near ptr  O_4_INT_C_GIOS

P_MEMTOVRAM:
         ; PROCEDURE MemtoVRAM(Offset: INTEGER; Page,Channel: BYTE);
         RET

P_MEMLOADPICTURE:
         ; PROCEDURE MemLoadPicture(X: INTEGER; Y,Page,Channel: BYTE);
         MOV al,88                    ; MemLoadPicture entry
         JMP near ptr  O_4_INT_C_GIOS

;P_MEMUNCRUNCH:
;         ; PROCEDURE MemUnCrunch(X: INTEGER; Y,Page,Channel: BYTE);
;         LD A,89                    ; MemUnCrunch entry
;         JP O_4_INT_C_GIOS

P_MEMSAVEPICTURE:
         ; PROCEDURE MemSavePicture(X1,Y1,X2,Y2: INTEGER; Page,Channel: BYTE);
         MOV al,90                    ; MemSavePicture entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_5_INT           ; 5 x ',' INT
         JMP near ptr  C_GIOS

P_SETCLIPPING:
         ; PROCEDURE SetClipping(Clipping: BOOLEAN);
         MOV al,55                    ; SetClipping entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr L5EB0                 ; parse boolean expression
         CALL near ptr O_PSHHL
         JMP near ptr  C_GIOS

P_SETVIEWPORT:
         ; PROCEDURE SetViewPort(X1,Y1,X2,Y2: INTEGER);
         MOV al,22                    ; SetViewPort entry
         JMP near ptr  O_4_INT_C_GIOS

P_GETVIEWPORT:
         ; PROCEDURE GetViewPort(VAR X1,Y1,X2,Y2: INTEGER);
         MOV al,23                    ; GetViewPort entry
         JMP near ptr  O_4_V_INT_C_GIOS

P_MEMCOPY:
         ; PROCEDURE MemCopy(Source,Destination: INTEGER; Length: REAL);
         MOV al,84                    ; MemCopy entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_INT             ; ',' INT
         CALL near ptr COMMA_REAL            ; ',' REAL
         JMP near ptr  C_GIOS

P_BLOAD:
         ; PROCEDURE BLoad(Offset: INTEGER; Page: BYTE; FileName: Str63);
         MOV al,73                    ; BLoad entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_INT             ; ',' INT
         CALL near ptr L6F5E                 ; match(',')
         JMP near ptr  STRING_C_GIOS           ; STRING ')' GENGIOS

P_BSAVE:
         ; PROCEDURE BSave(Address1,Page1,Address2,Page2: INTEGER;
         ;                 FileName: Str63);
         MOV al,76                    ; BSave entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_3_INT           ; 3x ',' INT
         CALL near ptr L6F5E                 ; match(',')
         JMP near ptr  STRING_C_GIOS           ; STRING ')' GENGIOS

P_CHANGECOLOR:
         ; PROCEDURE ChangeColor(ColorNr,R,G,B: BYTE):
         MOV al,9                     ; ChangeColor entry
         JMP near ptr  O_4_INT_C_GIOS

P_CHANGESCREEN:
         ; PROCEDURE ChangeScreen(Screen: INTEGER);
         MOV al,10                    ; ChangeScreen entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

P_CIRCLE:
         ; PROCEDURE Circle(X,Y,Radius: INTEGER);
         MOV al,21                    ; Circle entry
         JMP near ptr  O_3_INT_C_GIOS

P_CLEARMEM:
         ; PROCEDURE ClearMem;
         MOV al,42                    ; ClearMem entry
         JMP near ptr  GENGIOS

P_DATE:
         ; PROCEDURE Date(VAR Year: INTEGER; VAR Month,Day,WeekDay: BYTE);
         MOV al,57                    ; Date entry (GetDate)

         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr PARSEINTVAR           ; VAR INT
         CALL near ptr COMMA_V_BYTE          ; ',' VAR BYTE

V_2_BYTE_C_GIOS:
         CALL near ptr COMMA_V_BYTE          ; ',' VAR BYTE
         CALL near ptr COMMA_V_BYTE          ; ',' VAR BYTE
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

P_DISPLAYPAGE:
         ; PROCEDURE DisplayPage(PageNr: BYTE);
         MOV al,13                    ; DisplayPage

O_INT_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

P_ELLIPSE:
         ; PROCEDURE Ellipse(X,Y,RX,RY: INTEGER);
         MOV al,66                    ; Ellipse entry
         JMP near ptr  O_4_INT_C_GIOS

P_EXPAND:
         ; PROCEDURE Expand(DX,DY,Page: INTEGER; FileName: Str63);
         MOV al,49                    ; Expand entry

O_3_INT_STRING_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_2_INT           ; 2x ',' INT
         CALL near ptr L6F5E                 ; match(',')
;         JP STRING_C_GIOS           ; STRING ')' GENGIOS

         CALL near ptr L5ED0                 ; parse string expression

         CALL near ptr L6F13                 ; match(','), if present
         JNZ near ptr C_GIOS               ; ')' GENGIOS if no ',' present

         ; PROCEDURE Expand(DX,DY,Page: INTEGER; FileName: Str63;
         ;                  StartPos: LONGINT); EXTERNAL $F9C8;
         POP ax
	xchg ah,al
	sahf
         MOV al,72                    ; Expand entry with StartPos
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al

         CALL near ptr PARSELONG
         CALL near ptr L6148                 ; code: push LONG

         JMP near ptr  C_GIOS                  ; ')' GENGIOS

P_FASTBOX:
         ; PROCEDURE FastBox(X1,Y1,X2,Y2: INTEGER);
         MOV al,18                    ; FastBox entry
         JMP near ptr  O_4_INT_C_GIOS

P_FASTCOPY:
         ; PROCEDURE FastCopy(X1,Y1,X2,Y2,DX,DY,DestPage: INTEGER);
         MOV al,20                    ; FastCopy entry
         JMP near ptr  O_7_INT_C_GIOS

P_FILLBOX:
         ; PROCEDURE FillBox(X1,Y1,X2,Y2: INTEGER);
         MOV al,17                    ; FillBox entry
         JMP near ptr  O_4_INT_C_GIOS

P_FILLSHAPE:
         ; PROCEDURE FillShape(X,Y,Color: INTEGER);
         MOV al,54                    ; FillShape entry
         JMP near ptr  O_3_INT_C_GIOS

P_FILLSPRITE:
         ; PROCEDURE FillSprite(Plane,Color: BYTE);
         MOV al,36                    ; FillSprite entry
         JMP near ptr  O_2_INT_C_GIOS

P_GCOPY:
         ; PROCEDURE GCopy(X1,Y1,X2,Y2,DX,DY,DestPage: INTEGER);
         MOV al,19                    ; GCopy entry
         JMP near ptr  O_7_INT_C_GIOS

P_GETDOSVERSION:
         ; PROCEDURE GetDosVersion(VAR Kernel,System: INTEGER);
         MOV al,71                    ; GetDosVersion entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr PARSEINTVAR           ; VAR INT
         CALL near ptr COMMA_V_INT           ; ',' VAR INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

P_LINE:
         ; PROCEDURE Line(X1,Y1,X2,Y2: INTEGER);
         MOV al,16                    ; Line entry
         JMP near ptr  O_4_INT_C_GIOS

P_LOADPICTURE:
         ; PROCEDURE LoadPicture(DX,DY: INTEGER; Page: BYTE; FileName: Str63);
         MOV al,24                    ; LoadPicture entry
         JMP near ptr  O_3_INT_STRING_C_GIOS

P_LOADVRAM:
         ; PROCEDURE LoadVRAM(VRAMAddress: INTEGER; VRAMPage: BYTE;
         ;                    FileOffset: REAL; VRAMSize: REAL;
         ;                    FileName: Str63);
         MOV al,95                    ; LoadVRAM entry

O_2_INT_2_REAL_STRING_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_INT             ; ',' INT

REAL_REAL_STRING_C_GIOS:
         CALL near ptr COMMA_REAL            ; ',' REAL
         CALL near ptr COMMA_REAL            ; ',' REAL
         CALL near ptr L6F5E                 ; match(',')
         JMP near ptr  STRING_C_GIOS           ; STRING ')' GENGIOS

P_MEMREADFILE:
         ; PROCEDURE MemReadFile(Channel: INTEGER; Position, Length: REAL;
         ;                       FileName: Str63);
         MOV al,74                    ; MemReadFile entry

O_INT_2_REAL_STRING_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         JMP near ptr  REAL_REAL_STRING_C_GIOS

P_MEMWRITEFILE:
         ; PROCEDURE MemWriteFile(Channel: INTEGER; Position, Length: REAL;
         ;                        FileName: Str63);
         MOV al,83                    ; MemWriteFile entry
         JMP near ptr  O_INT_2_REAL_STRING_C_GIOS

P_MEMAPPENDFILE:
         ; PROCEDURE MemAppendFile(Channel: INTEGER; Position, Length: REAL;
         ;                         FileName: Str63);
         MOV al,94                    ; MemAppendFile entry
         JMP near ptr  O_INT_2_REAL_STRING_C_GIOS

P_MOVEVRAM:
         ; PROCEDURE MoveVRAM(SourceAddress,SourcePage,
         ;                    DestinationAddress,DestinationPage,
         ;                    Length: INTEGER);
         MOV al,82                    ; MoveVRAM
         JMP near ptr  O_5_INT_C_GIOS

P_PAINT:
         ; PROCEDURE Paint(X,Y,Border: INTEGER);
         MOV al,63                    ; Paint entry (BASIC paint)
         JMP near ptr  O_3_INT_C_GIOS

P_PSET:
         ; PROCEDURE PSet(X,Y: INTEGER);
         MOV al,15                    ; PSet entry
         JMP near ptr  O_2_INT_C_GIOS

P_PUTSPRITE:
         ; PROCEDURE PutSprite(X,Y,SpriteNum,Plane: BYTE);
         MOV al,35                    ; PutSprite entry
         JMP near ptr  O_4_INT_C_GIOS

P_READMEM:
         ; PROCEDURE ReadMem(Channel,Destination,Length: INTEGER);
         MOV al,44                    ; ReadMem entry
         JMP near ptr  O_3_INT_C_GIOS

P_READSECTOR:
         ; PROCEDURE ReadSector(Drive: BYTE; Sector, Address: INTEGER;
         ;                      SectorCount: BYTE);
         MOV al,61                    ; ReadSector entry
         JMP near ptr  O_4_INT_C_GIOS

P_SAVEPICTURE:
         ; PROCEDURE SavePicture(X1,Y1,X2,Y2: INTEGER;
         ;                       Page: BYTE; FileName: Str63);
         MOV al,48                    ; SavePicture entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_4_INT           ; 4x ',' INT
         CALL near ptr L6F5E                 ; match(',')
         JMP near ptr  STRING_C_GIOS           ; STRING ')' GENGIOS

;P_SAVEVRAM:
;         ; PROCEDURE SaveVRAM(VRAMAddress: INTEGER; VRAMPage: BYTE;
;         ;                    FileOffset: REAL; VRAMSize: REAL;
;         ;                    FileName: Str63);
;         LD A,96                    ; LoadVRAM entry
;         JP O_2_INT_2_REAL_STRING_C_GIOS

P_SCREEN:
         ; PROCEDURE Screen(Num: BYTE);
         MOV al,8                     ; Screen entry
         JMP near ptr  O_INT_C_GIOS

P_SCREENOFF:
         ; PROCEDURE ScreenOff;
         MOV al,29                    ; ScreenOff entry
         JMP near ptr  GENGIOS

P_SCREENON:
         ; PROCEDURE ScreenOn;
         MOV al,28                    ; ScreenOn entry
         JMP near ptr  GENGIOS

P_SETCHANNEL:
         ; PROCEDURE SetChannel(Channel: BYTE; Position: REAL);
         MOV al,45                    ; SetChannel entry
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr O_INT                 ; '(' INT
         CALL near ptr COMMA_REAL            ; ',' REAL
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

P_SOUND:
         ; PROCEDURE Sound(Register,Data: BYTE);
         MOV al,51                    ; Sound entry (WritePSG)
         JMP near ptr  O_2_INT_C_GIOS

P_SPRITEATTRIBUTEADDRESS:
         ; PROCEDURE SpriteAttributeAddress(Address: LONGINT);
         MOV al,39                    ; SpriteAttributeAdres entry

O_LONG_C_GIOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr PARSELONG
         CALL near ptr L6148                 ; code: push LONG

;         CALL O_INT                 ; '(' INT
         JMP near ptr  C_GIOS                  ; ')' GENGIOS

P_SPRITECOLOR:
         ; PROCEDURE SpriteColor(Plane: BYTE; Address: INTEGER);
         MOV al,37                    ; SpriteColor entry
         JMP near ptr  O_2_INT_C_GIOS

P_SPRITEPATTERN:
         ; PROCEDURE SpritePattern(SpriteNum: BYTE; Address: INTEGER);
         MOV al,38                    ; SpritePattern entry
         JMP near ptr  O_2_INT_C_GIOS

P_SPRITEPATTERNADDRESS:
         ; PROCEDURE SpritePatternAddress(Address: LONGINT);
         MOV al,40                    ; SpritePatternAddress entry
         JMP near ptr  O_LONG_C_GIOS
;         JP O_INT_C_GIOS

P_SPRITESIZE:
         ; PROCEDURE SpriteSize(Size: BYTE);
         MOV al,34                    ; SpriteSize entry
         JMP near ptr  O_INT_C_GIOS

P_SPRITESOFF:
         ; PROCEDURE SpritesOff;
         MOV al,31                    ; SpritesOff entry
         JMP near ptr  GENGIOS

P_SPRITESON:
         ; PROCEDURE SpritesOn;
         MOV al,30                    ; SpritesOn entry
         JMP near ptr  GENGIOS

P_TIME:
         ; PROCEDURE Time(VAR Hour,Minute,Second: BYTE);
         MOV al,58                    ; Time entry (GetTime)
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         CALL near ptr L6F66                 ; match('(')
         CALL near ptr PARSEBYTEVAR          ; VAR Byte
         JMP near ptr  V_2_BYTE_C_GIOS         ; ',' VAR Byte ',' VAR Byte ')'

;P_UNCRUNCH:
;         ; PROCEDURE UnCrunch(DX,DY,Page,Address: INTEGER);
;         LD A,33                    ; UnCrunch entry
;         JP O_4_INT_C_GIOS

P_VPOKE:
         ; PROCEDURE VPoke(Address,Value: INTEGER);
         MOV al,5                     ; VPoke entry
         JMP near ptr  O_2_INT_C_GIOS

P_WAITVDP:
         ; PROCEDURE WaitVDP;
         MOV al,50                    ; WaitVDP entry
         JMP near ptr  GENGIOS

P_WRITEMEM:
         ; PROCEDURE WriteMem(Channel,Source,Length: INTEGER);
         MOV al,43                    ; WriteMem entry
         JMP near ptr  O_3_INT_C_GIOS

P_WRITESECTOR:
         ; PROCEDURE WriteSector(Drive: BYTE; Sector,SourceAddress: INTEGER;
         ;                       SectorCount: BYTE);
         MOV al,62                    ; WriteSector entry
         JMP near ptr  O_4_INT_C_GIOS

P_WRITEVDP:
         ; PROCEDURE WriteVDP(Register,Data: BYTE);
         MOV al,4                     ; WriteVDP entry
         JMP near ptr  O_2_INT_C_GIOS