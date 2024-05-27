
.lall

GLOBAL2  MACRO NAME
         GLOBAL NAME : NEAR

         IFDEF MSX
         IFDEF RUNTIME
         GLOBAL _&NAME : NEAR
_&NAME:
         ELSE
                  _&NAME EQU NAME
         ENDIF
         ELSE
                  _&NAME EQU NAME
         ENDIF

         ENDM

GLOBALS MACRO NAMES

         IRP NAME,<NAMES>
                  GLOBAL2 <NAME>
         ENDM

         ENDM

IFNDEF MSX
         INCLUDE libconst.inc
ENDIF
         GLOBAL L0004:NEAR          ; def. init.mac
         GLOBAL L0006:NEAR          ; def. init.mac
         GLOBAL L005C:NEAR          ; def. init.mac
         GLOBAL L005D:NEAR          ; def. init.mac
         GLOBAL L0065:NEAR          ; def. init.mac
         GLOBAL L0066:NEAR          ; def. init.mac
         GLOBAL L006C:NEAR          ; def. init.mac
         GLOBAL L0080:NEAR          ; def. init.mac
         GLOBAL L00CE:NEAR          ; def. init.mac
         GLOBAL L00E0:NEAR          ; def. init.mac
         GLOBAL L0100:NEAR          ; def. init.mac
         GLOBAL L0101:NEAR          ; def. init.mac
         GLOBAL L0168:NEAR          ; def. init.mac
         GLOBAL L0169:NEAR          ; def. init.mac
         GLOBAL L01AE:NEAR          ; def. init.mac
         GLOBAL L01B4:NEAR          ; def. init.mac
         GLOBAL L01BC:NEAR          ; def. init.mac
         GLOBAL L01D0:NEAR          ; def. init.mac
         GLOBAL L01E1:NEAR          ; def. init.mac
         GLOBAL L01E8:NEAR          ; def. init.mac
         GLOBAL L01FA:NEAR          ; def. init.mac
         GLOBAL L0200:NEAR          ; def. init.mac
         GLOBAL L023E:NEAR          ; def. init.mac
         GLOBAL L0259:NEAR          ; def. init.mac
         GLOBAL L0262:NEAR          ; def. init.mac
         GLOBAL L026B:NEAR          ; def. init.mac
         GLOBAL L0284:NEAR          ; def. init.mac
         GLOBAL L0299:NEAR          ; def. init.mac
         GLOBAL L02A2:NEAR          ; def. init.mac
         GLOBAL L030A:NEAR          ; def. init.mac
         GLOBAL L0310:NEAR          ; def. init.mac
         GLOBAL L0364:NEAR          ; def. init.mac
         GLOBAL L03C9:NEAR          ; def. init.mac
         GLOBAL L03E1:NEAR          ; def. init.mac
         GLOBAL L03EE:NEAR          ; def. init.mac
         GLOBAL L0406:NEAR          ; def. init.mac
         GLOBAL L04A6:NEAR          ; def. init.mac
         GLOBAL L04B4:NEAR          ; def. init.mac
         GLOBAL L04D2:NEAR          ; def. init.mac
         GLOBAL L04AF:NEAR          ; def. init.mac
         GLOBAL L0581:NEAR          ; def. init.mac
         GLOBAL L0591:NEAR          ; def. init.mac
         GLOBAL L059B:NEAR          ; def. init.mac
         GLOBAL L0612:NEAR          ; def. init.mac
         GLOBAL L0783:NEAR          ; def. init.mac
         GLOBAL L07F7:NEAR          ; def. init.mac
         GLOBAL L1008:NEAR          ; def. init.mac
         GLOBAL L11A3:NEAR          ; def. init.mac
         GLOBAL L149B:NEAR          ; def. init.mac
         GLOBAL L14E8:NEAR          ; def. init.mac
         GLOBAL L1726:NEAR          ; def. init.mac
         GLOBAL L20E2:NEAR          ; def. init.mac

         GLOBAL CON1OUTPTR:NEAR     ; def. init.mac
         GLOBAL CONSTPTR:NEAR       ; def. init.mac
         GLOBAL A2L:NEAR            ; def. init.mac
         GLOBAL L_NEG:NEAR          ; def. init.mac
         GLOBAL L_R:NEAR            ; def. init.mac
         GLOBAL PREFIX:NEAR         ; def. init.mac

         GLOBAL DEF_TYPE:NEAR       ; def. compiler.mac
         GLOBAL L72E1:NEAR          ; def. compiler.mac, no conditon error
         GLOBAL L7B5C:NEAR          ; def. compiler.mac
         GLOBAL L7B62:NEAR          ; def. compiler.mac

         GLOBAL L7BF5:NEAR          ; def. end.mac

         GLOBAL O_BYTE:NEAR,O_CALHL:NEAR,O_CODE:NEAR,O_HL:NEAR
         GLOBAL O_JPHL:NEAR,O_LDDE:NEAR,O_LDHL:NEAR,O_PSHHL:NEAR

         GLOBAL ParseByteVar:NEAR   ; def. glib.mac
         GLOBAL ParseIntVar:NEAR    ; def. glib.mac
         GLOBAL ParseIntError:NEAR  ; def. glib.mac
         GLOBAL ParseStrVAR64:NEAR  ; def. glib.mac
         GLOBAL ParseVAR64:NEAR     ; def. glib.mac

         GLOBAL TableIndex2:NEAR    ; def. compiler.mac

         ; GIOS Procedures
         GLOBAL P_DELETEFILE:NEAR   ; def. glib.mac
         GLOBAL P_DEFINEPICTURE:NEAR; def. glib.mac
         GLOBAL P_PFILLSHAPE:NEAR   ; def. glib.mac
         GLOBAL P_PPAINT:NEAR       ; def. glib.mac
         GLOBAL P_MEMEXPAND:NEAR    ; def. glib.mac
         GLOBAL P_MEMTOVRAM:NEAR    ; def. glib.mac
         GLOBAL P_MEMLOADPICTURE:NEAR; def. glib.mac
         GLOBAL P_MEMUNCRUNCH:NEAR  ; def. glib.mac
         GLOBAL P_MEMSAVEPICTURE:NEAR; def. glib.mac
         GLOBAL P_SETCLIPPING:NEAR  ; def. glib.mac
         GLOBAL P_SETVIEWPORT:NEAR  ; def. glib.mac
         GLOBAL P_GETVIEWPORT:NEAR  ; def. glib.mac
         GLOBAL P_MEMCOPY:NEAR      ; def. glib.mac
         GLOBAL P_BLOAD:NEAR        ; def. glib.mac
         GLOBAL P_BSAVE:NEAR        ; def. glib.mac
         GLOBAL P_CHANGECOLOR:NEAR  ; def. glib.mac
         GLOBAL P_CHANGESCREEN:NEAR ; def. glib.mac
         GLOBAL P_CIRCLE:NEAR       ; def. glib.mac
         GLOBAL P_CLEARMEM:NEAR     ; def. glib.mac
         GLOBAL P_DATE:NEAR         ; def. glib.mac
         GLOBAL P_DISPLAYPAGE:NEAR  ; def. glib.mac
         GLOBAL P_ELLIPSE:NEAR      ; def. glib.mac
         GLOBAL P_EXPAND:NEAR       ; def. glib.mac
         GLOBAL P_FASTBOX:NEAR      ; def. glib.mac
         GLOBAL P_FASTCOPY:NEAR     ; def. glib.mac
         GLOBAL P_FILLBOX:NEAR      ; def. glib.mac
         GLOBAL P_FILLSHAPE:NEAR    ; def. glib.mac
         GLOBAL P_FILLSPRITE:NEAR   ; def. glib.mac
         GLOBAL P_GCOPY:NEAR        ; def. glib.mac
         GLOBAL P_GETDOSVERSION:NEAR; def. glib.mac
         GLOBAL P_LINE:NEAR         ; def. glib.mac
         GLOBAL P_LOADPICTURE:NEAR  ; def. glib.mac
         GLOBAL P_LOADVRAM:NEAR     ; def. glib.mac
         GLOBAL P_MEMREADFILE:NEAR  ; def. glib.mac
         GLOBAL P_MEMWRITEFILE:NEAR ; def. glib.mac
         GLOBAL P_MEMAPPENDFILE:NEAR; def. glib.mac
         GLOBAL P_MOVEVRAM:NEAR     ; def. glib.mac
         GLOBAL P_PAINT:NEAR        ; def. glib.mac
         GLOBAL P_PSET:NEAR         ; def. glib.mac
         GLOBAL P_PUTSPRITE:NEAR    ; def. glib.mac
         GLOBAL P_READMEM:NEAR      ; def. glib.mac
         GLOBAL P_READSECTOR:NEAR   ; def. glib.mac
         GLOBAL P_SAVEPICTURE:NEAR  ; def. glib.mac
         GLOBAL P_SAVEVRAM:NEAR     ; def. glib.mac
         GLOBAL P_SCREEN:NEAR       ; def. glib.mac
         GLOBAL P_SCREENOFF:NEAR    ; def. glib.mac
         GLOBAL P_SCREENON:NEAR     ; def. glib.mac
         GLOBAL P_SETCHANNEL:NEAR   ; def. glib.mac
         GLOBAL P_SOUND:NEAR        ; def. glib.mac
         GLOBAL P_SPRITEATTRIBUTEADDRESS:NEAR  ; def. glib.mac
         GLOBAL P_SPRITECOLOR:NEAR  ; def. glib.mac
         GLOBAL P_SPRITEPATTERN:NEAR; def. glib.mac
         GLOBAL P_SPRITEPATTERNADDRESS:NEAR    ; def. glib.mac
         GLOBAL P_SPRITESIZE:NEAR   ; def. glib.mac
         GLOBAL P_SPRITESOFF:NEAR   ; def. glib.mac
         GLOBAL P_SPRITESON:NEAR    ; def. glib.mac
         GLOBAL P_TIME:NEAR         ; def. glib.mac
         GLOBAL P_UNCRUNCH:NEAR     ; def. glib.mac
         GLOBAL P_VPOKE:NEAR        ; def. glib.mac
         GLOBAL P_WAITVDP:NEAR      ; def. glib.mac
         GLOBAL P_WRITEMEM:NEAR     ; def. glib.mac
         GLOBAL P_WRITESECTOR:NEAR  ; def. glib.mac
         GLOBAL P_WRITEVDP:NEAR     ; def. glib.mac

         ; GIOS Functions
         GLOBAL F_TSRPRESENT:NEAR   ; def. glib.mac
         GLOBAL F_GETCLIPPING:NEAR  ; def. glib.mac
         GLOBAL F_SIMULATEDDISK:NEAR; def. glib.mac
         GLOBAL F_FINDFIRST:NEAR    ; def. glib.mac
         GLOBAL F_FINDNEXT:NEAR     ; def. glib.mac
         GLOBAL F_GETDRIVE:NEAR     ; def. glib.mac
         GLOBAL F_TESTDRIVE:NEAR    ; def. glib.mac
         GLOBAL F_GETERROR:NEAR     ; def. glib.mac
         GLOBAL F_GETFKEY:NEAR      ; def. glib.mac
         GLOBAL F_GETPAD:NEAR       ; def. glib.mac
         GLOBAL F_GETPDL:NEAR       ; def. glib.mac
         GLOBAL F_GETCHANNEL:NEAR   ; def. glib.mac
         GLOBAL F_GETPAGEID:NEAR    ; def. glib.mac
         GLOBAL F_POINT:NEAR        ; def. glib.mac
         GLOBAL F_READPSG:NEAR      ; def. glib.mac
         GLOBAL F_READSTATUS:NEAR   ; def. glib.mac
         GLOBAL F_READVDP:NEAR      ; def. glib.mac
         GLOBAL F_SEARCH:NEAR       ; def. glib.mac
         GLOBAL F_SETDATE:NEAR      ; def. glib.mac
         GLOBAL F_SETMEM:NEAR       ; def. glib.mac
         GLOBAL F_SETTIME:NEAR      ; def. glib.mac
         GLOBAL F_STICK:NEAR        ; def. glib.mac
         GLOBAL F_STRIG:NEAR        ; def. glib.mac
         GLOBAL F_VPEEK:NEAR        ; def. glib.mac

