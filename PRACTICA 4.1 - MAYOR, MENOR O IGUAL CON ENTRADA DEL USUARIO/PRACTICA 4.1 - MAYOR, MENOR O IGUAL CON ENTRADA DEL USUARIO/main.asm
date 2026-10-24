;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    ;inicializamos los 2 valores a comparar con ? ya que no sabemos que no esta claro
    val1 DWORD ?
    val2 DWORD ?

    ;tambien declaramos los mensajes a mostrar
    msgNum1  BYTE "Ingresa el primer numero: ", 0
    msgNum2  BYTE "Ingresa el segundo numero: ", 0
    msgMayor BYTE " es MAYOR que ", 0
    msgMenor BYTE " es MENOR que ", 0
    msgIgual BYTE " es IGUAL a ", 0

.code
main PROC

    ; 1. Pedimos los valores a comparar

    ;Mostramos el mensaje primero para pedir el valor 1
    mov edx, OFFSET msgNum1
    call WriteString 
    call ReadInt ;Lee un entero y lo guarda en eax
    mov val1, eax ;Guardamos en la variable val1

    ;Mostramos el mensaje para pedir el valor 2 y hacemos la captura
    mov edx, OFFSET msgNum2
    call WriteString
    call ReadInt
    mov val2, eax

    ; 2. Comparar el primer numero contra el segundo
    mov eax, val1
    cmp eax, val2

    ; 3. Saltos condicionales
    je es_igual  ; Salta si los valores son iguales
    jg es_mayor  ; Salta si val1 es amyor que val2
    jl es_menor  ; Salta si val1 es menor que val2

    ;Se muestra el valor 1 luego el mensaje de iguales y luego el valor 2, luego se hace un salto de linea y salta a el fin de programa
es_igual:
    mov eax, val1
    call WriteInt ; Muestra val1
    mov edx, OFFSET msgIgual
    call WriteString
    mov eax, val2
    call WriteInt ; Muestra val2
    call Crlf
    jmp fin

    ;Se muestra el valor 1 luego el mensaje de mayor que y luego el valor 2, luego se hace un salto de linea y salta a el fin de programa
es_mayor:
    mov eax, val1
    call WriteInt
    mov edx, OFFSET msgMayor
    call WriteString
    mov eax, val2
    call WriteInt
    call Crlf
    jmp fin

    ;Se muestra el valor 1 luego el mensaje de menor que y luego el valor 2, luego se hace un salto de linea y salta a el fin de programa
es_menor:
    mov eax, val1
    call WriteInt
    mov edx, OFFSET msgMenor
    call WriteString
    mov eax, val2
    call WriteInt
    call Crlf
    jmp fin

fin:
    exit
main ENDP
END main