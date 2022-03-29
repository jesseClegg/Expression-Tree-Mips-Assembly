
	.data
input:	.space	256
outputExpression: .space 256
pushingToStack: .asciiz " ] is getting pushed to stack \n"
poppingFromStack: .asciiz " is popped from stack \n"
peakingFromStack: .asciiz " peeking from stack"
stackIsEmptyMessage: .asciiz " stack is empty"
stickIsNotEmpty: .asciiz " stack is NOT empty"
beingAppended: .asciiz " is being appended "
newline: .asciiz "\n"
postfixExpressionMessage: .asciiz "postfix expression: "
firstPrompt: .asciiz "Expression to be evaluated: \n"
isThree: .asciiz "its a three!!!   "
isOperatorMessage: .asciiz " is an operator"
isPlusOperator: .asciiz " found a +\n"
isMinusOperator: .asciiz " found a -\n"
isOpenParen: .asciiz " found (\n"
isClosedParen: .asciiz " found )\n"
isNumberMessage: .asciiz " is a number"
emptyingstackmessage: .asciiz "NOW EMPYTING THE STACK...\n"
sizeOf: .asciiz "expression has size of : "
plusSign: .byte '+'
minusSign: .byte '-'
emptyStackSentinel: .word 'E'
finishLine: .asciiz "finish line woo!"
resultofoperationmessage: .asciiz " result of operation "
firstnumis: .asciiz " is first number \n"
secondnumis: .asciiz " is second number \n"
equalCharacter: .asciiz "="
bracket: .asciiz " )"
	.text
	.globl main
main:

ScanUserinput:
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
	
	parserLoop:
		# $t3 is i=0
		add	$t3, $t2, $t0		# $t2 is the base address for our 'input' array, add loop index
		lb	$t4, 0($t3)		# load a byte at a time according to counter								
		beqz	$t4, AfterParseLoop		# We found the end of the expression (null-byte)
		
		beq $t4, '+' isPlusOrMinus
		beq $t4, '-' isPlusOrMinus
		beq $t4, '(' openParen
		beq $t4, ')' closedParen
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
			#append to post fix
			addi $a0, $zero, 0
			addi $a0, $t4, 0
			sb $t4, outputExpression($s0)
			addi $s0, $s0, 1
	
			j loopWork    
		   
		isPlusOrMinus:	
			#clear $s3, stores stack empty boolean 
			addi $s3, $zero, 0
			jal stackIsEmpty
			move $s3, $v0
				
				#if stack is not empty, pop from stack, and append to postfix until empty or '('
				beq $s3, 1 wasEmpty	
					
					addi $t6, $zero, 0
					jal stackPeek
					move $t6, $v0
					
					#top of the stack is peeked into $t6
					beq $t6, '(' wasEmpty
					
						jal stackPop
						addi $a0, $zero, 0
						addi $a0, $v0, 0
					
						sb $a0, outputExpression($s0)
						addi $s0, $s0, 1
				 
					j isPlusOrMinus
				wasEmpty:
					#push operator onto the stack if stack is empty
					addi $a0, $zero, 0
					move $a0, $t4
					jal stackPush
				
					j loopWork
		 
		openParen:
			#push opening paren onto the stack
			addi $a0, $zero, 0
			move $a0, $t4
			jal stackPush
			j loopWork
		 	
		 closedParen:
		 
			closedParenLoop:	
				#pop everything from stack until a closed parenthesis
				#need to make a loop here
				addi $t6, $zero, 0
				jal stackPeek
				move $t6, $v0
				
					beq $t6, '(' matchingParenFound
						addi $t8, $zero, 0
			
						#should have whats popped from stack now
						addi $t8, $zero, 0
						jal stackPop
						move $t8, $v0
			
						#append to post fix
						addi $a0, $zero, 0
						addi $a0, $t8, 0
						sb $t8, outputExpression($s0)
						addi $s0, $s0, 1
				
					j closedParenLoop
					
			matchingParenFound:
				#pop it to get rid of the '('
				jal stackPop
				j loopWork
		
		
	loopWork:
		addi	$t0, $t0, 1		# Advance our counter (i++)
		j	parserLoop		# Loop until we reach our condition
	


AfterParseLoop:
	#pop any remaining operators on the stock and append to postfix expression
	emptyTheStack:
		
		addi $s3, $zero, 0
		jal stackIsEmpty
		move $s3, $v0	
		
		beq $s3, 1 stackIsEmptied		
		
			jal stackPop
			addi $t9, $zero, 0
			addi $t9, $v0, 0
		
			sb $t9, outputExpression($s0)
			addi $s0, $s0, 1
			j emptyTheStack		 


	stackIsEmptied:
	
		
	
		addi $t9, $zero, 0
		addi $t9, $zero, 7
		sb $t9, outputExpression($s0)
		addi $s0, $s0, 1
		
		
		
		
output:
		
		#print postfix message
		#li	$v0, 4			
		#la	$a0, postfixExpressionMessage 
		#syscall
		
		#print the postfix expression	
		li, $v0, 4
		la $a0, outputExpression
		syscall
		
		#li	$v0, 4			
		#la	$a0, newline 
		#syscall

	
EvaluateExpression:	
	#reset index to zero
	addi $s0, $zero, 0
	addi $t2, $zero, 0
	la $t2, outputExpression

	li	$t0, 0			
	li	$t3, 0	
	li	$t4, 0

	
