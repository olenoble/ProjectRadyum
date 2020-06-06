; ***************************************************************************************
; ***************************************************************************************
; ** Bespoke function for game logic
; ** Require ...

GAME_ESCAPE_KEY         equ 1
CHARACTERSPRITE         equ CHARSTYLE
CHARACTER_STEP          equ 4

CHARACTER_BUFFER_LEFT   equ 3 * 0
CHARACTER_BUFFER_RIGHT  equ 2 * 0
CHARACTER_BUFFER_UP     equ 0
CHARACTER_BUFFER_DOWN   equ 0

.DATA 
CHARSTYLE           db 10h
CHAR_POS_X          dw 160
CHAR_POS_Y          dw 64


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
    sub ax, CHARACTER_STEP
    mov [CHAR_POS_X], ax


    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of upper left corner --> we need to have CHAR_POS_Y / 16 * 20 + CHAR_POS_X / 16
    push bx
    mov si, [CHAR_POS_Y]
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    add ax, CHARACTER_BUFFER_LEFT
    shr ax, 4
    add si, ax

    mov bx, [si + offset CURRENTROOM]
    and bx, 11111100b
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
    add ax, CHARACTER_STEP
    mov [CHAR_POS_X], ax

    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of upper right corner --> we need to have CHAR_POS_Y / 16 * 20 + (CHAR_POS_X + 16) / 16
    push bx
    mov si, [CHAR_POS_Y]
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    add ax, 16 + CHARACTER_BUFFER_RIGHT
    shr ax, 4
    add si, ax

    mov bx, [si + offset CURRENTROOM]
    and bx, 11111100b
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
    sub ax, CHARACTER_STEP
    mov [CHAR_POS_Y], ax

    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of upper left corner --> we need to have CHAR_POS_Y / 16 * 20 + (CHAR_POS_X) / 16
    push bx
    mov si, ax
    add si, CHARACTER_BUFFER_UP
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    mov bx, [CHAR_POS_X]
    shr bx, 4
    add si, bx

    mov bx, [si + offset CURRENTROOM]
    and bx, 11111100b
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
    add ax, CHARACTER_STEP
    mov [CHAR_POS_Y], ax

    ; Collision detection - did we hit a wall ?
    ; Find corresponding tile of bottom left corner --> we need to have (CHAR_POS_Y + 16) / 16 * 20 + (CHAR_POS_X) / 16
    push bx
    mov si, ax
    add si, 16 + CHARACTER_BUFFER_DOWN
    shr si, 4
    mov bx, si
    shl si, 4
    shl bx, 2
    add si, bx

    mov bx, [CHAR_POS_X]
    shr bx, 4
    add si, bx

    mov bx, [si + offset CURRENTROOM]
    and bx, 11111100b
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



UPDATE_CHARACTER_STANCE_DIRECTION_old:
    ; ********************************************************************
    ; Move player - Using key pressed passed in AL
    ; scan code: down = 50h - up = 48h - left = 4bh - right = 4dh
    ; space 39h ...
    ;left  01001011
    ;right 01001101
    ;up    01001000
    ;down  01010000
    push ax
    push bx
    push cx
    push dx

    ; Check direction (need to improve on this a bit)
    xor dx, dx
    mov bl, [CHARACTERSPRITE]
    mov bh, bl
    and bh, 0F0h
    and bl, 0Fh

    cmp al, 4bh
    jnz @@not_left
    mov dh, -1
    inc bl
    and bl, 11b
    mov bh, 30h
    jmp @@char_move

    @@not_left:
    cmp al, 4dh
    jnz @@not_right
    mov dh, 1
    inc bl
    and bl, 11b
    mov bh, 40h
    jmp @@char_move

@@not_right:
    cmp al, 48h
    jnz @@not_up
    mov dl, -1
    inc bl
    and bl, 11b
    mov bh, 20h
    jmp @@char_move

@@not_up:
    cmp al, 50h
    jnz @@not_down
    mov dl, 1
    inc bl
    and bl, 11b
    mov bh, 10h
    jmp @@char_move

@@not_down:
    xor bl, bl

@@char_move:
    add bl, bh
    mov [CHARSTYLE], bl

    ; Retrieve current position
    mov bx, [CHAR_POS_X]
    mov cx, [CHAR_POS_Y]

    ; Update X move (move stored in DH)
    mov al, dh
    cbw
    shl ax, CHARACTER_STEP
    add bx, ax

    ; Check if we hit a wall
    ; to find corresponding tile of upper left corner, we need to have CHAR_POS_Y / 16 * 20 + CHAR_POS_X / 16
    ; 20 / 16 = 1 + 1/4 (2 shift right + add original value)
    mov si, cx
    shr si, 2
    add si, cx

    mov di, bx
    ; if we moved right, we need to check the right corner
    cmp ax, 0
    jl @@moving_left
    add di, 16 - 6
@@moving_left:
    add di, 5
    shr di, 4
    add si, di

    mov di, [si + offset CURRENTROOM]
    and di, 11111100b
    jz @@all_good
    sub bx, ax

@@all_good:
    ; Update Y move
    mov al, dl
    cbw
    shl ax, CHARACTER_STEP
    add cx, ax

    ; Check if we hit a wall
    mov si, cx
    cmp ax, 0
    jl @@moving_up
    add si, 16
@@moving_up:
    shr si, 2
    add si, cx

    ;mov di, bx
    ;shr di, 4
    ;add si, di

    ;mov di, [si + offset CURRENTROOM]
    ;and di, 11111100b
    ;jz @@all_good2
    ;sub cx, ax

@@all_good2:

    mov [CHAR_POS_X], bx
    mov [CHAR_POS_Y], cx

@@end_actions:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
