# Linux x86-64 Assembly Calculator

## Production Team

Name: Mael Fernandez Jimenez  
Student Number: 547725  

Name: Konstantin Apostolov  
Student Number: 552608  

## Table Of Contents

1. Introduction  
2. Project Setup  
3. Coding Concepts  
   - Variable Declaration  
   - Input Handling  
   - Mathematical Operations  
   - Error Handling  
4. Result Display  
5. Usage Guidelines  
6. Future Improvements  
7. References  

---

## Introduction  

In the realm of low-level programming, understanding how fundamental mathematical operations are performed at the lowest level of all the programming languages is a unique and great experience to understand the basic concepts from a different perspective. This project was developed as part of the course **Advanced Programming Concepts** to explore how essential programming concepts are used, such as handling output and user input, constructing and implementing simple and complex mathematical operations, memory management, and LEA operations using **Linux x86-64 Assembly language (NASM).**  

This calculator supports various arithmetic operations like **addition, subtraction, multiplication, division, exponentiation, square root, natural logarithm, and exponential functions**. This project helped us understand why languages are divided into **high-level and low-level** and how high-level languages translate into low-level machine code.  

---

## Project Setup  

To set up and run this project, you will need an Assembly compiler. We used **NASM**, but you could also use **MASM** or another compiler that supports **x86-64 assembly**.  

### Prerequisites  

- Linux operating system (WSL or others also work).  
- NASM Assembler  
- GNU linker (`ld` command)  

### Downloading NASM  

```bash
sudo apt-get install nasm
sudo apt install binutils
```

### Compiling and Executing  

