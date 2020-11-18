; ***************************************************************************************
; ***************************************************************************************
; ** Just some final stuff for the winners

.DATA
WINNING_MSG     db "Felicitations - Vous avez atteint la sortie de mon escape game facon 80s.", 13, 10
                db "Vous avez resolu tous les puzzles et merite votre recompense:", 13, 10, 13, 10
                db 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 020h, 0dch, 020h, 020h, 020h, 020h, 0dch, 020h, 0dch, 0dch, 0dch, 0dch, 020h, 0dch, 0dch, 0dch, 020h, 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 13, 10
                db 020h, 0dbh, 020h, 0dch, 0dch, 0dch, 020h, 0dbh, 020h, 0dfh, 0dbh, 0dch, 0dbh, 0dfh, 020h, 0dfh, 0dbh, 020h, 0dfh, 020h, 020h, 0dfh, 0dch, 0dch, 0dch, 020h, 020h, 0dbh, 020h, 0dch, 0dch, 0dch, 020h, 0dbh, 13, 10
                db 020h, 0dbh, 020h, 0dbh, 0dbh, 0dbh, 020h, 0dbh, 020h, 0dfh, 0dfh, 0dch, 0dfh, 0dch, 0dbh, 0dfh, 020h, 0dch, 0dfh, 020h, 0dch, 0dfh, 0dch, 0dbh, 0dch, 0dfh, 020h, 0dbh, 020h, 0dbh, 0dbh, 0dbh, 020h, 0dbh, 13, 10
                db 020h, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dbh, 020h, 0dbh, 020h, 0dbh, 020h, 0dch, 020h, 0dbh, 0dfh, 0dch, 0dfh, 0dch, 020h, 0dbh, 0dfh, 0dch, 020h, 0dch, 020h, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dbh, 13, 10
                db 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 0dbh, 0dch, 0dbh, 020h, 0dfh, 0dch, 0dfh, 020h, 0dch, 0dfh, 0dch, 0dbh, 0dch, 0dch, 020h, 0dch, 020h, 0dch, 020h, 0dch, 020h, 13, 10
                db 020h, 0dfh, 020h, 020h, 0dfh, 0dfh, 0dch, 0dch, 0dbh, 0dfh, 0dbh, 020h, 0dch, 0dch, 0dfh, 0dch, 0dch, 0dch, 0dbh, 0dfh, 0dfh, 0dch, 020h, 0dch, 0dfh, 0dch, 0dbh, 0dfh, 0dch, 020h, 0dch, 0dfh, 0dbh, 0dfh, 13, 10
                db 020h, 0dfh, 0dbh, 0dfh, 0dbh, 0dfh, 0dch, 0dch, 020h, 0dfh, 0dbh, 0dfh, 0dbh, 020h, 020h, 020h, 0dfh, 020h, 0dch, 020h, 0dbh, 0dfh, 0dfh, 0dbh, 0dch, 0dch, 0dch, 020h, 0dbh, 0dbh, 0dch, 0dfh, 020h, 020h, 13, 10
                db 020h, 0dch, 020h, 0dfh, 0dbh, 0dfh, 0dbh, 0dch, 0dbh, 0dbh, 0dfh, 0dfh, 020h, 0dfh, 0dbh, 0dch, 0dch, 0dbh, 020h, 020h, 0dfh, 020h, 0dbh, 0dbh, 0dfh, 0dch, 0dch, 0dbh, 020h, 0dch, 020h, 020h, 0dbh, 0dfh, 13, 10
                db 020h, 020h, 0dfh, 0dfh, 0dbh, 0dfh, 0dch, 0dch, 020h, 020h, 0dfh, 0dch, 020h, 0dbh, 0dfh, 0dch, 0dch, 020h, 0dch, 020h, 020h, 0dch, 0dfh, 020h, 0dfh, 0dbh, 0dbh, 0dfh, 0dch, 0dch, 020h, 0dfh, 0dch, 020h, 13, 10
                db 020h, 0dbh, 0dfh, 0dch, 0dch, 0dfh, 020h, 0dch, 020h, 0dfh, 0dfh, 0dch, 0dch, 0dch, 020h, 020h, 0dch, 0dbh, 0dch, 0dch, 0dfh, 020h, 020h, 0dch, 0dfh, 0dch, 020h, 0dbh, 020h, 020h, 0dbh, 020h, 0dbh, 0dfh, 13, 10
                db 020h, 0dfh, 0dch, 0dbh, 0dch, 0dfh, 020h, 0dch, 0dbh, 0dfh, 0dfh, 020h, 0dbh, 020h, 020h, 0dfh, 0dfh, 020h, 0dch, 0dch, 0dfh, 0dch, 0dfh, 0dch, 0dbh, 0dch, 0dbh, 020h, 0dbh, 0dbh, 020h, 0dfh, 0dch, 020h, 13, 10
                db 020h, 0dbh, 0dfh, 0dbh, 0dbh, 020h, 0dch, 0dch, 0dbh, 020h, 0dbh, 0dbh, 020h, 0dfh, 0dbh, 0dbh, 0dch, 0dbh, 0dfh, 0dfh, 0dfh, 020h, 0dfh, 020h, 0dfh, 0dfh, 0dch, 0dbh, 0dch, 0dch, 0dbh, 020h, 0dbh, 0dfh, 13, 10
                db 020h, 0dbh, 020h, 020h, 020h, 020h, 0dch, 0dch, 0dfh, 0dch, 0dfh, 0dfh, 020h, 0dbh, 0dfh, 0dch, 0dfh, 0dfh, 0dch, 020h, 020h, 0dch, 0dfh, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dbh, 0dfh, 0dfh, 020h, 0dch, 13, 10
                db 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 0dbh, 0dch, 020h, 0dch, 0dch, 020h, 020h, 0dch, 0dch, 020h, 0dfh, 0dfh, 020h, 020h, 0dch, 0dch, 0dbh, 020h, 0dch, 020h, 0dbh, 0dbh, 0dch, 0dch, 0dfh, 13, 10
                db 020h, 0dbh, 020h, 0dch, 0dch, 0dch, 020h, 0dbh, 020h, 0dch, 0dch, 0dfh, 0dbh, 020h, 020h, 0dfh, 0dch, 0dch, 0dch, 020h, 0dfh, 0dch, 0dfh, 0dbh, 0dfh, 0dbh, 0dch, 0dch, 0dch, 0dbh, 0dfh, 0dfh, 0dch, 0dbh, 13, 10
                db 020h, 0dbh, 020h, 0dbh, 0dbh, 0dbh, 020h, 0dbh, 020h, 0dbh, 0dfh, 0dbh, 020h, 0dfh, 0dbh, 0dbh, 0dch, 0dbh, 020h, 020h, 0dfh, 0dch, 0dch, 0dch, 0dfh, 0dch, 0dfh, 0dch, 0dfh, 0dfh, 0dch, 0dch, 0dfh, 0dfh, 13, 10
                db 020h, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dbh, 020h, 0dbh, 0dbh, 0dch, 020h, 0dbh, 0dfh, 0dch, 0dbh, 0dfh, 0dch, 0dfh, 0dbh, 0dfh, 0dfh, 0dfh, 0dbh, 0dch, 0dch, 020h, 0dfh, 020h, 0dfh, 0dfh, 0dch, 020h, 13, 10
                db 13, 10, 13, 10, "$"
