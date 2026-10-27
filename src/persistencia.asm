# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Erik Vinicius Gomes de Lima
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores (UFRPE - 2026.2)
# Professor: Prof. Vítor A Coutinho
# Arquivo: persistencia.asm
# Descrição: gerenciamento de estado em disco (salvar, recarregar, formatar) e I/O binario
# ============================================================
.data  # Seleciona a seção de dados estáticos.

# Nome do arquivo utilizado para guardar o estado do condomínio
persist_nome_arquivo: .asciiz "condominio.dat"  # Define em persist_nome_arquivo uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Guarda o descritor do arquivo atualmente aberto
persist_descritor: .word -1  # Declara palavra(s) inicializada(s) com -1.


# ------------------------------------------------------------
# ROTINAS PÚBLICAS
# ------------------------------------------------------------

# Torna a rotina de inicialização acessível aos outros módulos
.globl persist_inicializar  # Exporta persist_inicializar para uso como símbolo global.

# Torna a rotina de carregamento acessível aos outros módulos
.globl persist_carregar  # Exporta persist_carregar para uso como símbolo global.

# Torna a rotina de gravação acessível aos outros módulos
.globl persist_salvar  # Exporta persist_salvar para uso como símbolo global.

# Torna a rotina de encerramento acessível aos outros módulos
.globl persist_encerrar  # Exporta persist_encerrar para uso como símbolo global.

# Torna a rotina de recarregamento acessível aos outros módulos
.globl persist_recarregar  # Exporta persist_recarregar para uso como símbolo global.

# Torna a rotina de formatação volátil acessível aos outros módulos
.globl persist_formatar  # Exporta persist_formatar para uso como símbolo global.



# Seleciona a seção de instruções
.text  # Seleciona a seção de instruções executáveis.


# ------------------------------------------------------------
# persist_inicializar()
#
# Prepara o descritor antes das operações de arquivo
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

persist_inicializar:

    # Obtém o endereço da variável que guarda o descritor
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.

    # Marca o descritor como fechado
    li      $t1, -1  # Carrega o valor imediato -1 no registrador $t1.

    # Salva o valor inicial do descritor
    sw $t1, 0($t0)  # Armazena palavra de $t1 na posição de memória 0($t0).

    # Retorna sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# persist_carregar()
#
# Abre o arquivo em modo de leitura e preenche toda a tabela
# de apartamentos com os dados armazenados
#
# Retorno:
#   $v0 = OK ou ERRO_ARQUIVO
# ------------------------------------------------------------

persist_carregar:

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -16  # Reserva espaço de pilha ajustando $sp em -16 bytes.

    # Salva o endereço de retorno
    sw $ra, 12($sp)  # Armazena palavra de $ra na posição de memória 12($sp).

    # Salva o descritor do arquivo
    sw $s0, 8($sp)  # Armazena palavra de $s0 na posição de memória 8($sp).

    # Salva o ponteiro de destino da leitura
    sw $s1, 4($sp)  # Armazena palavra de $s1 na posição de memória 4($sp).

    # Salva a quantidade de bytes ainda pendentes
    sw $s2, 0($sp)  # Armazena palavra de $s2 na posição de memória 0($sp).

    # Carrega o nome do arquivo para o primeiro argumento
    la      $a0, persist_nome_arquivo  # Carrega em $a0 o endereço persist_nome_arquivo para passá-lo como argumento.

    # Define o modo de abertura como leitura
    li      $a1, 0  # Carrega o valor imediato 0 no registrador $a1.

    # Mantém o terceiro argumento zerado
    li      $a2, 0  # Carrega o valor imediato 0 no registrador $a2.

    # Seleciona a chamada de sistema para abrir arquivo
    li      $v0, 13  # Seleciona em $v0 o serviço MARS de abrir arquivo.

    # Tenta abrir o arquivo
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Um valor negativo indica falha na abertura
    bltz    $v0, persist_carregar_erro  # Se $v0 for menor que zero, desvia para persist_carregar_erro.

    # Guarda o descritor retornado pelo MARS
    move    $s0, $v0  # Copia o valor de $v0 para $s0.

    # Atualiza o descritor global do módulo
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.
    sw $s0, 0($t0)  # Armazena palavra de $s0 na posição de memória 0($t0).

    # Carrega o endereço inicial da tabela de apartamentos
    la      $s1, apartamentos  # Obtém o endereço de apartamentos e o coloca em $s1.

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t0.

    # Carrega o tamanho de cada bloco
    li      $t1, TAM_BLOCO_AP  # Carrega o valor imediato TAM_BLOCO_AP no registrador $t1.

    # Calcula o total de bytes que precisam ser lidos
    mul     $s2, $t0, $t1  # Multiplica $t0 por $t1 e grava o produto em $s2.


