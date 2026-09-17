			AREA lfsr_step, CODE, READONLY
			EXPORT lfsr_step
			
			; Prototype:
			; unsigned char lfsr_step(unsigned char current_state, unsigned char taps, int *output_bit)
			
			PUSH {r4, r5, r6, lr}
			
			; r0 = current_state	; a0
			; r1 = taps				; a1
			; r2 = output_bit		; a2
			
			; *output_bit = current_state & 0x01
			AND 	r3, r0, #1
			STR		r3, [r2]
			
			; feedback = 0
			MOV 	r4, #0
			
			; loop on 8 bit
			MOV r3, #0
loop_taps
			CMP 	r3, #8
			BEQ 	end_loop
			
			; if (taps & (1 << i)
			MOV 	r5, #1
			LSL		r5, r5, r3
			TST 	r1, r5
			BEQ 	skip_xor
			
			; feedback ^= (current_state >> i) & 0x01
			LSR 	r6, r0, r3
			AND 	r6, r6, #1
			EOR		r4, r4, r6
			
skip_xor	
			ADD		r3, r3, #1
			B 		loop_taps
			
end_loop	
			; new_state = (current_state >> 1) | (feedback)
			LSR 	r0, r0, #1
			LSL		r4, r4, #7
			ORR		r0, r0, r4
			
			POP 	{r4, r5, r6, pc}
			END
			
			
			
			
			
			
			
			
			
			
			