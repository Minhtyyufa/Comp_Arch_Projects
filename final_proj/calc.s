/* 
	Minh-Thai Nguyen and Sophie Jaro
	This project uses PMDAS to calculate arguments on the command line
*/

.global main
.extern printf 
.extern sscanf

.data
.balign 4 
in_format:	.string "%f" 	/* input format for sscanf */

.balign 4 
out_msg:	.string "The result is: %lf\n"	/* output message format */

.balign 4
num_array: 	.skip 256 	/* array to store the floating point numbers */

.balign 4
op_array:	.skip 64 	/* array to store operators and right parenthese */

.balign 4 
return:		.word 0		/* return address */

.balign 4
bot_stack:	.word 0		/* address of the bottom of the stack */

.balign 4
prev_op: 	.word 0 	/* address of the prev operator in the string */

/* Error Messages for various errors */
.balign 4
unknown_input_msg:	.string "ERROR: Character not recognized\n"

.balign 4
bad_format_msg:	.string "ERROR: Bad equation format\n"

.balign 4
num_format_msg:		.string "ERROR: Bad number format\n"

.balign 4 
main: 
	ldr r2, ptr_return      /* r2 <- &return */
	str lr, [r2]            /* stores value of lr to address stored in r2 */
	ldr r2, ptr_bot_stack   /* r2 <- &bot_stack */
	str sp, [r2]            /* stores address of the bottom of the stack (used as a parameter to prevent stack underflow) */

