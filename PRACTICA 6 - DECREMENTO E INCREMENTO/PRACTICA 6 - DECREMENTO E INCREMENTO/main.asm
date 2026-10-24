;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    ;Declaramos los mensajes a utilizar
    msgPIN BYTE "Ingrese la clave: ", 0
    msgError BYTE "Clave Incorrecta.", 0
    msgAcceso BYTE "Acceso permitido", 0
    msgBloqueo BYTE "Sistema bloqueado", 0
    msgIntentos BYTE "Intentos restantes: ", 0

    ;Guardamos en una variable la clave con la que haremos la comparacion
    claveCorrecta = 1234

.code
main PROC
	
    mov ebx, 3 ; Se define el numero de intentos

	intentar:
    ;se pide al usuario que ingrese la clave
    mov edx, OFFSET msgPIN
    call WriteString
    call ReadInt ; Se lee por consola el numero que de el usuario

    cmp eax, ClaveCorrecta ; Se compara la clave que ingreso el usuario con la correcta

    je acceso ; Si son iguales salta a la etiqueta acceso

    ;se muestra un mensaje de error y hacemos un salto de linea
    mov edx, OFFSET msgError
    call WriteString
    call Crlf

    dec ebx ; se decrementa 1 a los intentos 

    jz bloqueado ; si los intentos son iguales a 0 salta a etiqueta bloqueado

    ;sino salta, se muestra el restante de intentos
    mov edx, OFFSET msgIntentos
    call WriteString ;muestra el mensaje
    mov eax, ebx
    call WriteDec ;muestra el numero de intentos
    call Crlf

    jmp intentar ;hace un salto para volver a intentar la clave

    ;si la clave coincidio se muestra el mensaje de acceso y salta al final
acceso:
    mov edx, OFFSET msgAcceso
    call WriteString
    jmp fin

    ;si despues de intentar los intentos son 0 salta a esta etiqueta y muestra un mensaje de que se bloqueo el sistema, luego salta al fin del programa
bloqueado:
    mov edx, OFFSET msgBloqueo
    call WriteString
    jmp fin

fin:
    exit
main ENDP
END main