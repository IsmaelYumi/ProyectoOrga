.model small
.stack 100h
.data 

; Mensajes
msg1 db 13,10,'Ingrese la primera cadena (max 45 caracteres): $'
msg2 db 13,10,'Ingrese la segunda cadena (max 45 caracteres): $'
msg_err db 13,10,'Error: Excedio el limite de 45 caracteres. Intente de nuevo.$'
msg_repeat db 13,10,'Desea ingresar nuevas cadenas? (S/N): $'
msg_invalid db 13,10,'Entrada invalida. Solo S o N.$'
cadena1 db 46 dup('$')    ; +1 para el terminador
cadena2 db 46 dup('$')
len1 db 0
len2 db 0

.code
start:
    mov ax, @data
    mov ds, ax

main_loop:
    ;Entrada y validacion de la primera cadena
    lea dx, msg1
    mov ah, 09h
    int 21h

    lea di, cadena1
    mov cx, 0
leer_cadena1:
    mov ah, 01h
    int 21h
    cmp al, 13          ; ENTER?
    je fin_cadena1
    cmp cx, 45
    jae error1
    mov [di], al
    inc di
    inc cx
    jmp leer_cadena1
fin_cadena1:
    mov [di], '$'
    mov len1, cl

    ;Entrada y validacion de la segunda cadena
    lea dx, msg2
    mov ah, 09h
    int 21h

    lea di, cadena2
    mov cx, 0
leer_cadena2:
    mov ah, 01h
    int 21h
    cmp al, 13
    je fin_cadena2
    cmp cx, 45
    jae error2
    mov [di], al
    inc di
    inc cx
    jmp leer_cadena2
fin_cadena2:
    mov [di], '$'
    mov len2, cl

    ;Aqui puedes agregar procesamiento de las cadenas

    ;Preguntar si desea repetir
repetir_pregunta:
    lea dx, msg_repeat
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    cmp al, 'S'
    je main_loop
    cmp al, 's'
    je main_loop
    cmp al, 'N'
    je salir
    cmp al, 'n'
    je salir

    ; Entrada invalida
    lea dx, msg_invalid
    mov ah, 09h
    int 21h
    jmp repetir_pregunta

;Manejo de errores
error1:
    lea dx, msg_err
    mov ah, 09h
    int 21h
    jmp main_loop

error2:
    lea dx, msg_err
    mov ah, 09h
    int 21h
    jmp main_loop

salir:
    mov ah, 4ch
    int 21h
end start