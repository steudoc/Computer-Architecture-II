/*----------------------------------------------------------------------------
 * Name:    sample.c
 * Purpose: to control led through EINT buttons 
 *        	- key1 switches on LED10 
 *				  - key2 switches off all LEDs 
 *			    - int0 switches on LED 11
 * Note(s): this version supports the LANDTIGER Emulator
 * Author: 	Paolo BERNARDI - PoliTO - last modified 07/12/2020
 *----------------------------------------------------------------------------
 *
 * This software is supplied "AS IS" without warranties of any kind.
 *
 * Copyright (c) 2017 Politecnico di Torino. All rights reserved.
 *----------------------------------------------------------------------------*/
                  
#include <stdio.h>
#include "LPC17xx.H"                    /* LPC17xx definitions                */
#include "led/led.h"
#include "button_EXINT/button.h"

/* Led external variables from funct_led */
extern unsigned char led_value;					/* defined in funct_led								*/
#ifdef SIMULATOR
extern uint8_t ScaleFlag; // <- ScaleFlag needs to visible in order for the emulator to find the symbol (can be placed also inside system_LPC17xx.h but since it is RO, it needs more work)
#endif

// =========================================================================== 
// ============================= EXERCISE 1.a ================================
// ===========================================================================
unsigned char state = 0xAA;   // 011001101
unsigned char taps = 0x1D;		// 00011101 -> 3, 4, 5, 7
int output_bit;


//extern unsigned char lfsr_step(unsigned char current_state, unsigned char taps, int *output_bit);

/*----------------------------------------------------------------------------
  Main Program
 *----------------------------------------------------------------------------*/
int main (void) {
  
  SystemInit();  												/* System Initialization (i.e., PLL)  */
  LED_init();                           /* LED Initialization                 */
  BUTTON_init();												/* BUTTON Initialization              */
	
	LED_Out(state);
	
  while (1) {                           /* Loop forever                       */	
		__ASM("wfi");												// Wait For Interrupt
  }
	
// =========================================================================== 
// ============================= EXERCISE 1.b ================================
// ===========================================================================
unsigned char state = 0xAA;   // 10101010
unsigned char taps = 0x00;		// 00000000
int output_bit, edit_mode = 1;	// 1 = edit taps, 0 = measure

//extern unsigned char lfsr_step(unsigned char current_state, unsigned char taps, int *output_bit);

/*----------------------------------------------------------------------------
  Main Program
 *----------------------------------------------------------------------------*/
int main (void) {
  
  SystemInit();  												/* System Initialization (i.e., PLL)  */
  LED_init();                           /* LED Initialization                 */
  BUTTON_init();												/* BUTTON Initialization              */
	
	LED_Out(taps);
	
  while (1) {                           /* Loop forever                       */	
		__ASM("wfi");												// Wait For Interrupt
  }

}
