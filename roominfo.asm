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
                    db 001b,  0, 16, 0, 16, 0, 9, 0, 14, 0, "A l'identique.           Mais surtout a gauche", "$", (75 - 47) dup (0)
                    db 001b,  9, 17, 0, 22, 0, 15, 0, 15, 0, "Dans la continuite", "$", (75 - 19) dup (0)
                    db 001b,  0, 23, 0, 16, 0, 0, 0, 0, 0, "Un miroir vers l'infini", "$", (75 - 24) dup (0)
                    db 001b,  2, 12, 0, 24, 0, 0, 0, 0, 0, "Remplissez moi jusqu'au  bord", "$", (75 - 30) dup (0)
                    db 001b, 20, 20, 0, 25, 0, 13, 0, 25, 0, "America !", "$", (75 - 10) dup (0)
                    db 001b, 16, 21, 0, 26, 23, 19, 0, 0, 0, "Transcendance", "$", (75 - 14) dup (0)
                    db 001b, 12, 22, 0, 20, 0, 0, 0, 0, 0, "Franchir la ligne", "$", (75 - 18) dup (0)
                    db 001b,  0, 28, 0, 16, 0, 21, 0, 0, 0, "De la Suede a la Norvege", "$", (75 - 25) dup (0)
                    db 001b,  4, 24, 0, 17, 0, 29, 0, 0, 0, "C'est bon les beignets. Mais je prefererais un donut", "$", (75 - 53) dup (0)
                    db 001b, 19, 30, 0, 18, 0, 23, 0, 0, 0, "Vive La reine ?", "$", (75 - 16) dup (0)
                    db 001b, 14, 19, 0, 31, 0, 19, 0, 0, 0, "Complementaire", "$", (75 - 15) dup (0)
                    db 111b,  0, 26, 0, 26, 0, 26, 0, 26, 0, "This is the end. Go towards the light!", "$", (75 - 39) dup (0)
                    db 001b, 21, 28, 0, 33, 0, 26, 0, 0, 0, "Compression horizontale", "$", (75 - 24) dup (0)
                    db 001b, 18, 29, 0, 22, 0, 27, 0, 0, 0, "XOR a droite", "$", (75 - 13) dup (0)
                    db 001b,  1, 30, 0, 35, 0, 23, 0, 28, 0, "Miroir Miroir", "$", (75 - 14) dup (0)
                    db 001b, 22, 24, 0, 29, 0, 0, 0, 0, 0, "4 rotations a droite", "$", (75 - 21) dup (0)
                    db 001b, 24, 32, 0, 25, 0, 0, 0, 0, 0, "Trop rapide. Reduit le tempo par deux", "$", (75 - 38) dup (0)
                    db 001b,  0, 33, 0, 26, 5, 31, 0, 0, 0, "Il vous manque une case", "$", (75 - 24) dup (0)
                    db 001b, 25, 34, 0, 27, 0, 32, 0, 0, 0, "Le meme a droite, mais avec rotation a 45 degres.", "$", (75 - 50) dup (0)
                    db 001b,  0, 35, 0, 33, 0, 0, 0, 0, 0, "Pas content, content", "$", (75 - 21) dup (0)
                    db 001b, 27, 36, 0, 29, 0, 34, 0, 0, 0, "Completez l'escargot", "$", (75 - 21) dup (0)
                    db 001b, 26, 35, 0, 0, 0, 0, 0, 0, 0, "Gliders... Game of Life", "$", (75 - 24) dup (0)
                    

                    db 85 * (TOTAL_NUMBER_ROOM-36) dup (0)

.CODE