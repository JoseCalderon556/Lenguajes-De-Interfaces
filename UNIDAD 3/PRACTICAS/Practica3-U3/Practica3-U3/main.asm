;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

INCLUDE Irvine32.inc

.code
main PROC 
	 mov ebx, 10 ;debe seguir valiendo 10 despues de la llamada porque sumarPila guarda y restaura EBX

	 ;se guardan en la pila unos argumentos
	 push 1 
	 push 2

	 call sumarPila ;guarda la direccion de retorno encima de los argumentos

	 nop
	 exit

main ENDP


sumarPila PROC 
	;usamos EBP como punto de referencia para movernos en la pila
	push ebp 
	mov ebp, esp 

	push ebx
	mov eax, [ebp+8] ; accede al valor 2
	mov ebx, [ebp+12]; accede al valor 1

	imul eax, ebx ;imul permite especificar 2 registros para la multiplicacion
	
	;se restauran los registros usados
	pop ebx
	pop ebp
	ret 8 ;RET toma la direccion de retorno y suma 8 a ESP

sumarPila ENDP

END main
