# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	displayAddress:	.word	0x10008000
.text
	lw $t0, displayAddress	# $t0 stores the base address for display
	li $t1, 0xff0000	# $t1 stores the red colour code
	li $t2, 0x00ff00	# $t2 stores the green colour code
	li $t3, 0x0000ff	# $t3 stores the blue colour code
	
	add $t4, $0, $t0 
	addi $t5, $t0 4096  # we need to store this because it is our end of while loop condition
	

# need to intialize the background for the map 
loop:
	beq, $t4, $t5, Exit
	sw $t1, 0($t4)
	addi $t4, $t4, 4
	j loop


main:

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall