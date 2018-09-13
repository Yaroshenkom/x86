include mystruc.asm

STACK_SEG SEGMENT PARA STACK 'STACK'
    DB      100 DUP (?)
STACK_SEG ENDS

DATA_SEG SEGMENT 'DATA'
	stringbuff 	db 50 dup (?)
	maxask 		db 6
	realask 	db ?
	askbuff 	db 6 dup (?)
	findbuff 	db 7 dup (?)
	file_name 	db 	'list.txt',0
	ask1 	db 'Enter symbols to find$',10,13
	maxsize db 7
	handle 	dw 1
	currstring db (?)
DATA_SEG ENDS

_CODE   SEGMENT PARA 'CODE'
ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
START_:
	MOV     AX, DATA_SEG        ;завантажимо адресу сегмента даних
	MOV     DS, AX              ;у сегментний регістр DS
	XOR     AX, AX
	
	MOV 	AH,3Dh
	MOV 	AL,2
	LEA 	DX,file_name
	INT 	21h
	MOV 	[handle],AX
	XOR 	AX,AX
	
	MOV  	AH,0    ;очищуємо вікно виводу
	MOV  	AL,2
	int  	10h
	
	LEA  	DX,ask1 	
	MOV  	AH,09h
	INT  	21h

	LEA  	DX,maxask 	
	LEA 	SI,maxask
	MOV  	AH,0ah
	INT  	21h
	
	MOV  	AH,3fh
	MOV  	BX,[handle]
	LEA 	DX,stringbuff
	MOV 	CX,50
	INT 	21h
	MOV 	currstring,0
search:	
	INC 	currstring
	MOV  	AH,3fh
	MOV  	BX,[handle]
	LEA 	DX,stringbuff
	MOV 	CX,50
	INT 	21h
string1:
	CMP 	BX,realask+1
	JE 		exit
	CLD
	MOV 	CX,50
continue:
	MOV 	AL,byte ptr [SI]
	LEA 	DI,stringbuff
	
	REPNE 	scasb
	JNZ 	search
	JZ 		string2
string2:
	PUSH 	BX
	MOV 	BX,0

	INC 	BX
	MOV 	AL,[SI+BX]
	scasb 	
	JNZ 	out2
	jne 	string2
	MOV 	findbuff[BX],currstring
exit:
	MOV		AH,4Ch 				;виходимо з програми
	INT		21H