evaluateLoop:
	# $t3 is i=0
		add	$t3, $t2, $t0		# $t2 is the base address for our 'input' array, add loop index
		lb	$t4, 0($t3)		# load a byte at a time according to counter								
		beqz	$t4, EndOfProgram

		#li	$v0, 4			
		#la	$a0, newline 
		#syscall

		#print the current element
		#li $v0, 11
		#move $a0, $t4
		#syscall
		
		#li	$v0, 4			
		#la	$a0, bracket
		#syscall
		
		
		
		beq $t4, '+' isPlus
		beq $t4, '-' isMinus
		beq $t4, '0' isOperand
		beq $t4, '1' isOperand
		beq $t4, '2' isOperand
		beq $t4, '3' isOperand
		beq $t4, '4' isOperand
		beq $t4, '5' isOperand
		beq $t4, '6' isOperand
		beq $t4, '7' isOperand
		beq $t4, '8' isOperand
		beq $t4, '9' isOperand		
		j iterate2

		isPlus:
		#	li	$v0, 4			
		#	la	$a0, isPlusOperator 
		#	syscall	
			
			#stack pop =$t6
			addi $t6, $zero, 0
			jal stackPop
			move $t6, $v0
			
			#printline messages
		#	li $v0, 11
		#	move $a0, $t6
		#	syscall
		#	li	$v0, 4			
		#	la	$a0, secondnumis 
		#	syscall	
			
			#stack pop =$t5
			addi $t5, $zero, 0
			jal stackPop
			move $t5, $v0
			
			#printline messages
		#	li $v0, 11
		#	move $a0, $t5
		#	syscall
		#	li	$v0, 4			
		#	la	$a0, firstnumis 
		#	syscall	
			
			# $t7=$t5+$t6
			addi $t7, $zero, 0
			add $t7, $t5, $t6
			
			#print the result
		#	li $v0, 1
		#	move $a0, $t7
		#	syscall
		
			#li	$v0, 4			
			#la	$a0, resultofoperationmessage 
			#syscall
			
			#push $t7(result) to stack
			addi $a0, $zero, 0
			move $a0, $t7
			jal stackPush
			
			j iterate2
		isMinus:
			#li	$v0, 4			
			#la	$a0, isMinusOperator 
			#syscall	
			
			#stack pop =$t6
			addi $t6, $zero, 0
			jal stackPop
			move $t6, $v0
			
			#printline messages
			#li $v0, 11
			#move $a0, $t6
			#syscall
			#li	$v0, 4			
			#la	$a0, secondnumis 
			#syscall	
			
			#stack pop =$t5
			addi $t5, $zero, 0
			jal stackPop
			move $t5, $v0
			
			#printline messages
			#li $v0, 11
			#move $a0, $t5
			#syscall
			#li	$v0, 4			
			#la	$a0, firstnumis 
			#syscall	
			
			# $t7=$t5-$t6
			addi $t7, $zero, 0
			sub $t7, $t5, $t6
			
			#print the result
			#li $v0, 1
			#move $a0, $t7
			#syscall
		
			
			
			#push $t7(result) to stack
			addi $a0, $zero, 0
			move $a0, $t7
			jal stackPush
			
			j iterate2
		
		#is a number
		isOperand:

			#subtract 48
			addi $t4, $t4, -48
			
			#li	$v0, 1			
			#la	$a0, isNumberMessage 
			#syscall		
			
			
			#push it onto stack
			addi $a0, $zero, 0
			move $a0, $t4
			jal stackPush

		

			j iterate2
		
		
		
	iterate2:
		addi	$t0, $t0, 1		# Advance our counter (i++)
		j	evaluateLoop










EndOfProgram:	
		
		#li	$v0, 4			
		#la	$a0, newline 
		#syscall
		
		
		#li	$v0, 4			
		#la	$a0, resultofoperationmessage 
		#syscall
		
		li	$v0, 4			
		la	$a0, equalCharacter 
		syscall
		
		
		#li	$v0, 4			
		#la	$a0, newline 
		#syscall
		
		
	emptyTheStack2:
		
		addi $s3, $zero, 0
		jal stackIsEmpty
		move $s3, $v0	
		
		beq $s3, 1 stackIsEmptied2		
		
			jal stackPop
			addi $t9, $zero, 0
			addi $t9, $v0, 0
		
			li $v0, 1
			move $a0, $t9
			syscall
			
			#li	$v0, 4			
			#la	$a0, newline 
			#syscall
			
			j emptyTheStack2		 


	stackIsEmptied2:
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		#newline
		#li	$v0, 4			
		#la	$a0, newline 
		#syscall	
		
		#finish line
		#li	$v0, 4			
		#la	$a0, finishLine		
		#syscall
		
		# exit()
		li	$v0, 10			
		syscall
#####################################################################################################################	
stackPush:
	#move stack pointer
	addi $sp, $sp, -4
	sw $a0, 0($sp) #push to stack	
	
	
	#move $t8, $a0
	#li	$v0, 4			
	#la	$a0, newline 
	#syscall	
	
	#li $v0, 11
	#move $a0, $t8
	#syscall
	
	#li	$v0, 4			
	#la	$a0, pushingToStack 
	#syscall	
	
	
	jr $ra
	
stackPop:
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	
	#move stack pointer
	addi $sp, $sp, 4
	
	addi $v0, $zero, 0
	move $v0, $t9
	jr $ra
	
stackPeek:
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	
	addi $v0, $zero, 0
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
	syscall		
	
	
	#dont need this?
	#increment the index we are at for main	
	addi $s0, $s0, 1
	jr $ra

		