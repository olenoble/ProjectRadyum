; ***************************************************************************************
; ***************************************************************************************
; ** Various (hardcoded) data for logic.asm
; ** Require ....

GAME_ESCAPE_KEY         equ 1
RESET_KEY               equ 13h
CHARACTERSPRITE         equ CHARSTYLE
CHARACTER_STEP          equ 7
TOTAL_NUMBER_ROOM       equ 36

CHARACTER_BUFFER_LEFT   equ 3 * 1
CHARACTER_BUFFER_RIGHT  equ 2 * 1
CHARACTER_BUFFER_UP     equ 0
CHARACTER_BUFFER_DOWN   equ -1 * 1

UP_DOOR                 equ 1ch
DOWN_DOOR               equ 1eh
LEFT_DOOR               equ 1fh
RIGHT_DOOR              equ 1dh

CLOSED_UP_DOOR          equ 0ch
CLOSED_DOWN_DOOR        equ 0eh
CLOSED_LEFT_DOOR        equ 0fh
CLOSED_RIGHT_DOOR       equ 0dh

.DATA 
                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Bottom area
CLUEAREA            db 1ah, 25 dup (1dh), 3ah
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1ch, 25 dup (3dh), 3ch

ORIGINALCLUEAREA    db 1ah, 25 dup (1dh), 3ah
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1bh, 25 dup (1eh), 3bh
                    db 1ch, 25 dup (3dh), 3ch

PASSCODEAREA        db 1ah, 11 dup (1dh), 3ah
                    db 1bh, 3 dup (1eh), 1fh, 3 dup (1eh), 1fh, 3 dup (1eh), 3bh
                    db 1bh, 3 dup (1eh), 1fh, 3 dup (1eh), 1fh, 3 dup (1eh), 3bh
                    db 1bh, 3 dup (1eh), 1fh, 3 dup (1eh), 1fh, 3 dup (1eh), 3bh
                    db 1ch, 11 dup (3dh), 3ch

                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ; Pop-up question area about the required passcode
QUESTIONAREA        db 1ah, 11 dup (1dh), 3ah
                    db 1bh, 1fh, 02h, 0eh, 03h, 04h, 1fh, 1fh, 1fh, 1fh, 1fh, 1fh, 3bh
                    db 1bh, 4 dup (1fh), 3 dup (1eh), 4 dup (1fh), 3bh
                    db 1ch, 11 dup (3dh), 3ch

SUBMITTEDPASS       db 3 dup (0)

                    ; Store the letter mappings - starting from space (20h = 32) - see http://www.asciitable.com/
                    ; Numbers start at 48 - upper case letters at 65 and lower case at 97
LETTER_MAPPING      db 1fh, 4eh, 5 dup (1fh), 4ch, 5 dup (1fh), 50h, 4fh, 1fh ; various characters
                    db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h       ; numbers
                    db 5 dup (1fh), 4dh, 1fh                                  ; various characters
                    db 00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h       ; upper case letters
                    db 0ah, 0bh, 0ch, 0dh, 0eh, 0fh, 10h, 11h, 12h, 13h 
                    db 14h, 15h, 16h, 17h, 18h, 19h
                    db 4 dup (1fh), 1eh, 1fh                                  ; various characters
                    db 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h       ; lower case letters
                    db 2ah, 2bh, 2ch, 2dh, 2eh, 2fh, 30h, 31h, 32h, 33h 
                    db 34h, 35h, 36h, 37h, 38h, 39h

.CODE
