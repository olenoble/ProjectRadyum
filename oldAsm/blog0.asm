.MODEL LARGE
.STACK 100H
.386


.DATA
memory_size         db 5 dup(0)
dos_major           db 2 dup (0)
dos_minor           db 2 dup (0)
msg_welcome         db "Welcome To Radyum", 13, 10, "$"
msg_memsize         db "You have $"
msg_memsize2        db "kb of memory available", 13, 10, "$"
msg_dosver          db "You are running DOS $"
msg_dosver2         db 13, 10, "$"

.CODE

MAIN PROC
    mov ax, @DATA
    mov ds, ax
    
    mov dx, offset msg_welcome
    mov ah, 9
    int 21h
    
    ; call int 12h to check how much memory we've got
    ; ax will contain the memory size
    int 12h
    
    ; Now the algo is about dividing by 10 the output
    ; and convert the remainder to ASCII
    mov di, offset memory_size
    mov bx, 10
decimal_conv:
    xor dx, dx
    div bx
    add dl, 30h
    mov [di], dl
    inc di
    or ax, ax
    jnz decimal_conv
    
    ; Then print it out
    mov dx, offset msg_memsize
    mov ah, 9
    int 21h

    mov si, offset memory_size
    add si, 4
    mov cx, 5
    mov ah, 02h
print_check:
    mov dl, ds:[si]
    or dl, dl
    jz noprint
    int 21h
noprint:    
    dec si
    dec cx
    jnz print_check
    
    mov dx, offset msg_memsize2
    mov ah, 9
    int 21h
    
    ; Now check dos version
    mov ax, 3000h
    int 21h
    
    mov cx, ax
    
    mov di, offset dos_major
decimal_al_conv:
    aam
    add al, 30h
    mov [di], al
    inc di
    mov al, ah
    or al, al
    jnz decimal_al_conv

    mov di, offset dos_minor
    mov al, ch
decimal_ah_conv:
    aam
    add al, 30h
    mov [di], al
    inc di
    mov al, ah
    or al, al
    jnz decimal_ah_conv
    
    ; and print it
    mov dx, offset msg_dosver
    mov ah, 9
    int 21h
    
    mov si, offset dos_major
    add si, 1
    mov cx, 2
    mov ah, 02h
print_major:
    mov dl, ds:[si]
    or dl, dl
    jz no_print_major
    int 21h
no_print_major:
    dec si
    loopnz print_major
    
    mov dl, 2eh
    int 21h  
    
    mov si, offset dos_minor
    add si, 1
    mov cx, 2
    mov ah, 02h
print_minor:
    mov dl, ds:[si]
    or dl, dl
    jz no_print_minor
    int 21h
no_print_minor:
    dec si
    loopnz print_minor 

    mov dx, offset msg_dosver2
    mov ah, 9
    int 21h
    
end_file:
    mov ah, 4ch
    int 21h

    
MAIN ENDP

END MAIN