;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    msgIgualcero BYTE "El numero es igual a cero", 0 
    num DWORD ? ;Declaracion de variable con ? ya que no se sabe que va a contener

.code
main PROC

ciclo:
    call ReadInt ; Llamamos a ReadInt para que lea el entero dado por el usuario, luego lo guarda en eax

    cmp eax, 0 ; Se compara eax con 0
    je es_cero  ; Si son iguales salta a la etiqueta
    jmp ciclo ; Si no salto en la instruccion anterior vuelve al ciclo

    ;Se muestra el mensaje de que se ingreso el 0 y hace un salto de linea, luego termina el programa
es_cero:
    mov edx, OFFSET msgIgualcero
    call WriteString
    call Crlf

exit
main ENDP

END main