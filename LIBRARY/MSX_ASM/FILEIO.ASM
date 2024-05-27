
       .model small
       .code
       .486

;!       .model small
;!       .code
;!       .486
;!       include pcmacros.inc
;!       include pcsim.inc

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

; DeleteFileHandle:
         ; in:    DE = handle/FCB address
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
         DB 0eh,6FH
         DB 0cdh
	DW  FILE_MSXDOS           ; get dos version
         DB 0b7h
         DB 20h,(INITFILEIO_1)-$-1         ; jump with no carry if DOS 1

         DB 78h
         DB 0feh, 2
         DB 3fh                        ; Carry if >= 2

INITFILEIO_1:
         DB 3eh,0
         DB 08fh                    ; Add 1 if DOS 2
         DB 32h
	DW DOS2PRESENT         ; 0 = not present, NonZero = present
         DB 0c9h

CHECKDRIVE:
	; in:  A = drive number, 0=default, 1='A:', 2='B:' etc.
	; out: A = drive number, 1='A:', 2='B:' etc. default filled in
         ;           carry set if drive number was illegal
	; changes: AF

         DB 0e5h
	DB 0d5h
	DB 0c5h
	DB 0b7h
         DB 28h,(CHECKDRIVEGETDEFAULT)-$-1  ; default drive

IFDEF MSX
         DB 0f5h
	DB 0eh,24
         DB 0cdh
	DW  FILE_MSXDOS           ; get login vector
	DB 0f1h
	; in A, 1='A:', 2='B:' enz.
	DB 0feh, 9			; must be lower than 9
	DB 3fh			; NC = correct
         DB 38h,(CHECKDRIVEQUIT)-$-1        ; quit with carry set if not correct

         DB 47h
CHECKDRIVELOOP:
         DB 0cbh,1dh
         DB 10h,( CHECKDRIVELOOP)-$-1
	DB 3fh			; complement >> NC = correct, anders fout
ELSE
         DB 0b7h                       ; set NC, always approve
                                    ; any drive on a PC
ENDIF    ; MAKEPC


CHECKDRIVEQUIT:
         DB 0c1h
	DB 0d1h
	DB 0e1h
	DB 0c9h

CHECKDRIVEGETDEFAULT:
         DB 0eh,25
         DB 0cdh
	DW  FILE_MSXDOS           ; Get Default Drive Name
	DB 3ch			; convert to 1=A, 2=B etc.
	DB 0b7h			; NC >> cannot make errors
         DB 18h,( CHECKDRIVEQUIT)-$-1

; ParseName
; Deze routine vormt de naam gegeven vanaf HL om tot een naam
; die direct in een FCB geplaatst kan worden. Deze naam moet
; afgesloten zijn door een spatie.
; Het doel address van de naam is DE.
; carry gezet >> fout

LASTITEM:
L1081:   DW 0

PATHSTART:
L1083:   DW 0

L1085:   DW 0

;LastItem:
;         DW 0                       ; 33e, 1081
;
;         DW 0                       ; new 33e, 1083
;
;PathStart:
;         DW 0                       ; 33e, 1085

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

         DB 08h

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 0cah
	DW PARSENAMEDOS1         ; jump if DOS 1

         DB 08h

PARSENAMEDOS2:
         DB 0c5h                    ; push last characters of default extension
         DB 0f5h                    ; push first character of default extension

         DB 13h                     ; reserve first byte for file handle

         DW 53edh,L1083              ; 33e, LD (PathStart),DE

         DB 0d5h                    ; save destination address

         DB 0cdh
	DW  L7D92                 ; skip spaces and tabs

         DB 0e5h                    ; save source address

         DB 22h
	DW L1081              ; 33e, LD (LastItem),HL
         DB 0ebh                   ; DE = drive/path/file string address
         DB 01h
	DW 5BH                  ; B = 0 (no volume name), C = function
         DB 0cdh
	DW  FILE_MSXDOS           ; Parse PathName

         ; HL = address of last item
         ; DE = first character after drive/path/file string

L10A6:
         DB 0c5h
         DB 0e5h
         DB 0edh,4bh
	DW L1081              ; 33e, LD BC,(LastItem)
         DB 0b7h
         DB 0EDH,042h                  ; - start of original drive/path/file
         DB 0edh,4bh
	DW L1083              ; 33e, LD BC,(PathStart)
         DB 09h
         DB 22h
	DW L1085 ; 33e, LD (LastItem),HL ; address of last item in copied path
         DB 0e1h
         DB 0c1h

         DB 0f5h
         DB 0ebh
         DB 0cdh
	DW  GOBACK                ; go back if there where special characters
                                    ; at the end
         DB 0ebh
         DB 0f1h

         DB 0e1h                     ; HL = start address of parsed string

         DB 0b7h
         DB 20h,(PARSENAMEDOS2_INVALID)-$-1; jump if error occurred
                                    ; invalid file name

         DB 3eh,0D9H                  ; assume: error code = invalid pathname
         DB 04h
         DB 05h
         DB 28h,(PARSENAMEDOS2_INVALID)-$-1 ; jump if error occurred
                                    ; nothing parsed --> invalid file name

         DB 78h                     ; A = parse flags

         DB 0c1h                     ; BC = destination address

         DB 0f5h                    ; save parse flags

PARSENAMEDOS2_LOOP:
         DB 7ch                     ; address of termination character reached ?
         DB 0bah
         DB 20h,(PARSENAMEDOS2_1)-$-1
         DB 7dh
         DB 0bbh
         DB 28h,(PARSENAMEDOS2_2)-$-1       ; jump if end found

PARSENAMEDOS2_1:
         DB 7eh
         DB 02h                  ; copy character
         DB 23h
         DB 03h
         DB 18h,( PARSENAMEDOS2_LOOP)-$-1

PARSENAMEDOS2_2:

         DB 0f1h                     ; A = parse flags

         DB 0cbh,05fh
         DB 28h,(PARSENAMEDOS2_INVALID1)-$-1; jump if no main filename specified

         DB 0cbh,067h
         DB 28h,(PARSENAMEDOS2_4)-$-1       ; jump if filename extension not specified

         DB 0f1h                     ; dump pushed
         DB 0f1h                     ;   default filename extension

PARSENAMEDOS2_3:
         DB 0afh                      ; return no errors
         DB 02h                  ; mark end of ASCIIZ string
         DB 0ebh                   ; HL = address after parsed string
         DB 0edh,4bh
	DW L1085              ; 33e, LD BC,(LastItem)
         DB 0c9h

PARSENAMEDOS2_4:
         DB 3eh,'.'
         DB 02h                  ; add '.'
         DB 03h
         DB 0f1h
         DB 0e1h

         DB 0feh, ' '
         DB 28h,(PARSENAMEDOS2_3)-$-1       ; quit if first character = ' '

         DB 02h                  ; first character of default extension
         DB 03h
         DB 7ch
         DB 02h                  ; second character of default extension
         DB 03h
         DB 7dh
         DB 02h                  ; third character of default extension
         DB 03h
         DB 18h,( PARSENAMEDOS2_3)-$-1

PARSENAMEDOS2_INVALID:
         DB 0c1h                     ; destination address
         DB 18h,( PARSENAMEDOS2_INVALID2)-$-1




PARSENAMEDOS2_INVALID1:
         DB 3eh,0D9H                  ; error code = Invalid pathname

PARSENAMEDOS2_INVALID2:
         DB 0c1h                     ; first character of default extension
         DB 0c1h                     ; last 2 characters of default extension

         DB 0b7h
         DB 0c9h




PARSENAMEDOS1:
         DB 08h                  ; A = first character of default extension

         DB 0c5h                    ; new 33e
         DB 0f5h                    ; new 33e

         DB 13h
         DW 53edh,L1083              ; 33e, LD (LastItem),DE
         DB 0e5h
         DB 21h
	DW 2 + 12 + 1           ; drive + 8 spaces, dot, 3 spaces, \0
         DB 019h
         DB 0ebh                   ; DE = address for FCB
         DB 0e1h

;         LD A,8                     ; no wild cards
;                                    ; don't init: ext
;                                    ; init: name, drive
;                                    ; disable '='
	DB 0d5h
	DB 0ebh
	DB 36h,0		; init as default drive
         DB 23h
         DB 0cdh
	DW  L7D12                 ; fill name with spaces (8 spaces)

         DB 77h                  ; first character of default extension
         DB 23h
         DB 70h                  ; second character
         DB 23h
         DB 71h                  ; third character
         DB 23h

         DB 0afh
         DB 77h                  ; make zero
	DB 23h
         DB 77h                  ; make zero
	DB 23h
         DB 77h                  ; make zero
	DB 23h
         DB 77h                  ; make zero
	DB 0ebh
	DB 0d1h

;         BIT 0,A
;         JR Z,L7C9A
;
;         CALL L7D92                 ; skip spaces and tabs
;         CALL L7DBE                 ; starts with '=', ';' or ','
;         JR NZ,L7C9D
;
;         INC HL                     ; yes, skip over '=', ';' or ','

         DB 0cdh
	DW  L7D92                 ; skip spaces and tabs

         DB 22h
	DW L1081              ; 33e
         DB 22h
	DW L1085              ; 33e

         DB 0eh,0                     ; 33e
         DB 0cdh
	DW  L7D9B                 ; 33e
	DB 38h,(L7CC1)-$-1		; < space
	DB 28h,(L7CC1)-$-1		; jump first character is one of
                                    ; ':."[]{}/+=;,', TAB or space
         DB 47h                     ; C = first capital
	DB 23h
	DB 7eh
	DB 2bh
         DB 0feh, ':'                     ; first capital followed by ':' (drive name)
         DB 78h                     ; A = first capital
	DB 20h,(L7CC1)-$-1		; jump if it wasn't a drive name

; 33e
         DB 23h
	DB 23h			; point to first character after ':'
	DB 0d6h, 'A'
	DB 38h,(L7CBB)-$-1		; jump illegal, < 'A'
	DB 3ch
         DB 0cdh
	DW  CHECKDRIVE
	DB 30h,(L7CC0)-$-1		; jump if correct drive

L7CBB:	DB 3eh,0DBH		; return A = Illegal drive
         DB 18h,( PARSENAMEDOS2_INVALID2)-$-1

; 33e: 115D
; 33e

