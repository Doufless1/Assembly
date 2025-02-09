;Final calculator

section .data
    EXIT                    equ 60
    EXIT_CODE               equ 0
    InputString1            DB "Enter the first number", 0x0a
    stringLen1              equ $ - InputString1
    InputString2            DB "Enter the second number", 0x0a
    stringLen2              equ $ - InputString2
    operatorString          DB "Enter opetator (+ - * / ^ ~ e l)"
    operatorLen             equ $ - operatorString
    invalidOperatorString   DB "Invalid operator, please enter an apropiate operator (+ - * / ^ ~ e)", 0x0a
    invalidOperatorLen      equ $ - invalidOperatorString
    divide0String           DB "You cannot divide by zero!!!", 0x0a
    divide0Len              equ $ - divide0String
    square_root_negative    DB "You can't have the square root of a negative number!!!", 0x0a
    square_root_negativeLen equ $ - square_root_negative
    continue_string         DB "Do you want to continue? (y/n)", 0x0a
    continue_String_Len     equ $ - continue_string
    continue_input          DB "Wrong option!!! Use only 'y' for yes and 'n' for no", 0x0a
    continue_inputLen       equ $ - continue_input
    not_a_number_string     DB "You did not enter a number, try again, you can do it!!! 加油", 0x0a
    not_a_number_stringLen  equ $ - not_a_number_string
    ln_no_negative          DB "You can't use negative numbers for the natural logarithm!!! Try again", 0x0a
    ln_no_negativeLen       equ $ - ln_no_negative
    goodbye_string          DB "See you later user!!", 0x0a
    goodbye_string_Len      equ $ - goodbye_string
    newline                 DB "", 0x0a
    newlineLen              equ $ - newline
    ten                     DD 10.0
    exp                     DD 2.718281828459045
    one                     DD 1.0
    negative_char           DB '-'
    dot                     DB '.'
    lnStore                 DD 0.0

section .bss
    num1            resd 10
    num2            resd 10
    flush           resb 1
    operator        resb 1
    result          resd 10
    remainder       resd 5
    sign            resb 1
    num1_sign       resb 1
    num2_sign       resb 1
    result_sign     resb 1
    want_continue   resb 1
    
section .text
    global _start
    _start:
        mov rax, 1              ;Output string one into the console
        mov rdi, 1
        mov rsi, InputString1     
        mov rdx, stringLen1
        syscall

        mov rax, 0             ;Read number 1 from input
        mov rdi, 0
        mov rsi, num1
        mov rdx, 10
        syscall

        mov rsi, num1             ;Ascii_to_int and not_a_number assumes number is in rsi so I loaded here
        call is_number            ;Check if the input is a number
        call ascii_to_int         ;Necessary so that the computer can compute the operations since input assumes they are integer
        mov [num1], rax           ;Final number result in rax, move back to num1 to operate with it
        mov r12b, byte[sign]      ;Sign is set in ascii_to_int so move it to num1_sign, but can't move directly between variables
        mov [num1_sign], r12b     ;so i use r12b as a medium register to move it

        mov rax, 1                ;Output the string to ask for the operator
        mov rdi, 1
        mov rsi, operatorString
        mov rdx, operatorLen
        syscall

        mov rax, 0                ;Read from the input to store the operator
        mov rdi, 0
        mov rsi, operator
        mov rdx, 1 
        syscall

        mov rax, 0                ;Flush input buffer for any extra characters
        mov rdi, 0
        mov rsi, flush
        mov rdx, 1
        syscall

        cmp byte[operator], '~'   ;Compare to see if the symbol is square root
        je sqrt

        cmp byte[operator], 'e'   ;Compare to see if the symbol is exponential
        je exponential

        cmp byte[operator], 'l'   ;Compare to see if the symbol is ln
        je ln

        mov rax, 1                ;Output string two into the console
        mov rdi, 1
        mov rsi, InputString2
        mov rdx, stringLen2
        syscall

        mov rax, 0                ;Read number 2 from input
        mov rdi, 0
        mov rsi, num2
        mov rdx, 10
        syscall

        mov rsi, num2
        call is_number
        call ascii_to_int
        mov [num2], rax
        mov r12b, byte[sign]
        mov [num2_sign], r12b

        cmp byte[operator], '-'     ;Compare to check which operation to execute
        je substraction

        cmp byte[operator], '+'
        je addition

        cmp byte[operator], '*'
        je multiplication

        cmp byte[operator], '/'
        je division

        cmp byte[operator], '^'
        je power

        jmp invalid_operator        ;If it hasn't triggered any execution, it is an invalid operator, throw exception

