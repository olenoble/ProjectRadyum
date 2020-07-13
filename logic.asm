; ***************************************************************************************
; ***************************************************************************************
; ** Bespoke function for game logic
; ** Require ...

GAME_ESCAPE_KEY         equ 1
RESET_KEY               equ 13h
CHARACTERSPRITE         equ CHARSTYLE
CHARACTER_STEP          equ 7
TOTAL_NUMBER_ROOM       equ 50

CHARACTER_BUFFER_LEFT   equ 3 * 1
CHARACTER_BUFFER_RIGHT  equ 2 * 1
CHARACTER_BUFFER_UP     equ 0
CHARACTER_BUFFER_DOWN   equ -1 * 1

UP_DOOR                 equ 1ch
DOWN_DOOR               equ 1eh
LEFT_DOOR               equ 1fh
RIGHT_DOOR              equ 1dh

.DATA 
CHARSTYLE           db 10h
CHAR_POS_X          dw 160
CHAR_POS_Y          dw 64
CHARACTER_MOVE      dw 0004h

                    ; set to next room if a door was hit
NEXT_ROOM           db 0
ADJUST_POS_X        dw 0
ADJUST_POS_Y        dw 0


                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Password details
                    ; Each password is 3 bytes long (1 letter and 2 numbers)
                    ; for each password, we associate a position XY (stored as a byte)
PASSWORD_LIST       db 27 * 3 dup (0)
PASSWORD_POSITIONS  db 27 dup (0)

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Bottom area
CLUEAREA            db 1ah, 25 dup (1dh), 3ah
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1ch, 25 dup (3dh), 3ch

ORIGINALCLUEAREA    db 1ah, 25 dup (1dh), 3ah
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1ch, 25 dup (3dh), 3ch

PASSCODEAREA        db 1ah, 11 dup (1dh), 3ah
                    db 1bh, 3 dup (1eh), 1fh, 3 dup (1eh), 1fh, 3 dup (1eh), 3bh
                    db 1bh, 3 dup (1eh), 1fh, 3 dup (1eh), 1fh, 3 dup (1eh), 3bh
                    db 1bh, 3 dup (1eh), 1fh, 3 dup (1eh), 1fh, 3 dup (1eh), 3bh
                    db 1ch, 11 dup (3dh), 3ch

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Current room details
ROOM_NUMBER         db 1

ORIGINALROOM        db 08h, 9 dup (04h), 0ch, 8 dup (04h), 09h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 5 dup (0203h), (0303h), 2 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    db 0bh, 18 dup (05h), 0ah

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

                    ; We use the edges to store information (assume that doors can only be on the edges)
TARGETROOM          db 10 dup (0), 1, 9 dup (0)
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    db 20 dup (0)

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; All room specific info

                    ; flags for the room 
                    ;   - bit 0 is set if room is changeable
                    ;   - bit 1 is set if room is completed
                    ;   - bit 2 is set if room generates a password upon solving
ROOM_FLAGS          db 001b
PASSCODE_ROOM       db 0                ; reference to passcode

                    ; Assume one action per door and up to 4 doors per room
                    ; First byte is destination room - higher bit is set to 1 if door is open
                    ; Next byte is reference to password (need to store password somewhere - there can be 27 in total for 3 players)
ACTION_LIST         db 2, 0
                    db 6 dup (0)

ROOM_CLUE           db "Il vous manque une case  Essayez Espace", "$"

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Pre-mapped data

                    ; contains all the position to be called
JUMP_POS            dw 256 dup (0)

                    ; Store the letter mappings - starting from space (20h = 32) - see http://www.asciitable.com/
                    ; Numbers start at 48 - upper case letters at 65 and lower case at 97
LETTER_MAPPING      db 16 dup (1fh)                                         ; various characters
                    db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h     ; numbers
                    db 7 dup (1fh)                                          ; various characters
                    db 00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h     ; upper case letters
                    db 0ah, 0bh, 0ch, 0dh, 0eh, 0fh, 10h, 11h, 12h, 13h 
                    db 14h, 15h, 16h, 17h, 18h, 19h
                    db 6 dup (1fh)                                          ; various characters
                    db 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h     ; lower case letters
                    db 2ah, 2bh, 2ch, 2dh, 2eh, 2fh, 30h, 31h, 32h, 33h 
                    db 34h, 35h, 36h, 37h, 38h, 39h

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; All room data
                    ; 400 bytes per room (20x10 for current and for target room)
                    ; for the info 2 bytes (flags + code) & 8 bytes for actions - 25*3 bytes for the message = 85 bytes per room
ALL_ROOMS_DATA      db 400 * TOTAL_NUMBER_ROOM dup (0)
ALL_ROOMS_INFO      db 85 * TOTAL_NUMBER_ROOM dup (0)

; ************************************************************************************
; ** A few macros
GET_NEXT_ROOM MACRO
    ; get the corresponding action
    xor ah, ah
    mov al, [si + offset TARGETROOM]
    dec al
    shl al, 1
    mov di, offset ACTION_LIST
    add di, ax
    mov al, [di]
    ; remove the open door flag
    and al, 7fh
    mov [NEXT_ROOM], al
ENDM


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
    mov bh, bl
    and bl, 11111100b
    jz @@all_good
    shl ax, 4
    add ax, 16 - CHARACTER_BUFFER_LEFT
    mov [CHAR_POS_X], ax

    ; is it a door ?
    cmp bh, LEFT_DOOR
    jnz @@all_good
    add ax, 16 * 17
    mov [ADJUST_POS_X], ax
    mov ax, [CHAR_POS_Y]
    mov [ADJUST_POS_Y], ax

    GET_NEXT_ROOM

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
    mov bh, bl
    and bl, 11111100b
    jz @@all_good
    shl ax, 4
    sub ax, 16 - CHARACTER_BUFFER_RIGHT
    mov [CHAR_POS_X], ax

    ; is it a door ?
    cmp bh, RIGHT_DOOR
    jnz @@all_good
    sub ax, 16 * 17
    mov [ADJUST_POS_X], ax
    mov ax, [CHAR_POS_Y]
    mov [ADJUST_POS_Y], ax

    GET_NEXT_ROOM

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
    mov bh, bl
    and bl, 11111100b
    jz @@all_good
    and ax, 0FFF0h
    add ax, 16 - CHARACTER_BUFFER_UP
    mov [CHAR_POS_Y], ax

    ; is it a door ?
    cmp bh, UP_DOOR
    jnz @@all_good
    add ax, 16 * 7
    mov [ADJUST_POS_Y], ax
    mov ax, [CHAR_POS_X]
    mov [ADJUST_POS_X], ax

    GET_NEXT_ROOM

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
    mov bh, bl
    and bl, 11111100b
    jz @@all_good
    add ax, 16
    and ax, 0FFF0h
    sub ax, 16 - CHARACTER_BUFFER_DOWN
    mov [CHAR_POS_Y], ax

    ; is it a door ?
    cmp bh, DOWN_DOOR
    jnz @@all_good
    sub ax, 16 * 7
    mov [ADJUST_POS_Y], ax
    mov ax, [CHAR_POS_X]
    mov [ADJUST_POS_X], ax

    GET_NEXT_ROOM

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

    ; we need know to confirm if the room matches the target
    call VALIDATE_ROOM
    call STORE_ROOM_VIDEO_RAM

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

    ;mov si, [CHARACTER_MOVE]
    ;inc si
    ;mov [CHARACTER_MOVE], si

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
    ; AX and SI will be changed (should be ok because it's only called from PRESS_SPACE which saved them in the stack)
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

    ; if all identical - flag the room as done
    mov al, [ROOM_FLAGS]
    or al, 10b
    and al, 11111110b
    mov [ROOM_FLAGS], al

    ; Now that we know the room is solved, we need to check each door
    ; we check each side independently (we can ignore each corner)
    ; top side
    mov si, offset TARGETROOM + 1
    mov cl, 18
    mov ch, 1
    call CHECK_SIDE
    
    ; left side
    mov si, offset TARGETROOM + 20
    mov cl, 9
    mov ch, 20
    call CHECK_SIDE

    ; right side
    mov si, offset TARGETROOM + 19
    mov cl, 9
    mov ch, 20
    call CHECK_SIDE

    ; bottom side
    mov si, offset TARGETROOM + 20*9
    mov cl, 18
    mov ch, 1
    call CHECK_SIDE

    @@end_check:
        pop di
        pop cx
        pop es

    ret


CHECK_SIDE:
    ; subroutine to check doors on side
    ; SI points to the top-left corner of the side of interest
    ; CL is the number of iteration
    ; CH is the SI increment
    xor ah, ah
    @@iter_side:
        mov al, [si]
        or al, al
        jz @@notadoor
        ; if it's a door, check the corresponding action
        dec al
        shl al, 1
        mov di, offset ACTION_LIST
        add di, ax
        inc di
        ; can we open it ?
        mov al, [di]
        or al, al
        jnz @@notadoor
        dec di
        ; now flag as open
        mov al, [di]
        or al, 10000000b
        mov [di], al
        
        ; and change the tile - the target room and current room are 200 bytes away
        sub si, 200
        mov al, [si]
        or al, 10h
        mov [si], al
        add si, 200

    @@notadoor:
        mov al, ch
        add si, ax
        dec cl
        jnz @@iter_side
    ret


GENERATE_CLUEAREA:
    ; Generate the clue area (bottom right)
    ; AX contains the tileset reference
    ; CL contains length of area (in multiples of 8)

    push si
    push dx
    push cx

    mov si, offset CLUEAREA
    mov dx, 104
    mov cl, 27
    call GENERATE_AREA

    pop cx
    pop dx
    pop si
    ret


GENERATE_PASSWORDAREA:
    ; Generate the password area (bottom left)
    ; AX contains the tileset reference
    ; CL contains length of area (in multiples of 8)

    push si
    push dx
    push cx

    mov si, offset PASSCODEAREA
    mov dx, 0
    mov cl, 13
    call GENERATE_AREA

    pop cx
    pop dx
    pop si
    ret


GENERATE_AREA:
    ; Generate one of the areas, either password or clue (bottom left or right)
    ; SI must point to the tile reference in DS
    ; AX contains the tileset reference
    ; DX contains the horizontal shift reference

    ; This is typically a one-off everytime we enter a room - so not time critical
    ; Similar to the room, we store (temporarily) the screen after the video buffer
    ; There is 1535 bytes left (and we only need up to 40*5=200 tiles -> 400 bytes)
    push ax
    push bx
    push cx
    push si
    push di
    push ds

    mov bx, [VIDEO_BUFFER]
    mov es, bx

    mov bh, cl

    ; move the tile config to the end of buffer
    ; this is to avoid using 3 segment (video buffer + screen tiles config + tiles gfx)
    ; tile config is 20 * 10 bytes = 200 bytes (there is 65535 - 64000 = 1535 bytes left)
    mov di, 320 * 200 + 600
    ; I need to multiply cl by 5 (since cl is at most 40 - it can be done on 8bits)
    mov ch, cl
    shl cl, 2
    add cl, ch
    xor ch, ch
    ;mov cx, 27 * 5
    rep movsw

    ; then we can
    ; this time, no need to store it. We can simply generate the sprite in the video buffer
    mov ds, ax
    mov si, 320 * 200 + 600
    mov di, 320 * 160
    add di, dx

    ; precalculate the return after each row
    mov ax, 320
    mov cl, bh
    xor ch, ch
    sub ax, cx
    shl ax, 3

    mov cl, 5
    @@loop_sprite8_cols:
        mov ch, bh
        @@loop_sprite8_rows:
            mov bl, es:[si]
            call DISPLAY_SMALL_SPRITE
            inc si
            add di, 8
            dec ch
            jnz @@loop_sprite8_rows

        add di, ax
        dec cl
        jnz @@loop_sprite8_cols

    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret


SET_ROOM_CLUE:
    ; Set the room clue - we need first to reset the clue area

    pusha    
    push ds
    pop es

    mov si, offset ORIGINALCLUEAREA
    mov di, offset CLUEAREA
    mov cx, 27 * 5
    rep movsb
    
    ; Then we can add the message
    mov si, offset ROOM_CLUE
    mov di, 28 + offset CLUEAREA

    mov cl, 5
    @@loop_cluearea_cols:
        mov ch, 25
        @@loop_cluearea_rows:
            xor ah, ah
            mov al, [si]
            cmp al, 24h
            jz @CLUE_AREA_DONE

            mov bx, offset LETTER_MAPPING
            sub ax, 20h
            add bx, ax
            mov al, [bx]
        @@add_letter:
            mov [di], al
            inc si
            inc di
            dec ch
            jnz @@loop_cluearea_rows

        add di, 2
        dec cl
        jnz @@loop_cluearea_cols


    @CLUE_AREA_DONE:
    popa
    ret