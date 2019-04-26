
.global main
.extern printf 

.data
.balign 4 
in_format:	.string "%f"

.balign 4 
out_msg:	.string "%f"

.balign 8
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
mult_sign:	.asciz "*"

.balign 4 
div_sign:	.asciz "/"

.balign 4 
r_paren:	.asciz ")"

.balign 4
bot_stack:	.word 0

.balign 4
prev_op: 	.word 0 	/* address of the prev operator in the string */

.balign 4
prev_was_r_pen: .word 0		/* was prev op a right parenthesis */

.balign 4 
main: 
	ldr r2, ptr_return
	str lr, [r2] 
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
	ldr r5, #0			/* initialize input string index to 0 */
	
	ldr r6, ptr_op_array		/* pointer to zeroth element of op_array */
	ldr r7, #0 			/* initialize op_array index to 0 */

	ldr r8, ptr_num_array		/* pointer to zeroth element of num_array */
	ldr r9, #0 			/* initialize num_array index to 0 */	
	
	mov r10, #0			/* was last op a parenth */

read:
	ldrb r3,[r4, r5]
	add r5, r5, #1
	cmp r3, #0x00
	beq end_of_input
	
	/* One check of validity */
	cmp r3, #57
	bgt error_unknown_input
	
	 
	cmp r3, #48			/* is it a number? */
	blt read
	cmp r3, #46			/* is it the . */
	blt read			
	
	cmp r3, #40
	beq left_paren

operator:
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

insert_right_parent:
	strb r3, [r6, r7]
	add r7, r7, #1
	ldr r2, ptr_prev_was_paren
	ldr r0, [r2]
	mov r1, #0
	str r1, [r2]
	cmp r0, #0
	beq scan_num	
insert_op:
	strb r3, [r6, r7]
	add r7, r7, #1
	ldr r2, ptr_prev_was_paren
	ldr r0, [r2]
	mov r1, #1
	str r1, [r2]
	cmp r0, #0
	beq scan_num	

	
scan_num:
	mov r3, #0
	sub r1, r5, #1
	add r1, r4, r1
	str r3, [r1]

	ldr r2, ptr_prev_op
	ldr r0, [r2]
	add r0, r0, #1
	str r1, [r2] 

	ldr r1, =in_format
	ldr r2, [r8, r9]
	add r9, r9, #4
	bl sscanf
	cmp r0, #0
	blt error_bad_format
	b read 
	
exit:
	ldr r1, ptr_return
	ldr lr, [r1]
	bx lr

solve:
/* change this to pass r0, r2 to the indices of the left parenthesis */
/*
	ldr r0, ptr_num_array
	mov r1, r0
	ldr r2, ptr_sym_array
	mov r3, r2
	flds s1, [r0] 
	ldr r5, ptr_mult_sign
	ldr r5, [r5]
	ldr r6, ptr_div_sign
	ldr r6, [r6]
	ldr r4, [r2]
	ldr r7, ptr_r_paren
	ldr r7, [r7]
*/
	
/* change increments to r1 and r0 when u switch to d instead of s */
mult_div_loop:
/*
	fcpys s0, s1
	flds s1, [r0, #4]
	add r0, r0, #4
	add r2, r2, #4
	cmp r4, r5 
	beq mult
	cmp r4, r6
	beq div
	fsts s0, [r1]
	str r4, [r3]
	add r1, r1, #4
	add r3, r3, #4
	ldr r4, [r2]
	cmp r4, r7
	beq shifts 
	cmp r4, #0x00
	beq move_on 
	b mult_div_loop
*/
/*
shifts:
	fsts s1, [r1]
	add r1, r1, #4
	
shift_loop:
	add r2, r2, #4
	ldr r4, [r2]
	str r4, [r3]
	add r3, r3, #4
	cmp r4, r7	*/	/* right parenthes */ /*
	beq shift_loop
	cmp r4, #0x00
	beq move_on
	flds s1, [r0, #4]
	add r0, r0, #4
	fsts s1, [r1]
	add r1, r1, #4
	b shift_loop
mult:
move_on:	
*/	
	
.balign 4 
ptr_return: 	.word return

.balign 4
ptr_bot_stack:	.word bot_stack
.balign 4
ptr_flt:	.word flt
	
.balign 4
ptr_other_flt:	.word other_flt
	
.balign 4 
ptr_num_array:	.word num_array
	
.balign 4 
ptr_sym_array:	.word sym_array
	
.balign 4 
ptr_mult_sign: 	.word mult_sign
	
.balign 4 
ptr_div_sign:	.word div_sign
	
.balign 4 
ptr_r_paren:	.word r_paren

.balign 4
ptr_prev_op:	.word prev_op

.balign 4
ptr_prev_was_r_paren:	.word prev_was_r_paren:
