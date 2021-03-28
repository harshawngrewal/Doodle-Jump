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
		
	sleep_time:	.word 0
.text
	li $s1, 0x87ceeb	# $t1 stores the red colour code
	li $s2, 0xffffff	# $t2 stores the green colour code
		
	
main_loop:
	# we are only going to call this if our
	add $t0, $zero, 2
	sw $t0, sleep_time

	lw $t0, displayAddressStart # temp vars so that we can paint entire bitmap
	lw $t1, displayAddressEnd
	jal repaint
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 12 # will let us know the end pointer in our array
	la $t2, stepsArray # pointer to the array(we are loading in the address)
	jal generate_steps
	
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 32 # will let us know the end pointer in our array
	la $t2, personArray
	
	jal blip_character # we will not return to this function now until we NEED to repaint ENTIRE screen

	add $t0, $zero, 500
	sw $t0, sleep_time
	jal sleep
	j main_loop
	j Exit
	
# need to intialize the background for the map 
repaint:
	sw $s1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t1 repaint

	jr $ra  # will return to the current instruction in main

	
				
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
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	jal sleep
	
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	bne $t0, $t1, generate_steps
	jr $ra 

		
blip_character:

	#blip our character icon
	add $t3, $t2, $t0 # current pointer at A[i], Not the value
	lw $t4, 0($t3) # stores actualy value from the pointer. Value itself is an address
	sw $s2, 0($t4) # now this offset the address so that we can store something there 
	addi $t0, $t0, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	jal sleep
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	bne $t0, $t1, blip_character
	
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	jal erase_doodle
	
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	jal checkUserInput
	
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 32 # will let us know the end pointer in our array
	la $t2, personArray
	j blip_character
	
	jr $ra


erase_doodle:
	add $t3, $t2, $t0 # current pointer at A[i], Not the value
	lw $t4, 0($t3) # stores actualy value from the pointer. Value itself is an address
	sw $s1, 0($t4) # now this offset the address so that we can store something there 
	addi $t0, $t0, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	jal sleep
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	bne $t0, $t1, erase_doodle
	
	jr $ra

	
	
checkUserInput:
	# going to check for input
	li $t1, 97
	li $t2, 100
	
	lw $s3, keyboardEvent # load in the address
	lw $t0, 0($s3) # get's the value at the address
	
	beq $t0, $zero, return_to_caller
	
	# need to load in the personArray in case we shift it
	add $t3, $zero, $zero # Will act as pointer to our array
	addi $t4, $zero, 32 # will let us know the end pointer in our array
	la $t5, personArray

	lw $s4, keyClicked # loads in the address
	lw $t0, 0($s4) # gives us the ASCII value of the key pressed  
	beq $t0, $t1, shift_Left
	
	add $t3, $zero, $zero # need to set this back to zero in case we modified it in shift left
	beq $t0, $t2, shift_Right
	
	jr $ra # return back to parent

return_to_caller:
	jr $ra
	
	
shift_Left:
	
	# need to shift every single elememt in personArray by a certain amount of units 
	add $t6, $t5, $t3 # current pointer at A[i], Not the value
	lw $t7, 0($t6) # load address A[i]
	
	addi $t7, $t7 -4 # prob gonna have to handle  the case where the character cannot move right
	
	sw $t7, 0($t6) # update value in the array
	addi $t3, $t3, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	jal sleep
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	bne $t3, $t4, shift_Left
	
	sw $zero, 0($s3) # need to reset the value at the keyboadEvent address
	jr $ra		
	

shift_Right:
	
	# need to shift every single elememt in personArray by a certain amount of units 
	add $t6, $t5, $t3 # current pointer at A[i], Not the value
	lw $t7, 0($t6) # load address A[i]
	
	addi $t7, $t7 4 # prob gonna have to handle  the case where the character cannot move right
	
	sw $t7, 0($t6) # update value in the array
	addi $t3, $t3, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	jal sleep
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	bne $t3, $t4, shift_Right
	
	sw $zero, 0($s3) # need to reset the value at the keyboadEvent address
	jr $ra	
			
 
 sleep:
 	# sleep to control the animations
 	li $v0, 32 # the sleep syscall
 	lw $a0, sleep_time
 	syscall
 	jr $ra
 	
 		 	 
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
	


