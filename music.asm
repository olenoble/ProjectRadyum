; ***************************************************************************************
; ***************************************************************************************
; ** Music - basic interface to call modplay.lib
; ** Require ...


.DATA
PSP_ES              dw 0
ERROR_SOUNDDRIVE1   db "Cannot initialize sound driver...", 13, 10, "$"
ERROR_SOUNDDRIVE2   db "Unable to load module file...", 13, 10, "$"


.CODE

START_MUSICDRIVER:
    mov ax, @DATA
    mov ds, ax
    mov [PSP_ES], es
    xor bx, bx
    xor ax, ax
    call far ptr Mod_Driver  ; Detection & Initialization
    or ax, ax
    jnz @@found_modfile
    
    ; error if can't initialize music
    mov dx, OFFSET ERROR_SOUNDDRIVE1
    mov ah, 9
    int 21h
    jmp @@end_music_init
    
    @@found_modfile:        
        call far ptr [Mod_End_Seg]   ; returns: ax=end segment
        mov bx, ax
        mov ax, [PSP_ES]
        mov es, ax
        sub bx, ax           ; bx=prog length in paragraphs
        mov ah, 4Ah
        int 21h              ; set memory control block
        mov bx, 2
        mov dx, OFFSET MOD_FILE
        call far ptr Mod_Driver  ; load module in ds:dx
        or ax, ax
        jnz @@end_music_init

        ; error if mod file not found
        mov dx,OFFSET ERROR_SOUNDDRIVE2
        mov ah, 9
        int 21h
        jmp END_MUSICDRIVER

    @@end_music_init:
        ret


START_MUSIC:        
    mov bx, 3
    mov ax, 1
    call far ptr Mod_Driver  ; start playing, looping is on
    ret


END_MUSICDRIVER:
    mov bx, 1
    call far ptr Mod_Driver
    ret