init_read:
	ldr r4, [r1, #4]        /* loads address of input string (2nd string in argv) to r4 */
	mov r5, #-1		/* initialize input string index to -1 */
	ldr r2, ptr_prev_op     /* r2 <- &prev_op */
	str r4, [r2]            /* prev_op <- r4 */
	
	ldr r6, ptr_op_array		/* pointer to zeroth element of op_array */
	mov r7, #0 			/* initialize op_array index to 0 */

	ldr r8, ptr_num_array		/* pointer to zeroth element of num_array */
	mov r9, #0 			/* initialize num_array index to 0 */
	
	mov r10, #0			/* was last operator a right parenthesis? 0 if no */
	mov r11, #0			/* Was there another decimal point when passing over a number? 0 if no */

read:
	add r5, r5, #1              /* increment input string index by 1 */
	ldrb r3, [r4, r5]           /* load ith element of input string to r3 */
	
	cmp r3, #0
	beq end_of_input            /* if the ith element is the null char, branch to end_of_input because the string is over */

	cmp r3, #57                 /* One check of validity; no legal input characters have ASCII val greater than 57 */
	bgt error_unknown_input     /* prints error */
	
	cmp r3, #48	        /* Is it a number? */
	bge num

	cmp r3, #46	        /* Is it a decimal point? */
	beq dec_point			
	
	cmp r3, #40		/* Is it a left parenthesis? */
	beq left_paren

operator:
	strb r3, [r6, r7]	/* ith element of op_array = r3 (the current character in string) */
	add r7, r7, #1		/* increment op_array index */
	
	cmp r3, #43 		/* Is it a +? */
	beq insert_op 
	
	cmp r3, #45             /* Is it a -? */
	beq insert_op 
	
	cmp r3, #42           	/* Is it a *? */
	beq insert_op 
	
	cmp r3, #47           	/* Is it a /? */
	beq insert_op 

	cmp r3, #41             /* Is it a right parenthesis? */
	beq insert_right_paren
	
	b error_unknown_input   /* If none of above, unknown input. Print error message. */

num:
	cmp r10, #1		/* Was the previous operator a left parentheses? */
	beq error_bad_format	/* If so, then this is a bad equation format */
	b read
dec_point:
	cmp r10, #1		/* Was the previous operator a left parentheses? */
	beq error_bad_format	/* If so, then this is a bad equation format */
	cmp r11, #1		/* Was there a decimal point before this one? */
	beq error_number_format	/* If so, then this is a bad number format */
	
	mov r11, #1
	b read

left_paren:
	push {r7}               /* push current index of op_array to stack */
	add r1, r4, r5          /* r1 = address of ith element of input string */
	add r1, r1, #1          /* r1 = address of (i+1)th element of input string */
	ldr r2, ptr_prev_op     /* r2 <- &prev_op */
	str r1, [r2]            /* stores value of r1 in prev_op (actually index + 1 aka start of number) */
	b read

insert_right_paren:
	mov r0, r10 		/* moves (was last op a right parenth)? to r0 */
	mov r10, #1         	/* last op was a right parenth */
	cmp r0, #0          	/* if r0 is 0, the last op was not a right parenth */
	beq scan_num	    	/* if last op was not a right parenth, scan number */

	add r1, r4, r5      	/* if last op was a right parenth, r1 = address of ith element of input string */
	add r1, r1, #1      	/* r1 = address of (i+1)th element of input string */
	ldr r2, ptr_prev_op 	/* r2 <- &prev_op */
	str r1, [r2]        	/* stores value of r1 in prev_op (actually index + 1 aka start of number) */
	b read

insert_op:
	mov r0, r10         /* moves (was last op a right parenth)? to r0  */
	mov r10, #0         /* last op was NOT a right parenth */
	cmp r0, #0          /* if r0 is 0, the last op was not a right parenth */
	beq scan_num        /* if last op was not a right parenth, scan number */

	add r1, r4, r5      /* if last op was a right parenth, r1 = address of ith element of input string */
	add r1, r1, #1      /* r1 = address of (i+1)th element of input string */
	ldr r2, ptr_prev_op /* r2 <- &prev_op */
	str r1, [r2]        /* stores value of r1 in prev_op (actually index + 1 aka start of number) */
	b read
	
scan_num:
	mov r11, #0		/* reset the decimal point tracker */	
	mov r3, #0        	/* r3 = 0 */
	add r1, r4, r5      	/* r1 = address of ith element of input string */
	strb r3, [r1]       	/* element at address of ith element of input string is now null char */

	ldr r2, ptr_prev_op 	/* r2 <- &prev_op */
	ldr r0, [r2]            /* r0 <- prev_op */
	add r1, r1, #1          /* r1 = address of (i+1)th element of input string */
	str r1, [r2]            /* element at address of (i+1)th element of input string is now prev_op */

	ldr r1, =in_format      /* load = input format to r1 (sscanf will read float) */
	add r2, r8, r9          /* r2 = pointer to ith element of num_array */
	add r9, r9, #4          /* increment pointer to num_array */
	bl sscanf               /* scan number using sscanf */
	cmp r0, #0              
	blt error_bad_format    /* if sscanf throws an error, print an error msg and end program */
	b read                  /* read next element */

end_of_input: 
	strb r3, [r6, r7]       /* ith element of op_array = r3 */
	ldr r7, ptr_bot_stack   /* r7 <- &bot_stack */
	ldr r7, [r7]            /* r7 = bot_stack */
	cmp r10, #1
	beq in_to_out_solve
final_scan:
	ldr r2, ptr_prev_op 	/* r2 <- &prev_op */
	ldr r0, [r2]            /* r0 <- prev_op */
	ldr r1, =in_format      /* load = input format to r1 (sscanf will read float) */
	add r2, r8, r9          /* r2 = pointer to ith element of num_array */
	bl sscanf
	cmp r0, #0
	blt error_bad_format 

in_to_out_solve:
	cmp sp, r7              /* is the bottom of the stack equal to the stack pointer? ie is the stack empty? are there paren to address? */
	bne paren_solve         /* if the stack is not empty, there are parentheses to address */
				/* otherwise on the final solve */
	mov r0, r8              /* r0 = ptr_num_array */
	mov r2, r6	            /* r2 = ptr_op_array */
	mov r10, #0		/* r10 <- 0, used for parentheses alignment checking */
	bl solve
	b out_result 
	
/* there are parentheses to solve first */
paren_solve:               
	pop {r2}                /* r2 = value at top of stack = number of operators before the left parenthesis */
	mov r1, r6              /* r1 = &op_array[0] (initialized for count)*/
	add r2, r2, r6          /* r2 = &op_array[k] where k is the starting index */
	mov r3, #0              /* r3 = 0 */
	bl count

	sub r0, r2, r6         
	sub r0, r0, r3          /* offset for num_array index */
	lsl r0, r0, #2          /* r0 = r0 *4  */
	add r0, r8, r0          /* r0 = ptr_num_array + r0 (goes to corresponding element in num_array) */
	mov r10, #1		/* r10 <- 1, used for parentheses alignment checking */

	bl solve
	b in_to_out_solve

/* count right parenthesis before starting index. Pass starting index with r2 and start of op_array with r1 */
count:
	cmp r1, r2
	bxeq lr                 /* if we reach the end, branch to link register */
	ldrb r0, [r1]           /* r2 <- &r1 */
	cmp r0, #41
	addeq r3, r3, #1        /* if the element in the op_array is a ), increment the count */
	add r1, r1, #1          /* increment the op_array */
	b count                 /* repeat count */
	
/* Solves a simple expression with no parenthesis. Passed arguments: r0 is starting point in num_array and r2 is starting point in op_array */
solve:
	push {lr}           /* push lr to stack */
	push {r0}           /* push r0 to stack */
	push {r2}           /* push r2 to stack */
	mov r1, r0          /* r1 = starting point in num_array*/
	mov r3, r2          /* r3 = starting point in op_array */
	flds s1, [r0]       /* loads floating point contents at r0 to s1 */
	
/* change increments to r1 and r0 when u switch to d instead of s */
mult_div_loop:
	fcpys s0, s1        /* s0 = s1 */
	
	ldrb r4, [r2]       /* r4 <- op_array[i] */
	cmp r4, #0          /* if a null character is reached on the op_array  */
	beq add_init        /* branch to addition function initialization */
    	cmp r4, #41         /* if the ) is reached on the op_array */
	beq add_init        /* branch to addition function initialization */

	flds s1, [r0, #4]   /* s1 = num_array[i+1] */
	
	/* i++ */
	add r0, r0, #4      /* r0 = r0 + 4 */
	add r2, r2, #1      /* r2 = r2 + 1 */

	cmp r4, #42
	beq mult            /* checks if operation in op_array is multiplication, performs multiplicaiton */
	cmp r4, #47
	beq div             /* checks if operation in op_array is division, performs division */
	
	/* if neither of these store it back into array to evaluate later (this means its an add or sub) */
	fsts s0, [r1]		/* store number into num_array */
	strb r4, [r3]		/* store operator into op_array */
	add r1, r1, #4      /* increment store pointer for num_array */
	add r3, r3, #1      /* increment store pointer for op_array */
	b mult_div_loop

mult:
	fmuls s1, s1, s0    /* multiplies floating point numbers */
	b mult_div_loop
div:
	fdivs s1, s0, s1    /* divides floating point numbers */
	b mult_div_loop
	
add_init:
	bl shifts           /* looks at next element */
	pop {r2}            /* r2 <- starting point in op_array */
	pop {r0}            /* r0 <- starting point in num_array */
	mov r1, r0          /* r1 = r0 */
	mov r3, r2          /* r3 = r2 */
	flds s1, [r0]       /* s1 <- num_array[k] where k is the starting index of the num_array */

add_sub_loop:
	fcpys s0, s1        /* s0 = s1 */
	ldrb r4, [r2]       /* r4 <- &r2 */
	cmp r4, #0          /* if null character reached in op_array... */
	beq end_solve       /* branch to end_solve */
    	cmp r4, #41         /* if ) character reached in op_array... */
	beq add_end         /* branch to add_end */
	
   	 flds s1, [r0, #4]   /* s1 = op_array[i+1] */
    
   	 /* i++ */
    	add r0, r0, #4      /* r0 = r0 + 4 */
    	add r2, r2, #1      /* r2 = r2 + 1 */
	
	cmp r4, #43         /* if element in the op_array is a +  */
	beq add_nums        /* add the numbers  */

sub_nums:
	fsubs s1, s0, s1    /* substracts floating point numbers */
	b add_sub_loop      /* returns to looking for add/sub operations */
	
add_nums:
	fadds s1, s0, s1    /* adds floating point numbers */
	b add_sub_loop      /* returns to looking for add/sub operations */

add_end:
	sub r10, r10, #1	/* if it was a parentheses subtract 1 from the value of r10 */ 
	add r2, r2, #1      /* increment op_array (skip storing the parentheses) */

end_solve:
	/* if it started with a parentheses it should end with one. If it didn't it should end in null. If either is mismatched r10 will not be 0 */
	/* branches to error_bad_format if so */
	cmp r10, #0	
	bne error_bad_format 

	bl shifts           /* branch link to shifts function, which loops through the elements of the num_array */
	pop {lr}            /* pops top of stack to lr */
	bx lr               /* branch exchange with lr */
	

shifts:
	fsts s0, [r1]       /* stores s0 in address of r1 */
	add r1, r1, #4      /* increments r1 */

/* this loop continues until the null char is reached */
shift_loop:  
	ldrb r4, [r2]       /* r4 <- &r2 */
	strb r4, [r3]       /* r4 -> &r3 */
	add r2, r2, #1      /* increment r2, which is read index for op_array */
	add r3, r3, #1      /* increment r3, which is store index for op_array */
	cmp r4, #41		    /* right parentheses */
	beq shift_loop      /* if r4 is a right parentheses, start shift_loop again */
	cmp r4, #0x00       /* if r4 is the null char */
	bxeq lr             /* return */
	flds s1, [r0, #4]   /* s1 <- num_array[i+1] */
	add r0, r0, #4      /* increment r0 */
	fsts s1, [r1]       /* s1 -> num_array[store index] */
	add r1, r1, #4      /* increment r1 */
	b shift_loop

out_result:
	ldr r2, ptr_num_array   /* r4 <- &num_array */
	flds s0, [r2]           /* s0 <- &r2 */
	fcvtds d0, s0           /* converts single-precision floating-point to double-precision */
	vmov r2, r3, d0         /* moves d0 to registers r2, r3 */
	ldr r0, =out_msg
	bl printf               /* prints output message, the evaluation */
exit:
	ldr r1, ptr_return  /* r1 <- &return */
	ldr lr, [r1]        /* lr <- return */
	bx lr               /* branch exchange with lr */

	

/* Printing ERRORS */
error_unknown_input:
	ldr r0, =unknown_input_msg
	bl printf
	b exit

error_bad_format:
	ldr r0, =bad_format_msg
	bl printf
	b exit

error_number_format:
	ldr r0, =num_format_msg
	bl printf
	b exit

	
.balign 4 
ptr_return: 	.word return

.balign 4
ptr_bot_stack:	.word bot_stack

.balign 4
ptr_op_array: 	.word op_array

.balign 4 
ptr_num_array:	.word num_array
	
.balign 4
ptr_prev_op:	.word prev_op

