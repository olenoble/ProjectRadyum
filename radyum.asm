.MODEL SMALL
.386

; Constants
LOCALS @@
USE_MUSIC       equ 1    ; if 0 no music
FINAL_ROOM      equ 26

; Adding music library
if USE_MUSIC
    INCLUDELIB      MODPLAY.LIB
    EXTRN           Mod_Driver:FAR,Mod_End_Seg:FAR
endif

; **********************************************
; **********************************************
; ** STACK + DATA here
.STACK 512

.DATA
; player + room - this will be overridden in the ROOM file
PLAYER_NUMBER       db 2    ; 0 to 2
ROOM_START          db 32   ; 0 -> 1 / 1 -> 6 / 2 -> 32

LOADINGSCR          db "INTRO.LBM", 0
COLORMAPS_BCKUP     db 3 * 256 * MAX_LBM_FILES dup (0)
TILESCR             db "GRID.LBM", 0
MOD_FILE            db "MUSIC.MOD", 0
FILEINFO            dw 4 dup (0)
MSG_WAITKEY         db 13, 10, "Appuyer sur une touche...", "$"

; size and pointer to memory allocated to game
; we assign a temporary zone, MAX_LBM_FILES image buffers, 1 video buffers --> all 64kb
; 5 * FFFF divided by 16 (segments) 
DATA_SIZE           dw (MAX_LBM_FILES + 2) * 0FFFFh / 10h ; 4FFFh
DATA_PTR            dw 0
BUFFER_PTR          dw 0
MEM_PTR_END         dw 0
ERR_MEMALLOCATE     db "Could not allocate memory", 13, 10, "$"

; Players colors
PLAYER_COLORS       db 204, 0, 76, 178, 0, 76
                    db 204, 204, 0, 178, 178, 0
                    db 0, 204, 76, 0, 178, 76

; Winning flag
IS_WINNER           db 0

ARBITRARY_MOVE      dw CHARACTER_STEP

; **********************************************
; **********************************************
; ** CODE here

; ** Some macros first
REDRAW_ALL_SCREEN MACRO
    ; this macro will redraw the whole screen - it will change AX
    push ds
    mov ax, [SCREEN_PTR+2]
    mov ds, ax
    call DISPLAY_TILESCREEN_FAST
    call DISPLAY_SPRITE_FAST
    call COPY_VIDEOBUFFER
    pop ds
ENDM


REDRAW_PARTIAL MACRO       
    ; Only redraw the meta tile around the sprite
    push ds
    push bx
    push di

    ; get the position for the top left corner of the character (effectively setting the last 4bits to 0)
    ; we use here the previous pos to override the metatile
    mov bx, [PREVIOUS_POS_Y]
    mov di, [PREVIOUS_POS_X]
    and bx, 0FFF0h
    and di, 0FFF0h
   
    ; we want SI to point to the tile position in the buffer
    ; need to divide CHAR_POS_X by 16 and multiply x2 (since there a word per tile) --> divide by 8
    mov si, di
    shr si, 3
    ; divide CHAR_POS_Y by 16 to get the row in tile
    ; need then to multiply by 40 (20 tiles per row x 2 bytes)
    ; since 40 = 32 + 8 --> bx / 16 * 40 = bx * 2 + bx / 2

    mov ax, bx
    shl ax, 1
    add si, ax
    mov ax, bx
    shr ax, 1 
    add si, ax

    ; now we want DI to point to the top left position in the video
    call MULTIPLYx320
    add di, bx

    ; move SI to BS (and shift at the beginning)
    mov bx, si
    add bx, 320*200 + 200
        
    mov ax, [SCREEN_PTR+2]
    mov ds, ax
    call DISPLAY_METATILE_FAST

    pop di
    pop bx
    call DISPLAY_SPRITE_FAST
    ;call COPY_VIDEOBUFFER_SEMIFAST
    call COPY_VIDEOBUFFER_SUPRATILE
    pop ds    
ENDM


