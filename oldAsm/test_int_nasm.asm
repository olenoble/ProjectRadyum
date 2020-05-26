;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keyboard int 09 driver ver: 1.4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;keywait    wait for change from keyboard scancode >> ax
;keyadr     si<=adr of NAME of keycode in ax
;int09i     install int 09
;int09u     uninstall int 09
;int09      update tab press/pop status (0=pop,255=pressed) and key...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;key.ascii  ASCII key code      byte
;key.scan   tab key code        word
;key.name   adr of key name in tab  word
;key.tab0/1/2   scan(Byte) ,pressed/poped,ASCII,ASCIIZ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutines: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
keywait:mov ax,[cs:key.scan];wait for change from keyboard scancode >> ax
.l0:    cmp ax,[cs:key.scan]
    jz  .l0
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
keyadr: push    ax      ;si<=adr of NAME of keycode ax
    cmp ax,197+512      ;not if Pause or Break
    jz  .q0
    cmp ax,198+512
    jz  .q0
    and al,127
.q0:    lea si,[cs:key.tab0]
    cmp ah,0
    jz  .r0
    lea si,[cs:key.tab1]
    cmp ah,1
    jz  .r0
    lea si,[cs:key.tab2]
    cmp ah,2
    jz  .r0
    jmp .err
.r0:    xchg    al,ah
.l0:    mov al,[cs:si]
    add si,3
    cmp al,ah
    jz  .esc
    cmp al,255
    jz  .err
.l1:    mov al,[cs:si]
    inc si
    or  al,al
    jnz .l1
    jmp .l0
.err:   lea si,[cs:.errkey]
.esc:   pop ax
    ret
    db      1,0,'?'
.errkey:db  'Unknown key',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int09i: pusha           ;install int 09
    push    es
    mov     al,9h
    mov     ah,35h
    int     21h
    mov     [cs:int09.vect],bx
    mov     [cs:int09.vect+2],es
    mov     al,9h
    mov     ah,25h
    lea     dx,[cs:int09]
    int     21h
    pop es
    popa
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int09u: push    ds      ;uninstall int 09
    pusha
    mov     dx,[cs:int09.vect]
    mov     ax,[cs:int09.vect+2]
    mov     ds,ax
    mov     al,9h
    mov     ah,25h
    int     21h
    popa
    pop     ds
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Prerusenia: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int09:  cli         ;keyboard
    pusha
    in  al,60h
    mov bx,[cs:key.stat]
    cmp bl,1
    jz  .r1
    cmp bl,2
    jz  .r2
.r0:    inc bl      ;level0 ... first byte of scan code
    cmp al,0E0h
    jz  .esc
    inc bl
    mov bh,5
    cmp al,0E1h
    jz  .esc
    sub ah,ah       ;normal code
    mov [cs:key.scan],ax
    sub bx,bx
    jmp .esc
.r1:    mov bx,2+256*2  ;level1 ... second byte of scan code
    cmp al,2Ah
    jz  .esc
    cmp al,46h
    jz  .esc
    cmp al,0AAh
    jz  .esc
    mov ah,1        ;extended1 code
    mov [cs:key.scan],ax
    sub bx,bx
    jmp .esc
.r2:    dec bh
    jnz .esc
    mov ah,2        ;extended2 code
    mov [cs:key.scan],ax
    sub bx,bx
.esc:   mov [cs:key.stat],bx
    mov ax,[cs:key.scan]
    call    keyadr
    mov ah,[cs:si-1]    ;ASCII
    mov [cs:key],ah
    mov [cs:key.name],si;NAME ADR
    and al,128
    jz  .keyp1
.keyp0: sub ax,ax
    mov [cs:si-2],al
    mov [cs:key],al
    mov [cs:key.scan],ax
    mov [cs:key.name],word key.tab0+3
    jmp .esc0
.keyp1: mov [cs:si-2],byte 255
.esc0:  in  al,61h      ;end of interrupt ...this is a must
    mov     ah,al
    or  al,80h
    out     61h,al
    xchg    al,ah
    out     61h,al
    mov     al,20h
    out     20h,al
    popa
    sti
    iret
.vect:  dw  0,0

key:
.ascii  db  0       ;ASCII
.scan   dw  0       ;low=key code ,hi=tab 0,1,2
.name   dw  0       ;adr of key NAME

.stat:  db  0,0     ;byte count of code,number of readed byte

