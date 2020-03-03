; ***************************************************************************************
; ***************************************************************************************
; ** Graphics tools
; ** Require setup.asm

MAX_LBM_FILES   equ 5

.DATA
; We can allow up to 10 color maps (limit completely arbitrary - about 4kb)
COLORMAPS   db 3 * 256 * MAX_LBM_FILES dup (0)
SCREEN_PTR  dw MAX_LBM_FILES dup (0)           ; segments to be allocated for images
FADEWAITITR dw 5


.CODE

; I think it makes more sense to call lbmtools from here so we can allocate the memory from here and 
; pass it on to lbmtool READ_LBM

FADEIN:
    ; Create a fade-in effect
    ; dx is the color map number
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
    loop FadeInMultipleScan
    
    inc ah
    dec bl
    jnz FadeInIterate
    
    popa
    ret