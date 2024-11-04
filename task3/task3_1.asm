assume  ds:data,cs:code

data segment
    description db ' 1:count the negetives',0dh,0ah,'2:sum the array',0dh,0ah,'3:sort the array',0dh,0ah,'4:exit',0dh,0ah,'$'
    message1    db 'type 10 numbers between -99999~99999: ',0dh,0ah,'$'
    message2    db 'choose the function:',0dh,0ah,'$'
    message3    db 'Please enter the right number! ',0dh,0ah,'$'
    message4    db 'done!',0dh,0ah,'$'


    array_buf   db 6
                db ?
                db 6 dup(0)



data ends



code segment
    start:  
              mov  ax, data
              mov  ds, ax


              
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



code ends
end start

