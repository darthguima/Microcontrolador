        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

SYSCTL_RCGCGPIO_R       EQU     0x400FE608
SYSCTL_PRGPIO_R		EQU     0x400FEA08
PORTF_BIT               EQU     0000000000100000b ; bit  5 = Port F
PORTJ_BIT               EQU     0000000100000000b ; bit  8 = Port J
PORTN_BIT               EQU     0001000000000000b ; bit 12 = Port N

GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTJ_DATA_R    	EQU     0x40060000
GPIO_PORTF_DATA_R    	EQU     0x4005D000

GPIO_PORTN_DIR_R        EQU     0x40064400
GPIO_PORTJ_DIR_R        EQU     0x40060400
GPIO_PORTF_DIR_R        EQU     0x4005D400

GPIO_PORTN_DEN_R     	EQU     0x4006451C
GPIO_PORTJ_DEN_R     	EQU     0x4006051C
GPIO_PORTF_DEN_R     	EQU     0x4005D51C

GPIO_PORTJ_PUR          EQU     0X40060510




__iar_program_start
        
        
main    
        BL config_N //CONFIGURA AS SAÍDA DOS LEDS D1 E D2
        BL config_F //CONFIGURA AS SAÍDA DOS LEDS D3 E D4
        BL config_J //CONFIGURA AS ENTRADAS DAS CHAVES SW1 E SW2
        
        BL config_micro //COMFIGURA AS CONDIÇÕES INICIAIS DA PROGRAMAÇÃO
        
        
loop    LDR R4, [R2, R12, LSL #2] ;lê o valor das chaves
        
        CMP R4, #2
        IT EQ
          BLEQ soma
          
        CMP R4, #1
        IT EQ
          BLEQ sub
            
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

config_J         
	MOV R3, #PORTJ_BIT
	LDR R0, =SYSCTL_RCGCGPIO_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R3 ; habilita port F
	STR R1, [R0] ; escrita do novo estado
        
        LDR R0, =SYSCTL_PRGPIO_R
waitj	LDR R3, [R0] ; leitura do estado atual
	TEQ R1, R3 ; clock do port F habilitado?
	BNE waitj ; caso negativo, aguarda

        MOV R3, #000000011b ; bit 0 e bit 4
        
	LDR R0, =GPIO_PORTJ_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	BIC R1, R3 ; bit de saída
	STR R1, [R0] ; escrita do novo estado

        LDR R0, =GPIO_PORTJ_PUR
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R3 ; habilita resistor de pull-up
	STR R1, [R0] ; escrita do novo estado

	LDR R0, =GPIO_PORTJ_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R3 ; habilita função digital
	STR R1, [R0] ; escrita do novo estado
        BX LR
        
config_micro
        LDR R0, = GPIO_PORTN_DATA_R
        LDR R1, = GPIO_PORTF_DATA_R
        LDR R2, = GPIO_PORTJ_DATA_R
        
        MOV R10, #00000011b //LEDS D1 E D2
        MOV R11, #00010001b //LEDS D3 E D4
        MOV R12, #00000011b // CHAVES SW1 E SW2
        
        MOV R3, #0 //CONTADOR
        MOV R4, #0 //GUARDAR OS VALORES DA CHAVE
        MOV R5, #0 //LEDS ACESOS DA PORTA N
        MOV R6, #0 //LEDS ACESOS PORTA F
        
        
	STR R5, [R0, R10, LSL #2] // aciona LED com estado atual
        STR R6, [R1, R11, LSL #2] // aciona LED com estado atual
        BX LR

soma
        MOVT R9, #0x30 //CONSTANTE DE TEMPO DE ATRASO
soma1   SUB R9, R9, #1 //TEMPO DE ATRASO PARA O BOUNCING
        CMP R9, #0
        BNE soma1
        ADD R3, R3, #1
        CMP R3, #0x10
        IT EQ
          MOVEQ R3, #0
        PUSH {LR}
        BL comp
        POP {PC}


sub
        MOVT R9, #0x30 //CONSTANTE DE TEMPO DE ATRASO
sub1    SUB R9, R9, #1 //TEMPO DE ATRASO PARA O BOUNCING
        CMP R9, #0
        BNE sub1
        SUB R3, R3, #1
        CMP R3, #-1
        IT EQ
          MOVEQ R3, #0X0F
        PUSH {LR}
        BL comp
        POP {PC}


comp 

        MOV R7, R3
        AND R7, #1 
        CMP R7, #0 //BIT 0 SENDO COMPARADO
        ITE EQ
          BICEQ R5, #0x02
          ORRNE R5, #0x02
          
        MOV R7, R3, LSR #1
        AND R7, #1
        CMP R7, #0 //BIT 1 SENDO COMPARADO
        ITE EQ
          BICEQ R5, #0x01
          ORRNE R5, #0x01
          
        MOV R7, R3, LSR #2
        AND R7, #1
        CMP R7, #0 //BIT 2 SENDO COMPARADO
        ITE EQ
          BICEQ R6, #0x10
          ORRNE R6, #0x10
        
        MOV R7, R3, LSR #3
        AND R7, #1
        CMP R7, #0 //BIT 3 SENDO COMPARADO
        ITE EQ
          BICEQ R6, #0x01
          ORRNE R6, #0x01

        STR R5, [R0, R10, LSL #2] ; aciona LED com estado atual
        STR R6, [R1, R11, LSL #2] ; aciona LED com estado atual

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