```bash
nasm -f elf64 calculator.asm -o calculator.o
ld calculator.o -o calculator
./calculator
```
- You should get output like this ![Compilation Screenshot](https://raw.githubusercontent.com/Doufless1/Assembly/main/docs/pics/after_compiling.png)
---

## GDB debugging

Further you will need gdb to debug
```bash
sudo apt install gdb
```
After that we used some gdb extention called gdb dashboard
```bash
git clone https://github.com/cyrus-and/gdb-dashboard.git
mv gdb-dashboard ~/.gdb-dashboard
echo "source ~/.gdb-dashboard/.gdbinit" >> ~/.gdbinit
```
After you have done this u have a functional gdb Dashboard!
Lastly if you want to compile your code and run with gdb you have to do this

```bash
nasm -f elf64 -g calculator.asm -o calculator.o
ld calculator.o -o calculator
gdb ./calculator
```

##Additional Notes
If you want to use a breakpoint you can just type b <the_function_you_want>
You run the program with run/r
If there is a segmentation fault u can always use strace or backtrace
To print some of the registers u can do x/10x $rsp (x is for hexadecimal d is for decimal c is for char)
To print variables x/8x &<the name of the variagble> (also like said previous u can change the 8x to 8d for decimala nd 8c for char 8 its just for the bits).


## Coding Concepts  

### Variable Declaration  

Assembly provides two primary ways to declare variables:To declare variables in Assembly there are you ways. If you know what the variable should hold, like a string to output or a constant variable, you declare it in 'section .data'. This section is reserved for variables which you know the contents of before the execution of the program. Here are some examples of how we declared our variables:  

1. **Predefined Variables (section .data)**  
   - Variables defined in `.data` are known **before execution**.
   - Used for constants, messages, and predefined values.

```assembly

section .data 

   InputString1            DB "Enter the first number", 0x0a 

    stringLen1              equ $ - InputString1 

    InputString2            DB "Enter the second number", 0x0a 

    stringLen2              equ $ - InputString2 

    operatorString          DB "Enter opetator (+ - * / ^ ~ e l)" 

    operatorLen             equ $ - operatorString 

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

```  
2. Define Varibles

First you put the name of the variable, then you need to put the amount of bytes you allocate per value, for the strings using DB we are allocating 1 byte per character. After you decide the allocation size, you put the value you want, in this case a string, and at the end you add 0x0a which is ascii code for a newline. After the declaration of each string there is a variable for the lenght using 'equ', this automatically gets the bytes the string needs. This will be important later for printing to the console. 

You can also declare numeric variables or characters you might need using the same method. If you noticed, for floats we used DD, which stores 4 bytes, this is needed since we need the extra precision. 

 

The second method to declare variables is in 'section .bss', here you directly allocate the memory you need for a variable, but you do not assign any value to it. In this program this is used for the buffer to store the numbers, operator and other things we set through out the program. 

 

```assembly 

section .data 

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

```
---


## Input Handling  

 

Fr the design of the calculator the most important thing is how the input is handled. The first step was to figure out how to output a message to the console. To do this you needed to have a set of register with certain values to indicate to print to the console. This is the general structure: 

```assembly

    mov rax, 1 

    mov rdi, 1 

    mov rsi, (The string to print)  

    mov rdx, (The lenght of the string) 

    syscall 

``` 

 

The string you want to print should have been declared already, as well as the lenght following the example from the previous section. 

The syscall tells the computer to execute it to produce output. For handling input the general structure is the same: 

 

```assembly

    mov rax, 0 

    mov rdi, 0 

    mov rsi, (Variable or buffer to store input)  

    mov rdx, (How many bytes you want to read) 

    syscall 

``` 

Similar as before, the buffer or variable should have been declared beforehand, as well as how many doublewords or bytes you want to read. Therefore both should be filled appropriately. 

 

This is how we ask the user for input and how we store it. Here is the snippets where we ask the user to enter a number, and how we store it. 

 

```assembly 

    mov rax, 1              ;Ask for the input 

    mov rdi, 1 

    mov rsi, InputString1      

    mov rdx, stringLen1 

    syscall 

 

    mov rax, 0             ;Read number 1 from input 

    mov rdi, 0 

    mov rsi, num1 

    mov rdx, 10 

    syscall 

     

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

``` 

But we are not done handling the input. For the operator character no changes need to be made, but when you input a number in Assembly it is not stored as '123' it is stored as '4202984' when you move it to a register. This is the ascii value of the number, which you have to handle to turn into integers, otherwise the operations will give unexpected results. For this there are two checks in place, the first one to check if it is a number, if it is, then we procede to call the function ascii_to_int to get the integer value to perform the necessary operations. 

 

We first check the first byte to see if it is negative, if it is we move onto the next byte, and check each byte of the input number to see if they are between the bounds of the ascii representations of numbers. If the byte is not a number it will print a message detailing the error and ask again for input. The check ends successfully when the newline character is found. 

Here is the function: 

 

```assembly

is_number:         

    push rsi                              

    xor rax, rax 

    movzx rcx, byte [rsi]                ;first byte loaded in rsi 

    cmp cl, '-'                          ;check for negative sign 

    jne .check_num 

    inc rsi                              ;If negative sign skip it 

 

    .check_num: 

        movzx rcx, byte [rsi]    

        cmp cl, 0x0a          ;if byte equal to newline input ended and valid 

        je .valid 

 

        cmp cl, '0'                   ;if less than 0 in ascii, is not number 

        jb .not_number 

 

        cmp cl, '9'                   ;if more than 9 in ascii, is not number 

        ja .not_number 

 

        inc rsi 

        jmp .check_num 

 

    .valid: 

        pop rsi 

        ret 

 

    .not_number: 

        jmp not_a_number                ;Jump to exception 

``` 

As seen, the check is quite a long proccess compared to other languages, where they already have especific commands for it, like is_digit for c++. 

 

Next step is to turn into integer, to do this we check for the negative sign, and save if it is negative, since we assume the number is positive by default. After checking for the sign, we go into a loop where we get the ascii value of the number, subtract the ascii value of 0 to get the real number and add it to rax. The next iteration we multiply rax by ten to make space for the next number. We do this until we get to the newline character. 

Here is the function. 


```assembly

ascii_to_int: 

    xor rax, rax                    ;Clear registers 

    xor rcx, rcx 

    mov byte[sign], 0               ;By default sign positive 

 

    movzx rcx, byte[rsi]            ;Check if negative, if not move to the loop to turn into integer 

    cmp cl, byte[negative_char] 

    jne .convert_loop 

 

    inc rsi 

    mov byte[sign], 1  

 

    .convert_loop: 

        movzx rcx, byte[rsi] 

        cmp rcx, 0x0a               ;Compare to newline, if equal no more digits, so exit loop  

        je .almost_finished 

 

        sub rcx, '0'                ;Turns first digit into integer 

        imul rax, rax, 10 

        add rax, rcx                ;It 'adds' the digit in rcx to rax 

        inc rsi 

        jmp .convert_loop 

 

    .almost_finished:        

        cmp byte[sign], 1 

        jne .finish 

        neg rax 

 

    .finish: 

    ret 

```` 

Now we are almost done handling the input. They only thing left is to same the result stored in [sign] and the final integer, stored in [rax]. To do this we store it in num1. To store the sign in [num1_sign], we need to use a register as intermediary since you cannot store the value of a variable into another variable directly. 

````assembly 

    mov [num1], rax            

    mov r12b, byte[sign] 

    mov [num1_sign], r12b 

```` 

 

After this, you have everything you need to start the mathematical operations, you have the integer value of the number and the sign. o
---

## Mathematical Operations  

This calculator supports:  

- **Basic Arithmetic** (`+`, `-`, `*`, `/`)  
- **Exponentiation (`^`)**  
- **Square Root (`~`)** using `SQRTSS`  
- **Exponential Function (`e^x`)** using `MULSS`  
- **Natural Logarithm (`ln`)**  

Example **Square Root Calculation**:  

```assembly
sqrt:
    cvtsi2ss xmm0, [num1]  ; Convert integer to float
    sqrtss xmm0, xmm0      ; Compute square root
    cvttss2si rax, xmm0    ; Convert back to integer
```
Most of the implementations are pretty simple, except two, division and exponentiation. We are going to break down a bit more these two functions and the logic behind them.

### Division
We will start with the division function. For using division we will use 'idiv' command which is unsigned division, the quotient will be stored in [rax] and the remainder in [rdx] if there is one, otherwise it will be 0. For the sign we use a xor between [num1_sign] and [num2_sign], where the result is stored in [result_sign]. If there is no remainder, the function is simple enough, we will simply print the result, but if there is remainder it gets a little complicated.

We will jump to .print_remainder, save the remainder and print the quotient first, next we print the dot for the remainder. After this a very important and simple step, turn the [result_sign] to 0, if you do not do this it will impact the printing of the decimals, printing negative signs when it should not.

If both numbers are positive we will simply enter the loop to turn the remainder into decimals and print them out one by one, with a maximum of six decimals. This amount of decimals can be changed by increasing or decreasing the initial value of [r9].

Doing a lot of testing there are different things you need to do depending on what number is negative. First case: Negative denominator. In this case we have to negate [num2]. This is because in the loop num2 is used to divide to find the decimal value of the remainder, if this is negative it will impact the result and the printing.

If the numerator is negative, the remainder will be negative as well, which will impact the printing of the decimals, so we negate the [remainder] to make sure this does not happen.

The last case is both numerator and denominator are negative. In this case we have to negate both the [remainder] and [num2]. The reason for this is equal to each of them separately.

### Exponentiation
Now we will move on to exponentiation. For exponentiation we check first if [num2] is 0, since any number to the power of 0 is 0. Next we check if the value of [num2] negative, if it is we simply negate [num2], if it is not negative we simple move to check the base.

If the base is negative, we check to see if the exponent ([num2]) is even or odd, if it is odd, we move into [result_sign] a 1, otherwise a 0. This is to check is the result will be negative or not. Next up is the loop.

The loop is simple, the numbers are loaded into registers and we multiply [num1] against itself as many times as [num2] indicates. After this is done, we check to see if [num2_sign] is 1, if it is we go to prepare the reciprocal. If not we simply print the answer.

If we need to prepare the reciprocal, we overwrite [num1] with 1, move the resulting number from the loop, which is in rax, into [num2]. This is because we are going to reuse the division function. We also set [num1_sign] to 0, since it doesn't impact the sign of the result. We have to check if the result from the loop is negative, if it is we set [num2_sign] to 1 and call division. If it is not negative, then we set [num2_sign] to 0 and call division.

This is how this two functions work, we choose to explain this two since they can be the most confusing ones and it required a lot of testing to make sure the result was printed correctly with the correct sign.

---

## Error Handling  

- **Invalid Input Handling:** Rejects non-numeric characters.  
- **Division by Zero Prevention:** Displays an error message if `num2 == 0`.  
- **Negative Square Root Prevention:** Returns an error for negative values.  

Example **Division by Zero Handling**:  

```assembly
test rbx, rbx
je divide_0  ; Jump to error handler if divisor is zero
```

---

## Future Improvements  

- **Support for floating-point arithmetic (e.g., 3.2, -1.2, etc.)**  
- **Optimization of logarithm calculations**  
- **Implementing support for trigonometric functions (sin, cos, tan, etc.)**  
- **Adding modulus (%) operation for computing remainders**  
- **Command history feature to allow users to view previous calculations**  
- **Error handling improvements for more user-friendly error messages**  
- **Expanding functionality to support complex number arithmetic**  

---

## References  

- Ed Jorgensen, Ph.D., *x86-64 Assembly Language Programming with Ubuntu*, Version 1.1.58  
- NASM Instruction Documentation: [http://home.myfairpoint.net/fbkotler/nasmdocc.html#section-A.4.114](http://home.myfairpoint.net/fbkotler/nasmdocc.html#section-A.4.114)  
- NASM Forum Discussion on Square Root Calculation: [https://forum.nasm.us/index.php?topic=3901.0](https://forum.nasm.us/index.php?topic=3901.0)  
- Stack Overflow: [https://stackoverflow.com/](https://stackoverflow.com/)  
