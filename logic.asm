; ***************************************************************************************
; ***************************************************************************************
; ** Bespoke function for game logic
; ** Require ...

GAME_ESCAPE_KEY         equ 1
CHARACTERSPRITE         equ CHARSTYLE
CHARACTER_STEP          equ 4

CHARACTER_BUFFER_LEFT   equ 3 * 1
CHARACTER_BUFFER_RIGHT  equ 2 * 1
CHARACTER_BUFFER_UP     equ 0
CHARACTER_BUFFER_DOWN   equ -1 * 1

.DATA 
CHARSTYLE           db 10h
CHAR_POS_X          dw 160
CHAR_POS_Y          dw 64
CHARACTER_MOVE      dw 0004h

CLUEAREA            db 0ah, 25 dup (0dh), 1ah
                    db 0bh, 25 dup (2ah), 1bh
                    db 0bh, 25 dup (2ah), 1bh
                    db 0bh, 25 dup (2ah), 1bh
                    db 0ch, 25 dup (1dh), 1ch

PASSCODEAREA        db 0ah, 25 dup (0dh), 1ah
                    db 0bh, 25 dup (2ah), 1bh
                    db 0bh, 25 dup (2ah), 1bh
                    db 0bh, 25 dup (2ah), 1bh
                    db 0ch, 25 dup (1dh), 1ch


CURRENTROOM         db 08h, 9 dup (04h), 0ch, 8 dup (04h), 09h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 5 dup (0203h), (0303h), 2 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    db 0bh, 18 dup (05h), 0ah

TARGETROOM          db 08h, 9 dup (04h), 0ch, 8 dup (04h), 09h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    db 0bh, 18 dup (05h), 0ah

                    ; flags for the room 
                    ;   - bit 0 is set if room is changeable
                    ;   - bit 1 is set if room is completed
ROOM_FLAGS          db 01b

                    ; contains all the position to be called
JUMP_POS            dw 256 dup (0)

.CODE

GENERATE_JUMP_POSITION:

    push ds
    pop es

    ; All keys defaults to DO_NOTHING
    mov di, offset JUMP_POS
    mov ax, offset DO_NOTHING
    ;xchg al, ah
    mov cx, 256
    rep stosw

    ; now add specific moves
    mov di, offset JUMP_POS

    mov ax, offset MOVE_CHARACTER_LEFT
    mov [di + 4bh * 2], ax

    mov ax, offset MOVE_CHARACTER_RIGHT
    mov [di + 4dh * 2], ax

    mov ax, offset MOVE_CHARACTER_UP
    mov [di + 48h * 2], ax

    mov ax, offset MOVE_CHARACTER_DOWN
    mov [di + 50h * 2], ax

    mov ax, offset PRESS_SPACE
    mov [di + 39h * 2], ax

    ret

RESET_CHARACTER_STANCE:
    ; Reset the character pose if no keys are being pressed
    ; BL is modified
    
    ; problem here is that - we read the keyboard too often and it resets to zero too quickly
    ;xor ax, ax
    mov ax, CHARACTER_STEP
    mov [CHARACTER_MOVE], ax

    mov al, [CHARACTERSPRITE]
    and al, 0F0h
    mov [CHARACTERSPRITE], al
    ret


MOVE_CHARACTER_LEFT:
    ; Displace character to the left

    ; read the sprite - make sure it points to the right direction
    ; and add some movement
    mov al, [CHARACTERSPRITE]
    and al, 0Fh
    inc al
    and al, 11b
    mov ah, 30h

    add al, ah
    mov [CHARACTERSPRITE], al

    ; Now move the position
    mov ax, [CHAR_POS_X]
    sub ax, [CHARACTER_MOVE]
    mov [CHAR_POS_X], ax


    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of middle left side --> we need to have (CHAR_POS_Y + 8) / 16 * 20 + CHAR_POS_X / 16
    push bx
    mov si, [CHAR_POS_Y]
    add si, 8
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    add ax, CHARACTER_BUFFER_LEFT
    shr ax, 4
    add si, ax

    mov bl, [si + offset CURRENTROOM]
    and bl, 11111100b
    jz @@all_good
    shl ax, 4
    add ax, 16 - CHARACTER_BUFFER_LEFT
    mov [CHAR_POS_X], ax

    @@all_good:
        pop bx
        pop si
        pop ax

    ret


