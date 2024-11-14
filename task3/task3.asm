assume  ds:data,ss:stack,cs:code

.486
data segment use16
    description  db 'Functons below:',0dh,0ah,'1:count the negetives',0dh,0ah,'2:sum the array',0dh,0ah,'3:sort the array',0dh,0ah,'4:exit',0dh,0ah,'$'
    message1     db 'type 10 numbers between -99999~99999,use enter to input: ',0dh,0ah,'$'
    message2     db 'choose the function:',0dh,0ah,'$'
    message3     db 'Please enter the right formula! ',0dh,0ah,'$'
    message4     db 'done!',0dh,0ah,'$'
    message5     db 'The number is too big! ',0dh,0ah,'$'
    message6     db 0dh,0ah,'The number of negative numbers is: ',0dh,0ah,'$'
    message7     db 0dh,0ah,'The sum of the array is: ',0dh,0ah,'$'
    message8     db 0dh,0ah,'The sorted array is: ',0dh,0ah,'$'
    message9     db 0dh,0ah,'The original array is: ',0dh,0ah,'$'
    num10        db '10',0dh,0ah,'$'
    negsign      db '-','$'
    nextline     db 0dh,0ah,'$'
    space        db ' ','$'

    array_buf    db 10
                 db ?
                 db 10 dup(0)

    num_buf      db 10 dup('$')

    digit        dd 10
    loop_time    db 0
    no           db 0
    neg_no       db 0
    initsp       dw 0
    tempadd      dw 0
    sorted       db 0
    
    ; number of negative numbers
    num          dd 0                                                                                                                                      ; input number
    array        dd 10 dup(0)
    sorted_array dd 10 dup(0)

data ends

stack segment use16
    cache dw 50 dup(0)
stack ends

code segment use16
    start:                                                 ; 设置相关段寄存器
                      mov  ax, data
                      mov  ds, ax
                      mov  ax, stack
                      mov  ss, ax
                      lea  ax, cache[50]
                      mov  sp, ax
                      mov  si, 0
                      mov  di, 0
                      mov  bx, 0
                      mov  cx, 0

                      call B10SCRN
                      call SHOWMENU
    inputnum:         
                      call ASCII2num                       ;0022
                      mov  eax,num                         ;0026

                      mov  array[si],eax
                      mov  num,0
                      mov  loop_time,0
                      add  si,4
                      inc  no
                      cmp  no,10
                      jb   inputnum                        ;004a/输入结束

                      lea  dx,message4
                      mov  ah,09h
                      int  21h

    choice:           
                      lea  dx,description
                      mov  ah,09h
                      int  21h
                      lea  dx,message2
                      mov  ah,09h
                      int  21h                             ;0060/显示菜单

                      mov  ah,01h
                      int  21h
                      cmp  al,31h                          ;0066
                      je   count_neg
                      cmp  al,32h
                      je   sum_array
                      cmp  al,33h
                      je   sort_array
                      cmp  al,34h
                      je   closeP

                      lea  dx,message3
                      mov  ah,09h
                      int  21h
                      jmp  choice

    count_neg:        call COUNTNEG
                      jmp  choice

    sum_array:        call SUMARRAY
                      jmp  choice

    sort_array:       call SORT
                      jmp  choice

    closeP:           mov  ax,4c00h
                      int  21h

SHOWMENU proc near
                      lea  dx,description
                      mov  ah,09h
                      int  21h
                      lea  dx,message1
                      mov  ah,09h
                      int  21h
                      ret
SHOWMENU endp

B10SCRN proc near
                      mov  ax,0600h
                      mov  bh,07h
                      mov  cx,0000h
                      mov  dx,184fh
                      int  10h
                      ret
B10SCRN endp

ASCII2num proc near
    input:            mov  ah,0ah
                      lea  dx,array_buf                    ;
                      int  21h
                      cmp  array_buf+1, 0
                      je   input
                      mov  bl,array_buf+1
                      mov  bh,0
                      mov  BYTE PTR[array_buf+bx+2],0ah
                      mov  BYTE PTR[array_buf+bx+3],24h
                      mov  ah,09h
                      lea  dx,array_buf+2
                      int  21h
                      lea  bx,array_buf+2

                      mov  cx,0
                      mov  eax,0
                      mov  dx,0
                      mov  initsp,sp

    s:                mov  ax,ds:[bx]
                      cmp  ah,0ah
                      push ax
                      je   next
                      inc  bl
                      jmp  s

    next:             pop  ax
                      lea  bx,cache[48]
                      cmp  sp,bx
                      je   negative

    n:                cmp  al,30h
                      jb   error
                      cmp  al,39h
                      ja   error
                      sub  al,30h
                      mov  ah,0h
                      mov  cl,loop_time
    ;num+=AL*10^CX
    d:                cmp  cx,0
                      je   e
                      mul  digit
                      dec  cx
                      jmp  d

    e:                add  num,eax
                      inc  loop_time
                      mov  cl,loop_time
                      cmp  sp,bx
                      je   exit
                      jmp  next
           
    exit:             cmp  num,99999
                      mov  eax,num
                      ja   error2
                      ret
    negative:         cmp  al,2dh
                      jne  n
                      cmp  num,99999
                      ja   error2
                      neg  num
                      inc  neg_no
                      ret

    error:            mov  ah,09h
                      lea  dx,message3
                      int  21h
                      jmp  recycle
    error2:           mov  ah,09h
                      lea  dx,message5
                      int  21h
    recycle:          mov  num,0
                      lea  ax, cache[50]
                      mov  sp, initsp
                      mov  loop_time,0
                      jmp  input

              
