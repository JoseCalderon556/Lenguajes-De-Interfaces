# Lenguajes de Interfaz — Unidad 3: Modularización

Prácticas en lenguaje ensamblador (MASM, x86 de 32 bits, biblioteca Irvine32) sobre procedimientos, manejo de la pila y macros.

---

## Práctica 1: Procedimiento básico con CALL y RET

**Objetivo:** definir un procedimiento (`mensajeAviso`) y llamarlo dos veces desde `main`. Una sola definición atiende varias llamadas.

**Qué hace:** muestra un mensaje de inicio, llama dos veces al procedimiento `mensajeAviso` y muestra un mensaje de fin.

**Qué se comprobó al ejecutarlo:** un procedimiento definido con `PROC` y `ENDP` puede llamarse varias veces desde `main`. En pantalla aparece primero el mensaje de inicio, luego dos veces el mensaje del procedimiento (una por cada `CALL`) y al final el mensaje de fin. Esto confirma que `CALL` transfiere el control al procedimiento y que `RET` regresa a la instrucción siguiente a la llamada. En el depurador se vio que EAX tomó el valor 10 y luego 20 justo después de cada regreso, lo que demuestra que la ejecución continuó donde debía.

---

## Práctica 2: Ver la dirección de retorno en la pila

**Objetivo:** observar que `[ESP]` contiene la dirección de retorno justo al entrar a cada procedimiento, y que cada llamada anidada guarda la suya (`main` → `procUno` → `procDos`).

**Qué hace:** en `main`, `procUno` y `procDos` lee `[esp]` y lo imprime en hexadecimal con `WriteHex`.

**Qué se comprobó al ejecutarlo:** al entrar a un procedimiento, la cima de la pila (`[esp]`) contiene la dirección de retorno guardada por `CALL`. El programa imprime en hexadecimal tres direcciones distintas: la de `main`, la de `procUno` y la de `procDos`. Esto confirma que cada llamada, aunque esté anidada, guarda su propia dirección de retorno, y que los regresos ocurren en orden inverso (primero `procDos`, luego `procUno`).

---

## Práctica 3: Argumentos por la pila, marco con EBP y RET 8

**Objetivo:** enviar dos argumentos con `PUSH`, localizarlos con EBP, conservar EBX y dejar la pila limpia con `RET 8`.

**Qué hace:** `main` coloca dos argumentos en la pila y llama a `sumarPila`, que los lee con `[ebp+8]` y `[ebp+12]`, los multiplica con `imul` y devuelve el resultado en EAX.

**Qué se comprobó al ejecutarlo:** el envío de dos argumentos mediante `PUSH` antes de `CALL` y su lectura dentro del procedimiento con `[ebp+8]` y `[ebp+12]`, usando EBP como referencia estable. Al terminar, EAX contiene el producto de los argumentos (2) y EBX conserva su valor original (10), lo que confirma que `push ebx` y `pop ebx` lo protegieron. También se comprobó que `ret 8` retira los dos argumentos de la pila, ya que ESP queda en el mismo valor que tenía antes de enviarlos.

---

## Práctica 4: Macros con parámetros

**Objetivo:** definir macros y ver que MASM las expande durante el ensamblado (no hay `CALL`/`RET` de la macro: el código se copia en cada lugar donde se usa).

**Qué hace:** define las macros `MostrarMensaje` (muestra una cadena y cambia de línea) y `Multi` (multiplica dos valores e imprime el resultado), y las usa desde `main`.

**Qué se comprobó al ejecutarlo:** una macro definida con `MACRO` y `ENDM` se expande durante el ensamblado cada vez que se usa. `MostrarMensaje` mostró el mensaje de bienvenida y el de despedida con el mismo código, y `Multi 4, 5` calculó e imprimió el resultado `+20`. Esto confirma que los argumentos sustituyen a los parámetros en cada uso y que no hay `CALL` ni `RET` de la macro.
