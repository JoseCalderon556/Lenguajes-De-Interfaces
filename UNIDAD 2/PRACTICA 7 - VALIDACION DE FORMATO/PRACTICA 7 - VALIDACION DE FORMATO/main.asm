;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    
    ;Declaracion de mesnajes y del buffer
    msgPedir  BYTE "Ingrese el codigo Formato (3 letras, guion, 3 numeros): ", 0 ;
    msgValido BYTE "Formato correcto", 0
    msgError  BYTE "Formato invalido, Intente de nuevo", 0

    bufferCodigo BYTE 31 DUP(0)

.code
main PROC

pedir_codigo:
    ;pedimos el texto al usuario
    mov edx, OFFSET msgPedir
    call WriteString

    ; Se guarda la direccion donde empieza la cadena en edx, ecx guarda la cantidad de bytes
    mov edx, OFFSET bufferCodigo
    mov ecx, SIZEOF bufferCodigo - 1
    call ReadString ;eax guarda el numero de caracteres leidos

    ;validamos que sean exactamente 7 caracteres por medio de una comparacion
    cmp eax, 7
    jne formato_invalido ;si no es igual salta a error

    ;validamos que las 3 primeras letras sean mayusculas
    mov esi, OFFSET bufferCodigo ;apuntamos al inicio de la cadena
    mov ecx, 3

validar_letras:
    mov al, [esi] ;Se guarda el caracter actual en al
    cmp al, 41h ;comparamos con el caracter'A' en hexadecimal
    jl  formato_invalido ;si es menor es cualquier otra cosa y salta a la etiqueta
    cmp al, 5Ah ;comparamos con 'Z' en hexadecimal
    jg  formato_invalido ;si es mayor salta a error
    inc esi ;incrementa la posicion
    loop validar_letras

    ;validamos que el guion este en la 3 posicion
    mov al, [esi]
    cmp al, 2Dh ;2Dh es el guion en hexadecimal
    jne formato_invalido ;si no es guion salta a error
    inc esi ;incrementa la posicion

    ;validamos los 3 ultimos digitos
    mov ecx, 3 ;revisamos 3 posiciones

validar_digitos:
    mov al, [esi]
    cmp al, 30h ;comparamos con '0' en hexa
    jl  formato_invalido ;si es menor puede ser una letra o simbolo asi que salta a error
    cmp al, 39h ;comparamos con '9' en hex
    jg  formato_invalido ;si es mayor tambien puede ser cualquier otra cosa asi que salta
    inc esi ;avanzamos posicion
    loop validar_digitos

    ; Si paso todas las validacion anteriores entonces se muestra el mensaje y termina el programa
    mov edx, OFFSET msgValido
    call WriteString

    exit

    ;Si hubo un error en el formato muestra el meensaje y vuelve al inicio
formato_invalido:
    mov edx, OFFSET msgError
    call WriteString
    jmp pedir_codigo

main ENDP
END main