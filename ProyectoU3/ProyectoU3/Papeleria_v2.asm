;Lenguajes De Interfaces 08:00-09:00
;Alumno: Jose Amado Calderon Herrera
;Docente: Jose Luis Medina Jimenez

;  PROYECTO UNIDAD 3
;  Sistema de ventas e inventario de una PAPELERIA



;  ORGANIZACION
;     1. Constantes
;     2. Datos
;     3. Macros
;     4. Utilidades de texto y numeros (CopiarCadena, CadenaAEntero, CadenaAPrecio, ...)
;     5. Validaciones y captura validada (ValidarCodigo, LeerCodigoValido, ...)
;     6. Catalogo (BuscarProducto, MostrarProducto, HayProductos)
;     7. Funciones del menu (Registrar, Listar, Consultar, Recibir, Vender, Resumen)
;     8. Archivo (Guardar, Cargar)
;     9. Programa principal (main)
;
;  CAMBIOS PARA ESTA UNIDAD
;   * Cada PROC documenta: Recibe / Devuelve / Modifica (solo lo que entrega como resultado).
;   * USES lista UNICAMENTE los registros que el procedimiento cambia y debe conservar.
;     Los registros que entregan un resultado (EAX, ESI, EDI, EBX segun el caso) NO van en USES.
;   * Con USES, MASM inserta los POP antes de cada RET, asi que un procedimiento puede tener
;     varios RET y la pila queda equilibrada; POP no altera las banderas (CF/ZF de resultado).
;   * Los procedimientos que fallan por entrada invalida muestran su propio mensaje y devuelven CF=1.

INCLUDE Irvine32.inc

; ------------------------------------------------------------------------------
; 1. CONSTANTES

MAX_PRODUCTOS       = 10            ; capacidad del catalogo
MAX_EXISTENCIA      = 100           ; existencia maxima por producto
MAX_PRECIO          = 999999        ; $9999.99 MXN expresado en centavos
MAX_ENTRADA         = 80            ; caracteres maximos que se leen con ReadString
TAM_BUFFER_ARCHIVO  = 1024          ; tamano del buffer del archivo (incluye el 00h)

; Limites de campos
LONG_CODIGO         = 7             ; caracteres de "ABC-123"
MAX_NOMBRE          = 25            ; caracteres maximos del nombre
MAX_CAMPO_NUM       = 9             ; digitos maximos de un campo numerico del archivo

; Caracteres especiales del archivo
CAR_SEP             = ';'
CAR_CR              = 0Dh
CAR_LF              = 0Ah

; Regla del negocio
DESC_CANT_MINIMA    = 10            ; unidades minimas para aplicar el descuento
DESC_PORCENTAJE     = 10            ; porcentaje de descuento

; Disposicion de UN producto dentro de la memoria (registro de 44 bytes).
;   Direccion del producto = ESI.   Campo = [ESI + desplazamiento]
;   +0   codigo     8 bytes   (7 caracteres "ABC-123" + 00h)
;   +8   nombre    26 bytes   (hasta 25 caracteres + 00h)
;   +34  relleno    2 bytes   (para alinear los DWORD)
;   +36  precio     DWORD     (centavos)
;   +40  existencia DWORD     (unidades)
DESP_CODIGO         = 0
DESP_NOMBRE         = 8
DESP_PRECIO         = 36
DESP_EXISTENCIA     = 40
TAM_REGISTRO        = 44
TAM_TABLA           = MAX_PRODUCTOS * TAM_REGISTRO

; ------------------------------------------------------------------------------
; 2. DATOS

.data

; Catalogo en memoria 
catalogo            BYTE TAM_TABLA dup(0)   ; catalogo oficial
catalogoTemporal    BYTE TAM_TABLA dup(0)   ; catalogo temporal (para validar la carga)
cantProductos       DWORD 0                 ; productos registrados en catalogo
cantProductosTemp   DWORD 0                 ; productos leidos en catalogoTemporal

; Estado de la sesion
ingresosSesion      DWORD 0                 ; ingresos acumulados (centavos)
hayCambiosSinGuardar BYTE 0                 ; 1 = hay cambios sin guardar
espInicial          DWORD 0                 ; ESP inicial, para comprobar la pila

; Datos temporales de una captura 
codigoTemp          BYTE 8  dup(0)
nombreTemp          BYTE 26 dup(0)
precioTemp          DWORD 0
existenciaTemp      DWORD 0

; Datos temporales de una venta
cantVenta           DWORD 0                 ; unidades vendidas
baseVenta           DWORD 0                 ; precio x cantidad
descuentoVenta      DWORD 0                 ; descuento
totalVenta          DWORD 0                 ; base - descuento

; Buffers de texto
bufferEntrada       BYTE MAX_ENTRADA+1 dup(0)   ; lo que escribe el usuario (+1 para 00h)
bufferNumero        BYTE 12 dup(0)              ; numero convertido a texto
bufferCampo         BYTE 12 dup(0)              ; campo numerico leido del archivo

; Archivo
nombreArchivo       BYTE "inventario.txt",0
bufferArchivo       BYTE TAM_BUFFER_ARCHIVO dup(0)
manejadorArchivo    DWORD 0
longitudArchivo     DWORD 0                     ; bytes que se van a escribir
bytesLeidos         DWORD 0                     ; bytes que devolvio ReadFromFile

; Mensajes
msgTitulo       BYTE 0Dh,0Ah,"*** PAPELERIA - VENTAS E INVENTARIO ***",0Dh,0Ah,0
msgMenu         BYTE 0Dh,0Ah
                BYTE "----------- MENU -----------",0Dh,0Ah
                BYTE " 1. Registrar producto",0Dh,0Ah
                BYTE " 2. Mostrar inventario",0Dh,0Ah
                BYTE " 3. Buscar producto por codigo",0Dh,0Ah
                BYTE " 4. Recibir mercancia",0Dh,0Ah
                BYTE " 5. Vender",0Dh,0Ah
                BYTE " 6. Resumen",0Dh,0Ah
                BYTE " 7. Guardar catalogo en archivo",0Dh,0Ah
                BYTE " 8. Cargar catalogo desde archivo",0Dh,0Ah
                BYTE " 9. Ver regla del negocio (descuento)",0Dh,0Ah
                BYTE " 0. Salir",0Dh,0Ah,0
promptOpcion    BYTE "Opcion: ",0
msgOpcionMala   BYTE "Opcion no valida. Escriba un solo digito del menu.",0Dh,0Ah,0
msgPila         BYTE "AVISO: la pila quedo desequilibrada.",0Dh,0Ah,0

promptCodigo    BYTE "Codigo (3 letras MAYUSCULAS, guion, 3 digitos; ej. ABC-123): ",0
promptNombre    BYTE "Nombre (1 a 25 caracteres, sin ';'): ",0
promptPrecio    BYTE "Precio en MXN (ej. 185.50, maximo 2 decimales): ",0
promptExist     BYTE "Existencia inicial (0 a 100): ",0
promptCantEntra BYTE "Unidades que llegan (entero mayor que cero): ",0
promptCantVenta BYTE "Unidades a vender (entero mayor que cero): ",0

