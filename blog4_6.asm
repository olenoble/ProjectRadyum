.MODEL LARGE
.STACK 100H
.386

.STACK 4096

.DATA
FILENAME    db "C:\IMG_TEST.LBM", 0
FILEINFO    dw 4 dup (0)

MSG_TEST    db 13, 10, "Press Any Key...", "$"
.CODE

MAIN PROC

    call SETUP
    call INT9_SETUP
    call INTRO

    ; open the file
    mov dx, offset FILENAME
    mov di, offset FILEINFO
    call OPEN_FILE
    
    ; Then print it out
    mov dx, offset MSG_TEST
    mov ah, 9
    int 21h    
    
    call READ_KEY_WAIT
    
    ; remember to free up the requested memory
    mov ax, [di+6]
    mov es, ax
    mov ah, 49h
    int 21h
    
    call INT9_RESET
    jmp ENDPROG

MAIN ENDP

    ; **********************************************
    ; **********************************************
    ; ** Include files here
    INCLUDE setup.asm
    INCLUDE intro.asm
    INCLUDE filemgmt.asm
    INCLUDE keyb.asm
    
END MAIN

