; fast_inv_sqrt.s (ARMASM / Keil syntax)
				THUMB
					
; ========== READONLY DATA SECTION ==========
				AREA	RO_DATA, DATA, READONLY
				
				ALIGN 4
				EXPORT	_Input_Values
_Input_Values
				DCD     0x40000000, 0x40800000, 0x41200000, 0x41C80000
                DCD     0x42C80000, 0x447A0000, 0x3F800000, 0x42480000
				
				ALIGN 1
				EXPORT _NUM_VALUES
_NUM_VALUES
				DCB		8
				
; ========== CODE SECTION ==========
				AREA 	|.text|, CODE, READONLY
				
				EXPORT	fast_magic_calc
					
; int fast_magic_calc(int input_float_as_int)
; r0: input (bits di float)
; return r0 = 0x5f3759 - (input >> 1)
fast_magic_calc	PROC
				PUSH	{lr}
				LSRS	r1, r0, #1			; r1 = input >> 1 (logic)
				LDR		r2, =0x5F3759DF		; magic constant
				SUBS	r0, r2, r1			; r0 = magic - shifted
				POP 	{lr}
				BX		lr
				ENDP
					
				END