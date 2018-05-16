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

;;;;; Loop Registers
;;; eax         = i
;;; ebx         = items popped
;;; ecx, cx, ch = current character
;;; edx, dx, dh = popped character count
_getNextCharacterSetup:
mov eax, 0                  ; i = 0
mov ebx, 0                  ; popped characters = 0
_getNextCharacter:
xor ecx, ecx                ; zero'r out - easier to debug ch
xor edx, edx                ; zero'r out - easier to debug dx
mov ch, [inputBuffer + eax]         ; c = [inputBuffer + i] ; 1 byte
inc eax                     ; i++
jmp __validate

;;; <helpers prefix="__">
__validate:

; Left Braces - Push To Stack
cmp ch, "("                 ; current character == (
je __pushCharacter          ;   true --> push current character (
cmp ch, "["                 ; current character == [
je __pushCharacter          ;   true --> push current character [
cmp ch, "{"                 ; current character == {
je __pushCharacter          ;   true --> push current character {

; Right Braces - Pop & Validate Stack
cmp eax, 1                  ; i == 1
je _failed                  ;   true; Can't start with a right brace

pop dx                      ; dx = pop stack - should be a left brace
inc ebx                     ; popped character count ++ 

; Determine popped character
cmp ch, ")"                 ; current character == )
je __validateStack1         ;   true --> validate stack for )
cmp ch, "]"                 ; current character == ]
je __validateStack2         ;   true --> validate stack for ]
cmp ch, "}"                 ; current character == }
je __validateStack3         ;   true --> validate stack for }

; EOL - End of Line / Input - Check for Empty Stack
cmp ch, 0xa                 ; current character == new line feed / EOL
je __checkEmptyStack        ;   true --> Check for empty stack

; Some Weird Input,,, Rage Quit
jmp _failed                 ; else / default --> failure


; Left brace
__pushCharacter:
push cx                     ; push current character onto the stack
jmp _getNextCharacter       ; restart loop

; Right Brace
__validateStack1:
cmp dh, "("                 ; popped character == (
je _getNextCharacter        ;   true --> restart loop
jmp _failed                 ;   false --> failure message
__validateStack2:           
cmp dh, "["                 ; popped character == [
je _getNextCharacter        ;   true --> retart loop
jmp _failed                 ;   false --> failure message
__validateStack3:
cmp dh, "{"                 ; popped character == {
je _getNextCharacter        ;   true --> restart loop
jmp _failed                 ;   false --> fialure message

; EOL - End of Line Character
__checkEmptyStack:
inc eax                     ; i++ - so we can divide by 2 counting base 0
sal ebx, 1                  ; pushed count *= 2 ;OLD: sar eax, 1; i / 2
cmp eax, ebx                ; i == pushed count
je _success                 ; true --> WE WON!
jmp _failed                 ; false --> failure

;;; </helpers>


_success:
mov eax, 4                  ; syscall #4 - write
mov ebx, 1                  ; std out
mov ecx, inputBuffer        ; buffer out
mov edx, BUFFER_SIZE        ; buffer size
int 0x80                    ; invoke dispatcher
jmp _exit

_failed:
mov eax, 4                  ; syscall #4 - write
mov ebx, 1                  ; std out
mov ecx, errorMessage       ; buffer out
mov edx, errorMessageSize   ; buffer size
int 0x80                    ; invoke dispatcher
jmp _exit

_exit:
mov eax, 1                  ; syscall #1 - Exit?
mov ebx, 0                  ; exit code? 0
int 0x80                    ; invoke dispatcher

;;; Variables
section .data
helloMessage: db "Enter braces and the magic computer monkeys will let you know there's an error if they don't match.", 10, ">> "
helloMessageSize: equ $ - helloMessage
errorMessage: db "ERROR!!! Danger Will Robinson", 10
errorMessageSize: equ $ - errorMessage
BUFFER_SIZE: equ 1024    ; declare constant

section .bss
inputBuffer: resb BUFFER_SIZE   ; declare inputBuffer of SIZE bytes
