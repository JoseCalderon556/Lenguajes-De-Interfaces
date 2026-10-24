;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    CAPACIDAD EQU 5 ;Capacidad maxima del estacionamiento
    carros DWORD 2  ;Cantidad inicial de carros

    ;Declaracion de mensajes a usar
    msgCap   BYTE "Carros en estacionamiento: ", 0
    msgLleno BYTE " (LLENO)", 0
    msgVacio BYTE " (VACIO)", 0
    msgOpc   BYTE "1=Entrar, 2=Salir, 0=Terminar: ", 0
    msgErr   BYTE "Opcion no valida o limite alcanzado", 0

.code
main PROC

inicio:
    ; 1. Mostrar cantidad de carros que hay
    mov edx, OFFSET msgCap
    call WriteString
    mov eax, carros 
    call WriteDec

    ; Se verifica si el estacionamiento esta lleno o vacio
    cmp carros, CAPACIDAD
    je es_lleno ;Si la cantidad de carros es igual a la capacidad maxima brinca a la etiqueta
    cmp carros, 0
    je es_vacio ;Si la cantidad de carros es igual a 0 entonces esta vacio y salta a la etiqueta
    jmp pedir_opcion

    ;Se muestra por mensaje que esta lleno
es_lleno:
    mov edx, OFFSET msgLleno
    call WriteString
    jmp pedir_opcion

    ;Se muestra por mensaje que esta vacio
es_vacio:
    mov edx, OFFSET msgVacio
    call WriteString

pedir_opcion:
    call Crlf ; Salto hace salto de linea antes de pedir opcion
    mov edx, OFFSET msgOpc
    call WriteString ;muestra el mensaje de opciones
    call ReadInt ; Se lee por consola la opcion del usuario y se guiarda en eax

    ; 2. Evaluar Opcion
    cmp eax, 0
    je fin ;si es igual a 0 entonces se salta a la terminacion del programa 

    cmp eax, 1
    je entrar ; si es igual a 1 salta al procedimiento de entrada

    cmp eax, 2
    je salir ; si es igual a 2 salta al procedimiento de salida

    ; Si la opcion seleccionada no es ninguna de las anteriores se muestra un mensaje de error y vuelve a empezar el programa
    call Crlf
    mov edx, OFFSET msgErr
    call WriteString
    call Crlf
    jmp inicio

entrar:
    ; Se verifica que no este lleno el estacionamiento, si esta lleno salta a un procedimiento de error
    cmp carros, CAPACIDAD
    je error_accion

    inc carros ;Se incrementa la cantidad de carros
    call Crlf ;salto de linea
    jmp inicio ;vuelve al principio

salir:
    ; Se verifica si esta vacio, si esta vacio manda al procedimiento de error
    cmp carros, 0
    je error_accion

    dec carros ;Se decrementa la cantidad de carros
    call Crlf ;salto de linea
    jmp inicio ;vuelve al inicio

    ;muestra un mensaje de error y vuelve al inicio
error_accion:
    call Crlf
    mov edx, OFFSET msgErr
    call WriteString
    call Crlf
    jmp inicio

fin:
    exit
main ENDP
END main