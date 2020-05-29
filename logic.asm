; ***************************************************************************************
; ***************************************************************************************
; ** Bespoke function for game logic
; ** Require ...

GAME_ESCAPE_KEY   equ 1
REFDATA   equ CHARSTYLE

.DATA 
TEMP    db 0
CHARSTYLE           db 10h
CHAR_POS_X          dw 160
CHAR_POS_Y          dw 64

.CODE

RESET_CHARACTER_STANCE:
    ; Reset the character pose if no keys are being pressed
    ; BL is modified
    mov bl, [REFDATA]
    and bl, 0F0h
    mov [REFDATA], bl
    ret

UPDATE_CHARACTER_STANCE_DIRECTION:
    ; ********************************************************************
    ; move player
    ; scan code: down = 50h - up = 48h - left = 4bh - right = 4dh
    ; space 39h ...
    ;left  01001011
    ;right 01001101
    ;up    01001000
    ;down  01010000

    xor dx, dx
    mov bl, [CHARSTYLE]
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

    mov al, dh
    cbw
    
    mov bx, [CHAR_POS_X]
    shl ax, CHARACTER_STEP
    add bx, ax
    mov [CHAR_POS_X], bx

    mov al, dl
    cbw
    
    mov bx, [CHAR_POS_Y]
    shl ax, CHARACTER_STEP
    add bx, ax
    mov [CHAR_POS_Y], bx

    ret