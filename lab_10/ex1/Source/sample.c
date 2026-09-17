/*----------------------------------------------------------------------------
 * Name:    sample.c
 * Purpose: 
 *		to control led11 and led 10 through EINT buttons (similarly to project 03_)
 *		to control leds9 to led4 by the timer handler (1 second - circular cycling)
 * Note(s): this version supports the LANDTIGER Emulator
 * Author: 	Paolo BERNARDI - PoliTO - last modified 15/12/2020
 *----------------------------------------------------------------------------
 *
 * This software is supplied "AS IS" without warranties of any kind.
 *
 * Copyright (c) 2017 Politecnico di Torino. All rights reserved.
 *----------------------------------------------------------------------------*/

                  
#include <stdio.h>
#include "LPC17xx.h"                    /* LPC17xx definitions                */
#include "led/led.h"
#include "button_EXINT/button.h"
#include "timer/timer.h"

/* Led external variables from funct_led */
extern unsigned char led_value;					/* defined in lib_led								*/
#ifdef SIMULATOR
extern uint8_t ScaleFlag; // <- ScaleFlag needs to visible in order for the emulator to find the symbol (can be placed also inside system_LPC17xx.h but since it is RO, it needs more work)
#endif
/*----------------------------------------------------------------------------
  Main Program
 *----------------------------------------------------------------------------*/
int main (void) {
  	
	SystemInit();  												/* System Initialization (i.e., PLL)  */
  LED_init();                           /* LED Initialization                 */
  BUTTON_init();												/* BUTTON Initialization              */
	//init_timer(0,0x017D7840);							/* TIMER0 Initialization  	*/
	
	init_timer(2, 0, 0, 1, 0x32DCD); 
	init_timer(2, 0, 1, 3, 0x65B9A);
	
	init_timer(3, 0, 0, 1, 0x4C4B4); 
	init_timer(3, 0, 1, 3, 0x98968);
	
																			  /* K = T*Fr = [s]*[Hz] = [s]*[1/s]	  */
																				/* T = K / Fr = 0x017D7840 / 25MHz    */
																				/* T = K / Fr = 25000000 / 25MHz      */
																				/* T = 1s	(one second)   							*/
	//init_timer(0, 0, 1, 1, 0x0bebc20);   /* 500ms  -> only interrupt! */
	
	//init_timer(0, 0, 2, 1, 0x05f5e10);   /* 250ms  -> only interrupt! */
	//init_timer(2, 0, 0, 2,122344);
	//enable_timer(2);
	
	enable_timer(2);
	enable_timer(3);
	LED_On(7);
	LED_On(2);
	
	//LPC_SC->PCON |= 0x1;									/* power-down	mode										*/
	//LPC_SC->PCON &= 0xFFFFFFFFD;						
		
  while (1) {                           /* Loop forever                       */	
		//__ASM("wfi");
  }

}
