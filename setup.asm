; ***************************************************************************************
; ***************************************************************************************
; ** Basic setup and functions for asm programs

.DATA
ERRORMSG_MEMRESIZE  db "Could not resize memory", 13, 10, "$"
GOODBYE_MSG         db 13, 10, 13, 10, "Thanks for using Radyum", 13, 10, "$"


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
    ; Also add 2 to be safe
    mov ax, sp
    add ax, 0fh
    shr ax, 4
    ; inc ax
    
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
