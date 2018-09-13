include mystruc.asm

STACK_SEG SEGMENT PARA STACK 'STACK'
    DB      100 DUP (?)
STACK_SEG ENDS

DATA_SEG SEGMENT 'DATA'
	buf 	db (?)
	template 	student <,,,'DK-52'>
	file_name 	db 	'list.txt',0
	table_head  db 'N ','Name', 21 dup (' '),'Sport', 10 dup (' '),'Group',13,10 ;50
	handle 	dw 1
	space 	db ' '
	tab 	db 13,10 ;2
	maxsize db 7
	maxbuf 	db 7
	realbuf db ?
	txtbuf 	db 7 dup (?)
DATA_SEG ENDS

_CODE   SEGMENT PARA 'CODE'
ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
START_:
	MOV     AX, DATA_SEG        ;завантажимо адресу сегмента даних
	MOV     DS, AX              ;у сегментний регістр DS
	MOV 	ES, AX
	XOR     AX, AX
	
	MOV  AH,0    ;очищуємо вікно виводу
	MOV  AL,2
	int  10h

	LEA 	DX,maxbuf		;вводимо в буфер текст, що хочемо записати в усі поля Name файлу
	MOV 	ah,0ah
	int 	21h
	CLD
	XOR 	CX,CX 			;записуємо текст з буфера в поле Name структури
	MOV 	CL,realbuf
	LEA 	SI,txtbuf
	LEA 	DI,template.fsname
	ADD     DI,CX
	REP 	MOVSB
	
	
	MOV 	AH,3Dh			;відкриваємо файл на читання та запис
	MOV 	AL,2
	LEA 	DX,file_name
	INT 	21h
	MOV 	[handle],AX
	XOR 	AX,AX
	
	MOV 	AH,40h 			;записуємо в файл шапку таблиці
	MOV 	BX,[handle]
	LEA 	DX,table_head
	MOV 	CX,49
	INT 	21h
	LEA 	SI,template
	MOV 	DX,00h
wm1:
	INC		DX 				;записуємо в файл структуру 7 разів, з кожно строкою збільшуючи
	push 	DX				;поле number на 1
	ADD 	DX,3030h
	MOV 	byte ptr [SI].number,DL
	MOV 	AH,40h
	LEA 	DX,template
	MOV 	CX,size template
	int 	21h
	MOV 	AH,40h
	LEA 	DX,tab
	MOV 	CX,2
	int 	21h
	POP 	DX
	CMP 	DL,maxsize
	JNE 	wm1
	
	MOV		AH,4Ch 				;виходимо з програми
	INT		21H
 _CODE  ENDS
 END  START_  
	