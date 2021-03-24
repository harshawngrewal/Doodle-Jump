# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
# - 32 units per row = 128 bytes
.data
	displayAddress:	.word	0x10008000 # 268468224 in decimal
	
	# note that each step will take up 4 units = 16 bytes since each unit is 4 bytes 
	steponeAddress : .word  0x10008180 # 268468724 in decimal
	steptwoAddress: .word 0x10008820 # 268470272 in decimal 
	stepthreeAddress: .word 0x10008F40 # 268468104 in decxmal
	
.text
	lw $s0, displayAddress	# $t0 stores the base address for display
	li $s1, 0xff0000	# $t1 stores the red colour code
	li $s2, 0x00ff00	# $t2 stores the green colour code
	
	# This is the start address of the bitmap and the end address 
	add $s4, $0, $s0 
	addi $s5, $s0 4096	
	
	# each step
	lw $s6, steponeAddress
	lw $s7 steptwoAddress
	lw $s3 stepthreeAddress
		
	
main:
	
	# Gives us the bounds for each "step"
	
	
# need to intialize the background for the map 
repaint:
	beq, $s4, $s5, generate_steps
	sw $s1, 0($s4)
	addi $s4, $s4, 4
	j repaint

	
generate_steps:
	# top step
	sw $s2, 0($s6)
	sw $s2, 4($s6)
	sw $s2, 8($s6)
	sw $s2, 12($s6)
	sw $s2, 16($s6)
	sw $s2, 20($s6)
	sw $s2, 24($s6)
	
	# second step
	sw $s2, 0($s7)
	sw $s2, 4($s7)
	sw $s2, 8($s7)
	sw $s2, 12($s7)
	sw $s2, 16($s7)
	sw $s2, 20($s7)
	sw $s2, 24($s7)
	
	
	# third step
	sw $s2, 0($s3)
	sw $s2, 4($s3)
	sw $s2, 8($s3)
	sw $s2, 12($s3)
	sw $s2, 16($s3)
	sw $s2, 20($s3)
	sw $s2, 24($s3)
	
	

	# need to generate 2 random numbers from  0 - 40 and 0 - 128. this will give us the location of the new step
	# the bottom step we will erase and the other 2 steps we will shift down always by the same amount
	
	li $v0, 42  # generate a random number
	li $a1, 40  #random num between 0 and 40
    	syscall # will store the random number in a0
    	
    	move $t0, $a1 # store the random number in a temp register
    	
    	li $v0, 42  # generate a random number
	li $a1, 128  #random num between 0 and 40
    	syscall # will store the random number in a0
    	
    	move $t0, $a0 # store the random number in a temp register
    	
    	li $v0, 1  # generate a random number
	li $a1, 128  #random num between 0 and 128 
    	syscall # will store the random number in a0
    	
    	move $t1, $a0 # store the random number in a temp register
    	
    	#now that we have a new step, we update our bitmap and shift the other two
    	# this needs to be modified later so that 
    	
 
    	 
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall