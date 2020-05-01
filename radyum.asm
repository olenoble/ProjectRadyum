.MODEL SMALL
.386


; TODO --> Cycle of colors on the intro file

.STACK 4096

.DATA
LOADINGSCR  db "c:\INTRO.LBM", 0
;TILESCR     db "c:\TILE.LBM", 0
TILESCR     db "c:\GRIDT2.LBM", 0

FILEINFO    dw 4 dup (0)

MSG_WAITKEY db 13, 10, "Press Any Key...", "$"

; size and pointer to memory allocated to game
; we assign a temporary zone, MAX_LBM_FILES image buffers, 1 video buffers --> all 64kb
; 5 * FFFF divided by 16 (segments) 
DATA_SIZE           dw (MAX_LBM_FILES + 2) * 0FFFFh / 10h ; 4FFFh
DATA_PTR            dw 0
BUFFER_PTR          dw 0
MEM_PTR_END         dw 0
ERR_MEMALLOCATE     db "Could not allocate memory", 13, 10, "$"
SCREENTEST          db 08h, 9 dup (04h), 0ch, 8 dup (04h), 09h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    db 0bh, 18 dup (05h), 0ah

SCREENTEST2          db 08h, 9 dup (04h), 0ch, 8 dup (04h), 09h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 5 dup (0203h), (0303h), 2 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    db 0bh, 18 dup (05h), 0ah

; **********************************************
; **********************************************
; ** Include files here
INCLUDE setup.asm
INCLUDE intro.asm
INCLUDE filemgmt.asm
INCLUDE keyb.asm
INCLUDE lbmtool.asm
INCLUDE grafx.asm

.CODE

; **********************************************
; **********************************************
; ** Main Loop
MAIN PROC

    call SETUP
    call INT9_SETUP
    call INTRO

    ; set DF to 0 by default
    cld

    ; now assign all the necessary memory
    mov bx, [DATA_SIZE]
    mov ah, 48h
    int 21h
    jc NOT_ENOUGH_MEMORY

    ; we place the temporary zone at the beginning
    ; then we start the data area 64kb after
    mov bx, ax
    mov [BUFFER_PTR], bx
    add bx, 0fffh
    mov [DATA_PTR], bx
    
    call ALLOCATE_IMG_PTR
    mov [MEM_PTR_END], bx

    ; open the loading screen file
    mov dx, offset LOADINGSCR
    mov di, offset FILEINFO
    mov ax, [BUFFER_PTR]
    mov [di+6], ax
    call OPEN_FILE

    ; decompress the LBM file
    mov si, offset FILEINFO
    call EXTRACT_IMG

    ; open tile screen and decompress
    mov dx, offset TILESCR
    mov di, offset FILEINFO
    mov ax, [BUFFER_PTR]
    mov [di+6], ax
    call OPEN_FILE
    mov si, offset FILEINFO
    call EXTRACT_IMG
    
    ; Then print a little message
    mov dx, offset MSG_WAITKEY
    mov ah, 9
    int 21h
    call READ_KEY_WAIT
    
    ; start graphic mode and display
    call SWITCH_TO_320x200
    call BLACKOUT
    
    ; ********** FIRST IMAGE *****************************
    ; Now move the image to the buffer
    push ds
    mov ax, [VIDEO_BUFFER]
    mov es, ax
    mov ax, [SCREEN_PTR]
    mov ds, ax
    
    xor di, di
    xor si, si
    mov cx, 320 * 200
    rep movsb
    pop ds
    
    call COPY_VIDEOBUFFER

    xor ax, ax
    call FADEIN

    ; Insert here a cycle color loop
    mov cl, 0
    @@wait_for_key:
        DETECT_VSYNC
        ; for this cycle, only cycle every 4 vsync
        mov ch, cl
        and ch, 11b
        jnz @@no_cycle_1
        mov bx, (12 * 16 - 1) * 16 * 16 + (11 * 16)
        xor al, al
        call COLORCYCLE
        call SET_PALETTE
    @@no_cycle_1:
        mov ch, cl
        and ch, 111b
        jnz @@no_cycle_2
        mov bx, (8 * 16 - 1) * 16 * 16 + (7 * 16)
        xor al, al
        call COLORCYCLE
        call SET_PALETTE
    @@no_cycle_2:
        inc cl
        call READ_KEY_NOWAIT
        or al, al
        jz @@wait_for_key
    
    ; and fadeout - but let's have a faster one
    mov word ptr [FADEWAITITR], 2
    xor ax, ax
    call FADEOUT

    xor ax, ax
    call CLEAR_VIDEOBUFFER
    call COPY_VIDEOBUFFER

    ; *************************************************************************************************
    ; *************************************************************************************************
    ; generate a dummy screen
    mov ax, [VIDEO_BUFFER]
    mov es, ax

    ; move the tile config to the end of buffer
    ; this is to avoid using 3 segment (video buffer + screen tiles config + tiles gfx)
    ; tile config is 20 * 10 bytes = 200 bytes (there is 65535 - 64000 = 1535 bytes left)
    mov si, offset SCREENTEST2
    mov di, 320 * 200
    mov cx, 100
    rep movsw

    ; then we can add the corresponding position in the image for each tile
    ; this takes an additional 400 bytes (since address is a word)
    push ds
    mov ds, ax
    mov si, 320*200
    mov di, 320*200+200
    mov cx, 200
    @@loop_tileaddresses:
        ; to convert the tile number into a position
        ; old code used if we need to multiply by 320
        ;mov bl, es:[si]
        ;xor bh, bh
        ;mov ax, bx
        ;and ax, 0fff0h
        ;shl ax, 2
        ;shl bx, 4
        ;add ax, bx
        ; easier now if we x256
        mov al, es:[si]
        shl ax, 4
        shl ah, 4
        stosw
        inc si
        dec cx
        jnz @@loop_tileaddresses
    pop ds

    ; Now we need to fill up the buffer with the tiles
    ; DS:SI points to the tiles graphics
    ; ES:DI points to the buffer
    ; ES:BX points to the tile address table
    push ds
    mov ax, [SCREEN_PTR+2]
    mov ds, ax

    ; iterate over rows
    ; dl = row count
    ; dh is used as a column/tile count
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

    pop ds

    call COPY_VIDEOBUFFER
    mov word ptr [FADEWAITITR], 5
    mov ax, 1
    call FADEIN
    ;call SET_PALETTE
    call READ_KEY_WAIT

    mov word ptr [FADEWAITITR], 5
    mov ax, 1
    call FADEOUT


TEMPEND:
    jmp END_GAME


MAIN ENDP


END_GAME:
    ; return INT to their former processes
    call INT9_RESET
    
    ; reset the screen and quit
    call RESET_SCREEN
    jmp ENDPROG


NOT_ENOUGH_MEMORY:
    ; This routine is called if DOS can't allocate the requested memory    
    call RESET_SCREEN

    mov dx, offset ERR_MEMALLOCATE
    mov ah, 9
    int 21h
    
    call INT9_RESET   
    jmp ENDPROG


END MAIN