L7CC0:   DB 22h
	DW L1085              ; 33e
         DB 12h                  ; 1 = 'A:', 2 = 'B:' etc.
L7CC1:	DB 13h
; 33e    LD C,0                     ; flag for no wildcards used yet
	DB 06h,8			; for 8 letters in filename
	DB 0cdh
	DW  L7CD6		; parse filename
	DB 7eh
         DB 0feh, '.'                     ; is there an extension ?
	DB 20h,(L7CD4)-$-1		; no, quit

         DB 0cbh,0e1h

         DB 23h                     ; yes, skip extension
	DB 06h,3
	DB 0cdh
	DW  L7CDD		; parse extension

L7CD4:   DB 0ebh
         DB 02ah
	DW L1083
         DB 0e5h
         DB 02ah
	DW L1081
         DB 0e5h
         DB 02ah
	DW L1085
         DB 41h
         DB 0afh
         DB 0c3h
	DW  L10A6

;         PUSH BC
;         PUSH HL
;
;         LD HL,(LastItem)
;         LD DE,14
;         ADD HL,DE
;         LD DE,(LastItem)
;
;         LD BC,8
;
;Part1:   LD A,(HL)
;         CP ' '
;         JR Z,Part2
;         LD (DE),A
;         INC HL
;         INC DE
;         DEC C
;         JR NZ,Part1
;
;Part2:
;         ADD HL,BC
;         LD BC,3
;
;         LD A,(HL)
;         CP ' '
;         JR Z,Part3
;
;         LD A,'.'
;         LD (DE),A
;         INC DE
;
;Part3:   LD A,(HL)
;         CP ' '
;         JR Z,Part4
;         LD (DE),A
;         INC HL
;         INC DE
;         DEC C
;         JR NZ,Part3
;
;Part4:   XOR A
;         LD (DE),A                  ; end the ASCIIZ-string
;
;         POP HL
;         POP BC
;         LD A,C                     ; return flag for wildcards
;                                    ; 0: no wildcards used
;                                    ; 1: wildcards used
;
;         LD BC,(LastItem)
;         XOR A                      ; return with no errors
;         RET

L7CD6:	DB 0cdh
	DW  L7D9B
	DB 38h,(L7CFD)-$-1		; < space ? quit and increase DE with B
	DB 28h,(L7CFD)-$-1		; special ? quit and increase DE with B

         DB 0cbh,0d9h

L7CDD:	DB 0cdh
	DW  L7D9B
	DB 28h,(L7D03)-$-1		; jump if special character
	DB 38h,(L7D03)-$-1		; < space
	DB 23h
	DB 04h
	DB 05h
	DB 28h,(L7CDD)-$-1		; if B = 0 skip all until special of < space

         DB 0feh, '*'                     ; asterisk
	DB 28h,(L7CF6)-$-1		; fill rest with '?'

	DB 12h
	DB 13h
	DB 05h
         DB 0feh, '?'                     ; was this a wildcard
	DB 28h,(L7CF9)-$-1

	DB 18h,( L7CDD)-$-1

L7CF6:	DB 0cdh
	DW  L7D0C		; fill rest with '?'

L7CF9:
;         LD C,1                     ; wildcard used = true
         DB 18h,( L7CDD)-$-1                   ; continue


                                    ; 33e 11AC
L7CFD:   DB 7bh                     ; increase DE with letters left, from 8
	DB 080h
	DB 5fh
	DB 0d0h
	DB 14h
	DB 0c9h

                                    ; 33e 11B2
L7D03:   DB 04h                      ; stil letters to go ?
	DB 05h
	DB 0c8h			; no, quit
         DB 3eh,' '                   ; yes, fill rest of letters with spaces
	DB 18h,( L7D0E)-$-1

L7D0A:   DB 06h,11                    ; 33e 11B9

L7D0C:   DB 3eh,'?'                   ; fill with wildcards

L7D0E:   DB 12h
	DB 13h
	DB 10h,( L7D0E)-$-1
	DB 0c9h

L7D12:   DB 0c5h                    ; 33e 11C2
         DB 0eh,8
L7D13:   DB 36h,20H                ; fill with spaces
	DB 23h
	DB 0dh
	DB 20h,(L7D13)-$-1
         DB 0c1h
         DB 0c9h

L7D92:   DB 7eh                  ; 33e 11CD
	DB 23h
	DB 0cdh
	DW  L7DC7
	DB 28h,(L7D92)-$-1
	DB 2bh
	DB 0c9h

L7D9B:   DB 7eh                  ; 33e 11D6
         DB 0feh, 'a'                     ; < 'a' ?
	DB 38h,(L7DA6)-$-1		; yes, no lower
         DB 0feh, 'z'+1                   ; > 'z' ?
	DB 30h,(L7DA6)-$-1		; yes, no lower

         DB 0d6h, 20H                    ; make capital

L7DA6:   DB 0feh, 20H                     ; < spatie ?
         DB 38h,(L7DA7)-$-1

         DB 0c5h
         DB 0e5h
         DB 21h
	DW SEPARATORTABLE
         DB 01h
	DW SEPARATORTABLELENGTH
         DB 0edh,0b1h
         DB 0e1h
         DB 0c1h
         DB 0c9h

