.MODEL SMALL
.386

.STACK 1024

.DATA

msg_memsize         db "You have $"
msg_memsize2        db "kb of memory available", 13, 10, "$"
memory_size         db 5 dup(0)

segment_pos         db "Segment Position $"
segment_pos2        db "h", 13, 10, "$"
segment_val         dw 0

MSG0        db 13, 10, "Instantiate Memory", 13, 10, "$"
MSG1        db 13, 10, "Loading LBM file", 13, 10, "$"
MSG2        db 13, 10, "Extract image", 13, 10, "$"
MSG3        db 13, 10, "Free LBM file", 13, 10, "$"
MSG4        db 13, 10, "Allocate video buffer", 13, 10, "$"
MSG5        db 13, 10, "Free image", 13, 10, "$"
MSG6        db 13, 10, "Free buffer", 13, 10, "$"

LBMPTR      dw 0
IMGPTR      dw 0
BUFPTR      dw 0

.CODE

; **********************************************
; **********************************************
; ** Main Loop
MAIN PROC    
    
    ; ********************************************
    ; **** MEMORY TIME0
    mov ax, @DATA
    mov ds, ax
    mov dx, offset MSG0
    mov ah, 9
    int 21h

    call MemoryStillAvail

    mov ax, es
    mov [segment_val], es
    call PrintSegment

    ; Subtract SS and ES (do not modify either!)
    mov bx, ss
    mov ax, es
    sub bx, ax
    
    ; Find the end of the stack and shift 4bits to the rights
    ; Also add 2 to be safe
    mov ax, sp
    add ax, 0fh
    shr ax, 4
    
    ; now add both and adjust
    add bx, ax
    mov ah, 4Ah
    int 21h
    
    call MemoryStillAvail
    
    ; ********************************************
    ; **** LOAD LBM
    mov dx, offset MSG1
    mov ah, 9
    int 21h

    mov bx, 35000
    shr bx, 4
    mov ah, 48h
    int 21h

    mov [LBMPTR], ax    

    call MemoryStillAvail

    mov [segment_val], ax
    call PrintSegment
    
    ; ********************************************
    ; **** ALLOCATE SPACE FOR IMG
    mov dx, offset MSG2
    mov ah, 9
    int 21h
    
    mov bx, 64000
    shr bx, 4
    mov ah, 48h
    int 21h

    mov [IMGPTR], ax

    call MemoryStillAvail

    mov [segment_val], ax
    call PrintSegment
    
    ; ********************************************
    ; **** FREE LBM
     mov dx, offset MSG3
     mov ah, 9
     int 21h   
    
    mov ax, [LBMPTR]
    mov es, ax
    mov ah, 49h
    int 21h

    call MemoryStillAvail
    
    ; ********************************************
    ; **** ALLOCATE BUFFER
    mov dx, offset MSG4
    mov ah, 9
    int 21h

    mov bx, 64000
    shr bx, 4
    mov ah, 48h
    int 21h

    mov [BUFPTR], ax
    
    call MemoryStillAvail

    mov [segment_val], ax
    call PrintSegment
    
    ; ********************************************
    ; **** FREE IMG
     mov dx, offset MSG5
     mov ah, 9
     int 21h   
    
    mov ax, [IMGPTR]
    mov es, ax
    mov ah, 49h
    int 21h

    call MemoryStillAvail

    ; ********************************************
    ; **** FREE BUFFER
     mov dx, offset MSG6
     mov ah, 9
     int 21h   
    
    mov ax, [BUFPTR]
    mov es, ax
    mov ah, 49h
    int 21h

    call MemoryStillAvail

    ; ********************************************
    ; **** FREE BUFFER
    mov ah, 4ch
    int 21h
    
MAIN ENDP

MemoryStillAvail:
    pusha
    push ds
    
    mov ax, @DATA
    mov ds, ax
    
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

    mov di, offset memory_size
    mov cx, 5
    call clear_ascii    
    
    mov dx, offset msg_memsize2
    mov ah, 9
    int 21h

    pop ds
    popa
    ret
    
; Very simple algo to convert a 16bit number in AX into an ASCII equivalent
convert_ax_ascii:    
    ; AX = number to convert
    ; DI = address to store the output (assume ds for segment) 
    ; Note that the data is stored backwards (i.e. "640" will be stored "046")
    
    push ax
    push bx
    push dx
    push di
    
    mov bx, 10
    ; The algo is about dividing by 10 the output
    ; and convert the remainder to ASCII
    @@decimal_conv:
        xor dx, dx
        div bx
        add dl, 30h
        mov [di], dl
        inc di
        or ax, ax
        jnz @@decimal_conv
    
    pop di
    pop dx
    pop bx
    pop ax
    ret 

print_ascii:
    ; CX = size of string
    ; SI = address of the string to print out (assume characters are stored in reverse)
    
    push si
    push cx
    push ax
    push dx

    add si, cx
    dec si

    mov ah, 02h
    @@print_check:
        mov dl, [si]
        or dl, dl
        jz @@noprint  ; do not print if you find 0
        int 21h
    @@noprint:
        dec si
        dec cx
        jnz @@print_check
    
    pop dx
    pop ax
    pop cx
    pop si
   
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
    

PrintSegment:
    pusha
    
    mov dx, offset segment_pos
    mov ah, 9
    int 21h

    mov cl, 10h

    @@LoopPrint:
        sub cl, 4
        mov dx, [segment_val]
        shr dx, cl
        and dx, 0fh

        cmp dl, 9
        jng @@ShiftVal
        add dl, 7
    @@ShiftVal:
        add dl, 30h

        mov ah, 02h
        int 21h

        or cl, cl
        jnz @@LoopPrint

    mov dx, offset segment_pos2
    mov ah, 9
    int 21h

    popa
    ret
    
END MAIN

