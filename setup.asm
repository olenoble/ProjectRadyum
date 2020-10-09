; ***************************************************************************************
; ***************************************************************************************
; ** Basic setup and functions for asm programs

.DATA
ERRORMSG_MEMRESIZE  db "Could not resize memory", 13, 10, "$"
GOODBYE_MSG         db 13, 10, 13, 10, "Thank you for playing. Hope you enjoyed it !", 13, 10, "$"


.CODE
SETUP:
    ; Set up some basic stuff for the code at start
    ; i.e. freeing unnecessary memory
    ; Should be called at start (otherwise stack size may not be estimated properly)
    ; Registers are changed
    
    ; Resize the memory allocated to our program
    ; Subtract SS and ES (do not modify either!)
    mov bx, ss
    mov ax, es
    sub bx, ax
    
    ; Find the end of the stack and shift 4bits to the rights
    ; Also add 1 to be safe
    mov ax, sp
    add ax, 0fh     ; that's to make sure we can round up
    shr ax, 4
    inc ax
    
    ; now add both and adjust
    add bx, ax
    mov ah, 4Ah
    int 21h
    jc CantResizeMemory
    
    ; also place DS on the data segment by default
    mov ax, @DATA
    mov ds, ax

    ret


RESET_SCREEN:
    ; go back to text mode - this function modifies AX
    mov ax, 0003h
    int 10h
    ret


ENDPROG:
    ; This is simply the end of program
    ; reset the screen - display a nice message and exit back to DOS
    
    mov dx, offset GOODBYE_MSG
    mov ah, 09h
    int 21h

    ; free memory
    mov ax, [BUFFER_PTR]
    mov es, ax
    mov ah, 49h
    int 21h
    
    call MemoryStillAvail
    
    mov ah, 4ch
    int 21h


; ********************************************************************************************
; ********************************************************************************************
; ** Various functions
CantResizeMemory:
    call RESET_SCREEN
    ; This routine is called if DOS can't resize the program memory
    mov ax, @DATA
    mov ds, ax
    
    mov dx, offset ERRORMSG_MEMRESIZE
    mov ah, 9
    int 21h
    
    jmp ENDPROG

; Function to call to check how much memory is still available
MemoryStillAvail:
    pusha
    push ds
    
    mov ax, @DATA
    mov ds, ax

    ; clear the string first before writing down the size
    mov di, offset memory_size
    mov cx, 5
    call clear_ascii
    
    mov bx, 0ffffh
    mov ah, 48h
    int 21h
    
    mov ax, bx
    shr ax, 6
    
    ; convert it to ASCII
    mov di, offset memory_size
    call convert_ax_ascii
    
    ; Then print it out
    mov dx, offset msg_memsize
    mov ah, 9
    int 21h
    
    mov si, offset memory_size
    mov cx, 5
    call print_ascii
    
    mov dx, offset msg_memsize2
    mov ah, 9
    int 21h

    pop ds
    popa
    ret

clear_ascii:
    ; CX = size of string
    ; DI = address of the string to clear
    
    push di
    push cx
    push ax
    push es

    push ds
    pop es
    xor ax, ax
    rep stosb

    pop es
    pop ax
    pop cx
    pop di

    ret