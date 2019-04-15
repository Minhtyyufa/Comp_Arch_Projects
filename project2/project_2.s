/*
	Minh-Thai Nguyen and Sophie Jaro
	4/14/2019
	This program sorts an array from a given input file and outputs 
	the result to an output file 
*/  


.global main
.extern printf 	/* import printf */
.extern scanf	/* import scanf */
.extern fscanf	/* import fscanf */
.extern fopen 	/* import fopen */
.extern fclose 	/* import fclose */

.data
.balign 4
infile_msg:	.asciz "What is the input file name?: "		/* msg to prompt for input file name */
outfile_msg:	.string "What is the output file name?: "	/* msg to prompt for output file name */
input_format: 	.string "%s"	/* input format for scanf */
r_mode:		.string "r"	/* read mode for fscanf */
w_mode:		.string "w"	/* write mode for fscanf */

file_format:	.string "%d"	/* input format for fscanf */ 
array:		.skip 404	/* allocation for the array */
size_of_array:	.word 0		/* var for size_of_array. Actually size of array*4 */
file_name:	.skip 100	/* char array to store file_name */	
file:		.word 0		/* ptr to file */
out_msg:	.asciz "%d \n"	/* output format for fscanf */
return:		.word 0		/* var for return address */

/* error messages */
error_no_input: .string "ERROR: Could not find the input file\n"	/* error msg for no input file */
error_too_big:	.string "ERROR: File is too big\n"		/* error msg for too big of an array */

.balign 4
/* stores return address in return */
main:
	ldr r1, ptr_return	/* r1 <- &return */	
	str lr, [r1]		/* return <- lr */

/* gets input file name from user */
get_infile:

	/* prints infile_msg */
	ldr r0, =infile_msg	/* r0 <- &infile_msg */	
	bl printf

	/* reads the user input and stores it in file name */
	ldr r0, =input_format	/* r0 <- &input_format */
	ldr r1, ptr_file_name	/* r1 <- &file_name */
	bl scanf
	
	
/* Opens file and initializes iterator for reading */
init_read:
	ldr r1, =r_mode /* r1 <- &r_mode This is an input parameter for open_file as defined below*/
	bl open_file	/* branches to open_file */
	mov r5, #0	/* r5 <- 0 */
		
/* loop that reads line and stores it in the array until it hits the end of the file */
read_line:
	cmp r5, #404		/* if i is bigger than 100 then throw error */
	beq error_big
	ldr r0, ptr_file	/* r0 <- &file */
	ldr r0, [r0]		/* r0 <- file */
	ldr r1,	=file_format	/* r1 <- &file_format */	
	ldr r2, ptr_array	/* r2 <- &array[0] */
	add r2, r2, r5		/* r2 <- &array[i] */
	bl fscanf

	add r5, r5, #4		/* i++ */	
	cmp r0, #0		/* if r0 is -1 that means end of file */
	bge read_line		/* exit loop if end of file */ 

/* stores the size of array and closes file */
eof:
	ldr r1, ptr_size_of_array	/* r1 <- &size_of_array */
	sub r5, r5, #4	/* Had to subtract one iteration because the iterator of the 
			loop is separated from the compare. Did this so we wouldn't
			have a line in read_line that branches to eof in read_line */
	str r5, [r1] 	/* size_of_array <- r5 */
	bl close_file	/* closes file */

/* initiates the variables for the sort */
init_sort:
	ldr r0, ptr_array	/* r0 <- &array[0] */
	ldr r1, ptr_size_of_array	/* r1 <- &size_of_array */
	ldr r1, [r1]	/* r1 <- size_of_array */ 
	sub r1, r1, #4	/* r1 = r1 - 4 */
	add r1, r0, r1	/* r1 <- address of last element */
	mov r2, r0	/* r2 <- r0 */

