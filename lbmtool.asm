; ***************************************************************************************
; ***************************************************************************************
; ** Tools to decompress LBM fikes
; ** The code only works for 320x200 256 color files


.DATA
PICT_SIZE   dw 2 dup (0)
CMAP_REF    db "CMAP"
BODY_REF    db "BODY"

CMAP_BUFFER db 3 * 256 dup (0)
BODY_BUFFER db 320 * 200 dup (0)

.CODE

READ_LBM:
    ; decompress LBM file
    ; SI must point to the file info with the format:
    ; FILEHANDLE (1w) + FILESIZE (2w - big endian) + FILESEGMENT (1w)

    pusha
    
    ; Save SI for later
    push si
    
    ; get the file segment
    mov ax, [si+6]
    mov es, ax
    
    ; extract the size here (14h position in the header)
    mov si, offset PICT_SIZE
    mov di, 14h
    mov ax, es:[di]   ; Number of columns
    xchg al, ah
    mov [si], ax
    mov ax, es:[di+2] ; Number of rows
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
    add si, 4
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
    add di, 4
    pop si
    push si
    mov bx, [si+4]
    
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

    ; All done we can leave now
    push ds
    push es
    pop ds
    pop es
    
    ; remember to free up the original file memory
    ; move si to di (last pop)
    pop di
    mov ax, [di+6]
    mov es, ax
    mov ah, 49h
    int 21h

    popa
    ret 
    
; ********************************************************************************************
; ********************************************************************************************
; ** Various functions
; list of error functions
;CantAllocateMemory:
;    ; This routine is called if DOS can't allocate the requested memory
;    mov dx, offset ERR_FILE4
;    jmp FileErrorMsgAndQuit
;
;    jmp ENDPROG
