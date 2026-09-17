/*********************************************************************************************************
**--------------File Info---------------------------------------------------------------------------------
** File name:           IRQ_timer.c
** Last modified Date:  2014-09-25
** Last Version:        V1.00
** Descriptions:        functions to manage T0 and T1 interrupts
** Correlated files:    timer.h
**--------------------------------------------------------------------------------------------------------
*********************************************************************************************************/
#include "LPC17xx.h"
#include "timer.h"
#include "../led/led.h"

/******************************************************************************
** Function name:		Timer0_IRQHandler
**
** Descriptions:		Timer/Counter 0 interrupt handler
**
** parameters:			None
** Returned value:		None
**
******************************************************************************/
extern unsigned char led_value;					/* defined in funct_led								*/
void TIMER0_IRQHandler (void)
{
	static uint8_t position = 7;
	int tmp_leds=0;
	tmp_leds = led_value; 
	/* Match register 0 interrupt service routine */
	if (LPC_TIM0->IR & 01)
	{
		//LED_Off(position);
		tmp_leds = tmp_leds &  ~(1<<position);
		if(position == 7)
			position = 2;
		else
			position++;
		tmp_leds = tmp_leds | 1<<position;
//		LED_On(position);
		/* alternatively to LED_On and LED_off try to use LED_Out */
		//LED_Out((1<<position)|(led_value & 0x3));							
		/* LED_Out is CRITICAL due to the shared led_value variable */
		/* LED_Out MUST NOT BE INTERRUPTED */
		
		LPC_TIM0->IR = 1;			/* clear interrupt flag */
	}
		/* Match register 1 interrupt service routine */
	  /* it should be possible to access to both interrupt requests in the same procedure*/
	else if(LPC_TIM0->IR & 02)
  {
		//led_value ^= 2;
		tmp_leds ^= 2;
//		LED_Out(led_value);
	  if(LPC_TIM0->MR1 ==0x0bebc20 ) /* No check with the higher value (17D7840) since this may change to 0*/ 
		{  
			 LPC_TIM0->MR1 = 0x017D7840;
		}
		else
		{ 
			 LPC_TIM0->MR1 = 0x0bebc20;
		}

		LPC_TIM0->IR =  2 ;			/* clear interrupt flag */	
	}
	/* Match register 2 interrupt service routine */
  /* it should be possible to access to both interrupt requests in the same procedure*/
	else if(LPC_TIM0->IR & 4)
  {
		//led_value ^= 1;
		tmp_leds ^= 1;
		
		// LED_Out(led_value);
		LPC_TIM0->MR2 += 0x05f5e10;
	  if(LPC_TIM0->MR2 > 0x017D7840)
		{  
			 LPC_TIM0->MR2 = 0x05f5e10;
		}	
		
		LPC_TIM0->IR =  4 ;			/* clear interrupt flag */	
	}
		/* Match register 3 interrupt service routine */
  	/* it should be possible to access to both interrupt requests in the same procedure*/
	else if(LPC_TIM0->IR & 8)
  {
	 
		LPC_TIM0->IR =  8 ;			/* clear interrupt flag */	
	}
	LED_Out(tmp_leds);
  return;
}


/******************************************************************************
** Function name:		Timer1_IRQHandler
**
** Descriptions:		Timer/Counter 1 interrupt handler
**
** parameters:			None
** Returned value:		None
**
******************************************************************************/
void TIMER1_IRQHandler (void)
{
  LPC_TIM1->IR = 1;			/* clear interrupt flag */
  return;
}

/******************************************************************************
** Function name:		Timer2_IRQHandler
**
** Descriptions:		Timer/Counter 2 interrupt handler
**
** parameters:			None
** Returned value:		None
**
******************************************************************************/
void TIMER2_IRQHandler(void)
{

    /* Match register 0 interrupt:  LED off */
    if (LPC_TIM2->IR & 1)
    {
        LED_Off(7);
        LPC_TIM2->IR = 1;        // clear interrupt flag
    }

    /* Match register 1 interrupt: LED on */
    else if (LPC_TIM2->IR & 2)
    {
        LED_On(7);
        LPC_TIM2->IR = 2;        // clear interrupt flag
    }

		return;
}

void TIMER3_IRQHandler(void)
{

    /* Match register 0 interrupt:  LED off */
    if (LPC_TIM3->IR & 1)
    {
        LED_Off(2);
        LPC_TIM3->IR = 1;        // clear interrupt flag
    }

    /* Match register 1 interrupt: LED on */
    else if (LPC_TIM3->IR & 2)
    {
        LED_On(2);
        LPC_TIM3->IR = 2;        // clear interrupt flag
    }

		return;
}






/******************************************************************************
**                            End Of File
******************************************************************************/
