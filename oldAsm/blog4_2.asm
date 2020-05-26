.MODEL LARGE
.STACK 100H
.386

.STACK 4096

.DATA
FILENAME    db "C:\IMG_TEST.LBM", 0
ERRMSG1     db "Could not open file", 13, 10, "$"
ERRMSG2     db "Could not read file", 13, 10, "$"
ERRMSG3     db "Could not close file", 13, 10, "$"
ERRMSG4     db "Could not allocate memory", 13, 10, "$"
ERRMSG5     db "Could not resize memory", 13, 10, "$"
DONEMSG     db "All good - Bye!", 13, 10, "$"

FILEHANDLE  dw 0
FILESIZE    dw 0
FILESEGMENT dw 0
    
TESTxxx db 24000 dup (0)

.CODE

MAIN PROC

    ; Resize the memory allocated to our program
    ; Subtract SS and ES (do not modify either!)
    mov bx, ss
    mov ax, es
    sub bx, ax
    
    ; Find the end of the stack and shift 4bits to the rights
    ; Also add 2 to be safe
    mov ax, sp
    ;add ax, 0Fh
    shr ax, 4
    inc ax
    
    ; now add both and adjust
    add bx, ax
    mov ah, 4Ah
    int 21h
    jc CantResizeMemory
      
    call INTRO

    mov ax, @DATA
    mov ds, ax
    
    ; Open file
    mov dx, offset FILENAME
    mov ax, 3d00h
    int 21h
    
    jc CantOpen
    
    ; Save the handle
    mov [FILEHANDLE], ax
    
    ; now we need to detect the size of the file - move to the end
    mov bx, ax
    mov ax, 4202h
    mov cx, 0
    mov dx, 0
    int 21h
    
    ; a bit lazy here - reusing the same error message
    jc CantRead
    mov [FILESIZE], ax
    
    ; Now we can allocate memory as needed
    mov bx, ax
    shr bx, 4
    mov ah, 48h
    int 21h
    
    jc CantAllocateMemory
    mov [FILESEGMENT], ax
        
    ; Remember we need to get back to the beginning of the file
    mov bx, ax
    mov ax, 4200h
    mov cx, 0
    mov dx, 0
    int 21h

    ; Now read file - save ds and point to the new segment
    ; dx can be zero since we start at the beginning of the segment
    push ds
    mov bx, [FILEHANDLE]
    mov ax, [FILESEGMENT]
    mov ds, ax
    mov cx, [FILESIZE]
    mov dx, 0
    mov ah, 3fh
    int 21h
    pop ds
    
    jc CantRead

    ; now close the file
    mov ah, 3eh
    int 21h
    
    jc CantClose
    
    mov dx, offset DONEMSG
    mov ah, 9
    int 21h
    
    ; remember to free up the requested memory
    mov ax, [FILESEGMENT]
    mov es, ax
    mov ah, 49h
    int 21h
    
endmain:   
    mov ah, 4ch
    int 21h


; list of error functions
CantOpen:
    ; This routine is called if DOS can't access the file
    mov dx, offset ERRMSG1
    mov ah, 9
    int 21h
    jmp endmain

CantRead:
    ; This routine is called if DOS can't read the file
    mov dx, offset ERRMSG2
    mov ah, 9
    int 21h
    jmp endmain
        
CantClose:
    ; This routine is called if DOS can't close the file
    mov dx, offset ERRMSG3
    mov ah, 9
    int 21h
    jmp endmain

CantAllocateMemory:
    ; This routine is called if DOS can't allocate the requested memory
    mov dx, offset ERRMSG4
    mov ah, 9
    int 21h
    jmp endmain

CantResizeMemory:
    ; This routine is called if DOS can't resize the program memory
    mov dx, offset ERRMSG5
    mov ah, 9
    int 21h
    jmp endmain  
   
MAIN ENDP

    ; **********************************************
    ; **********************************************
    ; ** Include files here
    INCLUDE intro.asm

    
END MAIN

