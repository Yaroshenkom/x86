 STACK_SEG 	SEGMENT	PARA STACK 'STACK'
	DB	100 DUP(?)
 STACK_SEG	ENDS
 
 DATA_SEG		SEGMENT 
	WORLD       DB  ", world !!!!$"
	BUFF 		LABEL 	BYTE
	MAX			DB 	25							;максимальне число символів
	LENGT		DB  ?							;реальна довжина введеної строки
	INPUT		DB	25 DUP (?)					;безпосередньо буфер для розміщення символів
 DATA_SEG 	ENDS
 
 _CODE 		SEGMENT PARA 'CODE'
	ASSUME	CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
 BEG_:	
		PUSH 	DS							;записуємо в стек 
		XOR 	AX,AX						;адресу початку PSP, де знаходиться переривання INT 20h
		PUSH 	AX
		MOV		AX,DATA_SEG					;завантажимо адресу сегмента даних
		MOV		DS,AX						;у сегментний регістр DS
		XOR 	AX,AX

		
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
											
		RETF								; вихід в MS-DOS
 _CODE		ENDS
	END		BEG_                                           