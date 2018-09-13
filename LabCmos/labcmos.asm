NAME main

STACK_SEG SEGMENT PARA STACK 'STACK'
    DB      100 DUP (?)
STACK_SEG ENDS

DATA_SEG SEGMENT 'DATA'
    old70   db  4 DUP   (?)
DATA_SEG ENDS

_CODE   SEGMENT PARA PUBLIC 'CODE'
    EXTRN   new70:FAR
    ASSUME  CS:_CODE, SS:STACK_SEG, DS:DATA_SEG, ES:DATA_SEG
Start:
    MOV     AX, DATA_SEG       
    MOV     DS, AX              
    MOV     ES, AX
    XOR     AX, AX

    PUSh    ES
    MOV     AX, 3570h               ;зберігаємо адресу обробника переривання IRQ8
    INT     21h
    MOV     word ptr old70, BX     
    MOV     word ptr old70+2, ES    
    POP     ES

    CLI
    MOV     AX, 2570h 				;встановлюємо адресу нового обробника IRQ8
    MOV     DX, offset new70
    PUSH    DS
    PUSH    CS
    POP     DS
    INT     21h
    POP     DS
	
	MOV     AL, 0ah 				;встановлюємо частоту переривань IRQ8 в 2 Гц
    OUT     70h, AL
    IN      AL, 71h
    OR      AL, 00001111b
    OUT     71h, AL
	
    MOV     AL, 0Bh 				;дозволяємо періодичні переривання від годинника CMOS
    OUT     70h, AL
    IN      AL, 71h
    OR      AL, 01110100b
    XOR     AL, 01100000b   
    OUT     71h, AL
    STI
    
    MOV     AH,08h    ;очікуємо натискання клавіши
    INT     21h
    
    CLI
    MOV     AX, 2570h 			;встановлюємо адресу минулого обробника IRQ8
    MOV     DX, word ptr old70
    PUSH    DS
    MOV     DS, word ptr old70+2
    INT     21h
    POP     DS
    STI 
    
    MOV     AH,4Ch     ;виходимо з програми
    INT     21H
_CODE  ENDS
 END  Start
    