persist_carregar_loop:

    # Verifica se todos os bytes já foram lidos
    beq     $s2, $zero, persist_carregar_sucesso  # Se $s2 e $zero forem iguais, desvia para persist_carregar_sucesso.

    # Passa o descritor para a chamada de leitura
    move    $a0, $s0  # Copia o valor de $s0 para $a0.

    # Passa o endereço de destino da leitura
    move    $a1, $s1  # Copia o valor de $s1 para $a1.

    # Solicita no máximo a quantidade de bytes restantes
    move    $a2, $s2  # Copia o valor de $s2 para $a2.

    # Seleciona a chamada de sistema para ler arquivo
    li      $v0, 14  # Seleciona em $v0 o serviço MARS de ler arquivo.

    # Lê uma parte do estado salvo
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Um valor negativo indica falha de leitura
    bltz    $v0, persist_carregar_erro_fechando  # Se $v0 for menor que zero, desvia para persist_carregar_erro_fechando.

    # Zero antes do fim indica arquivo incompleto
    beq     $v0, $zero, persist_carregar_erro_fechando  # Se $v0 e $zero forem iguais, desvia para persist_carregar_erro_fechando.

    # Avança o ponteiro pelo número de bytes lidos
    addu    $s1, $s1, $v0  # Soma $s1 e $v0, gravando o resultado em $s1.

    # Remove da pendência os bytes que já foram lidos
    subu    $s2, $s2, $v0  # Subtrai $v0 de $s2 e grava o resultado em $s2.

    # Continua até preencher toda a tabela
    j       persist_carregar_loop  # Desvia a execução incondicionalmente para persist_carregar_loop.


persist_carregar_sucesso:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0  # Copia o valor de $s0 para $a0.

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16  # Seleciona em $v0 o serviço MARS de fechar arquivo.

    # Fecha o arquivo após a leitura completa
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Marca o descritor global como fechado
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.
    li      $t1, -1  # Carrega o valor imediato -1 no registrador $t1.
    sw $t1, 0($t0)  # Armazena palavra de $t1 na posição de memória 0($t0).

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Finaliza a rotina
    j       persist_carregar_finalizar  # Desvia a execução incondicionalmente para persist_carregar_finalizar.


persist_carregar_erro_fechando:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0  # Copia o valor de $s0 para $a0.

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16  # Seleciona em $v0 o serviço MARS de fechar arquivo.

    # Fecha o arquivo mesmo após uma falha
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Marca o descritor global como fechado
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.
    li      $t1, -1  # Carrega o valor imediato -1 no registrador $t1.
    sw $t1, 0($t0)  # Armazena palavra de $t1 na posição de memória 0($t0).

    # Define o código de erro de arquivo
    li      $v0, ERRO_ARQUIVO  # Carrega o valor imediato ERRO_ARQUIVO no registrador $v0.

    # Finaliza a rotina
    j       persist_carregar_finalizar  # Desvia a execução incondicionalmente para persist_carregar_finalizar.


persist_carregar_erro:

    # Workaround essencial para bug nativo do MARS 4.5 (mars.util.SystemIO.openFile):
    # Ao abrir arquivo inexistente em modo leitura (O_RDONLY), o MARS reserva o primeiro
    # descritor livre (fd = 3, após STDIN=0, STDOUT=1, STDERR=2) em FileIOData.nowOpening(),
    # mas ao capturar FileNotFoundException (SystemIO.java:441) retorna -1 sem invocar
    # FileIOData.close(fdToUse). Isso deixa o nome "condominio.dat" travado em fileNames[3],
    # fazendo com que futuras chamadas a persist_salvar falhem com "File already open".
    # O syscall 16 em fd = 3 limpa fileNames[3] = null com segurança no MARS.
    li      $a0, 3  # Carrega o valor imediato 3 no registrador $a0.
    li      $v0, 16  # Seleciona em $v0 o serviço MARS de fechar arquivo.
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Define o código de erro quando a abertura falha
    li      $v0, ERRO_ARQUIVO  # Carrega o valor imediato ERRO_ARQUIVO no registrador $v0.


persist_carregar_finalizar:

    # Restaura a quantidade de bytes pendentes
    lw $s2, 0($sp)  # Carrega palavra da posição 0($sp) para $s2.

    # Restaura o ponteiro de destino
    lw $s1, 4($sp)  # Carrega palavra da posição 4($sp) para $s1.

    # Restaura o descritor
    lw $s0, 8($sp)  # Carrega palavra da posição 8($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 12($sp)  # Carrega palavra da posição 12($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16  # Libera espaço de pilha ajustando $sp em 16 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# persist_salvar()
