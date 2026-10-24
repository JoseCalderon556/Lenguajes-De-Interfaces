;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
mensaje BYTE "Escribe tu nombre: ",0 ;Declaracion del mensaje con terminacion 0 para senalar que termina ahi
nombre BYTE 30 DUP(0) ;Declaracion de un buffer con un espacio de 30 bytes e inicializados en 0

.code
main PROC
    ;movemos a edx la direccion de donde empieza la cadena y se llama a writestring para mostrar el mensaje
    mov edx, OFFSET mensaje 
    call WriteString 

    ;se mueve a edx la direccion de donde empieza el buffer y en ecx la cantidad maxima que puede leerse
    mov edx, OFFSET nombre
    mov ecx, SIZEOF nombre 

    call ReadString ;llamada del metodo para leer la cadena

    mov edx, OFFSET nombre ;Igualmente movemos la direccion a edx de donde empieza el nombre
    call WriteString ;llamada al metodo para escribir la cadena

    exit 

main ENDP

END main