L7DA7:   DB 0afh                      ; return Zero
         DB 0c9h

SEPARATORTABLE:
         DB ' .,;:=/+[]<>{}'
SEPARATORTABLELENGTH EQU $-SEPARATORTABLE

L7DC7:   DB 0feh, 9
	DB 0c8h

         DB 0feh, ' '
	DB 0c9h

GOBACK:  DB 2bh
         DB 7eh
         DB 0feh, '.'
         DB 28h,(GOBACKQUIT)-$-1            ; jump to leave '.' where it is

         DB 0cdh
	DW  L7DA6                 ; special character ?
         DB 28h,(GOBACK)-$-1                ; yes,

GOBACKQUIT:
         DB 23h
         DB 0c9h

SETEXTENSION:
         ; in:    HL = address of filename
         ;        ABC = new extension
         ;        Carry set if extension is to be overruled
         ;        Carry clear if extension is not to be overruled
         ; out:   A, HL, BC unchanged

         DB 0f5h                    ; save Carry
         DB 0c5h
         DB 0e5h                    ; save address of filename

         DB 16h,-1
         DB 2bh
SETEXTENSION1:
         DB 14h
         DB 23h
         DB 7eh
         DB 0b7h
         DB 20h,(SETEXTENSION1)-$-1        ; repeat until HL = address of '\0'

         DB 0e5h                    ; save address of '\0'

         DB 14h
         DB 15h
         DB 28h,(SETEXTENSIONNODOT)-$-1     ; jump if string was empty

         DB 06h,4

SETEXTENSION2:
         DB 2bh
         DB 7eh
         DB 0feh, '.'
         DB 28h,(SETEXTENSIONDOTPRESENT)-$-1; jump if '.' found

         DB 0feh, 5CH                     ; \\
         DB 28h,(SETEXTENSIONNODOT)-$-1     ; jump if name delimiter found

         DB 0feh, ':'
         DB 28h,(SETEXTENSIONNODOT)-$-1     ; jump if drivename delimiter found

         DB 15h
         DB 28h,(SETEXTENSIONNODOT)-$-1     ; jump if no '.' found in first 3 chars

         DB 10h,( SETEXTENSION2)-$-1
         DB 0c3h
	DW  SETEXTENSIONNODOT

SETEXTENSIONDOTPRESENT:
         DB 0d1h                     ; throw address of '\0' away

         DB 0d1h                     ; DE = filename address
                                    ; HL = address of dot

         DB 0ebh                   ; HL = filename address

         DB 0c1h
         DB 0f1h

         DB 0d0h                     ; quit if not to be overruled

         DB 0ebh

SETEXTENSION5:
         DB 36h,'.'
         DB 23h
         DB 77h
         DB 23h
         DB 70h
         DB 23h
         DB 71h
         DB 23h
         DB 36h,0
         DB 0ebh
         DB 0c9h

SETEXTENSIONNODOT:
         DB 0d1h                     ; DE = address of '\0'
         DB 0e1h                     ; HL = filename address

         DB 0c1h                     ; pop extension
         DB 0f1h

         DB 0ebh                   ; HL = address of '\0'
                                    ; DE = filename address
         DB 18h,( SETEXTENSION5)-$-1

         ; FUNCTION GetError: BYTE; EXTERNAL $F9CB;
GETERROR:; pascal function
         ; in:    ErrorNumber
         ; out:   HL = contents of ErrorNumber
         DB 3ah
	DW ERRORNUMBER
	DB 6fh
	DB 26h,0
	DB 0afh
         DB 32h
	DW ERRORNUMBER         ; clear for next disk action
         DB 0c9h

SETERRORHANDLER:
         DB 0f5h
         DB 0c5h
         DB 0d5h
         DB 0e5h

         DB 21h
	DW ERRORHANDLERPRESENT
         DB 7eh
         DB 0b7h
         DB 20h,(ERRORHANDLERQUIT)-$-1     ; quit if already on

         DB 36h,255                ; set error handler on

         DB 0afh
         DB 32h
	DW ERRORNUMBER         ; clear for next disk action
         DB 32h
	DW FATALERROR

IFDEF MSX
         DB 02ah
	DW 0F323H
         DB 22h
	DW OLDERRORVECTOR

         DB 21h
	DW ERRORVECTOR
         DB 22h
	DW 0F323H             ; set new error vector

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 28h,(SETERRORHANDLER1)-$-1      ; jump if DOS 1

         DB 02ah
	DW 0F325H
         DB 22h
	DW OLDABORTVECTOR

         DB 21h
	DW ABORTVECTOR
         DB 22h
	DW 0F325H

         DB 18h,( ERRORHANDLERQUIT)-$-1

SETERRORHANDLER1:

         DB 02ah
	DW 0F1E6H
         DB 22h
	DW OLDABORTVECTOR

         DB 02ah
	DW ABORTVECTOR
         DB 22h
	DW 0F1E6H             ; set new abort vector

ENDIF    ; MSX

ERRORHANDLERQUIT:
         DB 0e1h
         DB 0d1h
         DB 0c1h
         DB 0f1h
	DB 0c9h

