.data

# define the require data
array: .space 1000 #leave enough spave for input data
newline: .asciiz "\n"
space: .asciiz " "
str1: .asciiz "Please enter the number of integers you want to sort: "
str2: .asciiz "Enter the integer: "
original: .asciiz "\nThe original array: "
sort: .asciiz "\nThe sorted array: "
switches: .asciiz "\n#switches: "


.text


main:
	# a.	To get array’s size and input integers from users.
	jal getSize
	jal getInputIntergers
	jal printOriginal
	# b.	To bubble sort the input array
	jal bubbleSort
	# c.	To output the sorted array
	jal printSorted
	# The number of switches is used for debug 
	jal printNoOfSwitches
	j exit

getSize:
	# print "Enter the integer: " on console
	li $v0, 4								# print string instruction
	la $a0, str1							# load addr of str1 for syscall
	syscall
	# read the number of integers
	li $v0, 5								# read integer and save in $v0
	syscall

	add $s0, $v0, $zero						# transfer the number into $s0
	j Out

	# $s0 : the number of integers

	# for(i = 0; i< no of integers; i++){
	# 	A.push(i);
	# }


getInputIntergers:
	la $s2, array							# $s2 = array address
	add $t0, $zero, $zero					# set index i = 0 ($t0)
	add $t1, $s2, $zero 					# $t1 = array address (tmp)

	# print "Please enter the number of integers you want to sort: " on console
prompt: li $v0, 4						    # print string instruction
		la $a0, str2
		syscall
		li $v0, 5							# read integer and save in $v0
		syscall
		sw $v0, ($t1)						# store the input value
		addi $t1, $t1, 4					# remove the current address to next array cell
		addi $t0, $t0, 1					# increase index i, i++
		beq $t0, $s0, Out					# break loop if all the integers are obtained
		j prompt

	# while(i<numberOfIntegers){
	# 	print(A[i]);
	# 	i++;
	# }


printInteger:
	add $t0, $zero, $zero					# set index i = 0 ($t0)
	add $t1, $a0, $zero 					# $t1 = array pointer
loop:	lw $t2, ($t1)						# load the inreger into $t2
		add $a0, $t2, $zero					# print
		li $v0, 1
		syscall
		li $v0, 4						    # print string instruction
		la $a0, space						# print space
		syscall
		addi $t1, $t1, 4 					# increment pointer to next array cell	
		addi $t0, $t0, 1					# increment index i
		bne $t0, $s0, loop					# if index i < numberOfIntegers
		j Out

# s0 : number of integers
# s2 : address of first value of array
# s3 : save the number of switches
# t0 : counter for outer loop
# t1 : counter for inner loop
# t2 : n-1 
# t3 :	
# t4 : n-c-1
# t5 : A[d]
# t6 : A[d+1]

##########################################################
# void BubbleSort::Sort(int* array, int length)			 #
# {														 #
#     for (int i = length - 1; i > 0; --i)				 #
#         for (int j = 0; j < i; ++j)					 #
#             if (array[j] > array[j + 1])				 #
#                 swap(array[j], array[j + 1]);			 #
# }														 #
##########################################################


bubbleSort:
			li $t0, 0 						# t0 = counter for outer loop (initialized:0) = c
	OuterLoop:
			li $t1, 0						# t1 = counter for inner loop (initialized:0) = j
			add $t2, $zero, $zero				
			li $t2, -1
			add $t2, $s0 $t2				# t2 = n-1
			slt $t7, $t0, $t2				# if( t0 < n-1 )
			beq $t7, $zero, Out
	InnerLoop:
			sub $t4, $t2, $t0				# t4 = n - c -1
			slt $t3, $t1, $t4				# if( t1=j < n-c-1 )
			beq $t3, $zero, incT1ctr		# if( t1 = n-c-1 ), jump out of inner loop
			sll $t3, $t1, 2					
			add $t3, $t3, $s2               
			lw $t5, 0($t3)					# save A[j]
			lw $t6, 4($t3)					# save A[j+1]
			bgt $t6, $t5, no_swap           # if(A[j] <= A[j+1])
			# if if(A[j] > A[j+1]) :
			addi $s3, $s3 , 1				# update $s3 which tracks number of Swaps used in the sortIntegers funtion
			sw $t6, 0($t3)					# swap
			sw $t5, 4($t3)
	no_swap:
			add $t1, $t1, 1					#increment counter of inner loop
			j InnerLoop
	incT1ctr: 
			add $t0, $t0, 1 				# increment counter $t0 for outer loop
			beq $t3, $zero, OuterLoop
			j Out

printSorted:
	li $v0, 4
	la $a0, sort
	syscall
	add $a0, $s2, $zero						# load the integers into $a0
	j printInteger

printOriginal:
	li $v0, 4
	la $a0, original
	syscall
	add $a0, $s2, $zero						# load the integers into $a0
	j printInteger

printNoOfSwitches:
	li $v0, 4
	la $a0, switches
	syscall
	add $a0, $s3, $zero						# load the integers into $a0
	li $v0, 1
	syscall
	j pOut

Out:
	jr $ra 									# return to the original address
exit:
	li $v0, 10
	syscall