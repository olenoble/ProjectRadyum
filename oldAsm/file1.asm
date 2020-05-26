.MODEL SMALL
.STACK 100H
.386

.DATA 
MSG db "Welcome User", 13, 10, "$"
MSG2 db "Please Press Enter:  $"


TEXT_BUF_SIZE db 255
TEXT_BUF_READ db 1 dup (?)
BUFFER db 255 dup (?)

.CODE

MAIN PROC
    ; set ds register (points to data)
    ; note that ds can't be assigned directly
    mov ax, @DATA
    mov ds, ax
    
    ; switch to 320x200 256 colors
    mov ax, 0013h
    int 10h
    
    ; Welcome message
    mov dx, offset MSG
    mov ah, 9
    int 21h
    
    ; Question ?
    ;mov dl, 10
    ;mov ah, 02h
    ;int 21h
    ;mov dl, 13
    ;mov ah, 02h
    ;int 21h

    mov dx, offset MSG2
    mov ah, 9
    int 21h
    
    mov dx, offset TEXT_BUF_SIZE
    mov ah, 0ah
    int 21h
    
    ; quick test (10 new lines + 13 CR)
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h    
    mov dl, 13
    mov ah, 02h
    int 21h

    mov cl, TEXT_BUF_READ
    mov si, offset BUFFER
    mov ah, 02h
print_check:    
    mov dl, ds:[si]
    int 21h
    inc si
    dec cl
    jnz print_check
    
    ; wait for any key press
wait_key:
    in al, 60h

    mov dl, al
    mov ah, 02h
    int 21h
    
    cmp dl, 1
    jnz wait_key

    mov dx, offset TEXT_BUF_SIZE
    mov ah, 0ah
    int 21h

    
    ;mov ax, 0a000h
    ;mov es, ax
    
    ;mov di, 160*50 + 80
    ;mov dl, 7   
    ;mov es:[di], dl
    
    mov ax, 0003h
    int 10h
    
    mov ah, 4ch
    int 21h



    
MAIN ENDP

END MAIN