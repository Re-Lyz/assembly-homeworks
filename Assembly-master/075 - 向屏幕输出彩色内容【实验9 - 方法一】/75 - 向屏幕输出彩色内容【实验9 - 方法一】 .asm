; 75 - �1�7�1�7�1�7�1�7�0�3�1�7�1�7�1�7�1�7�1�7�0�2�1�7�1�7�1�7�1�3�1�7�0�6�1�7�1�79�1�7�1�7 

; =================================================================
; �0�8�1�7�1�7: �1�7�1�7�1�7�1�7�0�3�1�7�ބ1�7�0�1�1�7�1�7�1�7�0�5�1�7�1�7�0�2�1�7�1�7�1�7�0�9�0�4�1�7�0�2�1�7�1�7�1�7�0�9�1�7�1�7�1�7�0�2�1�7�0�7�1�7�1�7�1�7�1�7�1�7welcome to masm!�1�7�1�7
; =================================================================

assume cs:codesg, ds:datasg, es:colorsg, ss:stacksg

; =================================================================

datasg segment
		dw 'w','e','l','c','o','m','e',' ','t','o',' ','m','a','s','m','!'
		dw 'w','e','l','c','o','m','e',' ','t','o',' ','m','a','s','m','!'
		dw 'w','e','l','c','o','m','e',' ','t','o',' ','m','a','s','m','!'
datasg ends

; =================================================================

colorsg segment
		db 00000010B, 10101100B, 01111001B
colorsg ends

; =================================================================

stacksg segment
		dw 48 dup (0)
stacksg ends

; =================================================================

codesg segment
start:		mov ax, stacksg
		mov ss, ax
		mov sp, 61H


		mov cx, 48
		mov bx, 5EH
		mov ax, datasg
		mov ds, ax
pushData:	push ds:[bx]	; �1�7�1�7welcome to masm! �1�7�1�7�1�7�1�7�1�7�1�2�0�7�1�7�1�7
		sub bx, 2
		loop pushData

		mov ax, colorsg
		mov ds, ax
		mov di, 0
		mov dx, 3	; 3�1�7�1�7

		mov ax, 0B800H
		mov es, ax
		mov bx, 160 * 12 + 64
		
		; �1�7�1�7�1�7�1�7�0�7�0�5�1�7�ք1�7�1�7�1�7�1�7�1�7
		mov cx, 3	; �1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�0�0�1�7�1�7�1�7�1�7�1�7�1�7���1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7
loop3:		mov dx, cx
		mov cx, 16
		oneRow:		pop es:[bx]
				mov ah, ds:[di]
				mov es:[bx + 1], ah
				add bx, 2
				loop oneRow

		inc di
		add bx, 160 - 32
		mov cx, dx
		loop loop3

		mov ax, 4c00h
		int 21h


codesg ends

end start

; =================================================================


; ===============================================================
;assume cs:codesg, ds:datasg, es:colorsg, ss:stacksg
;
;; =================================================================
;
;datasg segment
;		dw 'w','e','l','c','o','m','e',' ','t','o',' ','m','a','s','m','!'
;		;dw 'w','e','l','c','o','m','e',' ','t','o',' ','m','a','s','m','!'
;		;dw 'w','e','l','c','o','m','e',' ','t','o',' ','m','a','s','m','!'
;datasg ends
;
;; =================================================================
;
;colorsg segment
;		db 00000010B, 10100100B, 01110001B
;colorsg ends
;
;; =================================================================
;
;stacksg segment
;		dw 16 dup (0)
;stacksg ends
;
;; =================================================================
;
;codesg segment
;start:		mov ax, stacksg
;		mov ss, ax
;		mov sp, 33
;
;
;		mov cx, 16
;		mov bx, 30
;		mov ax, datasg
;		mov ds, ax
;pushData:	push ds:[bx]
;		sub bx, 2
;		loop pushData
;
;		mov ax, colorsg
;		mov ds, ax
;		mov di, 0
;		mov dx, 3	; 3�1�7�1�7
;
;		mov ax, 0B800H
;		mov es, ax
;		mov bx, 160 * 12 + 64
;		mov cx, 16
;		; �1�7�0�5�1�7�0�5�1�7�ք1�7�1�7�1�7�1�7�1�3�1�7�1�7�1�7�1�7�1�7
;oneRow:		pop es:[bx]
;		mov ah, ds:[di]
;		mov es:[bx + 1], ah
;		add bx, 2
;		jcxz initCX
;		loop oneRow
;		
;
;initCX:		dec dx
;		mov cx, dx
;		jcxz exit
;		mov cx, 16
;		mov di, 0
;		add bx, 160 - 64
;		jmp initStack
;back:		jmp short oneRow
;
;exit:		mov ax, 4c00h
;		int 21h
;		
;
;initStack:		mov cx, 16
;			mov bx, 30
;			mov ax, datasg
;			mov ds, ax
;	pushAgain:	push ds:[bx]
;			sub bx, 2
;			loop pushAgain
;	jmp short back
;
;codesg ends
;
;end start
;
;; =================================================================;