msgLleno        BYTE "RECHAZADO: el catalogo ya tiene 10 productos.",0Dh,0Ah,0
msgSinProd      BYTE "No hay productos registrados.",0Dh,0Ah,0
msgCodigoMalo   BYTE "RECHAZADO: codigo vacio o con formato incorrecto.",0Dh,0Ah,0
msgDuplicado    BYTE "RECHAZADO: ya existe un producto con ese codigo.",0Dh,0Ah,0
msgNoExiste     BYTE "No existe un producto con ese codigo.",0Dh,0Ah,0
msgNombreMalo   BYTE "RECHAZADO: nombre vacio, mayor a 25 caracteres o con caracteres no permitidos.",0Dh,0Ah,0
msgPrecioMalo   BYTE "RECHAZADO: precio invalido (use 0.01 a 9999.99, sin simbolos ni comas).",0Dh,0Ah,0
msgExistMala    BYTE "RECHAZADO: existencia invalida (entero de 0 a 100).",0Dh,0Ah,0
msgCantMala     BYTE "RECHAZADO: cantidad invalida (entero mayor que cero).",0Dh,0Ah,0
msgAltaOk       BYTE "Producto registrado correctamente.",0Dh,0Ah,0
msgExcede       BYTE "RECHAZADO: la existencia superaria 100 unidades.",0Dh,0Ah,0
msgEntradaOk    BYTE "Mercancia recibida. Nueva existencia: ",0
msgSinStock     BYTE "RECHAZADO: no hay existencias suficientes. Disponibles: ",0
msgDesborda     BYTE "RECHAZADO: el calculo provocaria un desbordamiento.",0Dh,0Ah,0

hdrLista        BYTE "CODIGO  | NOMBRE                    | PRECIO          | EXISTENCIA",0Dh,0Ah,0
sepCampo        BYTE " | ",0
sepExist        BYTE " | Existencia: ",0

msgVentaOk      BYTE 0Dh,0Ah,"VENTA ACEPTADA",0Dh,0Ah,0
lblBase         BYTE "  Importe base      : ",0
lblDesc         BYTE "  Descuento (10%)   : -",0
lblFinal        BYTE "  Importe final     : ",0
msgSinDesc      BYTE "  (No se aplico descuento: menos de 10 unidades)",0Dh,0Ah,0

lblProductos    BYTE "Productos registrados : ",0
lblUnidades     BYTE "Unidades disponibles  : ",0
lblValorInv     BYTE "Valor del inventario  : ",0
lblIngresos     BYTE "Ingresos de la sesion : ",0

msgRegla        BYTE 0Dh,0Ah
                BYTE "REGLA: DESCUENTO POR CANTIDAD",0Dh,0Ah
                BYTE " Se aplica cuando se venden 10 o mas unidades de un producto.",0Dh,0Ah
                BYTE " Descuento = 10% del importe base (precio x cantidad).",0Dh,0Ah
                BYTE " Las fracciones de centavo se descartan.",0Dh,0Ah
                BYTE " Con menos de 10 unidades se cobra el importe base completo.",0Dh,0Ah,0

msgGuardaOk     BYTE "Catalogo guardado en inventario.txt.",0Dh,0Ah,0
msgErrCrear     BYTE "ERROR: no se pudo crear el archivo.",0Dh,0Ah,0
msgErrEscribir  BYTE "ERROR: no se escribieron todos los bytes. El archivo puede estar incompleto.",0Dh,0Ah,0
msgNoArchivo    BYTE "ERROR: el archivo inventario.txt no existe o no se pudo abrir.",0Dh,0Ah,0
msgErrLeer      BYTE "ERROR: fallo la lectura del archivo.",0Dh,0Ah,0
msgArchInvalido BYTE "ERROR: archivo vacio, demasiado grande o con datos invalidos. Se conserva el catalogo actual.",0Dh,0Ah,0
msgCargaOk      BYTE "Catalogo cargado. Productos leidos: ",0
promptReemplazo BYTE "Hay cambios sin guardar que se perderan. Continuar? (S/N): ",0
promptSalir     BYTE "Hay cambios sin guardar. Salir de todas formas? (S/N): ",0
msgAdios        BYTE "Hasta luego.",0Dh,0Ah,0

strPeso         BYTE "$",0
strPunto        BYTE ".",0
strCero         BYTE "0",0
strMXN          BYTE " MXN",0

; ------------------------------------------------------------------------------
; 3. MACROS
;   Una macro se expande en cada punto de uso: sirve para secuencias cortas que se repiten y que cambian segun el argumento.

; MostrarMensaje msg : muestra una cadena terminada en 00h. Conserva EDX.
MostrarMensaje MACRO msg
    push edx
    mov  edx, OFFSET msg
    call WriteString
    pop  edx
ENDM

; Rechazar msg : muestra el mensaje de rechazo y deja CF=1 .
Rechazar MACRO msg
    MostrarMensaje msg
    stc
ENDM

; MostrarEtiquetaEntero etiqueta, valor : "etiqueta" + entero + salto de linea. Modifica EAX.
;   valor puede ser un registro, una variable o [ESI + desplazamiento].
MostrarEtiquetaEntero MACRO etiqueta, valor
    MostrarMensaje etiqueta
    mov  eax, valor
    call MostrarEntero
    call Crlf
ENDM

; MostrarEtiquetaImporte etiqueta, valor : "etiqueta" + "$p.cc MXN" + salto de linea. Modifica EAX.
MostrarEtiquetaImporte MACRO etiqueta, valor
    MostrarMensaje etiqueta
    mov  eax, valor
    call MostrarImporteMXN
    call Crlf
ENDM

; SaltarFueraDeRango valor, minimo, maximo, etiquetaFuera : salta si valor < minimo o valor > maximo
; Modifica solo las banderas.
SaltarFueraDeRango MACRO valor, minimo, maximo, etiquetaFuera
    cmp  valor, minimo
    jb   etiquetaFuera
    cmp  valor, maximo
    ja   etiquetaFuera
ENDM

; SaltarSiNoDigito valor, etiquetaFuera : salta si el caracter no esta entre '0' y '9'.
SaltarSiNoDigito MACRO valor, etiquetaFuera
    SaltarFueraDeRango valor, '0', '9', etiquetaFuera
ENDM

; TomarDigito etiquetaNoDigito : EBX = valor numerico del caracter en [ESI]; salta si no es digito.
;   Modifica EBX y las banderas.
TomarDigito MACRO etiquetaNoDigito
    movzx ebx, BYTE PTR [esi]
    SaltarSiNoDigito bl, etiquetaNoDigito
    sub  ebx, '0'
ENDM

; IniciarRecorrido : prepara el recorrido del catalogo. ESI = primer producto, ECX = cuantos hay.
IniciarRecorrido MACRO
    mov  esi, OFFSET catalogo
    mov  ecx, cantProductos
ENDM

; AgregarTexto origen : agrega la cadena "origen" al texto que se arma en [EDI]; EDI queda en su 00h.
;   Modifica EDX y EDI.
AgregarTexto MACRO origen
    lea  edx, origen
    call CopiarCadena
ENDM

; CopiarTexto origen, destino : copia una cadena completa de "origen" a "destino". Modifica EDX y EDI.
CopiarTexto MACRO origen, destino
    lea  edi, destino
    AgregarTexto origen
ENDM

; AgregarByte valor : escribe un byte en [EDI] y avanza EDI.
AgregarByte MACRO valor
    mov  BYTE PTR [edi], valor
    inc  edi
ENDM

; CapturarCon mensaje, rutina : muestra mensaje, lee una linea y llama a rutina con ESI = texto.
;   Modifica EAX, EDX y ESI, ademas de lo que modifique rutina (LeerConMensaje conserva ECX).
CapturarCon MACRO mensaje, rutina
    mov  edx, OFFSET mensaje
    call LeerConMensaje
    mov  esi, OFFSET bufferEntrada
    call rutina
ENDM

; LlamarConCadena rutina, cadena : llama a rutina con ESI = cadena, pero conserva el ESI original
;   (la posicion de lectura del archivo). POP no altera CF, asi que el resultado de rutina sigue
;   disponible. Se usa PUSH/POP y no USES porque aqui ESI se redefine como parametro de la llamada.
LlamarConCadena MACRO rutina, cadena
    push esi
    lea  esi, cadena
    call rutina
    pop  esi
