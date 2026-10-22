# Descrição: leitura e gravação do estado dos apartamentos em
#            arquivo usando as chamadas de sistema do MARS



# ------------------------------------------------------------
# ÁREA DE DADOS DO MÓDULO
# ------------------------------------------------------------

.data

# Nome do arquivo utilizado para guardar o estado do condomínio
persist_nome_arquivo: .asciiz "condominio.dat"

# Guarda o descritor do arquivo atualmente aberto
persist_descritor: .word -1


# ------------------------------------------------------------
# ROTINAS PÚBLICAS
# ------------------------------------------------------------

# Torna a rotina de inicialização acessível aos outros módulos
.globl persist_inicializar

# Torna a rotina de carregamento acessível aos outros módulos
.globl persist_carregar

# Torna a rotina de gravação acessível aos outros módulos
.globl persist_salvar

# Torna a rotina de encerramento acessível aos outros módulos
.globl persist_encerrar

# Torna a rotina de recarregamento acessível aos outros módulos
.globl persist_recarregar

# Torna a rotina de formatação volátil acessível aos outros módulos
.globl persist_formatar



# Seleciona a seção de instruções
.text


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
    la      $t0, persist_descritor

    # Marca o descritor como fechado
    li      $t1, -1

    # Salva o valor inicial do descritor
    sw      $t1, 0($t0)

    # Retorna sucesso
    li      $v0, OK

    # Retorna ao módulo chamador
    jr      $ra


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
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno
    sw      $ra, 12($sp)

    # Salva o descritor do arquivo
    sw      $s0, 8($sp)

    # Salva o ponteiro de destino da leitura
    sw      $s1, 4($sp)

    # Salva a quantidade de bytes ainda pendentes
    sw      $s2, 0($sp)

    # Carrega o nome do arquivo para o primeiro argumento
    la      $a0, persist_nome_arquivo

    # Define o modo de abertura como leitura
    li      $a1, 0

    # Mantém o terceiro argumento zerado
    li      $a2, 0

    # Seleciona a chamada de sistema para abrir arquivo
    li      $v0, 13

    # Tenta abrir o arquivo
    syscall

    # Um valor negativo indica falha na abertura
    bltz    $v0, persist_carregar_erro

    # Guarda o descritor retornado pelo MARS
    move    $s0, $v0

    # Atualiza o descritor global do módulo
    la      $t0, persist_descritor
    sw      $s0, 0($t0)

    # Carrega o endereço inicial da tabela de apartamentos
    la      $s1, apartamentos

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS

    # Carrega o tamanho de cada bloco
    li      $t1, TAM_BLOCO_AP

    # Calcula o total de bytes que precisam ser lidos
    mul     $s2, $t0, $t1


persist_carregar_loop:

    # Verifica se todos os bytes já foram lidos
    beq     $s2, $zero, persist_carregar_sucesso

    # Passa o descritor para a chamada de leitura
    move    $a0, $s0

    # Passa o endereço de destino da leitura
    move    $a1, $s1

    # Solicita no máximo a quantidade de bytes restantes
    move    $a2, $s2

    # Seleciona a chamada de sistema para ler arquivo
    li      $v0, 14

    # Lê uma parte do estado salvo
    syscall

    # Um valor negativo indica falha de leitura
    bltz    $v0, persist_carregar_erro_fechando

    # Zero antes do fim indica arquivo incompleto
    beq     $v0, $zero, persist_carregar_erro_fechando

    # Avança o ponteiro pelo número de bytes lidos
    addu    $s1, $s1, $v0

    # Remove da pendência os bytes que já foram lidos
    subu    $s2, $s2, $v0

    # Continua até preencher toda a tabela
    j       persist_carregar_loop


persist_carregar_sucesso:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16

    # Fecha o arquivo após a leitura completa
    syscall

    # Marca o descritor global como fechado
    la      $t0, persist_descritor
    li      $t1, -1
    sw      $t1, 0($t0)

    # Define o retorno de sucesso
    li      $v0, OK

    # Finaliza a rotina
    j       persist_carregar_finalizar


persist_carregar_erro_fechando:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16

    # Fecha o arquivo mesmo após uma falha
    syscall

    # Marca o descritor global como fechado
    la      $t0, persist_descritor
    li      $t1, -1
    sw      $t1, 0($t0)

    # Define o código de erro de arquivo
    li      $v0, ERRO_ARQUIVO

    # Finaliza a rotina
    j       persist_carregar_finalizar


persist_carregar_erro:

    # Define o código de erro quando a abertura falha
    li      $v0, ERRO_ARQUIVO