RESERRORHANDLER:
         DB 0f5h
         DB 0c5h
         DB 0d5h
         DB 0e5h

         DB 21h
	DW ERRORHANDLERPRESENT
         DB 7eh
         DB 0b7h
         DB 28h,(ERRORHANDLERQUIT)-$-1      ; quit if already restored

         DB 36h,0                  ; set error handler off

IFDEF MSX
         DB 02ah
	DW OLDERRORVECTOR
         DB 22h
	DW 0F323H             ; restore DOS 1/2 error vector

         DB 02ah
	DW OLDABORTVECTOR

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 28h,(RESERRORHANDLER1)-$-1      ; jump if DOS 1

         DB 22h
	DW 0F325H             ; restore DOS 2 abort vector
         DB 18h,( ERRORHANDLERQUIT)-$-1

RESERRORHANDLER1:
         DB 22h
	DW 0F1E6H             ; restore DOS 1 abort vector
ENDIF    ; MSX

         DB 18h,( ERRORHANDLERQUIT)-$-1

DOSSTCK: DW 0

FILE_MSXDOS:
         DB 0f5h
         DW 73edh,DOSSTCK            ; stack pointer as if CALL was made !!
	DB 79h
         DB 32h
	DW DOSFUNCTION
	DB 0f1h

         DB 0ddh,0e5h
         DB 0fdh,0e5h
         DB 0cdh
	DW  MSXDOS
         DB 0fdh,0e1h
         DB 0ddh,0e1h
         DB 0b7h
         DB 32h
	DW ERRORNUMBER
         DB 0c8h                      ; quit if no error

         DB 0cdh
	DW  ABORT
         DB 32h
	DW ERRORNUMBER
	DB 0b7h
	DB 0c9h

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
         DB 32h
	DW DRIVENUMBER         ; save
         DB 79h
         DB 32h
	DW ERRORDOS1
         DB 08h
         DB 32h
	DW ERRORDOS2
         DB 08h
         DB 78h
         DB 32h
	DW ERRORDOS2_SEC

         DB 3eh,255
         DB 32h
	DW FATALERROR

         DB 0eh,2            ; Abort
         DB 0c9h

ABORTROUTINE:
;         POP AF                     ; 12

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 28h,(ABORTROUTINE1)-$-1         ; jump if DOS 1

         DB 3ah
	DW ERRORDOS2
         DB 0b7h
         DB 0c9h

ABORTROUTINE1:
         DB 0edh,7bh
	DW DOSSTCK            ; quit via own stack saving
         DB 0c9h

ABORT:   ; in:    A = error code
         ; out:   A = always a DOS 2 error code

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(ABORTDOS2)-$-1            ; jump if DOS 2

         ; DOS 1
         DB 3ah
	DW FATALERROR
         DB 0b7h
         DB 0c2h
	DW CONVERTFATALDOS1CODE ; jump if FatalError

         DB 0c3h
	DW  CONVERTDOS1CODE

ABORTDOS2:
         DB 3ah
	DW FATALERROR
         DB 0b7h
         DB 0cah
	DW ABORTDOS2_1           ; jump if no FatalError
 
         DB 3ah
	DW ERRORNUMBER
         DB 0feh, 9DH
         DB 38h,(ABORTDOS2_1)-$-1
         DB 0feh, 9FH+1
         DB 30h,(ABORTDOS2_1)-$-1

         ; return second code
         DB 3ah
	DW ERRORDOS2_SEC
         DB 0c9h

ABORTDOS2_1:
         DB 3ah
	DW ERRORNUMBER
         DB 0c9h

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
         DB 0c5h
         DB 0e5h
         DB 3ah
	DW ERRORDOS1
	DB 0fh
	DB 0e6h, 7
	DB 4fh
	DB 06h,0
	DB 21h
	DW FATALTAB
	DB 09h
	DB 7eh		; maak van DOS 1 nummer een DOS 2 nummer
         DB 0e1h
         DB 0c1h
	DB 0c9h

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

         DB 0c5h
         DB 0e5h
         DB 21h
	DW ERRORTAB
         DB 3ah
	DW DOSFUNCTION
	DB 4fh			; C = number of last DOS-call

CONVERTDOS1CODE1:
	DB 7eh		; A = DOS-call number
         DB 23h
	DB 0b7h
         DB 28h,(CONVERTDOS1CODE2)-$-1      ; quit with error 255 if not found

	DB 0b9h			; DOS-call number found in tabel?
         DB 28h,(CONVERTDOS1CODE2)-$-1      ; yes, quit loop

         DB 23h                     ; point to next DOS-call number
         DB 18h,( CONVERTDOS1CODE1)-$-1        ; repeat until end of tabel

CONVERTDOS1CODE2:
         DB 7eh                  ; return DOS 2 error
         DB 0e1h
         DB 0c1h
         DB 0c9h

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

         DB 32h
	DW OPENCREATEDEFAULT
         DW 43edh,OPENCREATEDEFAULT+1

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h

         DB 0eh,44H                   ; DOS 2 create file
         DB 20h,(OPENCREATEFILEDOS2)-$-1

         ; DOS 1
         DB 0eh,16H                   ; DOS 1 create file
         DB 18h,( OPENCREATEFILEDOS1)-$-1

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

         DB 32h
	DW OPENCREATEDEFAULT
         DW 43edh,OPENCREATEDEFAULT+1

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h

         DB 0eh,43H                   ; DOS 2 open file
         DB 20h,(OPENCREATEFILEDOS2)-$-1

         ; DOS 1
         DB 0eh,0FH                   ; DOS 1 open file

