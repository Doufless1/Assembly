section .data
    EXIT equ 60
    EXIT_CODE equ 0
    NEWLINE equ 10
    InputString1 DB "Enter the first number", NEWLINE
    stringLen1 equ $ - InputString1
    InputString2 DB "Enter the second number", NEWLINE
    stringLen2 equ $ - InputString2
    operatorString DB "Enter operator (+ - * / ^ ~ e)", NEWLINE
    operatorLen equ $ - operatorString
    invalidString DB "Invalid input, please try again.", NEWLINE
    invalidLen equ $ - invalidString
    divide0String DB "You cannot divide by zero!", NEWLINE
    divide0Len equ $ - divide0String
    minusChar DB '-'
    TEN equ 10
    ONE equ 1
    TWENTY equ 20
    FIVE equ 5
    ZERO equ 0
    ten DD 10.0
    exp DD 2.718281828459045
    one DD 1.0

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

    mov rsi, num1
    call ascii_to_int
    mov [num1], rax

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

    cmp byte [operator], '~'
    je sqrt_op
    cmp byte [operator], 'e'
    je exponential_op

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

    mov rsi, num2
    call ascii_to_int
    mov [num2], rax

    cmp byte [operator], '+'
    je addition
    cmp byte [operator], '-'
    je substraction
    cmp byte [operator], '*'
    je multiplication
    cmp byte [operator], '/'
    je division
    cmp byte [operator], '^'
    je power_op

    jmp invalid_input

sqrt_op:
    ; Check if num1 is negative
    mov rax, [num1]
    test rax, rax ; it will only jump if rax is negative
    js sqrt_negative

    cvtsi2ss xmm0, rax
    sqrtss xmm0, xmm0
    cvttss2si rax, xmm0  
    mov r13, rax

    call print_result

    cvtsi2ss xmm1, r13
    subss xmm0, xmm1

   
    mov byte [result], '.'
    mov rax, ONE
    mov rdi, ONE
    mov rsi, result
    mov rdx, ONE
    syscall

   
    mov r10, 4
.printDecimal:
    mulss xmm0, [ten]
    cvttss2si rax, xmm0
    push r10
    call print_result
    pop r10
    cvtsi2ss xmm1, rax
    subss xmm0, xmm1
    dec r10
    jnz .printDecimal
    jmp exit

sqrt_negative:
    ; Print error and reprompt
    mov rax, ONE
    mov rdi, ONE
    mov rsi, invalidString
    mov rdx, invalidLen
    syscall
.flush:
    mov rax, ZERO
    mov rdi, ZERO
    mov rsi, flush
    mov rdx, ONE
    syscall
    cmp byte [flush], NEWLINE
    jne .flush
    jmp _start

exponential_op:
    ; e^num1
    mov r9, [num1]
    movss xmm0, [one]
    movss xmm1, [exp]
    test r9, r9
    jz .exp_done  ; e^0 = 1 jz is like  je but its just more appropriate something being tested to 0
    ;  u can read here for more https://stackoverflow.com/questions/14267081/difference-between-je-jne-and-jz-jnz
.exp_loop:
    mulss xmm0, xmm1
    dec r9
    jnz .exp_loop
.exp_done:
    cvttss2si rax, xmm0  ; Integer part
    mov r13, rax
    call print_result

    ; Subtract integer part
    cvtsi2ss xmm1, r13
    subss xmm0, xmm1

    ; Print decimal point
    mov byte [result], '.'
    mov rax, ONE
    mov rdi, ONE
    mov rsi, result
    mov rdx, ONE
    syscall

    ; Print fractional part
    mov r10, 4
.printDecimal:
    mulss xmm0, [ten]
    cvttss2si rax, xmm0
    call print_result
    cvtsi2ss xmm1, rax
    subss xmm0, xmm1
    dec r10
    jnz .printDecimal
    jmp exit

