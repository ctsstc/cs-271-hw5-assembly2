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
_getNextCharacter:
xor ecx, ecx                ; zero'r out - easier to debug ch
xor edx, edx                ; zero'r out - easier to debug dx
mov ch, [inputBuffer + eax]         ; c = [inputBuffer + i] ; 1 byte
inc eax                     ; i++
jmp __validate

__validate:

; Left Braces - Push To Stack
cmp ch, "("
je __pushCharacter
cmp ch, "["
je __pushCharacter
cmp ch, "{"
je __pushCharacter

; Right Braces - Pop & Validate Stack
cmp eax, 1
je _failed                  ; Can't start with a right brace

pop dx                      ; cl = pop stack - all 

cmp ch, ")"
je __validateStack1
cmp ch, "]"
je __validateStack2
cmp ch, "}"
je __validateStack3

; EOL - End of Line - Check for Empty Stack
cmp ch, 0xa                 ; ch == new line feed / EOL
je __checkEmptyStack

; Some Weird Input,,, Rage Quit
jmp _failed

__pushCharacter:
push cx
jmp _getNextCharacter

__validateStack1:
cmp dh, "("
je _getNextCharacter
jmp _failed
__validateStack2:
cmp dh, "["
je _getNextCharacter
jmp _failed
__validateStack3:
cmp dh, "{"
je _getNextCharacter
jmp _failed

__checkEmptyStack:
pop ebx
pop ebx
pop ebx

_writeInput:
mov eax, 4
mov ebx, 1
mov ecx, inputBuffer
mov edx, BUFFER_SIZE
int 0x80

_failed:
mov eax, 4                  ; syscall #4 - write
mov ebx, 1                  ; std out
mov ecx, errorMessage       ; buffer out
mov edx, errorMessageSize   ; buffer size
int 0x80                    ; invoke dispatcher
jmp _exit

_exit:
mov eax, 1
mov ebx, 0
int 0x80

;;; Variables
section .data
helloMessage: db "Enter braces and the magic computer monkeys will let you know there's an error if they don't match.", 10, ">> "
helloMessageSize: equ $ - helloMessage
errorMessage: db "ERROR!!! Danger Will Robinson", 10
errorMessageSize: equ $ - errorMessage
BUFFER_SIZE: equ 1024    ; declare constant

section .bss
inputBuffer: resb BUFFER_SIZE   ; declare inputBuffer of SIZE bytes
