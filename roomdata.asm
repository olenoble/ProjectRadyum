; ***************************************************************************************
; ***************************************************************************************
; ** Room data - contains only room data (starting + target)
; ** Require ...


.DATA 
                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; All room data
                    ; 400 bytes per room (20x10 for current and for target room)
ALL_ROOMS_DATA      db 08h, 9 dup (04h), 0ch, 8 dup (04h), 09h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 5 dup (0203h), (0303h), 2 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    db 0bh, 18 dup (05h), 0ah

                    db 10 dup (0), 1, 9 dup (0)
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    db 20 dup (0)

                    db 08h, 9 dup (04h), 0ch, 8 dup (04h), 09h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 030fh, 8 dup (0302h), 0702h
                    dw 0206h, 8 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    dw 0206h, 5 dup (0203h), (0303h), 2 dup (0203h), 0703h
                    dw 0306h, 8 dup (0302h), 0702h
                    db 0bh, 9 dup (05h), 1eh, 8 dup (05h), 0ah

                    db 10 dup (0), 1, 9 dup (0)
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0302h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    dw 0200h, 8 dup (0203h), 0003h
                    dw 0300h, 8 dup (0302h), 0002h
                    db 10 dup (0), 3, 9 dup (0)

                    db 400 * (TOTAL_NUMBER_ROOM-2) dup (0)

.CODE