WINNING_CODE    db "Votre code pour obtenir votre recompense est ", "$"
PLAYER1_CODE    db "Anthony4Ever!", 13, 10, "$"
PLAYER2_CODE    db "DematBreizh29", 13, 10, "$"
PLAYER3_CODE    db "6502vZ80v8086", 13, 10, "$"
CODE_END_RC     db 13, 10, "$"

.CODE

WINNING_MESSAGE:
    ; print QR Code
    mov dx, offset WINNING_MSG
    mov ah, 09h
    int 21h

    ; print gift password
    mov dx, offset WINNING_CODE
    mov ah, 09h
    int 21h

    ; read cursor position (we need to use bios to change colors)
    mov ah, 03h
    mov bh, 0
    int 10h
    push dx
    
    ; we need to multiply position by 16 from player 0 (to get the right code)
    mov al, PLAYER_NUMBER
    xor ah, ah
    shl ax, 4
    
    mov si, offset PLAYER1_CODE
    add si, ax
    mov dx, 13
    mov cx, 1       ; we only need to repeat the character ince

    @@print_char_color:
        ; using light gray (7) in background + red (4) in foreground
        mov bx, 7 * 16 + 4
        mov ah, 9
        mov al, [si]
        int 10h

        inc si

        mov bx, dx
        ; move cursor right
        pop dx
        inc dx
        mov ah, 2
        int 10h
        push dx

        mov dx, bx
        dec dx
        or dx, dx
        jnz @@print_char_color

    pop dx
    
    mov dx, offset CODE_END_RC
    mov ah, 09h
    int 21h
    
    ret