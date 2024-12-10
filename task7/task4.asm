.386
public func4 

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
 
data segment use16 para public 'data'
    message1     db 'Enter the radius of the circle <=250: ',0ah,0dh,'$'
    message2     db 'Please enter a number between 1 and 250!',0ah,0dh,'$'
    message3     db 'Please enter the title: ',0ah,0dh,'$'
    message4     db 'You can enter "y" to input again, any other key to exit: ',0dh,0ah,'$'
    space        db ' '
    nextline     db 0dh,0ah,'$'

    x_buf        db 500 dup('0')
    y_buf        db 500 dup('0')
    x_up         db 500 dup('0')
    y_up         db 500 dup('0')
    
    radius_buf   db 5
                 db ?
                 db 5 dup(0)
    title_buf    db 50
                 db ?
                 db 50 dup(0)

    digit        dw 10
    radius       dw 0

    initsp       dw 0
    loop_time    db 0
    loop_times   dw 0
    loops        dw 0
    color_change db 1

    y_end        dw 0
    x_end        dw 0
    x_start      dw 0

    colors       db 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

    stack_sp     dw 0
    stack_ss     dw 0

data ends

stack segment use16 para public 'stack'
    cache dw 128 dup(?)
stack ends

code segment use16 para public 'code'
                       assume ds:data,ss:stack,cs:code

func4 proc far
                       mov    stack_sp, sp
                       mov    stack_ss, ss
    start:             
                       mov    ax,data
                       mov    ds,ax
                       lea    ax, cache[50]
                       mov    sp, ax
                       mov    ax,data
                       mov    ds,ax
                       mov    si, 0
                       mov    di, 0
                       mov    ebx, 0
                       mov    ecx, 0
                       mov    edx, 0
                       mov    eax, 0
                       call   B10SCRN
                       mov    ah,09h
                       lea    dx,message3
                       int    21h
    input_title:       lea    dx,title_buf
                       mov    ah,0ah
                       int    21h
                       cmp    title_buf+1, 0
                       je     input_title
                       mov    bl, title_buf+1
                       mov    bh, 0
                       mov    BYTE PTR[title_buf+bx+2],24h
                       mov    ah,09h
                       lea    dx,title_buf+2
                       int    21h
                       mov    ah,09h
                       lea    dx,nextline
                       int    21h

                       mov    ah,09h
                       lea    dx,message1
                       int    21h
                       call   ASCII2num
                       call   B10SCRN

    draw_title:        mov    cx,0                             ;0071
                       mov    dx,0101h
                       mov    loop_time, 1
                       mov    di,0
                       screen
                       mov    ah,02h
                       mov    bh,0
                       int    10h
                       mov    ah,09h
                       lea    si,title_buf+2

    show_title1:       mov    ah,02h
                       mov    bh,0
                       int    10h
                       mov    ah,09h
                       mov    al,ds:[si]
                       mov    bl,colors[di]
                       mov    cx,1
                       int    10h
                       inc    si
                       inc    dl
                       call   long_delay
                       mov    al,ds:[si]
                       cmp    al,'$'
                       je     clear_title
                       jmp    show_title1

    display_title_loop:
                       mov    ah,02h
                       mov    bh,0
                       int    10h
                       mov    ah,09h
                       lea    si,title_buf+2
    show_title:        mov    ah,02h
                       mov    bh,0
                       int    10h
                       mov    ah,09h
                       mov    al,ds:[si]
                       mov    bl,colors[di]
                       mov    cx,1
                       int    10h
                       inc    si
                       inc    dl
                       mov    al,ds:[si]
                       cmp    al,'$'
                       je     clear_title
                       jmp    show_title
    clear_title:       call   long_delay
                       mov    ah,02h
                       mov    bh,0
                       mov    dx,0100h
                       int    10h
                       inc    loop_time
                       mov    ah,09h
                       lea    si,space
                       mov    al,ds:[si]
                       mov    cx,640
                       mov    bl,0
                       int    10h
                       inc    di
                       mov    dl,loop_time
                       cmp    di,10
                       jbe    change_color
                       mov    di,0
    change_color:      
                       cmp    loop_time, 80
                       jne    change_loop
                       mov    loop_time, 0
    change_loop:       mov    ah, 01h
                       int    16h
                       jz     display_title_loop
    next_step:         
                       call   long_delay
                       write  320, 240, 15
                       mov    loop_time, 0
                       call   draw_circle                      ;00af
                       call   draw_square                      ;00b2

                       mov    ah,02h
                       mov    bh,0
                       mov    dx,1900h
                       int    10h

                       mov    ah,09h
                       lea    dx,message4
                       int    21h
                       mov    ah, 08h                          ;004a
                       int    21h
                       mov    ah, 01h                          ;004a
                       int    21h
                       cmp    al, 'y'
                       je     recyle
                       cmp    al, 'Y'
                       je     recyle
                       
                       mov    sp,stack_sp
                       mov    ss,stack_ss
                       retf
    recyle:            lea    dx,nextline
                       mov    ah,09h
                       int    21h
                       mov    digit, 10
                       mov    loop_time, 0
                       mov    color_change,1
                       mov    loop_times,0
                       mov    radius,0
                       mov    cx, 5
                       lea    si, radius_buf+2
    clear_radius_buf:  mov    byte ptr[si], '0'
                       inc    si
                       loop   clear_radius_buf
                       mov    si,0
                       mov    eax,0
                       mov    ebx,0
                       mov    ecx,0
                       jmp    start

func4 endp

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

time_delay proc near
                       mov    cx,16383
    delay:             nop
                       loop   delay
                       ret
time_delay endp

long_delay proc near
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
                       ret
long_delay endp

ASCII2num proc near
    input:             mov    ah,0ah
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
                       mov    initsp,sp
    s:                 mov    ax,ds:[bx]
                       cmp    ah,0ah
                       push   ax
                       je     next
                       inc    bl
                       jmp    s
    next:              
                       pop    ax
    n:                 cmp    al,30h
                       jb     error
                       cmp    al,39h
                       ja     error
                       sub    al,30h
                       mov    ah,0h
                       mov    cl,loop_time                     ;radius+=AL*10^CX
    d:                 cmp    cx,0
                       je     e
                       mul    digit
                       dec    cx
                       jmp    d
    e:                 add    radius,ax
                       inc    loop_time
                       mov    cl,loop_time
                       lea    bx,cache[48]
                       cmp    sp,bx
                       je     exit
                       jmp    next
    exit:              cmp    radius,250
                       ja     error
                       cmp    radius,0
                       jbe    error
                       ret
    error:             mov    ah,09h
                       lea    dx,message2
                       int    21h
                       mov    radius,0
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
                       mov    x_start,si                       ;找到起始点的x坐标：320-radius
                       mov    di,dx                            ;找到起始点的y坐标：240
                       mov    x_end,320                        ;绘制左上角的边界 x边界：320
                       mov    ax,dx
                       sub    ax,bx
                       dec    ax
                       mov    y_end,ax                         ;y边界：240-radius ;01c7
    select:            mov    ax,si
                       sub    ax,cx
                       imul   ax,ax
                       mov    bx,di
                       sub    bx,dx
                       cmp    bx, 0
                       imul   bx,bx
                       add    eax,ebx
                       mov    cx,radius
                       imul   cx,cx
                       sub    eax,ecx
                       mov    ebx,0
                       mov    bx,radius
                       cmp    eax, 0
                       jge    positive
                       neg    eax
    positive:          cmp    eax,ebx
                       jg     draw_pixel
                       mov    cx,si
                       mov    bx,di
                       mov    ax,0
                       mov    ax,loop_times
                       mov    si,ax
                       mov    ax,0
                       mov    x_buf[si], cl
                       mov    y_buf[si], bl
                       mov    x_up[si], ch
                       mov    y_up[si], bh
                       inc    loop_times
                       mov    si,cx
                       mov    cx,0
                       mov    bx,0
                       call   draw_dot
    draw_pixel:        mov    cx,320
                       mov    dx,240
                       inc    si
                       cmp    si, x_end
                       jne    next_line
                       dec    di
                       mov    si, x_start
    next_line:         cmp    di, y_end
                       jne    select
                       mov    ax,0
                       mov    ax,loop_times
                       mov    loops,ax
                       mov    di,0
    draw_next_1_4:     mov    si,loops
                       mov    ax,0
                       mov    bx,0
                       mov    al,x_buf[si]
                       mov    bl,y_buf[si]
                       mov    ah,x_up[si]
                       mov    bh,y_up[si]
                       sub    ax,640
                       neg    ax
                       dec    loops
                       mov    si,ax
                       mov    di,bx
                       mov    ax,0
                       mov    bx,0
                       call   draw_dot
                       cmp    loops,0
                       jge    draw_next_1_4
                       mov    ax,loop_times
                       mov    loops,0
    draw_next_2_4:     mov    si,loops
                       mov    ax,0
                       mov    bx,0
                       mov    al,x_buf[si]
                       mov    bl,y_buf[si]
                       mov    ah,x_up[si]
                       mov    bh,y_up[si]
                       sub    ax,640
                       neg    ax
                       sub    bx,480
                       neg    bx
                       inc    loops
                       mov    si,ax
                       mov    di,bx
                       mov    ax,0
                       mov    bx,0
                       call   draw_dot
                       mov    ax,loops
                       cmp    ax,loop_times
                       jbe    draw_next_2_4
                       mov    ax,0
                       mov    ax,loop_times
                       mov    loops,ax
                       mov    di,0
    draw_next_3_4:     mov    si,loops
                       mov    ax,0
                       mov    bx,0
                       mov    al,x_buf[si]
                       mov    bl,y_buf[si]
                       mov    ah,x_up[si]
                       mov    bh,y_up[si]
                       sub    bx,480
                       neg    bx
                       dec    loops
                       mov    si,ax
                       mov    di,bx
                       mov    ax,0
                       mov    bx,0
                       call   draw_dot
                       cmp    loops,0
                       jge    draw_next_3_4
                       ret
draw_circle endp

draw_square proc near
                       mov    color_change,0
                       mov    dx,0
                       mov    ax,loop_times
                       mov    bx,2
                       div    bx
                       mov    si,ax
                       mov    al,x_buf[si]
                       mov    bl,y_buf[si]
                       mov    ah,x_up[si]
                       mov    bh,y_up[si]
                       mov    si,ax
                       mov    di,bx
                       mov    x_start,ax
    first_side:        call   draw_dot
                       inc    si
                       mov    ax,si
                       sub    ax,640
                       neg    ax
                       cmp    ax,x_start
                       jg     first_side
                       mov    x_start,di
    second_side:       call   draw_dot
                       inc    di
                       mov    ax,di
                       sub    ax,480
                       neg    ax
                       cmp    ax,x_start
                       jg     second_side
                       mov    x_start,si
    third_side:        call   draw_dot
                       dec    si
                       mov    ax,si
                       sub    ax,640
                       neg    ax
                       cmp    ax,x_start
                       jb     third_side
                       mov    x_start,di
    fourth_side:       call   draw_dot
                       dec    di
                       mov    ax,di
                       sub    ax,480
                       neg    ax
                       cmp    ax,x_start
                       jb     fourth_side
                       ret
draw_square endp

draw_dot proc near
                       mov    bx,0
                       mov    bl,color_change
                       cmp    bl,0
                       jg     color_1
                       write  si, di, colors[0]
                       neg    color_change
                       jmp    color_2
    color_1:           write  si, di, colors[1]
                       neg    color_change
    color_2:           call   time_delay
                       ret
draw_dot endp

code ends
end start