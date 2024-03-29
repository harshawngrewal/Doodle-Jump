# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
# - 32 units per row = 128 bytes

.data
	digit_1:  .word 0x10008070
	
		   
	digit_2: .word 0x10008060
	
	digit_3:.word 0x10008050
	
	score: .word 0 # will keep track of score and then display it
	
	
	instrument: .word 7
	iteration:  .word 0
	
	# the following is the music cords for twinkle twinkle little star
	twinkle_little_star: .word  72, 72, 67, 67, 69, 69, 67, 
				    65, 65, 64, 64, 62, 62, 72, 
				    67, 67, 65, 65, 64, 64, 62,
				    67, 67, 65, 65, 64, 64, 62
				    72, 72, 67, 67, 69, 69, 67, 
				    65, 65, 64, 64, 62, 62, 72
				    0, 0, 0 
	current_note_index: .word 0
	duration: .word 700
	volume: .word 50
	
	#  this is the sound effect for hitting a platform. Total 42 notes, index 0-41
	beep: .word 72
	instrument2: .word 38
	volume2: .word 100
	

	displayAddressStart:	.word	0x10008000 # 268468224 in decimal
	displayAddressEnd: 	.word   0x10009000 # the end of display
	
	highest_doodle_position: .word	0x10008280 # 268468224 in decimal
	lowest_doodle_position:  .word  0x10009000
	
	# note that each step will take up 4 units = 16 bytes since each unit is 4 bytes 
	stepsArray:	.word   0x10008500, 0x10008A20,  0x10008F40,
	ground:		.word 0x10008FC0 # the floor
	
	# this will hold the contents of the character in our game
	personArray: 	.word 0x10008E44, 0x10008DC4, 0x10008DC8, 0x10008D48, 0x10008DCC, 0x10008E4C
	
	# this hold the addresses that keep information of keyboard events
	keyboardEvent:	.word 0xffff0000
	keyClicked:	.word 0xffff0004
		
	sleep_time:	.word 0
	
	shift_direction:	.word 0 # zero means we are shifting up and 1 means we should shift down 
	
	jump_start_location:	.word 0x10008F40
	max_jump_height:	.word 0xA00 #storing the max jump height in hexadecimal
	
	# 
	letter_b:	.word  0x10008720, 0x100087A0, 0x10008820, 0x100088A0, 0x10008920, 0x100089A0, 0x100089A4, 0x100089A8, 0x10008928, 0x100088A8, 0x100088A4, 
	letter_y:	.word  0x100088B0, 0x10008930, 0x100089B0 0x100089B4, 0x100089B8, 0x10008938, 0x100088B8, 0x10008A38, 0x10008AB8, 0x10008AB4, 0x10008AB0,
	letter_e:	.word  0x10008940, 0x10008944,  0x10008948, 0x1000894C,  0x100088C0, 0x10008840,  0x10008844,  0x10008848,  0x1000884C,  0x100087C0, 0x10008740,  0x10008744,  0x10008748,  0x1000874C

	shift_platforms_bool:	.word 0 			 
.text 
	li $s1, 0x87ceeb	# $s1 stores the blue colour code
	li $s2, 0xffffff	# $s2 stores the white colour code
	li $s4 	0xff0000	# $s4 stores the white colour code
		
	
main:
	
	# This part is just for the intial set up of our screen
	# Set the sleep time(keep it low)
	add $t0, $zero, 70
	sw $t0, sleep_time

	lw $t0, displayAddressStart # temp vars so that we can paint entire bitmap
	lw $t1, displayAddressEnd
	jal paint_background
	
	jal display_score
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 12 # Will let us know the end pointer in our array
	la $t2, stepsArray # pointer to the platform array(we are loading in the address)
	jal generate_steps
	
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 24 # Will let us know the end pointer in our array
	la $t2, personArray
	 
	j game_loop

	
# Need to intialize the background for the map 
paint_background:
	sw $s1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t1 paint_background

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
	bne $t0, $t1, generate_steps
	jr $ra 

		
