.386
public func6

data segment use16 para public 'data'
      message   db 0dh, 0ah, "Please input a number between 1 and 8 to play (Input 0 to quit): ", '$'
      nextline  db 0dh, 0ah, '$'
      tune      dw 0
      frequency dw 0, 261, 293, 329, 349, 392, 440, 493, 523

data ends

stack segment use16 para public 'stack'
      cache dw 50 dup(0)
stack ends

code segment use16 para public 'code'
                 assume ds:data,ss:stack,cs:code

func6 proc far
      start:     
                 mov    ax, data
                 mov    ds, ax
                 mov    si, 0
                 mov    di, 0
                 mov    bx, 0
                 mov    cx, 0
                 call   B10SCRN

                 lea    dx, message
                 mov    ah,09h
                 int    21h

      next:      call   input                         ;0027
                 cmp    tune, 0
                 je     exit
                 call   play
                 jmp    next

      exit:      in     al, 61h
                 and    al, 11111100b
                 out    61h, al
                 mov    tune, 0
                 retf
func6 endp

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

input proc near
      loop1:     mov    bx,400h
      loop2:     mov    cx,00ffh
      loop3:     mov    ah,01h
                 int    16h
                 jnz    next_step1
                 loop   loop3
                 dec    bx
                 jnz    loop2

      error:     mov    ah,01h
                 in     al,61h
                 and    al,11111100b
                 out    61h,al
                 jmp    loop1

      next_step1:mov    ah,00h
                 int    16h
                 cmp    al,30h
                 jb     error
                 cmp    al,38h
                 ja     error

                 sub    al,30h
                 mov    ah,0
                 mov    tune,ax

                 in     al,61h
                 or     al,00000011b
                 out    61h,al
                 ret
input endp

play proc near
                 push   ax
                 push   dx
                 mov    si, tune
                 add    si,si
                 mov    dx,12H
                 mov    ax,34DEH
                 div    frequency[si]

                 out    42h,al
                 mov    al,ah
                 out    42h,al
                 pop    dx
                 pop    ax
                 ret
play endp

code ends
end start

