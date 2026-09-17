		AREA SVC_Handler_Area, CODE, READONLY
		EXPORT SVC_Handler
		
SVC_Handler
		; Extract lower 4 bits (d1...d4)
		MRS r1, IPSR
		MOV 