; ***************************************************************************************
; ***************************************************************************************
; ** Password list
; ** Require ....

.DATA 
                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Contains passcode number, passcode (3bytes), owner (1byte), position (column + row - 2bytes), and padding (1 byte)
                    ; Number and padding are not necessary, but it's visually useful. Also, it makes 8 bytes each
                    ; which is practical
ALL_PASSCODE        db  1, "G97", "D", 1, 1, 0
                    db  2, "C18", "D", 1, 2, 0
                    db  3, "N79", "D", 1, 3, 0
                    db  4, "B84", "D", 2, 1, 0
                    db  5, "V79", "D", 2, 2, 0
                    db  6, "O24", "D", 2, 3, 0
                    db  7, "C43", "D", 3, 1, 0
                    db  8, "A15", "D", 3, 2, 0
                    db  9, "V51", "D", 3, 3, 0

                    db 10, "A91", "S", 1, 1, 0
                    db 11, "Q36", "S", 1, 2, 0
                    db 12, "D45", "S", 1, 3, 0
                    db 13, "X58", "S", 2, 1, 0
                    db 14, "J64", "S", 2, 2, 0
                    db 15, "M34", "S", 2, 3, 0
                    db 16, "F52", "S", 3, 1, 0
                    db 17, "C36", "S", 3, 2, 0
                    db 18, "P63", "S", 3, 3, 0
                    
                    db 19, "E52", "G", 1, 1, 0
                    db 20, "X76", "G", 1, 2, 0
                    db 21, "F67", "G", 1, 3, 0
                    db 22, "L36", "G", 2, 1, 0
                    db 23, "W29", "G", 2, 2, 0
                    db 24, "S57", "G", 2, 3, 0
                    db 25, "T18", "G", 3, 1, 0
                    db 26, "W35", "G", 3, 2, 0
                    db 27, "I39", "G", 3, 3, 0

.CODE

ADD_PREVIOUS_PASSWORDS:
    ; code will browse ROOM_INFO and figure out whether to add previous password
    push ax
    push si

    mov si, offset ALL_ROOMS_INFO
    mov ah, 36

    @@loop_over_roominfo:
        ; check if room was solved - if second bit is off, room is unsolved
        mov al, [si]
        and al, 10b
        or al, al
        jz @@move_next_room

        ; if solved, was there a code ? if next byte is 0 -> no code
        mov al, [si + 1]
        or al, al
        jz @@move_next_room

        call ADD_NEW_PASSWORD

        @@move_next_room:
            add si, 85
        
        dec ah
        jnz @@loop_over_roominfo

    pop si
    pop ax
    ret