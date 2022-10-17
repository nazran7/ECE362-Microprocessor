.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.data
.balign 4
// Your global variables go here
.global arr
arr: .word 14, 15, 18, 12, 7, 11, 16, 24, 22, 15, 23, 21, 13, 15, 24, 17
.global value
value: .word 0
.global str
str: .string "HeLlO, 98765 WoRlD! 43210 InTeReStInG!"


.text
.global intsub
intsub:
	PUSH {R4-R7,LR}
    // Your code for intsub goes here
for1:
	movs r0, #0 // initiating i
	movs r1, #15 //for loop ends at
check1:
	cmp r0, r1 // i < 15?
	bge endfor1
body1:
if1:
	movs r2, #1 // constant 1 for and
	ands r2, r0
	cmp r2, #1
	bne else1 //if and condition not met
then1:
	ldr r3, =arr //address of arr[i]
	lsls r4, r0, #2 //muliply by 4
	ldr r5, [r3, r4] //arr[i]
	adds r4, #4
	ldr r2, [r3, r4] //arr[i+1]
	ldr r3, =value //address of value
	ldr r6, [r3] //value
	muls r5, r2, r5
	adds r6, r5
	str r6, [r3]
	b endif1

else1:
	ldr r3, =arr //address of arr[i]
	lsls r4, r0, #2 //muliply by 4
	ldr r5, [r3, r4] //arr[i]
	adds r4, #4
	ldr r2, [r3, r4] //arr[i+1]
	ldr r3, =value //address of value
	ldr r6, [r3] //value
	movs r7, #3
	muls r5, r7
	adds r6, r5
	str r6, [r3]
	b endif1
endif1:
	ldr r3, =arr //address of arr[i]
	lsls r4, r0, #2 //muliply by 4
	ldr r5, [r3, r4] //arr[i]
	adds r4, #4
	ldr r2, [r3, r4] //arr[i+1]
	adds r5, r2
	subs r4, #4
	str r5, [r3, r4]
	adds r0, #1 //i++
	b check1

endfor1:
    // You must terminate your subroutine with bx lr
    // unless you know how to use PUSH and POP.
    POP {R4-R7,PC}


.global charsub
charsub:
    PUSH {R4-R7,LR}
    // Your code for charsub goes here
for2:
	movs r0, #0 // initiating x
	ldr r1, =str //address of string
check2:
	ldrb r3, [r1, r0] //loads one letter from string
	cmp r3, #0 // str[x] != '\0'
	beq endfor2
body2:
if2:
	movs r4, #0x20 //0x20
	mvns r4, r4 //~0x20
	ands r4, r3 //str[x] & ~0x20
	cmp r4, #0x41 //A
	blt else2
	cmp r4, #0x5a//Z
	bgt endif2
then2:
	movs r5, #0x20
	eors r3, r5
	strb r3, [r1, r0]
else2:

endif2:
	adds r0, #1 //x++
	b check2
endfor2:
    // You must terminate your subroutine with bx lr
    // unless you know how to use PUSH and POP.
    POP {R4-R7,PC}


.global login
login: .string "nfarook" // Make sure you put your login here.
.balign 2
.global main
main:
    bl autotest // uncomment AFTER you debug your subroutines
    bl intsub
    bl charsub
    bkpt