UPDATE_PREVIOUS_POS MACRO
    mov bx, [CHAR_POS_X]
    mov [PREVIOUS_POS_X], bx

    mov bx, [CHAR_POS_Y]
    mov [PREVIOUS_POS_Y], bx
ENDM


.CODE
; ** Include files here
INCLUDE setup.asm
INCLUDE intro.asm
INCLUDE filemgmt.asm
INCLUDE keyb.asm
INCLUDE lbmtool.asm
INCLUDE grafx.asm
INCLUDE logic.asm
INCLUDE roomdata.asm
INCLUDE roominfo.asm
INCLUDE miscdata.asm
INCLUDE passcode.asm
INCLUDE winner.asm

if USE_MUSIC
    include music.asm
endif

; **********************************************
; **********************************************
; ** Main Loop
MAIN PROC

    if USE_MUSIC
        call START_MUSICDRIVER
    endif

    call SETUP
    call INT9_SETUP
    
    ; let's read the ROOM.DAT file to update player+position+achievements
    call USE_ROOM_FILE
    call INTRO

    ; update PREVIOUS_POS_X and PREVIOUS_POS_Y
    UPDATE_PREVIOUS_POS

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

    ; we need now to update the previously found password
    mov byte ptr [DISPLAY_PASSWORD], 0
    call ADD_PREVIOUS_PASSWORDS
    mov byte ptr [DISPLAY_PASSWORD], 1

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

    ; Launch music
    if USE_MUSIC
        call START_MUSIC
    endif

    ; set the right color for the character
    mov ax, 1
    call UPDATE_PLAYER_COLORS

    ; let's backup the palettes as well - so we can easily reset them after a cycle
    mov si, offset COLORMAPS
    mov di, offset COLORMAPS_BCKUP
    push ds
    pop es
    mov cx, 3 * 128 * MAX_LBM_FILES
    rep movsw

    ; Launch the "loading screen" (nothing really loads - but it's a nice intro)
    call LOADING_SCREEN

    ; set up the various functions to move the character
    call GENERATE_JUMP_POSITION

    ; Clear out the video buffer + RAM before we can start
    xor ax, ax
    call CLEAR_VIDEOBUFFER
    call COPY_VIDEOBUFFER

    ; *************************************************************************************************
    ; *************************************************************************************************
    ; ** Room action - this is the main game loop
    mov al, [ROOM_START]
    mov [NEXT_ROOM], al

    @@new_room:
        ; update room number
        mov al, [NEXT_ROOM]
        mov [ROOM_NUMBER], al
        call UPLOAD_CURRENT_ROOM

        ; Store room data in the video buffer (past 64000 first bytes)
        call STORE_ROOM_VIDEO_RAM
        call SET_ROOM_CLUE

        ; Generate clue area and screen
        mov ax, [SCREEN_PTR+2]
        call GENERATE_CLUEAREA
        call GENERATE_PASSWORDAREA
        
        ; generate tileset and sprite
        mov bx, [CHAR_POS_Y]
        mov di, [CHAR_POS_X]
        call MULTIPLYx320
        add di, bx

        xor bh, bh
        mov bl, [CHARSTYLE]

        REDRAW_ALL_SCREEN

        ; reset palette - not really sure why I need to save ES here
        ; but it crashes if I don't ...
        push es
        mov di, offset COLORMAPS
        mov si, offset COLORMAPS_BCKUP
        push ds
        pop es
        mov cx, 3 * 128 * MAX_LBM_FILES
        rep movsw
        pop es

        mov word ptr [FADEWAITITR], 4 - 2 * USE_MUSIC
        mov ax, 1
        call FADEIN

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
        mov al, [CHANGE_IN_ROOM]
        or al, al
        jz @@partial_drawing
            REDRAW_ALL_SCREEN
            jmp @@done_with_drawing
        @@partial_drawing:
            REDRAW_PARTIAL
        @@done_with_drawing:

        ; reset the rawing flag
        mov byte ptr [CHANGE_IN_ROOM], 0

        ; check keyboard
        call READ_KEY_NOWAIT
        or al, al
        jnz @@user_input

        call RESET_CHARACTER_STANCE
        jmp @@wait_for_key_tile

    @@user_input:
        cmp al, GAME_ESCAPE_KEY
        jz @@exit_game_loop

        cmp al, RESET_KEY
        jz @@reset_room

        ; save current pos and move character
        UPDATE_PREVIOUS_POS
        call UPDATE_CHARACTER_STANCE_DIRECTION

        ; check if we changed room
        mov al, [NEXT_ROOM]
        mov ah, [ROOM_NUMBER]
        cmp ah, al
        jz @@still_sameroom

        mov ax, [ADJUST_POS_X]
        mov [CHAR_POS_X], ax

        mov ax, [ADJUST_POS_Y]
        mov [CHAR_POS_Y], ax
        
        xor ax, ax
        mov [ADJUST_POS_X], ax
        mov [ADJUST_POS_Y], ax

        call SAVE_CURRENT_ROOM
        mov word ptr [FADEWAITITR], 4 - 2 * USE_MUSIC
        mov ax, 1
        call FADEOUT
        jmp @@new_room
    
    @@reset_room:
        ; is room already complete / changeable ?
        mov al, [ROOM_FLAGS]
        mov ah, al
        and ah, 1b
        jz @@still_sameroom

        ; reset the rawing flag
        mov byte ptr [CHANGE_IN_ROOM], 1

        push ds
        pop es
        mov si, offset ORIGINALROOM
        mov di, offset CURRENTROOM
        mov cx, 100
        rep movsw
        call STORE_ROOM_VIDEO_RAM

    @@still_sameroom:
        ; need to check here if we reach the end
        ; we need ROOM_NUMBER == 26 and CHAR_POS_X / CHAR_POS_Y around the center of the room
        call CHECK_REACH_END
        jmp @@wait_for_key_tile

@@exit_game_loop:
    mov word ptr [FADEWAITITR], 4 - 2 * USE_MUSIC
    mov ax, 1
    call FADEOUT

    ; this is where we save down the data

    jmp END_GAME

MAIN ENDP


END_GAME:
    ; let's save the game!
    call SAVE_ROOM_FILE

    ; return INT to their former processes
    call INT9_RESET

    ; stop music
    if USE_MUSIC
        call END_MUSICDRIVER
    endif
    
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
    mov word ptr [FADEWAITITR], 2 - USE_MUSIC
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


UPDATE_PLAYER_COLORS:
    ; AL is the palette number
    POINT_TO_PALETTE
    
    push ds
    pop es
    mov di, ax
    add di, 15
    mov si, offset PLAYER_COLORS
    ; need to multiply by 6 the player number to get the right colors
    ; x6 = x4 + x2
    mov al, [PLAYER_NUMBER]
    mov ah, al
    shl al, 2
    shl ah, 1
    add al, ah
    xor ah, ah
    add si, ax

    mov cx, 6
    rep movsb

    ret


CHECK_REACH_END:
    ; are we in the final room ?
    mov al, [ROOM_NUMBER]
    cmp al, FINAL_ROOM
    jne @@not_at_end

    ; if we are, are we within the center ?
    ; check X first - it needs to be between the 36th and 38th (incl.) quarter-tiles
    mov ax, [CHAR_POS_X]
    shr ax, 2
    sub al, 36

	cmp al, 2
	ja @@not_at_end

    ; then check Y - must be between the 16th and 18th (incl.) quarter-tiles
    mov ax, [CHAR_POS_Y]
    shr ax, 2
    sub al, 16

	cmp al, 2
	ja @@not_at_end

    mov byte ptr [IS_WINNER], 1
    mov word ptr [FADEWAITITR], 7 - 2 * USE_MUSIC
    mov ax, 1
    call FADETOWHITE
    jmp END_GAME

    @@not_at_end:
        ret

END MAIN
