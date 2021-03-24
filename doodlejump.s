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
	displayAddressStart:	.word	0x10008000 # 268468224 in decimal
	displayAddressEnd: 	.word   0x10009000 # the end of display
	
	
	# note that each step will take up 4 units = 16 bytes since each unit is 4 bytes 
	steponeAddress : .word  0x10008180 # 268468724 in decimal
	steptwoAddress: .word 0x10008820 # 268470272 in decimal 
	stepthreeAddress: .word 0x10008F40 # 268468104 in decxmal
	
.text
	li $s1, 0xff0000	# $t1 stores the red colour code
	li $s2, 0x00ff00	# $t2 stores the green colour code
		
	# each step
	lw $s3, steponeAddress
	lw $s4 steptwoAddress
	lw $s5 stepthreeAddress
		
	
main:
	lw $t0, displayAddressStart # temp vars so that we can paint entire bitmap
	lw $t1, displayAddressEnd
		
# need to intialize the background for the map 
repaint:
	
	beq, $t0, $t1, generate_doodle_and_steps
	sw $s1, 0($t0)
	addi $t0, $t0, 4
	j repaint


generate_doodle_and_steps:

	# fist step
	sw $s2, 0($s3)
	sw $s2, 4($s3)
	sw $s2, 8($s3)
	sw $s2, 12($s3)
	sw $s2, 16($s3)
	sw $s2, 20($s3)
	sw $s2, 24($s3)
	
	# second step
	sw $s2, 0($s4)
	sw $s2, 4($s4)
	sw $s2, 8($s4)
	sw $s2, 12($s4)
	sw $s2, 16($s4)
	sw $s2, 20($s4)
	sw $s2, 24($s4)
	
	
	# third step
	sw $s2, 0($s5)
	sw $s2, 4($s5)
	sw $s2, 8($s5)
	sw $s2, 12($s5)
	sw $s2, 16($s5)
	sw $s2, 20($s5)
	sw $s2, 24($s5)
	
	#doodle
	
	
	
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