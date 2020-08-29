; ***************************************************************************************
; ***************************************************************************************
; ** Room data - contains only room data (starting + target)
; ** Require ...


.DATA
                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; All room info
                    ; for the info 2 bytes (flags + code) & 8 bytes for actions - 25*3 bytes for the message = 85 bytes per room
ALL_ROOMS_INFO      db 001b,  0, 2, 0, 0, 0, 0, 0, 0, 0, "Il vous manque une case", "$", (75 - 24) dup (0)
                    db 001b, 17, 3, 1, 8, 0, 1, 0, 0, 0, "Vous devriez utiliser vosdoigts", "$", (75 - 32) dup (0)
                    db 001b, 10, 2, 0, 0, 0, 0, 0, 0, 0, "Un peu de perspective", "$", (75 - 22) dup (0)
                    db 001b,  6, 5, 0, 0, 0, 0, 0, 0, 0, "Il suffirait de peu pour etre juste", "$", (75 - 36) dup (0)
                    db 001b,  7, 11, 0, 4, 17, 0, 0, 0, 0, "Transcendance", "$", (75 - 14) dup (0)
                    db 001b,  0, 12, 0, 0, 0, 0, 0, 0, 0, "Il vous manque une case", "$", (75 - 24) dup (0)
                    db 001b, 11, 8, 0, 0, 0, 0, 0, 0, 0, "Soyons clair et mettons  les points sur les i", "$", (75 - 46) dup (0)
                    db 001b, 13, 14, 7, 2, 0, 7, 0, 0, 0, "Le temps est ecoule", "$", (75 - 20) dup (0)
                    db 001b,  5, 15, 0, 0, 0, 0, 0, 0, 0, "Content Pas Content", "$", (75 - 20) dup (0)
                    db 001b,  0, 0, 0, 0, 0, 0, 0, 0, 0, "Vous ne devriez pas etre ici", "$", (75 - 29) dup (0)
                    db 001b,  8, 12, 0, 5, 0, 0, 0, 0, 0, "Pauvre Blinky", "$", (75 - 14) dup (0)
                    db 001b,  3, 18, 0, 6, 0, 11, 0, 0, 0, "Par ici la sortie", "$", (75 - 18) dup (0)
                    db 001b, 23, 19, 0, 0, 0, 0, 0, 0, 0, "Kori o tokasu", "$", (75 - 14) dup (0)
                    db 001b, 15, 15, 0, 8, 0, 0, 0, 0, 0, "Retour a la racine", "$", (75 - 19) dup (0)
                    db 001b,  0, 16, 0, 16, 0, 9, 0, 14, 0, "A l'identique.            Mais surtout a gauche", "$", (75 - 48) dup (0)
                    db 001b,  9, 17, 0, 22, 0, 15, 0, 15, 0, "Dans la continuite", "$", (75 - 19) dup (0)
                    

                    db 85 * (TOTAL_NUMBER_ROOM-16) dup (0)

.CODE