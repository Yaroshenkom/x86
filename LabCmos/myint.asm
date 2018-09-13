NAME    procs

DATA_SEG1 SEGMENT 'DATA'
    cnt     DB  0 					;місце для запису секунд
	template     DB  '0', 00000111b  ;шаблон виводу символа
	buf 	DW 	2 DUP (0) 			;буфер виводу на екран
DATA_SEG1 ENDS
    
_CODE   SEGMENT PARA PUBLIC 'CODE'
    PUBLIC  new70
    ASSUME  CS:_CODE, DS:DATA_SEG1, ES:DATA_SEG1
    
new70 PROC FAR
	PUSH 	DS 	;збереження регістрів
	PUSH 	ES
	PUSH 	CX
    PUSH    AX
    PUSH    BX
    PUSH    SI
    PUSH    DI
	
	MOV     AX, DATA_SEG1        
    MOV     DS, AX              
    MOV     ES, AX
    XOR     AX, AX
	MOV 	AX, word ptr template[0] ;запис шаблону вивода в буфер
	MOV 	word ptr buf[0], AX
    MOV 	word ptr buf[2], AX
	
	MOV     AL, 0h 			;отримання поточного
    OUT     70h, AL			; значення секунд
    IN      AL, 71h
	CMP 	cnt, AL 		;якщо поточне і минуле значення
	JE 		outint			; секунд співпадають, то виходимо з обробника,
	MOV 	cnt, AL			; якщо ні, записуємо нове значення секунд в пам'ять
	
	AAM 					;записуємо в буфер поточне значення секунд
	ADD 	byte ptr buf[0],AH
	ADD 	byte ptr buf[2], AL
	
    CLD 					;виводимо на екран поточне значення секунд
    MOV   	CX, 2
    LEA   	SI, buf[0]
    MOV   	AX, 0B800h
    MOV   	ES, AX
    MOV   	DI, 156
    REP   	MOVSW
outint:    
    MOV     AL, 0Ch 		;зчитуємо значення статусного регістра С
    OUT     70h, AL			; задля дозволення подальших переривань від годинника
    IN      AL, 71h
    
    MOV     AL, 20h 		;разблокуємо переривання
    out     20h, AL
    out     0a0h, AL
    
    POP     DI 				;відновлення регістрів
    POP     SI
    POP     BX
    POP     AX
	POP 	CX
	POP 	ES
	POP 	DS
    IRET
new70 ENDP

_CODE ENDS
END