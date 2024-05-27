
;M       .model small
;M       .code
;M       .486

       .model small
       .code
       .486
       include pcmacros.inc
       include pcsim.inc

IFNDEF MAKEPC
MSX:
ENDIF

IFDEF MSX
MSXDOS EQU 5
USELIB:
ENDIF

         INCLUDE FILEIO.INC

         INCLUDE MACROS.INC

; InitFileIO:
         ; in:    -
         ; out:   DOS2Present set

; ParseName:
         ; in:    HL = source filename string, preceding spaces or tabs allowed
         ; DOS 1: DE = address of FCB - block to be filled with filename and
         ;             drive number, 0 = default, 1 = 'A:', 2 = 'B:'
         ; DOS 2: DE+1 = destination for drive/path/file string
         ;        ABC = default filename extension, A='P', B='A', C='S'

         ; out:   DE = parsed filename string
         ;        HL = address direct after drive/path/file string
         ;        BC = address of last item
	;	A = 0,	if no error occurred
	;		otherwise:
	;			0DBH, Invalid drive
         ;                          0DAH, Invalid filename
         ;                          0D9H, Invalid pathname
         ;                                  wild cards used when not permitted
	; changes: only AF, BC, DE and HL

; SetExtension:
         ; in:    HL = address of filename
         ;        ABC = new extension
         ;        Carry set if extension is to be overruled
         ;        Carry clear if extension is not to be overruled
         ; out:   A, HL, BC unchanged

; CreateFile:
         ; in:    HL = address of file name
         ;        DE = address of handle or unopened FCB
         ;        ABC = default extension
         ; out:   HL = address of handle or unopened FCB
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; OpenFile:
         ; in:    HL = address of file name
         ;        DE = address of handle or unopened FCB
         ;        ABC = default extension
         ; out:   HL = address of handle or unopened FCB
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; FileSeek:
         ; in:    BC = handle/FCB address
         ;        DEHL = new file position
         ; out:   DEHL = new file position
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; FilePos:
         ; in:    BC = handle/FCB address
         ; out:   DEHL = current file position
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; FileSize:
         ; in:    BC = handle/FCB address
         ; out:   DEHL = file size
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; ReadFile:
         ; in:    BC = handle/FCB address
         ;        DE = destination address for data
         ;        HL = number of bytes to read
         ; out:   HL = number of bytes actually read
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; WriteFile:
         ; in:    BC = handle/FCB address
         ;        DE = source address for data
         ;        HL = number of bytes to write
         ; out:   HL = number of bytes actually written
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; CloseFile:
         ; in:    BC = handle/FCB address
         ; out:   BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

; DeleteFile: or subdirectory under DOS 2
         ; in:    DE = Drive/path/file ASCIIZ string
         ; out:    A = DOS 2 error code, 0 on success
         ;             flags are set on A

; RenameFile: or subdirectory under DOS 2
         ; in:    DE = old Drive/path/file ASCIIZ string
         ;        HL = new filename ASCIIZ string
         ; out:    A = DOS 2 error code, 0 on success
         ;             flags are set on A

; GetCurrentDirectory:
         ; in:     B = drive number, 0 = default, 1 = A: etc.
         ;        DE = address where to put drive/path string
         ;             without a trailing backslash
         ; out:    A = DOS 2 error code, 0 on succes
         ;             flags are set on A

TEMPFILENAME:
         db 64+1 dup (0)  ; used by Open/Create File to setup default extension
                  ; used by Delete File


DOS2PRESENT:      DB 0              ; 0 = not present, NonZero = present
                                    ; default no DOS 2

ERRORHANDLERPRESENT:DB 0            ; 0 = not present, NonZero = present

OLDERRORVECTOR:   DW 0
OLDABORTVECTOR:   DW 0

INITFILEIO:
         ; in:    -
         ; out:   DOS2Present set
         MOV cl,6FH
         CALL near ptr FILE_MSXDOS           ; get dos version
         OR al, al
         JNZ near ptr INITFILEIO_1         ; jump with no carry if DOS 1

         MOV al,ch
         CMP al, 2
         CMC                        ; Carry if >= 2

INITFILEIO_1:
         MOV al,0
         ADC al,al                    ; Add 1 if DOS 2
         MOV byte ptr DOS2PRESENT,al         ; 0 = not present, NonZero = present
         RET

CHECKDRIVE:
	; in:  A = drive number, 0=default, 1='A:', 2='B:' etc.
	; out: A = drive number, 1='A:', 2='B:' etc. default filled in
         ;           carry set if drive number was illegal
	; changes: AF

         PUSH bx
	PUSH dx
	PUSH cx
	OR al, al
         JZ near ptr CHECKDRIVEGETDEFAULT  ; default drive

IFDEF MSX
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
	MOV cl,24
         CALL near ptr FILE_MSXDOS           ; get login vector
	POP ax
	xchg ah,al
	sahf
	; in A, 1='A:', 2='B:' enz.
	CMP al, 9			; must be lower than 9
	CMC			; NC = correct
         JC near ptr CHECKDRIVEQUIT        ; quit with carry set if not correct

         MOV ch,al
CHECKDRIVELOOP:
         RCR bl,1
         DEC ch
	JNZ near ptr CHECKDRIVELOOP
	CMC			; complement >> NC = correct, anders fout
ELSE
         OR al, al                       ; set NC, always approve
                                    ; any drive on a PC
ENDIF    ; MAKEPC


CHECKDRIVEQUIT:
         POP cx
	POP dx
	POP bx
	RET

