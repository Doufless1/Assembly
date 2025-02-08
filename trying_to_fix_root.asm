section .data
    dot      db '.', 0 
    EXIT equ 60
    EXIT_CODE equ 0
    NEWLINE equ 10
    InputString1 DB "Enter the first number", NEWLINE
    stringLen1 equ $ - InputString1
    InputString2 DB "Enter the second number", NEWLINE
    stringLen2 equ $ - InputString2
    operatorString DB "Enter opetator (+ - * / ^ ~)"
    operatorLen equ $ - operatorString
    invalidString DB "Invalid answer, please enter apropiate inputs", NEWLINE
    invalidLen equ $ - invalidString
    divide0String DB "You cannot divide by zero!", NEWLINE
    divide0Len equ $ - divide0String
    ten dd 10.0

section .bss
    num1 resd 10
    num2 resd 10
    flush resb 1
    operator resb 1
    result resd 20
    remainder resd 5
    
section .text
    global _start

_start:

mov rax, 1
        mov rdi, 1
        mov rsi, InputString1
        mov rdx, stringLen1
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, num1
        mov rdx, 10
        syscall

        mov rax, 0
        mov rsi, num1
        call ascii_to_int
        mov [num1], rax

        mov rax, 1
        mov rdi, 1
        mov rsi, operatorString
        mov rdx, operatorLen
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, operator
        mov rdx, 1 
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, flush
        mov rdx, 1
        syscall

        cmp byte[operator], '~' ;compare first since no second number needed
        je sqrt

sqrt:
    ; Step 1: Convert num1 to float and compute the square root
    cvtsi2ss xmm0, [num1]      ; Convert num1 (integer) to float
    sqrtss xmm0, xmm0          ; Compute sqrt(num1)

    ; Step 2: Extract and print the integer part
    cvttss2si rax, xmm0        ; Convert float to integer
    call print_result

    ; Print the decimal point
    mov byte [result], '.'
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 1
    syscall

    ; Step 3: Extract and print fractional part (4 digits precision)
    movss xmm1, xmm0           ; Copy xmm0
    cvtsi2ss xmm2, rax         ; Convert integer part back to float
    subss xmm1, xmm2           ; Subtract integer part to isolate fraction

    mov rcx, 4                 ; Number of decimal places
.print_decimal:
    mulss xmm1, [ten]          ; Multiply by 10 to shift next digit
    cvttss2si rax, xmm1        ; Convert to integer (truncate)
    call print_result          ; Print the digit

    cvtsi2ss xmm2, rax         ; Convert printed digit back to float
    subss xmm1, xmm2           ; Subtract digit to isolate next frac

ascii_to_int:
    xor rax, rax
    xor rcx, rcx
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
    ret

print_result:
    mov rbx, 10
    xor rsi, rsi
    xor r8, r8
    mov r8, 0
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

        mov rax, 1
        mov rdi, 1
        mov rsi, result
        mov rdx, 1
        syscall
        dec r8 

        jnz .print_loop
    .done:
        ret



