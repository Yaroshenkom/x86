NAME main

STACK_SEG SEGMENT PARA STACK 'STACK'
    DB      100 DUP (?)
STACK_SEG ENDS

DATA_SEG SEGMENT 'DATA'
	randnum 	dw 	0025h
	timerbuf 	db 2 DUP (?) 			;буфер, куда записывается "случайное число"
	screenbuf 	db  0,0,0,13,10,'$'		;буфер для вывода на экран
DATA_SEG ENDS

_CODE   SEGMENT PARA PUBLIC 'CODE'
    EXTRN   new70:FAR
    ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
_START:
	mov     AX, DATA_SEG        
    mov     DS, AX              
    mov     ES, AX
    XOR     AX, AX
mainloop:
	mov 	al, 10110100b 	; настройка таймера CT2 режим генератора импульсов, формат двоичный
	out  	43h, al      

	mov 	ax, randnum		;вводим количество счетов
	out 	42h, al		;сначала младший байт потом старший
	xchg 	al, ah
	out 	42h, al
	xor 	ax,ax
	mov 	al, 0ffh 	; посылаем на  Gate "1" - запустить таймер
	out 	61h, al
	
	mov		ah,08h
	int		21h
	
	cmp		al,1bh		     ;проверяем введена ли кнопка = 1bh (Esc), если да, то выходим из программы
	je		exitmain
	
	mov 	byte ptr timerbuf[1], al 	;записываем в память код нажатой клавиши
	mov 	al, 10000000b 		;считываем значение таймера №2 функцией CLC
	out 	43h, al
	in 		al, 42h
	mov 	ah, al
	in 		al, 42h
	xchg 	al,ah
	add 	word ptr timerbuf, ax 	;вычисляем сумму кода нажатой клавиши и показаний таймера - наше "случайное число"
		
	mov 	bx,2
screenoutput:						;запишем наше "случайное число" в буфер вывода в 
	mov 	al, byte ptr timerbuf[bx-1]		; виде неупакованного трехзначного BCD числа
	add 	byte ptr screenbuf[bx], al
	mov 	al, byte ptr screenbuf[bx]
	aam 	
	mov 	byte ptr screenbuf[bx], al
	add 	byte ptr screenbuf[bx-1],ah
	dec 	bx
	cmp 	bx,0
	jne 	screenoutput
ascii: 								;преобразовываем неупакованное BCD число для вывода на 
	or 		screenbuf[bx],30h		; экран, заменяя цифры их ASCII-кодами
	inc 	bx
	cmp 	bx,3
	jne 	ascii
	
	lea 	dx,screenbuf 			;выводим "случайное число" на экран
	mov 	ah, 9
	int 	21h

	in 		al,61h					;читаем байт с системного порта 61h
    or 		al,3             		;установкой двух младших битов в 1 устанавливаем управление динамиком
    out 	61h,al					; с помощью системного таймера
	
	mov 	al, 10110110b			;настраиваем таймер №2 на генерацию меандра 
	out 	43h, al
	
	mov 	ax, word ptr timerbuf 	;частота генерируемого звука
	mov 	bx,50					; равна 1190000/(случайное число*50)
	mul 	bx
	out 	42h, al	
	xchg 	al, ah
	out 	42h, al
	xor 	ax,ax
	
	mov 	al, 0ffh 	;посылаем на  Gate "1" - запустить таймер
	out 	61h, al
	
	mov		ah,08h 		;ожидание нажатия клавиши
	int		21h
	cmp		al,1bh		     ; проверяем введена ли кнопка = 1bh (Esc), если да, то выйти из программы
	je		exitmain

	and 	word ptr timerbuf, 0 		;очистка буферов 
	mov 	byte ptr screenbuf[2], 0
	mov 	word ptr screenbuf[0], 0
	jmp 	mainloop
exitmain:	
	mov 	al, 00h
	out 	61h, al 	;посылаем на  Gate "0" - остановить таймер
	
	mov		AH,4Ch 				;выход из программы
	int		21H
_CODE  ENDS
 END  _START