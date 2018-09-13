NAME 	counter
_CODE1   SEGMENT PARA 'CODE'
	PUBLIC 		lenghtcounter
	ASSUME 	CS:_CODE1
lenghtcounter PROC FAR	
START1_:
	MOV 	DX,0
c2b:
	CMP 	byte ptr [SI],65
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
jout:	
	CMP 	DX,[BX]
	JBE 	jret
	MOV 	[BX],DX
jret:
	RETF 	
lenghtcounter	ENDP
_CODE1  ENDS
	END