power_op:
    ; num1^num2
    mov rcx, [num2]
    mov rax, 1
    mov rbx, [num1]
    test rcx, rcx
    jz exit  ; result is 1
.power_loop:
    imul rax, rbx
    dec rcx
    jnz .power_loop
    call print_result
    jmp exit

addition:
    mov rax, [num1]
    add rax, [num2]
    call print_result
    jmp exit

substraction:
    mov rax, [num1]
    sub rax, [num2]
    jns .positive
    neg rax
    push rax
    mov byte [result], '-'
    mov rax, ONE
    mov rdi, ONE
    mov rsi, result
    mov rdx, ONE
    syscall
    pop rax
.positive:
    call print_result
    jmp exit

multiplication:
    mov rax, [num1]
    imul rax, [num2]
    call print_result
    jmp exit

division:
    mov rbx, [num2]
    test rbx, rbx
    je divide_0
    mov rax, [num1]
    cqo
    idiv rbx
    call print_result
    test rdx, rdx
    jz exit
    mov byte [result], '.'
    mov rax, ONE
    mov rdi, ONE
    mov rsi, result
    mov rdx, ONE
    syscall
    mov rcx, 4
.decimals:
    imul rdx, 10
    mov rax, rdx
    cqo
    idiv rbx
    call print_result
    mov rdx, rdx
    loop .decimals
    jmp exit

ascii_to_int:
    xor     rax, rax        
    xor     r8, r8          ; make signs for 0 to be positve in r8 and r1 to be for negative
    movzx   rcx, byte [rsi]   ; loading the charecter into rcx to Check
    cmp     rcx, '-'        
    jne     .convert_loop   ; if not '-', go to conversion loop
    mov     r8, 1           ; then if it skips we mark that the nubmer is negative
    inc     rsi             ; skipping negative sing 
.convert_loop:
    movzx   rcx, byte [rsi]   ; we get the next charecter.
    cmp     rcx, NEWLINE    ; idk what you were trying to achive here but i think if its the end the charecter we are done?
    je      .done
    ; So now here we are going to check if the user input it accually digits because in asci digits are from 30-39 everything under is a letter or symbol or whatever and everything above as well so we do that.
    cmp     rcx, '0'
    jb      .invalid_char
    cmp     rcx, '9'
    ja      .invalid_char
    sub     rcx, '0'        
    imul    rax, rax, 10
    add     rax, rcx
    inc     rsi
    jmp     .convert_loop
.invalid_char:
    ; here we print the error message and restart
    mov     rax, ONE
    mov     rdi, ONE
    mov     rsi, invalidString
    mov     rdx, invalidLen
    syscall
    jmp     _start
.done:
    test    r8, r8
    jz      .positive_num
    neg     rax
.positive_num:
    ret

print_result:
    mov rbx, TEN
    xor r8, r8
    test rax, rax
    jns .reverse_loop
    push rax
    mov byte [result], '-'
    mov rax, ONE
    mov rdi, ONE
    mov rsi, result
    mov rdx, ONE
    syscall
    pop rax
    neg rax
.reverse_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc r8
    test rax, rax
    jnz .reverse_loop
.print_loop:
    pop rdx
    mov [result], dl
    mov rax, ONE
    mov rdi, ONE
    mov rsi, result
    mov rdx, ONE
    syscall
    dec r8
    jnz .print_loop
    xor rdx,rdx
    ret

invalid_input:
    mov rax, ONE
    mov rdi, ONE
    mov rsi, invalidString
    mov rdx, invalidLen
    syscall
.flush:
    mov rax, ZERO
    mov rdi, ZERO
    mov rsi, flush
    mov rdx, ONE
    syscall
    cmp byte [flush], NEWLINE
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
    mov byte [flush], NEWLINE
    mov rax, ONE
    mov rdi, ONE
    mov rsi, flush
    mov rdx, ONE
    syscall
    mov rax, EXIT
    xor rdi, EXIT_CODE
    syscall
