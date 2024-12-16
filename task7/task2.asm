.386
assume cs:code, ds:data
public func2

data segment use16 para public 'data'
    message1  db "What's your name?",0dh,0ah,'$'
    message2  db "Which class are you in?",0dh,0ah,'$'
    message3  db "Your name is ",'$'
    message4  db ", and your class is ",'$'
    message5  db ". confirm(y/n)",'$'

    string    db 0dh,0ah,24h

    name_buf  db 20
              db ?
              db 20 dup(0)

    class_buf db 20
              db ?
              db 20 dup(0)
              
    answer    db 0

data ends

stack segment use16 para public 'stack'
    cache dw 50 dup(0)
stack ends

code segment use16 para public 'code'

func2 proc far
    start:      
                mov  ax, data
                mov  ds, ax
                mov  si, 0
                mov  bx,0

                mov  bh,00h
                call B10SCRN

                mov  ah,09h
                lea  dx,message1
                int  21h

    input_name: lea  dx,name_buf
                mov  ah,0ah
                int  21h
                cmp  name_buf+1, 0
                je   input_name

                mov  bl, name_buf+1
                mov  bh, 0
                mov  BYTE PTR[name_buf+bx+2],24h

                lea  dx,string
                mov  ah,09h
                int  21h

                mov  ah,09h
                lea  dx,message2
                int  21h

    input_class:mov  ah,0ah
                lea  dx,class_buf
                int  21h
                cmp  class_buf+1, 0
                je   input_class

                mov  bl, class_buf+1
                mov  bh, 0
                mov  BYTE PTR[class_buf+bx+2],24h

                lea  dx,string
                mov  ah,09h
                int  21h

                mov  ah,09h
                lea  dx,message3
                int  21h

                mov  ah,09h
                lea  dx,name_buf+2
                int  21h

                mov  ah,09h
                lea  dx,message4
                int  21h

                mov  ah,09h
                lea  dx,class_buf+2
                int  21h
                
                mov  ah,09h
                lea  dx,message5
                int  21h

                lea  dx,string
                mov  ah,09h
                int  21h

    Confirm:    
                mov  ah,01h
                int  21h

                mov  answer, al

                cmp  answer, 'n'
                je   start

                cmp  answer, 'N'
                je   start

                cmp  answer, 'y'
                je   exit

                cmp  answer, 'Y'
                je   exit

                jmp  Confirm

    exit:       retf
func2 endp

B10SCRN proc near
                mov  ax, 03h
                int  10h
                mov  ax,0600h
                mov  bh,07h
                mov  cx,0000h
                mov  dx,184fh
                int  10h
                mov  ah, 09h
                mov  al, ' '
                mov  bh, 0
                mov  bl, 0Fh
                mov  dl, 00h
                int  10h
                ret
B10SCRN endp




code ends
end start