;tables:    scancode low(hi is tab 0,1,2),pressed/poped,ASCII,name,0
.tab0:  db      0,0,' ','                 ',0   ;basic scan codes
    db      1,0,'?','Esc',0
    db  2,0,'1','1',0
    db      3,0,'2','2',0
    db      4,0,'3','3',0
    db      5,0,'4','4',0
    db      6,0,'5','5',0
    db      7,0,'6','6',0
    db      8,0,'7','7',0
    db      9,0,'8','8',0
    db  10,0,'9','9',0
    db      11,0,'0','0',0
    db      12,0,'-','-',0
    db      13,0,'=','=',0
    db      14,0, 8 ,'Backspace',0
    db      15,0, 9 ,'Tab',0
    db      16,0,'Q','Q',0
    db      17,0,'W','W',0
    db      18,0,'E','E',0
    db      19,0,'R','R',0
    db      20,0,'T','T',0
    db      21,0,'Y','Y',0
    db      22,0,'U','U',0
    db      23,0,'I','I',0
    db      24,0,'O','O',0
    db      25,0,'P','P',0
    db      26,0,'[','[',0
    db      27,0,']',']',0
    db      28,0, 13,'Enter',0
    db      29,0,'?','L-Ctrl',0
    db      30,0,'A','A',0
    db      31,0,'S','S',0
    db      32,0,'D','D',0
    db      33,0,'F','F',0
    db      34,0,'G','G',0
    db      35,0,'H','H',0
    db      36,0,'J','J',0
    db      37,0,'K','K',0
    db      38,0,'L','L',0
    db      39,0,';',';',0
    db      40,0,'"','"',0
    db      41,0,'~','~',0
    db      42,0,'?','L-Shift',0
    db      43,0,'\','\',0
    db      44,0,'Z','Z',0
    db      45,0,'X','X',0
    db      46,0,'C','C',0
    db      47,0,'V','V',0
    db      48,0,'B','B',0
    db      49,0,'N','N',0
    db      50,0,'M','M',0
    db      51,0,',',',',0
    db      52,0,'.','.',0
    db      53,0,'/','/',0
    db      54,0,'?','R-Shift',0
    db      55,0,'*','Num *',0
    db      56,0,'?','L-Alt',0
    db      57,0,' ','Space',0
    db      58,0,'?','Caps Lock',0
    db      59,0,'?','F1',0
    db      60,0,'?','F2',0
    db      61,0,'?','F3',0
    db      62,0,'?','F4',0
    db      63,0,'?','F5',0
    db      64,0,'?','F6',0
    db      65,0,'?','F7',0
    db      66,0,'?','F8',0
    db      67,0,'?','F9',0
    db      68,0,'?','F10',0
    db      69,0,'?','Num Lock',0
    db      70,0,'?','Scroll Lock',0
    db      71,0,'7','Num 7',0
    db      72,0,'8','Num 8',0
    db      73,0,'9','Num 9',0
    db      74,0,'-','Num -',0
    db      75,0,'4','Num 4',0
    db      76,0,'5','Num 5',0
    db      77,0,'6','Num 6',0
    db      78,0,'+','Num +',0
    db      79,0,'1','Num 1',0
    db      80,0,'2','Num 2',0
    db      81,0,'3','Num 3',0
    db      82,0,'0','Num 0',0
    db      83,0,'.','Num .',0
    db      84,0,'?','Alt-Prnscr',0
    db      87,0,'?','F11',0
    db      88,0,'?','F12',0
    db      255
.tab1:  db      28,0,'?','Num Enter',0  ;scan codes after E0h
    db      29,0,'?','R-Ctrl',0
    db      53,0,'/','Num /',0
    db      55,0,'?','System Request',0
    db      56,0,'?','R-Alt',0
    db      71,0,'?','Home',0
    db      72,0,'?','Up',0
    db      73,0,'?','Page Up',0
    db      75,0,'?','Left',0
    db      77,0,'?','Right',0
    db      79,0,'?','End',0
    db      80,0,'?','Down',0
    db      81,0,'?','Page Down',0
    db      82,0,'?','Ins',0
    db      83,0,'?','Del',0
    db  93,0,'?','Win F2',0
    db      255
.tab2:  db  55,0,'?','Print Screen',0   ;scan codes after E0h AAh E0h
    db      53,0,'?','Shift-Num /',0
    db      71,0,'?','Shift-Home',0
    db      72,0,'?','Shift-Up',0
    db      73,0,'?','Shift-Page Up',0
    db      75,0,'?','Shift-Left',0
    db      77,0,'?','Shift-Right',0
    db      79,0,'?','Shift-End',0
    db      80,0,'?','Shift-Down',0
    db      81,0,'?','Shift-Page Down',0
    db  82,0,'?','Shift-Insert',0
    db  83,0,'?','Shift-Delete',0
    db  197,0,'?','Pause',0
    db  198,0,'?','Break',0
    db  255
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Scan codes constants: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.esc    equ 1
.n1 equ 2
.n2 equ 3
.n3 equ 4
.n4 equ 5
.n5 equ 6
.n6 equ 7
.n7 equ 8
.n8 equ 9
.n9 equ 10
.n0 equ 11
.minus  equ 12
.equal  equ     13
.bckspc equ     14
.tab    equ     15
.q  equ     16
.w  equ     17
.e  equ     18
.r  equ     19
.t  equ     20
.y  equ     21
.u  equ     22
.i  equ     23
.o  equ     24
.p  equ     25
.enter  equ     28
.lctrl  equ     29
.a  equ     30
.s  equ     31
.d  equ     32
.f  equ     33
.g  equ     34
.h  equ     35
.j  equ     36
.k  equ     37
.l  equ     38
.lshift equ     42
.z  equ     44
.x  equ     45
.c  equ     46
.v  equ     47
.b  equ     48
.n  equ     49
.m  equ     50
.rshift equ     54
.lalt   equ     56
.space  equ     57
.caps   equ     58
.f1 equ     59
.f2 equ     60
.f3 equ     61
.f4 equ     62
.f5 equ     63
.f6 equ     64
.f7 equ     65
.f8 equ     66
.f9 equ     67
.f10    equ     68
.f11    equ     87
.f12    equ     88

.rctrl  equ 256+29
.ralt   equ 256+56
.home   equ 256+71
.up equ 256+72
.pgup   equ 256+73
.left   equ 256+75
.right  equ 256+77
.end    equ 256+79
.down   equ 256+80
.pgdown equ 256+81
.insert equ 256+82
.delete equ 256+83
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; End. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;