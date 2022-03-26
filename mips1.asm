.data
	userInput: .space 10 #number of characters to accept is 10
	firstPrompt: .asciiz "enter an expression..."
	newline: .asciiz "\n"
	uEntered: .asciiz "you entered= \n"
	testExpression: .asciiz "(1-(3+5))\n"
	finishLine: .asciiz "\nfinish line!!!\n"
	
.text

.globl main

	main: 
		#li $v0, 4
		#la $a0, firstPrompt
		#syscall
		
		#scan user input 
		#li $v0, 8 #8 for a string
		#la $a0, userInput #input will be stored to the address of userInput
		#li $a1, 10 #tell the system how many characters we are going to store
		#syscall 
		
		#print "ypu entered..."
		#li $v0, 4
		#la $a0, uEntered
		#syscall
		
		
		
		
		#print the actual string
		li $v0, 4 
		la $a0, testExpression
		syscall
		
		#print newline
		li $v0, 4
		la $a0, newline
		syscall
		
		#int i=0
		addi $t0, $zero, 0
	
		#$t1=array.length	
		addi $t1, $zero, 9			
		sll $t1, $t1, 2 #multiply by 4
	
		#successfully loop 9 times
		Loop:
			beq $t0, $t1, breakLoop
			addi, $t0, $t0, 4
			
			#print the actual string
			li $v0, 4 
			la $a0, testExpression
			syscall

			lw $t4, testExpression($t0)
			addi $a0, $t4, $zero

			li $v0, 1
			syscall



		j Loop

	breakLoop:
			



	#print finish line
	li $v0, 4 
	la $a0, finishLine
	syscall
		
	end:
	# code for exit
	li $v0, 10 
	syscall	
	
				
	