addition:
    
    mov rbx, [num2]                 ;Load num2 into rbx
    mov rax, [num1]                 ;Load num1 into rax
    add rax, rbx

    cmp rax, 0                      ;Compare result to see if answer negative or positive
    jge .positive

    jmp .negative

    .positive:
        mov byte[result_sign], 0    ;Result will be positive
        jmp .printresult

    .negative:
        mov byte[result_sign], 1    ;Result will be negative
        jmp .printresult

    .printresult:
        call print_result

        call print_newline          ;Print newline, otherwise it will be right next to the wanto_to_continue text
        jmp continue__

substraction:
    mov rbx, [num2]
    mov rax, [num1]
    sub rax, rbx                    ;Sub can return a negative or positive value depending on the values

    cmp rax, 0                      ;Check if the result is positive or negative
    jge .positive

    jmp .negative

    .positive:                      ;Set sign flag for the print
        mov byte[result_sign], 0
        jmp .print_result

    .negative:                      ;Set sign flag for the print
        mov byte[result_sign], 1
        jmp .print_result

    .print_result:
        call print_result

        call print_newline
        jmp continue__

multiplication:
    mov rbx, [num2]
    mov rax, [num1]
    imul rax, rbx                   ;performs unsigned multiplication

    movzx r14, byte[num1_sign]
    xor r14, [num2_sign]            ;xor: if only one negative, r14 will be 1(negative), if both positive, r14 will be 0(positive), same with both negative, r14 will be 0
    mov [result_sign], r14

    call print_result

    call print_newline
    jmp continue__

division:
    xor rdx, rdx                    ;Clear rdx since remainder will be stored there
    movsx rbx, dword[num2]
    movsx rax, dword[num1]

    test rbx, rbx                   ;Test rbx, which has the denominator, to see if it is 0
    je divide_0
    
    cqo                             ;Command to sign-extend before using idiv, which does unsigned division
    idiv rbx                        ;The quotient is now in rax, and the remainder is in rdx

    movzx r14, byte[num1_sign]      ;Same as with multiplication
    xor r14, [num2_sign]
    mov [result_sign], r14

    test rdx, rdx                   ;Test to see if its equal to 0, if 0 no remainder
    jne .print_remainder            ;If rdx is not 0, there is remainder
    
    call print_result

    call print_newline
    
    jmp continue__        

    .print_remainder:
        mov [remainder], rdx

        call print_result               ;Print whole part and negative sign if necesary

        mov rax, 1                      ;Print dot
        mov rdi, 1
        mov rsi, dot
        mov rdx, 1
        syscall

        xor r9, r9
        mov r9, 6                       ;Number of decimals that will be printed
        
        mov byte[result_sign], 0        ;If number was negative it was already printed with the whole part, set to 0 to not print - again

        ;This next section of compares has to do with the printing of the decimals, our print function cannot print negative numbers and from debugging
        ;we found out that depending of the numerator and denominator which one was negative, the remainder could also have the negative sign this next part
        ;checks to see if there is a need to negate the remainder, or since the denominator is used to divide to find the decimals, also to negate the denominator
        movzx r15, byte[num1_sign]
        cmp r15b, byte[num2_sign]        ;Check if both are the same sign
        je .both_same_sign

        cmp byte[num2_sign], 1          ;Check if num2 negative
        je .negative_denominador    

        cmp byte[num1_sign], 1          ;Check if num1 negative
        je .negative_numerator
        
        .decimals:
            movsx rax, dword[remainder]     ;Remainder has number left to fill (If remainder 3 and denominator 5, then it means 3/5)
            mov rcx, 10                     ;This block makes the remainder into the actual number (If 3/5, then this turns it into 6, which will print as 0.6 in this case)
            mul rcx
            movsx rbx, dword[num2]
            div rbx

            mov [remainder], rdx            ;Move remainder into remainder

            call print_result
            dec r9

            test r9, r9                     ;Checks to see if r9 is 0, this loop will print as many decimals as r9 is set to, including 0 if there is not more decimals
            jnz .decimals

            call print_newline

            jmp continue__
            
        .negative_denominador:      ;Denominator negative then we have to negate it to turn positive
            neg dword[num2]
            jmp .decimals

        .negative_numerator:        ;If numerator negative the remainder will also have - sign, so we need to negate it
            neg dword[remainder]
            jmp .decimals

        .both_same_sign:            ;If both are negative, then you have to negate the remainder and num2
            cmp byte[num1_sign], 1  ;Check here to see if negative, since first check is just to see if they are the same sign
            jne .decimals           ;If not negative, simply print out decimals

            neg dword[remainder]
            neg dword[num2]
            jmp .decimals


