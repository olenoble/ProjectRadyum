; ***************************************************************************************
; ***************************************************************************************
; ** Bespoke function for game logic
; ** Require grafx.asm & roomdata.asm & roominfo.asm & miscdata.asm

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
                    ; Current room details
ROOM_NUMBER         db 0

ORIGINALROOM        db 200 dup (0)
CURRENTROOM         db 200 dup (0)
TARGETROOM          db 200 dup (0)

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; All room specific info
                    ; all the data below must remain in that order!

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
ROOM_CLUE           db 85 dup (0)

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Pre-mapped data
                    ; contains all the position to be called
JUMP_POS            dw 256 dup (0)


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


GET_PASSWORD_REFERENCE MACRO
    ; get the corresponding action
    xor ah, ah
    mov al, [si + offset TARGETROOM]
    dec al
    shl al, 1
    mov di, offset ACTION_LIST
    add di, ax
    inc di
    mov al, [di]
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

    ; Password management here
    ; cmp bh, LEFT_DOOR_CLOSED ; is it a closed door ?
    ; then  GET_PASSWORD_REFERENCE if it is closed
    ; if al not zero --> request password (and maybe open door if needed)
    
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

    ; now get tile - little trick, only tile 2 and 3 can be swapped
    ; tile 0 and 1 can't (to be used to fix certain tiles)
    mov al, [si + offset CURRENTROOM]
    mov ah, al
    and ah, 10b
    shr ah, 1
    ;xor al, 1b
    xor al, ah
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
        mov cx, 19
        repe cmpsb
        ; if cx is not zero, a difference was found somewhere
        or cx, cx        
        jnz @@end_check

        ; if zero, let's move to the next row
        ; si and di should be on the boundary of the previous row
        add si, 1
        add di, 1
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

    ; Now check if there is a new password attributed after solving
    mov si, offset PASSCODE_ROOM
    mov al, [si]
    or al, al
    jz @@end_check
    call ADD_NEW_PASSWORD

    @@end_check:
        pop di
        pop cx
        pop es

    ret


ADD_NEW_PASSWORD:
    ; subroutine to add a new password if needed
    ; AL contains the reference to the password
    pusha
    ;mov al, 17
    ; 8 bytes per password - SI points to the password
    dec al
    shl al, 3
    inc al
    xor ah, ah
    mov si, offset ALL_PASSCODE
    add si, ax

    ; make sure we write it at the right place
    ; AX will contain the row/columns (AH row and AL column)
    ; and DI will point to the right position
    mov di, 14 + offset PASSCODEAREA
    mov ax, [si + 4]
    
    ; we need to multiply AL by 4 (easy)
    ; and AH by 13 (harder) --> x13 = x8 + x4 + x1
    xor cx, cx
    dec al
    shl al, 2
    mov cl, al

    dec ah
    mov al, ah
    shl ah, 2   ; x4
    add al, ah  ; adding on top of x1
    shl ah, 1   ; x8 now
    add al, ah
    add cl, al
    add di, cx

    ; now update the password area
    push ds
    pop es
    mov cl, 3
    @@update_password_area:
        xor ah, ah
        lodsb
        mov bx, offset LETTER_MAPPING
        sub ax, 20h
        add bx, ax
        mov al, [bx]
        stosb
        dec cl
        jnz @@update_password_area

    mov ax, [SCREEN_PTR+2]
    call GENERATE_PASSWORDAREA

    popa
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
    ; CL contains length of area (in multiples of 8)

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

    mov cl, 3
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


UPLOAD_CURRENT_ROOM:
    pusha

    push ds
    pop es

    ; first update the original / target room
    mov al, [ROOM_NUMBER]
    dec al
    ; shift by x400 = x256 + x144 = x256 + x128 + x16
    ; x256 is easy since it means moving al to ah
    mov ah, al    
    mov bl, al
    xor al, al
    xor bh, bh
    shl bx, 7       ; x128
    add ax, bx
    shr bx, 3       ; /128 and x16, i.e. /8
    add ax, bx

    mov si, offset ALL_ROOMS_DATA
    add si, ax
    mov di, offset ORIGINALROOM
    mov cx, 100
    rep movsw

    mov di, offset TARGETROOM
    mov cx, 100
    rep movsw

    ; copy over original room to current room
    mov si, offset ORIGINALROOM
    mov di, offset CURRENTROOM
    mov cx, 100
    rep movsw
 
    ; now all the room information
    mov al, [ROOM_NUMBER]
    dec al
    ; we need to multiply x85. This one is tricky = x64 + x21 = x64 + x16 + x4 + x1
    xor ah, ah
    mov bx, ax
    shl ax, 6       ; x64
    add ax, bx      ; + x1
    shl bx, 2       
    add ax, bx      ; + x4
    shl bx, 2
    add ax, bx      ; + x16
    mov si, offset ALL_ROOMS_INFO
    add si, ax
    mov di, offset ROOM_FLAGS
    mov cx, 85
    rep movsb

    popa
    ret

SAVE_CURRENT_ROOM:
    ; this is basically the reverse of UPLOAD_CURRENT_ROOM - we essentially exchange si and di
    ; it stores the current room data, if we are leaving it
    pusha

    push ds
    pop es

    ; first update the original / target room
    mov al, [ROOM_NUMBER]
    dec al
    ; shift by x400 = x256 + x144 = x256 + x128 + x16
    ; x256 is easy since it means moving al to ah
    mov ah, al    
    mov bl, al
    xor al, al
    xor bh, bh
    shl bx, 7       ; x128
    add ax, bx
    shr bx, 3       ; /128 and x16, i.e. /8
    add ax, bx

    mov di, offset ALL_ROOMS_DATA
    add di, ax
    mov si, offset ORIGINALROOM
    ; do we use original or target room ?
    mov al, [ROOM_FLAGS]
    and al, 10b
    jz @@use_original_room
    mov si, offset CURRENTROOM
    @@use_original_room:
    mov cx, 100
    rep movsw
 
    ; now all the room information
    mov al, [ROOM_NUMBER]
    dec al
    ; we need to multiply x85. This one is tricky = x64 + x21 = x64 + x16 + x4 + x1
    xor ah, ah
    mov bx, ax
    shl ax, 6       ; x64
    add ax, bx      ; + x1
    shl bx, 2       
    add ax, bx      ; + x4
    shl bx, 2
    add ax, bx      ; + x16
    mov di, offset ALL_ROOMS_INFO
    add di, ax
    mov si, offset ROOM_FLAGS
    mov cx, 85
    rep movsb

    popa
    ret

