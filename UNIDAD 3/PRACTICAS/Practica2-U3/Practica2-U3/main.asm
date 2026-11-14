;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

main PROC 
	mov eax,[esp]  ;se mueve a eax la direccion de la cima de la pila

	call WriteHex ;Imprime EAX en hexadecimal
	call Crlf

	call procUno ;call guarda en la pila la direccion de la instruccion siguiente

	exit
main ENDP
	
procUno PROC
	mov eax, [esp] ;al entrar la cima es la direccion de retorno hacia main

	call WriteHex ;la imprime
	call Crlf

	call procDos ;procUno llama a otro procedimiento por loque se guarda otra direccion de retorno
	
	ret ;regresa a main usando la direccion de retorno de procUno
procUno ENDP

procDos PROC
	mov eax, [esp] ;la cima ahora es la direccion de retorno hacia procUno

	call WriteHex
	call Crlf

	;el primer ret que se ejecuta es el de procDos ya que la llamada mas reciente guarda el primer retorno que se recupera y despues regresa procUno
	ret
procDos ENDP

END main
