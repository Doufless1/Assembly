section .bss
number1 resd 10 ; we reserve only for 4 bytes for the integer
number2 resd 10
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
mov rdx, 10
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
mov rdx, 10
syscall

mov rsi,number2
mov rax, 0 
call loop_for_adding_the_numbers 

add rax,rbx


mov rsi,resultBuffer ; set resultBuffer so after we finish with make_it_ASCII everything is inside him
call make_it_ASCII



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
mov rdx,0
mov rcx, 10
mov rsi, resultBuffer ; here we want the address of the resultBuffer so we can point to him
add rsi,19


convert_loop:
test rax, rax
je done ; btw this is if they are equal
div rcx
add dl, '0' ;Wait a bit explanationg here. So rdx register is a 64 bit register it has dl lowest 8 bit, dh highest 8 bit dx for 16 for lowest i think it was btw it combines dl + dh. in linux x84-64 and here we want ONLY THE REMAINDER REMEMBER THIS. So if we need only the remainder we need the lowest bits of the register. If u ask why we dont use rdx then its because if we everytime we divide it rdx may contain left over data from the previous division and it can lead to crashes or undefined behaviour but I think this way we cant handle more then a couple of numbers liek I think the max is 5?
mov [rsi], dl ; btw this is like saying &rsi because rsi is a pointer to the address of some variable this way u save it inside rsi.
dec rsi, ; we move the pointer backwards so we can store them accordingly 
; for example if we have 123 and we start diving it its gonna be rdx = 3 then rdx = 2 then rdx = 1 it starts from least to most significant digit thats why we need to reverse it like this
mov rdx, 0
jmp convert_loop

done: 
inc rsi ; after we reverse it we point to the most significant bit again
ret
