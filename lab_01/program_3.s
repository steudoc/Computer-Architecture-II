# Data section
.section .data
# Place here your program data.
V1:	.byte	2, 6, -3, 11, 9, 18, -13, 16, 5, 1 
V2:	.byte	4, 2, -13, 3, 9, 9, 7, 16, 4, 7 
V3: 	.space	10
flag1:	.byte 	1
flag2: 	.byte   1
flag3:	.byte 	1

# Code section
.section .text
# The _start label signals the entry point of your program
.globl _start 
_start:
	# In the _start area, load the first byte/word of each of 
	# the areas declared in the .data section
	# This is needed to load data in the cache and avoid 
	# pipeline stalls later
	la x1, V1
	la x2, V2
	la x3, V3
	
	li x4, 0	# i = 0 (V1 index)
	li x8, 10
	li x9, 1	# flag 1
	li x10, 1	# flag 2
	li x11, -129
	li x12, 1	# flag 3
	li x13, 129
	
	la x14, flag1
	la x15, flag2
	la x16, flag3
Main:
	# Your code goes here
	bge x4, x8, End
	
	lb x5, 0(x1)	# loads the i element of V1
	
	li x6, 0	# j = 0 (V2 index)
	li x17, 0	# match flag
	
loop:	# cycle on V2 elements
	bge x6, x8, next1
	
	lb x7, 0(x2)	# loads the i element of V2
	
	beq x5, x7, Match
	j next2
	
Match: 	
	sb x5, 0(x3)	# store the match in V3
	addi x3, x3, 1
	addi x9, x0, 0
	addi x17, x17, 1
	blt x11, x5, str_incr
	addi x10, x0, 0
	
	blt x5, x13, str_decr
str_incr:
	addi x12, x0, 0
str_decr:
	addi x11, x5, 0
	addi x13, x5, 0
next2:
	addi x6, x6, 1	# j++
	addi x2, x2, 1
	bnez x17, next1
	j loop
	
next1:
	addi x1, x1, 1
	addi x4, x4, 1	# i++
	la x2, V2
	j Main		
	
End:
	sb x9, 0(x14)
	sb x10, 0(x15)
	sb x12, 0(x16)
# exit() syscall. This is needed to end the simulation gracefully
	li a0, 0
	li a7, 93
	ecall


