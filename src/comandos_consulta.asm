# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Erik Vinicius Gomes de Lima
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores (UFRPE - 2026.2)
# Professor: Prof. Vítor A Coutinho
# Arquivo: comandos_consulta.asm
# Descrição: consultas formatadas de apartamentos (infoAp, --all) e panorama geral (infoGeral)
# ============================================================
.data  # Seleciona a seção de dados estáticos.

# Título exibido antes da listagem geral dos apartamentos
texto_consulta_apartamentos: .asciiz "\n=== Apartamentos ===\n"  # Define em texto_consulta_apartamentos uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Texto usado antes do número de cada apartamento
texto_ap: .asciiz "AP "  # Define em texto_ap uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Separador e descrição da quantidade de moradores
texto_moradores: .asciiz " | moradores: "  # Define em texto_moradores uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Separador e descrição da quantidade de automóveis
texto_autos: .asciiz " | autos: "  # Define em texto_autos uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Título exibido antes da listagem de moradores
texto_consulta_moradores: .asciiz "\n=== Moradores do AP "  # Define em texto_consulta_moradores uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Título exibido antes da listagem de automóveis
texto_consulta_automoveis: .asciiz "\n=== Automoveis do AP "  # Define em texto_consulta_automoveis uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Final dos títulos que exibem o número do apartamento
texto_fim_titulo: .asciiz " ===\n"  # Define em texto_fim_titulo uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Mensagem usada quando não há moradores cadastrados
texto_sem_moradores: .asciiz "Nenhum morador cadastrado\n"  # Define em texto_sem_moradores uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Mensagem usada quando não há automóveis cadastrados
texto_sem_automoveis: .asciiz "Nenhum automovel cadastrado\n"  # Define em texto_sem_automoveis uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Texto que identifica o tipo de automóvel
texto_tipo: .asciiz " | tipo: "  # Define em texto_tipo uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Texto usado para identificar um carro
texto_carro: .asciiz "carro"  # Define em texto_carro uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Texto usado para identificar uma moto
texto_moto: .asciiz "moto"  # Define em texto_moto uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Marcador visual de cada registro listado
texto_item: .asciiz " - "  # Define em texto_item uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Texto que identifica a placa do veículo
texto_placa: .asciiz " | placa: "  # Define em texto_placa uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Quebra de linha usada nas listagens
texto_quebra: .asciiz "\n"  # Define em texto_quebra uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Textos padronizados para o comando infoAp (cmd_6)
texto_info_ap_rotulo:        .asciiz "AP: "  # Define em texto_info_ap_rotulo uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_ap_vazio:         .asciiz "Apartamento vazio\n"  # Define em texto_info_ap_vazio uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_ap_moradores:     .asciiz "Moradores:\n"  # Define em texto_info_ap_moradores uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_ap_carro:         .asciiz "Carro:\n"  # Define em texto_info_ap_carro uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_ap_moto:          .asciiz "Moto:\n"  # Define em texto_info_ap_moto uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_ap_separador:     .asciiz " / "  # Define em texto_info_ap_separador uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Textos padronizados para o comando infoGeral (cmd_7)
texto_info_geral_nao_vazios: .asciiz "Nao vazios: "  # Define em texto_info_geral_nao_vazios uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_geral_vazios:     .asciiz "Vazios: "  # Define em texto_info_geral_vazios uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_geral_espaco:     .asciiz " ("  # Define em texto_info_geral_espaco uma string terminada em nulo usada pelas mensagens/dados do módulo.
texto_info_geral_porcento:   .asciiz "%)\n"  # Define em texto_info_geral_porcento uma string terminada em nulo usada pelas mensagens/dados do módulo.


# ------------------------------------------------------------
# ROTINAS PÚBLICAS
# ------------------------------------------------------------

# Torna a rotina de listagem de apartamentos acessível aos outros módulos
.globl consulta_listar_apartamentos  # Exporta consulta_listar_apartamentos para uso como símbolo global.

# Torna a rotina de listagem de moradores acessível aos outros módulos
.globl consulta_listar_moradores  # Exporta consulta_listar_moradores para uso como símbolo global.

# Torna a rotina de listagem de automóveis acessível aos outros módulos
.globl consulta_listar_automoveis  # Exporta consulta_listar_automoveis para uso como símbolo global.

# Torna a rotina de busca de moradores acessível aos outros módulos
.globl consulta_buscar_morador  # Exporta consulta_buscar_morador para uso como símbolo global.

# Torna a rotina de busca de automóveis acessível aos outros módulos
.globl consulta_buscar_auto  # Exporta consulta_buscar_auto para uso como símbolo global.

# Torna a rotina infoAp acessível ao shell
.globl consulta_info_ap  # Exporta consulta_info_ap para uso como símbolo global.

# Torna a rotina infoGeral acessível ao shell
.globl consulta_info_geral  # Exporta consulta_info_geral para uso como símbolo global.


# Seleciona a seção de instruções
.text  # Seleciona a seção de instruções executáveis.



# ------------------------------------------------------------
# consulta_listar_apartamentos()
#
# Lista os 24 apartamentos e suas quantidades cadastradas
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

consulta_listar_apartamentos:

    # Reserva espaço para o endereço de retorno e os registradores salvos (16 bytes, múltiplo de 8)
    addiu   $sp, $sp, -16  # Reserva espaço de pilha ajustando $sp em -16 bytes.

    # Salva o endereço de retorno da rotina
    sw $ra, 12($sp)  # Armazena palavra de $ra na posição de memória 12($sp).

    # Salva o registrador usado como ponteiro de memória
    sw $s0, 8($sp)  # Armazena palavra de $s0 na posição de memória 8($sp).

    # Salva o registrador usado como contador de apartamentos
    sw $s1, 4($sp)  # Armazena palavra de $s1 na posição de memória 4($sp).

    # Seleciona o serviço de impressão de string do MARS
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o título da listagem geral
    la      $a0, texto_consulta_apartamentos  # Carrega em $a0 o endereço texto_consulta_apartamentos para passá-lo como argumento.

    # Exibe o título no terminal
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Carrega o endereço do primeiro bloco de apartamento
    la      $s0, apartamentos  # Obtém o endereço de apartamentos e o coloca em $s0.

    # Inicia o índice dos apartamentos em zero
    li      $s1, 0  # Carrega o valor imediato 0 no registrador $s1.


