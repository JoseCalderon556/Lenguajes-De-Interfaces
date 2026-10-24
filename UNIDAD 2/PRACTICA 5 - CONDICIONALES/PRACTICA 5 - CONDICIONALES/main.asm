;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    ;Mensaje a usar
    msgMostrar BYTE "El valor de EAX es: ", 0

.code
main PROC
    
    mov eax, 1

ciclo:
    ; Comparamos el valor en eax con 5
    cmp eax, 5
    jg  fin ;si eax es mayor que 5 salta a el fin de programa

    ;Mostramos mensaje 
    mov edx, OFFSET msgMostrar
    call WriteString
    call WriteInt ;muestra el valor en eax
    call Crlf ;hacemos salto de linea

    inc eax ;Incrementamos eax en 1
    jmp ciclo ;saltamos al inicio del ciclo

fin:
    exit

main ENDP
END main