/* outer loop for insertion sort */
insertion_sort:
	/* if we reach the last element end the loop */	
	cmp r2, r1
	bgt get_outfile	
	
	/* else prepare for swaps (the inner loop) */
	mov r3, r2	/* r3 <- r2 */
	bl swaps	/* branch to swaps */
	
	add r2, r2, #4	/* i++ increment the element in the array */
	b insertion_sort	

/* inner loop that swaps until everything before index specified in r2 is sorted */
swaps:
	sub r3, r3, #4	/* r3 <- &array[i-1] */
	cmp r3, r0	/* sees if r3 is less than &array[0], if it is return to outer loop */
	bxlt lr 

	ldr r4, [r3]		/* r4 <- array[i-1] */
	ldr r5, [r3, #4]	/* r5 <- array[i] */
	cmp r5, r4		/* if r4 is <= r5 then return to outer loop */
	bxge lr 
	
	/* if no exit conditions, then swap and repeat */
	/* array[i] <-> array[i-1] */
	str r4, [r3, #4]	 
	str r5, [r3]	
	b swaps

/* prompts the user for an outfile */
get_outfile:
	/* prints the prompt msg */
	ldr r0, =outfile_msg
	bl printf

	/* stores the input from the user into file_name */
	ldr r0, =input_format
	ldr r1, ptr_file_name
	bl scanf

/* opens the file and initializes the vars */
init_write:
	/* opens file in write mode */
	ldr r1, =w_mode /* r1 <- &w_mode */
	bl open_file

	mov r4, #0	/* r4 <- 0 */
	ldr r5,	ptr_size_of_array /* r5 <- &size_of_array */
	ldr r5, [r5] 	/* r5 <- size_of_array */	
	sub r5, r5, #4	/* r5 = r5 - 4 */
	ldr r6, ptr_array	/* r6 <- &array[0] */

/* loop for writing a line to a file */
write_line:
	ldr r0, ptr_file	/* r0 <- &file */
	ldr r0, [r0]		/* r0 <- file */
	ldr r1, =out_msg	/* r1 <- &out_mst */
	ldr r2, [r6, r4]	/* r2 <- array[i] */
	bl fprintf

	add r4, r4, #4 	/* i++, where i is the index given by r4 */
	cmp r4, r5 	/* sees if r4 is less than or equal the address of the last element in the array */ 
	ble write_line	/* if it isn't continue */

/* exit the program */
exit:
	bl close_file 		/* branch to close_file */ 
	ldr r1, ptr_return	/* r1 <- &return */
	ldr lr, [r1]		/* lr <- return */
	bx lr			/* exit */

/* opens the file specified in file_name and stores the file pointer in file */
/* r1 should be mode */
open_file:
	push {lr}		/* push lr onto the stack */	
	ldr r0, ptr_file_name	/* r0 <- &file_name */
	bl fopen		/* branch to fopen */

	/* if it can't find the file it will throw an error and exit */
	/* fopen returns the null character when it can't find the file */
	cmp r0, #0x00
	beq error_no_file

	ldr r1, ptr_file	/* r1 <- &file */
	str r0, [r1] 		/* file <- r0 fopen returns a pointer to the file */
	pop {lr}		/* restore lr to its original value */
	bx lr			/* return */
	
/* closes the file specified in file */
close_file:
	push {lr}		/* push lr onto the stack */
	ldr r0, ptr_file 	/* r0 <- &file */	
	ldr r0, [r0]		/* r0 <- file */
	bl fclose		/* branch to fclose */
	pop {lr}		/* restore lr to its original value */
	bx lr			/* return */

error_big:
	ldr r0, =error_too_big 	/* r0 <- &error_too_big */
	bl printf
	b exit

error_no_file:
	ldr r0, =error_no_input	/* r0 <- &error_no_input */
	bl printf
	ldr r1, ptr_return	/* r1 <- &return */
	ldr lr, [r1]		/* lr <- return */	
	bx lr
		
/* pointers to variables */
ptr_return:		.word return
ptr_file_name:		.word file_name
ptr_file:		.word file
ptr_array:		.word array
ptr_size_of_array:	.word size_of_array
