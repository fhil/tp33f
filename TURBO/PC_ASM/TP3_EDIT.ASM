         .model small
         .code
         .8086
         JUMPS

         ASSUME cs:_TEXT, ds:_TEXT

;         ALIGN 2

         include ..\library\pcmacros.inc

         include ..\library\pcsim.inc

         include pc_gen\editor.asm

         end

