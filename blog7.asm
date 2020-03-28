.MODEL SMALL
.386


.STACK 4096

.DATA
FILENAME    db "C:\IMGTEST.LBM", 0
;FILENAME    db "C:\IMG_TEST.LBM", 0
;FILENAME    db "C:\IMG5_VGA.LBM", 0
FILEINFO    dw 4 dup (0)

MSG_WAITKEY db 13, 10, "Press Any Key...", "$"

MSG1        db "Loading LBM file", 13, 10, "$"
MSG2        db "Extract image", 13, 10, "$"
MSG3        db "Free LBM file", 13, 10, "$"
MSG4        db "Allocate video buffer", 13, 10, "$"


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

    ; **** debug message
    mov dx, offset MSG1
    mov ah, 9
    int 21h

    ; open the file
    mov dx, offset FILENAME
    mov di, offset FILEINFO
    call OPEN_FILE
    
    ; **** debug message
    mov dx, offset MSG2
    mov ah, 9
    int 21h
    
    ; decompress the LBM file
    mov si, offset FILEINFO
    call EXTRACT_IMG
    
     ; **** debug message
     mov dx, offset MSG3
     mov ah, 9
     int 21h   
    
    ;;;;; *** TEST
    mov di, offset FILEINFO
    mov ax, [di+6]
    mov es, ax
    mov ah, 49h
    int 21h


    call MemoryStillAvail
    ;;;;; *** TEST
    
    ; Then print a little message
    mov dx, offset MSG_WAITKEY
    mov ah, 9
    int 21h
    
    call READ_KEY_WAIT

    ; **** debug message
    mov dx, offset MSG4
    mov ah, 9
    int 21h
    
    call CREATE_VIDEOBUFFER
    ; call SET_UP_GRAPHIC_MODE
    jmp TEMPEND

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
    
    ; and fadeout - but let's have a faster one
    mov word ptr [FADEWAITITR], 2
    xor ax, ax
    call FADEOUT
TEMPEND:
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
    ; call RESET_SCREEN
    jmp ENDPROG 
    
END MAIN

