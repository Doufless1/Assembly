section .bss
number1 resd 4 ; we reserve only for 4 bytes for the integer
number2 resd 4 
result resd 1 
resultBuffer resd 20; here as well

section .data
 message1 db "Insert The First Positive Number:", 0xA
 message1Len equ $ - message1

 message2 db "Insert The Second Positivie Number:", 0xA
 message2Len equ $ - message2

 message3 db "The Sum of the Two Number is:"
 message3Len equ $ - message3

section .text
global _start

_start:
mov rax, 1
mov rdi, 1
mov rsi, message1
mov rdx, message1Len
syscall

mov rax, 0
mov rdi, 0
mov rsi, number1
mov rdx, 4
syscall

  movzx rax, byte [number1] ; Load the ASCII character into rax and zero-extend
    sub rax, '0'

mov rbx,rax

mov rax, 1
mov rdi, 1
mov rsi, message2
mov rdx, message2Len
syscall

mov rax, 0
mov rdi, 0
mov rsi, number2
mov rdx, 4
syscall

  movzx rax, byte [number2] ; Load the ASCII character into rax and zero-extend
    sub rax, '0'

add rax,rbx

add rax, '0'

mov [resultBuffer],rax

;movzx rax,byte [resultBuffer]
;add rax, '0'


mov rax,1
mov rdi,1
mov rsi,message3
mov rdx,message3Len
syscall

mov rax,1
mov rdi,1
mov rsi,resultBuffer
mov rdx,20
syscall

mov rax,60
mov rdi,0
syscall


