assume cs:code, ds:data, ss:stack

data segment
    message1 db "What's your name?",0
    message2 db "Which class are you in?",0
    message3 db "Your name is ",0
    message4 db ", and your class is ",0
    message5 db ". confirm(y/n)",0

data ends

stack segment
          db 128 dup (0)
stack ends

code segment
    start:      
                mov  ax, stack
                mov  ss, ax
                mov  sp, 128

                mov  ax, data
                mov  ds, ax
                mov  si, 0

	            mov  ax, 0B800H
	            mov  es, ax

	            mov  dl, 1
	            mov  dh, 0
	            mov  cl, 00000111B
	            call show_str

                call get_str

	            mov  dl, 3
	            mov  dh, 0
	            mov  cl, 00000111B
	            call show_str    

	            mov  ax, 4c00h
	            int  21h



    show_str:   push ax
                push bx
                push ds
                push es
                push di
                push si
                push cx
                push dx
            			
                mov  ah, 0
                mov  al, 160
                mov  dh, 0
                mov  bx, dx
                mov  dx, 0
                mul  bx
                pop  dx
                mov  dh, 0
                add  ax, dx; 注意这里加两遍，不能简单地将列号相加，因为显示一个字符用了两个字节
                add  ax, dx
                mov  bx, ax
    ; 确定输出的位置
    _showStr:   mov  cx, 0
                mov  cl, ds:[si + 0]
                jcxz _retShowStr
                mov  es:[bx + 0], cl
                pop  cx
                push cx
                mov  byte ptr es:[bx + 1], cl
                inc  si
                add  bx, 2
                jmp  _showStr

    _retShowStr:pop  cx
                pop  si
                pop  di
                pop  es
                pop  ds
                pop  bx
                pop  ax
                ret

    get_str:    push ax
    _getStrs:   
                mov  ah, 0
                int  16h
                cmp  al, 20h                      ; ASCII码小于20h说明不是字符
                jb   nochar
                mov  ah, 0
                call char_stack                   ; 字符入栈
                mov  ah, 2
                call char_stack                   ; 显示栈中字符
                jmp  _getStrs

    nochar:     cmp  ah, 0eh                      ; 退格键的扫描码
                je   _backspace
                cmp  ah, 1ch                      ; Enter 的扫描码
                je   _enter
                jmp  _getStrs

    _backspace: 
                mov  ah, 1
                call char_stack                   ; 字符出栈
                mov  ah, 2
                call char_stack
                jmp  _getStrs

    _enter:     mov  al, 0
                mov  ah, 0
                call char_stack                   ; 0 入栈
                mov  ah, 2
                call char_stack                   ; 显示栈中字符串
                pop  ax
                ret


               
    char_stack: jmp  _charStart
    table       dw   _push, _pop, _show
    top         dw   0                            ; 栈顶

    _charStart: push bx
                push dx
                push di
                push es


                cmp  ah, 2
                ja   _ret
                mov  bl, ah
                mov  bh, 0
                add  bx, bx
                jmp  word ptr table[bx]

    _push:      mov  bx, top
                mov  [si][bx], al
                inc  top
                jmp  _ret

    _pop:       cmp  top, 0
                je   _ret
                dec  top
                mov  bx, top
                mov  al, [si][bx]
                jmp  _ret

    _show:      mov  bx, 0b800h
                mov  es, bx
                mov  al, 160
                mov  ah, 0
                mul  dh
                mov  di, ax
                add  dl, dl
                mov  ah, 0
                add  di, ax

                mov  bx, 0

    _shows:     cmp  bx, top
                jne  _noempty
                mov  byte ptr es:[di], ' '
                jmp  _ret
	
    _noempty:   mov  al, [si][bx]
                mov  es:[di], al
                mov  byte ptr es:[di + 2], ' '
                inc  bx
                add  di, 2
                jmp  _shows

    _ret:       pop  es
                pop  di
                pop  dx
                pop  bx
                ret




                mov  ax,4c00h
                int  21h
code ends
end start