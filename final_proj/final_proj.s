
.global main
.extern printf 
.extern sscanf

.data
.balign 4 
in_format:	.string "%f"

.balign 4 
out_msg:	.string "%lf\n"

.balign 4
num_array: 	.skip 256

.balign 4
op_array:	.skip 64 

.balign	4  
flt:		.skip 64 

.balign 8	
other_flt:	.skip 16 

.balign 4 
return:		.word 0

.balign 4
bot_stack:	.word 0		/* address of the bottom of the stack */

.balign 4
prev_op: 	.word 0 	/* address of the prev operator in the string */

.balign 4
unknown_input_msg:	.string "ERROR: Character not recognized\n"

.balign 4
bad_format_msg:	.string "ERROR: Bad equation format\n"

.balign 4
div_by_zero_msg:	.string "ERROR: Division by zero\n"
.balign 4 
main: 
	ldr r2, ptr_return
	str lr, [r2] 
	ldr r2, ptr_bot_stack
	str sp, [r2] 

	
/*
	
	ldr r0, =in_msg
	ldr r1, ptr_flt
	bl scanf
	
	ldr r0, ptr_flt
	flds s0, [r0]
	fadds s0, s0, s0
	fsts s0, [r0]

	ldr r0, =out_msg
	ldr r1, ptr_flt
	bl printf
*/
init_read:
	ldr r4, [r1, #4]
	mov r5, #-1			/* initialize input string index to -1 */
	ldr r2, ptr_prev_op
	str r4, [r2] 
	
	ldr r6, ptr_op_array		/* pointer to zeroth element of op_array */
	mov r7, #0 			/* initialize op_array index to 0 */

	ldr r8, ptr_num_array		/* pointer to zeroth element of num_array */
	mov r9, #0 			/* initialize num_array index to 0 */	
	
	mov r10, #0			/* was last op a right parenth */

read:
	add r5, r5, #1
	ldrb r3, [r4, r5]
	cmp r3, #0

	beq end_of_input
	
	/* One check of validity */
	cmp r3, #57
	bgt error_unknown_input
	
	cmp r3, #48			/* is it a number? */
	bge read
	cmp r3, #46			/* is it the . */
	beq read			
	
	cmp r3, #40
	beq left_paren

operator:
	strb r3, [r6, r7]
	add r7, r7, #1
	cmp r3, #43
	beq insert_op 
	
	cmp r3, #45
	beq insert_op 
	
	cmp r3, #42
	beq insert_op 
	
	cmp r3, #47
	beq insert_op 

	cmp r3, #41
	beq insert_right_paren
	
	b error_unknown_input

left_paren:
	push {r7} 
	add r1, r4, r5
	add r1, r1, #1
	ldr r2, ptr_prev_op
	str r1, [r2]
	b read

insert_right_paren:
	mov r0, r10 		/* was the last operator a right parenthesis */
	mov r10, #1
	cmp r0, #0
	beq scan_num	

	add r1, r4, r5
	add r1, r1, #1
	ldr r2, ptr_prev_op
	str r1, [r2]
	b read
insert_op:
	mov r0, r10
	mov r10, #0
	cmp r0, #0
	beq scan_num

	add r1, r4, r5
	add r1, r1, #1
	ldr r2, ptr_prev_op
	str r1, [r2]
	b read
	
scan_num:
	mov r3, #0
	add r1, r4, r5 
	strb r3, [r1]

	ldr r2, ptr_prev_op 	/* actually the previous op plus one */
	ldr r0, [r2]
	add r1, r1, #1
	str r1, [r2]

	ldr r1, =in_format
	add r2, r8, r9
	add r9, r9, #4
	bl sscanf
	cmp r0, #0
	blt error_bad_format
	b read

	
end_of_input: 
	strb r3, [r6, r7]
	ldr r2, ptr_prev_op 	/* actually the previous op plus one */
	ldr r0, [r2]
	ldr r1, =in_format
	add r2, r8, r9
	bl sscanf
	/* don't need to fix  because its good */
	/*
	cmp r0, #0
	blt error_bad_format
	*/

	
	ldr r7, ptr_bot_stack
	ldr r7, [r7]

in_to_out_solve:
	cmp sp, r7
	bne paren_solve
	mov r0, r8
	mov r2, r6	
	bl solve
	b out_result 
	
paren_solve:
	pop {r2}
	mov r1, r6
	add r2, r2, r6
	mov r3, #0
	bl count

	sub r0, r2, r6
	sub r0, r0, r3
	lsl r0, r0, #2
	add r0, r8, r0

	bl solve
	b in_to_out_solve

count:
	cmp r1, r2
	bxeq lr
	ldrb r0, [r1]
	cmp r0, #41 	
	addeq r3, r3, #1
	add r1, r1, #1
	b count
	

solve:
/* change this to pass r0, r2 to the indices of the left parenthesis */
	push {lr}
	push {r0}
	push {r2}
	mov r1, r0
	mov r3, r2
	flds s1, [r0] 
	
/* change increments to r1 and r0 when u switch to d instead of s */
mult_div_loop:
	fcpys s0, s1

	ldrb r4, [r2]
	cmp r4, #0
	beq add_init 
	cmp r4, #41
	beq add_init 

	flds s1, [r0, #4]
	add r0, r0, #4
	add r2, r2, #1

	cmp r4, #42 
	beq mult
	cmp r4, #47 
	beq div
	fsts s0, [r1]
	strb r4, [r3]
	add r1, r1, #4
	add r3, r3, #1
	b mult_div_loop


mult:
	fmuls s1, s1, s0
	b mult_div_loop
div:

	/* fcmps s1, #0		 this is wrong but the general idea 
	beq error_div_by_0
*/
	fdivs s1, s0, s1
	b mult_div_loop
	
add_init:
	bl shifts		
	pop {r2}
	pop {r0}
	mov r1, r0
	mov r3, r2
	flds s1, [r0]
add_sub_loop:
	fcpys s0, s1
	ldrb r4, [r2]
	cmp r4, #0
	beq end_solve
	cmp r4, #41
	beq add_end 
	
	flds s1, [r0, #4]
	add r0, r0, #4
	add r2, r2, #1
	
	cmp r4, #43
	beq add_nums
sub_nums:
	fsubs s1, s0, s1
	b add_sub_loop
	
add_nums:
	fadds s1, s0, s1
	b add_sub_loop

add_end:
	add r2, r2, #1
end_solve:
	bl shifts
	pop {lr}
	bx lr
	

shifts:
	fsts s0, [r1]
	add r1, r1, #4
	
shift_loop:
	ldrb r4, [r2]
	strb r4, [r3]
	add r2, r2, #1
	add r3, r3, #1
	cmp r4, #41		/* right parenthes */ 
	beq shift_loop
	cmp r4, #0x00
	bxeq lr 
	flds s1, [r0, #4]
	add r0, r0, #4
	fsts s1, [r1]
	add r1, r1, #4
	b shift_loop

out_result:
	ldr r2, ptr_num_array
	flds s0, [r2]
	fcvtds d0, s0 
	vmov r2, r3, d0
	ldr r0, =out_msg		 	
	bl printf
exit:
	ldr r1, ptr_return
	ldr lr, [r1]
	bx lr

error_unknown_input:
	ldr r0, =unknown_input_msg
	bl printf
	b exit

error_bad_format:
	ldr r0, =bad_format_msg
	bl printf
	b exit
error_div_by_zero:
	ldr r0, =div_by_zero_msg
	bl printf
	b exit
	
.balign 4 
ptr_return: 	.word return

.balign 4
ptr_bot_stack:	.word bot_stack

.balign 4
ptr_op_array: 	.word op_array

.balign 4
ptr_flt:	.word flt
	
.balign 4
ptr_other_flt:	.word other_flt
	
.balign 4 
ptr_num_array:	.word num_array
	
.balign 4
ptr_prev_op:	.word prev_op