ENDM

; CerrarManejador : cierra el archivo cuyo handle esta en manejadorArchivo. Modifica EAX.
CerrarManejador MACRO
    mov  eax, manejadorArchivo
    call CloseFile
ENDM

; CargarCampo rutina, destino, maximo, etiquetaMal : copia un campo del texto (ESI) a destino,
;   con maximo caracteres como tope, usando rutina. Salta a etiquetaMal si el campo es muy largo
;   o (segun la rutina) si falta el ';'. Modifica EDI y ECX.
CargarCampo MACRO rutina, destino, maximo, etiquetaMal
    lea  edi, destino
    mov  ecx, maximo
    call rutina
    jc   etiquetaMal
ENDM

; Opcion caracter, rutina : opcion del menu. Si AL == caracter llama a rutina y vuelve al menu.
;   Lleva una etiqueta interna y se usa 8 veces: por eso se declara con LOCAL (cada expansion
;   recibe un nombre distinto; sin LOCAL MASM reportaria la etiqueta duplicada).
Opcion MACRO caracter, rutina
    LOCAL siguiente
    cmp  al, caracter
    jne  siguiente
    call rutina
    jmp  menuLoop
siguiente:
ENDM

.code

; ==============================================================================
; 4. UTILIDADES DE TEXTO Y NUMEROS

; LeerConMensaje
;   Muestra un mensaje y captura una linea con ReadString.
;   Recibe   : EDX = direccion del mensaje
;   Devuelve : EAX = numero de caracteres capturados
;              El texto queda en bufferEntrada, terminado en 00h por ReadString.
;   Modifica : EAX (resultado). Conserva ECX y EDX (USES).

LeerConMensaje PROC USES ecx edx
    call WriteString ; muestra el mensaje
    mov  edx, OFFSET bufferEntrada ; EDX = donde guardar lo escrito
    mov  ecx, MAX_ENTRADA ; ECX = maximo de caracteres a leer
    call ReadString ; EAX = cuantos caracteres se leyeron
    ret
LeerConMensaje ENDP


; CopiarCadena
;   Copia una cadena (incluye el 00h final).
;   Recibe   : EDX = origen,  EDI = destino
;   Devuelve : EDI apunta al 00h del destino (sirve para seguir agregando texto)
;   Modifica : EDI (resultado). Conserva EAX y EDX (USES).

CopiarCadena PROC USES eax edx
cc_sigue:
    mov  al, [edx] ; lee un caracter del origen
    mov  [edi], al ; lo escribe en el destino
    cmp  al, 0 ; era el final?
    je   cc_fin
    inc  edx ; siguiente caracter
    inc  edi
    jmp  cc_sigue
cc_fin:
    ret
CopiarCadena ENDP


; CadenaAEntero
;   Convierte una cadena de digitos a entero sin signo.
;   Idea: valor = valor * 10 + digito, por cada caracter.
;   Recibe   : ESI = cadena terminada en 00h
;   Devuelve : CF=0 -> EAX = valor.   CF=1 -> cadena vacia, caracter que no es digito, o desbordamiento de 32 bits.
;   Modifica : EAX (resultado) y banderas. Conserva EBX, ECX, EDX y ESI (USES).

CadenaAEntero PROC USES ebx ecx edx esi
    xor  eax, eax ; valor = 0
    xor  ecx, ecx ; ECX cuenta cuantos digitos hay
ce_sigue:
    cmp  BYTE PTR [esi], 0 ; comprueba si es fin de la cadena
    je   ce_fin
    TomarDigito ce_mal ; EBX = digito (o salta si no es digito)
    mov  edx, 10
    mul  edx ; EDX:EAX = EAX * 10
    jc   ce_mal ; CF=1 si no cupo en 32 bits
    add  eax, ebx ; + digito
    jc   ce_mal
    inc  ecx
    inc  esi
    jmp  ce_sigue
ce_fin:
    cmp  ecx, 0 ; cadena vacia?
    je   ce_mal
    clc
    ret
ce_mal:
    stc
    ret
CadenaAEntero ENDP


; CadenaAPrecio
;   Convierte un precio en pesos ("185.50", "12.05", "40", "7.5") a CENTAVOS.
;   Recibe   : ESI = cadena terminada en 00h
;   Devuelve : CF=0 -> EAX = centavos.   CF=1 -> precio invalido
;   Modifica : EAX (resultado) y banderas. Conserva EBX, ECX, EDI y ESI (USES).

CadenaAPrecio PROC USES ebx ecx edi esi
    xor  eax, eax ; EAX = pesos enteros
    xor  ecx, ecx ; ECX = cuantos digitos tiene la parte entera

; parte entera
cp_entero:
    TomarDigito cp_finEntero ; EBX = digito; si no es digito termina la parte entera
    imul eax, eax, 10 ; pesos = pesos * 10
    add  eax, ebx ; + digito
    cmp  eax, 9999 ; mas de $9999 no es valido
    ja   cp_mal
    inc  ecx
    inc  esi
    jmp  cp_entero
cp_finEntero:
    cmp  ecx, 0 ; debe haber al menos un digito antes del punto
    je   cp_mal
    imul eax, eax, 100 ; pesos -> centavos
    mov  edi, eax ; EDI acumula los centavos totales
    cmp  BYTE PTR [esi], 0
    je   cp_rango ; solo pesos enteros: ya terminamos
    cmp  BYTE PTR [esi], '.'
    jne  cp_mal ; cualquier otro caracter se rechaza
    inc  esi ; salta el punto
; primer decimal
    TomarDigito cp_mal ; despues del punto debe haber al menos 1 digito
    imul ebx, ebx, 10 ; ej. "5" -> 50 centavos
    add  edi, ebx
    inc  esi
; segundo decimal
    cmp  BYTE PTR [esi], 0
    je   cp_rango ; solo un decimal
    TomarDigito cp_mal
    add  edi, ebx ; ej. "05" -> 0*10 + 5 = 5 centavos
    inc  esi
    cmp  BYTE PTR [esi], 0 ; si todavia hay algo, es un tercer decimal
    jne  cp_mal
; rango 
cp_rango:
    SaltarFueraDeRango edi, 1, MAX_PRECIO, cp_mal ; $0.01 a $9999.99
    mov  eax, edi
    clc
    ret
cp_mal:
    stc
    ret
CadenaAPrecio ENDP


; CadenaACentavos
;   Convierte el campo "precio" del ARCHIVO (ya en centavos, sin punto) y valida 1..MAX_PRECIO.
;   Recibe   : ESI = cadena terminada en 00h
;   Devuelve : CF=0 -> EAX = centavos.   CF=1 -> invalido
;   Modifica : EAX (resultado). No usa mas registros (CadenaAEntero ya conserva los suyos).

CadenaACentavos PROC
    call CadenaAEntero
    jc   cen_fin
    SaltarFueraDeRango eax, 1, MAX_PRECIO, cen_mal
    clc
    ret
cen_mal:
    stc
cen_fin:
    ret
CadenaACentavos ENDP


; CadenaAExistencia
;   Convierte una cadena a existencia y valida 0..MAX_EXISTENCIA. La usan la captura por
;   teclado (LeerExistenciaValida) y la carga del archivo (ProcesarArchivo).
;   Recibe   : ESI = cadena terminada en 00h
;   Devuelve : CF=0 -> EAX = existencia.   CF=1 -> invalida
;   Modifica : EAX (resultado).

CadenaAExistencia PROC
    call CadenaAEntero
    jc   cex_fin
    cmp  eax, MAX_EXISTENCIA
    ja   cex_mal
    clc
    ret
cex_mal:
    stc
cex_fin:
    ret
CadenaAExistencia ENDP


; EnteroACadena
;   Convierte un entero sin signo a cadena decimal.
;   Recibe   : EAX = numero,  EDI = destino
;   Devuelve : cadena con 00h en el destino; EDI apunta a ese 00h
;   Modifica : EDI (resultado). Conserva EAX, EBX, ECX y EDX (USES).

EnteroACadena PROC USES eax ebx ecx edx
    mov  ebx, 10  ; divisor
    xor  ecx, ecx  ; ECX = cuantos digitos se apilaron
ec_divide:
    xor  edx, edx ; prepara el dividendo EDX:EAX (EDX = 0)
    div  ebx  ; EAX = cociente,  EDX = residuo (0..9)
    add  dl, '0' ; residuo -> caracter ASCII
    push edx  ; guarda el digito
    inc  ecx
    cmp  eax, 0 ; quedan mas digitos?
    jne  ec_divide
ec_escribe:
    pop  edx  ; saca el digito (el ultimo en entrar sale primero)
    mov  [edi], dl
    inc  edi
    loop ec_escribe ; ECX = ECX - 1; repite mientras no sea 0
    mov  BYTE PTR [edi], 0 ; fin de cadena
    ret
EnteroACadena ENDP


; MostrarEntero
;   Muestra un entero sin signo en pantalla.
;   Recibe   : EAX = numero
;   Modifica : nada. Conserva EDX y EDI (USES); EAX lo conserva EnteroACadena.

MostrarEntero PROC USES edx edi
    mov  edi, OFFSET bufferNumero
    call EnteroACadena ; bufferNumero = texto del numero
    mov  edx, OFFSET bufferNumero
    call WriteString
    ret
MostrarEntero ENDP

; MostrarImporteMXN
;   Muestra un importe en centavos como "$pesos.cc MXN".
;   Recibe   : EAX = importe en centavos
;   Modifica : nada. Conserva EAX, EBX y EDX (USES). EDI lo conserva MostrarEntero.

MostrarImporteMXN PROC USES eax ebx edx
    MostrarMensaje strPeso
    mov  ebx, 100
    xor  edx, edx ; dividendo = EDX:EAX con EDX = 0
    div  ebx  ; EAX = pesos,  EDX = centavos
    push edx  ; guarda los centavos
    call MostrarEntero ; muestra los pesos (EAX)
    MostrarMensaje strPunto
    pop  eax  ; EAX = centavos
    cmp  eax, 10
    jae  mxn_dosDigitos
    MostrarMensaje strCero ; centavos de un solo digito: agrega el cero
mxn_dosDigitos:
    call MostrarEntero ; muestra los centavos
    MostrarMensaje strMXN
    ret
MostrarImporteMXN ENDP


; LeerCantidad
;   Pide una cantidad entera mayor que cero. Si es invalida, muestra msgCantMala.
;   (Antes los dos llamadores, Recibir y Vender, mostraban ese mensaje por separado.)
;   Recibe   : EDX = mensaje a mostrar
;   Devuelve : CF=0 -> EAX = cantidad.   CF=1 -> entrada invalida (mensaje ya mostrado)
;   Modifica : EAX (resultado) y banderas. Conserva ESI (USES); ECX y EDX los conserva LeerConMensaje.

LeerCantidad PROC USES esi
    call LeerConMensaje ; texto en bufferEntrada
    mov  esi, OFFSET bufferEntrada
    call CadenaAEntero
    jc   lc_mal
    cmp  eax, 0 ; cero no es cantidad valida
    je   lc_mal
    clc
    ret
lc_mal:
    Rechazar msgCantMala
    ret
LeerCantidad ENDP


; PreguntarSiNo
;   Pregunta Si/No. Solo una letra basta.
;   Recibe   : EDX = mensaje
;   Devuelve : CF=0 -> respondio Si.   CF=1 -> No
;   Modifica : solo CF. Conserva EAX (USES) y, via LeerConMensaje, ECX y EDX.

PreguntarSiNo PROC USES eax
    call LeerConMensaje
    cmp  eax, 1  ; debe ser exactamente un caracter
    jne  sn_no
    mov  al, bufferEntrada
    cmp  al, 'S'
    je   sn_si
    cmp  al, 's'
    je   sn_si
sn_no:
    stc
    ret
sn_si:
    clc
    ret
PreguntarSiNo ENDP

; ==============================================================================
; 5. VALIDACIONES Y CAPTURA VALIDADA

; ValidarCodigo
;   Comprueba el formato ABC-123: 3 letras mayusculas, guion y 3 digitos.
;   Recibe   : ESI = cadena terminada en 00h
;   Devuelve : CF=0 -> valido.   CF=1 -> invalido
;   Modifica : solo CF. Conserva EAX, ECX y ESI (USES).

ValidarCodigo PROC USES eax ecx esi
    mov  ecx, 3 ; 3 letras
vc_letras:
    mov  al, [esi]
    SaltarFueraDeRango al, 'A', 'Z', vc_mal
    inc  esi
    loop vc_letras
    cmp  BYTE PTR [esi], '-' ; el guion
    jne  vc_mal
    inc  esi
    mov  ecx, 3 ; 3 digitos
vc_digitos:
    mov  al, [esi]
    SaltarSiNoDigito al, vc_mal
    inc  esi
    loop vc_digitos
    cmp  BYTE PTR [esi], 0  ; no debe sobrar nada
    jne  vc_mal
    clc
    ret
vc_mal:
    stc
    ret
ValidarCodigo ENDP

; ValidarNombre
;   Nombre de 1 a 25 caracteres imprimibles.
;   Recibe   : ESI = cadena terminada en 00h
;   Devuelve : CF=0 -> valido.   CF=1 -> invalido
;   Modifica : solo CF. Conserva EAX, ECX y ESI (USES).

ValidarNombre PROC USES eax ecx esi
    xor  ecx, ecx ; ECX = longitud
vn_sigue:
    mov  al, [esi]
    cmp  al, 0 ; fin de cadena
    je   vn_longitud
    SaltarFueraDeRango al, 32, 126, vn_mal ; controles y fuera de ASCII imprimible
    cmp  al, CAR_SEP ; separador reservado
    je   vn_mal
    inc  ecx
    inc  esi
    jmp  vn_sigue
vn_longitud:
    SaltarFueraDeRango ecx, 1, MAX_NOMBRE, vn_mal ; vacio o demasiado largo
    clc
    ret
vn_mal:
    stc
    ret
ValidarNombre ENDP


; LeerCodigoValido
;   Pide un codigo y comprueba su formato. Si es incorrecto muestra msgCodigoMalo.
;   Recibe   : nada
;   Devuelve : CF=0 -> codigo valido en bufferEntrada.   CF=1 -> invalido (mensaje ya mostrado)
;   Modifica : solo banderas y bufferEntrada. Conserva EAX, EDX y ESI (USES).

LeerCodigoValido PROC USES eax edx esi
    CapturarCon promptCodigo, ValidarCodigo
    jnc  lcv_fin
    Rechazar msgCodigoMalo
lcv_fin:
    ret
LeerCodigoValido ENDP


; LeerCodigoExistente
;   Pide un codigo y lo busca en el catalogo. Es la captura comun de Consultar, Recibir y Vender
;   (las tres repetian: pedir, validar, buscar y mostrar el error correspondiente).
;   Recibe   : nada
;   Devuelve : CF=0 -> ESI = direccion del producto.
;              CF=1 -> formato incorrecto (msgCodigoMalo) o no existe (msgNoExiste); ya mostrado.
;   Modifica : ESI (resultado) y banderas. Conserva EDI (USES); EAX, ECX y EDX los conservan
;              los procedimientos que llama.

LeerCodigoExistente PROC USES edi
    call LeerCodigoValido
    jc   lce_fin
    mov  edi, OFFSET bufferEntrada
    call BuscarProducto ; ESI = producto si CF=0
    jnc  lce_fin
    Rechazar msgNoExiste
lce_fin:
    ret
LeerCodigoExistente ENDP


; LeerNombreValido
;   Pide el nombre y lo valida. Si es incorrecto muestra msgNombreMalo.
;   Devuelve : CF=0 -> nombre valido en bufferEntrada.   CF=1 -> invalido (mensaje ya mostrado)
;   Modifica : solo banderas y bufferEntrada. Conserva EAX, EDX y ESI (USES).

LeerNombreValido PROC USES eax edx esi
    CapturarCon promptNombre, ValidarNombre
    jnc  lnv_fin
    Rechazar msgNombreMalo
lnv_fin:
    ret
LeerNombreValido ENDP


; LeerPrecioValido
;   Pide el precio en pesos y lo convierte a centavos. Si es incorrecto muestra msgPrecioMalo.
;   Devuelve : CF=0 -> EAX = centavos.   CF=1 -> invalido (mensaje ya mostrado)
;   Modifica : EAX (resultado) y banderas. Conserva EDX y ESI (USES).

LeerPrecioValido PROC USES edx esi
    CapturarCon promptPrecio, CadenaAPrecio
    jnc  lpv_fin
    Rechazar msgPrecioMalo
lpv_fin:
    ret
LeerPrecioValido ENDP


; LeerExistenciaValida
;   Pide la existencia inicial (0 a 100). Si es incorrecta muestra msgExistMala.
;   Devuelve : CF=0 -> EAX = existencia.   CF=1 -> invalida (mensaje ya mostrado)
;   Modifica : EAX (resultado) y banderas. Conserva EDX y ESI (USES).

LeerExistenciaValida PROC USES edx esi
    CapturarCon promptExist, CadenaAExistencia
    jnc  lev_fin
    Rechazar msgExistMala
lev_fin:
    ret
LeerExistenciaValida ENDP

; ==============================================================================
; 6. CATALOGO

; CodigosIguales
;   Compara 8 bytes (7 caracteres del codigo + 00h).
;   Recibe   : ESI = codigo del producto,  EDI = codigo a comparar
;   Devuelve : ZF=1 si son iguales
;   Modifica : solo banderas. Conserva ESI, EDI y ECX (USES); POP no cambia ZF.

CodigosIguales PROC USES esi edi ecx
    cld  ; CMPSB avanza hacia adelante
    mov  ecx, 8
    repe cmpsb  ; repite mientras los bytes sean iguales
    ret
CodigosIguales ENDP

; BuscarProducto
;   Busca un codigo recorriendo el catalogo con ESI (de 44 en 44 bytes).
;   Recibe   : EDI = codigo buscado (cadena con 00h)
;   Devuelve : CF=0 -> encontrado, ESI = direccion del producto. CF=1 -> no existe.
;   Modifica : ESI (resultado) y banderas. Conserva ECX (USES).

BuscarProducto PROC USES ecx
    IniciarRecorrido ; ESI = primer producto, ECX = cuantos revisar
    cmp  ecx, 0
    je   bp_noHay
bp_busca:
    call CodigosIguales
    je   bp_hallado ; ZF=1 -> mismo codigo
    add  esi, TAM_REGISTRO ; ESI = siguiente producto
    loop bp_busca
bp_noHay:
    stc
    ret
bp_hallado:
    clc
    ret
BuscarProducto ENDP


; HayProductos
;   Comprueba que el catalogo no este vacio. Listar, Recibir, Vender y Guardar empezaban con las
;   mismas 4 lineas (comparar, saltar, mensaje, saltar al final).
;   Recibe   : nada
;   Devuelve : CF=0 -> hay al menos un producto.   CF=1 -> vacio (msgSinProd ya mostrado)
;   Modifica : solo banderas.

HayProductos PROC
    cmp  cantProductos, 0
    jne  hp_si
    Rechazar msgSinProd
    ret
hp_si:
    clc
    ret
HayProductos ENDP


; MostrarProducto
;   Muestra una linea con los datos de un producto.
;   Recibe   : ESI = direccion del producto
;   Modifica : nada. Conserva EAX y EDX (USES).

MostrarProducto PROC USES eax edx
    lea  edx, [esi + DESP_CODIGO] ; direccion del codigo dentro del registro
    call WriteString
    MostrarMensaje sepCampo
    lea  edx, [esi + DESP_NOMBRE] ; direccion del nombre
    call WriteString
    MostrarMensaje sepCampo
    mov  eax, [esi + DESP_PRECIO] ; precio en centavos
    call MostrarImporteMXN
    MostrarMensaje sepExist
    mov  eax, [esi + DESP_EXISTENCIA] ; existencia
    call MostrarEntero
    call Crlf
    ret
MostrarProducto ENDP

; ==============================================================================
; 7. FUNCIONES DEL MENU

; AgregarProductoTemporal
;   Copia codigoTemp, nombreTemp, precioTemp y existenciaTemp (ya validados) al siguiente lugar
;   libre del catalogo.
;   Recibe   : las variables temporales
;   Modifica : cantProductos (+1) y hayCambiosSinGuardar (=1). Registros: ninguno
;              (conserva EAX, EBX, EDX y EDI con USES).

AgregarProductoTemporal PROC USES eax ebx edx edi
    imul ebx, cantProductos, TAM_REGISTRO ; EBX = desplazamiento del nuevo producto
    add  ebx, OFFSET catalogo  ; EBX = direccion del nuevo producto
    CopiarTexto codigoTemp, [ebx + DESP_CODIGO]
    CopiarTexto nombreTemp, [ebx + DESP_NOMBRE]
    mov  eax, precioTemp
    mov  [ebx + DESP_PRECIO], eax
    mov  eax, existenciaTemp
    mov  [ebx + DESP_EXISTENCIA], eax
    inc  cantProductos
    mov  hayCambiosSinGuardar, 1
    ret
AgregarProductoTemporal ENDP


; RegistrarProducto
;   Captura y valida codigo, nombre, precio y existencia. Todo se guarda primero
;   en variables temporales; el producto solo se agrega al catalogo si todas las
;   validaciones pasan, asi un rechazo no deja datos a medias.
;   Modifica : nada (conserva EAX, EDX, ESI y EDI con USES).

RegistrarProducto PROC USES eax edx esi edi
    cmp  cantProductos, MAX_PRODUCTOS
    jb   rp_hayEspacio
    MostrarMensaje msgLleno
    ret
rp_hayEspacio:
; codigo
    call LeerCodigoValido
    jc   rp_fin
    mov  edi, OFFSET bufferEntrada
    call BuscarProducto ; CF=0 significa que YA existe
    jnc  rp_duplicado
    CopiarTexto bufferEntrada, codigoTemp
; nombre 
    call LeerNombreValido
    jc   rp_fin
    CopiarTexto bufferEntrada, nombreTemp
; precio
    call LeerPrecioValido ; EAX = centavos
    jc   rp_fin
    mov  precioTemp, eax
; existencia 
    call LeerExistenciaValida
    jc   rp_fin
    mov  existenciaTemp, eax
; todo valido: agregar al catalogo
    call AgregarProductoTemporal
    MostrarMensaje msgAltaOk
    ret
rp_duplicado:
    MostrarMensaje msgDuplicado
rp_fin:
    ret
RegistrarProducto ENDP


; ListarInventario
;   Recorre el catalogo con ESI y muestra cada producto.
;   Modifica : nada (conserva ECX y ESI con USES).

ListarInventario PROC USES ecx esi
    call HayProductos
    jc   li_fin
    MostrarMensaje hdrLista
    IniciarRecorrido ; ESI = primer producto, ECX = contador del ciclo
li_ciclo:
    call MostrarProducto
    add  esi, TAM_REGISTRO  ; siguiente producto
    loop li_ciclo
li_fin:
    ret
ListarInventario ENDP


; ConsultarProducto
;   Pide un codigo y muestra el producto si existe.
;   Modifica : nada (conserva ESI con USES).

ConsultarProducto PROC USES esi
    call LeerCodigoExistente ; ESI = producto; ya mostro el error si CF=1
    jc   cons_fin
    call MostrarProducto
cons_fin:
    ret
ConsultarProducto ENDP

; RecibirMercancia
;   Suma unidades a un producto existente sin pasar de 100. La suma se calcula en EBX y solo se guarda si es valida.
;   Modifica : nada (conserva EAX, EBX, EDX y ESI con USES).

RecibirMercancia PROC USES eax ebx edx esi
    call HayProductos
    jc   rm_fin
    call LeerCodigoExistente ; ESI = producto
    jc   rm_fin
    mov  edx, OFFSET promptCantEntra
    call LeerCantidad ; EAX = cantidad (ESI se conserva)
    jc   rm_fin
    mov  ebx, [esi + DESP_EXISTENCIA] ; existencia actual
    add  ebx, eax ; + unidades que llegan
    jc   rm_excede  ; CF=1 -> desbordamiento
    cmp  ebx, MAX_EXISTENCIA
    ja   rm_excede  ; mas de 100 -> se rechaza
    mov  [esi + DESP_EXISTENCIA], ebx ; se actualiza solo si todo salio bien
    mov  hayCambiosSinGuardar, 1
    MostrarEtiquetaEntero msgEntradaOk, ebx
    ret
rm_excede:
    MostrarMensaje msgExcede
rm_fin:
    ret
RecibirMercancia ENDP

; AplicarDescuento
;   Descuento por cantidad: si cantVenta >= DESC_CANT_MINIMA, descuento = 10% de baseVenta.
;   Descuento = (baseVenta * 10) / 100.  DIV descarta el residuo, o sea que se descartan las fracciones de centavo.
;   Recibe   : cantVenta y baseVenta (variables)
;   Devuelve : descuentoVenta y totalVenta (variables)
;   Modifica : solo esas dos variables. Conserva EAX, EBX y EDX (USES; el resultado va a memoria).

AplicarDescuento PROC USES eax ebx edx
    mov  descuentoVenta, 0  ; por omision no hay descuento
    mov  eax, baseVenta
    mov  totalVenta, eax  ; importe final = base
    cmp  cantVenta, DESC_CANT_MINIMA
    jb   ad_fin  ; menos de 10 unidades: no aplica
    mov  ebx, DESC_PORCENTAJE
    mul  ebx    ; EDX:EAX = base * 10 
    mov  ebx, 100
    div  ebx   ; EAX = base*10/100 (EDX = residuo, se descarta)
    mov  descuentoVenta, eax
    mov  eax, baseVenta
    sub  eax, descuentoVenta ; final = base - descuento
    mov  totalVenta, eax
ad_fin:
    ret
AplicarDescuento ENDP


; MostrarComprobante
;   Imprime el comprobante de una venta aceptada (base, descuento si aplico, y total).
;   Recibe   : baseVenta, descuentoVenta y totalVenta (variables)
;   Modifica : nada. Conserva EAX (USES).

MostrarComprobante PROC USES eax
    MostrarMensaje msgVentaOk
    MostrarEtiquetaImporte lblBase, baseVenta
    cmp  descuentoVenta, 0
    je   mc_sinDescuento
    MostrarEtiquetaImporte lblDesc, descuentoVenta
    jmp  mc_total
mc_sinDescuento:
    MostrarMensaje msgSinDesc
mc_total:
    MostrarEtiquetaImporte lblFinal, totalVenta
    ret
MostrarComprobante ENDP


; VenderProducto
;   Una venta = un producto. Orden de operaciones:
;     1) validar codigo y cantidad   2) comprobar existencias
;     3) calcular base  4) aplicar la regla
;     5) comprobar que los ingresos no se desbordan
;     6) solo ahora actualizar existencia e ingresos.
;   Si algo falla antes del paso 6 no se modifica nada.
;   Modifica : nada en registros (conserva EAX, EDX y ESI con USES; MUL cambia EDX).

VenderProducto PROC USES eax edx esi
    call HayProductos
    jc   vp_fin
    call LeerCodigoExistente ; ESI = producto
    jc   vp_fin
    mov  edx, OFFSET promptCantVenta
    call LeerCantidad  ; EAX = cantidad
    jc   vp_fin
    mov  cantVenta, eax
    cmp  eax, [esi + DESP_EXISTENCIA] ; cantidad > existencia ?
    ja   vp_sinStock
    mov  eax, [esi + DESP_PRECIO] ; importe base = precio * cantidad
    mul  cantVenta    ; EDX:EAX
    jc   vp_desborda    ; CF=1 -> no cupo en 32 bits
    mov  baseVenta, eax
    call AplicarDescuento  ; calcula descuentoVenta y totalVenta
    mov  eax, ingresosSesion
    add  eax, totalVenta  ; ingresos + importe final
    jc   vp_desborda
; paso 6: modificar datos 
    mov  ingresosSesion, eax
    mov  eax, cantVenta
    sub  [esi + DESP_EXISTENCIA], eax ; descuenta las unidades vendidas
    mov  hayCambiosSinGuardar, 1
    call MostrarComprobante
    ret
vp_sinStock:
    MostrarEtiquetaEntero msgSinStock, [esi + DESP_EXISTENCIA]
    ret
vp_desborda:
    MostrarMensaje msgDesborda
vp_fin:
    ret
VenderProducto ENDP


; CalcularTotalesInventario
;   Recorre el catalogo con ESI acumulando unidades y valor del inventario.
;   Recibe   : nada
;   Devuelve : CF=0 -> EBX = unidades disponibles,  EDI = valor del inventario (centavos).
;              CF=1 -> desbordamiento de 32 bits al calcular el valor.
;   Modifica : EBX y EDI (resultados). Conserva EAX, ECX, EDX y ESI (USES).

CalcularTotalesInventario PROC USES eax ecx edx esi
    xor  ebx, ebx ; unidades = 0
    xor  edi, edi ; valor = 0
    IniciarRecorrido
    cmp  ecx, 0
    je   ct_ok
ct_ciclo:
    add  ebx, [esi + DESP_EXISTENCIA] ; unidades += existencia
    mov  eax, [esi + DESP_PRECIO]
    mul  DWORD PTR [esi + DESP_EXISTENCIA] ; EDX:EAX = precio * existencia
    jc   ct_mal
    add  edi, eax   ; valor += precio * existencia
    jc   ct_mal
    add  esi, TAM_REGISTRO
    loop ct_ciclo
ct_ok:
    clc
    ret
ct_mal:
    stc
    ret
CalcularTotalesInventario ENDP


; MostrarResumen  
;   Muestra productos, unidades, valor del inventario e ingresos de la sesion.
;   Modifica : nada (conserva EAX, EBX y EDI con USES).

MostrarResumen PROC USES eax ebx edi
    call CalcularTotalesInventario ; EBX = unidades,  EDI = valor
    jc   mr_desborda
    call Crlf
    MostrarEtiquetaEntero lblProductos, cantProductos
    MostrarEtiquetaEntero lblUnidades, ebx
    MostrarEtiquetaImporte lblValorInv, edi
    MostrarEtiquetaImporte lblIngresos, ingresosSesion
    ret
mr_desborda:
    MostrarMensaje msgDesborda
    ret
MostrarResumen ENDP

; ==============================================================================
; 8. ARCHIVO

; ArmarTextoArchivo
;   Arma en bufferArchivo una linea de texto por producto:
;          CODIGO;NOMBRE;CENTAVOS;EXISTENCIA<CR><LF>
;   (EDI va avanzando por el buffer; ESI recorre el catalogo)
;   Recibe   : el catalogo (cantProductos >= 1)
;   Devuelve : longitudArchivo = bytes armados (variable)
;   Modifica : solo bufferArchivo y longitudArchivo. Conserva EAX, ECX, EDX, ESI y EDI (USES).

ArmarTextoArchivo PROC USES eax ecx edx esi edi
    mov  edi, OFFSET bufferArchivo ; EDI = donde se escribe el texto
    IniciarRecorrido    ; ESI = producto actual, ECX = cuantos quedan
ta_ciclo:
    AgregarTexto [esi + DESP_CODIGO]
    AgregarByte CAR_SEP
    AgregarTexto [esi + DESP_NOMBRE]
    AgregarByte CAR_SEP
    mov  eax, [esi + DESP_PRECIO]
    call EnteroACadena ; precio en centavos (EDI avanza)
    AgregarByte CAR_SEP
    mov  eax, [esi + DESP_EXISTENCIA]
    call EnteroACadena    ; existencia
    AgregarByte CAR_CR
    AgregarByte CAR_LF
    add  esi, TAM_REGISTRO
    dec  ecx    ; se usa DEC+JNZ porque el cuerpo es largo
    jnz  ta_ciclo
    sub  edi, OFFSET bufferArchivo ; EDI = bytes armados
    mov  longitudArchivo, edi
    ret
ArmarTextoArchivo ENDP


; GuardarCatalogo
;   1) ArmarTextoArchivo escribe el texto en bufferArchivo.
;   2) CreateOutputFile -> EAX = handle (INVALID_HANDLE_VALUE si fallo)
;   3) WriteToFile: EAX = handle, EDX = buffer, ECX = bytes a escribir;
;      al regresar EAX = bytes escritos, que se compara con longitudArchivo.
;   4) CloseFile.
;   Modifica : nada (conserva EAX, ECX y EDX con USES).

GuardarCatalogo PROC USES eax ecx edx
    call HayProductos
    jc   gc_fin
    call ArmarTextoArchivo
    mov  edx, OFFSET nombreArchivo
    call CreateOutputFile    ; EAX = handle
    cmp  eax, INVALID_HANDLE_VALUE
    je   gc_errCrear
    mov  manejadorArchivo, eax  ; EAX ya trae el handle que pide WriteToFile
    mov  edx, OFFSET bufferArchivo
    mov  ecx, longitudArchivo
    call WriteToFile    ; EAX = bytes escritos
    jc   gc_errEscribir
    cmp  eax, longitudArchivo  ; se escribieron todos los bytes pedidos?
    jne  gc_errEscribir
    CerrarManejador
    mov  hayCambiosSinGuardar, 0 ; ya no hay cambios pendientes
    MostrarMensaje msgGuardaOk
    ret
gc_errCrear:
    MostrarMensaje msgErrCrear
    ret
gc_errEscribir:
    CerrarManejador
    MostrarMensaje msgErrEscribir
gc_fin:
    ret
GuardarCatalogo ENDP


; EsDelimitador
;   Dice si un caracter termina un campo del archivo.
;   Recibe   : AL = caracter
;   Devuelve : ZF=1 si AL es ';', CR, LF o 00h
;   Modifica : solo banderas.

EsDelimitador PROC
    cmp  al, CAR_SEP
    je   ed_fin
    cmp  al, CAR_CR
    je   ed_fin
    cmp  al, CAR_LF
    je   ed_fin
    cmp  al, 0
ed_fin:
    ret
EsDelimitador ENDP


; CopiarCampo
;   Copia un campo del texto del archivo hasta encontrar ';', CR, LF o 00h.
;   Recibe   : ESI = posicion actual en bufferArchivo,  EDI = destino,  ECX = maximo
;   Devuelve : CF=0 -> campo copiado con 00h; ESI queda en el delimitador.
;              CF=1 -> el campo es mas largo que el maximo
;   Modifica : ESI (resultado) y banderas. Conserva EAX, ECX y EDI (USES).

CopiarCampo PROC USES eax ecx edi
ccf_sigue:
    mov  al, [esi]
    call EsDelimitador
    je   ccf_ok
    cmp  ecx, 0  ; ya no caben mas caracteres
    je   ccf_largo
    mov  [edi], al
    inc  esi
    inc  edi
    dec  ecx
    jmp  ccf_sigue
ccf_ok:
    mov  BYTE PTR [edi], 0
    clc
    ret
ccf_largo:
    stc
    ret
CopiarCampo ENDP


; CopiarCampoConSeparador
;   CopiarCampo + exigir que el campo termine en ';' y saltarlo.
;   Recibe   : igual que CopiarCampo
;   Devuelve : CF=0 -> campo copiado y ESI ya pasa el ';'.   CF=1 -> muy largo o no hay ';'
;   Modifica : ESI (resultado) y banderas. No usa mas registros.

CopiarCampoConSeparador PROC
    call CopiarCampo
    jc   ccs_fin
    cmp  BYTE PTR [esi], CAR_SEP
    jne  ccs_mal
    inc  esi
    clc
    ret
ccs_mal:
    stc
ccs_fin:
    ret
CopiarCampoConSeparador ENDP


; HayCodigoRepetido
;   Busca el codigo del producto temporal actual entre los productos temporales anteriores.
;   Recibe   : EBX = producto temporal actual (su codigo ya esta copiado)
;   Devuelve : CF=1 -> el codigo ya aparece antes en el archivo.   CF=0 -> no se repite
;   Modifica : solo banderas. Conserva ESI y EDI (USES; ESI es la posicion de lectura del texto).

HayCodigoRepetido PROC USES esi edi
    mov  esi, OFFSET catalogoTemporal ; ESI recorre los productos ya leidos
    lea  edi, [ebx + DESP_CODIGO]
hr_sigue:
    cmp  esi, ebx  ; llego al producto actual?
    jae  hr_no
    call CodigosIguales
    je   hr_si
    add  esi, TAM_REGISTRO
    jmp  hr_sigue
hr_si:
    stc
    ret
hr_no:
    clc
    ret
HayCodigoRepetido ENDP


; SaltarFinDeLinea
;   Avanza ESI sobre todos los CR y LF consecutivos.
;   Recibe   : ESI = posicion actual
;   Devuelve : ESI = primer caracter que no es CR ni LF
;   Modifica : ESI (resultado). Conserva EAX (USES).

SaltarFinDeLinea PROC USES eax
sf_sigue:
    mov  al, [esi]
    cmp  al, CAR_CR
    je   sf_avanza
    cmp  al, CAR_LF
    jne  sf_fin
sf_avanza:
    inc  esi
    jmp  sf_sigue
sf_fin:
    ret
SaltarFinDeLinea ENDP


; ProcesarArchivo
;   Reconstruye el catalogo temporal a partir del texto de
;   bufferArchivo y valida TODO: formato de cada campo, rangos, codigos duplicados,
;   maximo de 10 productos y que haya al menos uno. ESI recorre el texto; EBX
;   apunta al producto temporal que se esta llenando.
;   Recibe   : ESI = inicio de bufferArchivo (ya terminado con 00h)
;   Devuelve : CF=0 -> catalogoTemporal y cantProductosTemp listos.  CF=1 -> archivo invalido
;   Modifica : solo banderas, catalogoTemporal y cantProductosTemp.
;              Conserva EAX, EBX, ECX, EDX, EDI y ESI (USES).