OPENCREATEFILEDOS1:
         DB 0c5h                    ; save DOS 1 function
         DB 0d5h                    ; save FCB address

         DB 3ah
	DW OPENCREATEDEFAULT
         DB 0edh,4bh
	DW OPENCREATEDEFAULT+1; ABC = default extension
         DB 0cdh
	DW  PARSENAME             ; parse file name at HL to FCB at DE+16

;         LD HL,L005C
;         POP DE                     ; restore FCB address
;         PUSH DE
;         LD BC,FCB_LEN
;         LDIR                       ; copy filled in FCB to its destination

         DB 0e1h                     ; HL = address of FCB

         DB 0c1h                     ; C = DOS 1 function call

         DB 0e5h

         OFF_HL 0 16
         DB 0e5h

         OFF_HL 0 FCB_RECSIZE       ; goto extent byte
         DB 36h,0                  ; clear the FCB

         DB 0d1h
         DB 0d5h

         DB 0cdh
	DW  FILE_MSXDOS

         DB 0e1h                     ; HL = FCB address
         DB 0e5h

         DB 0f5h                    ; save error + corresponding flags

         OFF_HL 0 FCB_RECSIZE       ; goto record size
         DB 36h,1                  ; record size = 1
         DB 23h
         DB 0afh
         DB 77h

         OFF_HL FCB_RECSIZE+1 FCB_FILEPOS ; current file position
         DB 77h                  ; file position = 0
         DB 23h
         DB 77h
         DB 23h
         DB 77h
         DB 23h
         DB 77h

         DB 0f1h                     ;  A = error code

         DB 0e1h                     ; HL+16
         DB 0e1h                     ; HL = FCB address

	DB 0c9h

OPENCREATEFILEDOS2:

         DB 0d5h                    ; save address of handle

         DB 0c5h                    ; save function number

         ;LD DE,TEMPFileName
         DB 3ah
	DW OPENCREATEDEFAULT
         DB 0edh,4bh
	DW OPENCREATEDEFAULT+1; ABC = default extension
         DB 0cdh
	DW  PARSENAME             ; parse file name at HL to FCB at DE

         DB 0c1h

         DB 0d1h
         DB 0d5h

;         EX DE,HL                   ; DE = address of filename
;         LD DE,TEMPFileName+1
         DB 13h                     ; parsename placed the filename after
                                    ; the file handle
         DB 0afh                      ; no special permissions
         DB 47h

         DB 0cdh
	DW  FILE_MSXDOS

         DB 0e1h                     ; HL = address of handle
         DB 0c0h                     ; quit if not succeeded

         DB 70h                  ; save handle
	DB 0afh			; return with NO_ERROR
	DB 0c9h

FILESEEK:
         ; in:    BC = handle/FCB address
         ;        DEHL = new file position
         ; out:   DEHL = new file position
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         DB 0c5h                    ; save for return

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(FILESEEKDOS2)-$-1

         ; DOS 1
         DB 0d5h                    ; save high-word
         DB 0e5h                    ; save low-word

         DB 60h                     ; HL = handle/FCB address
         DB 69h
         OFF_HL 0 FCB_FILEPOS+16 ; 33e +14    ; current file position
         DB 0c1h                     ; BC = low-word
         DB 71h                  ; set low-word
         DB 23h
         DB 70h
         DB 23h
         DB 0d1h                     ; DE = high-word
         DB 73h                  ; set high-word
         DB 23h
         DB 72h
         DB 60h                     ; HL = high-word, DEHL complete again
         DB 69h

         DB 0c1h                     ; BC = handle/FCB address
         DB 0afh                      ; return with no errors
         DB 0c9h

FILESEEKDOS2:
         DB 0ah                  ; A = handle
	DB 47h
         DB 0eh,4AH                   ; DOS 2 FileSeek function
	DB 0afh			; mode 0, relative to the file beginning
         DB 0cdh
	DW  FILE_MSXDOS                ; Move File Handle Pointer, mode 0

         DB 0c1h
         DB 0c9h

FILEPOS:
         ; in:    BC = handle/FCB address
         ; out:   DEHL = current file position
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         DB 0c5h

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(FILEPOSDOS2)-$-1

         DB 60h                     ; HL = handle/FCB address
         DB 69h
         OFF_HL 0 FCB_FILEPOS+16    ; 33e, +14

FILEPOS_FILESIZEDOS1:
         DB 4eh                  ; BC = low-word
         DB 23h
         DB 46h
         DB 23h
         DB 5eh                  ; DE = high-word
         DB 23h
         DB 56h

         DB 60h                     ; HL = low-word
         DB 69h

         DB 0c1h                     ; BC = handle/FCB address
         DB 0afh                      ; return with no errors
         DB 0c9h

FILEPOSDOS2:
         DB 11h
	DW 0
	DB 21h
	DW 0
         DB 0ah
         DB 47h                     ; B = handle
	DB 0eh,4AH
         DB 3eh,1                     ; mode 1, relative to current position
         DB 0cdh
	DW  FILE_MSXDOS           ; Get File Handle Pointer, mode 1

         DB 0c1h                     ; BC = handle/FCB address
         DB 0c9h

