.MODEL SMALL
.STACK 100H
.386

.DATA 
MSG db "Welcome New Project - Act I / Scene 1$"

.CODE

MAIN PROC
    ; set ds register (points to data)
    ; note that ds can't be assigned directly
    mov ax, @DATA
    mov ds, ax
   
    mov ax, 0013h
    int 10h
    
    ;lea dx, MSG
    mov dx, offset MSG
    mov ah, 9
    int 21h
    
    mov ax, 0a000h
    mov es, ax
    
    mov di, 160*50 + 80
    mov dl, 7
    ;STOSB
    
    mov es:[di], dl
    mov fs ,ax
     
    
    mov ah, 4Ch
    int 21h

    mov ax, 0003h
    int 10h

    
MAIN ENDP

END MAIN