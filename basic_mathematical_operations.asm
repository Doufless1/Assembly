section .bss
number1 resd 10 ; we reserve only for 4 bytes for the integer
number2 resd 10
operator resd 1 
flushing_new_line resd 1
resultBuffer resd 70; here as well

section .data

operator_message db "Enter an operator (+, -, *, /):", 0xA
    operator_len equ $ - operator_message


 message1 db "Insert The First Positive Number:", 0xA
 message1Len equ $ - message1

 message2 db "Insert The Second Positivie Number:", 0xA
 message2Len equ $ - message2

 message3 db "The Solution of the Two Number is:"
 message3Len equ $ - message3


 error_message_cant_divid_0 db "You Cant Divide with 0!!!!", 0xA
 error_message_cant_divid_0_Len equ $ - error_message_cant_divid_0

 
 wrong_user_input db "You Made Wrong User Input From The Given Examples. Try Again!!!", 0xA
 wrong_user_input_Len equ $ - wrong_user_input

zero db "0"
zero_Len equ $ - zero

section .text
global _start

_start:
mov r9, 10 ; so if u ask why i put htis here is beause of the make it ascii funciton
; if u keep it and it dosent update and there is second left over it overwrite the first one 
; thats why we need it kinda like a global variable
    mov rax, 1                
    mov rdi, 1                
    mov rsi, operator_message  
    mov rdx, operator_len     
    syscall




    mov rax, 0               
    mov rdi, 0                
    mov rsi, operator         
    mov rdx, 1                
    syscall

   mov rax, 0                
    mov rdi, 0
    mov rsi, flushing_new_line 
    mov rdx, 1                
    syscall

    
    mov al, byte [operator]    
    cmp al, '+'                
    je continue_execution
    cmp al, '-'                
    je continue_execution
    cmp al, '*'                
    je continue_execution
    cmp al, '/'                
    je continue_execution

    
    mov rax, 1
    mov rdi, 1
    mov rsi, wrong_user_input  
    mov rdx, wrong_user_input_Len 
    syscall

    
flush_input:
    mov rax, 0                
    mov rdi, 0
    mov rsi, flushing_new_line 
    mov rdx, 1                
    syscall
    cmp byte [flushing_new_line], 0x0A ; this checks for a new line so it properly clears the user input so we dont get a repeating erorr message with the asking for input 
    ; for example if u put adada its gonna handle each of this wrong inputs individaully
    jne flush_input            

    
    jmp _start

continue_execution:

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

push rax
mov al,byte [operator]
cmp al, '+'
je perform_adddition
cmp al, '-'
je perform_substraction
cmp al, '*'
je perform_multiplication
cmp al, '/'
je perform_division



prepare_result:
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




perform_adddition:
mov rax, 0
pop rax
add rax,rbx
jmp prepare_result


perform_substraction:
mov rax, 0
pop rax 
cmp rax, rbx
jl handle_negative_numbers
sub rax,rbx
jmp prepare_result


handle_negative_numbers:
sub rax, rbx
neg rax
mov byte [resultBuffer],'-' ; we add - to the buffer 
inc rsi ; so it can point to the number
jmp prepare_result


perform_multiplication:
mov rax, 0
pop rax
imul rax,rbx
jmp prepare_result

perform_division:
mov rdx, 0
mov rax, 0
pop rax
cmp rbx, 0
je error_message_cant_divid_null
cmp rax, 0
je zero_divided_by_something_is_zero
cmp rax , rbx ; i am trying as example rax = 1 rbx = 2 it probably wont work for more complicated numbers
jl convert_loop_for_decimal_points

div rbx
push rdx
cmp rdx, 0
je prepare_result
call make_it_ASCII
lea rsi, [rsi + r11]
mov byte [rsi], '.'
lea rsi, [rsi + 1]
pop rdx
jmp get_the_decimal_part 



get_the_decimal_part:
cmp r15,4 ; if u ask this is for precision points when u have numbers like 70/3 which is equal to 23.3333 if u dont put it it goes into infinet loop
je prepare_result_for_decimal_points
mov rax, rdx
mov rdx, 0
imul rax,rax,10
div rbx
push rdx
call make_it_ASCII_for_DECIMAL
pop rdx
inc r15
cmp rdx, 0
jne get_the_decimal_part
jmp prepare_result_for_decimal_points


prepare_result_for_decimal_points:
lea rsi, [resultBuffer]
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



convert_loop_for_decimal_points:
imul rax, rax, 10000 ; we multiple it like this because we want the divison so its going to be like rax = 1*10=10 if rax was one before
div rbx
mov byte [resultBuffer], '.'
jmp prepare_result


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
mov r11, 4
mov rdx,0
mov rcx, 10
lea rsi, [resultBuffer + r11]

convert_loop:
test rax, rax
je done ; btw this is if they are equal
div rcx
add dl, '0' ;Wait a bit explanationg here. So rdx register is a 64 bit register it has dl lowest 8 bit, dh highest 8 bit dx for 16 for lowest i think it was btw it combines dl + dh. in linux x84-64 and here we want ONLY THE REMAINDER REMEMBER THIS. So if we need only the remainder we need the lowest bits of the register. If u ask why we dont use rdx then its because if we everytime we divide it rdx may contain left over data from the previous division and it can lead to crashes or undefined behaviour but I think this way we cant handle more then a couple of numbers liek I think the max is 5?
mov [rsi], dl ; btw this is like saying &rsi because rsi is a pointer to the address of some variable this way u save it inside rsi.
dec rsi, ; we move the pointer backwards so we can store them accordingly 
; for example if we have 123 and we start diving it its gonna be rdx = 3 then rdx = 2 then rdx = 1 it starts from least to most significant digit thats why we need to reverse it like this
inc r11
mov rdx, 0
jmp convert_loop

done: 
inc rsi ; after we reverse it we point to the most significant bit again
ret


make_it_ASCII_for_DECIMAL:
mov rdx,0
mov rcx, 10
lea rsi, [resultBuffer + r9]


convert_loop_for_DECIMAL:
cmp r8, 5
je done ; btw this is if they are equal
div rcx
add dl, '0' ;Wait a bit explanationg here. So rdx register is a 64 bit register it has dl lowest 8 bit, dh highest 8 bit dx for 16 for lowest i think it was btw it combines dl + dh. in linux x84-64 and here we want ONLY THE REMAINDER REMEMBER THIS. So if we need only the remainder we need the lowest bits of the register. If u ask why we dont use rdx then its because if we everytime we divide it rdx may contain left over data from the previous division and it can lead to crashes or undefined behaviour but I think this way we cant handle more then a couple of numbers liek I think the max is 5?
mov [rsi], dl ; btw this is like saying &rsi because rsi is a pointer to the address of some variable this way u save it inside rsi.
dec rsi, ; we move the pointer backwards so we can store them accordingly 
; for example if we have 123 and we start diving it its gonna be rdx = 3 then rdx = 2 then rdx = 1 it starts from least to most significant digit thats why we need to reverse it like this
inc r9
inc r8
mov rdx, 0
jmp convert_loop


error_message_cant_divid_null:
mov rax,1
mov rdi, 1
mov rsi, error_message_cant_divid_0
mov rdx, error_message_cant_divid_0_Len
syscall

jmp return_0



zero_divided_by_something_is_zero:

mov rax,1
mov rdi,1
mov rsi,message3
mov rdx,message3Len
syscall

mov rax,1
mov rdi, 1
mov rsi, zero
mov rdx, zero_Len
syscall

jmp return_0
