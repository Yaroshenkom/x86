CODE_SEG SEGMENT
ASSUME  CS:CODE_SEG, DS:CODE_SEG, SS:CODE_SEG, ES:CODE_SEG
        ORG     100h

START_:                 

			JMP     BEG_					;������� �� ��������� ��������
	WORLD       DB  ", world !!!!$"
	BUFF 		LABEL 	BYTE
	MAX			DB 	25							;����������� ����� �������
	LENGT		DB  ?							;������� ������� ������� ������
	INPUT		DB	25 DUP (?)					;������������� ����� ��� ��������� �������


BEG_:     
        LEA		DX,BUFF						;������ ��������� 
		MOV		AH,0Ah						;��� ����������� DOS INT 21 (0Ah) -�������� ������ ������� � �����
		INT		21H							;������ ������ �����������
		
		XOR 	AX,AX						;������� ������ 
		MOV 	AL,LENGT					;���������� ������� �� ������
		MOV		SI,AX						;���� ������
		MOV 	INPUT[SI],"$"				;
		
		LEA     DX, INPUT                   ;������ ���������       
        MOV     AH, 09h                     ;��� ����������� DOS INT 21 (09h) -�������� ������ ������� �� �����       
        INT     21h 
		
		LEA     DX, WORLD                   ;������ ���������                            
        INT     21h 						;��� ����������� DOS INT 21 (09h) -�������� ������ ������� �� �����
											
		RET								; ����� � MS-DOS                   
CODE_SEG ENDS
        END     START_