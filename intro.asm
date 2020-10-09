; ***************************************************************************************
; ***************************************************************************************
; ** Simple into function (display basic messages)
; ** Require setup.asm

.DATA
memory_size         db 5 dup(0)
dos_major           db 2 dup (0)
dos_minor           db 2 dup (0)
msg_welcome         db "Welcome Player ", (49 + PLAYER_NUMBER), 13, 10, "$"
msg_memsize         db "You have $"
msg_memsize2        db "kb of memory available", 13, 10, "$"
msg_dosver          db "You are running DOS $"
msg_dosver2         db 13, 10, "$"

.CODE
INTRO:
    ; simple welcome piece of code
    ; Frankly not very well written but that's not critical   
    mov dx, offset msg_welcome
    mov ah, 9
    int 21h
    
    ; call int 12h to check how much memory we've got
    ; ax will contain the memory size
    ; int 12h
    
    ; int 12h is not super accurate (it just gives the max amount of potentially free memory)
    ; Better solution is to use 48h / int 21h and request the max - which is bound to fail with DOSBOX
    ; bx will return the largest amount of 16bytes pages that can be requested
    mov bx, 0ffffh
    mov ah, 48h
    int 21h
    mov ax, bx
    shr ax, 6
    
    ; convert it to ASCII
    mov di, offset memory_size
    call convert_ax_ascii
    
    ; Then print it out
    mov dx, offset msg_memsize
    mov ah, 9
    int 21h

    mov si, offset memory_size
    mov cx, 5
    call print_ascii
    
    mov dx, offset msg_memsize2
    mov ah, 9
    int 21h
    
    ; Now check dos version
    mov ax, 3000h
    int 21h
    
    ; Convert the major/minor versions to ASCII
    mov di, offset dos_major
    call convert_al_ascii
    
    mov al, ah
    mov di, offset dos_minor
    call convert_al_ascii
    
    ; and print it
    mov dx, offset msg_dosver
    mov ah, 9
    int 21h
    
    mov si, offset dos_major
    mov cx, 2
    call print_ascii
    
    mov dl, 2eh
    mov ah, 02h
    int 21h
    
    mov si, offset dos_minor
    mov cx, 2
    call print_ascii

    mov dx, offset msg_dosver2
    mov ah, 9
    int 21h
    
    ret


; ********************************************************************************************
; ********************************************************************************************
; ** Various functions
    
; Very simple algo to convert a 16bit number in AX into an ASCII equivalent
convert_ax_ascii:    
    ; AX = number to convert
    ; DI = address to store the output (assume ds for segment) 
    ; Note that the data is stored backwards (i.e. "640" will be stored "046")
    
    push ax
    push bx
    push dx
    push di
    
    mov bx, 10
    ; The algo is about dividing by 10 the output
    ; and convert the remainder to ASCII
    @@decimal_conv:
        xor dx, dx
        div bx
        add dl, 30h
        mov [di], dl
        inc di
        or ax, ax
        jnz @@decimal_conv
    
    pop di
    pop dx
    pop bx
    pop ax
    ret 


; Similar function but for AL (8bits) - a lot easier
convert_al_ascii:
    ; AL = number to convert
    ; DI = address to store the output (assume ds for segment) 
    ; Note that the data is stored backwards (i.e. "64" will be stored "46")
    
    push ax
    push di
    
    @@decimal_al_conv:
        aam
        add al, 30h
        mov [di], al
        inc di
        mov al, ah
        or al, al
        jnz @@decimal_al_conv
    
    pop di
    pop ax
    ret


print_ascii:
    ; CX = size of string
    ; SI = address of the string to print out (assume characters are stored in reverse)
    
    push si
    push cx
    push ax
    push dx

    add si, cx
    dec si

    mov ah, 02h
    @@print_check:
        mov dl, [si]
        or dl, dl
        jz @@noprint  ; do not print if you find 0
        int 21h
    @@noprint:    
        dec si
        dec cx
        jnz @@print_check
    
    pop dx
    pop ax
    pop cx
    pop si
   
    ret 
