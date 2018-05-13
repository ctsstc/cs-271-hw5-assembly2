section .text
global _start       ; for linker

_start:             ; label
jmp _readCrap
jmp _exit

_writeCrap:
mov eax, 4          ; syscall #4 - write
mov ebx, 1          ; std out
mov ecx, buffer        ; buffer out
mov edx, INSIZE       ; buffer size
int 0x80            ; invoke dispatcher
jmp _exit

_readCrap:
mov eax, 3          ; syscall 3 - read
mov ebx, 0          ; std in
mov ecx, buffer     ; buffer to read into
mov edx, INSIZE     ; number of bytes to read
int 0x80            ; invoke dispatcher
jmp _writeCrap

_exit:
mov eax, 1
mov ebx, 0
int 0x80

;;; Variables
section .data
msg: db "Hello World", 10
SIZE: equ $ - msg

section .bss
INSIZE: equ 1024    ; declare constant
buffer: resb INSIZE ; declare buffer of SIZE bytes