CHECKDRIVEGETDEFAULT:
         MOV cl,25
         CALL near ptr FILE_MSXDOS           ; Get Default Drive Name
	INC al			; convert to 1=A, 2=B etc.
	OR al, al			; NC >> cannot make errors
         JMP near ptr  CHECKDRIVEQUIT

; ParseName
; Deze routine vormt de naam gegeven vanaf HL om tot een naam
; die direct in een FCB geplaatst kan worden. Deze naam moet
; afgesloten zijn door een spatie.
; Het doel address van de naam is DE.
; carry gezet >> fout

PATHSTART:
         DW 0
LASTITEM:DW 0


PARSENAME:
         ; in:    HL = source filename string, preceding spaces or tabs allowed
         ; DOS 1: DE = address of FCB - block to be filled with filename and
         ;             drive number, 0 = default, 1 = 'A:', 2 = 'B:'
         ; DOS 2: DE+1 = destination for drive/path/file string
         ;        ABC = default filename extension, A='P', B='A', C='S'

         ; out:   DE = parsed filename string
         ;        HL = address direct after drive/path/file string
         ;        BC = address of last item
	;	A = 0,	if no error occurred
	;		otherwise:
	;			0DBH, Invalid drive
         ;                          0DAH, Invalid filename
         ;                          0D9H, Invalid pathname
         ;                                  wild cards used when not permitted
         ; changes: only AF, AF', BC, DE and HL

;         PUSH DE
;         PUSH HL
;
;         OR A                       ; clear carry, no overruling
;         CALL SetExtension
;
;         POP HL
;         POP DE

         lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JZ near ptr PARSENAMEDOS1         ; jump if DOS 1

         lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf

PARSENAMEDOS2:
         PUSH cx                    ; push last characters of default extension
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al                    ; push first character of default extension

         INC dx                     ; reserve first byte for file handle

         MOV word ptr PATHSTART,dx

         PUSH dx                    ; save destination address

         CALL near ptr L7D92                 ; skip spaces and tabs

         PUSH bx                    ; save source address

         XCHG dx,bx                   ; DE = drive/path/file string address
         MOV word ptr LASTITEM,dx
         MOV cx,5BH                  ; B = 0 (no volume name), C = function
         CALL near ptr FILE_MSXDOS           ; Parse PathName

         ; HL = address of last item
         ; DE = first character after drive/path/file string

         PUSH cx
         PUSH bx
         MOV cx,word ptr LASTITEM
         OR al, al
         SBB bx,cx                  ; - start of original drive/path/file
         MOV cx,word ptr PATHSTART
         ADD bx,cx
         MOV word ptr LASTITEM,bx           ; address of last item in copied path
         POP bx
         POP cx

         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         XCHG dx,bx
         CALL near ptr GOBACK                ; go back if there where special characters
                                    ; at the end
         XCHG dx,bx
         POP ax
	xchg ah,al
	sahf

         POP bx                     ; HL = start address of parsed string

         OR al, al
         JNZ near ptr PARSENAMEDOS2_INVALID; jump if error occurred
                                    ; invalid file name

         MOV al,0D9H                  ; assume: error code = invalid pathname
         INC ch
         DEC ch
         JZ near ptr PARSENAMEDOS2_INVALID ; jump if error occurred
                                    ; nothing parsed --> invalid file name

         MOV al,ch                     ; A = parse flags

         POP cx                     ; BC = destination address

         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al                    ; save parse flags

PARSENAMEDOS2_LOOP:
         MOV al,bh                     ; address of termination character reached ?
         CMP al, dh
         JNZ near ptr PARSENAMEDOS2_1
         MOV al,bl
         CMP al, dl
         JZ near ptr PARSENAMEDOS2_2       ; jump if end found

PARSENAMEDOS2_1:
         MOV al,byte ptr [bx]
         xchg cx,bx
	MOV [bx],al
	xchg cx,bx                  ; copy character
         INC bx
         INC cx
         JMP near ptr  PARSENAMEDOS2_LOOP

PARSENAMEDOS2_2:

         POP ax
	xchg ah,al
	sahf                     ; A = parse flags

         TEST al,8
         JZ near ptr PARSENAMEDOS2_INVALID1; jump if no main filename specified

         TEST al,16
         JZ near ptr PARSENAMEDOS2_4       ; jump if filename extension not specified

         POP ax
	xchg ah,al
	sahf                     ; dump pushed
         POP ax
	xchg ah,al
	sahf                     ;   default filename extension

PARSENAMEDOS2_3:
         XOR al, al                      ; return no errors
         xchg cx,bx
	MOV [bx],al
	xchg cx,bx                  ; mark end of ASCIIZ string
         XCHG dx,bx                   ; HL = address after parsed string
         MOV cx,word ptr LASTITEM
         RET

PARSENAMEDOS2_4:
         MOV al,'.'
         xchg cx,bx
	MOV [bx],al
	xchg cx,bx                  ; add '.'
         INC cx
         POP ax
	xchg ah,al
	sahf
         POP bx

         CMP al, ' '
         JZ near ptr PARSENAMEDOS2_3       ; quit if first character = ' '

         xchg cx,bx
	MOV [bx],al
	xchg cx,bx                  ; first character of default extension
         INC cx
         MOV al,bh
         xchg cx,bx
	MOV [bx],al
	xchg cx,bx                  ; second character of default extension
         INC cx
         MOV al,bl
         xchg cx,bx
	MOV [bx],al
	xchg cx,bx                  ; third character of default extension
         INC cx
         JMP near ptr  PARSENAMEDOS2_3

PARSENAMEDOS2_INVALID:
         POP cx                     ; destination address
         JMP near ptr  PARSENAMEDOS2_INVALID2




