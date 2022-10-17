#include "stm32f0xx.h"

extern int counter;

// Q1
unsigned int recur(unsigned int x) {
        if (x < 3)
                return x;
        if ((x & 0xf) == 0)
                return 1 + recur(x - 1);
        return recur(x >> 1) + 2;
}

// Q2
void enable_portb(void) {
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
}

// Q3
void enable_portc(void) {
    RCC->AHBENR |= RCC_AHBENR_GPIOCEN;
}

// Q4
void setup_pb3() {
    GPIOB->MODER &= ~(0x000000c0);
    GPIOB->MODER |= (0x00000000);
    GPIOB->PUPDR &= ~(0x000000c0);
    GPIOB->PUPDR |= (0x00000080);
}

// Q5
void setup_pb4() {
    GPIOB->MODER &= ~(0x00000300);
    GPIOB->MODER |= (0x00000000);
    GPIOB->PUPDR &= ~(0x00000300);
    GPIOB->PUPDR |= (0x00000000);
}

// Q6
void setup_pc8() {
    GPIOC->MODER &= ~(0x00030000);
    GPIOC->MODER |= (0x00010000);
    GPIOC->OSPEEDR &= ~(0x00030000);
    GPIOC->OSPEEDR |= (0x00030000);
}

// Q7
void setup_pc9() {
    GPIOC->MODER &= ~(0x000c0000);
    GPIOC->MODER |= (0x00040000);
    GPIOC->OSPEEDR &= ~(0x000c0000);
    GPIOC->OSPEEDR |= (0x00040000);
}

// Q8
void action8() {
    int state = (GPIOB->IDR & 0x18);
    if (state == 8){
        GPIOC->ODR &= ~(0x00000100);
        GPIOC->ODR |= (0x00000000);
    }
    else {
        GPIOC->ODR &= ~(0x00000100);
        GPIOC->ODR |= (0x00000100);
    }
}

// Q9
void action9() {
    int state = (GPIOB->IDR & 0x18);
    if (state == 16){
        GPIOC->ODR &= ~(0x00000200);
        GPIOC->ODR |= (0x00000200);
    }
    else {
        GPIOC->ODR &= ~(0x00000200);
        GPIOC->ODR |= (0x00000000);
    }
}

// Q10
void EXTI2_3_IRQHandler() {
    EXTI->PR &= ~(0x00000010);
    EXTI->PR |= (0x00000010);

    counter += 1;
}

// Q11
void enable_exti() {
    RCC->APB2ENR = RCC_APB2ENR_SYSCFGEN;
    SYSCFG->EXTICR[0] &= ~(0x00000f00);
    SYSCFG->EXTICR[0] |= (0x00000100);
    EXTI->IMR = (1 << 2);
    EXTI->RTSR = (1 << 2);
    NVIC->ISER[0] = (1 << EXTI2_3_IRQn);
}

// Q12
void TIM3_IRQHandler() {
        GPIOC->ODR ^= (1 << 9);
        TIM3->SR &= ~(1 << 0);
}

// Q13
void enable_tim3() {
    RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;
    TIM3->PSC = (48000 - 1);
    TIM3->ARR = (250 - 1);
    TIM3->DIER |= (1 << 0);
    NVIC->ISER[0] = (1 << TIM3_IRQn);
    TIM3->CR1 |= (1 << 0);
}
