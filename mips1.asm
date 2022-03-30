#Jesse Clegg 404 Project 2, Spring 2022
.data
input:	.space	256
outputExpression: .space 256
newline: .asciiz "\n"
firstPrompt: .asciiz "Expression to be evaluated: \n"
emptyStackSentinel: .word 'E'
equalCharacter: .asciiz "="

.text

.globl main
main:

#state 1==input
scanUserinput:
	#clear some registers to be safe
	#will use $s0 as an index for appending to string
	addi $s0, $zero, 0
	add $t1, $zero, 0
	addi $t8, $zero, 0
	
	#put our sentinel 'E' onto the stack for isEmpty()
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
	
	#read in expression, stored into input, max size= 256 chars/bytes
	li	$v0, 8			 
	la	$a0, input		
	li	$a1, 256		
	syscall
	
	#keep track of the start address of input string
	la $t2, input
	
#state 2==convert-to-postfix	
convertToPostfix:
	#clear some registers
	li	$t0, 0			
	li	$t3, 0			
	li 	$t6, 0			
	li	$t5, 13
	
	parserLoop:
		# $t3 is i=0
		add	$t3, $t2, $t0		# $t2 is the base address for our 'input' array, add loop index
		lb	$t4, 0($t3)		# load a byte at a time according to counter								
	beqz	$t4, emptyTheStack		# We found the end of the expression (null-byte)
		
		#switch case for current character of expression
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
				addi $t6, $zero, 0
				jal stackPeek
				move $t6, $v0
				
					#stop popping when we find the matching '('
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
				#pop stack to get rid of the '('
				jal stackPop
				j loopWork
		
		
	loopWork:
		addi	$t0, $t0, 1		# increment by size of a byte
		j	parserLoop		# Loop until end of expression
	
	
emptyTheStack:
		
		#check if stack is empty
		addi $s3, $zero, 0
		jal stackIsEmpty
		move $s3, $v0	
		
		#pop any remaining operators on the stock and append to postfix expression
		beq $s3, 1 stackIsEmptied		
			
			jal stackPop
			addi $t9, $zero, 0
			addi $t9, $v0, 0
		
			sb $t9, outputExpression($s0)
			addi $s0, $s0, 1
			j emptyTheStack		 


	stackIsEmptied:
		#append last value popped from stack to the postfix expression
		addi $t9, $zero, 0
		addi $t9, $zero, 7
		sb $t9, outputExpression($s0)
		addi $s0, $s0, 1
		

		
#state 3==evaluate	
EvaluateExpression:	
	#reset index i to zero
	addi $s0, $zero, 0
	
	#clear out $t2 and use it to store start of outputExpression
	addi $t2, $zero, 0
	la $t2, outputExpression

	li	$t0, 0			
	li	$t3, 0	
	li	$t4, 0

	evaluateLoop:
		#$t3 is base address of output string plus loop counter $t0 which is incremented each iteration
		add	$t3, $t2, $t0		
		
		# load current byte of the postfix into $t4	
		lb	$t4, 0($t3)								
	
	#if we reach end of expression($t4==0), we are done evaluating
	beqz $t4, output
		#switch case for current character of expression
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
			#stack pop =$t6
			addi $t6, $zero, 0
			jal stackPop
			move $t6, $v0
			
			#stack pop =$t5
			addi $t5, $zero, 0
			jal stackPop
			move $t5, $v0
			
			# $t7=$t5+$t6
			addi $t7, $zero, 0
			add $t7, $t5, $t6
		
			#push $t7(result) to stack
			addi $a0, $zero, 0
			move $a0, $t7
			
			jal stackPush	
			
			j iterate2
		
		isMinus:
			#stack pop =$t6
			addi $t6, $zero, 0
			jal stackPop
			move $t6, $v0	
			
			#stack pop =$t5
			addi $t5, $zero, 0
			jal stackPop
			move $t5, $v0	
			
			# $t7=$t5-$t6
			addi $t7, $zero, 0
			sub $t7, $t5, $t6
			
			#push $t7(result) to stack
			addi $a0, $zero, 0
			move $a0, $t7
			jal stackPush
			j iterate2
		
		isOperand:
			#subtract 48 to convert from ascii to an integer
			addi $t4, $t4, -48
			
			#push integer value onto stack
			addi $a0, $zero, 0
			move $a0, $t4
			jal stackPush

			j iterate2
			
	iterate2:
		#increment index $t0 by one byte
		addi	$t0, $t0, 1		
		j evaluateLoop


		
#state 4==output		
output:
		
		#print the postfix expression	
		li, $v0, 4
		la $a0, outputExpression
		syscall
		
		#prints '='
		li	$v0, 4			
		la	$a0, equalCharacter 
		syscall
	#solution should be on top of the stack	
	emptyTheStack2:
		
		addi $s3, $zero, 0
		jal stackIsEmpty
		move $s3, $v0	
		
		beq $s3, 1 endOfProgram		
		
			jal stackPop
			addi $t9, $zero, 0
			addi $t9, $v0, 0
		
			li $v0, 1
			move $a0, $t9
			syscall
			
			j emptyTheStack2		 


endOfProgram:
	# exit program
	li	$v0, 10			
	syscall

#modular helper methods below
stackPush:
	#move stack pointer by size of a word
	addi $sp, $sp, -4
	sw $a0, 0($sp) #push to stack	
	
	jr $ra
	
stackPop:
	#load word on top of stack into $t9
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	
	#move stack pointer
	addi $sp, $sp, 4
	
	#return this value in $v0
	addi $v0, $zero, 0
	move $v0, $t9
	jr $ra
	
stackPeek:
	#load word on top of stack into $t9
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	
	#return this value in $v0
	addi $v0, $zero, 0
	move $v0, $t9
	jr $ra
	
stackIsEmpty:
	#load word on top of stack into $t9
	addi $t9, $zero, 0
	lw $t9, 0($sp)
	
	#load the sentinel value 'E' which indicates an empty stack into $t8
	addi $t8, $zero, 0
	lw $t8, emptyStackSentinel($zero)
	
	#If our sentinel value is on top of the stack, 
	#then this stack is empty(return 1), 
	#else it is not(return 0)
	beq $t9, $t8 empty
		addi $v0, $zero, 0
		jr $ra
	empty:
	 	addi $v0, $zero, 1
	 	jr $ra
	 	