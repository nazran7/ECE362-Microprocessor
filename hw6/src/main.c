/**
  ******************************************************************************
  * @file    main.c
  * @author  Ac6
  * @version V1.0
  * @date    01-December-2013
  * @brief   Default main function.
  ******************************************************************************
*/


#include "stm32f0xx.h"
#include <string.h>


const char font[] = {
        [' '] = 0x00,
        ['0'] = 0x3f,
        ['1'] = 0x06,
        ['2'] = 0x5b,
        ['3'] = 0x4f,
        ['4'] = 0x66,
        ['5'] = 0x6d,
        ['6'] = 0x7d,
        ['7'] = 0x07,
        ['8'] = 0x7f,
        ['9'] = 0x67,
        ['A'] = 0x77,
        ['B'] = 0x7c,
        ['C'] = 0x39,
        ['D'] = 0x5e,
        ['*'] = 0x49,
        ['#'] = 0x76,
        ['.'] = 0x80,
        ['?'] = 0x53,
        ['b'] = 0x7c,
        ['r'] = 0x50,
        ['g'] = 0x6f,
        ['i'] = 0x10,
        ['n'] = 0x54,
        ['u'] = 0x1c,
};

int hrs = 12;
int min = 06;
int sec = 30;
int eighth;

uint16_t digit[8*4];

void setup_dma(void) {
    RCC->AHBENR |= RCC_AHBENR_DMAEN;
    DMA1_Channel2->CMAR = (uint32_t) &(digit);
    DMA1_Channel2->CPAR = (uint32_t) &(GPIOB->ODR);
    DMA1_Channel2->CNDTR = 8*4;
    DMA1_Channel2->CCR |= DMA_CCR_DIR;
    DMA1_Channel2->CCR &= ~(0x00000f00);
    DMA1_Channel2->CCR |= (0x00000500);
    DMA1_Channel2->CCR |= DMA_CCR_MINC;
    DMA1_Channel2->CCR |= DMA_CCR_CIRC;
    DMA1_Channel2->CCR |= DMA_CCR_EN;
}

void init_tim2(void){
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;
    TIM2->PSC = (48 - 1);
    TIM2->ARR = (125 - 1);
    TIM2->DIER |= (1 << 8);
    TIM2->CR1 |= TIM_CR1_CEN;
}

void TIM6_DAC_IRQHandler(void) {
    TIM6->SR &= ~(1 << 0);
    eighth += 1;
    if (eighth >= 8) { eighth -= 8; sec += 1; }
    if (sec >= 60)   { sec -= 60;   min += 1; }
    if (min >= 60)   { min -= 60;   hrs += 1; }
    if (hrs >= 24)   { hrs -= 24; }
    char time[8];
    sprintf(time, "%02d%02d%02d  ", hrs, min, sec);
    set_string(time);
    if (eighth > 0 && eighth < 4) {
        memcpy(&digit[8*eighth], digit, 2*8);
    }
}

void init_tim6(void)
{
    RCC->APB1ENR |= RCC_APB1ENR_TIM6EN;
    TIM6->PSC = (48000 - 1);
    TIM6->ARR = (125 - 1);
    TIM6->DIER |= (1 << 0);
    TIM6->CR1 |= TIM_CR1_CEN;
    NVIC->ISER[0] = (1 << TIM6_DAC_IRQn);
}


void set_digit(int n, char c)
{
    digit[n] = (n<<8) | font[c];
}

void set_string(const char *s)
{
    for(int n=0; s[n] != '\0'; n++)
        set_digit(n,s[n]);
}

int main(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
    GPIOB->MODER |= 0x155555;
    set_string("running.");

    setup_dma();
    init_tim2();
    init_tim6();

    // display loop
    for(;;) {
        for(int x=0; x < 8; x++) {
            GPIOB->ODR = digit[x];
            for(int n=0; n < 100; n++);
        }
    }

}
