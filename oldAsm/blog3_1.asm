.MODEL SMALL
.STACK 100H
.386

.DATA 
MSG db "Welcome Friend", 13, 10, "$"
MSG2 db "Please type your text:  $"


.CODE

MAIN PROC
    mov ax, @DATA
    mov ds, ax
    
    ; Welcome message
    mov dx, offset MSG
    mov ah, 9
    int 21h
    
    ; Now wait for user pressing ESC
wait_key:    
    in al, 60h
    
    mov ah, al
    and ah, 80h
    jnz  wait_key       ; if it was a key up, go back and wait
    
    mov dl, al
    mov ah, 02h
    int 21h
        
    xor dl, 1
    jnz wait_key

    mov ah, 4ch
    int 21h
    
MAIN ENDP

END MAIN