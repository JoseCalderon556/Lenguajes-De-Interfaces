;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.code
main PROC

	;usamos ecx como contador con un valor de 5 
	mov ecx, 5
	jecxz fin_ciclo ;salta a fin de ciclo si ecx es igual a 0

ciclo:
	;se copia el contador a eax
	mov eax, ecx
	call WriteDec ;metodo que imprime el valor decimal de eax
	call Crlf ;hace un salto de linea

	loop ciclo ;loop va decrementando ecx en uno y si el resultado no es 0 salta a la etiqueta ciclo

	;terminacion del programa
fin_ciclo:
	exit

main ENDP

END main