.text
.global main
.extern printf
.extern scanf

.data
.balign 4
result_array:	.skip 21
first_word:	.skip 400
second_word:	.skip 400
input_msg_1:	.asciz "Input first string: "
input_msg_2:	.asciz "Input second string: " 
input_format:	.string "%s"
output_msg:	.asciz "The concatenated string is: %s\n"
return: 	.word 0

.balign 4
main:
	ldr r1, ptr_return	/* r1 <- &return */
	str lr, [r1]		/* return <- return address in lr */

	ldr r0, =input_msg_1	/* r0 <- &input_msg_1 This is the first message prompt */ 
	bl printf		/* branches to printf */
	
	ldr r0, =input_format	/* r0 <- &input_format Tells scanf the input format from the user */
	ldr r1, ptr_first_word	/* r1 <- &first_word Tells scanf where to store the char array */
	bl scanf		/* branches to scanf */
	
	ldr r0, ptr_first_word	/* r0 <- &first_word */
	ldr r4, ptr_result	/* r4 <- &result */
	mov r5, #0 		/* r5 <- 0 Offset index */	
	
	b loop1			/* starts loop1 */


init_loop2:
	
	ldr r0, =input_msg_2	/* r0 <- input_msg_2 */
	bl printf		/* branches to printf */
	
	ldr r0, =input_format	/* r0 <- &input_format */ 
	ldr r1, ptr_second_word	/* r1 <- &first_word */
	bl scanf		/* branches to scanf */
	
	ldr r0, ptr_second_word /* r0 <- &second_word */
	mov r1, #0		/* r1 <- 0 Offset for the second input */
	b loop2			/* starts loop2 */

loop1:
	ldrb r2, [r0, r5]	/* r2 <- element in address r0 + r5 */
	cmp r2, #0x00		/* Compares r2 with the null character */
	beq init_loop2 		/* If they are the same start the second loop */
	cmp r5, #10		/* Compares r5 with 10 if they are the same it means that the first input is invalid */
	beq error1		/* Branches to error1 if the first input is invalid */
	str r2, [r4, r5]	/* r4 + r5 <- r2 stores r2 into the result char array with the same offset of r5 */
	add r5, r5, #1 		/* Increment the offset */
	b loop1			/* Loop again */

error1: 
	mov r0, #21		/* r0 <- 21 Error code for error 1 */
	ldr r1, ptr_return	/* r1 <- &return */
	ldr lr, [r1]		/* lr <- element in r1 */
	bx lr			/* exit */

loop2:
	ldrb r2, [r0, r1]
	cmp r2, #0x00	
	beq end
	cmp r1, #10
	beq error2
	str r2, [r4, r5]
	add r5, r5, #1
	add r1, r1, #1
	b loop2

error2:
	mov r0, #22
	ldr r1, ptr_return
	ldr lr, [r1]
	bx lr

end:
	mov r2, #0x00
	str r2, [r4, r5]
	ldr r1, ptr_result 
	ldr r0, =output_msg		
	bl printf
	
	mov r0, r5
	ldr r1, ptr_return
	ldr lr, [r1]
	bx lr
	
ptr_return:	.word return
ptr_result:	.word result_array
ptr_first_word:	.word first_word
ptr_second_word:.word second_word
