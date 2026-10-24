;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.code
main PROC

    ; 1. SUMA Y RESTA

    mov eax, 50 ;le damos a eax valor de 50
    add eax, 20 ;se le suma 20
    sub eax, 15 ;se le resta 15

    nop 

    ; 2. CF: ACARREO EN UNA SUMA SIN SIGNO

    mov eax, 0 ;limpiamos eax
    mov al, 255 ;se asigna a al el valor maximo sin signo
    add al, 1 ;se le suma 1 lo que hace que al vuelva a 0 y se active CF 

    nop

    ; 3. OF: CONDICION DE DESBORDAMIENTO

    mov eax, 0 
    mov al, 127 ;se asigna a al el valor maximo con signo
    add al, 1 ;suma 1 a al hacindo que se desborde y activa OF

    nop

    ; 4. MUL: MULTIPLICACIÓN DE VALORES DENTRO DE 32 BITS

    mov eax, 25 ; se asigna a eax el primer numero a multiplicar
    mov ebx, 3  ; se asigna a ebx el segundo numero a multiplicar

    mul ebx ; multiplica ebx por eax, como el resultado si cabe dentro de los 32 bits se guarda completo en eax y edx queda en 0

    nop

    ; 5. MUL: PRODUCTO QUE NECESITA MÁS DE 32 BITS.

    ;se asignan valores que multiplicandolos se superen los 32 bits
    mov eax, 65537
    mov ebx, 65537

    mul ebx ; se hace la multiplicacion de eax y ebx, el resultado supera los 32 bits por lo que los 32 bits superiores van a edx y los inferiores a eax

    nop

    ; 6. IMUL: MULTIPLICACIÓN CON SIGNO

    mov eax, -5 ;asignamos un negativo

    imul eax, eax, 3 ;se guarda en eax el resultado del valor en eax por 3

    nop

    ; 7. DIV: DIVIDIENDO SIN SIGNO

    mov eax, 125 ;es el dividendo
    mov edx, 0   ;se limpia el registro donde se guarda el residuo
    mov ebx, 12  ;es el divisor

    div ebx ;realiza la division y el cociente se guarda en eax, el residuo en edx

    nop

    ; 8. IDIV: DIVISION CON SIGNO

    mov eax, -125 ;asignamos un negativo

    cdq ;llena de 1 si eax es negativo o llena de 0 si es positivo

    mov ebx, 12 ;divisor

    idiv ebx ;hace la division con signo y guarda el cociente en eax y el residuo en edx

    nop
main ENDP

END main