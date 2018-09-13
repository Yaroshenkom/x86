STACK_SEG SEGMENT PARA STACK 'STACK'
    DB      100 DUP (?)
STACK_SEG ENDS

DATA_SEG SEGMENT 'DATA'
	BUF 	DB 	0
	BUF1 	DB	0
	OCTAVES DW 	2AF2h, 2144h, 18A2h, 1450h, 1228h, 914h, 48Ah, 245h, 122h ; кількість відліків, що відповідає ноті "До" кожній з 9 октав
DATA_SEG ENDS

_CODE   SEGMENT PARA PUBLIC 'CODE'
	ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
MAIN PROC 
	MOV     AX, DATA_SEG        
    MOV     DS, AX              
    MOV     ES, AX
    XOR     AX, AX

check: 		; очікуємо натискання клавіши
	CALL 	take_button 	; отримуємо скан-код останньої натиснутої клавіши
	CMP 	AL, 1 	; якщо це Esc - то виходимо з програми
	JE 		exitmain
	CMP 	BUF, AL	; якщо клавіша затиснута, 
	JE 		check ; то очікуємо її відтискання
	CMP 	BUF1, AL ; якщо клавіша відтиснута, 
	JE 		turn_off ; то від'єднуємо таймер від динаміка

	CMP 	AL, 2 ; перевіряємо,
	JL 		check ; чи натиснути клавіши 1-9
	CMP 	AL, 10
	JG 		check ; якщо ні - то очікуємо натискання іншої клавіши
	
	PUSH 	AX 
	ADD 	AL, 128 ; зберігаємо скан-код відтиснутої клавіши
	MOV 	BUF1, AL
	POP 	AX
	
	SUB 	AL, 2
	MOV 	BX, AX
	MOV 	AX, word ptr OCTAVES[BX] ; оберемо октаву
	
	PUSH 	AX
	
	MOV 	AL, 10110110b ; програмуєо таймер
	OUT 	43h, AL
	POP 	AX
	OUT 	42h, AL	
	XCHG 	AL, AH
	OUT 	42h, AL
	XOR 	AX,AX
	
	OR	 	AL, 3 ; під'єднуєио його до динаміка
	OUT 	61h, AL
	JMP 	check
turn_off:
	XOR		AL, 3 ; вивимкаємо таймер
	OUT 	61h, AL
	JMP		check
	
exitmain:
	MOV 	AL, 0 ; вивимкаємо таймер
	OUT 	61h, AL
	CLI                   
	XOR  	AX,AX            
	MOV  	ES,AX            
	MOV  	AL,ES:[41AH]  ; очищуємо буфер клавіатури
	MOV  	ES:[41CH],AL     
	STI 

	CLI
wait_kbd:
	mov		cx,2500h	;затримка приблизно 10 мсек
test_kbd:
	in		al,64h		;зчитуємо стан клавіатури
	test	al,2			;перевірка біту готовності
	loopnz	test_kbd	;повтор якщо не готово	
	MOV 	AL, 0dfh
	OUT 	60h, AL
	STI
	
	mov		AH,4Ch
	int		21H
MAIN 	ENDP

take_button 	PROC 	NEAR
	XOR 	AX,AX
	IN 		AL,60H 	; отримаємо скан-код клавіші із рА
	PUSH 	AX
	IN		AL,61H 	; ввід із порту рВ
	MOV 	AH,AL
	OR 		AL,80H 	; встановити біт "підтвердження вводу"
	OUT 	61H,AL 	; відправляємо змінений байт в порт
	XCHG 	AH,AL 	; вивести старе значення рВ
	OUT 	61H,AL 		
	POP 	AX
	RET
take_button	ENDP
_CODE 	ENDS
END 	MAIN