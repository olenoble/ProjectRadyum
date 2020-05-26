.MODEL SMALL
.STACK 100H
.386

.DATA 
MSG db "Welcome User", 13, 10, "$"
MSG2 db "Please Press Enter:  $"


TEXT_BUF_SIZE db 255
TEXT_BUF_READ db 1 dup (?)
BUFFER db 255 dup (?)

.CODE

MAIN PROC
    mov ax, @DATA
    mov ds, ax
    
    ; Switch to 320x200 256 colors
    mov ax, 0013h
    int 10h
    
    ; Welcome message
    mov dx, offset MSG
    mov ah, 9
    int 21h
    
    ; Ask user to type something
    mov dx, offset MSG2
    mov ah, 9
    int 21h
    
    ; This is how the text is captured. In .DATA, there need to be (back to back)
    ; 1 byte showing the max number of character to be read
    ; 1 byte that will contain the size of the string that was read (returned by the interrupt)
    ; A buffer (whose size is consistent with the max length) to store the text (also returned by the interrupt)
    mov dx, offset TEXT_BUF_SIZE
    mov ah, 0ah
    int 21h
    
    ; Now skippinh some lines - ah = 2h / int 21h prints a character
    ; dl = 10 is a new line - dl = 13 is the carriage return
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h

    ; Now I print again the text - to make sure I had it right
    mov cl, TEXT_BUF_READ
    mov si, offset BUFFER
    mov ah, 02h
    print_check:
    mov dl, ds:[si]
    int 21h
    inc si
    dec cl
    jnz print_check
    
    ; Now wait for user pressing ESC
wait_key:
    xor cx, cx
wait_loop:
    in al, 64h
    and al, 10b
    ;jnz wait_loop
    loopnz wait_loop
    
    in al, 60h
    
    mov ah, al
    and ah, 80h
    jnz  wait_key       ; if it was a key up, go back and wait
    
    mov dl, al
    mov ah, 02h
    int 21h
        
    xor dl, 1
    jnz wait_key

    ; Back to text mode
    mov ax, 0003h
    int 10h
    
    mov ah, 4ch
    int 21h

    
    ;MOV     AL,09h                    ; Get INT 09h address
    ;MOV     AH,35h
    ;INT     21h
    ;MOV     [oldint9],BX              ; Save it for later
    ;MOV     [oldint9+2],ES
    ;MOV     AL,09h                    ; Set new INT 09h
    ;MOV     DX,Newint9        ; DS:DX = new interrupt
    ;MOV     AH,25h
    ;INT     21h         
    
    ;Newint9: pusha   ;Do some thing here       
    ;        mov     al, 0x20
    ;        out     0x20, al        ; If you do something like, jump exit do it here, after the above code.     
    ;        popa
    ;        IRET
    
MAIN ENDP

END MAIN