power:
    cmp byte[num2], 0       ;Check if num2 is 0, since any number to the power of 0 is 0
    je .power0

    cmp dword[num2], 0      ;If the power is negative, we need to do reciprocal, but first we find the normal power value
    jl .pow_first

    .start:
        movsx r9, dword[num2]   ;Has the number of times loop need to run
        mov rax, 1              ;Initialize it at 1 otherwise the mul happens one too many times since rax already has num1 from
        mov r11, [num1]         ;Ised to multiply itself

        cmp byte[num1_sign], 1  ;If it has a negative base we need to know if the result will be positive or negative
        je .handle_neg_base

        jmp .comence

        .handle_neg_base:
            test r9, 1          ;This is the equivalent of doing num2 % 2
            jz .even
            jmp .odd

            .even:              ;If the power is even, then the result will be positive
                mov byte[result_sign], 0
                jmp .comence

            .odd:               ;If the power is odd, the result will be negative
                mov byte[result_sign], 1
                jmp .comence


        .comence:
            imul rax, r11           ;Multiply by itself
            dec r9

            test r9, r9
            jnz .comence

        .end:
            cmp byte[num2_sign], 1          ;If the exponent is negative we need to prepare the reciprocal, otherwise we just print result
            je .prepare_reciprocal

            call print_result

            call print_newline
            jmp continue__

        .power0:            ;If the power is 0, result will be one no matter what so we just load 1 into rax and jump to the final part with the printing
            mov rax, 1
            jmp .end

        .pow_first:         ;Here we negate the base to make sure there isn't issues when multiplying and the negative signs
            neg dword[num2]
            jmp .start

        .prepare_reciprocal:            ;Here we prepare reciprocal for the negative exponent
            mov dword[num1], 1          ;We will reuse the division function, and num1 holds the numerator, we over write it to 1 since we are doing the reciprocal
            mov dword[num2], eax        ;32 bit resgister of rax, here we have the resulting number of the power stored, which will be the denominator
            mov byte [num1_sign], 0     ;We set the num1 sign to 0 since it doesn't matter what the base's sign was

            movsx rcx, byte[num2]       
            cmp rcx, 0           ;Here we compare to see if num2 is negative or not since the base sign affected the multiplication, since num2 has the power result
            jl .modify_sign

            mov byte [num2_sign], 0     ;Num2 has positive, we set the flag to 0 and call division

            call division

        .modify_sign:               ;Num2 holds a negative number, we set the flag and call division
            mov byte[num2_sign], 1
            call division

    ret

 
sqrt:
    cmp byte[num1_sign], 1          
    je square_root_exception        ;If number is negative throw exception

    cvtsi2ss xmm0, [num1]           ;Use cvtsi2ss to turn the integer into a single precision float, since sqrtss or sqrtsd only work with floats
    sqrtss xmm0, xmm0               ;Store the result in xmm0 since print float expects it there

    call print_float

    call print_newline
    jmp continue__

