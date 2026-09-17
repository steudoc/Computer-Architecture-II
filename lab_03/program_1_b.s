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
	li x10, 3	# constant 3
	fadd.s f10, f0, f0	# b = 0
	
loop:	
	# LOAD PHASE - Load data for BOTH iterations
	flw f1, 0(x1)		# iter1: v1[i]
	flw f2, 0(x2)		# iter1: v2[i]
	flw f3, 0(x3)		# iter1: v3[i]
	flw f11, -4(x1)		# iter2: v1[i-1]
	flw f12, -4(x2)		# iter2: v2[i-1]
	flw f13, -4(x3)		# iter2: v3[i-1]
	
	# NTEGER COMPUTE PHASE - Interleave both iterations
	# Iteration 1: Start remainder and shifts
	rem x11, x7, x10	# iter1: i % 3
	sll x12, x8, x7		# iter1: m << i
	mul x13, x8, x7		# iter1: m * i
	
	# Iteration 2: Calculate next i and start its operations
	addi x9, x7, -1		# iter2: i-1
	rem x14, x9, x10	# iter2: (i-1) % 3
	
	# Iteration 1: Branch decision
	bnez x11, not_mul_1
	fcvt.s.w f8, x12	# iter1: shift path
	j skip_mul_1
not_mul_1:	
	fcvt.s.w f8, x13	# iter1: multiply path
skip_mul_1:
	
	# Start iter1 division (long latency)
	fdiv.s f9, f1, f8 	# iter1: a = v1[i] / ...
	
	# Iteration 2: Complete integer ops while div completes
	sll x15, x8, x9		# iter2: m << (i-1) - use OLD m value
	mul x16, x8, x9		# iter2: m * (i-1) - use OLD m value
	
	# Iteration 2: Branch decision
	bnez x14, not_mul_2
	fcvt.s.w f18, x15	# iter2: shift path
	j skip_mul_2
not_mul_2:	
	fcvt.s.w f18, x16	# iter2: multiply path
skip_mul_2:
	
	# Start iter2 division (interleaved with iter1)
	fdiv.s f19, f11, f18	# iter2: a = v1[i-1] / ...
	
	# COMPLETE ITERATION 1
	# Convert iter1 result (division should be near complete)
	fcvt.w.s x8, f9		# iter1: m = (int) a (for next loop)
	
	# v4[i] = a * v1[i] - v2[i]
	fmul.s f14, f9, f1	# iter1: a * v1[i]
	fsub.s f4, f14, f2	# iter1: - v2[i]
	
	# v5[i] = v4[i]/v3[i] - b (start division)
	fdiv.s f5, f4, f3	# iter1: v4[i]/v3[i]
	
	# INTERLEAVE ITERATION 2 COMPUTATION
	# Convert iter2 result while iter1 division runs
	fcvt.w.s x17, f19	# iter2: m_temp = (int) a
	
	# v4[i-1] = a * v1[i-1] - v2[i-1]
	fmul.s f24, f19, f11	# iter2: a * v1[i-1]
	
	# Complete iter1 v5
	fsub.s f5, f5, f10	# iter1: - b
	
	# Continue iter2 v4
	fsub.s f14, f24, f12	# iter2: v4[i-1]
	
	# v6[i] = (v4[i]-v1[i])*v5[i]
	fsub.s f6, f4, f1	# iter1: v4[i]-v1[i]
	
	# v5[i-1] = v4[i-1]/v3[i-1] - b
	fdiv.s f15, f14, f13	# iter2: v4[i-1]/v3[i-1]
	
	# Complete iter1 v6
	fmul.s f6, f6, f5	# iter1: * v5[i]
	
	# Complete iter2 v5
	fsub.s f15, f15, f10	# iter2: - b
	
	# Store iter1 results
	fsw f4, 0(x4)
	fsw f5, 0(x5)
	fsw f6, 0(x6)
	
	# v6[i-1] = (v4[i-1]-v1[i-1])*v5[i-1]
	fsub.s f16, f14, f11	# iter2: v4[i-1]-v1[i-1]
	fmul.s f16, f16, f15	# iter2: * v5[i-1]
	
	# Store iter2 results
	fsw f14, -4(x4)
	fsw f15, -4(x5)
	fsw f16, -4(x6)
	
	addi x1, x1, -8		
	addi x2, x2, -8
	addi x3, x3, -8
	addi x4, x4, -8
	addi x5, x5, -8
	addi x6, x6, -8
	
	addi x7, x7, -2		# Decrement by 2
	
	# Continue if x7 >= 1 (need at least 2 elements)
	li x20, 1
	bge x7, x20, loop

End:
	# exit() syscall
	li a0, 0
	li a7, 93
	ecall
