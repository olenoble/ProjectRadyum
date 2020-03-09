; ***************************************************************************************
; ***************************************************************************************
; ** Graphics tools
; ** Require setup.asm & lbmtool.asm

MAX_LBM_FILES   equ 5

.DATA
; We can allow up to 10 color maps (limit completely arbitrary - about 4kb)
COLORMAPS    db 3 * 256 * MAX_LBM_FILES dup (0)
SCREEN_PTR   dw MAX_LBM_FILES dup (0)           ; segments to be allocated for images
FADEWAITITR  dw 5
IMG_COUNTER  db 0
VIDEO_BUFFER dw 0

ERR_BUFFER   db "Could not allocate memory for the video buffer", 13, 10, "$"

; ************************************************************************************
; ** A few macros
DETECT_VSYNC MACRO
    ; Detect vsync - will modify ax and dx
    mov dx, 03dah
WaitNotVSyncMACRO:
    ;wait to be out of vertical sync
    in al, dx
    and al, 08h
    jnz WaitNotVSyncMACRO
WaitVSyncMACRO:
    ;wait until vertical sync begins
    in al, dx
    and al, 08h
    jz WaitVSyncMACRO
ENDM

; ************************************************************************************
; ** real code is here
.CODE

SWITCH_TO_320x200:
    mov ax, 0013h
    int 10h
    ret
    
    
CREATE_VIDEOBUFFER:
    ; code to create the second screen buffer
    ; automatically allocate 64kb
    mov bx, 0fa0h
    mov ah, 48h
    int 21h
    
    jc CantAllocateMemoryForBuffer
    mov [VIDEO_BUFFER], ax
    ret


FREE_VIDEOBUFFER:
    ; free it
    ret
    

FREE_SEGMENT_IMG:
    ; code to free the memory allocated to an image
    ; AL is the number of the image
    ret


FREE_ALL_IMG_MEMORY:
    ; loop over SCREEN_PTR and free all memory
    ret


EXTRACT_IMG:
    ; call lbmtool to decompress a LBM file.
    ; SI must point to the file info with the format:
    ; FILEHANDLE (1w) + FILESIZE (2w - big endian) + FILESEGMENT (1w)
    ; IMG_PTR points to the data segment for the image (to get back and store in SCREEN_PTR)
    ; the colormap in lbmtool also need to be copied over in the right location in COLORMAPS
    
    call READ_LBM
    
    pusha
       
    ; save pointer to buffer
    mov si, offset SCREEN_PTR
    mov al, [IMG_COUNTER]
    xor ah, ah
    add si, ax
    mov ax, [IMG_PTR]
    mov [si], ax
    
    ; transfer colormap
    push ds
    pop es
    mov si, offset CMAP_BUFFER
    mov di, offset COLORMAPS
    
    mov cl, [IMG_COUNTER]
    mov bx, 300h
    xor ch, ch
    xor ax, ax
    inc cx
shift_pos:    
    add ax, bx
    dec cx
    jnz shift_pos
    sub ax, bx
    
    add di, ax
    mov cx, bx
    rep movsb
    
    ; now increase the counter
    mov al, [IMG_COUNTER]
    inc al
    mov [IMG_COUNTER], al
    
    popa    
    ret
 

SET_PALETTE:
    ret


BLACKOUT:
    ret
    
  
FADOUT:
    ; Create a fade-in effect
    ; DX is the color map number
   ret
 
   
FADEIN:
    ; Create a fade-in effect
    ; DX is the color map number
    pusha
    
    mov di, offset FADEWAITITR
    
    ; bl = max number of iteration (4bit coded so 1111b is enough)
    ; we start at ah = 0
    mov bl, 1111b
    mov ah, 0
FadeInIterate:    
    ; now set colors 
    mov cx, 256 * 3
    mov si, offset COLORMAPS
      
    mov dx, 03c8h
    xor al, al
    out dx, al
    
    mov dx, 03c9h
    cli
FadeInColorLoop:
    ; set the red/green/blue component
    lodsb
    and al, 1111b
    ; if greater than ah, use ah - otherwise use rgb
    ; this is effectively min(rgb, ah)
    cmp al, ah
    jb use_al_fadein
    mov al, ah
use_al_fadein:    
    shl al, 2
    out dx, al

    loop FadeInColorLoop
    sti
    
    ; then we wait a few iteration of the Vsync scan
    ; so it doesn't go too fast
    mov cx, [di]
FadeInMultipleScan:
    mov dx, 03dah
WaitNotVSyncFadeIn:
    in al, dx
    and al, 08h
    jnz WaitNotVSyncFadeIn
WaitVSyncFadeIn:
    in al, dx
    and al, 08h
    jz WaitVSyncFadeIn
    DETECT_VSYNC
    loop FadeInMultipleScan
    
    inc ah
    dec bl
    jnz FadeInIterate
    
    popa
    ret
    
    
; ********************************************************************************************
; ********************************************************************************************
; ** Various functions
CantAllocateMemoryForBuffer:
    ; This routine is called if DOS can't allocate the requested memory
    mov dx, offset ERR_BUFFER
    jmp Grafx_FileErrorMsgAndQuit
    
Grafx_FileErrorMsgAndQuit:
    ; Routine display the corresponding error message and exit
    call RESET_SCREEN
    mov ah, 9
    int 21h
    
    jmp ENDPROG