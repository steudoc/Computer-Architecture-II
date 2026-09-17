#include "button.h"
#include "lpc17xx.h"

#include "../led/led.h"

extern unsigned char state;
extern unsigned char taps;
extern int output_bit;
extern unsigned char lfsr_step(unsigned char current_state, unsigned char taps, int *output_bit);

void EINT0_IRQHandler (void)	  
{
	// KEY0 -> reset seed
	state = 0xAA;
	LED_Out(state);
  LPC_SC->EXTINT &= (1 << 0);     /* clear pending interrupt         */
}


void EINT1_IRQHandler (void)	  
{
	// KEY1 -> LFSR go ahead
	state = lfsr_step(state, taps, &output_bit);
  LED_Out(state);
	LPC_SC->EXTINT &= (1 << 1);     /* clear pending interrupt         */
}

void EINT2_IRQHandler (void)	  
{
	// KEY -> Switch off all buttons
	LED_Out(0x00);
  LPC_SC->EXTINT &= (1 << 2);     /* clear pending interrupt         */    
}


