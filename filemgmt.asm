; ***************************************************************************************
; ***************************************************************************************
; ** Tools for file management
; ** Require setup.asm

.DATA
            ; A little repetitive (I could have used generic messages using the file name more explicitely)
            ; just a little lazy right now....  
ERR_FILE1   db "Could not open IMG file", 13, 10, "$"
ERR_FILE2   db "Could not read IMG file", 13, 10, "$"
ERR_FILE3   db "Could not close IMG file", 13, 10, "$"

ERR_ROOM1   db "Could not read ROOM file", 13, 10, "$"
ERR_ROOM2   db "Could not write ROOM file", 13, 10, "$"
ERR_ROOM3   db "Could not close ROOM file", 13, 10, "$"

ERR_ROOM4   db "Could not open ROOM file", 13, 10, "$"


ROOM_FILENAME            db "C:\ROOM.DAT"
ROOM_FILEHANDLE          dw 0

.CODE

OPEN_FILE:
    ; basic function to open files
    ; DX must point to the filename in DS segment
    ; DI must point to a 4 word that will contain respectively 
    ; FILEHANDLE (1w) + FILESIZE (2w - big endian) + FILESEGMENT (1w)  - segment is prepopulated

    pusha
    
    ; Open file
    mov ax, 3d00h
    int 21h
    jc CantOpen
    
    ; Save the handle
    mov [di], ax
    
    ; now we need to detect the size of the file - move to the end
    mov bx, ax
    mov ax, 4202h
    mov cx, 0
    mov dx, 0
    int 21h
    
    ; a bit lazy here - reusing the same error message
    jc CantRead
    mov [di+2], dx
    mov [di+4], ax
        
    ; Remember we need to get back to the beginning of the file
    mov bx, [di]
    mov ax, 4200h
    mov cx, 0
    mov dx, 0
    int 21h
    
    ; Now read file - save ds and point to the new segment
    ; dx can be zero since we start at the beginning of the segment
    push ds
    mov bx, [di]
    mov ax, [di+6]
    ; Note that we only read one segment
    mov cx, [di+4]    
    mov ds, ax
    mov dx, 0
    mov ah, 3fh
    int 21h
    pop ds
    
    jc CantRead

    ; now close the file
    mov ah, 3eh
    int 21h
    
    jc CantClose

    popa
    ret


SAVE_ROOM_FILE:
    ; This is where we save the game upon exiting
    pusha 

    mov ax, @DATA
    mov ds, ax

    ; open the file
    mov dx, offset ROOM_FILENAME
    mov ax, 3d02h
    int 21h
    jc CantOpenRoom

    mov [ROOM_FILEHANDLE], ax

    ; we write (in that order) - player number, room number, pos X and pos Y
    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 1
    mov dx, offset PLAYER_NUMBER
    int 21h  
    jc CantWriteRoom

    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 1
    mov dx, offset ROOM_NUMBER
    int 21h
    jc CantWriteRoom

    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 4
    mov dx, offset CHAR_POS_X
    int 21h
    jc CantWriteRoom

    ; now save the room data
    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 36 * 2 * 20 * 10
    mov dx, offset ALL_ROOMS_DATA
    int 21h
    jc CantWriteRoom

    ; and then the room info
    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 36 * (10 + 75)
    mov dx, offset ALL_ROOMS_INFO
    int 21h
    jc CantWriteRoom

    ; now close the file
    mov bx, [ROOM_FILEHANDLE]
    mov ah, 3eh
    int 21h
    jc CantCloseRoom
    
    popa
    ret


USE_ROOM_FILE:
    ; This is where we read the ROOM.DAT file for the last save
    pusha

    mov ax, @DATA
    mov ds, ax

    ; open the file
    mov dx, offset ROOM_FILENAME
    mov ax, 3d00h
    int 21h
    jc CantOpenRoom

    mov [ROOM_FILEHANDLE], ax

    ; now read every bit of info
    ; first the player number
    mov ah, 3fh
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 1
    mov dx, offset PLAYER_NUMBER
    int 21h
    jc CantReadRoom

    ; then the current room
    mov ah, 3fh
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 1
    mov dx, offset ROOM_START
    int 21h
    jc CantReadRoom

    ; and the player position
    mov ah, 3fh
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 4
    mov dx, offset CHAR_POS_X
    int 21h
    jc CantReadRoom

    ; now read the room data
    mov ah, 3fh
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 36 * 2 * 20 * 10
    mov dx, offset ALL_ROOMS_DATA
    int 21h
    jc CantReadRoom

    ; and finally the room info
    mov ah, 3fh
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 36 * (10 + 75)
    mov dx, offset ALL_ROOMS_INFO
    int 21h
    jc CantReadRoom

    ; now close the file
    mov bx, [ROOM_FILEHANDLE]
    mov ah, 3eh
    int 21h
    jc CantCloseRoom
    
    popa
    ret


; ********************************************************************************************
; ********************************************************************************************
; ** Various functions
; list of error functions
CantOpen:
    ; This routine is called if DOS can't access the file
    mov dx, offset ERR_FILE1
    jmp FileErrorMsgAndQuit

CantRead:
    ; This routine is called if DOS can't read the file
    mov dx, offset ERR_FILE2
    jmp FileErrorMsgAndQuit
        
CantClose:
    ; This routine is called if DOS can't close the file
    mov dx, offset ERR_FILE3
    jmp FileErrorMsgAndQuit

CantReadRoom:
    ; This routine is called if DOS can't access the file
    mov dx, offset ERR_ROOM1
    jmp FileErrorMsgAndQuit

CantWriteRoom:
    ; This routine is called if DOS can't read the file
    mov dx, offset ERR_ROOM2
    jmp FileErrorMsgAndQuit
        
CantCloseRoom:
    ; This routine is called if DOS can't close the file
    mov dx, offset ERR_ROOM3
    jmp FileErrorMsgAndQuit

CantOpenRoom:
    ; This routine is called if DOS can't read the file
    mov dx, offset ERR_ROOM4
    jmp FileErrorMsgAndQuit   

FileErrorMsgAndQuit:
    ; Routine display the corresponding error message and exit
    call RESET_SCREEN
    mov ah, 9
    int 21h
    
    call INT9_RESET
    
    jmp ENDPROG
