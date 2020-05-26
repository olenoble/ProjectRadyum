.MODEL SMALL
.STACK 100H
.386

.DATA
FILENAME    db "IMGTEST.LBM", 0
FILEHANDLE  dw 0
FILEBUFFER  db 65521 dup (0)

.CODE

MAIN PROC
    mov ax, @DATA
    mov ds, ax    
    
    ; Lire un fichier - ah = 3Dh
    ; al = contient les access mode (0 = read only / 1 = write only / 2 = read & write)
    ; dx pointe sur le nom du ficher
    mov dx, offset FILENAME
    mov ax, 3d00h
    int 21h
 
    ; Le handle du fichier est renvoye dans ax
    ; en cas d'erreur le flag carry est a 1
    mov [FILEHANDLE], ax
    
    ; On lit maintenant le fichier - ah = 3Fh
    ; bx contient le handle
    ; cx la taille (maximale) a lire (si le fichier est plus petit, DOS s'arretera avant)
    ; dx pointe sur le buffer
    mov bx, [FILEHANDLE]
    mov cx, 65535
    mov dx, offset FILEBUFFER
    mov ah, 3fh
    int 21h
    

    ; On peut maintenant fermer le fichier - ah = 3Eh
    ; bx contient le handle
    mov bx, [FILEHANDLE]
    mov ah, 3eh
    int 21h
   
    
MAIN ENDP

END MAIN