MOVE_CHARACTER_RIGHT:
    ; Displace character to the right

    ; read the sprite - make sure it points to the right direction
    ; and add some movement
    mov al, [CHARACTERSPRITE]
    and al, 0Fh
    inc al
    and al, 11b
    mov ah, 40h

    add al, ah
    mov [CHARACTERSPRITE], al

    ; Now move the position
    mov ax, [CHAR_POS_X]
    add ax, [CHARACTER_MOVE]
    mov [CHAR_POS_X], ax

    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of middle right side --> we need to have (CHAR_POS_Y + 8) / 16 * 20 + (CHAR_POS_X + 16) / 16
    push bx
    mov si, [CHAR_POS_Y]
    add si, 8
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    add ax, 16 + CHARACTER_BUFFER_RIGHT
    shr ax, 4
    add si, ax

    mov bl, [si + offset CURRENTROOM]
    and bl, 11111100b
    jz @@all_good
    shl ax, 4
    sub ax, 16 - CHARACTER_BUFFER_RIGHT
    mov [CHAR_POS_X], ax

    @@all_good:
        pop bx
        pop si
        pop ax

    ret


MOVE_CHARACTER_UP:
    ; Displace character to the up

    ; read the sprite - make sure it points to the right direction
    ; and add some movement
    mov al, [CHARACTERSPRITE]
    and al, 0Fh
    inc al
    and al, 11b
    mov ah, 20h

    add al, ah
    mov [CHARACTERSPRITE], al

    ; Now move the position
    mov ax, [CHAR_POS_Y]
    sub ax, [CHARACTER_MOVE]
    mov [CHAR_POS_Y], ax

    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of upper middle side --> we need to have CHAR_POS_Y / 16 * 20 + (CHAR_POS_X + 8) / 16
    push bx
    mov si, ax
    add si, CHARACTER_BUFFER_UP
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    mov bx, [CHAR_POS_X]
    add bx, 8
    shr bx, 4
    add si, bx

    mov bl, [si + offset CURRENTROOM]
    and bl, 11111100b
    jz @@all_good
    and ax, 0FFF0h
    add ax, 16 - CHARACTER_BUFFER_UP
    mov [CHAR_POS_Y], ax

    @@all_good:
        pop bx
        pop si
        pop ax

    ret


MOVE_CHARACTER_DOWN:
    ; Displace character to the up

    ; read the sprite - make sure it points to the right direction
    ; and add some movement
    mov al, [CHARACTERSPRITE]
    and al, 0Fh
    inc al
    and al, 11b
    mov ah, 10h

    add al, ah
    mov [CHARACTERSPRITE], al

    ; Now move the position
    mov ax, [CHAR_POS_Y]
    add ax, [CHARACTER_MOVE]
    mov [CHAR_POS_Y], ax

    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of lower middle side --> we need to have (CHAR_POS_Y + 16) / 16 * 20 + (CHAR_POS_X + 8) / 16
    push bx
    mov si, ax
    add si, 16 + CHARACTER_BUFFER_DOWN
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    mov bx, [CHAR_POS_X]
    add bx, 8
    shr bx, 4
    add si, bx

    mov bl, [si + offset CURRENTROOM]
    and bl, 11111100b
    jz @@all_good
    add ax, 16
    and ax, 0FFF0h
    sub ax, 16 - CHARACTER_BUFFER_DOWN
    mov [CHAR_POS_Y], ax

    @@all_good:
        pop bx
        pop si
        pop ax

    ret


