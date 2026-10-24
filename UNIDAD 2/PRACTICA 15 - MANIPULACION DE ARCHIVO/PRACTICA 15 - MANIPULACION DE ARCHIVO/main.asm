;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
    ;Declaramos el texto que va a estar en el archivo y tambien mensajes para mostrar resultados 
	nombreArchivo BYTE "Inventario.txt", 0
    texto BYTE "125", 0
    archivoHandle DWORD ?
    
    mensajeExito BYTE "Archivo guardado correctamente.", 0
    mensajeError BYTE "No se pudo guardar el archivo", 0

.code
main PROC

	; 1. Crear archivo txt.
    ;Primero movemos a edx la direccion del nombre que va a tener el archivo y luego llamamos a CreateOutputFile el cual recibe la direccion y crea el archivo
    mov edx, OFFSET nombreArchivo
    call CreateOutputFile
    
    ;Si el metodo tuvo exito deberia devolver el handle en eax por lo que comparamos lo que hay en eax ya que si es diferente de -1 entonces no fallo, si falla se brinca a la etiqueta error
    cmp eax, INVALID_HANDLE_VALUE
    je error

    ; guardamos en otra variable el handle del archivo para no perderlo
    mov archivoHandle, eax

    ; 2. Escribir caracteres en archivo txt.
    ;asignamos a los registros lo que WriteToFile requiere: el handle en eax, la direccion del buffer en edx y la cantidad de bytes a escribir en ecx, luego se llama al metodo
    mov eax, archivoHandle
    mov edx, OFFSET texto
    mov ecx, SIZEOF texto - 1 ;el -1 sirve para que no se incluya el 00h 
    call WriteToFile

    jc errorEscritura ;si se activo cf hubo un error al escribir asi que saltamos a la etiqueta

    ;si eax contiene la cantidad de bytes recuperados entonces tuvo exito sino hubo un error en la escritura
    cmp eax, SIZEOF texto - 1
    jne errorEscritura

    ; 3. Cerrar archivo txt
    ;movemos otra vez a eax el handle para que CloseFile lo use
    mov eax, archivoHandle
    call CloseFile

    ;aqui hacemos la prueba para saber si el archivo cerro correctamente si es diferente de 0 tuvo exito si es igual a 0 hubo un error y saltamos a la etiqueta
    test eax, eax
    jz error

    ;aqui ya solo mostramos el mensaje de exito y saltamos al fin del programa
    mov edx, OFFSET mensajeExito
    call WriteString
    jmp fin


;etiquetas de errores y de fin

errorEscritura:
    mov eax, archivoHandle
    call CloseFile

error:
    mov edx, OFFSET mensajeError
    call WriteString

fin:
	exit
main ENDP

END main