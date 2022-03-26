.data
	userInput: .space 10 #number of characters to accept is 10
	firstPrompt: .asciiz "enter an expression..."
	newline: .asciiz "\n"
	uEntered: .asciiz "you entered= \n"
.text

.globl main

	main: 
		li $v0, 4
		la $a0, firstPrompt
		syscall
		
		#scan user input 
		li $v0, 8 #8 for a string
		la $a0, userInput #input will be stored to the address of userInput
		li $a1, 10 #tell the system how many characters we are going to store
		syscall 
		
		#print "ypu entered..."
		li $v0, 4
		la $a0, uEntered
		syscall
		
		#prin the actual string
		li $v0, 4 
		la $a0, userInput
		syscall
		
		#print newline
		li $v0, 4
		la $a0, newline
		syscall
		
		
		#put the string address into $t0
		la $t0, userInput
		
		#get the first byte pointed to by the address
		lb $t2, ($t0)
		
		#if the byte in $t2 is equalt to zero, loop ends
		beqz $t2, end
		
	continue:
		add $t0, 1	
	
		











		end:
		# code for exit
		li $v0, 10 
		syscall	
	
				
	