consulta_listar_apartamentos_loop:

    # Carrega a quantidade total de apartamentos em um registrador
    li      $t0, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t0.

    # Encerra quando todos os apartamentos forem percorridos
    bge     $s1, $t0, consulta_listar_apartamentos_finalizar  # Se $s1 e $t0 forem maior ou igual a, desvia para consulta_listar_apartamentos_finalizar.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o texto que antecede o número do apartamento
    la      $a0, texto_ap  # Carrega em $a0 o endereço texto_ap para passá-lo como argumento.

    # Exibe o prefixo AP
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.

    # Lê o número armazenado no cabeçalho do bloco
    lw $a0, OFFSET_AP_NUMERO($s0)  # Carrega palavra da posição OFFSET_AP_NUMERO($s0) para $a0.

    # Exibe o número do apartamento
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o texto que identifica a quantidade de moradores
    la      $a0, texto_moradores  # Carrega em $a0 o endereço texto_moradores para passá-lo como argumento.

    # Exibe o separador dos moradores
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.

    # Lê a quantidade de moradores do cabeçalho
    lw $a0, OFFSET_AP_QTD_MORADORES($s0)  # Carrega palavra da posição OFFSET_AP_QTD_MORADORES($s0) para $a0.

    # Exibe a quantidade de moradores
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o texto que identifica a quantidade de veículos
    la      $a0, texto_autos  # Carrega em $a0 o endereço texto_autos para passá-lo como argumento.

    # Exibe o separador dos automóveis
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.

    # Lê a quantidade de veículos do cabeçalho
    lw $a0, OFFSET_AP_QTD_AUTOS($s0)  # Carrega palavra da posição OFFSET_AP_QTD_AUTOS($s0) para $a0.

    # Exibe a quantidade de veículos
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega uma quebra de linha
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.

    # Finaliza a linha atual
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP  # Soma $s0 e TAM_BLOCO_AP, gravando o resultado em $s0.

    # Avança para o próximo índice
    addiu   $s1, $s1, 1  # Soma $s1 e 1, gravando o resultado em $s1.

    # Continua a listagem dos apartamentos
    j       consulta_listar_apartamentos_loop  # Desvia a execução incondicionalmente para consulta_listar_apartamentos_loop.


consulta_listar_apartamentos_finalizar:

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Restaura o contador de apartamentos
    lw $s1, 4($sp)  # Carrega palavra da posição 4($sp) para $s1.

    # Restaura o ponteiro dos blocos
    lw $s0, 8($sp)  # Carrega palavra da posição 8($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 12($sp)  # Carrega palavra da posição 12($sp) para $ra.

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 16  # Libera espaço de pilha ajustando $sp em 16 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# consulta_listar_moradores()
#
# Entrada:
#   $a0 = número do apartamento
#
# Retorno:
#   $v0 = OK ou AP_INVALIDO
# ------------------------------------------------------------

consulta_listar_moradores:

    # Reserva espaço para o endereço de retorno e os registradores salvos (24 bytes, múltiplo de 8)
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva o endereço do bloco do apartamento
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).

    # Salva o número do apartamento recebido
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).

    # Salva a quantidade de moradores
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).

    # Salva o índice do morador atual
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Guarda o número do apartamento para uso posterior
    move    $s1, $a0  # Copia o valor de $a0 para $s1.

    # Procura o bloco correspondente ao apartamento
    jal     dados_obter_ap  # Chama a rotina dados_obter_ap e salva o endereço de retorno em $ra.

    # Encerra caso o apartamento seja inválido
    bne     $v0, $zero, consulta_listar_moradores_finalizar  # Se $v0 e $zero forem diferentes, desvia para consulta_listar_moradores_finalizar.

    # Guarda o endereço do bloco encontrado
    move    $s0, $v1  # Copia o valor de $v1 para $s0.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o início do título da consulta
    la      $a0, texto_consulta_moradores  # Carrega em $a0 o endereço texto_consulta_moradores para passá-lo como argumento.

    # Exibe o início do título
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.

    # Passa o número do apartamento para a impressão
    move    $a0, $s1  # Copia o valor de $s1 para $a0.

    # Exibe o número do apartamento
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona novamente o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o final do título
    la      $a0, texto_fim_titulo  # Carrega em $a0 o endereço texto_fim_titulo para passá-lo como argumento.

    # Finaliza o título no terminal
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Lê a quantidade de moradores do apartamento
    lw $s2, OFFSET_AP_QTD_MORADORES($s0)  # Carrega palavra da posição OFFSET_AP_QTD_MORADORES($s0) para $s2.

    # Verifica se a lista está vazia
    beq     $s2, $zero, consulta_moradores_vazia  # Se $s2 e $zero forem iguais, desvia para consulta_moradores_vazia.

    # Começa pelo primeiro morador
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.


consulta_listar_moradores_loop:

    # Verifica se todos os moradores já foram exibidos
    bge     $s3, $s2, consulta_listar_moradores_sucesso  # Se $s3 e $s2 forem maior ou igual a, desvia para consulta_listar_moradores_sucesso.

    # Carrega o tamanho do registro de morador
    li      $t0, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $t0.

    # Calcula o deslocamento do morador atual
    mul     $t1, $s3, $t0  # Multiplica $s3 por $t0 e grava o produto em $t1.

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES  # Soma $s0 e OFFSET_AP_MORADORES, gravando o resultado em $t2.

    # Calcula o endereço do nome atual
    addu    $a0, $t2, $t1  # Soma $t2 e $t1, gravando o resultado em $a0.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Exibe o nome do morador
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega uma quebra de linha
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.

    # Finaliza a linha do morador
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Avança para o próximo morador
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua a listagem
    j       consulta_listar_moradores_loop  # Desvia a execução incondicionalmente para consulta_listar_moradores_loop.


