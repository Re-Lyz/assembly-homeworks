.386

public func5

data segment use16 para public 'data'
    description db 'Please input a 4-bit hexadecimal number: ',0dh,0ah,'$'
    message1    db 'You can enter "y" to input again, any other key to exit: ',0dh,0ah,'$'

    hexlinkdec  db 'H=','$'
    nextline    db 0dh,0ah,'$'

    input_buf   db 10 dup('$')
    num_buf     db 10 dup('$')

    digit       dd 10h
    loop_time   db 4

    num         dd 0
    num_temp    dd 4 dup(0)                                                                   ; input number
data ends

stack segment use16 para public 'stack'
    cache dw 50 dup(0)
stack ends

code segment use16 para public 'code'
assume  ds:data,ss:stack,cs:code
func5 proc far
    start:          mov  ax, data
                    mov  ds, ax

    again:          mov  si, 0
                    mov  di, 0
                    mov  bx, 0
                    mov  cx, 0
                    call B10SCRN
                    lea  dx, description
                    mov  ah, 09h
                    int  21h
                    call ASCII2num            ;0027
                    lea  dx, hexlinkdec
                    mov  ah, 09h
                    int  21h
                    mov  ebx, num             ;0033
                    call num2ASCII
                    lea  dx, nextline
                    mov  ah, 09h
                    int  21h

                    lea  dx, message1
                    mov  ah, 09h
                    int  21h
                    mov  ah, 01h              ;004a
                    int  21h
                    cmp  al, 'y'
                    je   recyle
                    cmp  al, 'Y'
                    je   recyle
                    retf
                     
    recyle:         lea  dx,nextline
                    mov  ah,09h
                    int  21h
                    mov  num, 0
                    mov  loop_time, 4
                    mov  cx, 10
                    lea  si, input_buf
    clear_input_buf:mov  byte ptr [si], '$'
                    inc  si
                    loop clear_input_buf
                    mov  eax,0
                    mov  ecx,0
                    mov  digit,10h
                    jmp  again                ;0092

func5 endp

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

ASCII2num proc near
                    mov  si,0
                    mov  di,0
                    mov  ebx,0
    input:          mov  eax,0
                    mov  ah,08h
                    int  21h
    chr_dect:       cmp  al,08h
                    je   backspace
                    cmp  al,30h               ;0-9
                    jb   input
                    cmp  al,39h
                    jbe  cal_num
                    cmp  al,41h               ;A-F
                    jb   input
                    cmp  al,46h
                    jbe  cal_num_hex
                    cmp  al,61h               ;a-f
                    jb   input
                    cmp  al,66h
                    jbe  cal_num_small
                    jmp  input
    cal_num_small:  sub  al,20h
    cal_num_hex:    mov  input_buf[si],al
                    lea  dx,input_buf[si]
                    mov  ah,09h
                    int  21h
                    mov  al, input_buf[si]
                    sub  al,37h
                    mov  ah,0h
                    jmp  next
    cal_num:        mov  input_buf[si],al
                    lea  dx,input_buf[si]
                    mov  ah,09h
                    int  21h
                    mov  al, input_buf[si]
                    sub  al,30h
                    mov  ah,0h
    next:           mov  cl,loop_time         ;num+=AL*16^CX
    d:              cmp  cx,1
                    je   e
                    mul  digit
                    dec  cx
                    jmp  d
    e:              mov  num_temp[di],eax
                    add  num,eax
                    dec  loop_time
                    inc  si
                    add  di,4
                    cmp  loop_time,0
                    jne  input
                    ret
    backspace:      cmp  si,0
                    je   input
                    dec  si
                    sub  di,4
                    inc  loop_time
                    mov  eax,num_temp[di]
                    mov  input_buf[si],'$'
                    sub  num,eax
                    mov  eax,0
                    mov  ah,03h
                    mov  bh,0
                    int  10h
                    dec  dl
                    mov  ah,02h
                    mov  bh,0
                    int  10h
                    mov  ah,09h
                    mov  al,' '
                    mov  bh,0
                    mov  bl,07h
                    mov  cx,1
                    int  10h
                    jmp  input

ASCII2num endp

num2ASCII proc near
    shownum:        mov  eax,ebx
                    lea  di, num_buf
                    mov  ecx,10
    convert10:      
                    xor  edx, edx
                    div  ecx
                    add  dl,30h
                    mov  ds:[di],dl
                    inc  di
                    cmp  eax,0
                    jne  convert10            ;0217
                    lea  si, num_buf
                    dec  di
    reverse_string: 
                    cmp  si, di
                    jge  done
                    mov  al, ds:[si]
                    mov  bl, ds:[di]
                    mov  ds:[si], bl
                    mov  ds:[di], al
                    inc  si
                    dec  di
                    jmp  reverse_string
    done:           
                    mov  ah, 09h
                    lea  dx, num_buf
                    int  21h
                    lea  si, num_buf
                    mov  cx, 10
    reset_num_buf:  
                    cmp  byte ptr [si],'$'
                    je   reset_done
                    mov  byte ptr [si],'$'
                    inc  si
                    loop reset_num_buf
    reset_done:     mov  si,0
                    mov  di,0                 ;025d
                    ret
num2ASCII endp
 
code ends
end start