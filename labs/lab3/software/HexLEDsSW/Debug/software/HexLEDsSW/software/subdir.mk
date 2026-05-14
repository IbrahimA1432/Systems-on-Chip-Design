################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../software/HexLEDsSW/software/led.c \
../software/HexLEDsSW/software/main.c \
../software/HexLEDsSW/software/seg7.c 

OBJS += \
./software/HexLEDsSW/software/led.o \
./software/HexLEDsSW/software/main.o \
./software/HexLEDsSW/software/seg7.o 

C_DEPS += \
./software/HexLEDsSW/software/led.d \
./software/HexLEDsSW/software/main.d \
./software/HexLEDsSW/software/seg7.d 


# Each subdirectory must supply rules for building sources it contributes
software/HexLEDsSW/software/%.o: ../software/HexLEDsSW/software/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	arm-linux-gnueabihf-gcc -I/usr/local/Quartus-EDS-14.0/embedded/ip/altera/hps/altera_hps/hwlib/include -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


