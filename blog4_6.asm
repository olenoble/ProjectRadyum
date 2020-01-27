.MODEL LARGE
.STACK 100H
.386

.STACK 4096

.DATA
FILENAME    db "C:\IMG_TEST.LBM", 0
FILEINFO    dw 4 dup (0)

.CODE

MAIN PROC

    call SETUP   
    call INTRO

    ; open the file
    mov dx, offset FILENAME
    mov di, offset FILEINFO
    call OPEN_FILE
    
    ; remember to free up the requested memory
    mov ax, [di+6]
    mov es, ax
    mov ah, 49h
    int 21h
    
    jmp ENDPROG

MAIN ENDP

    ; **********************************************
    ; **********************************************
    ; ** Include files here
    INCLUDE setup.asm
    INCLUDE intro.asm
    INCLUDE filemgmt.asm
    
END MAIN

