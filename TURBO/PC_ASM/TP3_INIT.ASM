         ; LZW cruncher by Frits Hilderink

         .model small
         .stack 0fc00h
         .code
         .8086
         JUMPS

         include ..\library\pcmacros.inc

start:
         mov ax,cs
         mov es,ax

         mov si,0080h
         mov di,offset L0080
         mov cx,128
         rep movsb

         mov ax,cs
         mov ds,ax
         jmp L0100

L0080:   db 256 dup(?)

         include ..\library\pcsim.inc

         include pc_gen\init.asm

         end start

