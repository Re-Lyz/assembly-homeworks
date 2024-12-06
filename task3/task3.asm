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
    num10        db '10','$'
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
    flag         db 0

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
                      mov  ah,0
                      mov  al,ds:[array_buf+bx+1]
                      cmp  al,20h
                      jne  space_change
    space_dectect:    dec  bx
                      mov  al,ds:[array_buf+bx+1]
                      cmp  al,20h
                      je   space_dectect
    space_change:     mov  BYTE PTR[array_buf+bx+2],0ah
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
                      mov  cl,loop_time                    ;num+=AL*10^CX
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
                      cmp  num,0
                      je   exit
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

                      call num2ASCII
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

                      mov  cx, 9
    loop1:            mov  di, cx
                      mov  si, 0
    loop2:            mov  eax, sorted_array[si]
                      cmp  eax, sorted_array[si+4]
                      jge  next_num
                      xchg eax, sorted_array[si+4]
                      mov  sorted_array[si], eax
    next_num:         add  si, 4
                      dec  di
                      cmp  di, 0
                      jne  loop2

                      dec  cx
                      jnz  loop1

                      mov  sorted,1
                      mov  si,0
                      mov  cx,10
    show_sorted_array:mov  ebx,sorted_array[si]
                      mov  loop_time,cl
                      mov  tempadd,si
                      call num2ASCII
                      mov  cl,loop_time
                      mov  si,tempadd
                      add  si,4
                      lea  dx,space
                      mov  ah,09h
                      int  21h
                      loop show_sorted_array

                      lea  dx,nextline
                      mov  ah,09h
                      int  21h
                      mov  loop_time,0
                      ret
SORT endp

num2ASCII proc near
                      cmp  ebx,0
                      jge  shownum
                      neg  ebx
                      lea  dx,negsign
                      mov  ah,09h
                      int  21h
    shownum:          mov  eax,ebx
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
                      cmp  ebx,0
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
                      ret                                  ;33e
SHOWARRAY endp

code ends
end start