;Using functions and implementing all 4 basic operations

section .data
    EXIT equ 60
    EXIT_CODE equ 0
    NEWLINE equ 10
    InputString1 DB "Enter the first number", NEWLINE
    stringLen1 equ $ - InputString1
    InputString2 DB "Enter the second number", NEWLINE
    stringLen2 equ $ - InputString2
    operatorString DB "Enter opetator (+ - * / ~)"
    operatorLen equ $ - operatorString
    invalidString DB "Invalid answer, please enter apropiate inputs", NEWLINE
    invalidLen equ $ - invalidString
    divide0String DB "You cannot divide by zero!", NEWLINE
    divide0Len equ $ - divide0String

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
        mov rsi, InputString2
        mov rdx, stringLen2
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, num2
        mov rdx, 10
        syscall

        mov rax, 0
        mov rsi, num2
        call ascii_to_int
        mov [num2], rax

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

        cmp byte[operator], '-'
        je substraction

        cmp byte[operator], '+'
        je addition

        cmp byte[operator], '*'
        je multiplication

        cmp byte[operator], '/'
        je division

        cmp byte[operator], '~'
        je square_root

        jmp invalid_input


   square_root:
    mov r15, 0         ; Start with x = 0
    mov rbx, 1         ; Step = 1
    mov rcx, [num1]    ; Load num1 into rcx

.square_loop:
    mov rax, 0
    mov rax, r15
    imul rax, rax
    mov rdx, rax ; rdx = rax * rax
    cmp rdx, rcx       ; Compare x^2 with num1
    je .found_root     ; Exact match found
    ja .done_root      ; If x^2 > num1, overshot

    add r15, rbx       ; Increment x
    jmp .square_loop

.done_root:
    sub rax, rbx       ; Floor approximation of square root
    mov r8, 0          ; Counter for fractional steps (tenths)
    mov r9, 10         ; We refine in steps of 0.1
    mov rdx, 0         ; Clear remainder

.fractional_loop:
    add rax, 1         ; Increment rax (equivalent to adding 0.1)
    imul rdx, rax      ; rdx = rax * rax
    cmp rdx, rcx       ; Compare x^2 with num1
    ja .fraction_done  ; Stop when overshot

    inc r8             ; Increment fractional counter
    cmp r8, r9         ; Check if refined up to 0.9
    jl .fractional_loop

.fraction_done:
    sub rax, 1         ; Undo last increment (overshoot)
    mov rsi, r8        ; Fractional counter
    call print_result_with_decimal
    jmp exit

.found_root:
    ; Exact square root found
    mov rax, r15
    call print_result
    jmp exit


print_result_with_decimal:
    ; Print integer part (rax)
    call print_result

    ; Print decimal point
    mov byte [result], '.'
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 1
    syscall

    ; Print fractional part (rsi = fractional counter)
  add sil, '0'          ; Convert the fractional counter to ASCII
mov byte [result], sil ; Store only the lowest byte into the result buffer
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 1
    syscall

    ret

addition:
    mov rbx, [num2]
    mov rax, [num1]
    add rax, rbx

    call print_result
    jmp exit

substraction:
    mov rbx, [num2]
    mov rax, [num1]
    sub rax, rbx

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

    mov byte[result], '.'
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 1
    syscall

    mov rax, [remainder]
    mov rcx, 10
    mul rcx
    mov rbx, [num2]
    div rbx

    mov [remainder], rdx
    call print_result

    mov rax, [remainder]
    test rax, rax
    jne .check

    jmp exit        

.check:
    mov rax, [remainder]
    mov rcx, 100
    mul rcx
    mov rbx, [num2]
    div rbx

    call print_result

    jmp exit

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

invalid_input:
    mov rax, 1
    mov rdi, 1
    mov rsi, invalidString
    mov rdx, invalidLen
    syscall
    mov rax, EXIT
    xor rdi, EXIT_CODE
    syscall

    ret

divide_0:
    mov rax, 1 
    mov rdi, 1
    mov rsi, divide0String
    mov rdx, divide0Len
    syscall

    jmp exit

exit:
    mov rax, EXIT
    xor rdi, EXIT_CODE
    syscall

    ret