consulta_moradores_vazia:

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega a mensagem de lista vazia
    la      $a0, texto_sem_moradores  # Carrega em $a0 o endereço texto_sem_moradores para passá-lo como argumento.

    # Informa que não existem moradores
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.


consulta_listar_moradores_sucesso:

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.


consulta_listar_moradores_finalizar:

    # Restaura o índice do morador
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.

    # Restaura a quantidade de moradores
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.

    # Restaura o número do apartamento
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.

    # Restaura o endereço do bloco
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# consulta_listar_automoveis()
#
# Entrada:
#   $a0 = número do apartamento
#
# Retorno:
#   $v0 = OK ou AP_INVALIDO
# ------------------------------------------------------------

consulta_listar_automoveis:

    # Reserva espaço para o endereço de retorno e os registradores salvos (24 bytes, múltiplo de 8)
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva o endereço do bloco
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).

    # Salva o número do apartamento
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).

    # Salva a quantidade de veículos
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).

    # Salva o índice do veículo atual
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Guarda o número do apartamento
    move    $s1, $a0  # Copia o valor de $a0 para $s1.

    # Procura o bloco do apartamento
    jal     dados_obter_ap  # Chama a rotina dados_obter_ap e salva o endereço de retorno em $ra.

    # Encerra caso o apartamento seja inválido
    bne     $v0, $zero, consulta_listar_automoveis_finalizar  # Se $v0 e $zero forem diferentes, desvia para consulta_listar_automoveis_finalizar.

    # Guarda o endereço do bloco encontrado
    move    $s0, $v1  # Copia o valor de $v1 para $s0.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o início do título
    la      $a0, texto_consulta_automoveis  # Carrega em $a0 o endereço texto_consulta_automoveis para passá-lo como argumento.

    # Exibe o início do título
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.

    # Passa o número do apartamento
    move    $a0, $s1  # Copia o valor de $s1 para $a0.

    # Exibe o número do apartamento
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o final do título
    la      $a0, texto_fim_titulo  # Carrega em $a0 o endereço texto_fim_titulo para passá-lo como argumento.

    # Finaliza o título
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Lê a quantidade de veículos cadastrados
    lw $s2, OFFSET_AP_QTD_AUTOS($s0)  # Carrega palavra da posição OFFSET_AP_QTD_AUTOS($s0) para $s2.

    # Verifica se não há veículos cadastrados
    beq     $s2, $zero, consulta_automoveis_vazia  # Se $s2 e $zero forem iguais, desvia para consulta_automoveis_vazia.

    # Exibe o texto que identifica o tipo do veículo
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    la      $a0, texto_tipo  # Carrega em $a0 o endereço texto_tipo para passá-lo como argumento.
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Lê o tipo armazenado no cabeçalho
    lw $t0, OFFSET_AP_TIPO_AUTO($s0)  # Carrega palavra da posição OFFSET_AP_TIPO_AUTO($s0) para $t0.

    # Carrega o código correspondente ao carro
    li      $t1, TIPO_AUTO_CARRO  # Carrega o valor imediato TIPO_AUTO_CARRO no registrador $t1.

    # Direciona para a impressão de carro quando os códigos forem iguais
    beq     $t0, $t1, consulta_imprimir_tipo_carro  # Se $t0 e $t1 forem iguais, desvia para consulta_imprimir_tipo_carro.

    # Caso contrário, utiliza o texto correspondente à moto
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    la      $a0, texto_moto  # Carrega em $a0 o endereço texto_moto para passá-lo como argumento.
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Exibe uma quebra após o tipo
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Começa a listagem pelo primeiro veículo
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.

    # Continua no laço principal dos veículos
    j       consulta_listar_automoveis_loop  # Desvia a execução incondicionalmente para consulta_listar_automoveis_loop.


consulta_imprimir_tipo_carro:

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o texto carro
    la      $a0, texto_carro  # Carrega em $a0 o endereço texto_carro para passá-lo como argumento.

    # Exibe o tipo do veículo
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Exibe uma quebra após o tipo
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Começa a listagem pelo primeiro veículo
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.


consulta_listar_automoveis_loop:

    # Verifica se todos os veículos já foram exibidos
    bge     $s3, $s2, consulta_listar_automoveis_sucesso  # Se $s3 e $s2 forem maior ou igual a, desvia para consulta_listar_automoveis_sucesso.

    # Exibe o marcador do registro atual
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    la      $a0, texto_item  # Carrega em $a0 o endereço texto_item para passá-lo como argumento.
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Carrega o tamanho de um registro de veículo
    li      $t0, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $t0.

    # Calcula o deslocamento do veículo atual
    mul     $t1, $s3, $t0  # Multiplica $s3 por $t0 e grava o produto em $t1.

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $t2.

    # Calcula o endereço do registro atual
    addu    $t2, $t2, $t1  # Soma $t2 e $t1, gravando o resultado em $t2.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Passa o endereço do modelo para impressão
    move    $a0, $t2  # Copia o valor de $t2 para $a0.

    # Exibe o modelo
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega o texto da placa
    la      $a0, texto_placa  # Carrega em $a0 o endereço texto_placa para passá-lo como argumento.

    # Exibe o separador da placa
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Avança até o campo da placa no registro
    addiu   $a0, $t2, TAM_MODELO  # Soma $t2 e TAM_MODELO, gravando o resultado em $a0.

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Exibe a placa cadastrada
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Exibe uma quebra de linha
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Avança para o próximo veículo
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua a listagem
    j       consulta_listar_automoveis_loop  # Desvia a execução incondicionalmente para consulta_listar_automoveis_loop.