game_loop:
	# Draw the doodle
	jal erase_doodle
	add $t0, $zero, $zero
	jal update_doodle_position_user 
	jal update_doodle_position_auto # Up down auto movement
	jal check_hit_ground  # will check if the doodle has hit the ground in which case the doodle loss
	jal check_collision # Will check collision of doodle with platforms 
	jal check_height # if the doodle is over a certain height from where it jumped we switch directions
	
	
	jal set_shift_platforms_bool
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 12 # Will let us know the end pointer in our array
	la $t2, stepsArray # pointer to the platform array(we are loading in the address)
 	jal erase_platforms # need to do  this 
	# we set this because the next function will use these vars
 	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 12 # Will let us know the end pointer in our array
	la $t2, stepsArray # pointer to the platform array(we are loading in the address)
	jal shift_platforms # will shift platforms if shift_platforms var is 0
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 12 # Will let us know the end pointer in our array
	la $t2, stepsArray # pointer to the platform array(we are loading in the address)
	jal generate_steps
	
	jal play_music # Responsible for playing the appropriate note for twinkle twinkle little star
	lw $t0, iteration
	addi $t0, $t0 1
	sw $t0, iteration # Update this value
	
	add $t0, $zero, $zero # Will act as pointer to our array
	addi $t1, $zero, 24 # Will let us know the end pointer in our array
	la $t2, personArray
	
	jal blip_doodle
	
	add $t0, $zero, $zero 
	
	
	jal sleep
	j game_loop
	


display_score:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	lw $a1, score
	
	jal blip_first_digit
	jal blip_second_digit
	jal blip_third_digit
	
	
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	jr $ra


blip_first_digit:
	li $t0, 10
	div $a1, $t0
	mfhi $t0 # this will be the digit we want to blip
	mflo $a1 # update this 
	
	la $a2, digit_1

	
	beq $t0  0, blip_zero
	beq $t0, 1, blip_one
	beq $t0, 2, blip_two
	beq $t0, 3, blip_three
	beq $t0, 4, blip_four
	beq $t0, 5, blip_five
	beq $t0, 6, blip_six
	beq $t0, 7, blip_seven
	beq $t0, 8, blip_eight
	beq $t0, 9, blip_nine
	
	
	jr $ra

blip_second_digit:
	li $t0, 10
	div $a1, $t0
	mfhi $t0 # this will be the digit we want to blip
	mflo $a1 # update this 
	
	la $a2, digit_2
	
	lw $t1, score
	li $t2, 9
	ble $t1, $t2 blip_clear

	
	
	beq $t0  0, blip_zero
	beq $t0, 1, blip_one
	beq $t0, 2, blip_two
	beq $t0, 3, blip_three
	beq $t0, 4, blip_four
	beq $t0, 5, blip_five
	beq $t0, 6, blip_six
	beq $t0, 7, blip_seven
	beq $t0, 8, blip_eight
	beq $t0, 9, blip_nine
	
	
	jr $ra

blip_third_digit:
	li $t0, 10
	div $a1, $t0
	mfhi $t0 # this will be the digit we want to blip
	mflo $a1 # update this 
	
	la $a2, digit_3
	
	lw $t1, score
	li $t2, 99
	ble $t1, $t2 blip_clear
	
	beq $t0  0, blip_zero
	beq $t0, 1, blip_one
	beq $t0, 2, blip_two
	beq $t0, 3, blip_three
	beq $t0, 4, blip_four
	beq $t0, 5, blip_five
	beq $t0, 6, blip_six
	beq $t0, 7, blip_seven
	beq $t0, 8, blip_eight
	beq $t0, 9, blip_nine
	
	jr $ra
	
blip_clear:
	lw $t0, 0($a2)
	
	sw $s1, 0($t0)
	sw $s1, 128($t0)
	sw $s1, 256($t0)
	sw $s1, 384($t0)
	sw $s1, 512($t0) 
	sw $s1, 516($t0) 
	
	sw $s1, 4($t0)
	
	sw $s1, 8($t0)
	sw $s1, 136($t0)
	sw $s1, 260($t0)
	sw $s1, 264($t0)
	sw $s1, 392($t0)
	sw $s1, 520($t0)
	
	jr $ra

	
blip_zero:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s4, 128($t0)
	sw $s4, 256($t0)
	sw $s4, 384($t0)
	sw $s4, 512($t0) 
	sw $s4, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s4, 136($t0)
	sw $s1, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra

	
