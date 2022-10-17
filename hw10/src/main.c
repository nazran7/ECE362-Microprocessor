#include "stm32f0xx.h"
#include <math.h>
#include <stdint.h>
#define SAMPLES 30
uint16_t array[SAMPLES];

void TIM15_IRQHandler(void) {
    TIM15->SR &= ~TIM_SR_UIF;
}

void setfreq(float fre)
{
   // All of the code for this exercise will be written here.

    RCC->APB2ENR |= RCC_APB2ENR_TIM15EN;
    TIM15->PSC = (1 - 1);
    TIM15->ARR = (48000000/(SAMPLES * floor(fre)) - 1);
    TIM15->DIER |= (1 << 8);
    TIM15->CR2 &= ~TIM_CR2_MMS_0;
    TIM15->CR2 &= ~TIM_CR2_MMS_2;
    TIM15->CR2 |= TIM_CR2_MMS_1;
    TIM15->CR1 |= TIM_CR1_CEN;

    RCC->AHBENR |= RCC_AHBENR_DMA1EN;
    DMA1_Channel5->CCR &= ~DMA_CCR_EN;
    DMA1_Channel5->CPAR = (uint32_t) &(DAC->DHR12R1);
    DMA1_Channel5->CMAR = (uint32_t) (array);
    DMA1_Channel5->CNDTR = SAMPLES;
    DMA1_Channel5->CCR |= DMA_CCR_DIR;
    DMA1_Channel5->CCR |= DMA_CCR_MINC;
    DMA1_Channel5->CCR &= ~(0x00000f00);
    DMA1_Channel5->CCR |= DMA_CCR_MSIZE_0;
    DMA1_Channel5->CCR |= DMA_CCR_PSIZE_0;
    DMA1_Channel5->CCR |= DMA_CCR_CIRC;
    DMA1_Channel5->CCR |= DMA_CCR_EN;

    RCC->APB1ENR |= RCC_APB1ENR_DACEN;
    DAC->CR &= ~DAC_CR_TSEL1;
    DAC->CR |= DAC_CR_TSEL1_1;
    DAC->CR |= DAC_CR_TSEL1_0;
    DAC->CR |= DAC_CR_TEN1;
    DAC->CR |= DAC_CR_EN1;

    for(int x=0; x < SAMPLES; x += 1)
        array[x] = 2048 + 1952 * sin(2 * M_PI * x / SAMPLES);

}

int main(void)
{
    // Uncomment any one of the following calls ...
    setfreq(1920.81);
    //setfreq(1234.5);
    //setfreq(8529.48);
    //setfreq(11039.274);
    //setfreq(92816.14);
}
