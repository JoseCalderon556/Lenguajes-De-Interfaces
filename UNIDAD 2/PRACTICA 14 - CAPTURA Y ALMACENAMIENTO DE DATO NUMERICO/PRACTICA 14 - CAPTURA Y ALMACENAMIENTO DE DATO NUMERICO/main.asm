;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    existenciaInicial DWORD 25
    cantidadRecibida DWORD ?
    existenciaActual DWORD ?

    ; Buffer para captura de datos
    buff1 BYTE 10 DUP(0)
    
    ; Buffer para convertir de numero a texto
    buff2 BYTE 10 DUP(0)

    ; Mensajes
    msgPedir BYTE "Ingrese la cantidad recibida de tarjetas (1-99): ", 0
    msgError BYTE "Entrada invalida. Debe ser un numero entre 1 y 99.", 0
    msgResultado BYTE "Existencia actual en almacen: ", 0

.code
main PROC

pedir_entrada:

    ; 1. Pedir el texto al usuario

    ; Mostramos el mensaje para pedir los recibidos
    mov edx, OFFSET msgPedir
    call WriteString

    ; Capturamos la cadena con ReadString, en edx se guarda la direccion donde empieza el buffer y en ecx la cantidad de Bytes
    mov edx, OFFSET buff1
    mov ecx, SIZEOF buff1
    call ReadString ; eax devuelve la cantidad de caracteres leidos

    ; 2. Validacion de entrada
    
    ; Se hace una comparacion para evitar cadenas vacias, si es igual a 0 hace un salto
    cmp eax, 0
    je mostrar_error

    ; Se hace una comparacion para rechazar mas de 2 digitos, si son mas de 2 hace un salto
    cmp eax, 2
    ja mostrar_error

    ; 3. Validar digitos y convertir ASCII a Numero
    mov esi, OFFSET buff1 ; Apuntador a la cadena ingresada
    mov ecx, eax ; Contador de digitos ingresados
    mov eax, 0 ; Aqui acumularemos el valor numerico
    mov ebx, 0 ; Limpiamos ebx para usar bl

validar_loop:
    mov bl, [esi] ;Se carga el caracter actual

    ; Validamos que el caracter sea un numero
    cmp bl, '0' 
    jb mostrar_error ; Si es menor que '0' es una letra, signo, espacio, por lo que salta 
    cmp bl, '9'
    ja mostrar_error ; Si es mayor que '9' es cualquier otra cosa

    ; Convertir caracter ASCII a valor numerico
    sub bl, '0'

    ; Multiplicamos el valor acumulado por 10 y sumamos el nuevo digito
    imul eax, 10
    add eax, ebx

    inc esi ; Avanzamos al siguiente caracter incrementando el esi
    loop validar_loop

    ; 4. Validar que este entre 1 y 99
    cmp eax, 1
    jb mostrar_error ; Si es menor que 1 salta a la etiqueta
    cmp eax, 99
    ja mostrar_error ; Si es mayor a 99 salta a la etiqueta

    ; Guardamos en la variable requerida y saltamos al siguiente paso
    mov cantidadRecibida, eax
    jmp calcular_existencia
    
    ; Etiqueta donde se recibe los errores, se muestra el mensaje y vuelve a la entrada
mostrar_error:
    mov edx, OFFSET msgError
    call WriteString
    call Crlf
    call Crlf
    jmp pedir_entrada

calcular_existencia:
    ; 5. Sumar la cantidad recibida a la existencia inicial
    mov eax, existenciaInicial
    add eax, cantidadRecibida
    mov existenciaActual, eax

    ; 6. Mostramos el mensaje con el resultado
    mov edx, OFFSET msgResultado
    call WriteString

    ; Convertimos la existenciaActual a ASCII para imprimir con WriteString
    mov eax, existenciaActual
    call MostrarNumeroDecimal
    call Crlf

    exit
main ENDP


; Procedimiento que convierte el valor numerico de eax a texto y lo despliega usando WriteString
MostrarNumeroDecimal PROC
    ;Guardamos en la pila el estado actual de los registros antes de modificarlos
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, OFFSET buff2
    add esi, 9  ; Nos posicionamos al final del buffer
    mov BYTE PTR [esi], 0  ; Terminador nulo para la cadena

    mov ebx, 10 ; Divisor para extraer digitos

convertir_loop:
    mov edx, 0 ; Limpiamos edx
    div ebx ; Divide entre 10, el cociente se guarda en eax y el residuo en edx
    
    add dl, '0' ; Convertimos el residuo a su caracter ASCII
    dec esi ;Se decrementa para mover el puntero una posicion a la izquierda
    mov [esi], dl ; Guardamos el caracter en el buffer

    cmp eax, 0
    jne convertir_loop ; Repetimos mientras el cociente sea mayor a 0

    ; Mostramos la cadena convertida
    mov edx, esi
    call WriteString

    ;Se restauran los valores originales de los regitros antes de la llamada
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret ;regresa
MostrarNumeroDecimal ENDP

END main