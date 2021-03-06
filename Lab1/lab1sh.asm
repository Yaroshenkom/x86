.model  tiny
.code
        org 100h
start:
        LEA		DX,BUFF						;задаємо параметри 
		MOV		AH,0Ah						;для переривання DOS INT 21 (0Ah) -введення строки символів в буфер
		INT		21H							;виклик самого переривання
		
		XOR 	AX,AX						;замінимо символ 
		MOV 	AL,LENGT					;повернення каретки на символ
		MOV		SI,AX						;кінця строки
		MOV 	INPUT[SI],"$"				;
		
		LEA     DX, INPUT                   ;задаємо параметри       
        MOV     AH, 09h                     ;для переривання DOS INT 21 (09h) -введення строки символів на екран       
        INT     21h 
		
		LEA     DX, WORLD                   ;задаємо параметри                            
        INT     21h 						;для переривання DOS INT 21 (09h) -введення строки символів на екран
											
		RET								; вихід в MS-DOS                   
	WORLD       DB  ", world !!!!$"
	BUFF 		LABEL 	BYTE
	MAX			DB 	25							;максимальне число символів
	LENGT		DB  ?							;реальна довжина введеної строки
	INPUT		DB	25 DUP (?)					;безпосередньо буфер для розміщення символів
        end     start
