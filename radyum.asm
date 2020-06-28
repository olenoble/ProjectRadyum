.MODEL SMALL
.386

; Constants
LOCALS @@

; **********************************************
; **********************************************
; ** STACK + DATA here
.STACK 4096

.DATA
LOADINGSCR  db "c:\INTRO.LBM", 0
TILESCR     db "c:\GRIDT5.LBM", 0

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


; **********************************************
; **********************************************
; ** CODE here
.CODE

; ** Include files here
INCLUDE setup.asm
INCLUDE intro.asm
INCLUDE filemgmt.asm
INCLUDE keyb.asm
INCLUDE lbmtool.asm
INCLUDE grafx.asm
INCLUDE logic.asm

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
    
    ; Launch the "loading screen" (nothing really loads - but it's a nice intro)
    ;call LOADING_SCREEN

    ; set up the various functions to move the character
    call GENERATE_JUMP_POSITION

    ; Clear out the video buffer + RAM before we can start
    xor ax, ax
    call CLEAR_VIDEOBUFFER
    call COPY_VIDEOBUFFER

    ; *************************************************************************************************
    ; *************************************************************************************************
    ; ** Room action

    ; Store room data in the video buffer (past 64000 first bytes)
    call STORE_ROOM_VIDEO_RAM
    call SET_ROOM_CLUE

    ; Generate clue area and screen
    mov ax, [SCREEN_PTR+2]
    call GENERATE_CLUEAREA
    call GENERATE_PASSWORDAREA
    
    push ds
    mov ds, ax    
    call DISPLAY_TILESCREEN_FAST
    pop ds

    ; Fade in is screwed here - check why
    ;mov word ptr [FADEWAITITR], 4
    mov ax, 1
    ;call FADEIN
    call SET_PALETTE

    @@wait_for_key_tile:

        ; color cycle if room is completed
        mov al, [ROOM_FLAGS]
        and al, 10b
        jz @@uncompleted_room
        mov ax, 1
        mov bx, (10 * 16 - 1) * 16 * 16 + (9 * 16)
        call COLORCYCLE
        call SET_PALETTE

    @@uncompleted_room:

        mov bx, [CHAR_POS_Y]
        mov di, [CHAR_POS_X]
        call MULTIPLYx320
        add di, bx

        xor bh, bh
        mov bl, [CHARSTYLE]

        ; refresh screen and display sprite
        push ds
        mov ax, [SCREEN_PTR+2]
        mov ds, ax
        call DISPLAY_SPRITE_FAST
        call COPY_VIDEOBUFFER
        ;call COPY_VIDEOBUFFER_PARTIAL

        ; redraw the meta tile around the character
        pop ds
        push bx
        mov bx, [CHAR_POS_Y]
        mov di, [CHAR_POS_X]
        and bx, 0FFF0h
        and di, 0FFF0h

        push ds
        mov ax, [SCREEN_PTR+2]
        mov ds, ax    
        
        ; need to divide CHAR_POS_X by 16 and multiply x2 --> divide by 8
        mov si, di
        shr si, 3
        ; divide bx by 16 to get the row in tile
        ; need then to multiply by 40 (20 tiles per row x 2 bytes)
        ; since 40 = 32 + 8 --> bx / 16 * 40 = bx * 2 + bx / 2

        mov ax, bx
        shl ax, 1
        add si, ax
        mov ax, bx
        shr ax, 1 
        add si, ax

        call MULTIPLYx320
        add di, bx
        mov bx, si
        add bx, 320*200 + 200
        call DISPLAY_METATILE_FAST
        pop ds
        pop bx

        ; check keyboard
        call READ_KEY_NOWAIT
        ;in al, 60h
        ;mov ah, al
        ;and ah, 80h
        or al, al
        jnz @@user_input
        call RESET_CHARACTER_STANCE
        jmp @@wait_for_key_tile

    @@user_input:
        cmp al, GAME_ESCAPE_KEY
        jz @@exit_game_loop

        call UPDATE_CHARACTER_STANCE_DIRECTION
        jmp @@wait_for_key_tile

@@exit_game_loop:
    mov word ptr [FADEWAITITR], 4
    mov ax, 1
    call FADEOUT
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


LOADING_SCREEN:
    ; This is the loading screen - with a nice color loop just for fun
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
    ret


MULTIPLYx320:
    ; Input BX (value to multiply)
    ; Output BX = BX * 320
    ; Note that output is 16bits so BX < 65535 / 320 --> BX < 205
    push ax
    mov ax, bx
    shl ax, 8
    shl bx, 6
    add bx, ax
    pop ax
    ret


END MAIN