PRESS_SPACE:
    ; check the room can still change
    mov al, [ROOM_FLAGS]
    and al, 1b
    jz @@done_press_space

    ; get position - roughly around where the waist is
    mov si, [CHAR_POS_Y]
    add si, 11          ; move to waist
    shr si, 4
    mov ax, si
    shl si, 4
    shl ax, 2
    add si, ax

    mov ax, [CHAR_POS_X]
    add ax, 8
    shr ax, 4
    add si, ax

    ; now get tile
    mov al, [si + offset CURRENTROOM]
    xor al, 1b
    mov [si + offset CURRENTROOM], al
    call STORE_ROOM_VIDEO_RAM

    ; we need know to confirm if the room matches the target
    call VALIDATE_ROOM

    @@done_press_space:
        pop si
        pop ax

    ret


DO_NOTHING:
    pop si
    pop ax
    ret


UPDATE_CHARACTER_STANCE_DIRECTION:

    push ax
    push si

    mov si, [CHARACTER_MOVE]
    inc si
    mov [CHARACTER_MOVE], si

    xor ah, ah
    mov si, offset JUMP_POS
    shl ax, 1
    add si, ax
    mov ax, [si]

    jmp ax

    ; That bit should not be used since the functions have a ret, but just in case
    pop si
    pop ax
    ret


STORE_ROOM_VIDEO_RAM:
    pusha
    mov ax, [VIDEO_BUFFER]
    mov es, ax

    ; move the tile config to the end of buffer
    ; this is to avoid using 3 segment (video buffer + screen tiles config + tiles gfx)
    ; tile config is 20 * 10 bytes = 200 bytes (there is 65535 - 64000 = 1535 bytes left)
    mov si, offset CURRENTROOM
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
        ; to convert the tile number into a position - easy now if we use x256
        mov al, es:[si]
        xor ah, ah
        shl ax, 4
        shl ah, 4
        stosw
        inc si
        dec cx
        jnz @@loop_tileaddresses

    pop ds
    popa
    ret


VALIDATE_ROOM:
    ; Check whether the current room matches the target room
    ; ignore the boundaries - we assume all doors are on boundaries (whether they are open is not a target)
    ; so we start on the second tile of the first row
    ; AX and SI will be changed
    push es
    push cx
    push di

    mov si, offset CURRENTROOM
    add si, 21
    mov di, offset TARGETROOM
    add di, 21

    push ds
    pop es
    
    ; checking each row and adding the remainder of cx (should be zero after each line)
    ; there are 9 words in each row if we ignore the boundaries
    mov al, 8
    @@check_row:
        mov cx, 9
        repe cmpsw
        ; if cx is not zero, a difference was found somewhere
        or cx, cx        
        jnz @@end_check

        ; if zero, let's move to the next row
        ; si and di should be on the boundary of the previous row
        add si, 2
        add di, 2
        dec al
        jnz @@check_row

    mov al, 10b
    mov [ROOM_FLAGS], al
    
    @@end_check:
        pop di
        pop cx
        pop es

    ret

GENERATE_CLUEAREA:
    ; Generate the clue area (bottom right)
    ; This is typically a one-off everytime we enter a room - so not time critical
    ; Similar to the room, we store (temporarily) the screen after the video buffer
    ; There is 1535 bytes left (and we only need up to 40*5=200 tiles -> 400 bytes)
;    pusha
;    push ds

    mov bx, [VIDEO_BUFFER]
    mov es, bx

    ; move the tile config to the end of buffer
    ; this is to avoid using 3 segment (video buffer + screen tiles config + tiles gfx)
    ; tile config is 20 * 10 bytes = 200 bytes (there is 65535 - 64000 = 1535 bytes left)
    mov si, offset CLUEAREA
    mov di, 320 * 200 + 600
    mov cx, 27 * 5
    rep movsw

    ; then we can
    ; this time, no need to store it. We can simply generate the sprite in the video buffer
    mov ds, ax
    mov si, 320 * 200 + 600
    mov di, 320 * 160 + 104

    mov cl, 5
    @@loop_sprite8_cols:
        mov ch, 27
        @@loop_sprite8_rows:
            mov bl, es:[si]
            call DISPLAY_SMALL_SPRITE
            inc si
            add di, 8
            dec ch
            jnz @@loop_sprite8_rows
        add di, 256 - 27 * 8
        dec cl
        jnz @@loop_sprite8_cols

    pop ds
    popa
    ret

RESET_CLUEAREA:
    ret