blip_one:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s4, 128($t0)
	sw $s4, 256($t0)
	sw $s4, 384($t0)
	sw $s4, 512($t0) 
	sw $s1, 516($t0) 
	
	sw $s1, 4($t0)
	
	sw $s1, 8($t0)
	sw $s1, 136($t0)
	sw $s1, 260($t0)
	sw $s1, 264($t0)
	sw $s1, 392($t0)
	sw $s1, 520($t0)
	
	jr $ra
	
blip_two:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s1, 128($t0)
	sw $s4, 256($t0)
	sw $s4, 384($t0)
	sw $s4, 512($t0) 
	sw $s4, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s4, 136($t0)
	sw $s4, 260($t0)
	sw $s4, 264($t0)
	sw $s1, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
	
	
blip_three:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s1, 128($t0)
	sw $s4, 256($t0)
	sw $s1, 384($t0)
	sw $s4, 512($t0) 
	sw $s4, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s4, 136($t0)
	sw $s4, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
	
	
blip_four:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s4, 128($t0)
	sw $s4, 256($t0)
	sw $s1, 384($t0)
	sw $s1, 512($t0) 
	sw $s1, 516($t0) 
	
	sw $s1, 4($t0)
	
	sw $s4, 8($t0)
	sw $s4, 136($t0)
	sw $s4, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
	
	
blip_five:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s4, 128($t0)
	sw $s4, 256($t0)
	sw $s1, 384($t0)
	sw $s4, 512($t0) 
	sw $s4, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s1, 136($t0)
	sw $s4, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
	
blip_six:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s4, 128($t0)
	sw $s4, 256($t0)
	sw $s4, 384($t0)
	sw $s4, 512($t0) 
	sw $s4, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s1, 136($t0)
	sw $s4, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
blip_seven:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s1, 128($t0)
	sw $s1, 256($t0)
	sw $s1, 384($t0)
	sw $s1, 512($t0) 
	sw $s1, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s4, 136($t0)
	sw $s1, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
	
	
blip_eight:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s4, 128($t0)
	sw $s4, 256($t0)
	sw $s4, 384($t0)
	sw $s4, 512($t0) 
	sw $s4, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s4, 136($t0)
	sw $s4, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
	
blip_nine:
	lw $t0, 0($a2)
	
	sw $s4, 0($t0)
	sw $s4, 128($t0)
	sw $s4, 256($t0)
	sw $s1, 384($t0)
	sw $s4, 512($t0) 
	sw $s4, 516($t0) 
	
	sw $s4, 4($t0)
	
	sw $s4, 8($t0)
	sw $s4, 136($t0)
	sw $s4, 260($t0)
	sw $s4, 264($t0)
	sw $s4, 392($t0)
	sw $s4, 520($t0)
	
	jr $ra
	

play_music:
	lw $t0, iteration
	addi $t2 $zero 10
	div $t0 $t2
	mfhi $t1
	bne $t1 $zero return_to_caller
	
	lw $t0, current_note_index
	la $t1, twinkle_little_star
	add $t1, $t1, $t0 # the address current note
	lw $t0, 0($t1) # the actual note
	
	li $v0, 31
	add $a0, $zero, $t0 
	lw $a1, duration
	lw $a2, instrument
	lw $a3, volume
	syscall
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
 	jal update_curr_note_index
 	
 	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	jr $ra
	
update_curr_note_index:

	lw $t0, current_note_index
	addi $t0, $t0 4
	sw $t0, current_note_index
	addi $t1, $zero 164
	ble $t0, $t1 return_to_caller
	
	addi $t1, $zero 176
	ble $t0, $t1 mute_volume  # mean we are in the final 2 notes
	
	# index is out of bounds, reset to 0
	sw $zero, current_note_index
	addi $t0, $zero 127 
	sw $t0, volume # reset volume as we had it on mute for a couple of notes
	jr $ra


mute_volume:
	sw $zero, volume
	jr $ra
	

erase_doodle:
	lw $t3, 0($t2) 
	sw $s1, 0($t3)
	lw $t3, 4($t2) 
	sw $s1, 0($t3)
	lw $t3, 8($t2) 
	sw $s1, 0($t3)
	lw $t3, 12($t2) 
	sw $s1, 0($t3)
	lw $t3, 16($t2) 
	sw $s1, 0($t3)
	lw $t3, 20($t2) 
	sw $s1, 0($t3)
	jr $ra