consulta_automoveis_vazia:

    # Seleciona o serviço de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Carrega a mensagem de lista vazia
    la      $a0, texto_sem_automoveis  # Carrega em $a0 o endereço texto_sem_automoveis para passá-lo como argumento.

    # Informa que não existem veículos cadastrados
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.


consulta_listar_automoveis_sucesso:

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.


consulta_listar_automoveis_finalizar:

    # Restaura o índice do veículo
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.

    # Restaura a quantidade de veículos
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.

    # Restaura o número do apartamento
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.

    # Restaura o endereço do bloco
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# consulta_buscar_morador()
#
# Entrada:
#   $a0 = endereço do nome procurado
#
# Saída:
#   $v0 = OK ou MORADOR_NAO_ENCONTRADO
#   $v1 = número do apartamento encontrado
# ------------------------------------------------------------

consulta_buscar_morador:

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva o ponteiro do bloco atual
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).

    # Salva o endereço do nome procurado
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).

    # Salva o índice do apartamento atual
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).

    # Salva o índice do morador atual
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Salva a quantidade de moradores do bloco
    sw $s4, 0($sp)  # Armazena palavra de $s4 na posição de memória 0($sp).

    # Garante que o segundo retorno seja zero quando não houver resultado
    move    $v1, $zero  # Copia o valor de $zero para $v1.

    # Guarda o endereço do nome procurado
    move    $s1, $a0  # Copia o valor de $a0 para $s1.

    # Começa pelo primeiro apartamento
    li      $s2, 0  # Carrega o valor imediato 0 no registrador $s2.

    # Carrega o início da tabela de apartamentos
    la      $s0, apartamentos  # Obtém o endereço de apartamentos e o coloca em $s0.


consulta_buscar_morador_apartamento:

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t0.

    # Encerra quando todos os blocos forem examinados
    bge     $s2, $t0, consulta_morador_nao_encontrado  # Se $s2 e $t0 forem maior ou igual a, desvia para consulta_morador_nao_encontrado.

    # Lê a quantidade de moradores do bloco atual
    lw $s4, OFFSET_AP_QTD_MORADORES($s0)  # Carrega palavra da posição OFFSET_AP_QTD_MORADORES($s0) para $s4.

    # Inicia a busca pelo primeiro morador
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.


consulta_buscar_morador_loop:

    # Verifica se todos os moradores do bloco foram examinados
    bge     $s3, $s4, consulta_proximo_apartamento_morador  # Se $s3 e $s4 forem maior ou igual a, desvia para consulta_proximo_apartamento_morador.

    # Carrega o tamanho de um registro de morador
    li      $t0, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $t0.

    # Calcula o deslocamento do morador atual
    mul     $t1, $s3, $t0  # Multiplica $s3 por $t0 e grava o produto em $t1.

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES  # Soma $s0 e OFFSET_AP_MORADORES, gravando o resultado em $t2.

    # Calcula o endereço do nome armazenado
    addu    $a0, $t2, $t1  # Soma $t2 e $t1, gravando o resultado em $a0.

    # Recupera o endereço do nome procurado
    move    $a1, $s1  # Copia o valor de $s1 para $a1.

    # Informa o tamanho máximo da comparação
    li      $a2, TAM_NOME  # Carrega o valor imediato TAM_NOME no registrador $a2.

    # Compara o nome armazenado com o nome procurado
    jal     cadastro_strings_iguais  # Chama a rotina cadastro_strings_iguais e salva o endereço de retorno em $ra.

    # Continua a busca quando os nomes forem diferentes
    beq     $v0, $zero, consulta_proximo_morador  # Se $v0 e $zero forem iguais, desvia para consulta_proximo_morador.

    # Lê o número do apartamento onde o nome foi encontrado
    lw $v1, OFFSET_AP_NUMERO($s0)  # Carrega palavra da posição OFFSET_AP_NUMERO($s0) para $v1.

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Finaliza a busca
    j       consulta_buscar_morador_finalizar  # Desvia a execução incondicionalmente para consulta_buscar_morador_finalizar.


consulta_proximo_morador:

    # Avança para o próximo morador do bloco
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua a busca no mesmo apartamento
    j       consulta_buscar_morador_loop  # Desvia a execução incondicionalmente para consulta_buscar_morador_loop.


consulta_proximo_apartamento_morador:

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP  # Soma $s0 e TAM_BLOCO_AP, gravando o resultado em $s0.

    # Avança para o próximo índice de apartamento
    addiu   $s2, $s2, 1  # Soma $s2 e 1, gravando o resultado em $s2.

    # Continua a busca nos blocos restantes
    j       consulta_buscar_morador_apartamento  # Desvia a execução incondicionalmente para consulta_buscar_morador_apartamento.


consulta_morador_nao_encontrado:

    # Informa que nenhum morador correspondeu ao nome
    li      $v0, MORADOR_NAO_ENCONTRADO  # Carrega o valor imediato MORADOR_NAO_ENCONTRADO no registrador $v0.


consulta_buscar_morador_finalizar:

    # Restaura a quantidade de moradores
    lw $s4, 0($sp)  # Carrega palavra da posição 0($sp) para $s4.

    # Restaura o índice do morador
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.

    # Restaura o índice do apartamento
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.

    # Restaura o endereço do nome
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.

    # Restaura o ponteiro do bloco
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# consulta_buscar_auto()
#
# Entrada:
#   $a0 = endereço da placa procurada
#
# Saída:
#   $v0 = OK ou AUTO_NAO_ENCONTRADO
#   $v1 = número do apartamento encontrado
# ------------------------------------------------------------

