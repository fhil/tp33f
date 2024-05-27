OFF_HL   MACRO CURRENT,NEW
         LOCAL DIF
DIF      EQU (NEW)-(CURRENT)

IFDEF MSX
         IFE DIF-1
          DB 23h; INC HL
         ELSE
          IFE DIF-2
           DB 23h; INC HL
           DB 23h; INC HL
          ELSE
           IFE DIF-3
            DB 23h; INC HL
            DB 23h; INC HL
            DB 23h; INC HL
           ELSE
            IFE DIF+1
             DB 2bh; DEC HL
            ELSE
             IFE DIF+2
              DB 2bh; DEC HL
              DB 2bh; DEC HL
             ELSE
              IFE DIF+3
               DB 2bh; DEC HL
               DB 2bh; DEC HL
               DB 2bh; DEC HL
              ELSE
               IFE DIF
               ELSE
                DB 0D5H ; PUSH DE
                DB 11H
                DW DIF
                DB 19H  ; ADD HL,DE
                DB 0D1H ; POP DE
               ENDIF
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
ELSE
         IFE DIF-1
          INC bx
         ELSE
          IFE DIF-2
           INC bx
           INC bx
          ELSE
           IFE DIF-3
            INC bx
            INC bx
            INC bx
           ELSE
            IFE DIF+1
             DEC bx
            ELSE
             IFE DIF+2
              DEC bx
              DEC bx
             ELSE
              IFE DIF+3
               DEC bx
               DEC bx
               DEC bx
              ELSE
               IFE DIF
               ELSE
                push dx
                mov dx,DIF
                ADD bx,dx
                pop dx
               ENDIF
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
ENDIF

         ENDM

dc	macro string

	strsize sizestr <string>
	pos = 0

	irpc parameter,string
		pos = pos + 1

		if pos EQ strsize - 1
		db '&parameter' + 80h
		endif

		if pos GT 1
			if pos LT strsize -1
				db '&parameter'
			endif
		endif

	endm

	endm

