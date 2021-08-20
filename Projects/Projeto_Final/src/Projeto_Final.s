        PUBLIC  __iar_program_start
        EXTERN  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

; System Control definitions
SYSCTL_BASE             EQU     0x400FE000
SYSCTL_RCGCGPIO         EQU     0x0608
SYSCTL_PRGPIO		EQU     0x0A08
SYSCTL_RCGCUART         EQU     0x0618
SYSCTL_PRUART           EQU     0x0A18
; System Control bit definitions
PORTA_BIT               EQU     000000000000001b ; bit  0 = Port A
UART0_BIT               EQU     00000001b        ; bit  0 = UART 0

; GPIO Port definitions
GPIO_PORTA_BASE         EQU     0x40058000
GPIO_DIR                EQU     0x0400
GPIO_IS                 EQU     0x0404
GPIO_IBE                EQU     0x0408
GPIO_IEV                EQU     0x040C
GPIO_IM                 EQU     0x0410
GPIO_RIS                EQU     0x0414
GPIO_MIS                EQU     0x0418
GPIO_ICR                EQU     0x041C
GPIO_AFSEL              EQU     0x0420
GPIO_PUR                EQU     0x0510
GPIO_DEN                EQU     0x051C
GPIO_PCTL               EQU     0x052C

; UART definitions
UART_PORT0_BASE         EQU     0x4000C000
UART_FR                 EQU     0x0018
UART_IBRD               EQU     0x0024
UART_FBRD               EQU     0x0028
UART_LCRH               EQU     0x002C
UART_CTL                EQU     0x0030
UART_CC                 EQU     0x0FC8
;UART bit definitions
TXFE_BIT                EQU     10000000b ; TX FIFO full
RXFF_BIT                EQU     01000000b ; RX FIFO empty
BUSY_BIT                EQU     00001000b ; Busy


; PROGRAMA PRINCIPAL

__iar_program_start
        
main:   
	BL UART_enable ; habilita clock ao port 0 de UART
	BL GPIO_enable ; habilita clock ao port A de GPIO
        BL GPIO_special ;habilita funcões especiais no port de GPIO desejado
        BL GPIO_select  ;seleciona funcões especiais no port de GPIO desejado
        BL UART_config ; configura periférico UART0     
        ; recepção e envio de dados pela UART utilizando sondagem (polling)
        ; resulta em um "eco": dados recebidos são retransmitidos pela UART

        BL conf_inicial //função de configuração dos registradores usados

loop:

        BL leitura //função para leitura da UART

        BL verifica_numero // função que recebe a leitura da UART e vê se é um
                          // número
        CMP R10, #0 //registrador que bloqueia entrada de sinal sem número
        BEQ loop
        
        BL verifica_sinal //função que identifica o sinal apertado
          


        B loop


; SUB-ROTINAS