blip_doodle:
	lw $t3, 0($t2) 
	sw $s2, 0($t3)
	lw $t3, 4($t2) 
	sw $s2, 0($t3)
	lw $t3, 8($t2) 
	sw $s2, 0($t3)
	lw $t3, 12($t2) 
	sw $s2, 0($t3)
	lw $t3, 16($t2) 
	sw $s2, 0($t3)
	lw $t3, 20($t2) 
	sw $s2, 0($t3)
	
	jr $ra

	
update_doodle_position_user:	
	# going to check for input
	li $t1, 106
	li $t2, 107

	lw $s3, keyboardEvent # load in the address
	lw $t0, 0($s3) # get's the value at the address
	
	beq $t0, $zero, return_to_caller
	
	# need to load in the personArray in case we shift it
	add $t3, $zero, $zero # Will act as pointer to our array
	addi $t4, $zero, 24 # will let us know the end pointer in our array
	la $t5, personArray
	
	lw $s4, keyClicked # loads in the address
	lw $t0, 0($s4) # gives us the ASCII value of the key pressed  
	

	beq $t0, $t1, shift_Left
	beq $t0, $t2, shift_Right
	
	jr $ra # return back to the game loop
	
	

update_doodle_position_auto:
	lw $t0, shift_platforms_bool
	bne $t0, $zero, return_to_caller
	
	add $t3, $zero, $zero # Will act as pointer to our array
	addi $t4, $zero, 24 # will let us know the end pointer in our array
	la $t5, personArray 
	lw $t0, shift_direction
	
	add $t3, $zero, $zero 
	beq $zero, $t0 shift_up_auto # if the shift direction is 0 then we should shift up
	j shift_down_auto # if we don't shift up that means we should shift down


	
shift_Left:
	# need to shift every single elememt in personArray by a certain amount of units 
	add $t6, $t5, $t3 # current pointer at A[i], Not the value
	lw $t7, 0($t6) # load address A[i]
	addi $t7, $t7 -4
	sw $t7, 0($t6) # update value in the array
	addi $t3, $t3, 4

	bne $t3, $t4, shift_Left
	sw $zero, 0($s3) # need to reset the value at the keyboadEvent address
	
	jr $ra		
	

shift_Right:
	# Need to shift every single elememt in personArray by a certain amount of units 
	add $t6, $t5, $t3 # current pointer at A[i], Not the value
	lw $t7, 0($t6) # load address A[i]
	addi $t7, $t7 4 
	sw $t7, 0($t6) # update value in the array
	addi $t3, $t3, 4
	
	bne $t3, $t4, shift_Right
	
	sw $zero, 0($s3) # need to reset the value at the keyboadEvent address
	jr $ra	


shift_up_auto:
	# Need to shift every single elememt in personArray by a certain amount of units 
	add $t6, $t5, $t3 # current pointer at A[i], Not the value
	lw $t7, 0($t6) # load address A[i]
	addi $t7, $t7 -128
	sw $t7, 0($t6) # update value in the array
	addi $t3, $t3, 4
	bne $t3, $t4, shift_up_auto
	
	sw $zero, 0($s3) # need to reset the value at the keyboadEvent address
	
	# we also may need to flip the value of the shift_direction
	lw $t0, highest_doodle_position
	lw $t1, 16($t5) # will load the the A[5] which is the position of the head 
	ble $t1, $t0, set_direction_to_1
	
	jr $ra				

shift_down_auto:
	# Need to shift every single elememt in personArray by a certain amount of units 
	add $t6, $t5, $t3 # current pointer at A[i], Not the value
	lw $t7, 0($t6) # load address A[i]
	addi $t7, $t7 128
	sw $t7, 0($t6) # update value in the array
	addi $t3, $t3, 4
	bne $t3, $t4, shift_down_auto
	
	sw $zero, 0($s3) # need to reset the value at the keyboadEvent address
	
	# we also may need to flip the value of the shift_direction
	lw $t0, lowest_doodle_position
	lw $t1, 16($t5) # will load the the A[5] which is the position of the head 
	bge $t1, $t0, set_direction_to_0
	
	jr $ra	
	

