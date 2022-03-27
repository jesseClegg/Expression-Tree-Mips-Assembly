
	.data
input:	.space	256
outputExpression: .space 256
pushingToStack: .asciiz " getting pushed to stack \n"
poppingFromStack: .asciiz " is popped from stack \n"
peakingFromStack: .asciiz " peeking from stack \n"
stackIsEmptyMessage: .asciiz " stack is empty"
stickIsNotEmpty: .asciiz " stack is NOT empty"
beingAppended: .asciiz " is being appended "
newline: .asciiz "\n"
firstPrompt: .asciiz "enter an expression: \n"
isThree: .asciiz "its a three!!!   "
isOperator: .asciiz " is an operator"
isPlusOperator: .asciiz " found a +"
isMinusOperator: .asciiz " found a -"
isOpenParen: .asciiz " found (\n"
isClosedParen: .asciiz " found )\n"
isNumberMessage: .asciiz " is a number"
isNotThree: .asciiz "NOT THREE\n"
sizeOf: .asciiz "expression has size of : "
plusSign: .byte '+'
minusSign: .byte '-'
emptyStackSentinel: .word 'E'
finishLine: .asciiz "finish line woo!\n"
	.text
	.globl main
main:
	#clear some registers
	#will use $s0 as an index for appending to string
	addi $s0, $zero, 0
	add $t1, $zero, 0
	addi $t8, $zero, 0
	
	#put our sentinel onto the stack for isEmpty()
	lw $t1, emptyStackSentinel($zero)
	addi $a0, $zero, 0
	move $a0, $t1
	jal stackPush
	
	#print newline
	li	$v0, 4			
	la	$a0, newline 
	syscall		
	
	#output the initial prompt
	li	$v0, 4			
	la	$a0, firstPrompt
	syscall
	
	#read in expression, stored into input, max size=  256 chars/bytes
	li	$v0, 8			 
	la	$a0, input		
	li	$a1, 256		
	syscall
	
	#keep track of start of input string
	la $t2, input
	
	
parseExpression:
	#clear some registers
	li	$t0, 0			
	li	$t3, 0			
	li 	$t6, 0			
	li	$t5, 13
	
	#checking if 13 is ascii for newline
	li	$v0, 11			
	move	$a0, $t5		
	syscall
	
	parserLoop:
		# $t3 is i=0
		add	$t3, $t2, $t0		# $t2 is the base address for our 'input' array, add loop index
		lb	$t4, 0($t3)		# load a byte at a time according to counter								
		beqz	$t4, exit		# We found the end of the expression (null-byte)
		
		#just prints each character for right now $t4
		li $v0, 11
		move $a0, $t4
		syscall	
		
		beq $t4, '+' isPlusOrMinus
		beq $t4, '-' isPlusOrMinus
		beq $t4, '(' openParen
		beq $t4, ')' closedParen
		beq $t4, $t5 loopWork
		beq $t4, '0' isNumber
		beq $t4, '1' isNumber
		beq $t4, '2' isNumber
		beq $t4, '3' isNumber
		beq $t4, '4' isNumber
		beq $t4, '5' isNumber
		beq $t4, '6' isNumber
		beq $t4, '7' isNumber
		beq $t4, '8' isNumber
		beq $t4, '9' isNumber
		j loopWork 
		
		isNumber:
			li	$v0, 4			
			la	$a0, isNumberMessage
			syscall	  
			li	$v0, 4			
			la	$a0, newline 
			syscall	    
			
			#append to post fix
			addi $a0, $zero, 0
			addi $a0, $t4, 0
			sb $t4, outputExpression($s0)
			addi $s0, $s0, 1
	
			j loopWork    
		    
		   
		isPlusOrMinus:
			    
		      	li	$v0, 4			
			la	$a0, isOperator
			syscall	
			li	$v0, 4			
			la	$a0, newline 
			syscall	
			
			addi $s3, $zero, 0
			
			jal stackIsEmpty
			move $s3, $v0
			
			li	$v0, 11			# Print
			move	$a0, $s3		# the string!
			syscall
			
			beq $s3, 1 wasEmpty
				#pop from stack and append to postfix
				jal stackPop
				addi $a0, $zero, 0
				addi $a0, $v0, 0
				sb $a0, outputExpression($s0)
				addi $s0, $s0, 1
				 
				#j loopWork
				j isPlusOrMinus
			wasEmpty:
				#put onto the stack if stack is empty!!
				addi $a0, $zero, 0
				move $a0, $t4
				jal stackPush
			
				j loopWork
		 
		openParen:
		 	li	$v0, 4			
			la	$a0, isOpenParen
			syscall	
			
			
			#push onto the stack
			addi $a0, $zero, 0
			move $a0, $t4
			jal stackPush
			
			j loopWork
		 	
		 closedParen:
		 	
			li	$v0, 4			
			la	$a0, isClosedParen 
			syscall	
			li	$v0, 4			
			la	$a0, newline 
			syscall	
			
			parenLoop:	
				#pop everything from stack until a closed parenthesis
				#need to make a loop here
				addi $t6, $zero, 0
				jal stackPeek
				move $t6, $v0
				
				beq $t6, '(' matchingParen
				addi $t8, $zero, 0
			
				#should have whats popped from stack now
				jal stackPop
				move $t8, $v0
			
				#append to post fix
				addi $a0, $zero, 0
				addi $a0, $t8, 0
				sb $t8, outputExpression($s0)
				addi $s0, $s0, 1
				
				j parenLoop
			matchingParen:
				#pop it to get rid of the '('
				jal stackPop
			
				li	$v0, 4			
				la	$a0, newline 
				syscall	
			 
				li $v0, 11
				move $a0, $t8
				syscall	
				
				j loopWork
		
		
	loopWork:
		li	$v0, 4			
		la	$a0, newline 
		syscall
		
		li, $v0, 4
		la $a0, outputExpression
		syscall
		
		li	$v0, 4			
		la	$a0, newline 
		syscall
		
		addi	$t0, $t0, 1		# Advance our counter (i++)
		j	parserLoop		# Loop until we reach our condition
	