ProcesarArchivo PROC USES eax ebx ecx edx edi esi
    mov  cantProductosTemp, 0
    mov  ebx, OFFSET catalogoTemporal
pa_linea:
    cmp  BYTE PTR [esi], 0  ; fin del texto?
    je   pa_fin
    cmp  cantProductosTemp, MAX_PRODUCTOS
    jae  pa_mal ; mas de 10 lineas
; codigo 
    CargarCampo CopiarCampoConSeparador, [ebx + DESP_CODIGO], LONG_CODIGO, pa_mal
    LlamarConCadena ValidarCodigo, [ebx + DESP_CODIGO]
    jc   pa_mal
    call HayCodigoRepetido ; codigo duplicado dentro del archivo?
    jc   pa_mal
; nombre 
    CargarCampo CopiarCampoConSeparador, [ebx + DESP_NOMBRE], MAX_NOMBRE, pa_mal
    LlamarConCadena ValidarNombre, [ebx + DESP_NOMBRE]
    jc   pa_mal
; precio
    CargarCampo CopiarCampoConSeparador, bufferCampo, MAX_CAMPO_NUM, pa_mal
    LlamarConCadena CadenaACentavos, bufferCampo
    jc   pa_mal
    mov  [ebx + DESP_PRECIO], eax
; existencia
    CargarCampo CopiarCampo, bufferCampo, MAX_CAMPO_NUM, pa_mal
    LlamarConCadena CadenaAExistencia, bufferCampo
    jc   pa_mal
    mov  [ebx + DESP_EXISTENCIA], eax
; fin de linea: no debe sobrar un ';'
    cmp  BYTE PTR [esi], CAR_SEP
    je   pa_mal
    call SaltarFinDeLinea ; salta CR y LF
    inc  cantProductosTemp
    add  ebx, TAM_REGISTRO  ; siguiente producto temporal
    jmp  pa_linea
pa_fin:
    cmp  cantProductosTemp, 0  ; un archivo sin productos no es valido
    je   pa_mal
    clc
    ret
pa_mal:
    stc
    ret
ProcesarArchivo ENDP


; LeerArchivoABuffer
;   1) OpenInputFile -> EAX = handle (INVALID_HANDLE_VALUE si no existe).
;   2) ReadFromFile: EAX = handle, EDX = buffer, ECX = capacidad de lectura.
;      Se piden TAM_BUFFER_ARCHIVO-1 bytes para reservar 1 byte para el 00h final.
;      Al regresar EAX = bytes LEIDOS
;   3) Se pone 00h justo despues del ultimo byte leido, para poder tratar el texto como cadena.
;   Devuelve : CF=0 -> bufferArchivo listo como cadena.
;              CF=1 -> no existe / fallo la lectura / vacio o demasiado grande (mensaje ya mostrado)
;   Modifica : bufferArchivo, bytesLeidos, manejadorArchivo y banderas. Conserva EAX, ECX y EDX (USES).

LeerArchivoABuffer PROC USES eax ecx edx
    mov  edx, OFFSET nombreArchivo
    call OpenInputFile   ; EAX = handle
    cmp  eax, INVALID_HANDLE_VALUE
    je   la_noExiste
    mov  manejadorArchivo, eax  ; EAX ya trae el handle que pide ReadFromFile
    mov  edx, OFFSET bufferArchivo
    mov  ecx, TAM_BUFFER_ARCHIVO - 1 ; capacidad menos el espacio del 00h
    call ReadFromFile    ; EAX = bytes leidos
    jc   la_errLectura
    mov  bytesLeidos, eax
    CerrarManejador
    mov  eax, bytesLeidos
    cmp  eax, 0    ; archivo vacio
    je   la_invalido
    cmp  eax, TAM_BUFFER_ARCHIVO - 1 ; lleno el buffer: probablemente es demasiado grande
    jae  la_invalido
    mov  BYTE PTR bufferArchivo[eax], 0 ; 00h despues del ultimo byte leido
    clc
    ret
la_noExiste:
    Rechazar msgNoArchivo
    ret
la_errLectura:
    CerrarManejador
    Rechazar msgErrLeer
    ret
la_invalido:
    Rechazar msgArchInvalido
    ret
LeerArchivoABuffer ENDP


; CargarCatalogo   (menu 8)
;   1) Si hay cambios sin guardar, pide confirmacion.
;   2) LeerArchivoABuffer lee el archivo.
;   3) ProcesarArchivo valida todo en el catalogo temporal
;   4) Solo si todo es valido se copia catalogoTemporal -> catalogo (REP MOVSB).
;      Si algo falla, el catalogo actual queda intacto.
;   Modifica : nada (conserva EAX, ECX, EDX, ESI y EDI con USES).

CargarCatalogo PROC USES eax ecx edx esi edi
    cmp  hayCambiosSinGuardar, 0
    je   ccat_sigue
    mov  edx, OFFSET promptReemplazo
    call PreguntarSiNo
    jc   ccat_fin    ; respondio No: no se carga nada
ccat_sigue:
    call LeerArchivoABuffer
    jc   ccat_fin
    cld      ; limpia catalogoTemporal antes de usarlo
    mov  edi, OFFSET catalogoTemporal
    mov  ecx, TAM_TABLA
    xor  al, al
    rep  stosb
    mov  esi, OFFSET bufferArchivo
    call ProcesarArchivo
    jc   ccat_invalido
; todo valido: reemplaza el catalogo
    mov  esi, OFFSET catalogoTemporal
    mov  edi, OFFSET catalogo
    mov  ecx, TAM_TABLA
    rep  movsb
    mov  eax, cantProductosTemp
    mov  cantProductos, eax
    mov  hayCambiosSinGuardar, 0
    MostrarEtiquetaEntero msgCargaOk, eax
    ret
ccat_invalido:
    MostrarMensaje msgArchInvalido
ccat_fin:
    ret
CargarCatalogo ENDP

; ==============================================================================
; 9. PROGRAMA PRINCIPAL

main PROC
    mov  espInicial, esp   ; guarda ESP para comprobar la pila en cada vuelta
    MostrarMensaje msgTitulo

menuLoop:
    cmp  esp, espInicial  ; si ESP cambio, algun CALL/RET/PUSH/POP no cuadro
    je   pilaOk
    MostrarMensaje msgPila
pilaOk:
    MostrarMensaje msgMenu
    mov  edx, OFFSET promptOpcion
    call LeerConMensaje    ; EAX = numero de caracteres escritos
    cmp  eax, 1  ; la opcion debe ser de un solo caracter
    jne  opcionMala
    mov  al, bufferEntrada  ; AL = el caracter escrito
    Opcion '1', RegistrarProducto
    Opcion '2', ListarInventario
    Opcion '3', ConsultarProducto
    Opcion '4', RecibirMercancia
    Opcion '5', VenderProducto
    Opcion '6', MostrarResumen
    Opcion '7', GuardarCatalogo
    Opcion '8', CargarCatalogo
    cmp  al, '9'
    je   opcion9
    cmp  al, '0'
    je   opcion0
opcionMala:
    MostrarMensaje msgOpcionMala
    jmp  menuLoop

opcion9:
    MostrarMensaje msgRegla
    jmp  menuLoop
opcion0:
    cmp  hayCambiosSinGuardar, 0 ; hay cambios sin guardar?
    je   salir
    mov  edx, OFFSET promptSalir
    call PreguntarSiNo
    jc   menuLoop   ; respondio No: regresa al menu
salir:
    MostrarMensaje msgAdios
    exit
main ENDP

END main
