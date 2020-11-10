; ********************************************************************************************
; ********************************************************************************************
; ** Simple script to generate the room files 


.MODEL SMALL
.386
.STACK 512

; Constants
LOCALS @@


; **********************************************
; **********************************************
; ** Data here
.DATA
FILENAME            db "ROOM_3.DAT"
FILEHANDLE          dw 0
FILEINFO            dw 4 dup (0)

; player info
PLAYER_NUMBER       db 2    ; 0 to 2
ROOM_START          db 32    ; 0 -> 1 / 1 -> 6 / 2 -> 32
CHAR_POS_X          dw 160
CHAR_POS_Y          dw 64

; **********************************************
; **********************************************
; ** CODE here
.CODE

; ** Include data files here
INCLUDE roomdata.asm
INCLUDE roominfo.asm

; **********************************************
; **********************************************
; ** Main Loop
MAIN PROC

    mov ax, @DATA
    mov ds, ax

    ; create the file
    mov dx, offset FILENAME
    mov ah, 3ch
    xor cx, cx
    int 21h

    mov [FILEHANDLE], ax

    ; first of all, write the player info
    mov ah, 40h
    mov bx, [FILEHANDLE]
    mov cx, 6
    mov dx, offset PLAYER_NUMBER
    int 21h

    ; now save the room data
    mov ah, 40h
    mov bx, [FILEHANDLE]
    mov cx, 36 * 2 * 20 * 10
    mov dx, offset ALL_ROOMS_DATA
    int 21h

    ; and then the room info
    mov ah, 40h
    mov bx, [FILEHANDLE]
    mov cx, 36 * (10 + 75)
    mov dx, offset ALL_ROOMS_INFO
    int 21h


    ; now close the file
    mov bx, [FILEHANDLE]
    mov ah, 3eh
    int 21h

    
    ; that's all folks
    mov ah, 4ch
    int 21h

MAIN ENDP


END MAIN