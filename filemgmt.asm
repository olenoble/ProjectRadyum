; ***************************************************************************************
; ***************************************************************************************
; ** Tools for file management
; ** Require setup.asm

; ** TODO --> we only read 1 segment at the moment....

.DATA
ERR_FILE1     db "Could not open file", 13, 10, "$"
ERR_FILE2     db "Could not read file", 13, 10, "$"
ERR_FILE3     db "Could not close file", 13, 10, "$"

ROOM_FILENAME            db "ROOM.DAT"
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


GENERATE_ROOM_FILE:

    ; create the file
    mov dx, offset ROOM_FILENAME
    mov ah, 3ch
    xor cx, cx
    int 21h

    mov [ROOM_FILEHANDLE], ax

    ; first of all, write the player info
    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 6
    mov dx, offset PLAYER_NUMBER
    int 21h

    ; now save the room data
    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 36 * 2 * 20 * 10
    mov dx, offset ALL_ROOMS_DATA
    int 21h

    ; and then the room info
    mov ah, 40h
    mov bx, [ROOM_FILEHANDLE]
    mov cx, 36 * (10 + 75)
    mov dx, offset ALL_ROOMS_INFO
    int 21h


    ; now close the file
    mov bx, [ROOM_FILEHANDLE]
    mov ah, 3eh
    int 21h
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

FileErrorMsgAndQuit:
    ; Routine display the corresponding error message and exit
    call RESET_SCREEN
    mov ah, 9
    int 21h
    
    call INT9_RESET
    
    jmp ENDPROG
