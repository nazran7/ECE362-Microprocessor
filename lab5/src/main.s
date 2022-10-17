.cpu cortex-m0
.thumb
.syntax unified

// RCC configuration registers
.equ  RCC,      0x40021000
.equ  AHBENR,   0x014
.equ  GPIOCEN,  0x080000
.equ  GPIOBEN,  0x040000
.equ  GPIOAEN,  0x020000
.equ  APB1ENR,  0x01c
.equ  TIM6EN,   1<<4
.equ  TIM7EN,   1<<5
.equ  TIM14EN,  1<<8

// NVIC configuration registers
.equ NVIC, 0xe000e000
.equ ISER, 0x0100
.equ ICER, 0x0180
.equ ISPR, 0x0200
.equ ICPR, 0x0280
.equ IPR,  0x0400
.equ TIM6_DAC_IRQn, 17
.equ TIM7_IRQn,     18
.equ TIM14_IRQn,    19

// Timer configuration registers
.equ TIM6,   0x40001000
.equ TIM7,   0x40001400
.equ TIM14,  0x40002000
.equ TIM_CR1,  0x00
.equ TIM_CR2,  0x04
.equ TIM_DIER, 0x0c
.equ TIM_SR,   0x10
.equ TIM_EGR,  0x14
.equ TIM_CNT,  0x24
.equ TIM_PSC,  0x28
.equ TIM_ARR,  0x2c

// Timer configuration register bits
.equ TIM_CR1_CEN,  1<<0
.equ TIM_DIER_UDE, 1<<8
.equ TIM_DIER_UIE, 1<<0
.equ TIM_SR_UIF,   1<<0

// GPIO configuration registers
.equ  GPIOC,    0x48000800
.equ  GPIOB,    0x48000400
.equ  GPIOA,    0x48000000
.equ  MODER,    0x0
.equ  PUPDR,    0xc
.equ  IDR,      0x10
.equ  ODR,      0x14
.equ  BSRR,     0x18
.equ  BRR,      0x28

