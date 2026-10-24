;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    ;declaracion de mensajes
    msgIguales BYTE "Los valores son iguales", 0
    msgDiferentes BYTE "Los valores son diferentes", 0

.code
main PROC

    ;movemos a eax el valor 5 para el ejemplo
	mov eax, 5

    ;jmp salta directamente a la etiqueta continuar, por lo que la intruccion de abajo no deberia llevarse a cabo
    jmp continuar
    mov eax, 10

    ;la instruccion continua aqui y de llana a DumpRegs para comprobar que si se hizo el salto

continuar:
    call DumpRegs

    ;asignamos valores a eax y ebx para nuevas comparaciones
    mov eax, 10
    mov ebx, 10

    cmp eax, ebx
    ;si al Comparar ambos valores son iguales brinca a la etiqueta iguales
    je iguales

    ;si son diferentes se muestra el mensaje respectivo y se hace un salto a fin
    mov edx, OFFSET msgDiferentes
    call WriteString

    jmp fin

    ;se muestra el mensaje respectivo
    iguales:
        mov edx, OFFSET msgIguales
        call WriteString

    ;se hace un salto de linea y termina el programa
    fin:
        call crlf
	    exit

main ENDP

END main