PARSENAMEDOS2_INVALID1:
         MOV al,0D9H                  ; error code = Invalid pathname

PARSENAMEDOS2_INVALID2:
         POP cx                     ; first character of default extension
         POP cx                     ; last 2 characters of default extension

         OR al, al
         RET




PARSENAMEDOS1:
         lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf                  ; A = first character of default extension

         INC dx
         MOV word ptr LASTITEM,dx
         PUSH bx
         MOV bx,12 + 1               ; 8 spaces, dot, 3 spaces, \0
         ADD bx,dx
         XCHG dx,bx                   ; DE = address for FCB
         POP bx

;         LD A,8                     ; no wild cards
;                                    ; don't init: ext
;                                    ; init: name, drive
;                                    ; disable '='
	PUSH dx
	XCHG dx,bx
	MOV byte ptr [bx],0		; init as default drive
         INC bx
         CALL near ptr L7D12                 ; fill name with spaces (8 spaces)

         MOV byte ptr [bx],al                  ; first character of default extension
         INC bx
         MOV byte ptr [bx],ch                  ; second character
         INC bx
         MOV byte ptr [bx],cl                  ; third character
         INC bx

         XOR al, al
         MOV byte ptr [bx],al                  ; make zero
	INC bx
         MOV byte ptr [bx],al                  ; make zero
	INC bx
         MOV byte ptr [bx],al                  ; make zero
	INC bx
         MOV byte ptr [bx],al                  ; make zero
	XCHG dx,bx
	POP dx

;         BIT 0,A
;         JR Z,L7C9A
;
;         CALL L7D92                 ; skip spaces and tabs
;         CALL L7DBE                 ; starts with '=', ';' or ','
;         JR NZ,L7C9D
;
;         INC HL                     ; yes, skip over '=', ';' or ','

         CALL near ptr L7D92                 ; skip spaces and tabs

         CALL near ptr L7D9B
	JC near ptr L7CC1		; < space
	JZ near ptr L7CC1		; jump first character is one of
                                    ; ':."[]{}/+=;,', TAB or space
	MOV cl,al			; C = first capital
	INC bx
	MOV al,byte ptr [bx]
	DEC bx
         CMP al, ':'                     ; first capital followed by ':' (drive name)
	MOV al,cl			; A = first capital
	JNZ near ptr L7CC1		; jump if it wasn't a drive name
	INC bx
	INC bx			; point to first character after ':'
	SUB al, 'A'
	JC near ptr L7CBB		; jump illegal, < 'A'
	INC al
         CALL near ptr CHECKDRIVE
	JNC near ptr L7CC0		; jump if correct drive

L7CBB:	MOV al,0DBH		; return A = Illegal drive
	RET

L7CC0:	xchg dx,bx
	MOV [bx],al
	xchg dx,bx		; 1 = 'A:', 2 = 'B:' etc.
L7CC1:	INC dx
	MOV cl,0			; flag for no wildcards used yet
	MOV ch,8			; for 8 letters in filename
	CALL near ptr L7CD6		; parse filename
	MOV al,byte ptr [bx]
         CMP al, '.'                     ; is there an extension ?
	JNZ near ptr L7CD4		; no, quit

         INC bx                     ; yes, skip extension
	MOV ch,3
	CALL near ptr L7CDD		; parse extension

L7CD4:   PUSH cx
         PUSH bx

         MOV bx,word ptr LASTITEM
         MOV dx,14
         ADD bx,dx
         MOV dx,word ptr LASTITEM

         MOV cx,8

PART1:   MOV al,byte ptr [bx]
         CMP al, ' '
         JZ near ptr PART2
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         INC bx
         INC dx
         DEC cl
         JNZ near ptr PART1

PART2:
         ADD bx,cx
         MOV cx,3

         MOV al,byte ptr [bx]
         CMP al, ' '
         JZ near ptr PART3

         MOV al,'.'
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         INC dx

PART3:   MOV al,byte ptr [bx]
         CMP al, ' '
         JZ near ptr PART4
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         INC bx
         INC dx
         DEC cl
         JNZ near ptr PART3

PART4:   XOR al, al
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx                  ; end the ASCIIZ-string

         POP bx
         POP cx
         MOV al,cl                     ; return flag for wildcards
				; 0: no wildcards used
				; 1: wildcards used

         MOV cx,word ptr LASTITEM
	XOR al, al			; return with no errors
	RET

L7CD6:	CALL near ptr L7D9B
	JC near ptr L7CFD		; < space ? quit and increase DE with B
	JZ near ptr L7CFD		; special ? quit and increase DE with B

L7CDD:	CALL near ptr L7D9B
	JZ near ptr L7D03		; jump if special character
	JC near ptr L7D03		; < space
	INC bx
	INC ch
	DEC ch
	JZ near ptr L7CDD		; if B = 0 skip all until special of < space

         CMP al, '*'                     ; asterisk
	JZ near ptr L7CF6		; fill rest with '?'

	xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	INC dx
	DEC ch
         CMP al, '?'                     ; was this a wildcard
	JZ near ptr L7CF9

	JMP near ptr  L7CDD

L7CF6:	CALL near ptr L7D0C		; fill rest with '?'

L7CF9:   MOV cl,1                     ; wildcard used = true
         JMP near ptr  L7CDD                   ; continue

L7CFD:   MOV al,dl                     ; increase DE with letters left, from 8
	ADD al,ch
	MOV dl,al
	RETNC 
	INC dh
	RET

