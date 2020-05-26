.MODEL LARGE
.STACK 100H
.386


.DATA
FILENAME    db "C:\IMGTEST.LBM", 0
ERRMSG1     db "Could not open file", 13, 10, "$"
ERRMSG2     db "Could not read file", 13, 10, "$"
ERRMSG3     db "Could not close file", 13, 10, "$"
DONEMSG     db "All good - Bye!", 13, 10, "$"
FILEHANDLE  dw 0

FILETEMP segment use16
FILEBUFFER  db 65535 dup (0)
FILETEMP ends

.CODE

MAIN PROC

    call INTRO

    mov ax, @DATA
    mov ds, ax
    
    ; Open file
    mov dx, offset FILENAME
    mov ax, 3d00h
    int 21h
    
    jc CantOpen
    
    ; Save the handle
    mov [FILEHANDLE], ax
    
    ; Now read file - save ds and point to the new segment
    push ds
    mov bx, ax
    mov ax, seg FILETEMP
    mov ds, ax
    mov cx, 65535
    mov dx, offset FILEBUFFER
    mov ah, 3fh
    int 21h
    pop ds
    
    jc CantRead

    ; now close the file
    mov ah, 3eh
    int 21h
    
    jc CantClose
    
    mov dx, offset DONEMSG
    mov ah, 9
    int 21h
    
endmain:   
    mov ah, 4ch
    int 21h


; list of error functions
CantOpen:
    ; This routine is called if DOS can't access the file
    mov dx, offset ERRMSG1
    mov ah, 9
    int 21h
    jmp endmain

CantRead:
    ; This routine is called if DOS can't read the file
    mov dx, offset ERRMSG2
    mov ah, 9
    int 21h
    jmp endmain
        
CantClose:
    ; This routine is called if DOS can't close the file
    mov dx, offset ERRMSG3
    mov ah, 9
    int 21h
    jmp endmain 

    
MAIN ENDP

    ; **********************************************
    ; **********************************************
    ; ** Include files here
    INCLUDE intro.asm    
    
END MAIN

