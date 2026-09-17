#include "button.h"
#include "lpc17xx.h"

#include "../led/led.h"

extern unsigned char state;   // 10101010
extern unsigned char taps;		// 00000000
extern int output_bit, edit_mode;	// 1 = edit taps, 0 = measure
extern unsigned char lfsr_step(unsigned char current_state, unsigned char taps, int *output_bit);


void EINT0_IRQHandler (void)	  
{
	
	if (edit_mode) {
		// Toogle bit0
		taps ^= 0x01;
		LED_Out(taps);
	} else {
		// Reset: back to edit mode
		taps = 0x00;
		LED_Out(taps);
		edit_mode = 1;
	}
	//state = 0xAA;
	//LED_Out(state);
  LPC_SC->EXTINT &= (1 << 0);     /* clear pending interrupt         */
}


void EINT1_IRQHandler (void)	  
{
	
	if (edit_mode) {
		// Left shift of taps
		taps <<= 1;
		LED_Out(taps);
	} else {
		// KEY1 -> LFSR go ahead
		state = lfsr_step(state, taps, &output_bit);
		LED_Out(state);
	}
	LPC_SC->EXTINT &= (1 << 1);     /* clear pending interrupt         */
}

void EINT2_IRQHandler (void)	  
{
	
	if (edit_mode) {
		// Switch to measure mode
		edit_mode = 0;
		state = 0xAA;	
		LED_Out(state);
		
		int count = 0;
		unsigned char start_state = state;
		
		do {
			state = lfsr_step(state, taps, &output_bit);
			LED_Out(state);
			count++;
		} while(state!=start_state && state!=0x00 && count<255);
		
		LED_Out(count);		// Shows count on leds (mod 256)
	} else {
		// Measure mode: 
		// KEY -> Switch off all buttons
		LED_Out(0x00);
	}
  LPC_SC->EXTINT &= (1 << 2);     /* clear pending interrupt         */    
}


