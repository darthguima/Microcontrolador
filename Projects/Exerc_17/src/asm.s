        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

SYSCTL_RCGCGPIO_R       EQU     0x400FE608
SYSCTL_PRGPIO_R		EQU     0x400FEA08
PORTF_BIT               EQU     0000000000100000b ; bit  5 = Port F
PORTN_BIT               EQU     0001000000000000b ; bit 12 = Port N


GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTF_DATA_R    	EQU     0x4005D000

GPIO_PORTN_DIR_R        EQU     0x40064400
GPIO_PORTF_DIR_R        EQU     0x4005D400


GPIO_PORTN_DEN_R     	EQU     0x4006451C
GPIO_PORTF_DEN_R     	EQU     0x4005D51C

__iar_program_start
        
        
main    
        BL config_N //CONFIGURA AS SAÍDA DOS LEDS D1 E D2, R2 COMO BASE
        BL config_F //CONFIGURA AS SAÍDA DOS LEDS D3 E D4, R3 COMO BASE

 	LDR R0, = GPIO_PORTN_DATA_R
        LDR R4, = GPIO_PORTF_DATA_R
        
loop2   MOV R6, #0
        MOV R7, #00000000b
        MOV R8, #00000000b
loop	STR R7, [R0, R2, LSL #2] ; aciona LED com estado atual
        STR R8, [R4, R3, LSL #2]
        MOVT R5, #0x000F ; constante de atraso 
delay   CBZ R5, theend ; 1 clock
        SUB R5, R5, #1 ; 1 clock
        B delay ; 3 clocks
theend  ADD R6, #1
        MOV R9, R6 ;UTILIZAÇÃO DE R9 PARA ENCURTAR UM POUCO A QUANTIDADE DE CÓDIGO, JÁ QUE A MUDANÇA BIT A BIT PODE SER FEITA COM REPETIÇÕES DOS 
        B comps    ; DE 1, 2 E 4.
        

comps   
        CMP R6, #16
        BEQ loop2
        
        
        
num1    CMP R9, #1
        ITT EQ
        ORREQ R7, R7, #0x02
          BEQ loop
          
num2    CMP R9, #2
        ITTT EQ
          BICEQ R7, R7, #0x02
          ORREQ R7, R7, #0x01
          BEQ loop
          
num3    CMP R9, #3
        ITT EQ
          MOVEQ R9, #1
          BEQ num1
          
num4    CMP R9, #4
        ITTT EQ
          ORREQ R8, R8, #0x10
          BICEQ R7, R7, #0x03
          BEQ loop
          
        CMP R9, #5
        ITT EQ
          MOVEQ R9, #1
          BEQ num1
        
        CMP R9, #6
        ITT EQ
          MOVEQ R9, #2
          BEQ num2
          
        CMP R9, #7
        ITT EQ
          MOVEQ R9, #1
          BEQ num1
        
        CMP R6, #8
        ITTTT EQ
          BICEQ R7, R7, #0x03
          BICEQ R8, R8, #0x10
          ORREQ R8, R8, #0x01
          BEQ loop
        
        CMP R6, #9
        ITT EQ
          MOVEQ R9, #1
          BEQ num1
        
        CMP R6, #10
        ITT EQ
          MOVEQ R9, #2
          BEQ num2
        
        CMP R6, #11
        ITT EQ
          MOVEQ R9, #3
          BEQ num3
        
        CMP R6, #12
        ITT EQ
          MOVEQ R9, #4
          BEQ num4
        
        CMP R6, #13
        ITT EQ
          MOVEQ R9, #1
          BEQ num1
        
        CMP R6, #14
        ITT EQ
          MOVEQ R9, #2
          BEQ num2
        
        CMP R6, #15
        ITT EQ
          MOVEQ R9, #3
          BEQ num3
   
config_N        
        MOV R2, #PORTN_BIT
	LDR R0, =SYSCTL_RCGCGPIO_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita port N
	STR R1, [R0] ; escrita do novo estado
        
        LDR R0, =SYSCTL_PRGPIO_R
waitn	LDR R2, [R0] ; leitura do estado atual
	TEQ R1, R2 ; clock do port N habilitado?
	BNE waitn ; caso negativo, aguarda

        MOV R2, #00000011b ; bit 0 e bit 1
        
	LDR R0, =GPIO_PORTN_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; bit de saída
	STR R1, [R0] ; escrita do novo estado

	LDR R0, =GPIO_PORTN_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita função digital
	STR R1, [R0] ; escrita do novo estado
        BX LR
        
        
config_F        
        MOV R3, #PORTF_BIT
	LDR R0, =SYSCTL_RCGCGPIO_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R3 ; habilita port F
	STR R1, [R0] ; escrita do novo estado
        
        LDR R0, =SYSCTL_PRGPIO_R
waitf	LDR R3, [R0] ; leitura do estado atual
	TEQ R1, R3 ; clock do port F habilitado?
	BNE waitf ; caso negativo, aguarda

        MOV R3, #00010001b ; bit 0 e bit 4
        
	LDR R0, =GPIO_PORTF_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R3 ; bit de saída
	STR R1, [R0] ; escrita do novo estado

	LDR R0, =GPIO_PORTF_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R3 ; habilita função digital
	STR R1, [R0] ; escrita do novo estado
        BX LR

        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END