#
# Abre o arquivo em modo de escrita e grava a tabela completa
# dos apartamentos
#
# Retorno:
#   $v0 = OK ou ERRO_ARQUIVO
# ------------------------------------------------------------

persist_salvar:

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -16  # Reserva espaço de pilha ajustando $sp em -16 bytes.

    # Salva o endereço de retorno
    sw $ra, 12($sp)  # Armazena palavra de $ra na posição de memória 12($sp).

    # Salva o descritor do arquivo
    sw $s0, 8($sp)  # Armazena palavra de $s0 na posição de memória 8($sp).

    # Salva o ponteiro de origem dos dados
    sw $s1, 4($sp)  # Armazena palavra de $s1 na posição de memória 4($sp).

    # Salva a quantidade de bytes ainda pendentes
    sw $s2, 0($sp)  # Armazena palavra de $s2 na posição de memória 0($sp).

    # Carrega o nome do arquivo
    la      $a0, persist_nome_arquivo  # Carrega em $a0 o endereço persist_nome_arquivo para passá-lo como argumento.

    # Define o modo de abertura como escrita
    li      $a1, 1  # Carrega o valor imediato 1 no registrador $a1.

    # Mantém o terceiro argumento zerado
    li      $a2, 0  # Carrega o valor imediato 0 no registrador $a2.

    # Seleciona a chamada de sistema para abrir arquivo
    li      $v0, 13  # Seleciona em $v0 o serviço MARS de abrir arquivo.

    # Abre ou cria o arquivo de persistência
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Um valor negativo indica falha na abertura
    bltz    $v0, persist_salvar_erro  # Se $v0 for menor que zero, desvia para persist_salvar_erro.

    # Guarda o descritor retornado pelo MARS
    move    $s0, $v0  # Copia o valor de $v0 para $s0.

    # Atualiza o descritor global
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.
    sw $s0, 0($t0)  # Armazena palavra de $s0 na posição de memória 0($t0).

    # Carrega o endereço inicial da tabela
    la      $s1, apartamentos  # Obtém o endereço de apartamentos e o coloca em $s1.

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t0.

    # Carrega o tamanho de cada bloco
    li      $t1, TAM_BLOCO_AP  # Carrega o valor imediato TAM_BLOCO_AP no registrador $t1.

    # Calcula a quantidade total de bytes que será gravada
    mul     $s2, $t0, $t1  # Multiplica $t0 por $t1 e grava o produto em $s2.


persist_salvar_loop:

    # Verifica se todos os bytes já foram gravados
    beq     $s2, $zero, persist_salvar_sucesso  # Se $s2 e $zero forem iguais, desvia para persist_salvar_sucesso.

    # Passa o descritor para a chamada de escrita
    move    $a0, $s0  # Copia o valor de $s0 para $a0.

    # Passa o endereço dos dados que serão gravados
    move    $a1, $s1  # Copia o valor de $s1 para $a1.

    # Informa a quantidade de bytes ainda pendentes
    move    $a2, $s2  # Copia o valor de $s2 para $a2.

    # Seleciona a chamada de sistema para escrever arquivo
    li      $v0, 15  # Seleciona em $v0 o serviço MARS de escrever arquivo.

    # Grava uma parte do estado em disco
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Um valor negativo indica falha de escrita
    bltz    $v0, persist_salvar_erro_fechando  # Se $v0 for menor que zero, desvia para persist_salvar_erro_fechando.

    # Zero antes do fim indica que a escrita não avançou
    beq     $v0, $zero, persist_salvar_erro_fechando  # Se $v0 e $zero forem iguais, desvia para persist_salvar_erro_fechando.

    # Avança o ponteiro pelo número de bytes gravados
    addu    $s1, $s1, $v0  # Soma $s1 e $v0, gravando o resultado em $s1.

    # Remove da pendência os bytes já gravados
    subu    $s2, $s2, $v0  # Subtrai $v0 de $s2 e grava o resultado em $s2.

    # Continua até gravar todo o estado
    j       persist_salvar_loop  # Desvia a execução incondicionalmente para persist_salvar_loop.


persist_salvar_sucesso:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0  # Copia o valor de $s0 para $a0.

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16  # Seleciona em $v0 o serviço MARS de fechar arquivo.

    # Fecha o arquivo após a gravação
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Marca o descritor global como fechado
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.
    li      $t1, -1  # Carrega o valor imediato -1 no registrador $t1.
    sw $t1, 0($t0)  # Armazena palavra de $t1 na posição de memória 0($t0).

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Finaliza a rotina
    j       persist_salvar_finalizar  # Desvia a execução incondicionalmente para persist_salvar_finalizar.


