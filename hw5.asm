section .text
global _start               ; for linker

_start:                     ; label
jmp _helloMessage

_helloMessage:
mov eax, 4                  ; syscall #4 - write
mov ebx, 1                  ; std out
mov ecx, helloMessage       ; buffer out
mov edx, helloMessageSize   ; buffer size
int 0x80                    ; invoke dispatcher
jmp _getInput

_getInput:
mov eax, 3                  ; syscall 3 - read
mov ebx, 0                  ; std in
mov ecx, inputBuffer        ; buffer to read into
mov edx, BUFFER_SIZE        ; number of bytes to read
int 0x80                    ; invoke dispatcher
jmp _getNextCharacterSetup

_getNextCharacterSetup:
mov eax, 0                  ; i = 0
mov ebx, inputBuffer        ; ebx = input buffer address
_getNextCharacter:
xor ecx, ecx                ; zero'r out - easier to debug
mov ch, [ebx + eax]         ; ch = [inputBuffer + i] ; 1 byte
inc eax                     ; i++

cmp ch, 0xa                 ; ch == new line feed / EOL
je _exit                    ; true; exit

jmp _getNextCharacter       ; false; continue loop

_writeInput:
mov eax, 4
mov ebx, 1
mov ecx, inputBuffer
mov edx, BUFFER_SIZE
int 0x80

_exit:
mov eax, 1
mov ebx, 0
int 0x80

;;; Variables
section .data
helloMessage: db "Enter braces and the magic computer monkeys will let you know there's an error if they don't match.", 10, ">> "
helloMessageSize: equ $ - helloMessage
errorMessage: db "ERORR", 10
errorMessageSize: equ $ - errorMessage
BUFFER_SIZE: equ 1024    ; declare constant

section .bss
inputBuffer: resb BUFFER_SIZE   ; declare inputBuffer of SIZE bytes
