DOSIO:	; in:	dx = function number
	cmp dx,3 	; CONSTPTR
	jz chsns
	cmp dx,6
	jz chget 	; CONINPTR
	cmp dx,9
	jz chput 	; CONOUTPTR
	ret

MSXDOS:	; in:	cl = DOS function number
	; out: -
	cmp cl,0 		; PROGRAM TERMINATE ?
	jz DOS_00

	cmp cl,0eh		; SELECT DEFAULT DRIVE ?
	jz DOS_0E

	cmp cl,0fh		; OPEN FILE USING FCB ?
	jz DOS_0F

	cmp cl,10h		; CLOSE FILE USING FCB ?
	jz DOS_10

	cmp cl,11h		; FIND FIRST MATCHING FILE USING FCB ?
	jz DOS_11

	cmp cl,12h		; FIND NEXT MATCHING FILE USING FCB ?
	jz DOS_12

	cmp cl,13h		; DELETE FILE USING FCB ?
	jz DOS_13

	cmp cl,14h		; SEQUENTIAL READ FROM FCB FILE ?
	jz DOS_14

	cmp cl,15h		; SEQUENTIAL WRITE FROM FCB FILE ?
	jz DOS_15

	cmp cl,16h		; CREATE OR TRUNCATE FILE USING FCB ?
	jz DOS_16

	cmp cl,17h		; RENAME FILE USING FCB ?
	jz DOS_17

	cmp cl,19h		; GET CURRENT DEFAULT DRIVE ?
	jz DOS_19

	cmp cl,1ah		; SET DISK TRANSFER AREA ADDRESS ?
	jz DOS_1A

	cmp cl,21h		; READ RANDOM RECORD FROM FCB FILE ?
	jz DOS_21

	cmp cl,22h		; WRITE RANDOM RECORD TO FCB FILE ?
	jz DOS_22

	cmp cl,23h		; GET FILE SIZE FOR FCB ?
	jz DOS_23

         cmp cl,26h
         jz DOS_26                  ; RANDOM BLOCK WRITE TO FCB

         cmp cl,27h                 ; RANDOM BLOCK READ FROM FCB
         jz DOS_27

	ret

DOS_00:	; PROGRAM TERMINATE
	; in:	-
	; out:	-
	mov ah,4ch
	int 21h

DOS_0E:	; SELECT DEFAULT DRIVE
	; in:	dl = new default dirve (00h = A:, 01h = B: , etc)
	; out:	al = number of drives (1..26)
	mov ah,0eh
	int 21h
	ret

DOS_0F:	; OPEN FILE USING FCB
	; in:	dx = address of unopened FCB
	; out:	al = 00h, successful
	;	al = ffh, file not found or access denied
	mov ah,0fh
	int 21h
	ret

DOS_10:	; CLOSE FILE USING FCB
	; in:	dx = address of FCB
	; out:	al = 00h, successful
	;	al = ffh, failed
	mov ah,10h
	int 21h
	ret

DOS_11:	; FIND FIRST MATCHING FILE USING FCB
	; in:	dx = unopened FCB, '?' wildcards allowed
	; out:	al = 00h, successful
	;	al = ffh, no matching filename, or bad FCB
	mov ah,11h
	int 21h
	ret

DOS_12:	; FIND NEXT MATCHING FILE USING FCB
	; in:	dx = unopened FCB
	; out:	al = 00h, successful
	;	al = ffh, no more matching filenames
	mov ah,12h
	int 21h
	ret

DOS_13:	; DELETE FILE USING FCB
	; in:	dx = unopened FCB, '?' wildcards allowed
	; out:	al = 00h, one or more files succesfully deleted
	;	al = ffh, no matching files or all were read-only or locked
	mov ah,13h
	int 21h
	ret

DOS_14:	; SEQUENTIAL READ FROM FCB FILE
	; in:	dx = address of opened FCB
	; out:	al = 00h, successful
	;	al = 01h, end of file (no data)
	;	al = 02h, segment wrap in DTA
	;	al = 03h, end of file, partial record read
	;	[DTA] = record read from file
	mov ah,14h
	int 21h
ignore2_3:
	cmp al,2
	jc DOS_14_Q
	xor al,al
DOS_14_Q:
	or al,al
	ret

DOS_15:	; SEQUENTIAL WRITE TO FCB FILE
	; in:	dx = address of opened FCB
	;	[DTA] = record to write
	; out:	al = 00h, successful
	;	al = 01h, disk full
	;	al = 02h, segment wrap in DTA
	mov ah,15h
	int 21h
	jmp ignore2_3

