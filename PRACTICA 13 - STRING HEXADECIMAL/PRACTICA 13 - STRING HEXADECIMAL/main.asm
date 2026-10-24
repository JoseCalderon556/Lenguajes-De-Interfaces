;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    ;Declaramos mensaje y un buffer
    msgResult BYTE "El valor en hexadecimal es: ", 0
    cadenaHex BYTE 9 DUP(0)

.code
main PROC

    mov eax, 24BE72ACh ;valor numerico de prueba
    ;Apuntamos a la direccion de comienzo del buffer y nos posicionamos al final para llenar de derecha a izquierda
    mov esi, OFFSET cadenaHex
    add esi, 7
    mov ecx, 8 ;procesamos los 8 digitos hex

convertir_hex:
    mov edx, eax
    and dl, 0Fh ;mascara AND 0Fh para aislar los 4 bits bajos

    cmp dl, 9
    jg  es_letra ; comparamos si es mayor a 9 pasa a convertir letras A-F

    or  dl, 30h ;mascara OR 30h para pasar digito 0-9 a ascii
    jmp guardar_caracter

es_letra:
    add dl, 37h ;37h,55 decimal convierte valores 10-15 directo a ascii de A - F

guardar_caracter:
    mov [esi], dl ;guardamos el caracter ascii en la posicion actual
    dec esi ;retrocedemos una posicion en la cadena
    shr eax, 4
    loop convertir_hex

    ;mostramos los mensajes resultado
    mov edx, OFFSET msgResult
    call WriteString 
    mov edx, OFFSET cadenaHex 
    call WriteString 
    call Crlf ; hace el salto de linea

    exit 

main ENDP
END main