L7D03:   INC ch                      ; stil letters to go ?
	DEC ch
	RETZ 			; no, quit
         MOV al,' '                   ; yes, fill rest of letters with spaces
	JMP near ptr  L7D0E

L7D0A:   MOV ch,11

L7D0C:   MOV al,'?'                   ; fill with wildcards

L7D0E:   xchg dx,bx
	MOV [bx],al
	xchg dx,bx
	INC dx
	DEC ch
	JNZ near ptr L7D0E
	RET

L7D12:   PUSH cx
         MOV cl,8
L7D13:   MOV byte ptr [bx],20H                ; fill with spaces
	INC bx
	DEC cl
	JNZ near ptr L7D13
         POP cx
         RET

L7D92:	MOV al,byte ptr [bx]
	INC bx
	CALL near ptr L7DC7
	JZ near ptr L7D92
	DEC bx
	RET

L7D9B:   MOV al,byte ptr [bx]
         CMP al, 'a'                     ; < 'a' ?
	JC near ptr L7DA6		; yes, no lower
         CMP al, 'z'+1                   ; > 'z' ?
	JNC near ptr L7DA6		; yes, no lower

         SUB al, 20H                    ; make capital

L7DA6:   CMP al, 20H                     ; < spatie ?
         JC near ptr L7DA7

         PUSH cx
         PUSH bx
         MOV bx,offset SEPARATORTABLE
         MOV cx,offset SEPARATORTABLELENGTH
         CALL __CPIR
         POP bx
         POP cx
         RET

L7DA7:   XOR al, al                      ; return Zero
         RET

SEPARATORTABLE:
         DB ' .,;:=/+[]<>{}'
SEPARATORTABLELENGTH EQU $-SEPARATORTABLE

L7DC7:   CMP al, 9
	RETZ 

         CMP al, ' '
	RET

GOBACK:  DEC bx
         MOV al,byte ptr [bx]
         CMP al, '.'
         JZ near ptr GOBACKQUIT            ; jump to leave '.' where it is

         CALL near ptr L7DA6                 ; special character ?
         JZ near ptr GOBACK                ; yes,

GOBACKQUIT:
         INC bx
         RET

SETEXTENSION:
         ; in:    HL = address of filename
         ;        ABC = new extension
         ;        Carry set if extension is to be overruled
         ;        Carry clear if extension is not to be overruled
         ; out:   A, HL, BC unchanged

         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al                    ; save Carry
         PUSH cx
         PUSH bx                    ; save address of filename

         MOV dh,-1
         DEC bx
SETEXTENSION1:
         INC dh
         INC bx
         MOV al,byte ptr [bx]
         OR al, al
         JNZ near ptr SETEXTENSION1        ; repeat until HL = address of '\0'

         PUSH bx                    ; save address of '\0'

         INC dh
         DEC dh
         JZ near ptr SETEXTENSIONNODOT     ; jump if string was empty

         MOV ch,4

SETEXTENSION2:
         DEC bx
         MOV al,byte ptr [bx]
         CMP al, '.'
         JZ near ptr SETEXTENSIONDOTPRESENT; jump if '.' found

         CMP al, 5CH                     ; \\
         JZ near ptr SETEXTENSIONNODOT     ; jump if name delimiter found

         CMP al, ':'
         JZ near ptr SETEXTENSIONNODOT     ; jump if drivename delimiter found

         DEC dh
         JZ near ptr SETEXTENSIONNODOT     ; jump if no '.' found in first 3 chars

         DEC ch
	JNZ near ptr SETEXTENSION2
         JMP near ptr  SETEXTENSIONNODOT

SETEXTENSIONDOTPRESENT:
         POP dx                     ; throw address of '\0' away

         POP dx                     ; DE = filename address
                                    ; HL = address of dot

         XCHG dx,bx                   ; HL = filename address

         POP cx
         POP ax
	xchg ah,al
	sahf

         RETNC                      ; quit if not to be overruled

         XCHG dx,bx

SETEXTENSION5:
         MOV byte ptr [bx],'.'
         INC bx
         MOV byte ptr [bx],al
         INC bx
         MOV byte ptr [bx],ch
         INC bx
         MOV byte ptr [bx],cl
         INC bx
         MOV byte ptr [bx],0
         XCHG dx,bx
         RET

SETEXTENSIONNODOT:
         POP dx                     ; DE = address of '\0'
         POP bx                     ; HL = filename address

         POP cx                     ; pop extension
         POP ax
	xchg ah,al
	sahf

         XCHG dx,bx                   ; HL = address of '\0'
                                    ; DE = filename address
         JMP near ptr  SETEXTENSION5

         ; FUNCTION GetError: BYTE; EXTERNAL $F9CB;
GETERROR:; pascal function
         ; in:    ErrorNumber
         ; out:   HL = contents of ErrorNumber
         MOV al,byte ptr ERRORNUMBER
	MOV bl,al
	MOV bh,0
	XOR al, al
         MOV byte ptr ERRORNUMBER,al         ; clear for next disk action
         RET

SETERRORHANDLER:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         PUSH cx
         PUSH dx
         PUSH bx

         MOV bx,offset ERRORHANDLERPRESENT
         MOV al,byte ptr [bx]
         OR al, al
         JNZ near ptr ERRORHANDLERQUIT     ; quit if already on

         MOV byte ptr [bx],255                ; set error handler on

         XOR al, al
         MOV byte ptr ERRORNUMBER,al         ; clear for next disk action
         MOV byte ptr FATALERROR,al

