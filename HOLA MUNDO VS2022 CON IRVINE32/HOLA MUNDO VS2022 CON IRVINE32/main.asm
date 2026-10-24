;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc ;Recursos externos

.data
;Declaracion de un texto, finaliza con 0 para representar el fin del texto
mensaje BYTE "Hola, Mundo!", 0

.code
main PROC
	mov edx, OFFSET mensaje ;se guarda en edx la direccion de donde empieza el texto para que WriteString lo utilize
	call WriteString ;Llamada a el metodo de Irvine32 para escribir cadenas
	exit
main ENDP

END main