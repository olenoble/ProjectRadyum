.MODEL SMALL
.386


.STACK 4096

.DATA
;FILENAME2    db ".\IMGTEST.LBM", 0
;FILENAME    db "c:\IMG_TEST.LBM", 0
FILENAME2   db ".\IMG5_VGA.LBM", 0
FILENAME   db ".\GRID1.LBM", 0

FILEINFO    dw 4 dup (0)

MSG_WAITKEY db 13, 10, "Press Any Key...", "$"

; size and pointer to memory allocated to game
; we assign a temporary zone, MAX_LBM_FILES image buffers, 1 video buffers --> all 64kb
; 5 * FFFF divided by 16 (segments) 
DATA_SIZE           dw (MAX_LBM_FILES + 2) * 0FFFFh / 10h ; 4FFFh
DATA_PTR            dw 0
BUFFER_PTR          dw 0
MEM_PTR_END         dw 0
ERR_MEMALLOCATE     db "Could not allocate memory", 13, 10, "$"

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

    ; now assign all the necessary memory
    mov bx, [DATA_SIZE]
    mov ah, 48h
    int 21h
    jc NOT_ENOUGH_MEMORY
    ;call MemoryStillAvail

    ; we place the temporary zone at the beginning
    ; then we start the data area 64kb after
    mov bx, ax
    mov [BUFFER_PTR], bx
    add bx, 0fffh
    mov [DATA_PTR], bx
    
    call ALLOCATE_IMG_PTR
    mov [MEM_PTR_END], bx

    ; open the first file
    mov dx, offset FILENAME
    mov di, offset FILEINFO
    mov ax, [BUFFER_PTR]
    mov [di+6], ax
    call OPEN_FILE

    ; decompress the LBM file
    mov si, offset FILEINFO
    call EXTRACT_IMG

    ; open the second file
    mov dx, offset FILENAME2
    mov di, offset FILEINFO
    mov ax, [BUFFER_PTR]
    mov [di+6], ax
    call OPEN_FILE

    ; decompress the LBM file
    mov si, offset FILEINFO
    call EXTRACT_IMG
    
    ; Then print a little message
    mov dx, offset MSG_WAITKEY
    mov ah, 9
    int 21h
    call READ_KEY_WAIT
    
    ; start graphic mode and display
    call SWITCH_TO_320x200
    
    ; ********** FIRST IMAGE *****************************
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

    ; ********** SECOND IMAGE *****************************
    push ds
    mov ax, [VIDEO_BUFFER]
    mov es, ax
    mov ax, [SCREEN_PTR + 2]
    mov ds, ax
    
    xor di, di
    xor si, si
    mov cx, 320 * 200
    rep movsb
    pop ds
    
    call COPY_TO_VIDEOBUFFER

    mov word ptr [FADEWAITITR], 4
    mov al, 1
    call FADEIN
    call READ_KEY_WAIT
    
    ; and fadeout
    mov al, 1
    call FADEOUT

TEMPEND:
    jmp END_GAME


MAIN ENDP


END_GAME:    
    ; return INT to their former processes
    call INT9_RESET
    
    ; reset the screen and quit
    call RESET_SCREEN
    jmp ENDPROG


NOT_ENOUGH_MEMORY:
    ; This routine is called if DOS can't allocate the requested memory    
    call RESET_SCREEN

    mov dx, offset ERR_MEMALLOCATE
    mov ah, 9
    int 21h
    
    call INT9_RESET
    
    jmp ENDPROG
    
END MAIN