persist_carregar_finalizar:

    # Restaura a quantidade de bytes pendentes
    lw      $s2, 0($sp)

    # Restaura o ponteiro de destino
    lw      $s1, 4($sp)

    # Restaura o descritor
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno
    lw      $ra, 12($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16

    # Retorna ao módulo chamador
    jr      $ra


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
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno
    sw      $ra, 12($sp)

    # Salva o descritor do arquivo
    sw      $s0, 8($sp)

    # Salva o ponteiro de origem dos dados
    sw      $s1, 4($sp)

    # Salva a quantidade de bytes ainda pendentes
    sw      $s2, 0($sp)

    # Carrega o nome do arquivo
    la      $a0, persist_nome_arquivo

    # Define o modo de abertura como escrita
    li      $a1, 1

    # Mantém o terceiro argumento zerado
    li      $a2, 0

    # Seleciona a chamada de sistema para abrir arquivo
    li      $v0, 13

    # Abre ou cria o arquivo de persistência
    syscall

    # Um valor negativo indica falha na abertura
    bltz    $v0, persist_salvar_erro

    # Guarda o descritor retornado pelo MARS
    move    $s0, $v0

    # Atualiza o descritor global
    la      $t0, persist_descritor
    sw      $s0, 0($t0)

    # Carrega o endereço inicial da tabela
    la      $s1, apartamentos

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS

    # Carrega o tamanho de cada bloco
    li      $t1, TAM_BLOCO_AP

    # Calcula a quantidade total de bytes que será gravada
    mul     $s2, $t0, $t1


persist_salvar_loop:

    # Verifica se todos os bytes já foram gravados
    beq     $s2, $zero, persist_salvar_sucesso

    # Passa o descritor para a chamada de escrita
    move    $a0, $s0

    # Passa o endereço dos dados que serão gravados
    move    $a1, $s1

    # Informa a quantidade de bytes ainda pendentes
    move    $a2, $s2

    # Seleciona a chamada de sistema para escrever arquivo
    li      $v0, 15

    # Grava uma parte do estado em disco
    syscall

    # Um valor negativo indica falha de escrita
    bltz    $v0, persist_salvar_erro_fechando

    # Zero antes do fim indica que a escrita não avançou
    beq     $v0, $zero, persist_salvar_erro_fechando

    # Avança o ponteiro pelo número de bytes gravados
    addu    $s1, $s1, $v0

    # Remove da pendência os bytes já gravados
    subu    $s2, $s2, $v0

    # Continua até gravar todo o estado
    j       persist_salvar_loop


persist_salvar_sucesso:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16

    # Fecha o arquivo após a gravação
    syscall

    # Marca o descritor global como fechado
    la      $t0, persist_descritor
    li      $t1, -1
    sw      $t1, 0($t0)

    # Define o retorno de sucesso
    li      $v0, OK

    # Finaliza a rotina
    j       persist_salvar_finalizar


persist_salvar_erro_fechando:

    # Passa o descritor para a chamada de fechamento
    move    $a0, $s0

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16

    # Fecha o arquivo mesmo após uma falha
    syscall

    # Marca o descritor global como fechado
    la      $t0, persist_descritor
    li      $t1, -1
    sw      $t1, 0($t0)

    # Define o código de erro de arquivo
    li      $v0, ERRO_ARQUIVO

    # Finaliza a rotina
    j       persist_salvar_finalizar


persist_salvar_erro:

    # Define o código de erro quando a abertura falha
    li      $v0, ERRO_ARQUIVO


persist_salvar_finalizar:

    # Restaura a quantidade de bytes pendentes
    lw      $s2, 0($sp)

    # Restaura o ponteiro de origem
    lw      $s1, 4($sp)

    # Restaura o descritor
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno
    lw      $ra, 12($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16

    # Retorna ao módulo chamador
    jr      $ra


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
    la      $t0, persist_descritor

    # Lê o descritor atualmente armazenado
    lw      $t1, 0($t0)

    # Carrega o valor usado para indicar descritor fechado
    li      $t2, -1

    # Se já estiver fechado, não executa outra chamada de sistema
    beq     $t1, $t2, persist_encerrar_sucesso

    # Passa o descritor para a chamada de fechamento
    move    $a0, $t1

    # Seleciona a chamada de sistema para fechar arquivo
    li      $v0, 16

    # Fecha o arquivo ainda aberto
    syscall

    # Marca o descritor como fechado
    sw      $t2, 0($t0)


persist_encerrar_sucesso:

    # Retorna sucesso
    li      $v0, OK

    # Retorna ao módulo chamador
    jr      $ra


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

    # Reserva espaço na pilha para o endereço de retorno
    addiu   $sp, $sp, -4

    # Salva o endereço de retorno
    sw      $ra, 0($sp)

    # Invoca o carregamento dos registros a partir do arquivo
    jal     persist_carregar

    # Restaura o endereço de retorno
    lw      $ra, 0($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 4

    # Retorna o status resultante em $v0
    jr      $ra


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

    # Reserva espaço na pilha para o endereço de retorno
    addiu   $sp, $sp, -4

    # Salva o endereço de retorno
    sw      $ra, 0($sp)

    # Reinicializa toda a tabela de apartamentos em memória
    jal     dados_inicializar

    # Restaura o endereço de retorno
    lw      $ra, 0($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 4

    # Define o retorno de sucesso
    li      $v0, OK

    # Retorna ao módulo chamador
    jr      $ra