persist_salvar_erro_fechando:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0  # Copia o valor de $s0 para $a0.

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16  # Seleciona em $v0 o serviço MARS de fechar arquivo.

    # Fecha o arquivo mesmo após uma falha
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Marca o descritor global como fechado
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.
    li      $t1, -1  # Carrega o valor imediato -1 no registrador $t1.
    sw $t1, 0($t0)  # Armazena palavra de $t1 na posição de memória 0($t0).

    # Define o código de erro de arquivo
    li      $v0, ERRO_ARQUIVO  # Carrega o valor imediato ERRO_ARQUIVO no registrador $v0.

    # Finaliza a rotina
    j       persist_salvar_finalizar  # Desvia a execução incondicionalmente para persist_salvar_finalizar.


persist_salvar_erro:

    # Define o código de erro quando a abertura falha
    li      $v0, ERRO_ARQUIVO  # Carrega o valor imediato ERRO_ARQUIVO no registrador $v0.


persist_salvar_finalizar:

    # Restaura a quantidade de bytes pendentes
    lw $s2, 0($sp)  # Carrega palavra da posição 0($sp) para $s2.

    # Restaura o ponteiro de origem
    lw $s1, 4($sp)  # Carrega palavra da posição 4($sp) para $s1.

    # Restaura o descritor
    lw $s0, 8($sp)  # Carrega palavra da posição 8($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 12($sp)  # Carrega palavra da posição 12($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16  # Libera espaço de pilha ajustando $sp em 16 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# persist_encerrar()
#
# Fecha o arquivo caso algum descritor ainda esteja aberto
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

persist_encerrar:

    # Carrega o endereço da variável do descritor
    la      $t0, persist_descritor  # Obtém o endereço de persist_descritor e o coloca em $t0.

    # Lê o descritor atualmente armazenado
    lw $t1, 0($t0)  # Carrega palavra da posição 0($t0) para $t1.

    # Carrega o valor usado para indicar descritor fechado
    li      $t2, -1  # Carrega o valor imediato -1 no registrador $t2.

    # Se já estiver fechado, não executa outra chamada de sistema
    beq     $t1, $t2, persist_encerrar_sucesso  # Se $t1 e $t2 forem iguais, desvia para persist_encerrar_sucesso.

    # Passa o descritor para a chamada de fechamento
    move    $a0, $t1  # Copia o valor de $t1 para $a0.

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16  # Seleciona em $v0 o serviço MARS de fechar arquivo.

    # Fecha o arquivo ainda aberto
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Marca o descritor como fechado
    sw $t2, 0($t0)  # Armazena palavra de $t2 na posição de memória 0($t0).


persist_encerrar_sucesso:

    # Retorna sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# persist_recarregar()
#
# Recarrega as informações salvas do arquivo externo na memória,
# descartando modificações não salvas (cmd_9)
#
# Retorno:
#   $v0 = OK ou ERRO_ARQUIVO
# ------------------------------------------------------------

persist_recarregar:

    # Reserva espaço na pilha alinhado em 8 bytes
    addiu   $sp, $sp, -8  # Reserva espaço de pilha ajustando $sp em -8 bytes.

    # Salva o endereço de retorno
    sw $ra, 4($sp)  # Armazena palavra de $ra na posição de memória 4($sp).

    # Invoca o carregamento dos registros a partir do arquivo
    jal     persist_carregar  # Chama a rotina persist_carregar e salva o endereço de retorno em $ra.

    # Restaura o endereço de retorno
    lw $ra, 4($sp)  # Carrega palavra da posição 4($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 8  # Libera espaço de pilha ajustando $sp em 8 bytes.

    # Retorna o status resultante em $v0
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# persist_formatar()
#
# Apaga todas as informações da execução atual deixando todos os
# apartamentos vazios em memória, sem alterar o arquivo em disco (cmd_10)
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

persist_formatar:

    # Reserva espaço na pilha alinhado em 8 bytes
    addiu   $sp, $sp, -8  # Reserva espaço de pilha ajustando $sp em -8 bytes.

    # Salva o endereço de retorno
    sw $ra, 4($sp)  # Armazena palavra de $ra na posição de memória 4($sp).

    # Reinicializa toda a tabela de apartamentos em memória
    jal     dados_inicializar  # Chama a rotina dados_inicializar e salva o endereço de retorno em $ra.

    # Restaura o endereço de retorno
    lw $ra, 4($sp)  # Carrega palavra da posição 4($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 8  # Libera espaço de pilha ajustando $sp em 8 bytes.

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.