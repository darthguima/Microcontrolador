# Laboratório 1, Exercício 3

Durante a execução desse exercício foi possível saber o funcionamento de algumas funções muito utilizadas para a programação de um microcontrolador.
As funções usadas foram:
      MOV, que move uma informação para um registrador. Ex: MOV R0, #0x55; essa função coloca o valor hexadecimal 0x55 no registrador R0.
      MVN, que move a informação negada a um registrador. Ex: MVN R1, #4; esta move o valor decimal 4 para o registrador R1 e nega os bits dele, então a informação que tem no R1 é 0xfffffffb.
      LSL, faz um deslocamento lógico de bits para a esquerda, e as novas posições são ocupadas por '0'.
      LDR, faz um deslocamento lógico de bits para a direita, e as novas posições são ocupadas por '0'.
      ASR, faz um deslocamento aritmético de bits para a direita, e as novas posições são ocupadas dependendo do bit mais significativo.
      ROR, faz uma rotação de bits para a direita, é como se os bits do final e do início estivessem colados e executa a mudança do bit mais significativo.
      
Essa primeira experiência também facilitou a entrada nesse novo mundo de microcontroladores de maneira muito prática e objetiva, além de facilitar o entendimento de como o software IAR funciona e a apresentação da linguagem assembly.