DOS_16:	; CREATE OR TRUNCATE FILE USING FCB
	; in:	dx = address of unopened FCB, wildcards not allowed
	; out:	al = 00h, successful
	;	al = ffh, directory full or file exists and is read-only or
	;		  locked
	mov ah,16h
	int 21h
	ret

DOS_17:	; RENAME FILE USING FCB
	; in:	dx = address of modified FCB
	; out:  al = 00h, successfully renamed
	;	al = ffh, no matching files, files is read-only, or new
	;		  name already exists
	mov ah,17h
	int 21h
	ret

DOS_19:	; GET CURRENT DEFAULT DRIVE
	; in:	-
	; out:	-
	mov ah,19h
	int 21h
	mov bl,al		; L = A = current drive
	ret

DOS_1A:	; SET DISK TRANSFER AREA ADDRESS
	; in:	dx = dma address
	; out:	-
	mov ah,1ah
	int 21h
	ret

DOS_21:	; READ RANDOM RECORD FROM FCB FILE
	; in:	dx = address of opened FCB
	; out:	al = 00h, successful
	;	al = 01h, end of file, no data read
	;	al = 02h, segment wrap in DTA, no data read
	;	al = 03h, end of file, partial record read
	;	[DTA] = record read from file
	mov ah,21h
	int 21h
	jmp ignore2_3

DOS_22:	; WRITE RANDOM RECORD TO FCB FILE
	; in:	dx = address of opened FCB
	;	[DTA] = record to write
         ; out:   al = 00h, succesful
	;	al = 01h, disk full
	;	al = 02h, segment wrap in DTA
	mov ah,22h
	int 21h
	jmp ignore2_3

DOS_23:	; GET FILE SIZE FOR FCB
	; in:	dx = address of unopened FCB, wildcards not allowed
	; out:	al = 00h, successful (matching file found)
	;	al = ffh, filed (no matching file found)
	mov ah,23h
	int 21h
	ret

DOS_26:  ; RANDOM BLOCK WRITE TO FCB
         ; in:    dx = address of opened FCB
         ;        bx = number of records to write
         ;        [DTA] = records to write
         ; out:   bx = number of records written
         ;        al = 00h, succesful
         ;        al = 01h, disk full
         ;        al = 02h, segment wrap in DTA
         mov cx,bx                  ; cx = number of records to write
         mov ah,28h                 ; PC numbering is different !
         int 21h
         mov bx,cx                  ; bx = number of records written
         jmp ignore2_3

DOS_27:  ; RANDOM BLOCK READ FROM FCB
         ; in:    dx = address of opened FCB
         ;        bx = number of records to read
         ;        [DTA]
         ; out:   bx = number of records read
         ;        al = 00h, succesful
         ;        al = 01h, disk full
         ;        al = 02h, segment wrap in DTA
         mov cx,bx                  ; cx = number of records to write
         mov ah,27h                 ; same number as MSXDOS 1 !!
         int 21h
         mov bx,cx                  ; bx = number of records written
         jmp ignore2_3

LF336:	DB 0			; flag, 0 = no character at LF337
LF337:	DB 0

chsns:	; in:	-
	; out:	al = character if present, otherwise 0
	mov al,byte ptr LF336
	and al,al
	mov al,byte ptr LF337
	retnz			; quit if character present
	push si
	mov ah,0bh		; get stdin status
	int 21h
	pop si
	retz			; quit if no characters present
	mov al,0ffh
	mov byte ptr LF336,al	; mark a character is present
	push si
	mov ah,07h
	int 21h			; direct character input, without echo
	pop si
	mov byte ptr LF337,al	; save character
	push cx
	mov ch,0
	inc ch			; make Z-flag NZ
	pop cx
	ret

chget:  ; in:	-
	; out:	al = character read from stdin
	push bx
	mov bx,offset LF336
	xor al,al
	cmp al,[bx]
	mov [bx],al
	pushf
	inc bx
	popf
	mov al,[bx]
	pop bx
	retnz
	push si
	mov ah,7
	int 21h			; direct character input, without echo
	pop si
	ret

chput:	; in:	cl = character to print
	push si
	push ax
	push bx
	push cx
	push dx
	mov ah,6
	mov dl,cl		; dl = character to print
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	pop si
	ret
