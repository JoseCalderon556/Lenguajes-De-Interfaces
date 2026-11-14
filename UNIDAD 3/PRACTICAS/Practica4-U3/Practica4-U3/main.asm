;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

;Macro que muestra una cadena y hace salto de linea
MostrarMensaje MACRO texto
	mov edx, OFFSET texto ;MASM sustituye texto por el nombre que se le pase
	call WriteString
	call Crlf
ENDM

;Macro que multiplica 2 valores y miestra el resultado
Multi MACRO num1, num2
	mov eax, num1
	imul eax, num2 
	call WriteInt ;Imprime eax como entero
	call Crlf
ENDM

.data
	;mensajes
	mensajeBienvenida BYTE "Bienvenidos a la cripta", 0
	mensajeFin BYTE "Adios", 0

.code
main PROC 
	;Cuando se llama a la macro se expande las instrucciones de la macro durante la ejecucion
	MostrarMensaje mensajeBienvenida
	MostrarMensaje mensajeFin

	Multi 4, 5 ;igual se expande las instrucciones de la macro

	exit
main ENDP
END main