;-----------------------------------------------------------
leitura:
wrx:    LDR R2, [R0, #UART_FR] ; status da UART
        TST R2, #RXFF_BIT ; receptor cheio?
        BEQ wrx
        LDR R1, [R0] ; lê do registrador de dados da UART0 (recebe)
        BX LR
        
;-----------------------------------------------------------
transmite:

wtx:    LDR R2, [R0, #UART_FR] ; status da UART
        TST R2, #TXFE_BIT ; transmissor vazio?
        BEQ wtx
        STR R1, [R0] ; escreve no registrador de dados da UART0 (transmite)
        BX LR

;-----------------------------------------------------------
verifica_numero:
        
        PUSH {LR}
        CMP R3, #0x03
        BEQ fim_verifica
        CMP R1, #0x30
        ITE HS
          BHS passo
          BLO fim_verifica
          
passo:
        CMP R1, #0x39
        ITE LS
          ADDLS R3,#1
          BHI fim_verifica
        
        BL transmite
        
        CMP R4, #0
        ITE EQ
          BEQ numero_um
          BNE numero_dois

numero_um:
        SUB R7, R1, #0x30
        MUL R5, R8
        ADD R5, R5, R7
        MOV R10, #1
        B fim_verifica

numero_dois:
        SUB R7, R1, #0x30
        MUL R6, R8
        ADD R6, R6, R7
        MOV R10, #1
        B fim_verifica

fim_verifica:
        POP {PC}
;-----------------------------------------------------------
verifica_sinal:

        PUSH {LR}
         
        CMP R1, #0x3D //compara com =
        ITTT EQ
          BLEQ transmite
          MOVEQ R10, #0
          BLEQ oper //função que faz a operação selecioanda conforme os valores
          

        CMP R4, #0
        BNE fim_sinal
        
        CMP R1, #0x2A //compara com *
        ITTTT EQ
          BLEQ transmite
          MOVEQ R3, #0
          MOVEQ R4, #1 //1 é para multiplicação
          MOVEQ R10, #0
          
          
        CMP R1, #0x2B //compara com +
        ITTTT EQ
          BLEQ transmite
          MOVEQ R3, #0
          MOVEQ R4, #2 // 2 é para adição
          MOVEQ R10, #0
         
          
        CMP R1, #0x2D //compara com -
        ITTTT EQ
          BLEQ transmite
          MOVEQ R3, #0
          MOVEQ R4, #3 //3 é para subtração
          MOVEQ R10, #0
          
          
        CMP R1, #0x2F //compara com /
        ITTTT EQ
          BLEQ transmite
          MOVEQ R3, #0
          MOVEQ R4, #4 // 4 é para a divisão
          MOVEQ R10, #0
 fim_sinal:          
        POP {PC}

;-----------------------------------------------------------        
oper:
          PUSH {LR}
          
          CMP R4, #0 //verifica se é igual e transfere para a saída
          IT EQ
            MOVEQ R7, R5
          
          CMP R4, #1
          IT EQ
            BLEQ multi //responsável pela multiplicação
            
          CMP R4, #2
          IT EQ
            BLEQ soma //responsável pela adição
            
          CMP R4, #3
          IT EQ
            BLEQ sub //responsável pela subtração
            
          CMP R4, #4
          IT EQ
            BLEQ div //responsável pela divisão
          
          CMP R7, #0
          ITTT EQ
            MOVEQ R1, #0x30
            BLEQ transmite
            BEQ final
          
          CMP R7, #0 //verifica se o número é menor que 0 e coloca o sinal na 
          ITTTT LT // UART e multiplica por -1 para ir para transmissão
            MOVLT R1, #0x2D 
            BLLT transmite
            MOVLT R3, #-1
            MULLT R7, R3
            
          
          BL trans //responsável pela mudança para ASCII para aparecer para o 
                  //usuário
final:    BL conf_inicial //volta para as configurações iniciais
          MOV R1, #0x0A
          BL transmite
          MOV R1, #0x0D
          BL transmite // colocam o \r e \n na UART
          
          POP {PC}

;-----------------------------------------------------------
multi:
        MOV R7, R5 
        MUL R7, R6
        BX LR
;-----------------------------------------------------------
soma:
        ADD R7, R5, R6
        BX LR
;-----------------------------------------------------------
sub:
        SUB R7, R5, R6
        BX LR
;-----------------------------------------------------------
div:
        PUSH {LR}
        
        CMP R6, #0
        ITE EQ
          BLEQ erro
          UDIVNE R7, R5, R6
               
        POP {PC}
;-----------------------------------------------------------
erro:
          PUSH {LR}  //mensagem de erro na UART quando tem 
                    // divisão por 0
          MOV R1, #0x45 //E
          BL transmite
          MOV R1, #0x52 //R
          BL transmite
          BL transmite
          MOV R1, #0x4F //O
          BL transmite

          POP {PC}
;-----------------------------------------------------------          
          
trans:
          PUSH {LR}      //faz a mudança de decimal para ASCII       
          
menor:    CMP R7, R9
          ITT LT
            UDIVLT R9, R9, R8
            BLT menor
          
mostrar:  CMP R9, #0
          ITT NE
            BLNE conta
            BNE mostrar
          
          POP {PC}
;-----------------------------------------------------------
conta:
          PUSH {LR}             //diviseões sucessivas até 
                                //até ficar na unidade e fácil
          UDIV R3, R7, R9       //de mudar para ASCII
          MOV R1, R3
          ADD R1, R1, #0x30
          BL transmite
          MUL R3, R9
          SUB R7, R7, R3
          UDIV R9, R9, R8
          
          POP {PC}


;-----------------------------------------------------------

conf_inicial:
          MOV R3, #0 // contador de números digitados
          MOV R4, #0 // indicador de operação 
          MOV R5, #0 // registrador que guarda primeiro número
          MOV R6, #0 // registrador que guarda segundo número
          MOV R7, #0 // registrador que guarda resultado
          MOV R8, #0x0A //constante para contas
          MOV R9, #0x86A0
          MOVT R9, #0x0001 // valor base para mostar na tela
          MOV R10, #0 //registrador que libera ou bloqueia o sinal
          BX LR
;-----------------------------------------------------------
;----------
; UART_enable: habilita clock para as UARTs selecionadas em R2
UART_enable:
        MOV R2, #(UART0_BIT)
        LDR R0, =SYSCTL_BASE
	LDR R1, [R0, #SYSCTL_RCGCUART]
	ORR R1, R2 ; habilita UARTs selecionados
	STR R1, [R0, #SYSCTL_RCGCUART]

waitu	LDR R1, [R0, #SYSCTL_PRUART]
	TEQ R1, R2 ; clock das UARTs habilitados?
	BNE waitu

        BX LR
        
; UART_config: configura a UART desejada
UART_config:
        LDR R0, =UART_PORT0_BASE
        LDR R1, [R0, #UART_CTL]
        BIC R1, #0x01 ; desabilita UART (bit UARTEN = 0)
        STR R1, [R0, #UART_CTL]

        ; clock = 16MHz, baud rate = 9600 bps
        MOV R1, #104
        STR R1, [R0, #UART_IBRD]
        MOV R1, #11
        STR R1, [R0, #UART_FBRD]
        
        ; 8 bits, 1 stop, odd parity, FIFOs disabled, no interrupts
        MOV R1, #0x62
        STR R1, [R0, #UART_LCRH]
        
        ; clock source = system clock
        MOV R1, #0x00
        STR R1, [R0, #UART_CC]
        
        LDR R1, [R0, #UART_CTL]
        ORR R1, #0x01 ; habilita UART (bit UARTEN = 1)
        STR R1, [R0, #UART_CTL]

        BX LR


; GPIO_special: habilita funcões especiais no port de GPIO desejado
GPIO_special:
        LDR R0, =GPIO_PORTA_BASE
        MOV R1, #00000011b ; bits 0 e 1 como especiais
	LDR R2, [R0, #GPIO_AFSEL]
	ORR R2, R1 ; configura bits especiais
	STR R2, [R0, #GPIO_AFSEL]

	LDR R2, [R0, #GPIO_DEN]
	ORR R2, R1 ; habilita função digital
	STR R2, [R0, #GPIO_DEN]

        BX LR

; GPIO_select: seleciona funcões especiais no port de GPIO desejado
GPIO_select:
        MOV R1, #0xFF ; máscara das funções especiais no port A (bits 1 e 0)
        MOV R2, #0x11  ; funções especiais RX e TX no port A (UART)
	LDR R3, [R0, #GPIO_PCTL]
        BIC R3, R1
	ORR R3, R2 ; seleciona bits especiais
	STR R3, [R0, #GPIO_PCTL]

        BX LR
;----------

; GPIO_enable: habilita clock para os ports de GPIO selecionados em R2
GPIO_enable:
        MOV R2, #(PORTA_BIT)
        LDR R0, =SYSCTL_BASE
	LDR R1, [R0, #SYSCTL_RCGCGPIO]
	ORR R1, R2 ; habilita ports selecionados
	STR R1, [R0, #SYSCTL_RCGCGPIO]

waitg	LDR R1, [R0, #SYSCTL_PRGPIO]
	TEQ R1, R2 ; clock dos ports habilitados?
	BNE waitg

        BX LR

;-----------------------------------------------------------
        END