set_direction_to_1:
	addi $t0, $zero, 1 
	sw $t0, shift_direction # now this means next time we will shift down
	jr $ra # jump back to the game loop
	
	

set_direction_to_0:
	sw $zero, shift_direction # now this means next time we will shift up
	
	# is in between the platform
	li $v0,31
	lw $a0,beep
	lw $a1,duration
	lw $a2, instrument2
	lw $a3, volume2

	syscall
	jr $ra # jump back to the game loop
	

check_collision:
	lw $t0 shift_direction
	beq $t0, $zero, return_to_caller # we don't check for collisions unless doodle is moving down
	# maybe we should still check as we may need to repaint the platforms in the case of any collision

	la $t0, personArray
	la $t1, stepsArray # Pointer to the platform array(we are loading in the address)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	
	lw $t2, 0($t1) # stepsArray[0]
	jal check_collision_left_leg # will check collision with current platform
	jal check_collision_right_leg
	
	lw $t2, 4($t1) # stepsArray[1]
	jal check_collision_left_leg
	jal check_collision_right_leg
	
	lw $t2, 8($t1) # stepsArray[2]
	jal check_collision_left_leg
	jal check_collision_right_leg
	
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	jr $ra
	

check_collision_left_leg:
	# if there is a collision we set the shift_direction to 0
	lw $t3, 0($t0) # left leg
	addi $t4, $zero 24 # the difference in bytes between the start of platform and the end of it
	
	sub $t5, $t3 $t2 # the difference in bytes between the left leg and the start of platform
	bgt $t5, $t4  return_to_caller
	blt $t5, $zero, return_to_caller
	sw $t2, jump_start_location
	
	# Is in between the platform
	j set_direction_to_0 # causes the doodle to bounce off the platform


check_collision_right_leg:
	# if there is a collision we set the shift_direction to 0
	lw $t3, 20($t0) # right leg
	addi $t4, $zero 24 # the difference in bytes between the start of platform and the end of it
	
	sub $t5, $t3 $t2 # the difference in bytes between the left leg and the start of platform
	bgt $t5, $t4  return_to_caller
	blt $t5, $zero, return_to_caller
	sw $t2, jump_start_location
	
	j set_direction_to_0 # causes the doodle to bounce off the platform

	
check_height:
 	lw $t0, jump_start_location # this will always be one of the platforms
 	la $t1, personArray
 	lw $t1, 12($t1) # this is the head of the character
 	lw $t2, max_jump_height
 	
 	sub $t3, $t0 $t1 # the difference in height
 	bge $t3 $t2 set_direction_to_1
 	
 	jr $ra
 	
		
check_hit_ground:
	la $t0, personArray
	lw $t1, 0($t0) # left leg
	lw $t2, displayAddressStart
	sub $t3, $t1 $t2 # will give the difference in bytes
	
	addi $t4, $zero 128
	div $t3, $t3 $t4
	addi $t5, $zero 32
	
	beq $t3, $t5 Exit
	jr $ra


# if the doodle height is over the third platform, we set shift_platforms which freezes the vertical movement of the doodle
set_shift_platforms_bool:
	lw $t0, shift_direction
	bne $t0, $zero, return_to_caller # if doodle is moving down then do nothing

	lw $t0, shift_platforms_bool
	bne $t0, $zero set_shift_platforms_bool_0 # since we don't want to set it if it's already set

	la $t0, personArray
 	lw $t0, 12($t0) # this is head of the doodle
 	la $t1, stepsArray
 	lw $t1, 0($t1)
 	
 	sub $t2, $t1 $t0 # the difference in height between the head of the doodle and the top platform 
 	addi $t1, $zero 128
 	blt $t2 $t1 return_to_caller
 	
 	li $t2, 1
 	sw $t2, shift_platforms_bool # 1 means that we should shift platforms down
 	
 	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
 	jal modify_stepsArray # will remove last element, shift other two and add a new element in the 0th index
 	
 	lw $t0, score
 	addi $t0, $t0, 1 # plus 1 to the score
 	sw $t0, score # have to increment the score
 	
 	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	jr $ra 

