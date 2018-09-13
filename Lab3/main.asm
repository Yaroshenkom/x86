	NAME    main
	STACK_SEG SEGMENT PARA STACK 'STACK'
	DB      100 DUP(?)
	STACK_SEG ENDS

	DATA_SEG SEGMENT 'DATA'
	counter 	db 2
	time_dat 	db 4 dup (?)
	DATA_SEG ENDS

	_CODE   SEGMENT PARA 'CODE'
	EXTRN   Taketime:FAR
	EXTRN 	Delay:FAR
	ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
START_:                 
	MOV     AX, DATA_SEG        ;завантажимо адресу сегмента даних
	MOV     DS, AX              ;у сегментний регістр DS
	XOR     AX, AX

	MOV 	AH,0				;очищуємо вікно виводу
    MOV 	AL,2
    int 	10h
	LEA     AX, time_dat		;завантажуємо в стек 
	PUSH    AX					;адресу в пам'яті,
	XOR     AX, AX				;в якій зберігаємо поточний час
	CALL    Taketime			;заповнюємо масив значенням часу і виводимо його
								;у вікно виводу
m1:	
	LEA     AX, time_dat 		;чекаємо 5 секунд
	PUSH    AX	
	XOR     AX, AX
	CALL 	Delay	
	
	LEA     AX, time_dat 		;виводимо час на екран
	PUSH    AX
	XOR     AX, AX
	CALL    Taketime
	DEC 	counter
	CMP 	counter,0
	JNE 	m1					;повторюємо затримку в 5с и вивід на екран
	
	MOV 	AH,08h				;очікуємо натискання будь-якої клавіши
	int 	21h
	
	MOV		AH,4Ch 				;виходимо з програми
	INT		21H
 _CODE  ENDS
 END  START_         