IFDEF MSX
         MOV bx,word ptr 0F323H
         MOV word ptr OLDERRORVECTOR,bx

         MOV bx,offset ERRORVECTOR
         MOV word ptr 0F323H,bx             ; set new error vector

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JZ near ptr SETERRORHANDLER1      ; jump if DOS 1

         MOV bx,word ptr 0F325H
         MOV word ptr OLDABORTVECTOR,bx

         MOV bx,offset ABORTVECTOR
         MOV word ptr 0F325H,bx

         JMP near ptr  ERRORHANDLERQUIT

SETERRORHANDLER1:

         MOV bx,word ptr 0F1E6H
         MOV word ptr OLDABORTVECTOR,bx

         MOV bx,word ptr ABORTVECTOR
         MOV word ptr 0F1E6H,bx             ; set new abort vector

ENDIF    ; MSX

ERRORHANDLERQUIT:
         POP bx
         POP dx
         POP cx
         POP ax
	xchg ah,al
	sahf
	RET

RESERRORHANDLER:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         PUSH cx
         PUSH dx
         PUSH bx

         MOV bx,offset ERRORHANDLERPRESENT
         MOV al,byte ptr [bx]
         OR al, al
         JZ near ptr ERRORHANDLERQUIT      ; quit if already restored

         MOV byte ptr [bx],0                  ; set error handler off

IFDEF MSX
         MOV bx,word ptr OLDERRORVECTOR
         MOV word ptr 0F323H,bx             ; restore DOS 1/2 error vector

         MOV bx,word ptr OLDABORTVECTOR

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JZ near ptr RESERRORHANDLER1      ; jump if DOS 1

         MOV word ptr 0F325H,bx             ; restore DOS 2 abort vector
         JMP near ptr  ERRORHANDLERQUIT

RESERRORHANDLER1:
         MOV word ptr 0F1E6H,bx             ; restore DOS 1 abort vector
ENDIF    ; MSX

         JMP near ptr  ERRORHANDLERQUIT

DOSSTCK: DW 0

FILE_MSXDOS:
         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al
         MOV word ptr DOSSTCK,sp            ; stack pointer as if CALL was made !!
	MOV al,cl
         MOV byte ptr DOSFUNCTION,al
	POP ax
	xchg ah,al
	sahf

         PUSH si
         PUSH di
         CALL near ptr MSXDOS
         POP di
         POP si
         OR al, al
         MOV byte ptr ERRORNUMBER,al
         RETZ                       ; quit if no error

         CALL near ptr ABORT
         MOV byte ptr ERRORNUMBER,al
	OR al, al
	RET

ERRORNUMBER:      DB 0              ; DOS 2 error of last 'DosFunction'
DOSFUNCTION:      DB 0
DRIVENUMBER:      DB 0
ERRORDOS1:        DB 0
ERRORDOS2:        DB 0
ERRORDOS2_SEC:    DB 0
FATALERROR:       DB 0              ; 0 = no fatal error, NonZero = fatal

ERRORVECTOR:      DW ERRORROUTINE
ABORTVECTOR:      DW ABORTROUTINE

ERRORROUTINE:
         MOV byte ptr DRIVENUMBER,al         ; save
         MOV al,cl
         MOV byte ptr ERRORDOS1,al
         lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
         MOV byte ptr ERRORDOS2,al
         lahf
	xchg ah,al
	XCHG ax,word ptr [AF_]
	xchg ah,al
	sahf
         MOV al,ch
         MOV byte ptr ERRORDOS2_SEC,al

         MOV al,255
         MOV byte ptr FATALERROR,al

         MOV cl,2            ; Abort
         RET

ABORTROUTINE:
;         POP AF                     ; 12

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JZ near ptr ABORTROUTINE1         ; jump if DOS 1

         MOV al,byte ptr ERRORDOS2
         OR al, al
         RET

ABORTROUTINE1:
         MOV sp,word ptr DOSSTCK            ; quit via own stack saving
         RET

ABORT:   ; in:    A = error code
         ; out:   A = always a DOS 2 error code

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr ABORTDOS2            ; jump if DOS 2

         ; DOS 1
         MOV al,byte ptr FATALERROR
         OR al, al
         JNZ near ptr CONVERTFATALDOS1CODE ; jump if FatalError

         JMP near ptr  CONVERTDOS1CODE

ABORTDOS2:
         MOV al,byte ptr FATALERROR
         OR al, al
         JZ near ptr ABORTDOS2_1           ; jump if no FatalError
 
         MOV al,byte ptr ERRORNUMBER
         CMP al, 9DH
         JC near ptr ABORTDOS2_1
         CMP al, 9FH+1
         JNC near ptr ABORTDOS2_1

         ; return second code
         MOV al,byte ptr ERRORDOS2_SEC
         RET

ABORTDOS2_1:
         MOV al,byte ptr ERRORNUMBER
         RET

CONVERTFATALDOS1CODE:
         ; converts DOS 1 error code to DOS 2 error code
	; bits 1-3
	;	0 - Write protected disk
	;	2 - Drive not ready
	;	4 - Data (CRC) error
	;	6 - Seek error
	;	8 - Record not found
         ;       10 - Write fault (verify error)
         ;       12 - Other error
	; rest of the bits are ignored
         ; out:   A = equivalent DOS 2 error code
         PUSH cx
         PUSH bx
         MOV al,byte ptr ERRORDOS1
	ROR al,1
	AND al, 7
	MOV cl,al
	MOV ch,0
	MOV bx,offset FATALTAB
	ADD bx,cx
	MOV al,byte ptr [bx]		; maak van DOS 1 nummer een DOS 2 nummer
         POP bx
         POP cx
	RET

