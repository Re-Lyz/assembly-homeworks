data segment
    NUMB db 36h
    db 18h

data ends

code segment
    assume cs:code, ds:data

start:
    mov ax, data
    mov ds, ax

    mov ax,0

    mov al, [NUMB]
    mov bl, [NUMB+1]
    sub al, bl

    mov al, [NUMB]
    mov bl, [NUMB+1]
    div bl

    mov ax, 4c00h
    int 21h
code ends
end start