FILESIZE:
         ; in:    BC = handle/FCB address
         ; out:   DEHL = file size
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(FILESIZEDOS2)-$-1

         DB 0c5h

         DB 60h                     ; HL = handle/FCB address
         DB 69h
         OFF_HL 0 FCB_FILESIZE+16   ; 33e, +14

         DB 0c3h
	DW  FILEPOS_FILESIZEDOS1

FILESIZETEMP:
         db 4 dup (0)

FILESIZEDOS2:
         DB 0cdh
	DW  FILEPOS               ; get curent file position
         DB 22h
	DW FILESIZETEMP       ; save current file position
         DW 53edh,FILESIZETEMP+2

         DB 0c5h
         DB 11h
	DW 0
	DB 21h
	DW 0
         DB 0ah
         DB 47h                     ; B = handle
	DB 0eh,4AH
	DB 3eh,2			; mode 2, relative to then end of the file
         DB 0cdh
	DW  FILE_MSXDOS           ; Get file size, mode 2, changes position
         DB 0c1h

         DB 0d5h                    ; save file size on stack
         DB 0e5h

         DB 02ah
	DW FILESIZETEMP        ; get current file position
         DB 0edh,5bh
	DW FILESIZETEMP+2
         DB 0cdh
	DW  FILESEEK              ; restore old file position

         DB 0e1h
         DB 0d1h
         DB 0c9h

READFILE:
         ; in:    BC = handle/FCB address
         ;        DE = destination address for data
         ;        HL = number of bytes to read
         ; out:   HL = number of bytes actually read
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         DB 0c5h                    ; save handle/FCB address

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(READFILEDOS2)-$-1

         DB 0e5h                    ; save number of bytes to read

         DB 0eh,1AH
         DB 0cdh
	DW  FILE_MSXDOS           ; set DMA-address

         DB 0e1h                     ; HL = number of bytes to read

         DB 0d1h                     ; DE = handle/FCB address

         DB 0d5h                    ; 33e, save handle/FCB address

         DB 0ebh
         DB 01h
	DW 16                   ; 33e, 14
         DB 09h                  ; 33e, DE += 14
         DB 0ebh

; 33e    PUSH DE

         DB 0eh,27H                   ; DOS 1 random read
         DB 0cdh
	DW  FILE_MSXDOS

READFILEQUIT:
         DB 0feh, 0C7H
         DB 20h,(READFILEQUIT1)-$-1

         DB 0afh

READFILEQUIT1:
         DB 0b7h
         DB 0c1h                     ; BC = handle/FCB address
         DB 0c9h

READFILEDOS2:
         DB 0ah
         DB 47h                     ; B = handle

         DB 0eh,48H                   ; DOS 2 read file handle
         DB 0cdh
	DW  FILE_MSXDOS

         DB 18h,( READFILEQUIT)-$-1

WRITEFILE:
         ; in:    BC = handle/FCB address
         ;        DE = source address for data
         ;        HL = number of bytes to write
         ; out:   HL = number of bytes actually written
         ;        BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A

         DB 0c5h                    ; save handle/FCB address

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(WRITEFILEDOS2)-$-1

         DB 0e5h

         DB 0eh,1AH
         DB 0cdh
	DW  FILE_MSXDOS           ; set DMA-address

         DB 0e1h                     ; HL = number of bytes to write

         DB 0d1h                     ; DE = handle/FCB address
         DB 0d5h                    ; save handle/FCB adress

         DB 0ebh
         DB 01h
	DW 16                   ; 33e, 14
         DB 09h                  ; 33e, DE += 14
         DB 0ebh

; 33e    PUSH DE

         DB 0eh,26H                   ; DOS 1 random write
         DB 0cdh
	DW  FILE_MSXDOS

         DB 0c1h                     ; BC = handle/FCB address
         DB 0c9h

WRITEFILEDOS2:
         DB 0ah
         DB 47h                     ; B = handle

         DB 0eh,49H                   ; DOS 2 write file handle
         DB 0cdh
	DW  FILE_MSXDOS

         DB 0c1h                     ; BC = handle address
         DB 0c9h


CLOSEFILE:
         ; in:    BC = handle/FCB address
         ; out:   BC = handle/FCB address
         ;         A = DOS 2 error code, 0 on success
         ;             flags are set on A
         DB 0c5h

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(CLOSEFILEDOS2)-$-1

         DB 60h
         DB 69h
         OFF_HL 0 16                ; 33e, 14
         DB 0ebh                   ; DE = FCB address

         DB 0eh,10H                   ; DOS 1 close file
         DB 0cdh
	DW  FILE_MSXDOS

         DB 0c1h
         DB 0c9h

CLOSEFILEDOS2:
         DB 0ah
         DB 47h                     ; B = handle
         DB 0eh,45H                   ; DOS 2 close file
         DB 0cdh
	DW  FILE_MSXDOS

         DB 0c1h
         DB 0c9h