//============================================================================
// enable_ports() {
// Set up the ports and pins exactly as directed.
// }
.global enable_ports
enable_ports:
	push {lr}
	ldr  r0,=RCC
    ldr  r1,[r0,#AHBENR]
    ldr r2, =GPIOCEN
    orrs r2, r1
    str r2, [r0, #AHBENR] //enables clock GPIOC

    ldr  r0,=RCC
    ldr  r1,[r0,#AHBENR]
    ldr r2, =GPIOBEN
    orrs r2, r1
    str r2, [r0, #AHBENR] //enables clock GPIOB

	ldr r0, =GPIOB
    ldr r1, [r0, #MODER]
    ldr r2, = 0x003fffff
    bics r1, r2
    ldr r2, =0x00155555
    orrs r1, r2
    str r1, [r0, #MODER] //PB0 – PB10 to be outputs

	ldr r0, =GPIOC
    ldr r1, [r0, #MODER]
    ldr r2, = 0x0003ff00
    bics r1, r2
    ldr r2, =0x00015500
    orrs r1, r2
    str r1, [r0, #MODER] //PC4 – PC8 to be outputs

	ldr r0, =GPIOC
    ldr r1, [r0, #MODER]
    ldr r2, = 0x000000ff
    bics r1, r2
    ldr r2, =0x00000000
    orrs r1, r2
    str r1, [r0, #MODER] //PC0 – PC3 to be inputs

    ldr r1, [r0, #PUPDR]
    ldr r2, = 0x000000ff
    bics r1, r2
    ldr r2, =0x000000aa
    orrs r1, r2
    str r1, [r0, #PUPDR] //PC0 – PC3 to be internally pulled low
    pop {pc}

//============================================================================
// TIM6_ISR() {
//   TIM6->SR &= ~TIM_SR_UIF
//   if (GPIOC->ODR & (1<<8))
//     GPIOC->BRR = 1<<8;
//   else
//     GPIOC->BSRR = 1<<8;
// }
.type TIM6_DAC_IRQHandler, %function
.global TIM6_DAC_IRQHandler
TIM6_DAC_IRQHandler:
	push {lr}
	ldr r0, =TIM6
	ldr r1, [r0, #TIM_SR]
	ldr r2, =TIM_SR_UIF
	mvns r2, r2
	ands r2, r1
	str r2, [r0, #TIM_SR]

	ldr r0, =GPIOC
	ldr r1, [r0, #ODR]
	movs r2, #1
	lsls r2, #8
	ands r1, r2
if:
	cmp r1, #0
	beq else
	str r2, [r0, #BRR]
	b endif
else:
	str r2, [r0, #BSRR]
endif:
	pop {pc}



//============================================================================
// Implement the setup_tim6 subroutine below.  Follow the instructions in the
// lab text.
.global setup_tim6
setup_tim6:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =TIM6EN
	orrs r1,r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM6
	ldr r1, =48000-1
	str r1, [r0, #TIM_PSC]

	ldr r1, =500-1
	str r1, [r0, #TIM_ARR]

	ldr r1, [r0, #TIM_DIER]
	ldr r2, =TIM_DIER_UIE
	orrs r1, r2
	str r1, [r0, #TIM_DIER]

	ldr r1, [r0, #TIM_CR1]
	ldr r2, =TIM_CR1_CEN
	orrs r1, r2
	str r1, [r0, #TIM_CR1]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =(1<<TIM6_DAC_IRQn)
	str r2, [r0, r1]

	pop {pc}

//============================================================================
// void show_char(int col, char ch) {
//   GPIOB->ODR = ((col & 7) << 8) | font[ch];
// }
.global show_char
show_char:
	push {lr}
	movs r2, #7
	ands r0, r2
	lsls r0, #8
	ldr r2, =font
	ldrb r3, [r2, r1]
	orrs r0, r3
	ldr r2, =GPIOB
	str r0, [r2, #ODR]
	pop {pc}
//============================================================================
// nano_wait(int x)
// Wait the number of nanoseconds specified by x.
.global nano_wait
nano_wait:
	subs r0,#83
	bgt nano_wait
	bx lr

//============================================================================
// This function is provided for you to fill the LED matrix with AbCdEFg.
// It is a very useful function.  Study it carefully.
.global fill_alpha
fill_alpha:
	push {r4,r5,lr}
	movs r4,#0
fillloop:
	movs r5,#'A' // load the character 'A' (integer value 65)
	adds r5,r4
	movs r0,r4
	movs r1,r5
	bl   show_char
	adds r4,#1
	movs r0,#7
	ands r4,r0
	ldr  r0,=1000000
	bl   nano_wait
	b    fillloop
	pop {r4,r5,pc} // not actually reached

//============================================================================
// void drive_column(int c) {
//   c = c & 3;
//   GPIOC->BSRR = 0xf00000 | (1 << (c + 4));
// }
.global drive_column
drive_column:
	push {lr}
	movs r1, #3
	ands r0, r1
	ldr r1, =0xf00000
	movs r2, #1
	adds r0, #4
	lsls r2, r0
	orrs r1, r2
	ldr r2, =GPIOC
	str r1, [r2, #BSRR]
	pop {pc}
//============================================================================
// int read_rows(void) {
//   return GPIOC->IDR & 0xf;
// }
.global read_rows
read_rows:
	push {lr}
	ldr r0, =GPIOC
	ldr r1, [r0, #IDR]
	ldr r2, =0xf
	ands r1, r2
	movs r0, r1
	pop {pc}

//============================================================================
// char rows_to_key(int rows) {
//   int n = (col & 0x3) * 4; // or int n = (col << 30) >> 28;
//   do {
//     if (rows & 1)
//       break;
//     n ++;
//     rows = rows >> 1;
//   } while(rows != 0);
//   char c = keymap[n];
//   return c;
// }
.global rows_to_key
rows_to_key:
	push {lr}
	ldr r1, =col
	ldrb r2, [r1]
	ldr r1, =0x3
	ands r1, r2
	movs r2, #4
	muls r1, r2 //n
do:
if1:
	movs r2, #1
	ands r2, r0
	cmp r2, #0
	beq endif1
then:
	b enddo
endif1:
	adds r1, #1
	lsrs r0, #1
while:
	cmp r0, #0
	bne do
enddo:
	ldr r3, =keymap
	ldrb r0, [r3, r1]

	pop {pc}

//============================================================================
// TIM7_ISR() {
//    TIM7->SR &= ~TIM_SR_UIF
//    int rows = read_rows();
//    if (rows != 0) {
//        char key = rows_to_key(rows);
//        handle_key(key);
//    }
//    char ch = disp[col];
//    show_char(col, ch);
//    col = (col + 1) & 7;
//    drive_column(col);
// }

.type TIM7_IRQHandler, %function
.global TIM7_IRQHandler
TIM7_IRQHandler:
	push {lr}
	ldr r0, =TIM7
	ldr r1, [r0, #TIM_SR]
	ldr r2, =TIM_SR_UIF
	mvns r2, r2
	ands r2, r1
	str r2, [r0, #TIM_SR] //acknowledge the timer interrupt

	bl read_rows
if_1:
	cmp r0, #0
	beq endif_1
then_1:
	bl rows_to_key
	bl handle_key
endif_1:
	ldr r1, =col
	ldrb r1, [r1] //col
	ldr r2, =disp
	ldrb r2, [r2, r1] //ch = disp[col]
	movs r3, r1 //copy of col
	movs r0, r1 //col
	movs r1, r2 //ch
	push {r3}
	bl show_char
	pop {r3}
	adds r3, #1
	movs r2, #7
	ands r3, r2 //(col + 1) & 7
	ldr r2, =col
	strb r3, [r2]
	movs r0, r3 //col
	bl drive_column
	pop {pc}


//============================================================================
// Implement the setup_tim7 subroutine below.  Follow the instructions
// in the lab text.
.global setup_tim7
setup_tim7:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =TIM7EN
	orrs r1,r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM7
	ldr r1, =48-1
	str r1, [r0, #TIM_PSC]

	ldr r1, =1000-1
	str r1, [r0, #TIM_ARR]

	ldr r1, [r0, #TIM_DIER]
	ldr r2, =TIM_DIER_UIE
	orrs r1, r2
	str r1, [r0, #TIM_DIER]

	ldr r1, [r0, #TIM_CR1]
	ldr r2, =TIM_CR1_CEN
	orrs r1, r2
	str r1, [r0, #TIM_CR1]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =(1<<TIM7_IRQn)
	str r2, [r0, r1]

	pop {pc}

//============================================================================
// void handle_key(char key)
// {
//     if (key == 'A' || key == 'B' || key == 'D')
//         mode = key;
//     else if (key &gt;= '0' && key &lt;= '9')
//         thrust = key - '0';
// }


//ldr r1, ='A'
//cmp r0, r1

//cmp r0, #65

.global handle_key
handle_key:
	push {lr}
iff:
	cmp r0, #'A'
	beq thenn
	cmp r0, #'B'
	beq thenn
	cmp r0, #'D'
	bne elseiff
thenn:
	ldr r3, =mode
	strb r0, [r3]
	b endiff
elseiff:
	cmp r0, #'0'
	blt endiff
	cmp r0, #'9'
	bgt endiff
thenn2:
	ldr r3, =thrust
	movs r1, #'0'
	subs r0, r1
	strb r0, [r3]
endiff:
	pop {pc}

//============================================================================
// void write_display(void)
// {
//     if (mode == 'C')
//         snprintf(disp, 9, "Crashed");
//     else if (mode == 'L')
//         snprintf(disp, 9, "Landed "); // Note the extra space!
//     else if (mode == 'A')
//         snprintf(disp, 9, "ALt%5d", alt);
//     else if (mode == 'B')
//         snprintf(disp, 9, "FUEL %3d", fuel);
//     else if (mode == 'D')
//         snprintf(disp, 9, "Spd %4d", velo);
// }
.global crashed
crashed:
.string "Crashed"

.global landed
landed:
.string "Landed "

.global alttt
alttt:
.string "ALt%5d"

.global fuelll
fuelll:
.string "FUEL %3d"

.global spddd
spddd:
.string "Spd %4d"

.global write_display
write_display:
	push {lr}
	ldr r0, =mode
	ldrb r1, [r0]
if_one:
	cmp r1, #'C'
	bne if_two
then_one:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =crashed
	bl snprintf
	b end_allif
if_two:
	cmp r1, #'L'
	bne if_three
then_two:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =landed
	bl snprintf
	b end_allif
if_three:
	cmp r1, #'A'
	bne if_four
then_three:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =alttt
	ldr r3, =alt
	ldrh r3, [r3]
	bl snprintf
	b end_allif
if_four:
	cmp r1, #'B'
	bne if_five
then_four:
	ldr r0, =disp
	movs r1, #9
	ldr r2, =fuelll
	ldr r3, =fuel
	ldrh r3, [r3]
	bl snprintf
	b end_allif
if_five:
	cmp r1, #'D'
	bne end_allif
then_five:
	ldr r0, =disp
	ldr r2, =spddd
	ldr r3, =velo
	movs r1, #0
	ldrsh r3, [r3, r1]
	movs r1, #9
	bl snprintf
	b end_allif
end_allif:
	pop {pc}

//============================================================================
// void update_variables(void)
// {
//     fuel -= thrust;
//     if (fuel &lt;= 0) {
//         thrust = 0;
//         fuel = 0;
//     }
//
//     alt += velo;
//     if (alt &lt;= 0) { // we've reached the surface
//         if (-velo &lt; 10)
//             mode = 'L'; // soft landing
//         else
//             mode = 'C'; // crash landing
//         return;
//     }
//
//     velo += thrust - 5;
// }
.global update_variables
update_variables:
	push {lr}
	ldr r0, =fuel
	movs r3, #0
	ldrsh r2, [r0, r3]
	ldr r1, =thrust
	ldrb r3, [r1]
	subs r2, r3
	strh r2, [r0]
if10:
	cmp r2, #0
	bgt endif10
then10:
	movs r3, #0
	strh r3, [r0]
	strb r3, [r1]
endif10:
	ldr r0, =alt
	ldr r1, =velo
	movs r3, #0
	ldrsh r2, [r0, r3] //alt
	ldrsh r3, [r1, r3] //velo
	adds r2, r3
	strh r2, [r0]
if11:
	cmp r2, #0
	bgt endif11
then11:
if12:
	negs r3, r3
	cmp r3, #10
	bge else12
then12:
	ldr r0, =mode
	ldr r1, ='L'
	strb r1, [r0]
	b endif12
else12:
	ldr r0, =mode
	ldr r1, ='C'
	strb r1, [r0]
endif12:
	b end
endif11:
	ldr r0, =velo
	movs r3, #0
	ldrsh r2, [r0, r3]
	ldr r1, =thrust
	ldrb r3, [r1]
	subs r2, #5
	adds r2, r3
	strh r2, [r0]
end:
	pop {pc}

//============================================================================
// TIM14_ISR() {
//    // acknowledge the interrupt
//    update_variables();
//    write_display();
// }
.type TIM14_IRQHandler, %function
.global TIM14_IRQHandler
TIM14_IRQHandler:
	push {lr}
	ldr r0, =TIM14
	ldr r1, [r0, #TIM_SR]
	ldr r2, =TIM_SR_UIF
	mvns r2, r2
	ands r2, r1
	str r2, [r0, #TIM_SR] //acknowledge the timer interrupt

	bl update_variables
	bl write_display

	pop {pc}
//============================================================================
// Implement setup_tim14 as directed.
.global setup_tim14
setup_tim14:
	push {lr}

	ldr r0, =RCC
	ldr r1, [r0, #APB1ENR]
	ldr r2, =TIM14EN
	orrs r1,r2
	str r1, [r0, #APB1ENR]

	ldr r0, =TIM14
	ldr r1, =48000-1
	str r1, [r0, #TIM_PSC]

	ldr r1, =500-1
	str r1, [r0, #TIM_ARR]

	ldr r1, [r0, #TIM_DIER]
	ldr r2, =TIM_DIER_UIE
	orrs r1, r2
	str r1, [r0, #TIM_DIER]

	ldr r1, [r0, #TIM_CR1]
	ldr r2, =TIM_CR1_CEN
	orrs r1, r2
	str r1, [r0, #TIM_CR1]

	ldr r0, =NVIC
	ldr r1, =ISER
	ldr r2, =(1<<TIM14_IRQn)
	str r2, [r0, r1]

	pop {pc}

.global login
login: .string "nfarook" // Replace with your login.
.balign 2

.global main
main:
	//bl check_wiring
	//bl fill_alpha
	//bl autotest
	bl enable_ports
	//bl setup_tim6
	bl setup_tim7
	bl setup_tim14
snooze:
	wfi
	b  snooze
	// Does not return.

//============================================================================
// Map the key numbers in the history array to characters.
// We just use a string for this.
.global keymap
keymap:
.string "DCBA#9630852*741"

//============================================================================
// This table is a *font*.  It provides a mapping between ASCII character
// numbers and the LED segments to illuminate for those characters.
// For instance, the character '2' has an ASCII value 50.  Element 50
// of the font array should be the 8-bit pattern to illuminate segments
// A, B, D, E, and G.  Spread out, those patterns would correspond to:
//   .GFEDCBA
//   01011011 = 0x5b
// Accessing the element 50 of the font table will retrieve the value 0x5b.
//
.global font
font:
.space 32
.byte  0x00 // 32: space
.byte  0x86 // 33: exclamation
.byte  0x22 // 34: double quote
.byte  0x76 // 35: octothorpe
.byte  0x00 // dollar
.byte  0x00 // percent
.byte  0x00 // ampersand
.byte  0x20 // 39: single quote
.byte  0x39 // 40: open paren
.byte  0x0f // 41: close paren
.byte  0x49 // 42: asterisk
.byte  0x00 // plus
.byte  0x10 // 44: comma
.byte  0x40 // 45: minus
.byte  0x80 // 46: period
.byte  0x00 // slash
.byte  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
.byte  0x7f, 0x67
.space 7
// Uppercase alphabet
.byte  0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x6f, 0x76, 0x30, 0x1e, 0x00, 0x38, 0x00
.byte  0x37, 0x3f, 0x73, 0x7b, 0x31, 0x6d, 0x78, 0x3e, 0x00, 0x00, 0x00, 0x6e, 0x00
.byte  0x39 // 91: open square bracket
.byte  0x00 // backslash
.byte  0x0f // 93: close square bracket
.byte  0x00 // circumflex
.byte  0x08 // 95: underscore
.byte  0x20 // 96: backquote
// Lowercase alphabet
.byte  0x5f, 0x7c, 0x58, 0x5e, 0x79, 0x71, 0x6f, 0x74, 0x10, 0x0e, 0x00, 0x30, 0x00
.byte  0x54, 0x5c, 0x73, 0x7b, 0x50, 0x6d, 0x78, 0x1c, 0x00, 0x00, 0x00, 0x6e, 0x00
//.byte 0x44 // added later
.balign 2

//============================================================================
// Data structures for this experiment.
//
.data
.global col
.global disp
.global mode
.global thrust
.global fuel
.global alt
.global velo
disp: .string "Hello..."
col: .byte 0
mode: .byte 'A'
thrust: .byte 0
.balign 4
.hword 0 // put this here to make sure next hword is not word-aligned
fuel: .hword 800
.hword 0 // put this here to make sure next hword is not word-aligned
alt: .hword 4500
.hword 0 // put this here to make sure next hword is not word-aligned
velo: .hword 0
