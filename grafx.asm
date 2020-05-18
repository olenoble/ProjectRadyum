; ***************************************************************************************
; ***************************************************************************************
; ** Graphics tools
; ** Require setup.asm & lbmtool.asm

MAX_LBM_FILES   equ 3
VGA_RAM_LOCATION equ 0a000h

.DATA
; We can allow up to 10 color maps (limit completely arbitrary - about 4kb)
COLORMAPS    db 3 * 256 * MAX_LBM_FILES dup (0)
SCREEN_PTR   dw MAX_LBM_FILES dup (0)           ; segments to be allocated for images
FADEWAITITR  dw 4
IMG_COUNTER  db 0
VIDEO_BUFFER dw 0
TEMP_RGB     db 3 dup (0)

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
    mov ah, al
    ; ah = al * 3 - we just need to set al to 0 then to create the multiple of 300h
    shl ah, 1
    add ah, al
    xor al, al
    ; then only add the starting position
    add ax, offset COLORMAPS
ENDM


GENERATE_TILE_FAST MACRO
    ; a fast brute-force way of generating a tile
    ; input = DS:SI points to the top left corner of the tile
    ;         ES:DI point to the top left corner of the buffer to display
    ; SI, DI and CX will be modified
    mov cl, 8
    rep movsw               ; iteration 1
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 2
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 3
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 4
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 5
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 6
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 7
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 8
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 9
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 10
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 11
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 12
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 13
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 14
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 15
    add di, 320 - 16
    add si, 256 - 16
    mov cl, 8
    rep movsw               ; iteration 16
ENDM


SPRITE_PIXEL MACRO
    local @@skip_pixel
    mov al, ds:[bx]
    or al, al
    jz @@skip_pixel
    mov es:[di], al
@@skip_pixel:
    inc bx
    inc di
ENDM

GENERATE_COLUMN_SPRITE_FAST MACRO
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
    SPRITE_PIXEL
ENDM


GENERATE_SPRITE_FAST MACRO
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
    add bx, 240
    add di, 304
    GENERATE_COLUMN_SPRITE_FAST
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
        add bx, 0fa0h
        dec cx
        jnz @@LoopImgPtr
    
    ;mov bx, VGA_RAM_LOCATION
    mov [VIDEO_BUFFER], bx

    pop si
    pop cx
    ret

   
COPY_VIDEOBUFFER:
    ; copy the contents of the video buffer over to the video memory
    push ax
    push cx
    push dx
    push si
    push di
    push es

    mov ax, VGA_RAM_LOCATION
    mov es, ax
    mov di, 0
    
    push ds
    mov ax, @DATA
    mov ds, ax
    mov ax, [VIDEO_BUFFER]
    mov ds, ax
    xor si, si
    
    cli
    DETECT_VSYNC
    mov cx, 320 * 100
    rep movsw
    sti
    
    pop ds
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret


COPY_VIDEOBUFFER_PARTIAL:
    ; copy the contents of the video buffer over to the video memory
    push ax
    push cx
    push dx
    push si
    push di
    push es

    mov ax, VGA_RAM_LOCATION
    mov es, ax
    ;mov di, 0
    
    push ds
    mov ax, @DATA
    mov ds, ax
    mov ax, [VIDEO_BUFFER]
    mov ds, ax
    ;xor si, si
    
    cli
    DETECT_VSYNC
    mov di, 64 * 320
    mov si, di
    mov cx, 320 * 16 / 2
    rep movsw
    sti
    
    pop ds
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret

CLEAR_VIDEOBUFFER:
    ; clear the videobuffer - copy value in AX all over
    push es
    push cx
    push di
    
    cld
    mov cx, [VIDEO_BUFFER]
    mov es, cx
    xor di, di
    
    mov cx, 320 * 200 / 2
    rep stosw

    pop di
    pop cx
    pop es
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
        ror al, 4
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
    push cx
    
    mov dx, 03c8h
    xor al, al
    out dx, al
    
    mov dx, 03c9h
    mov cx, 256 * 3
    cli
    @@BlackOutLoop:
        mov al, 0
        out dx, al
        loop @@BlackOutLoop

    sti

    pop cx
    pop dx
    pop ax
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
            ror al, 4
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
            ror al, 4
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

COLORCYCLE:
    ; Create a color cycle - one shift at a time. Palette is not preserved!
    ; AL is the color map number
    ; BL is the first color - BH is the last color
    ; Note that the code can handle cycles of up to 85 colors (this is because we count the color range as (bh-bl) * 3 
    ; and assumes it is an 8bits - so bh-bl < 86)
    ; Also note that this does not apply the palette (no call to SET_PALETTE) - this is to allow the code externally to handle it
    pusha
    push es

    ; get the palette offset (and save it)
    POINT_TO_PALETTE
    mov si, ax

    cld
    ; save the last color (make sure that es == ds)
    push bx
    push ds
    pop es

    mov cx, 3
    
    ; add bh * 3 to si
    mov bl, bh
    xor bh, bh
    mov ax, bx
    shl ax, 1
    add ax, bx

    add si, ax
    mov di, offset TEMP_RGB
    rep movsb

    pop bx

    ; To cycle through the color: 
    ;   1. Have di point to the B of the last color
    ;   2. Have si point to the B of the color before
    ;   3. Set std and rep movsb with cx = (bh - bl) * 3
    ; Note that now si points to the byte right after the last color
    dec si
    mov di, si
    sub di, 3
    xchg si, di
    std

    mov cl, bh
    sub cl, bl
    mov ch, cl
    shl cl, 1
    add cl, ch
    xor ch, ch
    rep movsb

    ; Finally let's copy from TEMP the first color
    ; DI should now point to the B of the first color
    mov si, 2 + offset TEMP_RGB
    mov cx, 3
    rep movsb
    
    ; clear DF just in case (we tend to assume it is 0 by default)
    cld
    pop es
    popa
    ret


