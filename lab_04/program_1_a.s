# Data section
.section .data
# Place here your program data.
i:	.float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
w:	.float 0.1, 0.2, 0.15, 0.25, 0.3, 0.05, 0.12, 0.18, 0.22, 0.08, 0.13, 0.17, 0.19, 0.11, 0.14, 0.16
b:	.word 0xab
y:	.float 0.0
zero:	.float 0.0	

# Code section
.section .text
# The _start label signals the entry point of your program
.globl _start
_start:
	# In the _start area, load the first byte/word of each of 
	# the areas declared in the .data section
	# This is needed to load data in the cache and avoid
	# pipeline stalls later
	la x2, i
	la x3, w 
	la x4, b
	la x5, y 
	la x6, zero
	
	li x7, 16	# K = 16
	li x8, 0	# j = 0 
	li x9, 0xFF
	flw f1, 0(x6)	# accumulator = 0.0
	
Main:
	# Your code goes here
	flw f2, 0(x2)	# load i[j]
	flw f3, 0(x3)	# load w[j]
	
	# Compute i[j] * w[j]
	fmul.s f6, f2, f3
	
	# OPTIMIZATION: Increment counter and addresses while waiting for f6
	addi x2, x2, 4
	addi x3, x3, 4
	addi x8, x8, 1
	
	# Add to accumulator
	fadd.s f1, f1, f6
	
	# cycle control
	blt x8, x7, Main

add_bias:	
	# Compute X
	flw f4, 0(x4)
	fadd.s f1, f1, f4
	
check_exponent:
	fmv.x.w x11, f1
	
	# Shift right by 23 bits to get exponent in lower bits
    	srli x12, x11, 23     # x18 = x17 >> 23
    	
    	# Mask to get only the 8-bit exponent (0xFF)
    	andi x12, x12, 0xFF   # x18 = exponent (8 bits)
    	
    	# Check if exponent == 0xFF (0x7FF is for double precision, 0xFF for single)
	beq x12, x9, set_zero # If exponent == 0xFF, set y = 0

	# Exponent is not 0xFF, so y = x
	fmv.s f5, f1          # y = x
	j store_result
	
set_zero:
	flw f5, 0(x6)	# y = 0	
	
store_result:
	fsw f5, 0(x5)	
	
End:
# exit() syscall. This is needed to end the simulation
# gracefully
	li a0, 0
	li a7, 93
	ecall
