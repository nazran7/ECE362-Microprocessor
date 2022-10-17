.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.global login
login: .string "nfarook"
hello_str: .string "Hello, %s!\n"
.balign  2
.global hello
hello:
	push {lr}
	ldr r0,=hello_str
	ldr r1, =login
	bl printf
	pop  {pc}

.global sub2_string
sub2_string: .string "%d - %d = %d\n"
.balign 2
.global showsub2
showsub2:
	push {lr}
	subs r3, r0, r1 //a-b
	movs r2, r1//b
	movs r1, r0//a
	ldr r0, =sub2_string
	bl printf
	pop  {pc}

// Add the rest of your subroutines below

//Q3
.global sub3_string
sub3_string: .string "%d - %d - %d = %d\n"
.balign 2
.global showsub3
showsub3:
	push {r5, lr}
	sub sp, #4 //stack
	subs r3, r0, r1 //a-b
	subs r5, r3, r2 //a-b-c
	str r5, [sp, #0]
	movs r3, r2 //c
	movs r2, r1 //b
	movs r1, r0 //a
	ldr r0, =sub3_string //string
	bl printf
	add sp, #4
	pop  {r5, pc}

//Q4
.global list_string
list_string: .string "%s %05d %s %d students in %s, %d\n"
.global listing
listing:
	push {r4-r7, lr}
	ldr r7, [sp, #24]
	ldr r6, [sp, #20]
	sub sp, #12
	str r3, [sp, #0]
	str r6, [sp, #4]
	str r7, [sp, #8]
	movs r3, r2
	movs r2, r1
	movs r1, r0
	ldr r0, =list_string
	bl printf
	add sp, #12
	pop  {r4-r7, pc}

//Q5
.global trivial
trivial:
	push {r4-r7, lr}
	sub sp, #400
	mov r1, sp
	movs r2, #0
	movs r3, #100
for_loop:
	cmp r2, r3
	bge endfor_loop
	lsls r4, r2, #2


do:
endfor_loop:

	pop  {r4-r7, pc}

//Q6
.global depth
depth:
	push {r4-r7, lr}
	movs r4, r0
	movs r5, r1
	movs r0, r1
	bl strlen //strlen(s)
	movs r6, r0 //copies length to r5
if:
	cmp r4, #0
	beq endif
then:
	movs r0, r5
	bl puts
	subs r0, r4, #1
	movs r1, r5
	bl depth
	adds r0, r6
	b endif1
endif:
	movs r0, r6
endif1:
	pop  {r4-r7, pc}

//Q7
.global collatz
collatz:
	push {lr}

	pop  {pc}

//Q8
.global permute
permute:
	push {lr}

	pop  {pc}

//Q9
.global bizarre
bizarre:
	push {lr}

	pop  {pc}

//Q10
.global easy
easy:
	push {lr}

	pop  {pc}
