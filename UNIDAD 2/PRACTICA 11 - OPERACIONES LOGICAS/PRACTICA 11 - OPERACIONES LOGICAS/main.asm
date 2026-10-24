;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    msgAlarma BYTE "La alarma esta encendida", 0

.code
main PROC

    ; bit 0 - Encendido de computadora
    ; bit 1 - Alarma
    ; bit 2 - Conectado
    ; Estado inicial: 00000101b


    ; 1 - AND: EXTRAER EL ESTADO DE ENCENDIDO
    ;se limpian los registros eax y ebx
    mov eax, 0
    mov ebx, 0
    ;se copia el estado inicial en al y luiego en bl
    mov al, 00000101b
    mov bl, al
    ;se hace la operacion AND con una mascara, si el bit 0 es 1, bl resulta 1 osea encendida, si el bit 0 es 0 bl resulta 0 osea esta apagada
    and bl, 00000001b

    call DumpRegs ; muestra el estado de los registros en consola
    nop


    ; 2 - OR: ENCENDER ALARMA
    ;se restablece al al estado inicial 
    mov al, 00000101b
    ;se hace la operacion OR con una mascara, fuerza a encender el bit 1 y mantiene los demas igual
    or al, 00000010b 

    call DumpRegs
    nop


    ; 3 - XOR: DESCONECTAR Y CONECTAR COMPUTADOR
    ; Invierte el estado del bit 2
    mov al, 00000101b
    xor al, 00000100b ;Desconecta

    call DumpRegs

    xor al, 00000100b ;Vuelve a conectar

    call DumpRegs
    nop


    ; 4 - NOT: DEVOLVER ESTADOS
    ; Invierte todos los bits
    mov al, 00000101b
    not al ; Como resultado quedaria 11111010b

    call DumpRegs
    nop


    ; 5 - TEST - EVALUAR ALARMA Y REALIZAR SALTO

    ;Evalua el bit 1 sin modificar al
    mov al, 00000010b ;Estado con alarma encendida
    test al, 00000010b ;Compara con la mascara

    jz alarmaApagada ;Salta si la alarma esta en 0

    ;Mostramos el mensaje de que la alarma esta encendida
    mov edx, OFFSET msgAlarma
    call WriteString
    call Crlf

alarmaApagada:
    call DumpRegs
    nop

    exit
main ENDP
END main