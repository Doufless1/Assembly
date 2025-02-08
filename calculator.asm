;Final calculator
; Assemble with: nasm -felf64 calculator.asm -o calculator.o
; Link with: ld calculator.o -o calculator

section .data
    EXIT equ 60
    EXIT_CODE equ 0
    NEWLINE equ 10
    InputString1 DB "Enter the first number", NEWLINE
    stringLen1 equ $ - InputString1
    InputString2 DB "Enter the second number", NEWLINE
    stringLen2 equ $ - InputString2
    operatorString DB "Enter opetator (+ - * /)"
    operatorLen equ $ - operatorString
    invalidString DB "Invalid answer, please enter apropiate inputs", NEWLINE
    invalidLen equ $ - invalidString
    divide0String DB "You cannot divide by zero!", NEWLINE
    divide0Len equ $ - divide0String
    minusChar DB '-'
    TEN equ 10
    ONE  equ 1
    TWENTY  equ 20
    FIVE  equ 5
    ZERO  equ 0

section .bss
    num1 resd TEN
    num2 resd TEN
    flush resb ONE
    operator resb ONE
    result resd TWENTY
    remainder resd FIVE
    
section .text
    global _start
    _start:

        mov rax, ONE
        mov rdi, ONE
        mov rsi, InputString1
        mov rdx, stringLen1
        syscall

        mov rax, ZERO
        mov rdi, ZERO
        mov rsi, num1
        mov rdx, TEN
        syscall

        mov rax, ZERO
        mov rsi, num1
        call ascii_to_int
        mov [num1], rax

        mov rax, ONE
        mov rdi, ONE
        mov rsi, InputString2
        mov rdx, stringLen2
        syscall

        mov rax, ZERO
        mov rdi, ZERO
        mov rsi, num2
        mov rdx, TEN
        syscall

        mov rax, ZERO
        mov rsi, num2
        call ascii_to_int
        mov [num2], rax

        mov rax, ONE
        mov rdi, ONE
        mov rsi, operatorString
        mov rdx, operatorLen
        syscall

        mov rax, ZERO
        mov rdi, ZERO
        mov rsi, operator
        mov rdx, ONE
        syscall


        mov rax, ZERO
        mov rdi, ZERO
        mov rsi, flush
        mov rdx, ONE
        syscall

        cmp byte[operator], '-'
        je substraction

        cmp byte[operator], '+'
        je addition

        cmp byte[operator], '*'
        je multiplication

        cmp byte[operator], '/'
        je division

        jmp invalid_input

addition:
    mov rbx, [num2]
    mov rax, [num1]
    add rax, rbx

    call print_result
    jmp exit

substraction:
    mov rbx, [num2]
    mov rax, [num1]
    cmp rax, rbx
    jl .negative
    sub rax, rbx

    call print_result
    jmp exit

    .negative:
        sub rbx, rax
        mov [remainder], rbx    ;Reusing remainder but this is the result of the substraction

        mov byte[result], '-'
        mov rax, ONE
        mov rdi, ONE
        mov rsi, result
        mov rdx, ONE
        syscall

        mov rax, rbx
        call print_result

        jmp exit

multiplication:
    mov rbx, [num2]
    mov rax, [num1]
    mul rbx

    call print_result
    jmp exit

division:
    xor rdx, rdx
    mov rbx, [num2]
    mov rax, [num1]

    test rbx, rbx
    je divide_0
    
    div rbx         ; The quotient is now in rax, and the remainder is in rdx

    mov [remainder], rdx
    call print_result

    mov rdx, [remainder]
    test rdx, rdx      ;to make it not print the dot if there is no remainder
    jne .check

    jmp exit        

.check:
    mov byte[result], '.'
    mov rax, ONE
    mov rdi, ONE
    mov rsi, result
    mov rdx, ONE
    syscall

    xor r9, r9
    mov r9, 4
    .decimals:
        mov rax, [remainder]
        mov rcx, TEN
        mul rcx
        mov rbx, [num2]
        div rbx

        mov [remainder], rdx

        call print_result
        dec r9

        test r9, r9
        jnz .decimals

    .end:
        jmp exit

ascii_to_int:
    xor     rax, rax        ; Clear accumulator
    xor     r8, r8          ; Clear sign flag (0 = positive, 1 = negative)

    ; Check if the first character is a negative sign.
    mov     bl, byte [rsi]
    cmp     bl, '-'         
    jne     .convert_digits ; If not '-', continue conversion as positive
    ; Found a '-', mark number as negative.
    mov     r8, ONE         
    inc     rsi             ; Skip the '-' character

.convert_digits:
    xor     rcx, rcx

.convert_loop:
    movzx rcx, byte [rsi]
    cmp rcx, NEWLINE
    je .finish
    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp .convert_loop


.finish:
    cmp   r8, 0
    je   .done
    neg   rax
.done:
ret

print_result:
    mov rbx, TEN
    xor rsi, rsi
    xor r8, r8
    cmp rax, ZERO
    jge .reverse_loop
    call do_neg
    .reverse_loop:
        xor rdx, rdx
        div rbx
        add dl, '0'
        push rdx
        inc r8
        test rax, rax
        jnz .reverse_loop

    .print_loop:
        pop rax
        mov [result], al

        mov rax, ONE
        mov rdi, ONE
        mov rsi, result
        mov rdx, ONE
        syscall
        dec r8 

        jnz .print_loop
    .done:
        ret

invalid_input:
    mov rax, ONE
    mov rdi, ONE
    mov rsi, invalidString
    mov rdx, invalidLen
    syscall

    .flush:
        mov rax, ONE
        mov rdi, ONE
        mov rsi, flush
        mov rdx, ONE
        syscall
        cmp byte[flush], NEWLINE
        jne .flush

    jmp _start

divide_0:
    mov rax, ONE
    mov rdi, ONE
    mov rsi, divide0String
    mov rdx, divide0Len
    syscall

    jmp exit

exit:
    mov byte[flush], NEWLINE 
    mov rax, ONE
    mov rdi, ONE
    mov rsi, flush
    mov rdx, ONE
    syscall

    mov rax, EXIT
    xor rdi, EXIT_CODE
    syscall

    ret


do_neg:
    ; Save the negative value
    push rax             ; save original negative value

    ; Print the '-' character
    mov     rax, ONE      
    mov     rdi, ONE       
    mov     rsi, minusChar 
    mov     rdx, ONE
    syscall

    
    pop     rax          ; restore the negative value
    neg     rax          ; now rax is the positive equivalent

    ret
