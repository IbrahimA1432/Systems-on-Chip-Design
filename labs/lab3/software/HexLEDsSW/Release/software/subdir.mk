################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../software/led.c \
../software/main.c \
../software/seg7.c 

OBJS += \
./software/led.o \
./software/main.o \
./software/seg7.o 

C_DEPS += \
./software/led.d \
./software/main.d \
./software/seg7.d 


# Each subdirectory must supply rules for building sources it contributes
software/%.o: ../software/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	arm-linux-gnueabihf-gcc -O3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


