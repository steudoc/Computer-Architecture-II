;/**************************************************************************//**
; * @file     startup_LPC17xx.s
; * @brief    CMSIS Cortex-M3 Core Device Startup File for
; *           NXP LPC17xx Device Series
; * @version  V1.10
; * @date     06. April 2011
; *
; * @note
; * Copyright (C) 2009-2011 ARM Limited. All rights reserved.
; *
; * @par
; * ARM Limited (ARM) is supplying this software for use with Cortex-M
; * processor based microcontrollers.  This file can be freely distributed
; * within development tools that are supporting such ARM based processors.
; *
; * @par
; * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
; * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
; * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
; * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
; *
; ******************************************************************************/

; *------- <<< Use Configuration Wizard in Context Menu >>> ------------------

; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00000200

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00000200

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3	; 2*3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     MemManage_Handler         ; MPU Fault Handler
                DCD     BusFault_Handler          ; Bus Fault Handler
                DCD     UsageFault_Handler        ; Usage Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     DebugMon_Handler          ; Debug Monitor Handler
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                ; External Interrupts
                DCD     WDT_IRQHandler            ; 16: Watchdog Timer
                DCD     TIMER0_IRQHandler         ; 17: Timer0
                DCD     TIMER1_IRQHandler         ; 18: Timer1
                DCD     TIMER2_IRQHandler         ; 19: Timer2
                DCD     TIMER3_IRQHandler         ; 20: Timer3
                DCD     UART0_IRQHandler          ; 21: UART0
                DCD     UART1_IRQHandler          ; 22: UART1
                DCD     UART2_IRQHandler          ; 23: UART2
                DCD     UART3_IRQHandler          ; 24: UART3
                DCD     PWM1_IRQHandler           ; 25: PWM1
                DCD     I2C0_IRQHandler           ; 26: I2C0
                DCD     I2C1_IRQHandler           ; 27: I2C1
                DCD     I2C2_IRQHandler           ; 28: I2C2
                DCD     SPI_IRQHandler            ; 29: SPI
                DCD     SSP0_IRQHandler           ; 30: SSP0
                DCD     SSP1_IRQHandler           ; 31: SSP1
                DCD     PLL0_IRQHandler           ; 32: PLL0 Lock (Main PLL)
                DCD     RTC_IRQHandler            ; 33: Real Time Clock
                DCD     EINT0_IRQHandler          ; 34: External Interrupt 0
                DCD     EINT1_IRQHandler          ; 35: External Interrupt 1
                DCD     EINT2_IRQHandler          ; 36: External Interrupt 2
                DCD     EINT3_IRQHandler          ; 37: External Interrupt 3
                DCD     ADC_IRQHandler            ; 38: A/D Converter
                DCD     BOD_IRQHandler            ; 39: Brown-Out Detect
                DCD     USB_IRQHandler            ; 40: USB
                DCD     CAN_IRQHandler            ; 41: CAN
                DCD     DMA_IRQHandler            ; 42: General Purpose DMA
                DCD     I2S_IRQHandler            ; 43: I2S
                DCD     ENET_IRQHandler           ; 44: Ethernet
                DCD     RIT_IRQHandler            ; 45: Repetitive Interrupt Timer
                DCD     MCPWM_IRQHandler          ; 46: Motor Control PWM
                DCD     QEI_IRQHandler            ; 47: Quadrature Encoder Interface
                DCD     PLL1_IRQHandler           ; 48: PLL1 Lock (USB PLL)
                DCD     USBActivity_IRQHandler    ; 49: USB Activity interrupt to wakeup
                DCD     CANActivity_IRQHandler    ; 50: CAN Activity interrupt to wakeup


                IF      :LNOT::DEF:NO_CRP
                AREA    |.ARM.__at_0x02FC|, CODE, READONLY
CRP_Key         DCD     0xFFFFFFFF
                ENDIF


var				RN 		2

                AREA    |.text|, CODE, READONLY
; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]                                            
                
				;your code here
				LDR R0, =CONDITION
				LDR R1, =N_CARDS
				LDRB R1, [R1]
				LDR R2, =POOR
				LDR R3, =GOOD
				LDR R4, =MINT
				MOV R5, #0		;contatore poor
				MOV R6, #0		;cont good
				MOV R7, #0		;cont mint
				
				MOV R8, #0		;indice per loop sulle carte
				
