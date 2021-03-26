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
	stepsArray:	.word  0x10008180, 0x10008820, 0x10008F40
	
	# this will hold the contents of the character in our game
	personArray: 	.word 0x10008E40, 0x10008DC0, 0x10008DC4, 0x10008DC8, 0x10008D48, 0x10008DCC, 0x10008DD0, 0x10008E50
			
	
.text
	li $s1, 0xff0000	# $t1 stores the red colour code
	li $s2, 0x00ff00	# $t2 stores the green colour code
		
	
main_loop:
	lw $t0, displayAddressStart # temp vars so that we can paint entire bitmap
	lw $t1, displayAddressEnd
	
	jal repaint
	
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 32 # will let us know the end pointer in our array
	la $t2, personArray
	jal generate_character
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 12 # will let us know the end pointer in our array
	la $t2, stepsArray
	jal generate_steps
	
	
	j Exit
		
# need to intialize the background for the map 
repaint:
	sw $s1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t1 repaint

	jr $ra # will return to the current instruction in main

generate_character:
	#blip our character icon
	add $t3, $t2, $t0 # current pointer at A[i], Not the value
	lw $t4, 0($t3) # stores actualy value from the pointer
	sw $s2, 0($t4)
	addi $t0, $t0, 4
	bne $t0, $t1, generate_character
	jr $ra			
	
generate_steps:
	# Need to load in the load in the steps
	add $t3, $t2, $t0 # current pointer at A[i], Not the value
	lw $t4, 0($t3) # stores actualy value from the pointer
	
	# now we actually colour in the units
	sw $s2, 0($t4)
	sw $s2, 4($t4)
	sw $s2, 8($t4)
	sw $s2, 12($t4)
	sw $s2, 16($t4)
	sw $s2, 20($t4)
	sw $s2, 24($t4)
	
	addi $t0, $t0, 4
	bne $t0, $t1, generate_steps
	jr $ra
		
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
    	jr $ra
    	

    	 
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall