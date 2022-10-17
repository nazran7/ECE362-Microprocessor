.syntax unified
.cpu cortex-m0
.fpu softvfp
.thumb

//==================================================================
// ECE 362 Lab Experiment 3
// General Purpose I/O
//==================================================================

.equ  RCC,      0x40021000
.equ  AHBENR,   0x014
.equ  GPIOAEN,  0x20000
.equ  GPIOBEN,  0x40000
.equ  GPIOCEN,  0x80000
.equ  GPIOA,    0x48000000
.equ  GPIOB,    0x48000400
.equ  GPIOC,    0x48000800
.equ  MODER,    0x00
.equ  PUPDR,    0x0c
.equ  IDR,      0x10
.equ  ODR,      0x14
.equ  BSRR,     0x18
.equ  BRR,      0x28

//==========================================================
// initb:
// Enable Port B in the RCC AHBENR register and configure
// the pins as described in section 2.1 of the lab
// No parameters.
// No expected return value.
.global initb
initb:
    push    {lr}
    // Student code goes here
	ldr  r0,=RCC
    ldr  r1,[r0,#AHBENR]
    ldr r2, =GPIOBEN
    orrs r2, r1
    str r2, [r0, #AHBENR]

    ldr r0, =GPIOB
    ldr r1, [r0, #MODER]
    ldr r2, = 0x00ff0303
    bics r1, r2
    ldr r2, =0x00550000
    orrs r1, r2
    str r1, [r0, #MODER]
    // End of student code
    pop     {pc}

//==========================================================
// initc:
// Enable Port C in the RCC AHBENR register and configure
// the pins as described in section 2.2 of the lab
// No parameters.
// No expected return value.
.global initc
initc:
    push    {lr}
    // Student code goes here
	ldr  r0,=RCC
    ldr  r1,[r0,#AHBENR]
    ldr r2, =GPIOCEN
    orrs r2, r1
    str r2, [r0, #AHBENR]

    ldr r0, =GPIOC
    ldr r1, [r0, #MODER]
    ldr r2, = 0x0000ffff
    bics r1, r2
    ldr r2, =0x00005500
    orrs r1, r2
    str r1, [r0, #MODER]

    ldr r1, [r0, #PUPDR]
    ldr r2, = 0x000000ff
    bics r1, r2
    ldr r2, =0x000000aa
    orrs r1, r2
    str r1, [r0, #PUPDR]

    // End of student code
    pop     {pc}

//==========================================================
// setn:
// Set given pin in GPIOB to given value in ODR
// Param 1 - pin number
// param 2 - value [zero or non-zero]
// No expected retern value.
.global setn
setn:
    push    {r1-r7,lr}
    // Student code goes here
if:
    cmp r1, #0
    beq else
then:
	ldr r1, =GPIOB
	movs r3, #1
	lsls r3, r3, r0
	str r3, [r1, #BSRR]
	b endif
else:
	ldr r1, =GPIOB
	movs r3, #1
	lsls r3, r3, r0
	str r3, [r1, #BRR]
endif:
    // End of student code
    pop     {r1-r7, pc}

//==========================================================
// readpin:
// read the pin given in param 1 from GPIOB_IDR
// Param 1 - pin to read
// No expected return value.
.global readpin
readpin:
    push    {lr}
    // Student code goes here
	ldr r1, =GPIOB
	ldr r2, [r1, #IDR]
	movs r3, #1
	lsls r3, r3, r0
	ands r3, r2
if1:
	cmp r3, #0
	ble else1
then1:
	movs r0, #0x1
	b endif1
else1:
	movs r0, #0x0
endif1:
    // End of student code
    pop     {pc}

//==========================================================
// buttons:
// Check the pushbuttons and turn a light on or off as
// described in section 2.6 of the lab
// No parameters.
// No return value
.global buttons
buttons:
    push    {lr}
    // Student code goes here
	movs r0, #0
	bl readpin
	movs r1, r0
	movs r0, #8
	bl setn

	movs r0, #4
	bl readpin
	movs r1, r0
	movs r0, #9
	bl setn

    // End of student code
    pop     {pc}

//==========================================================
// keypad:
// Cycle through columns and check rows of keypad to turn
// LEDs on or off as described in section 2.7 of the lab
// No parameters.
// No expected return value.
.global keypad
keypad:
    push    {r1-r7, lr}
    // Student code goes here
	movs r0, #8 //c
for:
	cmp r0, #0
	ble endfor
	movs r6, r0 //copy c
	lsls r6, #4 //c << 4
	ldr r1, =GPIOC
	str r6, [r1, #ODR]
	bl mysleep
	movs r2, #0xf
	ldr r1, =GPIOC
	ldr r3, [r1, #IDR]
	ands r3, r2 //r
if_1:
	cmp r0, #8
	beq then_1
	cmp r0, #4
	beq else_1
	cmp r0, #2
	beq else_2
else_3:
	movs r4, r0 //copy c
	movs r0, #11
	movs r1, #8
	ands r1, r3 //r & 8
	bl setn
	movs r0, r4 //retireves original value of c
	b endif_1
then_1:
	movs r4, r0 //copy c
	movs r0, #8
	movs r1, #1
	ands r1, r3 //r & 1
	bl setn
	movs r0, r4 //retireves original value of c
	b endif_1
else_1:
	movs r4, r0 //copy c
	movs r0, #9
	movs r1, #2
	ands r1, r3 //r & 2
	bl setn
	movs r0, r4 //retireves original value of c
	b endif_1
else_2:
	movs r4, r0 //copy c
	movs r0, #10
	movs r1, #4
	ands r1, r3 //r & 4
	bl setn
	movs r0, r4 //retireves original value of c
	b endif_1

endif_1:
	lsrs r0, #1 // c>>1
	b for
endfor:
    // End of student code
    pop     {r1-r7, pc}

//==========================================================
// mysleep:
// a do nothing loop so that row lines can be charged
// as described in section 2.7 of the lab
// No parameters.
// No expected return value.
.global mysleep
mysleep:
    push    {r0-r7,lr}
    // Student code goes here
	movs r0, #0
	ldr r1, =1000
for1:
	cmp r0, r1
	bge done1
do1: //nothing
	adds r0, #1 //increment
	b for1
done1:
    // End of student code
    pop     {r0-r7,pc}

//==========================================================
// The main subroutine calls everything else.
// It never returns.
.global main
main:
    push {lr}
    bl   autotest // Uncomment when most things are working
    bl   initb
    bl   initc
// uncomment one of the loops, below, when ready
//loop1:
//    bl   buttons
//    b    loop1
loop2:
    bl   keypad
    b    loop2

    wfi
    pop {pc}
