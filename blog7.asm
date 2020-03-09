.MODEL LARGE
.STACK 100H
.386

; TO DO
; A. move the following function into a grafx lib:
;   2. black out / fade in / fade out / change palette
;   3. create and manage a video buffer to copy data to A000
;   4. detect vertical sync


.STACK 4096

.DATA
FILENAME    db "C:\IMGTEST.LBM", 0
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
    
    ; decompress the LBM file
    mov si, offset FILEINFO
    call EXTRACT_IMG
    
    ; Then print a little message
    mov dx, offset MSG_TEST
    mov ah, 9
    int 21h
    
    call READ_KEY_WAIT
    call SWITCH_TO_320x200
    
    mov dx, 03dah
WaitNotVSync2:                              ;wait to be out of vertical sync
    in al, dx
    and al, 08h
    jnz WaitNotVSync2
WaitVSync2:                                 ;wait until vertical sync begins
    in al, dx
    and al, 08h
    jz WaitVSync2
    DETECT_VSYNC
    
    mov ax, 0a000h
    mov es, ax
    mov di, 0
    
    push ds
    mov ax, [IMG_PTR]
    mov ds, ax
    xor si, si
    mov cx, 320 * 200
    rep movsb
    pop ds
    
    call fade_in
    jmp wait4Key
    
    ; now set colors 
    mov cx, 256 * 3
    mov si, offset CMAP_BUFFER       ;load the DAC from this array
    
    mov dx, 03c8h
    xor al, al
    out dx, al
    
    mov dx, 03c9h
    cli
DACLoadLoop:
    ; set the red/green/blue component
    lodsb
    and al, 1111b
    shl al, 2
    out dx, al

    loop DACLoadLoop
    sti

wait4Key:    
    call READ_KEY_WAIT
    
    call INT9_RESET
    call RESET_SCREEN
    jmp ENDPROG 
    
MAIN ENDP


fade_in:

    mov bl, 1111b
    mov ah, 0
iterfade:    
    ; now set colors 
    mov cx, 256 * 3
    mov si, offset CMAP_BUFFER       ;load the DAC from this array
    
    mov dx, 03c8h
    xor al, al
    out dx, al
    
    mov dx, 03c9h
    cli
DACLoadLoop2:
    ; set the red/green/blue component
    lodsb
    and al, 1111b
    cmp al, ah
    jb use_al
    mov al, ah
use_al:    
    shl al, 2
    out dx, al

    loop DACLoadLoop2
    sti
    
    mov cx, 5
wait_several_scan:
    mov dx, 03dah
WaitNotVSync3:                              ;wait to be out of vertical sync
    in al, dx
    and al, 08h
    jnz WaitNotVSync3
WaitVSync3:                                 ;wait until vertical sync begins
    in al, dx
    and al, 08h
    jz WaitVSync3
    loop wait_several_scan
    
    inc ah
    dec bl
    jnz iterfade
    
    ret

    ; **********************************************
    ; **********************************************
    ; ** Include files here
    INCLUDE setup.asm
    INCLUDE intro.asm
    INCLUDE filemgmt.asm
    INCLUDE keyb.asm
    INCLUDE lbmtool.asm
    INCLUDE grafx.asm
    
END MAIN

