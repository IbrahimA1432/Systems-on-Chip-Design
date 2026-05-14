#include "led.h"
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include <stdint.h>

extern volatile uint32_t *h2p_lw_led_addr;

void LEDR_LightCount(unsigned char LightCount){ // 1: light, 0:unlight
    uint32_t Mask = 0;
    int i;
    for(i=0;i<LightCount;i++){
        Mask <<= 1;
        Mask |= 0x01;
    }
    
    alt_write_word(h2p_lw_led_addr, Mask );  //0:ligh, 1:unlight
}

void LEDR_OffCount(unsigned char OffCount){ // 1: light, 0:unlight
    uint32_t Mask = 0x03ff;
    int i;
    for(i=0;i<OffCount;i++){
        Mask >>= 1;
    }
   
    alt_write_word(h2p_lw_led_addr, Mask );  //0:ligh, 1:unlight
}

void LEDR_AllOn(void){

	alt_write_word(h2p_lw_led_addr, 0x3FF);  //0:ligh, 1:unlight
	
}

void LEDR_AllOff(void){

	alt_write_word(h2p_lw_led_addr, 0x00);  //0:ligh, 1:unlight
	
}
