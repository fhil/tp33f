
; FILEIO.MAC global definitions file

         GLOBAL DOS2Present:NEAR
         GLOBAL InitFileIO:NEAR
         GLOBAL GetError:NEAR
         GLOBAL SetErrorHandler:NEAR
         GLOBAL ResErrorHandler:NEAR

         GLOBAL ParseName:NEAR
         GLOBAL SetExtension:NEAR

         GLOBAL CreateFile:NEAR
         GLOBAL OpenFile:NEAR
         GLOBAL ReadFile:NEAR
         GLOBAL WriteFile:NEAR
         GLOBAL CloseFile:NEAR
         GLOBAL FileSeek:NEAR
         GLOBAL FilePos:NEAR
         GLOBAL FileSize:NEAR
         GLOBAL DeleteFile:NEAR     ; or subdirectory
         GLOBAL RenameFile:NEAR     ; or subdirectory
         GLOBAL GetCurrentDirectory:NEAR

         GLOBAL FatalError:NEAR     ; 0 = no fatal error, NonZero = fatal
         GLOBAL ErrorNumber:NEAR    ; 0 = no error, NonZero = DOS 2 error code

FCB_LEN           EQU 36            ; length of an FCB

FCB_DRIVE         EQU 0             ; Drive Number
FCB_NAME          EQU 1             ; Name
FCB_EXT           EQU 9             ; Extension
FCB_RECSIZE       EQU 0EH           ; Record Size (word)
FCB_FILESIZE      EQU 10H           ; File Size (long)
FCB_FILEPOS       EQU 21H           ; File Position (long)

