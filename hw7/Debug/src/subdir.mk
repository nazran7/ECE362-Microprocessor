################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/chariots-of-fire.c \
../src/main.c \
../src/midi.c \
../src/step.c \
../src/syscalls.c \
../src/system_stm32f0xx.c \
../src/wavetable.c 

OBJS += \
./src/chariots-of-fire.o \
./src/main.o \
./src/midi.o \
./src/step.o \
./src/syscalls.o \
./src/system_stm32f0xx.o \
./src/wavetable.o 

C_DEPS += \
./src/chariots-of-fire.d \
./src/main.d \
./src/midi.d \
./src/step.d \
./src/syscalls.d \
./src/system_stm32f0xx.d \
./src/wavetable.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m0 -mthumb -mfloat-abi=soft -DSTM32 -DSTM32F0 -DSTM32F091RCTx -DDEBUG -DSTM32F091 -DUSE_STDPERIPH_DRIVER -I"/home/shay/a/nfarook/workspace/hw7/StdPeriph_Driver/inc" -I"/home/shay/a/nfarook/workspace/hw7/inc" -I"/home/shay/a/nfarook/workspace/hw7/CMSIS/device" -I"/home/shay/a/nfarook/workspace/hw7/CMSIS/core" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


