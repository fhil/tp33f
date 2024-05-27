FIL_HDR  EQU 4                      ; length of FILE header

         include ..\library\fileio.inc

FIB_F    EQU 0                      ; Flags byte
FIB_CHR  EQU 1                      ; Character buffer
FIB_PTR  EQU 2                      ; Sector buffer pointer
FIB_NUM  EQU 4                      ; Number of records
FIB_REC  EQU 6                      ; Record length
FIB_CUR  EQU 8                      ; Current record
FIB_FCB  EQU 12                     ; First byte of FCB
FIB_BUF  EQU 48                     ; First byte of sector buffer

FIB_LEN  EQU FIB_BUF+128            ; total length of a complete FIB

DOS_FLG  EQU 0                      ; Flags byte
DOS_CHR  EQU 1                      ; Character buffer
DOS_PTR  EQU 2                      ; Sector buffer pointer
DOS_BLEN EQU 4                      ; Sector buffer length
DOS_NUM  EQU 6                      ; Number of records
DOS_REC  EQU 10                     ; Record length
DOS_CUR  EQU 12                     ; Current record
DOS_FCB  EQU 16                     ; First byte FCB/Handle structure
DOS_BUF  EQU (16 + 65)              ; First byte of sector buffer

DOS_LEN  EQU (DOS_BUF + 128)

         include ..\library\macros.inc
