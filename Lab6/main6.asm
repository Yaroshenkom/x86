STACK_SEG SEGMENT PARA STACK 'STACK'
    DB      100 DUP (?)
STACK_SEG ENDS

DATA_SEG SEGMENT 'DATA'
	max 	db 	40
	real 	db 	?
	txt 	db 	40 dup (?)
	wcntr 	db 	2 dup (?)
	longestw  db 2 dup (?)
	txt1 	db 	13,10,'Number of words: $'
	txt2 	db 	13,10,'The longest word has $'
	txt3 	db 	' letters$'
	outbuff db 	'  $'
DATA_SEG ENDS
_CODE   SEGMENT PARA 'CODE'
	ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
START_:
	MOV     AX, DATA_SEG        ;завантажимо адресу сегмента даних
	MOV     DS,AX               ;у сегментний регістр DS
	XOR     AX,AX
	
	MOV  	AH,0    				;очищуємо вікно виводу
	MOV  	AL,2
	int  	10h
	
	LEA		DX,max						;задаємо параметри 
	MOV		AH,0Ah						;для переривання DOS INT 21 (0Ah) -введення строки символів в буфер
	INT		21H
	XOR 	AX,AX
	LEA 	SI,txt
	MOV 	CL,real
	MOV 	wcntr,0
	MOV 	longestw,0
c1b:								;цикл, що перевіряє, чи е введений символ літерою
	CMP 	byte ptr [SI],65
	JL 		c1e
	CMP 	byte ptr [SI],90
	JLE		cnt
	CMP 	byte ptr [SI],97
	JL 		c1e
	CMP 	byte ptr [SI],122
	JLE 	cnt
cnt: 								;якщо ж введений символ є літерою, це вказує на початок слова
	INC 	wcntr					
	LEA 	BX,longestw				;тому переходимо в цикл, що рахує кількість літер у слові
	JMP 	count
c1e: 
	INC 	SI
	LOOP 	c1b
	
	LEA 	BX,wcntr 				;підготуємо результат (кількість слів) для виводу на екран
	MOV 	AX,[BX]
	AAM 	
	ADD 	AX,3030h
	LEA 	BX,outbuff
	MOV 	byte ptr [BX],AH
	MOV 	byte ptr [BX+1],AL
	
	LEA  	DX,txt1 		;виводимо результат на екран
	MOV  	AH,09h 			
	int  	21h
	
	LEA  	DX,outbuff 				
	MOV  	AH,09h
	int  	21h
	
	LEA  	DX,txt2
	MOV  	AH,09h
	int  	21h
	
	LEA 	BX,longestw 			;підготуємо результат (довжина найбільшого слова) для виводу на екран
	MOV 	AX,[BX]
	AAM 	
	ADD 	AX,3030h
	LEA 	BX,outbuff
	MOV 	byte ptr [BX],AH
	MOV 	byte ptr [BX+1],AL
	
	LEA  	DX,outbuff 				;виводимо результат на екран
	MOV  	AH,09h
	int  	21h
	LEA  	DX,txt3
	MOV  	AH,09h
	int  	21h
	
	MOV  	AH,08h    ;очікуємо натискання будь-якої клавіши
	int  	21h
	
	MOV		AH,4Ch 				;виходимо з програми
	INT		21H
	
count:	
	MOV 	DX,0 				;в DX записуємо розмір поточного слова 
c2b:
	CMP 	byte ptr [SI],65 	;цикл, що перевіряє, чи е введений символ літерою
	JL 		jout
	CMP 	byte ptr [SI],90
	JLE		lcnt
	CMP 	byte ptr [SI],97
	JL 		jout
	CMP 	byte ptr [SI],122
	JB 		lcnt
lcnt:
	INC	 	DX
	INC 	SI
	JMP 	c2b
jout:							;якщо ж введений символ не є літерою, це вказує на кінець слова
	CMP 	DX,[BX]				;якщо розмір поточного слова більший за максимальний розмір минулих слів,
	JBE 	jret				;то розмір потоного слова стає новим максимальним значенням
	MOV 	[BX],DX
jret:
	JMP 	c1e 				;повертаємось в цикл пошуку початку слова
	
 _CODE  ENDS
 END  START_ 


	