FATALTAB:
	; tabel for converting a DOS1 error code for a fatal error to
	; a corresponding DOS2 error code
         DB 0F8H                    ; 0, Write protected
         DB 0FCH                    ; 2, Not Ready, no disk in drive
         DB 0FAH                    ; 4, Data error, CRC error
         DB 0F3H                    ; 6, Seek error, track not found
         DB 0F9H                    ; 8, Sector not found
         DB 0FEH                    ; A, Write error
         DB 0FDH                    ; C, Disk error, unknown error

CONVERTDOS1CODE:
         ; in:    -
         ; out:   A = DOS 2 error code

         PUSH cx
         PUSH bx
         MOV bx,offset ERRORTAB
         MOV al,byte ptr DOSFUNCTION
	MOV cl,al			; C = number of last DOS-call

CONVERTDOS1CODE1:
	MOV al,byte ptr [bx]		; A = DOS-call number
         INC bx
	OR al, al
         JZ near ptr CONVERTDOS1CODE2      ; quit with error 255 if not found

	CMP al, cl			; DOS-call number found in tabel?
         JZ near ptr CONVERTDOS1CODE2      ; yes, quit loop

         INC bx                     ; point to next DOS-call number
         JMP near ptr  CONVERTDOS1CODE1        ; repeat until end of tabel

CONVERTDOS1CODE2:
         MOV al,byte ptr [bx]                  ; return DOS 2 error
         POP bx
         POP cx
         RET

ERRORTAB:
	; tabel for converting DOS1 non-fatal errors to a corresponding
	; DOS2 error code
         ;                            DOS1-call         if error then

         DB 0FH, 0D7H               ; open file,        file not found
         DB 10H, 0BAH               ; close file,       file handle disappeared
         DB 11H, 0D7H               ; search first,     file not found
         DB 12H, 0D7H               ; search next,      file not found
         DB 13H, 0D7H               ; delete file,      file not found
         DB 16H, 0D5H               ; create file,      root directory full
         DB 17H, 0D3H               ; rename file,      duplicate filename
         DB 26H, 0D4H               ; rand.block write, disk full
         DB 27H, 0C7H               ; rand.block read,  end of file
         DB 2BH, 0BEH               ; set date,         invalid date
         DB 2DH, 0BDH               ; set time,         invalid time
         DB 0  , 0FDH               ; quit if not found with error

; -------------------------------------------------------------

CREATEFILE:
         ; in:    HL = address of file name
         ;        DE = address of handle or unopened FCB
         ;        ABC = default extension
         ; out:   HL = address of handle or unopened FCB
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         MOV byte ptr OPENCREATEDEFAULT,al
         MOV word ptr OPENCREATEDEFAULT+1,cx

         MOV al,byte ptr DOS2PRESENT
         OR al, al

         MOV cl,44H                   ; DOS 2 create file
         JNZ near ptr OPENCREATEFILEDOS2

         ; DOS 1
         MOV cl,16H                   ; DOS 1 create file
         JMP near ptr  OPENCREATEFILEDOS1

OPENCREATEDEFAULT:
         db 3 dup (0)

OPENFILE:
         ; in:    HL = address of file name
         ; DOS 1: DE = address of handle followed by drive/path/filename
         ; DOS 2: DE = address of FCB
         ;        ABC = default extension
         ; out:   HL = address of handle or unopened FCB
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         MOV byte ptr OPENCREATEDEFAULT,al
         MOV word ptr OPENCREATEDEFAULT+1,cx

         MOV al,byte ptr DOS2PRESENT
         OR al, al

         MOV cl,43H                   ; DOS 2 open file
         JNZ near ptr OPENCREATEFILEDOS2

         ; DOS 1
         MOV cl,0FH                   ; DOS 1 open file

OPENCREATEFILEDOS1:
         PUSH cx                    ; save DOS 1 function
         PUSH dx                    ; save FCB address

         MOV al,byte ptr OPENCREATEDEFAULT
         MOV cx,word ptr OPENCREATEDEFAULT+1; ABC = default extension
         CALL near ptr PARSENAME             ; parse file name at HL to FCB at DE+14

;         LD HL,L005C
;         POP DE                     ; restore FCB address
;         PUSH DE
;         LD BC,FCB_LEN
;         LDIR                       ; copy filled in FCB to its destination

         POP bx                     ; HL = address of FCB

         POP cx                     ; C = DOS 1 function call

         PUSH bx

         OFF_HL 0 14
         PUSH bx

         OFF_HL 0 FCB_RECSIZE       ; goto extent byte
         MOV byte ptr [bx],0                  ; clear the FCB

         POP dx
         PUSH dx

         CALL near ptr FILE_MSXDOS

         POP bx                     ; HL = FCB address
         PUSH bx

         lahf
	xchg ah,al
	PUSH ax
	xchg ah,al                    ; save error + corresponding flags

         OFF_HL 0 FCB_RECSIZE       ; goto record size
         MOV byte ptr [bx],1                  ; record size = 1
         INC bx
         XOR al, al
         MOV byte ptr [bx],al

         OFF_HL FCB_RECSIZE+1 FCB_FILEPOS ; current file position
         MOV byte ptr [bx],al                  ; file position = 0
         INC bx
         MOV byte ptr [bx],al
         INC bx
         MOV byte ptr [bx],al
         INC bx
         MOV byte ptr [bx],al

         POP ax
	xchg ah,al
	sahf                     ;  A = error code

         POP bx                     ; HL+14
         POP bx                     ; HL = FCB address

	RET

