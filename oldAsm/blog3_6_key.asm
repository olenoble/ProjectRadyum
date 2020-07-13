.MODEL SMALL
.STACK 100H
.386

.DATA 
MSG db "Welcome Friend", 13, 10, "$"
OLDINT9 dw 2 dup (?)
BUFFER db 255 dup (0)
BUFFER_PTR db 0

.CODE

MAIN PROC
    mov ax, @DATA
    mov ds, ax

    ; Welcome message
    mov dx, offset MSG
    mov ah, 9
    int 21h
    
    mov ax, 0040h
    mov es, ax
    
    
    ; Now wait for user pressing ESC
    mov di, 01Ch
wait_key:
    mov si, 01Ah
    mov ax, es:[si]
    mov bx, es:[di]
    cmp ax, bx
    jz wait_key
    
    push ax
    mov si, ax
    mov ax, es:[si]
    
    mov dx, ax
    and dh, 80h
    jnz wait_key
    
    mov dl, ah
    mov ah, 2
    int 21h

    pop ax
    xor dl, 1
    jz end_game
    
    mov es:[di], ax
    jmp wait_key

end_game:
    mov ah, 4ch
    int 21h
    
    
MAIN ENDP

END MAIN
