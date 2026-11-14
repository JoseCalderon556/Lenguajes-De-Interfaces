;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.data
;Mensajes
mensajeInicio BYTE "inicio de programa",0
mensajeProcedimiento BYTE "Estoy dentro del procedimiento",0
mensajeFin BYTE "Fin del programa",0

.code
main PROC
	;Se imprime el mensaje de inicio
	mov edx, OFFSET mensajeInicio
	call WriteString
	call Crlf

	;Primera llamada
	call mensajeAviso ;Call guarda en la pila la direccion de la siguiente instruccion y EIP salta al proc

	mov eax, 10 ;Se ejecuta solo cuando ret regresa

	;Segunda llamado 
	call mensajeAviso ;EIP salta de nuevo a las instrucciones dentro del proc

	mov eax, 20 ;Se ejecuta solo cuando ret regresa

	;Se imprime el mensaje de inicio
	mov edx, OFFSET mensajeFin
	call WriteString
	call Crlf

	exit
main ENDP

;Procedimiento que solo muestra un mensaje en pantalla
mensajeAviso PROC
	mov edx, OFFSET mensajeProcedimiento
	call WriteString
	call Crlf
	ret  ;Toma de la cima de la pila la direccion guardada por call y la carga en EIP y regresa
mensajeAviso ENDP

END main