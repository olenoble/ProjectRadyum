; ***************************************************************************************
; ***************************************************************************************
; ** Tools to decompress LBM fikes
; ** The code only works for 320x200 256 color files
; ** Require setup.asm

.DATA
PICT_SIZE   dw 2 dup (0)
CMAP_REF    db "CMAP"
BODY_REF    db "BODY"

CMAP_BUFFER db 3 * 256 dup (0)
IMG_PTR     dw 0

.CODE

READ_LBM:
    ; decompress LBM file
    ; SI must point to the file info with the format:
    ; FILEHANDLE (1w) + FILESIZE (2w - big endian) + FILESEGMENT (1w)
    ; the routine will free up the memory at the end!
    ; the routine also allocates 64kb in memory for the image - stored in IMG_PTR

    pusha
    
    ; Save SI for later (till the very end of that routine)
    push si
    
    ; ****************************************************
    ; ** Important, we now allocate the 64kb for the image  
    mov bx, 0fa0h
    mov ah, 48h
    int 21h
    
    jc CantAllocateMemoryForImage
    call MemoryStillAvail
    mov [IMG_PTR], ax
    
    ; ****************************************************
    ; ** Now parse the LBM file
    
    ; get the file segment of file to ES
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
    
    ; ********************************************
    ; ** The tricky bit --> Parse body data
    ; ES:DI must point to the newly created buffer in memory
    add di, 4
    pop si
    push si
    mov bx, [si+4]
    
    ; first ES:DI points to the BODY data in the file (need to swap with SI)
    ; before doing this, let's put aside the segment for the buffer
    mov ax, [IMG_PTR]
    push ds
    push es
    pop ds
    
    ; we don't pop es here since we need to change it (DS is now pointing to BODY)
    ;pop es 
    ; mov si, offset BODY_BUFFER
    mov es, ax
    
    xor si, si
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

    ; All done we can leave now - and reset es/ds as they were
    ; first pop es (we skipped it just above)
    pop es
    
    ; and do the whole switcheroo all over again
    push ds
    push es
    pop ds
    pop es
    
    ; remember to free up the original file memory
    ; move si to di (last pop)
    pop di
    ;mov ax, [di+6]
    ;mov es, ax
    ;mov ah, 49h
    ;int 21h
    ;call MemoryStillAvail
    
    popa
    ret 
    
; ********************************************************************************************
; ********************************************************************************************
; ** Various functions
CantAllocateMemoryForImage:
    ; This routine is called if DOS can't allocate the requested memory
    mov dx, offset ERR_FILE4
    jmp LBM_FileErrorMsgAndQuit
    
LBM_FileErrorMsgAndQuit:
    ; Routine display the corresponding error message and exit
    call RESET_SCREEN
    mov ah, 9
    int 21h
    
    call INT9_RESET
    
    jmp ENDPROG