exit:
	#RENEMBER TO EMPTY THE STACK HERE!
	emptyTheStack:
		
		li	$v0, 4			
		la	$a0, isThree		
		syscall
		
		addi $s3, $zero, 0
		jal stackIsEmpty
		move $s3, $v0	
		
		beq $s3, 1 stackIsEmptied		
		
		jal stackPop
		addi $t9, $zero, 0
		addi $t9, $v0, 0
		
		li	$v0, 11			
		move	$a0, $t9 
		syscall
		
		li	$v0, 4			
		la	$a0, newline 
		syscall
		
		sb $t9, outputExpression($s0)
		addi $s0, $s0, 1
		j emptyTheStack		 


	stackIsEmptied:
	
		li	$v0, 4			
		la	$a0, newline 
		syscall	
		
		li	$v0, 4			
		la	$a0, finishLine		
		syscall

		li, $v0, 4
		la $a0, outputExpression
		syscall
	
		li	$v0, 4			
		la	$a0, newline 
		syscall	
	
		addi $t9, $zero, 0
		addi $t9, $zero, 7
		sb $t9, outputExpression($s0)
		addi $s0, $s0, 1
		
		li, $v0, 4
		la $a0, outputExpression
		syscall
	
		li	$v0, 10			# exit()
		syscall
	
stackPush:
	addi $sp, $sp, -4
	sw $a0, 0($sp) #push to stack
	
	move $t8, $a0
	li	$v0, 4			
	la	$a0, newline 
	syscall	
	
	li $v0, 11
	move $a0, $t8
	syscall
	
	li	$v0, 4			
	la	$a0, pushingToStack 
	syscall	
	
	jr $ra
	
stackPop:
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	addi $sp, $sp, 4
	
	li $v0, 11
	move $a0, $t9
	syscall
	
	li	$v0, 4			
	la	$a0, poppingFromStack 
	syscall
	
	#remember to return it in $v0 for use in main
	move $v0, $t9
	jr $ra
	
stackPeek:
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	
	li $v0, 11
	move $a0, $t9
	syscall
	
	li	$v0, 4			
	la	$a0, peakingFromStack  
	syscall
	
	move $v0, $t9
	jr $ra
	
stackIsEmpty:
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	
	addi $t8, $zero, 0
	lw $t8, emptyStackSentinel($zero)
	beq $t9, $t8 empty
	
	addi $v0, $zero, 0
	jr $ra
	empty:
	 addi $v0, $zero, 1
	 jr $ra
	 
appendToExpression:
	addi $t9, $zero, 0
	move $t9, $a0
	sw $t9, outputExpression($s0)
	
	li $v0, 11
	move $a0, $t9
	syscall	
	li	$v0, 4			
	la	$a0, beingAppended 
	syscall		
	
	#increment the index we are at for main	
	addi $s0, $s0, 1
	jr $ra

		