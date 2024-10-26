data segment

data ends

code segment
    assume cs:code, ds:data

start:
    mov ax, data
    mov ds, ax

    mov cx,40000

    s:
    nop
    loop s


    mov ax, 4c00h
    int 21h
code ends
end start