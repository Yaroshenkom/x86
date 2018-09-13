NAME    procs

_CODE1	SEGMENT 	'CODE'
	PUBLIC 	Mult
	ASSUME 	CS:_CODE1
	
Mult PROC FAR
	PUSH 	BP
	MOV 	BP,SP 
	;Наше стекове вікно:
	;bp=sp->old_bp
	;bp+2 ->ip
	;bp+4 ->cs
	;bp+6 ->res
	;bp+8 ->inputs+1
	;bp+10 ->inputf+1
	
	MOV 	BX,[BP+6]
	MOV 	SI,[BP+10]
	MOV 	DI,[BP+8]
	
	MOV 	CX,DI	 		;підготуємо СХ для застосування в циклі
	XOR 	AX,AX
	MOV 	AL,byte ptr [SI]
	
	ADD 	BX,AX		
	MOV 	AL,byte ptr [DI]
	ADD 	BX,AX		;тепер ВХ вказує на кінець res + 1
	
	MOV 	byte ptr [BX],'$'		;кінець строки після res
	DEC 	BX
	XOR 	AX,AX
	MOV 	AL,byte ptr [SI]
	ADD 	SI,AX			;SI тепер вказує на молодший байт першого множника
	MOV 	AL,byte ptr [DI]
	ADD 	DI,AX		;DI тепер вказує на молодший байт другого множника
	
m1:
	MOV 	AL,byte ptr [SI] 	;будемо використовувати AL для побайтового перемноження
	MOV 	DL,byte ptr [SI]	;запам1ятаємо в DL значення поточного байта 1 множника
m2:
	MUL 	byte ptr [DI]		;виконуємо безпосередньо множення байтів  
	ADD 	byte ptr [BX],AL 	;додємо результат з AX до відповідних байтів в масиві 
	ADD 	byte ptr [BX-1],AH	;результату
	DEC 	DI 					;зсуваємо вліво на 1 позицію вказівник 2 множника
	DEC 	BX					;зсуваємо вліво на 1 позицію вказівник результата
	XOR 	AH,AH
	MOV 	AL,DL
	CMP 	DI,[BP+8] 			;перевіряємо, чи не всі байти 2 множника ми перемножили з поточним байтом 1 множника
	JNE 	m2
	
	XOR 	AX,AX
	MOV 	AL,byte ptr [DI] 	
	ADD 	DI,AX				;знов встановлюємо DI на молодший байт другого множника
	ADD 	BX,AX 				;встановлюємо ВХ на місце, що відповідає SI-1 байту 1 множника
	DEC 	BX
	DEC 	SI
	CMP 	SI,[BP+10] 			;перевіряємо, чи не всі байти 2 множника ми перемножили з усіма байтами 1 множника
	JNE 	m1
	
	MOV 	BX,[BP+6] 			;записуємо в DХ адресу передостаннього за старшинством байта
	MOV 	DX,BX
	INC 	DX
	MOV 	SI,[BP+10] 			;відновлюємо значення регістрів після множення
	MOV 	DI,[BP+8]
	XOR 	AX,AX
	MOV 	AL,byte ptr [SI]
	ADD 	BX,AX
	MOV 	AL,byte ptr [DI]
	ADD 	BX,AX
m3:	 							;виконуємо корекцію результата
	DEC 	BX
	XOR 	AX,AX
	MOV		AL,byte ptr [BX]	
	AAM
	MOV 	byte ptr [BX],AL
	ADD 	byte ptr [BX-1],AH
	CMP 	DX,BX
	JNE 	m3
	
	POP 	BP
	RETF 	3
	
Mult 	ENDP
_CODE1  ENDS
	END

	
	
	