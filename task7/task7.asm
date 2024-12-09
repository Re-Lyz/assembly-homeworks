.386
data segment use16 para public 'data'
    message db 0dh, 0ah, "Please input a number to choose a sub program: "
            db 0dh, 0ah, "1--Sum and sort ten numbers between -99999 and 99999"
            db 0dh, 0ah, "2--Dynamic and colorful title bar and draw circles"
            db 0dh, 0ah, "3--Convert a hexadecimal number into decimal number"
            db 0dh, 0ah, "4--Simple electronic piano"
            db 0dh, 0ah, "5--Exit", 0dh, 0ah, '$'
data ends

stack segment use16 para public 'stack'
    cache dw 50 dup(?)
stack ends

code segment use16 para public 'code'
            assume cs:code, ds:data, ss:stack

            extrn  func3:far
            extrn  func4:far
            extrn  func5:far
            extrn  func6:far

    start:  
            mov    ax, data
            mov    ds, ax
            mov    ax, stack
            mov    ss, ax
            lea    ax, cache[50]
            mov    sp, ax
            mov    si, 0
            mov    di, 0
            mov    bx, 0
            mov    cx, 0
            call   B10SCRN

            lea    dx, message
            mov    ah,09h
            int    21h

            mov    ah,01h
            int    21h

            cmp    al, '1'
            jne    line1
            call   far ptr func3
            jmp    start

    line1:  cmp    al, '2'
            jne    line2
            call   far ptr func4
            jmp    start

    line2:  cmp    al, '3'
            jne    line3
            call   far ptr func5
            jmp    start

    line3:  cmp    al, '4'
            jne    line4
            call   far ptr func6
            jmp    start

    line4:  cmp    al, '5'
            jne    start
            mov    ax, 4c00h
            int    21h


B10SCRN proc near
                       mov    ax, 03h
                       int    10h
                       mov    ax,0600h
                       mov    bh,07h
                       mov    cx,0000h
                       mov    dx,184fh
                       int    10h
                       mov    ah, 09h
                       mov    al, ' '
                       mov    bh, 0
                       mov    bl, 0Fh
                       mov    dl, 00h
                       int    10h
                       ret
B10SCRN endp

code ends
end start