consulta_buscar_auto:

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva o ponteiro do bloco atual
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).

    # Salva o endereço da placa procurada
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).

    # Salva o índice do apartamento atual
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).

    # Salva o índice do veículo atual
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Salva a quantidade de veículos do bloco
    sw $s4, 0($sp)  # Armazena palavra de $s4 na posição de memória 0($sp).

    # Garante que o segundo retorno seja zero quando não houver resultado
    move    $v1, $zero  # Copia o valor de $zero para $v1.

    # Guarda o endereço da placa procurada
    move    $s1, $a0  # Copia o valor de $a0 para $s1.

    # Começa pelo primeiro apartamento
    li      $s2, 0  # Carrega o valor imediato 0 no registrador $s2.

    # Carrega o início da tabela de apartamentos
    la      $s0, apartamentos  # Obtém o endereço de apartamentos e o coloca em $s0.


consulta_buscar_auto_apartamento:

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t0.

    # Encerra quando todos os blocos forem examinados
    bge     $s2, $t0, consulta_auto_nao_encontrado  # Se $s2 e $t0 forem maior ou igual a, desvia para consulta_auto_nao_encontrado.

    # Lê a quantidade de veículos do bloco atual
    lw $s4, OFFSET_AP_QTD_AUTOS($s0)  # Carrega palavra da posição OFFSET_AP_QTD_AUTOS($s0) para $s4.

    # Inicia a busca pelo primeiro veículo
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.


consulta_buscar_auto_loop:

    # Verifica se todos os veículos do bloco foram examinados
    bge     $s3, $s4, consulta_proximo_apartamento_auto  # Se $s3 e $s4 forem maior ou igual a, desvia para consulta_proximo_apartamento_auto.

    # Carrega o tamanho de um registro de veículo
    li      $t0, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $t0.

    # Calcula o deslocamento do veículo atual
    mul     $t1, $s3, $t0  # Multiplica $s3 por $t0 e grava o produto em $t1.

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $t2.

    # Calcula o endereço do registro atual
    addu    $t2, $t2, $t1  # Soma $t2 e $t1, gravando o resultado em $t2.

    # Avança até o campo da placa
    addiu   $a0, $t2, TAM_MODELO  # Soma $t2 e TAM_MODELO, gravando o resultado em $a0.

    # Recupera o endereço da placa procurada
    move    $a1, $s1  # Copia o valor de $s1 para $a1.

    # Informa o tamanho máximo da comparação
    li      $a2, TAM_PLACA  # Carrega o valor imediato TAM_PLACA no registrador $a2.

    # Compara a placa armazenada com a placa procurada
    jal     cadastro_strings_iguais  # Chama a rotina cadastro_strings_iguais e salva o endereço de retorno em $ra.

    # Continua a busca quando as placas forem diferentes
    beq     $v0, $zero, consulta_proximo_auto  # Se $v0 e $zero forem iguais, desvia para consulta_proximo_auto.

    # Lê o número do apartamento onde a placa foi encontrada
    lw $v1, OFFSET_AP_NUMERO($s0)  # Carrega palavra da posição OFFSET_AP_NUMERO($s0) para $v1.

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Finaliza a busca
    j       consulta_buscar_auto_finalizar  # Desvia a execução incondicionalmente para consulta_buscar_auto_finalizar.


consulta_proximo_auto:

    # Avança para o próximo veículo
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua a busca no mesmo apartamento
    j       consulta_buscar_auto_loop  # Desvia a execução incondicionalmente para consulta_buscar_auto_loop.


consulta_proximo_apartamento_auto:

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP  # Soma $s0 e TAM_BLOCO_AP, gravando o resultado em $s0.

    # Avança para o próximo índice de apartamento
    addiu   $s2, $s2, 1  # Soma $s2 e 1, gravando o resultado em $s2.

    # Continua a busca nos blocos restantes
    j       consulta_buscar_auto_apartamento  # Desvia a execução incondicionalmente para consulta_buscar_auto_apartamento.


consulta_auto_nao_encontrado:

    # Informa que nenhuma placa correspondeu à busca
    li      $v0, AUTO_NAO_ENCONTRADO  # Carrega o valor imediato AUTO_NAO_ENCONTRADO no registrador $v0.


consulta_buscar_auto_finalizar:

    # Restaura a quantidade de veículos
    lw $s4, 0($sp)  # Carrega palavra da posição 0($sp) para $s4.

    # Restaura o índice do veículo
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.

    # Restaura o índice do apartamento
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.

    # Restaura o endereço da placa
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.

    # Restaura o ponteiro do bloco
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# consulta_info_ap()
#
# Imprime as informações cadastradas de um apartamento ou de
# todos os apartamentos quando solicitado com --all (cmd_6)
#
# Entrada:
#   $a0 = número do apartamento (quando $a1 = 0)
#   $a1 = flag indicando se a listagem é geral (1 = --all, 0 = individual)
#
# Retorno:
#   $v0 = OK ou AP_INVALIDO
# ------------------------------------------------------------

consulta_info_ap:

    # Reserva espaço na pilha para registradores preservados e retorno
    addiu   $sp, $sp, -16  # Reserva espaço de pilha ajustando $sp em -16 bytes.

    # Salva o endereço de retorno da chamada
    sw $ra, 12($sp)  # Armazena palavra de $ra na posição de memória 12($sp).

    # Salva o registrador para o número do AP ou endereço de bloco
    sw $s0, 8($sp)  # Armazena palavra de $s0 na posição de memória 8($sp).

    # Salva o registrador que guarda a flag --all
    sw $s1, 4($sp)  # Armazena palavra de $s1 na posição de memória 4($sp).

    # Salva o contador de iteração
    sw $s2, 0($sp)  # Armazena palavra de $s2 na posição de memória 0($sp).

    # Copia o número do AP recebido
    move    $s0, $a0  # Copia o valor de $a0 para $s0.

    # Copia a flag indicativa da opção --all
    move    $s1, $a1  # Copia o valor de $a1 para $s1.

    # Desvia caso a flag solicite listar todos os apartamentos
    bne     $s1, $zero, consulta_info_ap_todos  # Se $s1 e $zero forem diferentes, desvia para consulta_info_ap_todos.

    # Busca o endereço do bloco do apartamento especificado
    move    $a0, $s0  # Copia o valor de $s0 para $a0.
    jal     dados_obter_ap  # Chama a rotina dados_obter_ap e salva o endereço de retorno em $ra.

    # Retorna erro caso o apartamento seja inválido
    bne     $v0, OK, consulta_info_ap_finalizar  # Se $v0 e OK forem diferentes, desvia para consulta_info_ap_finalizar.

    # Imprime os detalhes formatados do apartamento localizado em $v1
    move    $a0, $v1  # Copia o valor de $v1 para $a0.
    jal     consulta_imprimir_detalhes_ap  # Chama a rotina consulta_imprimir_detalhes_ap e salva o endereço de retorno em $ra.

    # Define retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Encerra o processamento individual
    j       consulta_info_ap_finalizar  # Desvia a execução incondicionalmente para consulta_info_ap_finalizar.


