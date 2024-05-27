	; include file for macro definitions

;dc       macro string
;
;         strsize sizestr <string>
;         pos = 0
;
;         irpc parameter,string
;                  pos = pos + 1
;
;                  if pos EQ strsize - 1
;                  db '&parameter' + 80h
;                  endif
;
;                  if pos GT 1
;                           if pos LT strsize -1
;                                    db '&parameter'
;                           endif
;                  endif
;
;         endm
;
;         endm

	; macros for calls
	; ----------------
callnz	macro address
	local continue
	jz continue
         call near ptr address      ; CALL NZ,address
continue:
	endm

callz	macro address
	local continue
	jnz continue
         call near ptr address      ; CALL Z,address
continue:
	endm

callnc	macro address
	local continue
	jc continue
         call near ptr address      ; CALL NC,address
continue:
	endm

callc	macro address
	local continue
	jnc continue
         call near ptr address      ; CALL C,address
continue:
	endm

callp	macro address
	local continue
	js continue
         call near ptr address      ; CALL P,address
continue:
	endm

callm	macro address
	local continue
	jns continue
         call near ptr address      ; CALL M,address
continue:
	endm


	; macros for returns
	; ------------------
retnz	macro
;         local continue
         jnz __RET
;         jz continue
;         ret                        ; RET NZ
;continue:
	endm

retz	macro
         jz __RET
;         local continue
;         jnz continue
;         ret                        ; RET Z
;continue:
	endm

retnc	macro
         jnc __RET
;         local continue
;         jc continue
;         ret                        ; RET NC
;continue:
	endm

retc	macro
         jc __RET
;         local continue
;         jnc continue
;         ret                        ; RET C
;continue:
	endm

retp	macro
         jns __RET
;         local continue
;         js continue
;         ret                        ; RET P
;continue:
	endm

retm	macro
         js __RET
;         local continue
;         jns continue
;         ret                        ; RET M
;continue:
	endm

AF_:	DW 0

__R_BC:	DW 0
__R_DE:	DW 0
__R_HL:	DW 0

__EXX:	xchg cx,word ptr [__R_BC]
	xchg dx,word ptr [__R_DE]
	xchg bx,word ptr [__R_HL]
	RET

__LDIR:	; in:  bx = hl = source
	;      dx = de = destination
	;      cx = bc = length
	; out: -
	mov ah,[bx]
	xchg bx,dx
	mov [bx],ah
	xchg bx,dx
	inc bx
	inc dx
	loopnz __LDIR
	ret

__LDI:	; in:	bx = hl = source
	;	dx = de = destination
	;	cx = bc = length
	; out:	cx =  0, carry set
	;	cx <> 0, carry clear
	mov ah,[bx]
	xchg bx,dx
	mov [bx],ah
	xchg bx,dx
	inc bx
	inc dx
	dec cx
	je __LDI_C
	clc
	ret
__LDI_C:stc
	ret

__LDDR:	; in:	bx = hl = source
	;	dx = de = destination
	;	cx = bc = length
	; out:	-
	mov ah,[bx]
	xchg bx,dx
	mov [bx],ah
	xchg bx,dx
	dec bx
	dec dx
	loopnz __LDDR
	ret

__LDD:	RET

__CPIR:	; in:  al = al = character to find
	;      bx = hl = source address
	;      cx = bc = length
	; out: z-flag set if equal, c-flag always reset
	;      c-flag set if bc became zero
	cmp al,[bx]
	pushf
	inc bx
	dec cx
	popf
	retz			; quit if equal and no carry flag
	inc cx
	loopnz __CPIR

         inc cx                     ; zero flag = NonZero, not found
         clc                        ; clear carry flag

	ret

__CPI:	RET
__CPDR:	RET
__CPD:	RET
__RET:   RET

