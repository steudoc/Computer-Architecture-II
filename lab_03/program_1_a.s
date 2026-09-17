# Data section
.section .data

V1:	.float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0
V2: 	.float 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5
V3: 	.float 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0
V4: 	.space 128
V5:	.space 128
V6: 	.space 128	

# Code section
.section .text

.globl _start
_start:
	la x1, V1
	la x2, V2
	la x3, V3
	la x4, V4
	la x5, V5
	la x6, V6
	
	addi x1, x1, 124
	addi x2, x2, 124
	addi x3, x3, 124
	addi x4, x4, 124
	addi x5, x5, 124
	addi x6, x6, 124
Main:
	li x7, 31
	li x8, 1	# m = 1
	li x10, 3	# costante 3
	fadd.s f10, f0, f0	# b = 0
	
loop:	
	# OPTIMIZATION: Load all data early to hide latency
	flw f1, 0(x1)
	flw f2, 0(x2)
	flw f3, 0(x3)
	
	# OPTIMIZATION: Start remainder calculation early
	rem x11, x7, x10	# i % 3
	
	# OPTIMIZATION: Interleave independent integer ops during rem latency
	# Pre-calculate both paths to reduce branch penalty
	sll x12, x8, x7		# m << i (for mul path)
	mul x13, x8, x7		# m * i (for not_mul path)
	
	# OPTIMIZATION: Branch decision (x11 should be ready by now)
	bnez x11, not_mul
	
	# mul path: Use x12 (shift result)
	fcvt.s.w f8, x12	# int -> float
	# OPTIMIZATION: Start division early
	fdiv.s f9, f1, f8 	# a = v1[i] / ((float) m << i)
	
	# OPTIMIZATION: Do independent work while waiting for division
	# Start next iteration's address calculations
	addi x1, x1, -4
	addi x2, x2, -4
	addi x3, x3, -4
	
	fcvt.w.s x8, f9		# m = (int) a 
	j continue
not_mul:	
	fcvt.s.w f8, x12	# int -> float
	fmul.s f9, f1, f8	# a = v1[i] / ((float) m * i)
	
	# OPTIMIZATION: Do independent work during multiply latency
	addi x1, x1, -4
	addi x2, x2, -4
	addi x3, x3, -4
		
	fcvt.w.s x8, f9		# m = (int) a

continue:	
	#v4[i] = a * v1[i] – v2[i]
	fmul.s f14, f9, f1
	
	# OPTIMIZATION: Start second division while first multiply completes
	# v5[i] = v4[i]/v3[i] – b (start division early)
	# Wait for f4 from previous instruction
	fdiv.s f5, f14, f3
	
	# OPTIMIZATION: Continue with independent operations
	# Complete v4[i] calculation
	fsub.s f4, f14, f10
	
	# OPTIMIZATION: Continue address updates (independent)
	addi x4, x4, -4
	addi x5, x5, -4
	addi x6, x6, -4
	
	# Store v4[i]
	fsw f4, 4(x4)	# Adjust offset since we already decremented
	
	# OPTIMIZATION: Start v6 calculation while division completes
	# v6[i] = (v4[i]-v1[i])*v5[i]
	fsub.s f6, f4, f1	
	
	# Complete v5[i] (division should be done or close)							
	fsub.s f5, f5, f10
	fsw f5, 0(x5)
	
	# Complete v6[i]
	fmul.s f6, f6, f5
	fsw f6, 0(x6)

	# OPTIMIZATION: Counter decrement last (all address updates done)
	addi x7, x7, -1
	
	bgez x7, loop
End:
# exit() syscall. This is needed to end the simulation
# gracefully
	li a0, 0
	li a7, 93
	ecall
