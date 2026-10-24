;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    ; Datos
    tamanioTotal DWORD 100000 ; Tamanio completo del archivo en bytes
    bloquesRecibidos DWORD 125 ; Cantidad de bloques que llegaron
    tamanioBloque DWORD 512 ; Tamanio de cada bloque

    ; Variables para guardar los resultados
    bytesDescargados DWORD ?
    bytesPendientes DWORD ?
    porcentajeAvance DWORD ?
    grupos1024 DWORD ?
    residuo1024 DWORD ?

    ; Buffer para convertir texto
    buffer BYTE 11 DUP(0)

    ; Mensajes
    msgDescargados BYTE "Bytes descargados: ", 0
    msgPendientes BYTE "Bytes pendientes: ", 0
    msgPorcentaje BYTE "Porcentaje de avance: ", 0
    msgSimboloPct BYTE "%", 0
    msgGrupos BYTE "Grupos completos de 1024 bytes: ", 0
    msgResiduo BYTE "Residuo del agrupamiento: ", 0

.code
main PROC

    ; 1. CALCULAR BYTES DESCARGADOS
    ;se multiplican los bloques por los bytes
    mov eax, bloquesRecibidos
    mov ebx, tamanioBloque
    mul ebx ; eax = 125*512 = 64000
    mov bytesDescargados, eax

    ; 2. CALCULAR BYTES PENDIENTES
    ; De los 100000 totales llevamos 64000, por lo que con una resta salen los que faltan
    mov eax, tamanioTotal
    sub eax, bytesDescargados
    mov bytesPendientes, eax

    ; 3. CALCULAR PORCENTAJE
    ; El porcentaje se calcula con regla de 3, primero se multiplica por 100 y se divide entre el total
    mov eax, bytesDescargados
    mov ebx, 100
    mul ebx  ; eax = 64000 * 100 = 6400000
    mov edx, 0  ; Limpiamos edx para dividir sin errores
    div tamanioTotal ; eax = 6400000 / 100000 = 64%
    mov porcentajeAvance, eax

    ; 4. CALCULAR GRUPOS DE 1024 BYTES Y RESIDUO
    ; Se calcula con una division de los descargados/1024
    mov eax, bytesDescargados
    mov edx, 0
    mov ebx, 1024
    div ebx  ; en eax queda el cociente y en edx el residuo
    mov grupos1024, eax
    mov residuo1024, edx


    ; Bytes Descargados 
    ; Se muesrta el respectivo mensaje
    mov edx, OFFSET msgDescargados
    call WriteString
    mov eax, bytesDescargados
    mov esi, OFFSET buffer
    call convertirDecimal ; Devuelve en esi la direccion del numero convertido
    mov edx, esi ; Pasamos la direccion del numero a edx para imprimirlo
    call WriteString
    call Crlf

    ; Bytes Pendientes
    ; Se muesrta el respectivo mensaje
    mov edx, OFFSET msgPendientes
    call WriteString
    mov eax, bytesPendientes
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, esi  ; Pasamos esi a edx
    call WriteString
    call Crlf

    ; Porcentaje de avance
    ; Se muesrta el respectivo mensaje
    mov edx, OFFSET msgPorcentaje
    call WriteString
    mov eax, porcentajeAvance
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, esi ; Pasamos esi a edx
    call WriteString
    mov edx, OFFSET msgSimboloPct
    call WriteString
    call Crlf

    ; Grupos de 1024
    ; Se muesrta el respectivo mensaje
    mov edx, OFFSET msgGrupos
    call WriteString
    mov eax, grupos1024
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, esi ; Pasamos esi a edx
    call WriteString
    call Crlf

    ; Residuo de 1024
    ; Se muesrta el respectivo mensaje
    mov edx, OFFSET msgResiduo
    call WriteString
    mov eax, residuo1024
    mov esi, OFFSET buffer
    call convertirDecimal
    mov edx, esi ; Pasamos esi a edx
    call WriteString
    call Crlf

    exit
main ENDP



    ;Procedimiento que convierte numero a cadena 
convertirDecimal PROC
    ;Se guarda el contenido de los registros en la pila
    push eax
    push ebx
    push ecx
    push edx

    ; Colocamos el terminador nulo al final del buffer
    add esi, 10
    mov BYTE PTR [esi], 00h ; Delimitador nulo final

    mov ebx, 10 ; Base decimal para dividir

convertir_loop:
    mov edx, 0 ; Limpiamos edx para la division
    div ebx ; En eax queda el cociente y en edx la unidad

    add dl, 30h ; Convertimos la unidad rediduo a ASCII
    dec esi ; Movemos el puntero una posicion a la izquierda
    mov [esi], dl ; Guardamos el caracter en el buffer

    cmp eax, 0
    jne convertir_loop ; Repetimos mientras queden digitos

    ; Restauramos los valores originales de los registros antes de la llamada
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret ; regresdamos
convertirDecimal ENDP

END main