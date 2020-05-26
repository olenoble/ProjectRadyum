.MODEL SMALL
.STACK 100H
.386

.DATA 
MSG db "Welcome Friend", 13, 10, "$"
OLDINT9 dw 2 dup (?)
BUFFER db 0

.CODE

MAIN PROC
    mov ax, @DATA
    mov ds, ax
    
    ; Welcome message
    mov dx, offset MSG
    mov ah, 9
    int 21h

    ; Get current address of int 9
    mov al, 09h
    mov ah, 35h
    int 21h
    mov [OLDINT9], bx              ; Save it for later
    mov [OLDINT9 + 2], es
    
    ; Set new interrupt
    push ds
    mov ax, cs
    mov ds, ax
    mov al, 09h
    lea dx, cs:[BespokeInt9]
    mov ah, 25h
    int 21h  
    pop ds  
    
    ; Now wait for user pressing ESC
wait_key:    
    mov al, [BUFFER]
    or al, al
    jz  wait_key       ; if 0 in buffer, then keep on waiting
    
    push ax
    mov al, 0adh
    out 64h, al
    pop ax
    
    mov dl, al
    mov ah, 02h
    int 21h
    
    mov dl, 0
    mov [BUFFER], dl

    push ax
    mov al, 0aeh
    out 64h, al
    pop ax

    xor al, 1
    jnz wait_key
    
    
    ; Before exiting, we must reset int9 to its former address
    push ds
    mov dx, [OLDINT9]
    mov ax, [OLDINT9 + 2]
    mov ds, ax
    mov al, 09h    
    mov ah, 25h
    int 21h  
    pop ds  

    mov ah, 4ch
    int 21h
    
    ; Below is my new int9
BespokeInt9: 
    cli     ; stop all interrupts
    pusha   

    mov ax, @DATA
    mov ds, ax
    
    in al, 60h
    mov ah, al
    
    ; is it an up key (which we don't care about)
    and ah, 80h
    jz down_key
    
    mov al, 0
down_key:
    mov [BUFFER], al
    
    mov al, 20h
    out 20h, al
    
    popa
    sti
    iret
    
MAIN ENDP

END MAIN