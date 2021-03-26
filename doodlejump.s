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
	
	# this hold the addresses that keep information of keyboard events
	keyboardEvent:	.word 0xffff0000
	keyClicked:	.word 0xffff0004	
	
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
	
	jal checkUserInput
	
	j Exit
	
		
checkUserInput:
	# going to check for input
	li $t1, 97
	li $t2, 98
	
	lw $t0, keyboardEvent
	lw $t0, 0($t0) # get's the value at the address
	beq $t0, $zero, checkUserInput # no input so we keep checking
	
	lw $t0, keyClicked
	lw $t0, 0($t0) # gives us the ASCII value of the key pressed  
	beq $t0, $t1, return
	beq $t0, $t2, return
	j checkUserInput

return:
	jr $ra
	
		
# need to intialize the background for the map 
repaint:
	sw $s1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t1 repaint

	jr $ra # will return to the current instruction in main

generate_character:
	#blip our character icon
	add $t3, $t2, $t0 # current pointer at A[i], Not the value
	lw $t4, 0($t3) # stores actualy value from the pointer. Value itself is an address
	sw $s2, 0($t4) # now this offset the address so that we can store something there 
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
		
    	jr $ra
    	
    	 
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
	

