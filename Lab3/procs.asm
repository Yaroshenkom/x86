	NAME time	
		
_CODE1	SEGMENT 	'CODE'
	PUBLIC	Taketime
	Public 	Delay
	ASSUME	CS:_CODE1
	
;==============Процедура виводу поточного часу та числа на екран	
Taketime PROC FAR			
	PUSH 	BP
	MOV 	BP,SP 			;"призначуємо" ВР покажчиком вікна в стеці
	
	;записуємо поточнй час у відповідні регістри
	MOV 	AH,2ch			
	INT 	21h				
	XOR 	AH,AH
	MOV 	BX,[BP+6] 		;регістр ВХ тепер містить адресу масиву для запису часу
	MOV 	[BX],CH 		;записуємо години
	MOV 	[BX+1],CL		;хвилини
	MOV 	[BX+2],DH		;секунди
	
	MOV 	AH,2ah 			;отримуємо поточну дату
	INT 	21h		
	XOR 	AH,AH
	
	MOV 	[BX+3],DL 		;записуємо поточне число
	XOR 	AX,AX
	XOR 	CX,CX
	XOR 	DX,DX
	
	;виводимо час і дату згідно із заданим в умові форматом
	;ГГ:ХХ:СС.ДД
	MOV 	SI,0
mbegin:	
	MOV 	AL,[BX+SI]
	CALL 	Showsymbols 	;процедура символьного виводу двохзначного числа 
	MOV 	DL,":"
	MOV 	AH,02h
	INT 	21h
	INC 	SI
	CMP 	SI,2
	JNE		mbegin 	
	MOV 	AL,[BX+SI]
	CALL 	Showsymbols
	MOV 	DL,"."
	MOV 	AH,02h
	INT 	21h
	INC 	SI
	MOV 	AL,[BX+SI]
	CALL 	Showsymbols
	
	MOV 	AH,02h 			;перевод каретки на наступну строку
	MOV 	DL,0ah
	INT 	21h
	
	MOV 	DL,0dh			;перевод каретки на початок строки		
	INT 	21h
	XOR 	AX,AX
	POP 	BP
	RETF 4 	
Taketime ENDP
;============================

;==============Процедура виведення двозначного числа на екран
Showsymbols PROC FAR
	AAM 					;перевод двійкового числав в упакований BCD формат
	MOV 	CX,AX	
	ADD 	CX,3030h		;перевод BCD-числа в ASCII формат
	
	MOV 	AH,02h 			;вивід десятків
	MOV		DL,CH
	INT 	21h
	MOV		DL,CL 			;вивід одиниць
	INT 	21h
	XOR 	CX,CX
	XOR 	AX,AX
	RETF 	
Showsymbols ENDP
;============================

;==============Процедура очікування (5 секунд)
Delay 	PROC FAR
	PUSH 	BP
	MOV 	BP,SP 				;"призначуємо" ВР покажчиком вікна в стеці
	
	MOV 	BX,[BP+6]			;регістр ВХ тепер містить адресу масиву для запису часу
	MOV 	AL,[BX+2]
	ADD 	AL,5 				;додаючи до поточного часу 5 секунд
	MOV 	[BX+2],AL			;встановлюємо кінець затримки
	MOV 	CX,2
	MOV 	SI,2
	
	;контролюємо коректність додавання 5 секунд
incycle:	
	CMP 	byte ptr [BX+SI],59 ;запобігаємо запису >60 секунд і 
	JBE 	checktime			;>60 хвилин
	MOV 	AL,60
	SUB 	[BX+SI],AL
	DEC 	SI
	INC 	byte ptr [BX+SI]
	LOOP 	incycle
	
	CMP 	byte ptr [BX+SI],23	;запобігаємо запису >24 годин
	JBE 	checktime
	MOV 	AL,24
	SUB 	[BX+SI],AL 			
	INC 	byte ptr [BX+3]
checktime:	
	MOV 	AH,2ch 				;отримуємо поточнй час
	INT 	21h
	XOR 	AH,AH
	
	CMP 	[BX+2],DH 			;порівнюємо поточні секунди із 
	JNE 	checktime			;секундами часу завершення затримки
	CMP 	[BX+1],CL			;порівнюємо поточні хвилини із
	JNE 	checktime			;хвилинами часу завершення затримки
	CMP 	[BX],CH				;порівнюємо поточні години із
	JNE 	checktime			;годинами часу завершення затримки
	
	MOV 	AH,2ah				;отримуємо поточне число
	INT 	21h		
	XOR 	AH,AH
	
	CMP 	[BX+3],DL			;порівнюємо поточне число із
	JNE 	checktime			;числом дати затримки
	
	POP 	BP
	RETF 4
Delay 	ENDP
_CODE1  ENDS
	END
	
	
	
	