; ***************************************************************************************
; ***************************************************************************************
; ** Tools for keyboard management
; ** Require setup.asm

KEY_BUFFER_SIZE equ 1

.DATA 
OLD_INT9_ADDR   dw 2 dup (?)
KEY_BUFFER      db KEY_BUFFER_SIZE dup (0)
KEY_BUFFER_PTR  dw 0

.CODE
INT9_SETUP:
    
    pusha
    push es
    
    ; Get current address of int 9 and save it
    mov al, 09h
    mov ah, 35h
    int 21h
    mov [OLD_INT9_ADDR], bx
    mov [OLD_INT9_ADDR + 2], es
    
    ; Set new interrupt
    push ds
    mov ax, cs
    mov ds, ax
    mov al, 09h
    lea dx, cs:[BespokeInt9]
    mov ah, 25h
    int 21h
    
    pop ds
    pop es
    popa
    ret
    
INT9_RESET:
    ; Before exiting, we must reset int9 to its former address
    push ax
    push dx
    push ds
    
    mov dx, [OLD_INT9_ADDR]
    mov ax, [OLD_INT9_ADDR + 2]
    mov ds, ax
    mov al, 09h
    mov ah, 25h
    int 21h  
    
    pop ds
    pop dx
    pop ax
    
    ret
    

READ_KEY_WAIT:
    ; function reads the buffer and wait for a key to be pressed
    ; AL contains the key code

    push si
    push bx
    
    lea si, [KEY_BUFFER]
    @@wait_key:
        mov bx, [KEY_BUFFER_PTR]
        or bx, bx
        jz @@wait_key
    
    ; adjust the buffer
    dec bx
    mov [KEY_BUFFER_PTR], bx
    
    mov al, [si+bx]
    
    pop bx
    pop si
    ret


READ_KEY_NOWAIT:
    ; function reads the buffer and returns pressed key (if any)
    ; routine does not wait for a key to be pressed
    ; AL contains the key code - AH is also modified
    mov ax, [KEY_BUFFER_PTR]
    or ax, ax
    jz @@return_no_key
    
    ; adjust the buffer
    push si
    mov si, offset KEY_BUFFER
    dec ax
    mov [KEY_BUFFER_PTR], ax
    add si, ax
    mov al, [si]
    pop si

    @@return_no_key:
    ret

PURGE_KEY_BUFFER:
    ; purge the key buffer (effectively just setting KEY_BUFFER_PTR to 0)
    ; disable interrput first to make sure keyboard doesn't get call at the same time
    cli
    push ax
    push di
    push ds

    mov ax, @DATA
    mov ds, ax
    mov di, offset KEY_BUFFER_PTR
    mov [di], ax

    pop ds
    pop di
    pop ax
    sti
    ret


; ***************************************************************************************
; ** Below is my new int9
BespokeInt9:

    ; if you want to keep calling the previous interrupt - add something like this
    ;push si
    ;push es
    ;mov si, [OLD_INT9_ADDR]
    ;mov ax, [OLD_INT9_ADDR + 2]
    ;mov es, ax
    ;call es:si
    ;pop es
    ;pop si

    ;cli     ; stop all interrupts
    push ax

    in al, 60h
    mov ah, al

    ; is it an up key (which we don't care about)
    and ah, 80h
    jnz @@end_int9

    push bx
    push si
    push ds
    
    mov bx, @DATA
    mov ds, bx

    ; si points to buffer and dx is the current position
    mov si, offset KEY_BUFFER
    mov bx, [KEY_BUFFER_PTR]
    ; if overflow then don't bother storing it
    inc bx
    cmp bx, KEY_BUFFER_SIZE + 1
    jz @@pre_end_int9
    
    mov [KEY_BUFFER_PTR], bx
    dec bx
    add si, bx
    mov [si], al

    @@pre_end_int9:
        pop ds
        pop si
        pop bx
        
    @@end_int9:

        ; it seems that this bit below is necessary... but it works without
        in al, 61h
        mov ah, al
        or al, 80h
        out 61h, al
        xchg al, ah
        out 61h, al
        
        ; End of interrupt (that is necessary!)
        mov al, 20h
        out 20h, al
    
    pop ax
    ;sti
    iret