ASCII2num endp

COUNTNEG proc near
                      call B10SCRN
                      call SHOWARRAY
                      lea  dx,message6
                      mov  ah,09h
                      int  21h
                      mov  dx,0
                      mov  ah,0
               
                      mov  al,neg_no
                      cmp  al,10
                      je   ten
                      add  al,30h
                      mov  num_buf,al

                      lea  dx,num_buf
                      mov  ah,09h
                      int  21h
                      lea  dx,nextline
                      mov  ah,09h
                      int  21h
                      ret

    ten:              lea  dx,num10
                      mov  ah,09h
                      int  21h
                      lea  dx,nextline
                      mov  ah,09h
                      int  21h
                      ret
COUNTNEG endp

SUMARRAY proc near
                      call B10SCRN
                      call SHOWARRAY
                      lea  dx,message7
                      mov  ah,09h
                      int  21h
                      mov  si,0
                      mov  cx,10
                      mov  ebx,0

    array_sum:        add  ebx,array[si]
                      add  si,4
                      loop array_sum

                      cmp  ebx,0
                      jge  shownum
                      neg  ebx
                      lea  dx,negsign
                      mov  ah,09h
                      int  21h

    shownum:          call num2ASCII
                      lea  dx,nextline
                      mov  ah,09h
                      int  21h
                      ret
SUMARRAY endp

SORT proc near
                      call B10SCRN
                      call SHOWARRAY
                      mov  ah,09h
                      lea  dx,message8
                      int  21h

                      mov  si,0
                      mov  cx,10
                      cmp  sorted_array,0
                      jne  show_sorted_array
    copy:             mov  eax,array[si]
                      mov  sorted_array[si],eax
                      add  si,4
                      loop copy

                      mov  cx,9                            ;234
                      mov  bx,0
    loop1:            mov  di,cx
                      mov  si,bx

    loop2:            mov  eax,sorted_array[si]
                      cmp  eax,sorted_array[si+4]
                      jge  next_num
                      xchg eax,sorted_array[si+4]
                      mov  sorted_array[si],eax
    next_num:         add  si,4
                      dec  di
                      cmp  di,0
                      jne  loop2
                      add  bx,4
                      loop loop1
                      mov  sorted_array,1
                      mov  bx,0
    show_sorted_array:
                      mov  si,0
                      mov  cx,10
                      mov  ebx,sorted_array[si]
                      mov  loop_time,cl
                      mov  tempadd,si
                      call num2ASCII
                      mov  cl,loop_time
                      mov  si,tempadd

                      add  si,4
                      lea  dx,space
                      mov  ah,09h
                      int  21h
                      loop show_array

                      lea  dx,nextline
                      mov  ah,09h
                      int  21h
                      mov  loop_time,0
                      ret
SORT endp

num2ASCII proc near
                      mov  eax,ebx
                      lea  di, num_buf
                      mov  ecx,10
    convert10:        
                      xor  edx, edx
                      div  ecx
                      add  dl,30h
                      mov  ds:[di],dl
                      inc  di
                      cmp  eax,0
                      jne  convert10                       ;0217

                      lea  si, num_buf
                      dec  di
   
    reverse_string:   
                      cmp  si, di                          ; SI 指向字符串的开头，DI 指向末尾
                      jge  done                            ; SI >= DI，字符串反转完成，跳出循环
                      mov  al, ds:[si]                     ; 将 SI 指向的字符加载到 AL
                      mov  bl, ds:[di]                     ; 将 DI 指向的字符加载到 BL
                      mov  ds:[si], bl                     ; 将 BL 的值存储到 SI 指向的位置
                      mov  ds:[di], al                     ; 将 AL 的值存储到 DI 指向的位置
                      inc  si                              ; SI 向后移动
                      dec  di                              ; DI 向前移动
                      jmp  reverse_string

    done:             
                      mov  ah, 09h
                      lea  dx, num_buf
                      int  21h

                      lea  si, num_buf                     ; SI 指向 num 字符串的开始位置
                      mov  cx, 10                          ; 最大字符数（最多 10 个数字字符 + 1 个结束符）
    reset_num_buf:    
                      cmp  byte [si],'$'
                      je   reset_done
                      mov  byte [si],'$'
                      inc  si
                      loop reset_num_buf
    reset_done:       mov  si,0
                      mov  di,0                            ;025d
                      ret
num2ASCII endp

SHOWARRAY proc near
                      lea  dx,message9
                      mov  ah,09h
                      int  21h
                      mov  cx,10
                      mov  si,0
    show_array:       
                      mov  ebx,array[si]
                      mov  loop_time,cl
                      mov  tempadd,si
                      call num2ASCII
                      mov  cl,loop_time
                      mov  si,tempadd

                      add  si,4
                      lea  dx,space
                      mov  ah,09h
                      int  21h
                      loop show_array

                      lea  dx,nextline
                      mov  ah,09h
                      int  21h
                      mov  loop_time,0
                      ret                                  ;33f
SHOWARRAY endp

code ends
end start