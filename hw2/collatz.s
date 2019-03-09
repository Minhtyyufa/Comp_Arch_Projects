/* 
	Minh-Thai Nguyen
	3/8/2019
	This program performs the Collatz conjecture and returns how many iterations it takes to reach 1
*/

.text

/* Make sure everything is 4 byte aligned */
.balign 4
.global main

/* main initializes the parameters for this program */
main: 
	mov r2, #0	/* The counter for the loop. Initialized to 0 */
	mov r0, #123	/* The input number for the Collatz conjecture. 123 for this case */
	b odd_or_even	/* Starts by calling the function that determines if something is even or odd */
	
/* odd_or_even determines whether r0 is even or odd, branching to the appropriate fcn*/
odd_or_even:
	ror r1, r0, #1	/* Rotating r0 to the right by 1 and moving the value to r1. This shifts the lsb to the signed bit */
	cmp r1, #0	/* r1 - 0 */
	blt odd		/* If r1 is negative r0 is odd, calls the function for odd values */
	b even 		/* If r1 is positive r0 is even, calls the function for even values */

/* odd: r0 = 3*r0 +1 */
odd:
	cmp r0, #1	/* If the value is one then the process is over */
	beq end		/* Calls end when r0 reaches 1 */
	add r2, r2, #1	/* Increment the loop counter */
	add r0, r0, r0 , lsl #1	/* r0 = r0 + 2*r0 */
	add r0, #1	/* r0 = r0 + 1 */
	b odd_or_even	/* Calls odd_or_even */

/* even: r0 = r0/2 */
even:
	mov r0, r0, lsr #1	/* r0 = r0/2 through a bit shift to the right */
	add r2, r2, #1		/* Increment the loop counter */
	b odd_or_even		/* Calls odd_or_even */

/* ends the program */
end:
	mov r0, r2	/* r0 <- r2 */
	bx lr		/* exits */