# here we check if the shift is complete in which case we set shift_platforms back to 0
set_shift_platforms_bool_0:
	la $t0, stepsArray
 	lw $t0, 8($t0) # the bottomost platform
 	
 	lw $t1, displayAddressEnd
 	addi $t1, $t1, -256
 	
 	blt $t0, $t1, return_to_caller
 	li $t2, 0
 	sw $t2, shift_platforms_bool # 1 means that we should shift platforms down
 	
 	li $t2, 1
 	sw $t2, shift_direction # we want doodle to move down now
 	
 	jr $ra
 		
 		
 modify_stepsArray:
 	la $t0 stepsArray
 	lw $t1, 0($t0)
 	lw $t2, 4($t0)
 	lw $t3, 8($t0)
 	
 	# Want to erase the bottom platform
 	sw $s1, 0($t3)
	sw $s1, 4($t3)
	sw $s1, 8($t3)
	sw $s1, 12($t3)
	sw $s1, 16($t3)
	sw $s1, 20($t3)
	sw $s1, 24($t3)
	
	# new values for the second and  third  platforms
 	sw $t1, 4($t0)
 	sw $t2, 8($t0)
 	
 	
 	# Need to generate a new step location for the top step
 	li $v0, 42 # the random int generator
 	li $t3, 26
 	li $a0, 0  
 	add $a1, $t3, $zero
 	syscall # now a0 will contain a random value form 0-26
 	
 	li $t4, 4
 	mult $a0, $t4
 	mflo $t4
 	
 	lw $t3, displayAddressStart
 	add $t4, $t3, $t4
 	sw $t4, 0($t0) # generate new platform
 	
 	jr $ra


erase_platforms:
	lw $t5, shift_platforms_bool
	beq $t5, $zero return_to_caller # no need to erase as we are not in that state
	# Need to load in the load in the steps
	add $t3, $t2, $t0 # current pointer at A[i], Not the value
	lw $t4, 0($t3) # stores actualy value from the pointer
	
	# now we actually colour in the units
	sw $s1, 0($t4)
	sw $s1, 4($t4)
	sw $s1, 8($t4)
	sw $s1, 12($t4)
	sw $s1, 16($t4)
	sw $s1, 20($t4)
	sw $s1, 24($t4)

	addi $t0, $t0, 4
	bne $t0, $t1, erase_platforms
	jr $ra

 		
 	
			
shift_platforms:
	lw $t3  shift_platforms_bool
	beq $t3, $zero, return_to_caller # we are not suppose to shift in this case
	
	add $t4, $t2, $t0 # current pointer at A[i], Not the value
	lw $t5, 0($t4) # load address A[i]
	addi $t5, $t5 128
	sw $t5, 0($t4) # update value in the array
	
	addi $t0, $t0, 4
	bne $t1, $t0, shift_platforms
	
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
	jal display_score # this is the only time we update the score display
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	
	
	jr $ra # done shifting once
		
game_over:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # need to keep the previous parent pointer
 	
	add $a0, $zero, $zero
	la $a1, letter_b
	addi $a3, $zero 44
	jal blip_char
	jal sleep
	
	add $a0, $zero, $zero
	la $a1, letter_y
	addi $a3, $zero 44
	jal blip_char
	jal sleep
	
	add $a0, $zero, $zero
	la $a1, letter_e
	addi $a3, $zero 56
	jal blip_char
	jal sleep
	
	lw $ra, 0($sp) # restore the previous parent pointer
	addi $sp, $sp, 4
	jr $ra
	

blip_char:
	add $t3, $a1, $a0 # current pointer at A[i], Not the value
	lw $t4, 0($t3) # stores actualy value from the pointer
	
	# now we actually colour in the units
	sw $s4, 0($t4)

	addi $a0, $a0, 4
	bne $a0, $a3, blip_char
	jr $ra 
	
	
	
return_to_caller:
	jr $ra

 	
sleep:
	# sleep to control the animations
 	li $v0, 32 # the sleep syscall
 	lw $a0, sleep_time
 	syscall
 	jr $ra
 	
	 	 
Exit:	
	lw $t0, displayAddressStart # temp vars so that we can paint entire bitmap
	lw $t1, displayAddressEnd
	jal game_over
	
	li $v0, 10 # terminate the program gracefully
	syscall	
	
	