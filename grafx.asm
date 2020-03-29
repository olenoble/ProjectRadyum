; ***************************************************************************************
; ***************************************************************************************
; ** Graphics tools
; ** Require setup.asm & lbmtool.asm

MAX_LBM_FILES   equ 3

.DATA
; We can allow up to 10 color maps (limit completely arbitrary - about 4kb)
COLORMAPS    db 3 * 256 * MAX_LBM_FILES dup (0)
SCREEN_PTR   dw MAX_LBM_FILES dup (0)           ; segments to be allocated for images
FADEWAITITR  dw 4
IMG_COUNTER  db 0
VIDEO_BUFFER dw 0

ERR_BUFFER   db "Could not allocate memory for the video buffer", 13, 10, "$"

; ************************************************************************************
; ** A few macros
DETECT_VSYNC MACRO
    local @@WaitNotVSyncMACRO, @@WaitVSyncMACRO
    ; Detect vsync - will modify ax and dx
    mov dx, 03dah
    @@WaitNotVSyncMACRO:
        ;wait to be out of vertical sync
        in al, dx
        and al, 08h
        jnz @@WaitNotVSyncMACRO

    @@WaitVSyncMACRO:
        ;wait until vertical sync begins
        in al, dx
        and al, 08h
        jz @@WaitVSyncMACRO
ENDM


POINT_TO_PALETTE MACRO
    local @@PaletteShiftPos
    ; input = AL points to the palette number
    ; output = AX points to the beginning of palette
    ; need to add 300h x palette number to point to the right palette
    mov cl, al
    mov bx, 300h
    xor ch, ch

    mov ax, offset COLORMAPS
    inc cx
    @@PaletteShiftPos:
        add ax, bx
        dec cx
        jnz @@PaletteShiftPos
    sub ax, bx
ENDM


; ************************************************************************************
; ** real code is here
.CODE  
SWITCH_TO_320x200:
    ; pretty explicit
    ; ax is modified
    mov ax, 0013h
    int 10h
    ret


ALLOCATE_IMG_PTR:
    ; preset the position of the 320x200 img to store
    ; as well as the video buffer
    ; bx is input to the start of the memory zone
    ; return bx to the end of the memory zone
    push cx
    push si

    mov cx, MAX_LBM_FILES
    mov si, offset SCREEN_PTR

    @@LoopImgPtr:
        mov [si], bx
        add si, 2
        add bx, 0fa0h ;0fffh
        dec cx
        jnz @@LoopImgPtr
    
    mov [VIDEO_BUFFER], bx
    add bx, 0fa0h

    pop si
    pop cx
    ret

   
COPY_TO_VIDEOBUFFER:
    ; copy the contents of the video buffer over to the video memory
    pusha
    
    mov ax, 0a000h
    mov es, ax
    mov di, 0
    
    push ds
    mov ax, [VIDEO_BUFFER]
    mov ds, ax
    xor si, si
    
    DETECT_VSYNC
    mov cx, 320 * 200
    rep movsb
    pop ds
    
    popa
    ret
    

EXTRACT_IMG:
    ; call lbmtool to decompress a LBM file.
    ; SI must point to the file info with the format:
    ; FILEHANDLE (1w) + FILESIZE (2w - big endian) + FILESEGMENT (1w)
    ; IMG_PTR points to the data segment for the image (need to populate it from already allocated segments)
    ; the colormap in lbmtool also need to be copied over in the right location in COLORMAPS

    pusha

    mov di, offset SCREEN_PTR
    mov al, [IMG_COUNTER]
    shl al, 1           ; we use words so pointer needs to be multiplied by 2
    xor ah, ah
    add di, ax
    mov ax, [di]
    mov [IMG_PTR], ax

    call READ_LBM

    ; save pointer to buffer
    mov si, offset SCREEN_PTR
    mov al, [IMG_COUNTER]
    shl al, 1           ; we use words so pointer needs to be multiplied by 2
    xor ah, ah
    add si, ax
    mov ax, [IMG_PTR]
    mov [si], ax
    
    ; transfer colormap
    push ds
    pop es
    mov si, offset CMAP_BUFFER
    mov di, offset COLORMAPS
    
    ; need to add 300h x palette number to point to the right palette
    mov cl, [IMG_COUNTER]
    mov bx, 300h
    xor ch, ch
    xor ax, ax
    inc cx
    @@shift_pos:    
        add ax, bx
        dec cx
        jnz @@shift_pos
    
    sub ax, bx
    add di, ax
    mov cx, bx
    rep movsb
    
    ; now increase the counter
    mov al, [IMG_COUNTER]
    inc al
    mov [IMG_COUNTER], al
    
    popa    
    ret
 

