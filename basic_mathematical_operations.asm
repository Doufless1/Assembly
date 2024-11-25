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

  ;movzx rax, byte [number1] ; Load the ASCII character into rax and zero-extend
  ;  sub rax, '0'

mov rsi,number1
mov rax, 0 
call loop_for_adding_the_numbers ; the call instruction pushes the address of the next instruction after the call onto the stack
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

mov rsi,number2
mov rax, 0 
call loop_for_adding_the_numbers 

add rax,rbx

mov rsi,rax
mov rax,0
call make_it_ASCII
mov [resultBuffer],rax

add rax, '0'


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

jmp return_0

mov rax, 1
mov rdi, 1
mov rsi, resultBuffer
mov rdx, 20
syscall

jmp return_0


loop_for_adding_the_numbers:
movzx rcx, byte [rsi]
cmp rcx, 0x0A
je we_found_every_digit_inside_variable
sub rcx, '0'
imul rax,rax,10
add rax,rcx
inc rsi ; this points tot he next memory like if we have lets say '1','2','3' if we dont add it points to the first one
jmp loop_for_adding_the_numbers


return_0:
mov rax,60
mov rdi,0
syscall

we_found_every_digit_inside_variable:
ret


make_it_ASCII:
div rax,10
add rax, '0'
inc rsi
jmp make_it_ASCII

