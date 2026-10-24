;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.code
main PROC

    ; 1. ZF 
    ; Comparamos el mismo numero para hacer un resultado de 0
    mov eax, 5
    cmp eax, 5  

    call DumpRegs ; Muestra en consola el estado de todos los registros y banderas

    ; 2. SF
    ; Comparamos y hacemos que uno sea menor que el otro para que el resultado sea negativo
    mov eax, 3
    cmp eax, 8

    call DumpRegs

    ; 3. CF
    ; Se activa cuando requiere prestamo en operaciones sin signo
    mov eax, 10
    cmp eax, 20

    call DumpRegs

    ; 4. OF
    ; Se activa cuando hay desbordamiento en operaciones con signo
    mov al, 127 ; Maximo valor positivo para al
    cmp al, -1  ; 127-(-1)=128 se desborda

    call DumpRegs

    ; 5. Test
   
    mov al, 10000000b
    test al, 10000000b  ; Metodo que realiza una operacion AND bit a bit

    call DumpRegs  ;Se activa SF aunque no sea negativo ya que la cpu solo revisa el bit mas significativo. Si ese bit es 1 activa SF 

    exit
main ENDP

END main