consulta_info_ap_todos:

    # Carrega o início da tabela de apartamentos
    la      $s0, apartamentos  # Obtém o endereço de apartamentos e o coloca em $s0.

    # Inicia o índice de controle em zero
    li      $s2, 0  # Carrega o valor imediato 0 no registrador $s2.


consulta_info_ap_todos_loop:

    # Carrega a quantidade total de 24 apartamentos
    li      $t0, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t0.

    # Encerra quando todos os blocos tiverem sido impressos
    bge     $s2, $t0, consulta_info_ap_todos_sucesso  # Se $s2 e $t0 forem maior ou igual a, desvia para consulta_info_ap_todos_sucesso.

    # Imprime os detalhes do apartamento apontado por $s0
    move    $a0, $s0  # Copia o valor de $s0 para $a0.
    jal     consulta_imprimir_detalhes_ap  # Chama a rotina consulta_imprimir_detalhes_ap e salva o endereço de retorno em $ra.

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP  # Soma $s0 e TAM_BLOCO_AP, gravando o resultado em $s0.

    # Incrementa o índice do loop
    addiu   $s2, $s2, 1  # Soma $s2 e 1, gravando o resultado em $s2.

    # Continua para o próximo apartamento
    j       consulta_info_ap_todos_loop  # Desvia a execução incondicionalmente para consulta_info_ap_todos_loop.


consulta_info_ap_todos_sucesso:

    # Define retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.


consulta_info_ap_finalizar:

    # Restaura o contador de iteração
    lw $s2, 0($sp)  # Carrega palavra da posição 0($sp) para $s2.

    # Restaura a flag da opção --all
    lw $s1, 4($sp)  # Carrega palavra da posição 4($sp) para $s1.

    # Restaura o registrador $s0
    lw $s0, 8($sp)  # Carrega palavra da posição 8($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 12($sp)  # Carrega palavra da posição 12($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16  # Libera espaço de pilha ajustando $sp em 16 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# consulta_imprimir_detalhes_ap()
#
# Renderiza a estrutura textual de um único apartamento
# Entrada:
#   $a0 = endereço base do bloco do apartamento
# ------------------------------------------------------------

consulta_imprimir_detalhes_ap:

    # Reserva espaço para o endereço de retorno e registradores salvos
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno da sub-rotina
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva o ponteiro do bloco do apartamento
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).

    # Salva a quantidade de moradores
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).

    # Salva o índice de iteração
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).

    # Salva o ponteiro do item atual
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Salva registrador auxiliar para contadores
    sw $s4, 0($sp)  # Armazena palavra de $s4 na posição de memória 0($sp).

    # Guarda o endereço base do bloco
    move    $s0, $a0  # Copia o valor de $a0 para $s0.

    # Imprime o rótulo "AP: " via camada de I/O
    la      $a0, texto_info_ap_rotulo  # Carrega em $a0 o endereço texto_info_ap_rotulo para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime o número do apartamento armazenado no cabeçalho via I/O
    lw $a0, OFFSET_AP_NUMERO($s0)  # Carrega palavra da posição OFFSET_AP_NUMERO($s0) para $a0.
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int  # Chama a rotina shell_io_imprimir_int e salva o endereço de retorno em $ra.

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Lê a quantidade de moradores cadastrados
    lw $s1, OFFSET_AP_QTD_MORADORES($s0)  # Carrega palavra da posição OFFSET_AP_QTD_MORADORES($s0) para $s1.

    # Se a quantidade for maior que zero, desvia para listar moradores
    bnez    $s1, consulta_detalhes_nao_vazio

    # Apartamento vazio: imprime "Apartamento vazio\n" via I/O
    la      $a0, texto_info_ap_vazio  # Carrega em $a0 o endereço texto_info_ap_vazio para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Encerra a impressão deste apartamento
    j       consulta_detalhes_finalizar  # Desvia a execução incondicionalmente para consulta_detalhes_finalizar.


consulta_detalhes_nao_vazio:

    # Imprime o título "Moradores:\n" via camada de I/O
    la      $a0, texto_info_ap_moradores  # Carrega em $a0 o endereço texto_info_ap_moradores para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Inicia o índice de moradores em zero
    li      $s2, 0  # Carrega o valor imediato 0 no registrador $s2.

    # Carrega o endereço do primeiro morador
    addiu   $s3, $s0, OFFSET_AP_MORADORES  # Soma $s0 e OFFSET_AP_MORADORES, gravando o resultado em $s3.