SET_PALETTE:
    ; set the palette 
    ; AL points to the palette number
    pusha
    
    POINT_TO_PALETTE
    
    mov si, ax
    mov cx, 256 * 3
    
    ; and now apply it
    mov dx, 03c8h
    xor al, al
    out dx, al
    
    mov dx, 03c9h
    cli
    cld
    @@set_palette_loop:
        ; set the red/green/blue component
        lodsb
        and al, 1111b
        shl al, 2
        out dx, al
        loop @@set_palette_loop

    sti
    popa
    ret


BLACKOUT:
    ; set all colors to 0
    push ax
    push dx
    
    mov dx, 03c8h
    xor al, al
    out dx, al
    
    mov dx, 03c9h
    cli
    @@BlackOutLoop:
        mov al, 0
        out dx, al
        loop @@BlackOutLoop

    sti
    ret
    
  
FADEOUT:
    ; Create a fade-in effect
    ; AL is the color map number
    pusha
    
    ; get the palette offset (and save it)
    POINT_TO_PALETTE
    mov di, ax
    
    ; bl = max number of iteration (4bit coded so 1111b is enough)
    ; we start at ah = 1111b
    mov bl, 1111b
    mov ah, bl
    @@FadeOutIterate:
        ; now set colors 
        mov cx, 256 * 3
        
        ; get the offset back
        mov si, di
        
        mov dx, 03c8h
        xor al, al
        out dx, al
        
        mov dx, 03c9h
        cli
        @@FadeOutColorLoop:
            ; set the red/green/blue component
            lodsb
            and al, 1111b
            ; if greater than ah, use ah - otherwise use rgb
            ; this is effectively min(rgb, ah)
            cmp al, ah
            jb @@use_al_fadeout
            mov al, ah
        @@use_al_fadeout:    
            shl al, 2
            out dx, al

            loop @@FadeOutColorLoop

        sti
        
        ; then we wait a few iteration of the Vsync scan
        ; so it doesn't go too fast
        mov cx, [FADEWAITITR]
        @@FadeOutMultipleScan:
            DETECT_VSYNC
            loop @@FadeOutMultipleScan
        
        dec ah
        dec bl
        jnz @@FadeOutIterate
    
    popa
    ret
 
   
FADEIN:
    ; Create a fade-in effect
    ; AL is the color map number
    pusha
    
    ; get the palette offset (and save it)
    POINT_TO_PALETTE
    mov di, ax
    
    ; bl = max number of iteration (4bit coded so 1111b is enough)
    ; we start at ah = 0
    mov bl, 1111b
    mov ah, 0
    @@FadeInIterate:
        ; now set colors 
        mov cx, 256 * 3
        
        ; get the offset back
        mov si, di
        
        mov dx, 03c8h
        xor al, al
        out dx, al
        
        mov dx, 03c9h
        cli
        @@FadeInColorLoop:
            ; set the red/green/blue component
            lodsb
            and al, 1111b
            ; if greater than ah, use ah - otherwise use rgb
            ; this is effectively min(rgb, ah)
            cmp al, ah
            jb @@use_al_fadein
            mov al, ah
        @@use_al_fadein:    
            shl al, 2
            out dx, al

            loop @@FadeInColorLoop

        sti
        
        ; then we wait a few iteration of the Vsync scan
        ; so it doesn't go too fast
        mov cx, [FADEWAITITR]
        @@FadeInMultipleScan:
            DETECT_VSYNC
            loop @@FadeInMultipleScan
        
        inc ah
        dec bl
        jnz @@FadeInIterate
    
    popa
    ret
    
    
; ********************************************************************************************
; ********************************************************************************************
; ** Various functions
Grafx_FileErrorMsgAndQuit:
    ; Routine display the corresponding error message and exit
    call RESET_SCREEN
    mov ah, 9
    int 21h
    
    call MemoryStillAvail
    ;call FREE_ALL_IMG_MEMORY
    
    call INT9_RESET
    
    jmp ENDPROG