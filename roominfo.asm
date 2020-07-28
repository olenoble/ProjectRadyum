; ***************************************************************************************
; ***************************************************************************************
; ** Room info data
; ** Require ....

.DATA 
                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; All room info
                    ; for the info 2 bytes (flags + code) & 8 bytes for actions - 25*3 bytes for the message = 85 bytes per room
ALL_ROOMS_INFO      db 001b, 0, 2, 0, 0, 0, 0, 0, 0, 0, "Il vous manque une case", "$", (75 - 24) dup (0)
                    db 001b, 0, 3, 1, 8, 1, 1, 0, 0, 0, "Arithmetique", "$", (75 - 13) dup (0)
                    db 85 * (TOTAL_NUMBER_ROOM-2) dup (0)

.CODE

