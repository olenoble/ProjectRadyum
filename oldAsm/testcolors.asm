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
    lea si, [BUFFER]
wait_key:
    mov bl, [BUFFER_PTR]    
    or bl, bl
    jz wait_key        ; if 0 in buffer, then keep on waiting

    ; print the character (crude conversion into ascii)
    mov dl, bl
    add dl, 48
    mov ah, 02h
    int 21h
    
    ; reset the buffer
    dec bl
    mov [BUFFER_PTR], bl
    
    xor bh, bh
    mov dl, [si+bx]
    xor dl, 1
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
    jnz end_int9

    ; si points to buffer and dx is the current position
    lea si, [BUFFER]
    mov bl, [BUFFER_PTR]
    ; if overflow then don't bother storing it
    inc bl
    jz end_int9
    
    mov [BUFFER_PTR], bl
    dec bl
    xor bh, bh
    mov [si+bx], al
    
end_int9:
    mov al, 20h
    out 20h, al
    
    popa
    sti
    iret
    
MAIN ENDP

END MAIN