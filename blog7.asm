.MODEL LARGE
.STACK 100H
.386

; TO DO
; A. move the following function into a grafx lib:
;   2. fade out


.STACK 4096

.DATA
FILENAME    db "C:\IMGTEST.LBM", 0
FILEINFO    dw 4 dup (0)

MSG_TEST    db 13, 10, "Press Any Key...", "$"

; **********************************************
; **********************************************
; ** Include files here
INCLUDE setup.asm
INCLUDE intro.asm
INCLUDE filemgmt.asm
INCLUDE keyb.asm
INCLUDE lbmtool.asm
INCLUDE grafx.asm

.CODE

; **********************************************
; **********************************************
; ** Main Loop
MAIN PROC

    call SETUP
    call INT9_SETUP
    call INTRO

    ; open the file
    mov dx, offset FILENAME
    mov di, offset FILEINFO
    call OPEN_FILE
    
    ; decompress the LBM file
    mov si, offset FILEINFO
    call EXTRACT_IMG
    
    ; Then print a little message
    mov dx, offset MSG_TEST
    mov ah, 9
    int 21h
    
    call READ_KEY_WAIT
    call SET_UP_GRAPHIC_MODE
    
    DETECT_VSYNC
    
    ; Now move the image to the buffer
    push ds
    mov ax, [VIDEO_BUFFER]
    mov es, ax
    mov ax, [SCREEN_PTR]
    mov ds, ax
    
    xor di, di
    xor si, si
    mov cx, 320 * 200
    rep movsb
    pop ds
    
    call COPY_TO_VIDEOBUFFER

    xor ax, ax
    call FADEIN
    call READ_KEY_WAIT
    
    ; and fadeout - but let's have a slower one
    mov word ptr [FADEWAITITR], 16
    xor ax, ax
    call FADEOUT
    
    jmp END_GAME

    
MAIN ENDP


END_GAME:
    ; Put together functions to clear memory and restate interrupts...
    
    ; first free up the video buffer and all memory allocated to graphs
    call FREE_ALL_IMG_MEMORY
    call FREE_VIDEOBUFFER
    
    ; return INT to their former processes
    call INT9_RESET
    
    ; reset the screen and quit
    call RESET_SCREEN
    jmp ENDPROG 
    
END MAIN