consulta_detalhes_moradores_loop:

    # Verifica se já listou todos os moradores cadastrados
    bge     $s2, $s1, consulta_detalhes_veiculos  # Se $s2 e $s1 forem maior ou igual a, desvia para consulta_detalhes_veiculos.

    # Imprime o nome do morador atual via camada de I/O
    move    $a0, $s3  # Copia o valor de $s3 para $a0.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Avança para o próximo registro de morador
    addiu   $s3, $s3, TAM_REGISTRO_MORADOR  # Soma $s3 e TAM_REGISTRO_MORADOR, gravando o resultado em $s3.

    # Incrementa o contador de moradores
    addiu   $s2, $s2, 1  # Soma $s2 e 1, gravando o resultado em $s2.

    # Continua o loop de moradores
    j       consulta_detalhes_moradores_loop  # Desvia a execução incondicionalmente para consulta_detalhes_moradores_loop.


consulta_detalhes_veiculos:

    # Lê a quantidade de veículos cadastrados
    lw $s2, OFFSET_AP_QTD_AUTOS($s0)  # Carrega palavra da posição OFFSET_AP_QTD_AUTOS($s0) para $s2.

    # Se não houver veículos cadastrados, encerra
    beqz    $s2, consulta_detalhes_finalizar

    # Lê o tipo de veículo do apartamento
    lw $s3, OFFSET_AP_TIPO_AUTO($s0)  # Carrega palavra da posição OFFSET_AP_TIPO_AUTO($s0) para $s3.

    # Compara se o tipo cadastrado é carro
    li      $t0, TIPO_AUTO_CARRO  # Carrega o valor imediato TIPO_AUTO_CARRO no registrador $t0.
    # Se for carro, desvia para impressao de carro
    beq     $s3, $t0, consulta_detalhes_carro  # Se $s3 e $t0 forem iguais, desvia para consulta_detalhes_carro.

    # Compara se o tipo cadastrado é moto
    li      $t0, TIPO_AUTO_MOTO  # Carrega o valor imediato TIPO_AUTO_MOTO no registrador $t0.
    # Se for moto, desvia para impressao de moto
    beq     $s3, $t0, consulta_detalhes_moto  # Se $s3 e $t0 forem iguais, desvia para consulta_detalhes_moto.

    # Caso seja desconhecido, encerra
    j       consulta_detalhes_finalizar  # Desvia a execução incondicionalmente para consulta_detalhes_finalizar.


consulta_detalhes_carro:

    # Imprime o título "Carro:\n" via camada de I/O
    la      $a0, texto_info_ap_carro  # Carrega em $a0 o endereço texto_info_ap_carro para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime o modelo do carro via camada de I/O
    addiu   $a0, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $a0.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime o separador " / " via camada de I/O
    la      $a0, texto_info_ap_separador  # Carrega em $a0 o endereço texto_info_ap_separador para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime a placa do carro via camada de I/O
    addiu   $a0, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $a0.
    # Avanca o ponteiro para o campo da placa do automovel
    addiu   $a0, $a0, TAM_MODELO  # Soma $a0 e TAM_MODELO, gravando o resultado em $a0.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Encerra os detalhes do apartamento
    j       consulta_detalhes_finalizar  # Desvia a execução incondicionalmente para consulta_detalhes_finalizar.


consulta_detalhes_moto:

    # Imprime o título "Moto:\n" via camada de I/O
    la      $a0, texto_info_ap_moto  # Carrega em $a0 o endereço texto_info_ap_moto para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Inicia o índice de motos em zero
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.

    # Carrega o endereço do primeiro registro de veículo
    addiu   $s4, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $s4.


consulta_detalhes_moto_loop:

    # Verifica se já listou todas as motos cadastradas
    bge     $s3, $s2, consulta_detalhes_finalizar  # Se $s3 e $s2 forem maior ou igual a, desvia para consulta_detalhes_finalizar.

    # Imprime o modelo da moto via camada de I/O
    move    $a0, $s4  # Copia o valor de $s4 para $a0.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime o separador " / " via camada de I/O
    la      $a0, texto_info_ap_separador  # Carrega em $a0 o endereço texto_info_ap_separador para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime a placa da moto via camada de I/O
    addiu   $a0, $s4, TAM_MODELO  # Soma $s4 e TAM_MODELO, gravando o resultado em $a0.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra  # Carrega em $a0 o endereço texto_quebra para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Avança para o próximo registro de veículo
    addiu   $s4, $s4, TAM_REGISTRO_AUTO  # Soma $s4 e TAM_REGISTRO_AUTO, gravando o resultado em $s4.

    # Incrementa o contador de motos impressas
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua o loop de motos
    j       consulta_detalhes_moto_loop  # Desvia a execução incondicionalmente para consulta_detalhes_moto_loop.


consulta_detalhes_finalizar:

    # Restaura o registrador $s4
    lw $s4, 0($sp)  # Carrega palavra da posição 0($sp) para $s4.

    # Restaura o ponteiro de item $s3
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.

    # Restaura o contador $s2
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.

    # Restaura a quantidade de moradores $s1
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.

    # Restaura o ponteiro do bloco $s0
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna à rotina chamadora
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# consulta_info_geral()
#
# Calcula e imprime o panorama geral de apartamentos vazios
# e não vazios com contagem absoluta e percentual (cmd_7)
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

consulta_info_geral:

    # Reserva espaço na pilha para o endereço de retorno e registradores salvos
    addiu   $sp, $sp, -16  # Reserva espaço de pilha ajustando $sp em -16 bytes.

    # Salva o endereço de retorno
    sw $ra, 12($sp)  # Armazena palavra de $ra na posição de memória 12($sp).

    # Salva o contador de não vazios
    sw $s0, 8($sp)  # Armazena palavra de $s0 na posição de memória 8($sp).

    # Salva o contador de vazios
    sw $s1, 4($sp)  # Armazena palavra de $s1 na posição de memória 4($sp).

    # Salva o registrador de percentual
    sw $s2, 0($sp)  # Armazena palavra de $s2 na posição de memória 0($sp).

    # Inicializa o contador de não vazios com zero
    li      $s0, 0  # Carrega o valor imediato 0 no registrador $s0.

    # Inicializa o contador de vazios com zero
    li      $s1, 0  # Carrega o valor imediato 0 no registrador $s1.

    # Carrega o início da tabela de apartamentos
    la      $t0, apartamentos  # Obtém o endereço de apartamentos e o coloca em $t0.

    # Inicializa o índice do loop com zero
    li      $t1, 0  # Carrega o valor imediato 0 no registrador $t1.


