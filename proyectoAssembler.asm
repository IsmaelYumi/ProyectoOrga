
ORG 100h


; Definiciones de buffers


MAX_LEN EQU 45

cadena1 DB MAX_LEN+1 DUP('$')
cadena2 DB MAX_LEN+1 DUP('$')

; Contadores y flags
contador1 DB ?
contador2 DB ?


; Inicio

INICIO:

    ; Limpiar buffers
    LEA DI, cadena1
    MOV CX, MAX_LEN+1
    MOV AL, '$'
    REP STOSB

    LEA DI, cadena2
    MOV CX, MAX_LEN+1
    MOV AL, '$'
    REP STOSB

    ; -------------------------
    ; Ingresar primera cadena
    ; -------------------------
    MOV DX, OFFSET msg1
    CALL print_string

    LEA DI, cadena1
    CALL leer_cadena

   
    ; Ingresar segunda cadena
    
    MOV DX, OFFSET msg2
    CALL print_string

    LEA DI, cadena2
    CALL leer_cadena

 
    ; Verificar anagramas
 
    CALL limpiar_cadenas ; pasa a minúsculas y elimina espacios

    CALL son_anagramas
    CMP AL, 1
    JE ANAGRAMA
    JMP NO_ANAGRAMA

ANAGRAMA:
    MOV AH, 09h
    MOV DX, OFFSET msg_anagrama
    INT 21h
    JMP CONTINUAR

NO_ANAGRAMA:
    MOV AH, 09h
    MOV DX, OFFSET msg_no_anagrama
    INT 21h

CONTINUAR:
    MOV DX, OFFSET msg_continuar
    CALL print_string

    MOV AH, 1
    INT 21h
    CMP AL, 'S'
    JE INICIO
    CMP AL, 's'
    JE INICIO

    MOV AH, 4Ch
    INT 21h


; Funcion para imprimir cadena (terminada en $)

print_string PROC
    MOV AH, 09h
    INT 21h
    RET
print_string ENDP

; ---------------------------------------
; Leer cadena hasta ENTER, máx 45 caracteres
; ---------------------------------------
leer_cadena PROC
    MOV CX, 0
leer_loop:
    MOV AH, 1
    INT 21h
    CMP AL, 13  ; ENTER
    JE fin_leer
    CMP CX, MAX_LEN
    JAE leer_loop ; ignorar si ya superó
    MOV [DI], AL
    INC DI
    INC CX
    JMP leer_loop
fin_leer:
    MOV AL, '$'
    MOV [DI], AL
    RET
leer_cadena ENDP


; Pasar a minúsculas y eliminar espacios

limpiar_cadenas PROC

    ; Para cadena1
    LEA SI, cadena1
    LEA DI, cadena1
    CALL limpiar_una

    ; Para cadena2
    LEA SI, cadena2
    LEA DI, cadena2
    CALL limpiar_una

    RET
limpiar_cadenas ENDP

limpiar_una PROC
    limpiar_loop:
        LODSB
        CMP AL, '$'
        JE fin_limpia
        CMP AL, 'A'
        JB skip_minus
        CMP AL, 'Z'
        JA skip_minus
        ADD AL, 32 ; Convertir a minúscula
    skip_minus:
        CMP AL, ' '
        JE limpiar_loop
        STOSB
        JMP limpiar_loop
    fin_limpia:
        MOV AL, '$'
        STOSB
        RET
limpiar_una ENDP

; Verificar si son anagramas

son_anagramas PROC

    ; Contar longitudes
    LEA SI, cadena1
    MOV CL, 0
    count1_loop:
        LODSB
        CMP AL, '$'
        JE end_count1
        INC CL
        JMP count1_loop
    end_count1:
        MOV contador1, CL

    LEA SI, cadena2
    MOV CL, 0
    count2_loop:
        LODSB
        CMP AL, '$'
        JE end_count2
        INC CL
        JMP count2_loop
    end_count2:
        MOV contador2, CL

    ; Si longitudes diferentes => no anagramas
    MOV AL, contador1
    CMP AL, contador2
    JNE no_es_anagrama

    ; Comparar caracteres
    LEA SI, cadena1

comparar_loop:
    MOV BL, [SI]
    CMP BL, '$'
    JE fin_comparar

    ; Buscar BL en cadena2
    LEA DI, cadena2
    CALL buscar_caracter
    CMP AL, 1
    JNE no_es_anagrama

    ; Reemplazar el carácter encontrado con '*'
    MOV [DI-1], '*'

    INC SI
    JMP comparar_loop

fin_comparar:
    MOV AL, 1
    RET

no_es_anagrama:
    MOV AL, 0
    RET

son_anagramas ENDP


; Buscar carácter en cadena

buscar_caracter PROC
    buscar_loop:
        LODSB
        CMP AL, '$'
        JE not_found
        CMP AL, BL
        JE found
        JMP buscar_loop
    found:
        MOV AL, 1
        RET
    not_found:
        MOV AL, 0
        RET
buscar_caracter ENDP


; Mensajes

msg1 DB 0Dh,0Ah,'Ingrese la primera cadena: $'
msg2 DB 0Dh,0Ah,'Ingrese la segunda cadena: $'
msg_anagrama DB 0Dh,0Ah,'Las cadenas SON anagramas! $'
msg_no_anagrama DB 0Dh,0Ah,'Las cadenas NO son anagramas! $'
msg_continuar DB 0Dh,0Ah,'Desea ingresar otras cadenas? (S/N): $'

END INICIO