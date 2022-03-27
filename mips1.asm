#
# reverse.asm
# I'll probably improve on this over the semester,
# as it was hacked up in about an hour.
#
# 	**** user input : The quick brown fox jumped over the lazy cat.
# 	The quick brown fox jumped over the lazy cat.
# 	45
# 	.tac yzal eht revo depmuj xof nworb kciuq ehT
# 	-- program is finished running --
#
	.data
input:	.space	256
outputExpression: .space 256
pushingToStack: .asciiz " getting pushed to stack \n"
poppingFromStack: .asciiz " is popped from stack \n"
peakingFromStack: .asciiz " peeking from stack \n"
newline: .asciiz "\n"
firstPrompt: .asciiz "enter an expression: \n"
isThree: .asciiz "its a three\n!!! "
isOperator: .asciiz " is an operator"
isPlusOperator: .asciiz " found a +"
isMinusOperator: .asciiz " found a -"
isOpenParen: .asciiz " found ("
isClosedParen: .asciiz " found )"
isNumber: .asciiz " is a number"
isNotThree: .asciiz "NOT THREE\n"
sizeOf: .asciiz "expression has size of : "
plusSign: .byte '+'
minusSign: .byte '-'

	.text
	.globl main
main:
	
	
	li	$v0, 4			# output the initial prompt
	la	$a0, firstPrompt
	syscall
	
	li	$v0, 8			# read in expression
	la	$a0, input		#stored into input
	li	$a1, 256		# max size=  256 chars/bytes 
	syscall
	
	#li	$v0, 4			# output the expression
	#la	$a0, input
	#syscall
	la $t2, input
	
	
parseExpression:
	li	$t0, 0			# Set t0 to zero to be sure
	li	$t3, 0			# Set t3 to zero to be sure
	li 	$t6, 0
	
	parserLoop:
		# $t3 is i=0
		add	$t3, $t2, $t0		# $t2 is the base address for our 'input' array, add loop index
		lb	$t4, 0($t3)		# load a byte at a time according to counter
										
		beqz	$t4, exit		# We found the end of the expression (null-byte)
		#sb	$t4, output($t1) could later re purpose this for stack use
		
		
		#####THIS IS WHERE WE HAVE ACCESS TO THE CHARACTERS! $T4
		
		#just prints each character for right now
		li $v0, 11
		move $a0, $t4
		syscall
			
		#prnt a newline	
		#li	$v0, 4			
		#la	$a0, newline 
		#syscall	
		
		beq $t4, '+' isPlusOrMinus
		beq $t4, '-' isPlusOrMinus
		beq $t4, '(' openParen
		beq $t4, ')' closedParen
		
		#else is number section 
			li	$v0, 4			
			la	$a0, isNumber
			syscall	  
			li	$v0, 4			
			la	$a0, newline 
			syscall	    
			#append to post fix
			
			addi $a0, $zero, 0
			move $a0, $t4
			jal stackPush
			j loopWork    
		    
		   
		isPlusOrMinus:
			    
		      	li	$v0, 4			
			la	$a0, isOperator
			syscall	
			li	$v0, 4			
			la	$a0, newline 
			syscall	
			
			
			#addi $a0, $zero, 0
			#move $a0, $t4
			#jal stackPush
			
			j loopWork
		isPlus:
		
			li	$v0, 4			
			la	$a0, isPlusOperator
			syscall	
			li	$v0, 4			
			la	$a0, newline 
			syscall	
			j loopWork	
		
		isMinus:
		
			li	$v0, 4			
			la	$a0, isMinusOperator
			syscall	
			li	$v0, 4			
			la	$a0, newline 
			syscall	
			j loopWork
		 
		openParen:
		 	#push to stack
		 	li	$v0, 4			
			la	$a0, isOpenParen
			syscall	
			li	$v0, 4			
			la	$a0, newline 
			syscall	
			j loopWork
		 	
		 closedParen:
		 	#pop everything from stack until a closed parenthesis
			li	$v0, 4			
			la	$a0, isClosedParen 
			syscall	
			li	$v0, 4			
			la	$a0, newline 
			syscall	
			j loopWork
		
		
	loopWork:
		addi	$t0, $t0, 1		# Advance our counter (i++)
		j	parserLoop		# Loop until we reach our condition
	

	

exit:
	
	
	li	$v0, 4			# Print
	la	$a0, outputExpression		# the string!
	syscall
	
	li	$v0, 4			
	la	$a0, newline 
	syscall	
	
	jal stackPeek
	jal stackPop	
	jal stackPeek
	jal stackPop	
	jal stackPop
	jal stackPop
	jal stackPeek
	jal stackPeek
	jal stackPop
	jal stackPeek
	jal stackPop
	
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
	
	jr $ra
	
stackIsEmpty:
	#use stack peak and compare to an empty value
appendToExpression:



	