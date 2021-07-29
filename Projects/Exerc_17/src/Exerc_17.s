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
        LDR R1, = GPIO_PORTF_DATA_R
        
loop2   MOV R3, #0
        MOV R4, #00000011b
        MOV R5, #00010001b
loop	STR R7, [R0, R4, LSL #2] ; aciona LED com estado atual
        STR R8, [R1, R5, LSL #2]
        MOVT R6, #0x000F ; constante de atraso 
delay   CBZ R6, theend ; 1 clock
        SUB R6, R6, #1 ; 1 clock
        B delay ; 3 clocks
theend  ADD R3, #1
       
        B comps
        

comps   
        MOV R9, R3
        AND R9, #1 
        CMP R9, #0 //BIT 0 SENDO COMPARADO
        ITE EQ
          BICEQ R7, #0x02
          ORRNE R7, #0x02
          
        MOV R9, R3, LSR #1
        AND R9, #1
        CMP R9, #0 //BIT 1 SENDO COMPARADO
        ITE EQ
          BICEQ R7, #0x01
          ORRNE R7, #0x01
          
        MOV R9, R3, LSR #2
        AND R9, #1
        CMP R9, #0 //BIT 2 SENDO COMPARADO
        ITE EQ
          BICEQ R8, #0x10
          ORRNE R8, #0x10
        
        MOV R9, R3, LSR #3
        AND R9, #1
        CMP R9, #0 //BIT 3 SENDO COMPARADO
        ITE EQ
          BICEQ R8, #0x01
          ORRNE R8, #0x01
        
        B loop
   
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