DISPLAY_TILESCREEN:
    ; DS points to the tiles graphics segment
    ; ES points to the buffer segment
    ; Note that the tiles addresses must be stored in ES: (320*200 + 200)
    pusha

    ; iterate over rows
    ; dl = row count
    ; dh is used as a column/tile count
    xor cx, cx
    xor dx, dx
    xor di, di
    mov bx, 320*200 + 200 - 40
    xor al, al
    @@plot_rows:
        ; if dl mod 16 == 0 we need to add 20
        mov ah, dl
        and ah, 0Fh
        jnz @@same_tile_row
        add bx, 40
    @@same_tile_row:
        ; we also need to add to si the number of rows in the current tileset
        ; we essentially need to keep the value of ah from above multiply by 256 (2^8)
        ; essentially this means using ah to add to the upper bit on si (i.e si + ax)
        mov dh, 20
        @@plot_columns:
            mov si, es:[bx]
            add si, ax
            mov cl, 8
            rep movsw
            add bx, 2
            dec dh
            jnz @@plot_columns

        sub bx, 40
        inc dl
        cmp dl, 160
        jnz @@plot_rows
    
    popa
    ret


DISPLAY_TILESCREEN_FAST:
    ; Attempt at faster tileset generator - same inputs as DISPLAY_TILESCREEN
    pusha

    ; iterate over rows
    ; dl = row count
    ; dh is used as a column/tile count
    ; xor cx, cx
    xor dx, dx
    xor di, di
    mov bx, 320 * 200 + 200 - 40
    mov dh, 20
    @@generate_column_fast:
        mov dl, 10
        @@plot_rows_fast:
            ; this is brute force but the idea is that we know tiles have 16 rows/columns
            ; so we can just repeat the calculation 16 times to avoid having a loop with a counter and jnz
            add bx, 40
            mov si, es:[bx]
            GENERATE_TILE_FAST
            add di, 320 - 16
            dec dl
            jnz @@plot_rows_fast
        
        ; Now bring back di to the beginning of the next column
        sub di, 160 * 320 - 16
        sub bx, 40 * 10 - 2
        dec dh
        jnz @@generate_column_fast
    
    popa
    ret


DISPLAY_METATILE_FAST:
    ; DS points to the tiles graphics segment
    ; ES points to the buffer segment
    ; DI points to the position of top left time
    ; ES:BX points to the tile address - top left time
    pusha

    ; iterate over rows
    ; dl = row count
    ; dh is used as a column/tile count
    xor dx, dx
    mov dh, 2
    @@generate_column_fast:
        mov dl, 2
        @@plot_rows_fast:
            ; this is brute force but the idea is that we know tiles have 16 rows/columns
            ; so we can just repeat the calculation twice to avoid having a loop with a counter and jnz
            mov si, es:[bx]
            GENERATE_TILE_FAST
            add di, 320 - 16
            add bx, 40
            dec dl
            jnz @@plot_rows_fast
        
        ; Now bring back di to the beginning of the next column
        sub di, 32 * 320 - 16
        sub bx, 40 * 2 - 2
        dec dh
        jnz @@generate_column_fast
    
    popa
    ret


DISPLAY_SPRITE:
    ; DS points to the tiles graphics segment
    ; ES points to the buffer segment
    ; BX is the sprite number (0xABh --> A in hex is the row and B in hex is the coloumn)
    ;pusha
    push ax
    push bx
    push cx
    push di

    ; convert bx into a proper shift to sprite position
    shl bx, 4
    shl bh, 4

    ; iterate over rows/columns (16 of each)
    mov ch, 16
    @@plot_sprite_rows:
        mov cl, 16
        @@plot_sprite_columns:
            mov al, ds:[bx]
            or al, al
            jz @@skip_pixel
            mov es:[di], al
        @@skip_pixel:
            inc bx
            inc di
            dec cl
            jnz @@plot_sprite_columns

        add bx, 240
        add di, 304
        dec ch
        jnz @@plot_sprite_rows
    
    ;popa
    pop di
    pop cx
    pop bx
    pop ax
    ret


DISPLAY_SPRITE_FAST:
    ; Fast version of DISPLAY_SPRITE
    push ax
    push bx
    push cx
    push di

    ; convert bx into a proper shift to sprite position
    shl bx, 4
    shl bh, 4

    GENERATE_SPRITE_FAST
    
    pop di
    pop cx
    pop bx
    pop ax
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
    
    call INT9_RESET
    
    jmp ENDPROG