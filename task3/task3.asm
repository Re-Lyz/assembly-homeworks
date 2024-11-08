assume  ds:data,ss:stack,cs:code

.486
data segment use16
    description db '1:count the negetives',0dh,0ah,'2:sum the array',0dh,0ah,'3:sort the array',0dh,0ah,'4:exit',0dh,0ah,'$'
    message1    db 'type 10 numbers between -99999~99999: ',0dh,0ah,'$'
    message2    db 'choose the function:',0dh,0ah,'$'
    message3    db 'Please enter the right number! ',0dh,0ah,'$'
    message4    db 'done!',0dh,0ah,'$'
    message5    db 'The number is too big! ',0dh,0ah,'$'


    array_buf   db 7
                db ?
                db 7 dup(0)

    digit       dd 10

    no          dw 0                                                                                                            ; number of input
    neg_no      db 0                                                                                                            ; number of negative numbers
    num         dd 0                                                                                                            ; input number
    array       dd 10 dup(0)

data ends

stack segment use16
    cache db 100 dup(0)
stack ends

code segment use16
    start:    
    ; 设置相关段寄存器
              mov  ax, data
              mov  ds, ax
              mov  ax, stack
              mov  ss, ax
              lea  ax, cache[100]
              mov  sp, ax
              
              mov  si, 0
              mov  di, 0
              mov  bx, 0
              mov  cx, 0


              call B10SCRN

              lea  dx,description
              mov  ah,09h
              int  21h
              lea  dx,message1
              mov  ah,09h
              int  21h

    input:    mov  ah,0ah
              lea  dx,array_buf                    ;
              int  21h

              cmp  array_buf+1, 0
              je   input

              mov  bl,array_buf+1
              mov  bh,0
              mov  BYTE PTR[array_buf+bx+2],24h

    ;   mov  ah,09h
    ;   lea  dx,array_buf+2
    ;   int  21h

              inc  no

              lea  bl,array_buf+2
              call ASCII2num


              cmp  no,10
              jb   input

              lea  dx,message4
              mov  ah,09h
              int  21h

              lea  dx,message2
              mov  ah,09h
              int  21h


              mov  ax,4c00h
              int  21h

          
B10SCRN proc near
              mov  ax,0600h
              mov  bh,07h
              mov  cx,0000h
              mov  dx,184fh
              int  10h
              ret
B10SCRN endp

ASCII2num proc near
              mov  cx,0
              mov  eax,0
              mov  dx,0

    s:        mov  ax,ds:[bx]

    ;   mov  dx,ax
    ;   mov  ah,09h
    ;   int  21h

              cmp  al,24h
              je   next
              push ax
              inc  bx
              jmp  s

    next:     

              pop  ax
              mov  bx,sp
              cmp  bx,2
              je   negative
              cmp  bx,0
              je   exit
    n:        
              cmp  al,30h
              jb   error
              cmp  al,39h
              ja   error
              sub  al,30h
              mov  ebx,digit
    ;num+=AL*10^CX
              mov  bx,cx
    d:        mul  ebx
              loop d
              add  num,eax
              cmp  num,99999
              ja   error2
              inc  bx
              mov  cx,bx
              jmp  next
           
    exit:     ret

    negative: cmp  al,2dh
              jne  n
              neg  num
              inc  neg_no
              ret


    error:    mov  ah,09h
              lea  dx,message3
              int  21h
              dec  no
              jmp  input

    error2:   mov  ah,09h
              lea  dx,message5
              int  21h
              mov  num,0
              dec  no
              jmp  input
              
ASCII2num endp

num2ASCII proc near

              ret
num2ASCII endp

code ends
end start