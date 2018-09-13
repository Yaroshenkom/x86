NAME    main

STACK_SEG SEGMENT PARA STACK 'STACK'
    DB      100 DUP(?)
STACK_SEG ENDS

DATA_SEG SEGMENT 'DATA'
    BUFF    STRUC 
		MAX             DB      12
		RLNGT           DB      ?
		NBRS            DB      12  DUP (?)
	BUFF    ENDS
	inputf  BUFF <>
	inputs  BUFF <>
	entf            DB      'Enter the first multiplier: $'
	ents            DB      0dh,0ah, 'Enter the second multiplier: $'
	outres          DB      0dh,0ah, 'The result is $'
	res             DB      25 DUP  (?)
DATA_SEG ENDS

_CODE   SEGMENT PARA 'CODE'
	EXTRN  Mult:FAR
	ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
START_: 
	 MOV     AX, DATA_SEG        ;завантажимо адресу сегмента даних
	 MOV     DS,AX              ;у сегментний регістр DS
	 XOR     AX,AX
	 
	 MOV  AH,0    ;очищуємо вікно виводу
		MOV  AL,2
		int  10h
	 
	 LEA  DX,entf
	 MOV  AH,09h
	 INT  21h
	 
	 LEA  DX,inputf 	;записуємо перший множник
	 MOV  AH,0Ah
	 INT  21h
	 LEA  DX,inputf.RLNGT 	;"кладемо" в стек адресу 1 множника
	 PUSH  DX
	 
	 LEA  BX,inputf.NBRS
	 XOR  CX,CX
	 MOV  CL,inputf.RLNGT
	ms1:
	 SUB  byte ptr [BX],30h 	;перетворюємо з ASCII в неупакований BCD 1 множник
	 INC  BX
	 LOOP  ms1
	 
	 LEA  DX,ents
	 MOV  AH,09h
	 INT  21h
	 
	 LEA  DX,inputs 	;записуємо другий множник
	 MOV  AH,0Ah
	 INT  21h
	 LEA  DX,inputs.RLNGT 	;"кладемо" в стек адресу 2 множника
	 PUSH  DX
	 
	 LEA  BX,inputs.NBRS
	 XOR  CX,CX
	 MOV  CL,inputs.RLNGT
	ms2:
	 SUB  byte ptr [BX],30h 	;перетворюємо з ASCII в неупакований BCD 1 множник
	 INC  BX
	 LOOP  ms2
	 
	 XOR  AX,AX
	 LEA  AX,res
	 PUSH  AX 			;"кладемо" в стек адресу результата
	  
	 CALL  Mult
	 
	 LEA  BX,res
	ms3: 						;перетворюємо результат з unpacked BCD в ASCII
	 ADD  byte ptr [BX],30h
	 INC  BX
	 CMP  byte ptr [BX],'$'
	 JNE  ms3
	 
	 LEA  DX,outres
	 MOV  AH,09h
	 INT  21h
	 
	 LEA  DX,res 		;виводимо результат на екран
	 MOV  AH,09h
	 int  21h
	 
	 MOV  AH,08h    ;очікуємо натискання будь-якої клавіши
	 int  21h
	 
	 MOV  AH,4Ch     ;виходимо з програми
	 INT  21H
 
_CODE  ENDS
 END  START_  