exponential:
    cmp byte[num1_sign], 1              ;Check if the exponent is negative
    je .turn_positive

    .execution:
        movsx r9, dword[num1]       ;Amount of times loop will run
        movss xmm0, [one]           ;Load 1 to start multiplying it self
        movss xmm1, [exp]           ;Load the e value
        .exp:                       ;Loop to multiply by itself as many times and input
            mulss xmm0, xmm1
            dec r9
            test r9, r9
            jnz .exp
        
        cmp byte[num1_sign], 1      ;Compare sign to prepare reciprocal or simply print result
        je .reciprocal

        .print_result:
            call print_float

            call print_newline
            
            jmp continue__

    .turn_positive:                     ;turns the exponent positive so it doesn't impact the result sign
        neg dword[num1]
        jmp .execution

    .reciprocal:
        mov eax, 1              ;Load 1 as the numerator
        cvtsi2ss xmm3, eax      ;Turn into float and store in xmm3
        divss xmm3, xmm0

        mov byte[num1_sign], 0  ;Turn the sign positive to not print wrong sign

        movss xmm0, xmm3        ;Move xmm3 into xmm0 since the print takes the number from xmm0
        jmp .print_result

ln:
    cmp dword[num1], 0
    jle ln_negative_input

    fild dword[num1]            ;Load both values needed into the stack
    fldln2  

    fxch                        ;After debugging values needed to be flipped, this flips the top 2 values in the stack
     
    fyl2x                       ;Computes ln(2) * log2(10) = ln(10)

    fstp dword[result]          ;Pops result into result

    movss xmm0, [result]        ;Move into xmm0 to print

    call print_float

    call print_newline
    jmp continue__

ascii_to_int:
    xor rax, rax                    ;Clear registers
    xor rcx, rcx
    mov byte[sign], 0               ;By default sign positive

    movzx rcx, byte[rsi]            ;Check if negative, if not move to the loop to turn into integer
    cmp cl, byte[negative_char]
    jne .convert_loop

    inc rsi                         ;Otherwise increase the pointer to rsi and set negative flag
    mov byte[sign], 1 

    .convert_loop:
        movzx rcx, byte[rsi]
        cmp rcx, 0x0a               ;Compare to newline, if equal no more digits, so exit loop 
        je .almost_finished

        sub rcx, '0'                ;Turns first digit into integer
        imul rax, rax, 10           ;Multiplies the value in rax by ten, to make space for the next byte
        add rax, rcx                ;It 'adds' the digit in rcx to rax
        inc rsi
        jmp .convert_loop

    .almost_finished:               ;If the number was negative, turn negative since final number in rax and set negative flag
        cmp byte[sign], 1
        jne .finish
        neg rax

    .finish:
    ret

print_result:                       ;Prints the result of the operations, need to inverse 
    mov rbx, 10                     ;Used for the division in the loop 
    xor rsi, rsi
    xor r8, r8
    cmp byte[result_sign], 0
    jne .handle_negative

    .reverse_loop:
        xor rdx, rdx
        div rbx         ;Divide by 10 to get the least significant value
        add dl, '0'     ;Add 0 to remainder to turn from integer to ascii value
        push rdx        ;push value onto stack to save it
        inc r8          ;Increase to know how many numbers to print
        test rax, rax
        jnz .reverse_loop

    .print_loop:
        pop rax             ;Pop the last pushed value, the most significant value
        mov [result], al    ;Store it into result

        mov rax, 1          ;Print the number
        mov rdi, 1
        mov rsi, result
        mov rdx, 1
        syscall

        dec r8 

        jnz .print_loop
    .done:
        ret

    .handle_negative:
       push rax             ;save result stored in rax in the stack

        mov rax, 1          ;Print negative sign
        mov rdi, 1
        mov rsi, negative_char
        mov rdx, 1
        syscall

        pop rax
        neg rax             ;turn positive to print correctly

        jmp .reverse_loop