DELETEFILE:
         ; in:    DE = Drive/path/file ASCIIZ string
         ; out:    A = DOS 2 error code, 0 on success
         ;             flags are set on A
         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(DELETEFILEDOS2)-$-1

         DB 0ebh
         DB 11h
	DW TEMPFILENAME
         DB 3eh,' '
         DB 47h
         DB 4fh                     ; ABC = default extension = '   '
         DB 0cdh
	DW  PARSENAME             ; parse filename at HL to FCB at DE

         DB 11h
	DW TEMPFILENAME + 16    ; 33e
         DB 0eh,13H                   ; DOS 1 delete file
         DB 0c3h
	DW  FILE_MSXDOS

DELETEFILEDOS2:
         DB 0eh,4DH                   ; DOS 2 delete file
         DB 0c3h
	DW  FILE_MSXDOS

DELETEFILEHANDLE:
         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(DELETEFILEHANDLEDOS2)-$-1

         DB 21h
	DW 16
         DB 019h
         DB 0ebh
         DB 0eh,13H
         DB 0c3h
	DW  FILE_MSXDOS

DELETEFILEHANDLEDOS2:
         DB 1ah
         DB 47h
         DB 0eh,52H
         DB 0c3h
	DW  FILE_MSXDOS

RENAMEFILE:
         ; in:    DE = old Drive/path/file ASCIIZ string
         ;        HL = new filename ASCIIZ string
         ; out:    A = DOS 2 error code, 0 on success
         ;             flags are set on A
         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 20h,(RENAMEFILEDOS2)-$-1

         DB 0d5h

         DB 0ebh                   ; HL = address to old filename
         DB 11h
	DW TEMPFILENAME         ; address of first half of FCB
         DB 3eh,' '
         DB 47h
         DB 4fh                     ; ABC = default extension = '   '
         DB 0cdh
	DW  PARSENAME             ; parse filename at HL to FCB at DE

         DB 11h
	DW TEMPFILENAME
         DB 0eh,11H                   ; DOS 1 search first
         DB 0cdh
	DW  FILE_MSXDOS

         DB 0e1h                     ; HL = address of new filename

         DB 0c0h                     ; error, return with 0D7H, File not found

         DB 11h
	DW TEMPFILENAME+16-14   ; Second FileName at FCB+16
         DB 3eh,' '
         DB 47h
         DB 4fh                     ; ABC = default extension = '   '
         DB 0cdh
	DW  PARSENAME             ; parse filename at HL to FCB at DE

         DB 11h
	DW TEMPFILENAME
         DB 0eh,17H                   ; DOS 1 rename file
         DB 0c3h
	DW  FILE_MSXDOS

RENAMEFILEDOS2:
         DB 0d5h

         DB 0ebh                   ; DE = drive/path/file string address
         DB 01h
	DW 5BH                  ; B = 0 (no volume name), C = function
         DB 0cdh
	DW  FILE_MSXDOS           ; Parse PathName, NewName

         ; HL = pointer to last item, start of ASCIIZ filename string

         DB 0d1h

         DB 0c0h                     ; quit if error occurred during Parsing

         DB 0eh,4EH                   ; DOS 2 rename file
         DB 0c3h
	DW  FILE_MSXDOS

GETCURRENTDIRECTORY:
         ; in:     B = drive number, 0 = default, 1 = A: etc.
         ;        DE = address where to put drive/path string
         ;             without a trailing backslash
         ; out:    A = DOS 2 error code, 0 on succes
         ;             flags are set on A

         DB 78h
         DB 0cdh
	DW  CHECKDRIVE
         DB 38h,(GETCURRENTDIRECTORY_IDRV)-$-1

         ; A = drive number, default already converted
         DB 47h

         DB 0c6h,'A'-1
         DB 12h
         DB 13h
         DB 3eh,':'
         DB 12h
         DB 13h

         DB 3ah
	DW DOS2PRESENT
         DB 0b7h
         DB 0c8h                      ; return with no error if DOS 1

         DB 3eh,'\'
         DB 12h
         DB 13h

         DB 0eh,59H                   ; DOS 2 get current directory
         DB 0c3h
	DW  FILE_MSXDOS


GETCURRENTDIRECTORY_IDRV:
         DB 3eh,0DBH
         DB 0b7h
         DB 0c9h

L15B7:   DW 0
L15B9:   DW 0

L15BB:   DB 0cdh
	DW  L15CD
         DB 0cdh
	DW  READFILE              ; 33e, 14B2
         DB 0c3h
	DW  L15DC

L15C4:   DB 0cdh
	DW  L15CD
         DB 0cdh
	DW  WRITEFILE             ; 33e, 14DE
         DB 0c3h
	DW  L15DC

L15CD:   DB 0d5h
         DB 0e5h
         DB 0cdh
	DW  FILEPOS               ; 33e, 1446
         DB 22h
	DW L15B7
         DW 53edh,L15B9
         DB 0e1h
         DB 0d1h
         DB 0c9h

L15DC:   DB 0f5h
         DB 0d5h
         DB 0e5h
         DB 02ah
	DW L15B7
         DB 0edh,5bh
	DW L15B9
         DB 0cdh
	DW  FILESEEK              ; 33e, 141D
         DB 0e1h
         DB 0d1h
         DB 0f1h
         DB 0c9h

       END
;!       END