consulta_info_geral_loop:

    # Carrega a quantidade total de apartamentos
    li      $t2, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t2.

    # Conclui a varredura ao atingir os 24 apartamentos
    bge     $t1, $t2, consulta_info_geral_calculo  # Se $t1 e $t2 forem maior ou igual a, desvia para consulta_info_geral_calculo.

    # Lê a quantidade de moradores do apartamento atual
    lw $t3, OFFSET_AP_QTD_MORADORES($t0)  # Carrega palavra da posição OFFSET_AP_QTD_MORADORES($t0) para $t3.

    # Se a quantidade for maior que zero, é classificado como não vazio
    bgtz    $t3, consulta_info_geral_ocupado  # Se $t3 for maior que zero, desvia para consulta_info_geral_ocupado.

    # Caso contrário, incrementa a contagem de vazios
    addiu   $s1, $s1, 1  # Soma $s1 e 1, gravando o resultado em $s1.

    # Desvia para o próximo apartamento
    j       consulta_info_geral_proximo  # Desvia a execução incondicionalmente para consulta_info_geral_proximo.


consulta_info_geral_ocupado:

    # Incrementa a contagem de apartamentos não vazios
    addiu   $s0, $s0, 1  # Soma $s0 e 1, gravando o resultado em $s0.


consulta_info_geral_proximo:

    # Avança para o próximo bloco de memória
    addiu   $t0, $t0, TAM_BLOCO_AP  # Soma $t0 e TAM_BLOCO_AP, gravando o resultado em $t0.

    # Incrementa o índice de controle
    addiu   $t1, $t1, 1  # Soma $t1 e 1, gravando o resultado em $t1.

    # Continua o loop
    j       consulta_info_geral_loop  # Desvia a execução incondicionalmente para consulta_info_geral_loop.


consulta_info_geral_calculo:

    # Multiplica a quantidade de não vazios por cem
    li      $t4, 100  # Carrega o valor imediato 100 no registrador $t4.
    # Multiplica quantidade de apartamentos ocupados por cem
    mul     $t5, $s0, $t4  # Multiplica $s0 por $t4 e grava o produto em $t5.

    # Divide pelo total de 24 apartamentos para obter a porcentagem inteira
    li      $t6, TOTAL_APARTAMENTOS  # Carrega o valor imediato TOTAL_APARTAMENTOS no registrador $t6.
    # Divide pelo total de 24 apartamentos para calcular percentual
    divu    $t5, $t6  # Divide $t5 por $t6; quociente vai para LO e resto vai para HI.

    # Obtém o percentual inteiro calculado
    mflo    $s2  # Copia o resultado armazenado em LO para $s2.

    # Imprime o texto "Nao vazios: " via camada de I/O
    la      $a0, texto_info_geral_nao_vazios  # Carrega em $a0 o endereço texto_info_geral_nao_vazios para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime a quantidade absoluta de não vazios via I/O
    move    $a0, $s0  # Copia o valor de $s0 para $a0.
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int  # Chama a rotina shell_io_imprimir_int e salva o endereço de retorno em $ra.

    # Imprime o caractere de abertura " (" via camada de I/O
    la      $a0, texto_info_geral_espaco  # Carrega em $a0 o endereço texto_info_geral_espaco para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime o percentual de não vazios via I/O
    move    $a0, $s2  # Copia o valor de $s2 para $a0.
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int  # Chama a rotina shell_io_imprimir_int e salva o endereço de retorno em $ra.

    # Imprime o sufixo "%)\n" via camada de I/O
    la      $a0, texto_info_geral_porcento  # Carrega em $a0 o endereço texto_info_geral_porcento para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Multiplica a quantidade de vazios por cem
    mul     $t5, $s1, $t4  # Multiplica $s1 por $t4 e grava o produto em $t5.

    # Divide por 24 para obter a porcentagem de vazios
    divu    $t5, $t6  # Divide $t5 por $t6; quociente vai para LO e resto vai para HI.

    # Obtém o percentual inteiro de vazios
    mflo    $s2  # Copia o resultado armazenado em LO para $s2.

    # Imprime o texto "Vazios: " via camada de I/O
    la      $a0, texto_info_geral_vazios  # Carrega em $a0 o endereço texto_info_geral_vazios para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime a quantidade absoluta de vazios via I/O
    move    $a0, $s1  # Copia o valor de $s1 para $a0.
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int  # Chama a rotina shell_io_imprimir_int e salva o endereço de retorno em $ra.

    # Imprime o caractere de abertura " (" via camada de I/O
    la      $a0, texto_info_geral_espaco  # Carrega em $a0 o endereço texto_info_geral_espaco para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Imprime o percentual de vazios via I/O
    move    $a0, $s2  # Copia o valor de $s2 para $a0.
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int  # Chama a rotina shell_io_imprimir_int e salva o endereço de retorno em $ra.

    # Imprime o sufixo "%)\n" via camada de I/O
    la      $a0, texto_info_geral_porcento  # Carrega em $a0 o endereço texto_info_geral_porcento para passá-lo como argumento.
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Define o retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Restaura o registrador de percentual
    lw $s2, 0($sp)  # Carrega palavra da posição 0($sp) para $s2.

    # Restaura o contador de vazios
    lw $s1, 4($sp)  # Carrega palavra da posição 4($sp) para $s1.

    # Restaura o contador de não vazios
    lw $s0, 8($sp)  # Carrega palavra da posição 8($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 12($sp)  # Carrega palavra da posição 12($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16  # Libera espaço de pilha ajustando $sp em 16 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.