loop
				CMP R8, R1
				BGE continue
				
				LDR R9, [R0], #4	; card ID
				LDR R10, [R0], #4 	; card condition
				BL compute_difference
				
				PUSH {R0}
				CMP R10, #0
				BNE not_poor
				MOV R0, R2
				MOV R12, R5
				ADD R5, R5, #1
				B call_insert
not_poor
				CMP R10, #1
				BNE mint
				MOV R0, R3
				MOV R12, R6
				ADD R6, R6, #1
				B call_insert
mint			
				MOV R0, R4
				MOV R12, R7
				ADD R7, R7, #1
call_insert
				BL insert
				POP {R0}

				ADD R8, R8, #1
				B loop
continue
				; Check POOR array
				CMP R5, #0
				MOVEQ R5, #0x7FFFFFFF    ; If empty, set to max value
				LDRNE R5, [R2, #4]       ; Otherwise load minimum
				
				; Check GOOD array  
				CMP R6, #0
				MOVEQ R6, #0x7FFFFFFF    ; If empty, set to max value
				LDRNE R6, [R3, #4]       ; Otherwise load minimum
				
				; Check MINT array
				CMP R7, #0
				MOVEQ R7, #0x7FFFFFFF    ; If empty, set to max value
				LDRNE R7, [R4, #4]       ; Otherwise load minimum
				
				CMP R5, R6
				BGE not_r5
				CMP R5, R7
				BGE not_r5
				LDR R11, [R2]
				LDR R12, [R2, #4]
				B end_program
not_r5
				CMP R6, R7
				BGE not_r6
				LDR R11, [R3]
				LDR R12, [R3, #4]
				B end_program
not_r6
				LDR R11, [R4]
				LDR R12, [R4, #4]
				B end_program

;=========== SUBROUTINE ==========
insert			
				PUSH {R1-R8, R10, LR}
				
				MOV R2, R0		;vector address
				MOV R3, R11		;price difference
				MOV R4, R9		;card ID
				MOV R5, #0		;counter
				
insert_loop		
				CMP R5, R12
				BLT not_end
				STR R4, [R2]
				STR R3, [R2, #4]
				B end_insert_loop
not_end
				LDR R6, [R2, #4]!
				ADD R5, R5, #1
				CMP R6, R3
				ADD R2, R2, #4
				BLT insert_loop
				MOV R7, R6
				LDR R8, [R2, #-8]
				STR R4, [R2, #-8]
				STR R3, [R2, #-4]
				MOV R3, R7
				MOV R4, R8
				B insert_loop				
end_insert_loop
				POP {R1-R8, R10, PC}
	
compute_difference
				PUSH {R0-R7, LR}
				
				MOV R6, R9
				
				LDR R7, =PURCHASE_PRICE
				BL find_price
				MOV R0, R4
				LDR R7, =CURRENT_PRICE
				BL find_price
				MOV R1, R4
				
				SUB R11, R1, R0
				POP {R0-R7, PC}

find_price
				PUSH {R0-R3, LR}
				MOV R0, R7
				MOV R1, #0
				LDR R3, =N_CARDS
				LDRB R3, [R3]
search_price_loop
				LDR R2, [R0], #4	;carica ID e avanza di 4 byte
				CMP R2, R6			;confronta con ID cercato
				BEQ found_price
				ADD R0, R0, #4
				ADD R1, R1, #1
				CMP R1, R3
				BLT search_price_loop
				MOV R4, #0		; non trovato, ritorna 0
				B end_price			
found_price
				LDR R4, [R0]
end_price
				POP {R0-R3, PC}	

;=========== END PROGRAM ==========
end_program
				LDR     R0, =stop
				
stop            BX      R0
                ENDP
					
	LTORG
	
	ALIGN 2
	SPACE 4096
		
CARDS			DCD 	0x134, 3, 275, 0x2B9, 0xDC, 151, 2087
	
CONDITION		DCD		2087, 2
				DCD		275, 0x0 
				DCD		308, 0x1 
				DCD		0xDC, 2
				DCD		151, 2
				DCD		0x3, 0
				DCD		697, 2
					
PURCHASE_PRICE	DCD		0x3, 2000	;3
				DCD		0x113, 2 	;275
				DCD		151, 9 
				DCD		0x134, 45
				DCD		2087, 17 
				DCD		220, 5 		;0xDC
				DCD		697, 350	;0x2B9
					
CURRENT_PRICE	DCD		0xDC, 3
				DCD		151, 16 
				DCD		3, 3300 
				DCD		697, 420 	;0x2B9
				DCD		308, 63		;0x134
				DCD		275, 1
				DCD		0x827, 3	;2087
					
N_CARDS	DCB		7
	
	ALIGN
	SPACE 4096

				AREA myData, DATA, READWRITE
POOR			SPACE 56
GOOD			SPACE 56
MINT			SPACE 56
	
				AREA other, CODE, READONLY

; Dummy Exception Handlers (infinite loops which can be modified)

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]

                B       .
				
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]
                ; your code
				orr r0,r0,#1
				mov r1, r2
				BX	r0
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler         [WEAK]
                B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler          [WEAK]
                B       .
                ENDP
UsageFault_Handler\
                PROC
                EXPORT  UsageFault_Handler        [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler          [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
                EXPORT  SysTick_Handler           [WEAK]
                B       .
                ENDP

Default_Handler PROC

                EXPORT  WDT_IRQHandler            [WEAK]
                EXPORT  TIMER0_IRQHandler         [WEAK]
                EXPORT  TIMER1_IRQHandler         [WEAK]
                EXPORT  TIMER2_IRQHandler         [WEAK]
                EXPORT  TIMER3_IRQHandler         [WEAK]
                EXPORT  UART0_IRQHandler          [WEAK]
                EXPORT  UART1_IRQHandler          [WEAK]
                EXPORT  UART2_IRQHandler          [WEAK]
                EXPORT  UART3_IRQHandler          [WEAK]
                EXPORT  PWM1_IRQHandler           [WEAK]
                EXPORT  I2C0_IRQHandler           [WEAK]
                EXPORT  I2C1_IRQHandler           [WEAK]
                EXPORT  I2C2_IRQHandler           [WEAK]
                EXPORT  SPI_IRQHandler            [WEAK]
                EXPORT  SSP0_IRQHandler           [WEAK]
                EXPORT  SSP1_IRQHandler           [WEAK]
                EXPORT  PLL0_IRQHandler           [WEAK]
                EXPORT  RTC_IRQHandler            [WEAK]
                EXPORT  EINT0_IRQHandler          [WEAK]
                EXPORT  EINT1_IRQHandler          [WEAK]
                EXPORT  EINT2_IRQHandler          [WEAK]
                EXPORT  EINT3_IRQHandler          [WEAK]
                EXPORT  ADC_IRQHandler            [WEAK]
                EXPORT  BOD_IRQHandler            [WEAK]
                EXPORT  USB_IRQHandler            [WEAK]
                EXPORT  CAN_IRQHandler            [WEAK]
                EXPORT  DMA_IRQHandler            [WEAK]
                EXPORT  I2S_IRQHandler            [WEAK]
                EXPORT  ENET_IRQHandler           [WEAK]
                EXPORT  RIT_IRQHandler            [WEAK]
                EXPORT  MCPWM_IRQHandler          [WEAK]
                EXPORT  QEI_IRQHandler            [WEAK]
                EXPORT  PLL1_IRQHandler           [WEAK]
                EXPORT  USBActivity_IRQHandler    [WEAK]
                EXPORT  CANActivity_IRQHandler    [WEAK]

WDT_IRQHandler
TIMER0_IRQHandler
TIMER1_IRQHandler
TIMER2_IRQHandler
TIMER3_IRQHandler
UART0_IRQHandler
UART1_IRQHandler
UART2_IRQHandler
UART3_IRQHandler
PWM1_IRQHandler
I2C0_IRQHandler
I2C1_IRQHandler
I2C2_IRQHandler
SPI_IRQHandler
SSP0_IRQHandler
SSP1_IRQHandler
PLL0_IRQHandler
RTC_IRQHandler
EINT0_IRQHandler
EINT1_IRQHandler
EINT2_IRQHandler
EINT3_IRQHandler
ADC_IRQHandler
BOD_IRQHandler
USB_IRQHandler
CAN_IRQHandler
DMA_IRQHandler
I2S_IRQHandler
ENET_IRQHandler
RIT_IRQHandler
MCPWM_IRQHandler
QEI_IRQHandler
PLL1_IRQHandler
USBActivity_IRQHandler
CANActivity_IRQHandler

                B       .

                ENDP


                ALIGN


; User Initial Stack & Heap

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit                

                END
