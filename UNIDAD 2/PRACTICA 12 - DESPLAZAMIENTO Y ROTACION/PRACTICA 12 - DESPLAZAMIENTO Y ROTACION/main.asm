;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.code
main PROC
    ;limpiamos eax y ebx
    mov eax, 0 
    mov ebx, 0 

    ;1 SHL: DESPLAZAR UN BIT A LA IZQUIERDA 
    mov al, 10000110b ;Estado inicial
    shl al, 1 ;Desplazamos a la izquierda con shl

    call DumpRegs
    call WriteBin ;escribe los binarios

    ;2 SHR: DESPLAZAR UN BIT A LA DERECHA 
    mov al, 00001101b ;Estado inicial
    shr al, 1 ;Desplazamos a la derecha con shr

    call DumpRegs
    call WriteBin

    ;3 SAR: DESPLAZAMIENTO ARITMETICO CON SIGNO PAR
    mov eax, 0 ;limpiamos eax
    mov al, -8 ;asignamos valor a al
    sar al, 1 ;desplazamos un valor negativo 1 bit a la derecha conservando el signo

    call DumpRegs
    call WriteBin 

    ;4 SAR: DESPLAZAMIENTO ARITMETICO CON SIGNO IMPAR
    mov eax, 0 
    mov al, -9 ;movemos un valor a al
    sar al, 1 ;desplazamos con signo a la derecha redondeando hacia abajo

    call DumpRegs
    call WriteBin

    ;5 CONTEO CONSTANTE: DESPLAZAR CON 2 POSICIONES 
    mov al, 00001100b ;Estado inicial
    shl al, 2 ;desplazamos 2 posiciones a la izquierda

    call DumpRegs
    call WriteBin 

    ;6 CONTEO CON CL: UTILIZANDO REGISTRO 
    mov al, 00001100b ;Estado inicial
    mov cl, 2 ;copiamos el numero de desplazamientos a cl
    shr al, cl ;desplazamos al a la derecha el valor en cl

    call DumpRegs 
    call WriteBin 

    ;7 ROR, ROL, RCR, RCL: ROTACIONES DE BITS
    clc ;limpiamos la bandera de acarreo

    ; ROL: ROTACION A LA IZQUIERDA
    mov al, 10000001b ;Estado inicial
    rol al, 1 ;rotamos a la izquierda el bit mas significativo pasa al final y al carry
    call DumpRegs 
    call WriteBin 

    ; ROR: ROTACION A LA DERECHA 
    mov al, 10000001b ;Estado inicial
    ror al, 1 ;rotamos a la derecha el bit menos significativo pasa al inicio y al carry
    call DumpRegs 
    call WriteBin 

    ; RCL: ROTACION A LA IZQUIERDA A TRAVES DEL CARRY 
    mov al, 10000001b ;Estado inicial
    rcl al, 1 ;rotamos a la izquierda metiendo la bandera de carry en el bit menos significativo
    call DumpRegs 
    call WriteBin 

    ; RCR: ROTACION A LA DERECHA A TRAVES DEL CARRY 
    mov al, 10000001b ;Estado inicial
    rcr al, 1 ;rotamos a la derecha metiendo la bandera de carry en el bit mas significativo
    call DumpRegs
    call WriteBin 

    exit 

main ENDP
END main