OPENCREATEFILEDOS2:

         PUSH dx                    ; save address of handle

         PUSH cx                    ; save function number

         ;LD DE,TEMPFileName
         MOV al,byte ptr OPENCREATEDEFAULT
         MOV cx,word ptr OPENCREATEDEFAULT+1; ABC = default extension
         CALL near ptr PARSENAME             ; parse file name at HL to FCB at DE

         POP cx

         POP dx
         PUSH dx

;         EX DE,HL                   ; DE = address of filename
;         LD DE,TEMPFileName+1
         INC dx                     ; parsename placed the filename after
                                    ; the file handle
         XOR al, al                      ; no special permissions
         MOV ch,al

         CALL near ptr FILE_MSXDOS

         POP bx                     ; HL = address of handle
         RETNZ                      ; quit if not succeeded

         MOV byte ptr [bx],ch                  ; save handle
	XOR al, al			; return with NO_ERROR
	RET

FILESEEK:
         ; in:    BC = handle/FCB address
         ;        DEHL = new file position
         ; out:   DEHL = new file position
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         PUSH cx                    ; save for return

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr FILESEEKDOS2

         ; DOS 1
         PUSH dx                    ; save high-word
         PUSH bx                    ; save low-word

         MOV bh,ch                     ; HL = handle/FCB address
         MOV bl,cl
         OFF_HL 0 FCB_FILEPOS+14    ; current file position
         POP cx                     ; BC = low-word
         MOV byte ptr [bx],cl                  ; set low-word
         INC bx
         MOV byte ptr [bx],ch
         INC bx
         POP dx                     ; DE = high-word
         MOV byte ptr [bx],dl                  ; set high-word
         INC bx
         MOV byte ptr [bx],dh
         MOV bh,ch                     ; HL = high-word, DEHL complete again
         MOV bl,cl

         POP cx                     ; BC = handle/FCB address
         XOR al, al                      ; return with no errors
         RET

FILESEEKDOS2:
         xchg cx,bx
	MOV al,[bx]
	xchg cx,bx                  ; A = handle
	MOV ch,al
         MOV cl,4AH                   ; DOS 2 FileSeek function
	XOR al, al			; mode 0, relative to the file beginning
         CALL near ptr FILE_MSXDOS                ; Move File Handle Pointer, mode 0

         POP cx
         RET

FILEPOS:
         ; in:    BC = handle/FCB address
         ; out:   DEHL = current file position
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         PUSH cx

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr FILEPOSDOS2

         MOV bh,ch                     ; HL = handle/FCB address
         MOV bl,cl
         OFF_HL 0 FCB_FILEPOS+14

FILEPOS_FILESIZEDOS1:
         MOV cl,byte ptr [bx]                  ; BC = low-word
         INC bx
         MOV ch,byte ptr [bx]
         INC bx
         MOV dl,byte ptr [bx]                  ; DE = high-word
         INC bx
         MOV dh,byte ptr [bx]

         MOV bh,ch                     ; HL = low-word
         MOV bl,cl

         POP cx                     ; BC = handle/FCB address
         XOR al, al                      ; return with no errors
         RET

FILEPOSDOS2:
         MOV dx,0
	MOV bx,0
         xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
         MOV ch,al                     ; B = handle
	MOV cl,4AH
         MOV al,1                     ; mode 1, relative to current position
         CALL near ptr FILE_MSXDOS           ; Get File Handle Pointer, mode 1

         POP cx                     ; BC = handle/FCB address
         RET

FILESIZE:
         ; in:    BC = handle/FCB address
         ; out:   DEHL = file size
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr FILESIZEDOS2

         PUSH cx

         MOV bh,ch                     ; HL = handle/FCB address
         MOV bl,cl
         OFF_HL 0 FCB_FILESIZE+14

         JMP near ptr  FILEPOS_FILESIZEDOS1

FILESIZETEMP:
         db 4 dup (0)

FILESIZEDOS2:
         CALL near ptr FILEPOS               ; get curent file position
         MOV word ptr FILESIZETEMP,bx       ; save current file position
         MOV word ptr FILESIZETEMP+2,dx

         PUSH cx
         MOV dx,0
	MOV bx,0
         xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
         MOV ch,al                     ; B = handle
	MOV cl,4AH
	MOV al,2			; mode 2, relative to then end of the file
         CALL near ptr FILE_MSXDOS           ; Get file size, mode 2, changes position
         POP cx

         PUSH dx                    ; save file size on stack
         PUSH bx

         MOV bx,word ptr FILESIZETEMP        ; get current file position
         MOV dx,word ptr FILESIZETEMP+2
         CALL near ptr FILESEEK              ; restore old file position

         POP bx
         POP dx
         RET

READFILE:
         ; in:    BC = handle/FCB address
         ;        DE = destination address for data
         ;        HL = number of bytes to read
         ; out:   HL = number of bytes actually read
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         PUSH cx                    ; save handle/FCB address

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr READFILEDOS2

         PUSH bx

         MOV cl,1AH
         CALL near ptr FILE_MSXDOS           ; set DMA-address

         POP bx                     ; HL = number of bytes to read

         POP dx                     ; DE = FCB address

         XCHG dx,bx
         MOV cx,14
         ADD bx,cx                  ; DE += 14
         XCHG dx,bx

         PUSH dx

         MOV cl,27H                   ; DOS 1 random read
         CALL near ptr FILE_MSXDOS

READFILEQUIT:
         CMP al, 0C7H
         JNZ near ptr READFILEQUIT1

         XOR al, al

READFILEQUIT1:
         OR al, al
         POP cx                     ; BC = handle/FCB address
         RET

