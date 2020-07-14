        ; refresh screen and display sprite
        push ds
        mov ax, [SCREEN_PTR+2]
        mov ds, ax
        call DISPLAY_TILESCREEN_FAST
        call DISPLAY_SPRITE_FAST
        call COPY_VIDEOBUFFER

        ;; redraw the meta tile around the character
        ;pop ds
        ;push bx
        ;mov bx, [CHAR_POS_Y]
        ;mov di, [CHAR_POS_X]
        ;and bx, 0FFF0h
        ;and di, 0FFF0h

        ;push ds
        ;mov ax, [SCREEN_PTR+2]
        ;mov ds, ax    
        
        ;; need to divide CHAR_POS_X by 16 and multiply x2 --> divide by 8
        ;mov si, di
        ;shr si, 3
        ;; divide bx by 16 to get the row in tile
        ;; need then to multiply by 40 (20 tiles per row x 2 bytes)
        ;; since 40 = 32 + 8 --> bx / 16 * 40 = bx * 2 + bx / 2

        ;mov ax, bx
        ;shl ax, 1
        ;add si, ax
        ;mov ax, bx
        ;shr ax, 1 
        ;add si, ax

        ;call MULTIPLYx320
        ;add di, bx
        ;mov bx, si
        ;add bx, 320*200 + 200
        ;call DISPLAY_METATILE_FAST        
        pop ds
        ;pop bx