print_float:
    cvttss2si rax, xmm0             ;Use cvttss2si to turn into an integer to reuse print_result, this cuts the float (20.99999 would be 20 after this)
    push rax                        ;Pushes into stack to save value
    call print_result               ;Prints whole part

    pop rax                         ;Pops the value pushed previously
    cvtsi2ss xmm1, rax              ;Turns rax into float
    subss xmm0, xmm1                ;Subtract xmm0 minus xmm1. This is to get the decimal part remaining (From 20.9999 to 0.9999)

    mov byte[result_sign], 0        ;Turn the rest positive to not print another negative sign
         
    mov rax, 1                      ;Prints the dot
    mov rdi, 1
    mov rsi, dot
    mov rdx, 1
    syscall
    
    mov r10, 6                      ;Number of decimals to print
    .printDecimal:
        mulss xmm0, [ten]           ;Multiply remaining value by ten to get the next digit
        cvttss2si rax, xmm0         ;Cut into an integer

        push rax                    ;Save value
        call print_result           ;Print value

        pop rax                     ;Pop value
        cvtsi2ss xmm2, rax          ;Turn into float
        subss xmm0, xmm2            ;Subtract so only decimals left again

        dec r10                     ;Repeat until 6 decimals have been printed
        cmp r10, 0
        jnz .printDecimal

    ret

invalid_operator:                   ;Prints the invalid operator message if needed and flushes the input
    mov rax, 1
    mov rdi, 1
    mov rsi, invalidOperatorString
    mov rdx, invalidOperatorLen
    syscall

    call flush_input

    jmp _start

square_root_exception:              ;Prints if you try to get the square root of a negative value
    mov rax, 1
    mov rdi, 1
    mov rsi, square_root_negative
    mov rdx, square_root_negativeLen
    syscall

    call flush_input

    jmp _start

flush_input:            ;Flushes input
    mov rax, 0
    mov rdi, 0
    mov rsi, flush
    mov rdx, 1
    syscall

    cmp byte[flush], 0x0a
    jne flush_input

    ret

divide_0:                       ;Prints the  message if you try to divide by 0 and flushes the input
    mov rax, 1 
    mov rdi, 1
    mov rsi, divide0String
    mov rdx, divide0Len
    syscall

    call flush_input

    jmp _start

not_a_number:                           ;Prints if you don't input numbers and flushes the input
    mov rax, 1 
    mov rdi, 1
    mov rsi, not_a_number_string
    mov rdx, not_a_number_stringLen
    syscall

    call flush_input

    jmp _start

print_newline:                          ;Prints a newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, newlineLen
    syscall

    ret

is_number:                               ;Checks if the input is a number           
    push rsi                             ;Saves value to use for ascii_to_int later
    xor rax, rax
    movzx rcx, byte [rsi]                ;first number loaded in rsi
    cmp cl, '-'                          ;check for negative sign
    jne .check_num
    inc rsi                              ;If negative sign skip it

    .check_num:
        movzx rcx, byte [rsi]   
        cmp cl, 0x0a                    ;if byte equal to newline input ended and valid
        je .valid

        cmp cl, '0'                     ;if less than 0 in ascii, is not number
        jb .not_number

        cmp cl, '9'                     ;if more than 9 in ascii, is not number
        ja .not_number

        inc rsi
        jmp .check_num

    .valid:
        pop rsi                         ;get value to use for ascii_to_int
        ret

    .not_number:
        jmp not_a_number                ;Jump to exception

continue__:                             ;Prints message if you want to continue using the calculator
    mov rax, 1
    mov rdi, 1
    mov rsi, 0x0a
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, continue_string
    mov rdx, continue_String_Len
    syscall

    mov rax, 0                          ;Reads user input to either end the program or continue
    mov rdi, 0
    mov rsi, want_continue
    mov rdx, 2
    syscall

    cmp byte[want_continue], 'y'    
    je _start

    cmp byte[want_continue], 'n'
    je exit

    jmp continue_wrong_input

continue_wrong_input:                   ;Prints when you don't enter n or y for the continue prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, continue_input
    mov rdx, continue_inputLen
    syscall

    call flush_input

    jmp continue__

ln_negative_input:                      ;Prints message when the user inputs a negative natural logarithm
    mov rax, 1
    mov rdi, 1
    mov rsi, ln_no_negative
    mov rdx, ln_no_negativeLen
    syscall

    call flush_input

    jmp _start

exit:                               ;Prints exit message and ends program
    mov rax, 1
    mov rdi, 1
    mov rsi, goodbye_string
    mov rdx, goodbye_string_Len
    syscall

    mov rax, EXIT
    xor rdi, EXIT_CODE
    syscall

    ret