READFILEDOS2:
         xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
         MOV ch,al                     ; B = handle

         MOV cl,48H                   ; DOS 2 read file handle
         CALL near ptr FILE_MSXDOS

         JMP near ptr  READFILEQUIT

WRITEFILE:
         ; in:    BC = handle/FCB address
         ;        DE = source address for data
         ;        HL = number of bytes to write
         ; out:   HL = number of bytes actually written
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         PUSH cx                    ; save handle/FCB address

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr WRITEFILEDOS2

         PUSH bx

         MOV cl,1AH
         CALL near ptr FILE_MSXDOS           ; set DMA-address

         POP bx                     ; HL = number of bytes to write

         POP dx                     ; DE = FCB address

         XCHG dx,bx
         MOV cx,14
         ADD bx,cx                  ; DE += 14
         XCHG dx,bx

         PUSH dx

         MOV cl,26H                   ; DOS 1 random write
         CALL near ptr FILE_MSXDOS

         POP cx
         RET

WRITEFILEDOS2:
         xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
         MOV ch,al                     ; B = handle

         MOV cl,49H                   ; DOS 2 write file handle
         CALL near ptr FILE_MSXDOS

         POP cx                     ; BC = handle address
         RET


CLOSEFILE:
         ; in:    BC = handle/FCB address
         ; out:   BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A
         PUSH cx

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr CLOSEFILEDOS2

         MOV bh,ch
         MOV bl,cl
         OFF_HL 0 14
         XCHG dx,bx                   ; DE = FCB address

         MOV cl,10H                   ; DOS 1 close file
         CALL near ptr FILE_MSXDOS

         POP cx
         RET

CLOSEFILEDOS2:
         xchg cx,bx
	MOV al,[bx]
	xchg cx,bx
         MOV ch,al                     ; B = handle
         MOV cl,45H                   ; DOS 2 close file
         CALL near ptr FILE_MSXDOS

         POP cx
         RET

DELETEFILE:
         ; in:    DE = Drive/path/file ASCIIZ string
         ; out:    A = DOS 2 error code, 0 on success
         ;             flags are set on A
         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr DELETEFILEDOS2

         XCHG dx,bx
         MOV dx,offset TEMPFILENAME
         MOV al,' '
         MOV ch,al
         MOV cl,al                     ; ABC = default extension = '   '
         CALL near ptr PARSENAME             ; parse filename at HL to FCB at DE

         MOV dx,offset TEMPFILENAME
         MOV cl,13H                   ; DOS 1 delete file
         JMP near ptr  FILE_MSXDOS

DELETEFILEDOS2:
         MOV cl,4DH                   ; DOS 2 delete file
         JMP near ptr  FILE_MSXDOS

RENAMEFILE:
         ; in:    DE = old Drive/path/file ASCIIZ string
         ;        HL = new filename ASCIIZ string
         ; out:    A = DOS 2 error code, 0 on success
         ;             flags are set on A
         MOV al,byte ptr DOS2PRESENT
         OR al, al
         JNZ near ptr RENAMEFILEDOS2

         PUSH dx

         XCHG dx,bx                   ; HL = address to old filename
         MOV dx,offset TEMPFILENAME         ; address of first half of FCB
         MOV al,' '
         MOV ch,al
         MOV cl,al                     ; ABC = default extension = '   '
         CALL near ptr PARSENAME             ; parse filename at HL to FCB at DE

         MOV dx,offset TEMPFILENAME
         MOV cl,11H                   ; DOS 1 search first
         CALL near ptr FILE_MSXDOS

         POP bx                     ; HL = address of new filename

         RETNZ                      ; error, return with 0D7H, File not found

         MOV dx,offset TEMPFILENAME+16-14   ; Second FileName at FCB+16
         MOV al,' '
         MOV ch,al
         MOV cl,al                     ; ABC = default extension = '   '
         CALL near ptr PARSENAME             ; parse filename at HL to FCB at DE

         MOV dx,offset TEMPFILENAME
         MOV cl,17H                   ; DOS 1 rename file
         JMP near ptr  FILE_MSXDOS

RENAMEFILEDOS2:
         PUSH dx

         XCHG dx,bx                   ; DE = drive/path/file string address
         MOV cx,5BH                  ; B = 0 (no volume name), C = function
         CALL near ptr FILE_MSXDOS           ; Parse PathName, NewName

         ; HL = pointer to last item, start of ASCIIZ filename string

         POP dx

         RETNZ                      ; quit if error occurred during Parsing

         MOV cl,4EH                   ; DOS 2 rename file
         JMP near ptr  FILE_MSXDOS

GETCURRENTDIRECTORY:
         ; in:     B = drive number, 0 = default, 1 = A: etc.
         ;        DE = address where to put drive/path string
         ;             without a trailing backslash
         ; out:    A = DOS 2 error code, 0 on succes
         ;             flags are set on A

         MOV al,ch
         CALL near ptr CHECKDRIVE
         JC near ptr GETCURRENTDIRECTORY_IDRV

         ; A = drive number, default already converted
         MOV ch,al

         ADD al,'A'-1
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         INC dx
         MOV al,':'
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         INC dx

         MOV al,byte ptr DOS2PRESENT
         OR al, al
         RETZ                       ; return with no error if DOS 1

         MOV al,'\'
         xchg dx,bx
	MOV [bx],al
	xchg dx,bx
         INC dx

         MOV cl,59H                   ; DOS 2 get current directory
         JMP near ptr  FILE_MSXDOS


GETCURRENTDIRECTORY_IDRV:
         MOV al,0DBH
         OR al, al
         RET

;M       END
       END