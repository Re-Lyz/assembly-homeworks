assume  ds:data,ss:stack,cs:code
.486
screen MACRO
           mov ax,12h
           int 10h
           mov ah,0bh
           mov bx,0
           int 10h
ENDM

write MACRO x, y, color
          mov ah, 0ch
          mov bh, 0
          mov al, color
          mov cx, x
          mov dx, y
          int 10h
ENDM


data segment use16
    message1   db  '~~~DRAW A CIRCLE~~~'
    title_len  equ $-message1
    message2   db  'Enter the radius of the circle <=250: ',0ah,0dh,'$'
    message3   db  'Please enter a number between 1 and 250!',0ah,0dh,'$'

    buf        db  10 dup(?)
    radius_buf db  5
               db  ?
               db  5 dup(0)
    digit      dw  10
    radius     dw  0
    initsp     dw  0
    loop_time  db  0

    y          db  10
    colors     db  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    count      db  ?

data ends

stack segment use16
    cache dw 128 dup(?)
stack ends

code segment use16
    start:             mov    ax,stack
                       mov    ss,ax
                       lea    ax, cache[50]
                       mov    sp, ax
                       mov    ax,data
                       mov    ds,ax
                       mov    si, 0
                       mov    di, 0
                       mov    bx, 0
                       mov    cx, 0
                       call   B10SCRN
                       mov    ah,09h
                       lea    dx,message2
                       int    21h
                       call   ASCII2num
                       call   B10SCRN

                       mov    cx,title_len                     ;002d
                       mov    loop_time,cl
                       lea    si,message1                      ;0042
                       mov    dx,49
                       sub    dx,cx
                       mov    dh,10
    display_title_loop:
                       mov    bx,0
                       mov    ah,02h
                       int    10h
                       mov    ah,09h
                       mov    al,ds:[si]
                       mov    bh,0
                       mov    bl,colors[di]
                       mov    cx,1
                       int    10h
                       inc    si
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       dec    loop_time
                       cmp    loop_time,0
                       je     next_step
                       mov    ah,03h
                       int    10h
                       inc    dl
                       inc    di
                       cmp    di,11
                       jb     display_title_loop
                       mov    di,1
                       jmp    display_title_loop
    next_step:         
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       call   time_delay
                       screen

                       write  320, 240, 15
                       call   draw_circle
                       call   draw_square

                       mov    ah, 0
                       int    16h

                       mov    ax,4c00h
                       int    21h

B10SCRN proc near
                       mov    ax,0600h
                       mov    bh,07h
                       mov    cx,0000h
                       mov    dx,184fh
                       int    10h
                       ret
B10SCRN endp

time_delay proc near
                       mov    cx,65535
    delay:             nop
                       loop   delay
                       ret

time_delay endp

sqroot proc near
                       push   ax
                       push   bx
                       push   cx
                       mov    ax,si
                       sub    cx,cx
    again:             mov    bx,cx
                       add    bx,bx
                       inc    bx
                       sub    ax,bx
                       jc     over
                       inc    cx
                       jmp    again
    over:              mov    si,cx
                       pop    cx
                       pop    bx
                       pop    ax
                       ret
sqroot endp

ASCII2num proc near
    input:             mov    initsp,sp
                       mov    ah,0ah
                       lea    dx,radius_buf
                       int    21h
                       cmp    radius_buf+1, 0
                       je     input
                       mov    bl,radius_buf+1
                       mov    bh,0
                       mov    BYTE PTR[radius_buf+bx+2],0ah
                       mov    BYTE PTR[radius_buf+bx+3],24h
                       mov    ah,09h
                       lea    dx,radius_buf+2
                       int    21h
                       lea    bx,radius_buf+2
                       mov    cx,0
                       mov    eax,0
                       mov    dx,0
    s:                 mov    ax,ds:[bx]
                       cmp    ah,0ah
                       push   ax
                       je     next
                       inc    bl
                       jmp    s
    next:              pop    ax
                       lea    bx,cache[48]
    n:                 cmp    al,30h
                       jb     error
                       cmp    al,39h
                       ja     error
                       sub    al,30h
                       mov    ah,0h
                       mov    cl,loop_time                     ;num+=AL*10^CX
    d:                 cmp    cx,0
                       je     e
                       mul    digit
                       dec    cx
                       jmp    d
    e:                 add    radius,ax
                       inc    loop_time
                       mov    cl,loop_time
                       cmp    sp,bx
                       je     exit
                       jmp    next
    exit:              cmp    radius,250
                       ja     error
                       cmp    radius,0
                       je     error
                       ret
    error:             mov    ah,09h
                       lea    dx,message3
                       int    21h
    recycle:           mov    radius,0
                       lea    ax, cache[50]
                       mov    sp, initsp
                       mov    loop_time,0
                       jmp    input
ASCII2num endp

draw_circle proc near
                       mov    cx,320
                       mov    dx,240
                       mov    bx,radius
                       mov    ax,cx
                       sub    ax,bx
                       mov    si,ax
                       mov    ax,dx
                       sub    ax,bx
                       mov    di,ax
    select:            mov    ax,si
                       sub    ax,cx
                       imul   ax,ax
                       mov    bx,di
                       sub    bx,dx
                       imul   bx,bx
                       add    ax,bx

                       ret
draw_circle endp

code ends
end start