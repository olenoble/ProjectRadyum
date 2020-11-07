; ***************************************************************************************
; ***************************************************************************************
; ** Just some final stuff for the winners

.DATA
WINNING_MSG     db "Felicitations - Vous avez atteint la sortie de mon escape game facon 80s.", 13, 10
                db "Vous avez resolu tous les puzzles et merite votre recompense:", 13, 10, 13, 10
                db 020h, 020h, 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 020h, 0dch, 020h, 020h, 0dch, 0dch, 0dch, 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dbh, 020h, 0dch, 0dch, 0dch, 020h, 0dbh, 020h, 0dbh, 0dch, 0dch, 0dbh, 0dbh, 0dbh, 0dfh, 0dbh, 020h, 0dch, 0dbh, 020h, 0dbh, 020h, 0dbh, 020h, 0dch, 0dch, 0dch, 020h, 0dbh, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dbh, 020h, 0dbh, 0dbh, 0dbh, 020h, 0dbh, 020h, 0dch, 0dfh, 0dfh, 0dfh, 020h, 0dbh, 0dbh, 0dch, 020h, 020h, 0dbh, 020h, 020h, 020h, 0dbh, 020h, 0dbh, 0dbh, 0dbh, 020h, 0dbh, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dbh, 020h, 0dbh, 0dfh, 0dch, 0dfh, 0dch, 0dfh, 0dbh, 0dfh, 0dbh, 0dfh, 0dch, 0dfh, 0dch, 020h, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dbh, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dch, 0dch, 020h, 0dch, 020h, 020h, 0dch, 0dch, 0dfh, 0dfh, 0dch, 020h, 0dfh, 020h, 0dfh, 0dbh, 0dch, 0dfh, 020h, 0dfh, 0dch, 020h, 0dch, 0dch, 0dch, 020h, 0dch, 0dch, 020h, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 020h, 0dch, 0dbh, 0dch, 0dch, 0dbh, 0dch, 0dfh, 0dch, 0dch, 0dbh, 0dfh, 020h, 020h, 0dfh, 020h, 0dbh, 020h, 020h, 0dch, 0dfh, 0dfh, 0dbh, 020h, 020h, 0dbh, 0dch, 0dch, 0dfh, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dfh, 0dbh, 020h, 0dbh, 0dbh, 0dbh, 0dch, 0dbh, 0dbh, 020h, 020h, 020h, 0dch, 020h, 0dfh, 0dch, 0dbh, 0dch, 020h, 0dfh, 0dbh, 0dch, 0dch, 0dfh, 0dfh, 0dch, 0dfh, 0dbh, 0dch, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dfh, 0dfh, 0dbh, 0dfh, 0dch, 020h, 0dch, 020h, 0dbh, 0dch, 0dbh, 0dfh, 0dbh, 020h, 020h, 020h, 020h, 020h, 020h, 0dfh, 0dfh, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dch, 0dbh, 0dch, 0dbh, 0dbh, 020h, 0dch, 0dbh, 020h, 0dbh, 0dch, 0dch, 0dfh, 0dbh, 0dbh, 020h, 020h, 0dbh, 0dfh, 0dfh, 0dbh, 0dch, 0dfh, 020h, 020h, 0dfh, 020h, 0dbh, 020h, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dch, 020h, 0dbh, 0dch, 0dch, 0dfh, 0dch, 0dbh, 020h, 0dfh, 0dch, 020h, 020h, 0dch, 020h, 020h, 0dbh, 0dch, 020h, 020h, 020h, 0dfh, 0dfh, 0dbh, 0dch, 0dfh, 020h, 0dch, 0dbh, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dch, 020h, 0dfh, 0dbh, 0dch, 0dch, 0dch, 0dfh, 0dfh, 0dbh, 020h, 0dbh, 0dch, 0dfh, 0dch, 0dch, 0dch, 0dfh, 0dfh, 0dch, 0dch, 0dbh, 0dbh, 0dbh, 0dbh, 020h, 0dch, 0dfh, 0dfh, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 0dch, 020h, 0dbh, 0dch, 0dbh, 0dbh, 0dbh, 0dbh, 0dch, 020h, 020h, 0dbh, 0dbh, 0dfh, 0dbh, 020h, 0dch, 020h, 0dbh, 020h, 0dfh, 0dbh, 0dfh, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dbh, 020h, 0dch, 0dch, 0dch, 020h, 0dbh, 020h, 020h, 0dfh, 0dch, 0dbh, 0dfh, 0dfh, 0dch, 0dfh, 0dfh, 0dch, 0dfh, 020h, 0dbh, 0dch, 0dch, 0dch, 0dbh, 0dfh, 0dfh, 0dbh, 0dch, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dbh, 020h, 0dbh, 0dbh, 0dbh, 020h, 0dbh, 020h, 0dfh, 0dbh, 0dfh, 0dbh, 020h, 0dbh, 0dbh, 020h, 020h, 0dbh, 0dbh, 0dbh, 0dbh, 0dch, 0dfh, 0dfh, 0dbh, 0dbh, 0dbh, 0dfh, 0dch, 020h, 020h, 13, 10
                db 020h, 020h, 020h, 0dbh, 0dch, 0dch, 0dch, 0dch, 0dch, 0dbh, 020h, 0dbh, 0dbh, 0dch, 0dfh, 0dch, 0dch, 020h, 0dch, 0dfh, 0dbh, 020h, 0dfh, 0dbh, 020h, 020h, 0dch, 020h, 0dch, 020h, 0dbh, 020h, 020h, 020h, 13, 10
                db 13, 10, "$"

.CODE

WINNING_MESSAGE:
    mov dx, offset WINNING_MSG
    mov ah, 09h
    int 21h
    ret