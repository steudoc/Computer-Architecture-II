# Data section
.section .data
# Place here your program data.
#In this example, two vectors of floats
# a vector of ints and a single int are defined
V1:	.float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0
V2: 	.float 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5
V3: 	.float 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0
V4: 	.space 128
V5:	.space 128
V6: 	.space 128	

# Code section
.section .text
# The _start label signals the entry point of your program
# DO NOT CHANGE ITS NAME.
# It must be "-start", not "start", not "main", not "start_".
# It's "_start" with a leading '_' and all lowercase letters
.globl _start
_start:
	# In the _start area, load the first byte/word of each of 
	# the areas declared in the .data section
	# This is needed to load data in the cache and avoid
	# pipeline stalls later
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
	# Your code goes here
	li x7, 31
	li x8, 1	# m = 1
	li x10, 3	# costante 3
	fadd.s f10, f0, f0	# b = 0
	
loop:	
	flw f1, 0(x1)
	flw f2, 0(x2)
	flw f3, 0(x3)
	
	rem x11, x7, x10	# i % 3
	nop
	nop
	bnez x11, not_mul
	
	sll x12, x8, x7		# m << i
	fcvt.s.w f8, x12	# int -> float
	fdiv.s f9, f1, f8 	# a = v1[i] / ((float) m << i)
	fcvt.w.s x8, f9		# m = (int) a 
	j continue
not_mul:	
	mul x12, x8, x7		# (float) m * i
	fcvt.s.w f8, x12	# int -> float
	fmul.s f9, f1, f8	# a = v1[i] / ((float) m * i)	
	fcvt.w.s x8, f9		# m = (int) a

continue:	
	#v4[i] = a * v1[i] – v2[i]
	fmul.s f4, f9, f1
	fsub.s f4, f4, f2
	fsw f4, 0(x4)	
	
	#v5[i] = v4[i]/v3[i] – b							
	fdiv.s f5, f4, f3
	fsub.s f5, f5, f10
	fsw f5, 0(x5)
	
	#v6[i] = (v4[i]-v1[i])*v5[i]
	fsub.s f6, f4, f1
	fmul.s f6, f6, f5
	fsw f6, 0(x6)
	
	#increment addresses
	addi x1, x1, -4
	addi x2, x2, -4
	addi x3, x3, -4
	addi x4, x4, -4
	addi x5, x5, -4
	addi x6, x6, -4

	addi x7, x7, -1
	
	bgez x7, loop
End:
# exit() syscall. This is needed to end the simulation
# gracefully
	li a0, 0
	li a7, 93
	ecall
