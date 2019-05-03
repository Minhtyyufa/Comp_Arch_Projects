/* 
	Minh-Thai Nguyen
	3/8/2019
	This program calculates the 10th number in the fibonnaci sequence
*/

.data
.balign 4
element1:
	.word 1	/* Memory for an element in the fib sequence */

.balign 4
element2:
	.word 1	/* Memory for an element in the fib sequence */
.text
.balign 4
.global main

main:
	ldr r0, addr_of_el1	/* r0 <- &element1 */
	ldr r1, addr_of_el2	/* r1 <- &element2 */	
	mov r2, #3 		/* r2 = 3 This keeps track of where we are in the sequence */
	b loop1

loop1:
	cmp r2, #10	/* r2 - 10 */
	bgt exit	/* If tenth number, branch to exit */
	ldr r3, [r0]	/* r3 = element1 */
	ldr r4, [r1]	/* r4 = element 2 */
	str r3, [r1]	/* element2 = element1 */
	add r3, r4, r3	/* r3 = r4 + r3 */
	str r3, [r0]	/* element1 = r3 */
	add r2, r2, #1 	/* r2 = r2 + 1 Increment the counter */
	b loop1		/* loop */

exit:
	ldr r0, [r0]	/* returns element1 */
	bx lr		/* exits */	

/* addresses of elements 1 and 2 */
addr_of_el1: .word element1
addr_of_el2: .word element2
