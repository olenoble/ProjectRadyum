.MODEL LARGE
.STACK 100H
.386

.STACK 4096

.DATA
FILENAME    db "C:\IMG_TEST.LBM", 0
FILEINFO    dw 4 dup (0)

MSG_TEST    db 13, 10, "Press Any Key...", "$"

PICT_SIZE   dw 2 dup (0)
CMAP_REF    db "CMAP"
CMAP_BUFFER db 3 * 256 dup (0)

BODY_REF    db "BODY"
BODY_BUFFER db 320*200 dup (0)

.CODE

MAIN PROC

    call SETUP
    call INT9_SETUP
    call INTRO

    ; open the file
    mov dx, offset FILENAME
    mov di, offset FILEINFO
    call OPEN_FILE
    
    ; *****************************************
    ; Read the image now - find the size first
    mov si, offset FILEINFO
    mov ax, [si+6]
    mov es, ax
    
    mov si, offset PICT_SIZE
    mov di, 14h
    mov ax, es:[di]             ; Number of columns
    xchg al, ah
    mov [si], ax
    mov ax, es:[di+2]           ; Number of rows
    xchg ah, al
    mov [si+2], ax

    ; find cmap (color range)
    cld
    xor cx, cx
    dec cx
    mov si, offset CMAP_REF
find_cmap:
    mov ax, [si]
    repnz scasw
    mov ax, [si+2]
    scasw
    jnz find_cmap
    
    ; And store it (little annoying that movsb works with the registers the other way around)
    push ds
    push es
    pop ds
    pop es
    
    mov si, offset CMAP_BUFFER
    xchg si, di
    mov cx, 256 * 3
    rep movsb
    
    push ds
    push es
    pop ds
    pop es
    
    ; Now find body
    cld
    xor cx, cx
    dec cx
    mov si, offset BODY_REF
    xor di, di
find_body:
    mov ax, [si]
    repnz scasw
    mov ax, [si+2]
    scasw
    jnz find_body
    
    ; Parse body data
    add di, 2       ; looks like there is 2 empty bytes after BODY
    mov si, offset FILEINFO
    mov bx, [si+4]
    ; add bx, di
    mov dx, 0fe26h
    
    push ds
    push es
    pop ds
    pop es
    
    mov si, offset BODY_BUFFER
    xchg si, di
    xor ch, ch
fill_data:
    mov al, [si]
    inc si
    
    mov cl, al
    and al, 80h

    jz less80h

    neg cl
    inc cl
    mov al, [si]
    rep stosb
    inc si
    jmp test_pos
    
less80h:
    inc cl
    rep movsb
test_pos:
    cmp bx, si
    ja fill_data

end_filling:
    push ds
    push es
    pop ds
    pop es
    
    ; Then print a little message
    mov dx, offset MSG_TEST
    mov ah, 9
    int 21h
    
    call READ_KEY_WAIT
    
    mov ax, 0013h
    int 10h
    
    mov ax, 0a000h
    mov es, ax
    mov di, 0
    
    mov si, offset BODY_BUFFER
    mov cx, 320 * 200
    rep movsb
    
    call READ_KEY_WAIT
    
    
    ; remember to free up the requested memory
    mov di, offset FILEINFO
    mov ax, [di+6]
    mov es, ax
    mov ah, 49h
    int 21h
    
    call INT9_RESET
    call RESET_SCREEN
    jmp ENDPROG 
    
MAIN ENDP

    ; **********************************************
    ; **********************************************
    ; ** Include files here
    INCLUDE setup.asm
    INCLUDE intro.asm
    INCLUDE filemgmt.asm
    INCLUDE keyb.asm
    
END MAIN

