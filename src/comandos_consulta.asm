
# Descrição: consultas e listagens dos apartamentos, moradores
#     	     e automóveis cadastrados


# ------------------------------------------------------------
# ÁREA DE DADOS DO MÓDULO
# ------------------------------------------------------------

.data

# Título exibido antes da listagem geral dos apartamentos
texto_consulta_apartamentos: .asciiz "\n=== Apartamentos ===\n"

# Texto usado antes do número de cada apartamento
texto_ap: .asciiz "AP "

# Separador e descrição da quantidade de moradores
texto_moradores: .asciiz " | moradores: "

# Separador e descrição da quantidade de automóveis
texto_autos: .asciiz " | autos: "

# Título exibido antes da listagem de moradores
texto_consulta_moradores: .asciiz "\n=== Moradores do AP "

# Título exibido antes da listagem de automóveis
texto_consulta_automoveis: .asciiz "\n=== Automoveis do AP "

# Final dos títulos que exibem o número do apartamento
texto_fim_titulo: .asciiz " ===\n"

# Mensagem usada quando não há moradores cadastrados
texto_sem_moradores: .asciiz "Nenhum morador cadastrado\n"

# Mensagem usada quando não há automóveis cadastrados
texto_sem_automoveis: .asciiz "Nenhum automovel cadastrado\n"

# Texto que identifica o tipo de automóvel
texto_tipo: .asciiz " | tipo: "

# Texto usado para identificar um carro
texto_carro: .asciiz "carro"

# Texto usado para identificar uma moto
texto_moto: .asciiz "moto"

# Marcador visual de cada registro listado
texto_item: .asciiz " - "

# Texto que identifica a placa do veículo
texto_placa: .asciiz " | placa: "

# Quebra de linha usada nas listagens
texto_quebra: .asciiz "\n"

# Textos padronizados para o comando infoAp (cmd_6)
texto_info_ap_rotulo:        .asciiz "AP: "
texto_info_ap_vazio:         .asciiz "Apartamento vazio\n"
texto_info_ap_moradores:     .asciiz "Moradores:\n"
texto_info_ap_carro:         .asciiz "Carro:\n"
texto_info_ap_moto:          .asciiz "Moto:\n"
texto_info_ap_separador:     .asciiz " / "

# Textos padronizados para o comando infoGeral (cmd_7)
texto_info_geral_nao_vazios: .asciiz "Nao vazios: "
texto_info_geral_vazios:     .asciiz "Vazios: "
texto_info_geral_espaco:     .asciiz " ("
texto_info_geral_porcento:   .asciiz "%)\n"


# ------------------------------------------------------------
# ROTINAS PÚBLICAS
# ------------------------------------------------------------

# Torna a rotina de listagem de apartamentos acessível aos outros módulos
.globl consulta_listar_apartamentos

# Torna a rotina de listagem de moradores acessível aos outros módulos
.globl consulta_listar_moradores

# Torna a rotina de listagem de automóveis acessível aos outros módulos
.globl consulta_listar_automoveis

# Torna a rotina de busca de moradores acessível aos outros módulos
.globl consulta_buscar_morador

# Torna a rotina de busca de automóveis acessível aos outros módulos
.globl consulta_buscar_auto

# Torna a rotina infoAp acessível ao shell
.globl consulta_info_ap

# Torna a rotina infoGeral acessível ao shell
.globl consulta_info_geral


# Seleciona a seção de instruções
.text



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
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno da rotina
    sw      $ra, 12($sp)

    # Salva o registrador usado como ponteiro de memória
    sw      $s0, 8($sp)

    # Salva o registrador usado como contador de apartamentos
    sw      $s1, 4($sp)

    # Seleciona o serviço de impressão de string do MARS
    li      $v0, 4

    # Carrega o título da listagem geral
    la      $a0, texto_consulta_apartamentos

    # Exibe o título no terminal
    syscall

    # Carrega o endereço do primeiro bloco de apartamento
    la      $s0, apartamentos

    # Inicia o índice dos apartamentos em zero
    li      $s1, 0


consulta_listar_apartamentos_loop:

    # Carrega a quantidade total de apartamentos em um registrador
    li      $t0, TOTAL_APARTAMENTOS

    # Encerra quando todos os apartamentos forem percorridos
    bge     $s1, $t0, consulta_listar_apartamentos_finalizar

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o texto que antecede o número do apartamento
    la      $a0, texto_ap

    # Exibe o prefixo AP
    syscall

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1

    # Lê o número armazenado no cabeçalho do bloco
    lw      $a0, OFFSET_AP_NUMERO($s0)

    # Exibe o número do apartamento
    syscall

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o texto que identifica a quantidade de moradores
    la      $a0, texto_moradores

    # Exibe o separador dos moradores
    syscall

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1

    # Lê a quantidade de moradores do cabeçalho
    lw      $a0, OFFSET_AP_QTD_MORADORES($s0)

    # Exibe a quantidade de moradores
    syscall

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o texto que identifica a quantidade de veículos
    la      $a0, texto_autos

    # Exibe o separador dos automóveis
    syscall

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1

    # Lê a quantidade de veículos do cabeçalho
    lw      $a0, OFFSET_AP_QTD_AUTOS($s0)

    # Exibe a quantidade de veículos
    syscall

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega uma quebra de linha
    la      $a0, texto_quebra

    # Finaliza a linha atual
    syscall

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP

    # Avança para o próximo índice
    addiu   $s1, $s1, 1

    # Continua a listagem dos apartamentos
    j       consulta_listar_apartamentos_loop


consulta_listar_apartamentos_finalizar:

    # Define o retorno de sucesso
    li      $v0, OK

    # Restaura o contador de apartamentos
    lw      $s1, 4($sp)

    # Restaura o ponteiro dos blocos
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno
    lw      $ra, 12($sp)

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 16

    # Retorna ao módulo chamador
    jr      $ra


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
    addiu   $sp, $sp, -24

    # Salva o endereço de retorno
    sw      $ra, 20($sp)

    # Salva o endereço do bloco do apartamento
    sw      $s0, 16($sp)

    # Salva o número do apartamento recebido
    sw      $s1, 12($sp)

    # Salva a quantidade de moradores
    sw      $s2, 8($sp)

    # Salva o índice do morador atual
    sw      $s3, 4($sp)

    # Guarda o número do apartamento para uso posterior
    move    $s1, $a0

    # Procura o bloco correspondente ao apartamento
    jal     dados_obter_ap

    # Encerra caso o apartamento seja inválido
    bne     $v0, $zero, consulta_listar_moradores_finalizar

    # Guarda o endereço do bloco encontrado
    move    $s0, $v1

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o início do título da consulta
    la      $a0, texto_consulta_moradores

    # Exibe o início do título
    syscall

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1

    # Passa o número do apartamento para a impressão
    move    $a0, $s1

    # Exibe o número do apartamento
    syscall

    # Seleciona novamente o serviço de impressão de string
    li      $v0, 4

    # Carrega o final do título
    la      $a0, texto_fim_titulo

    # Finaliza o título no terminal
    syscall

    # Lê a quantidade de moradores do apartamento
    lw      $s2, OFFSET_AP_QTD_MORADORES($s0)

    # Verifica se a lista está vazia
    beq     $s2, $zero, consulta_moradores_vazia

    # Começa pelo primeiro morador
    li      $s3, 0


consulta_listar_moradores_loop:

    # Verifica se todos os moradores já foram exibidos
    bge     $s3, $s2, consulta_listar_moradores_sucesso

    # Carrega o tamanho do registro de morador
    li      $t0, TAM_REGISTRO_MORADOR

    # Calcula o deslocamento do morador atual
    mul     $t1, $s3, $t0

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES

    # Calcula o endereço do nome atual
    addu    $a0, $t2, $t1

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Exibe o nome do morador
    syscall

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega uma quebra de linha
    la      $a0, texto_quebra

    # Finaliza a linha do morador
    syscall

    # Avança para o próximo morador
    addiu   $s3, $s3, 1

    # Continua a listagem
    j       consulta_listar_moradores_loop


consulta_moradores_vazia:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de lista vazia
    la      $a0, texto_sem_moradores

    # Informa que não existem moradores
    syscall


consulta_listar_moradores_sucesso:

    # Define o retorno de sucesso
    li      $v0, OK


consulta_listar_moradores_finalizar:

    # Restaura o índice do morador
    lw      $s3, 4($sp)

    # Restaura a quantidade de moradores
    lw      $s2, 8($sp)

    # Restaura o número do apartamento
    lw      $s1, 12($sp)

    # Restaura o endereço do bloco
    lw      $s0, 16($sp)

    # Restaura o endereço de retorno
    lw      $ra, 20($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24

    # Retorna ao módulo chamador
    jr      $ra


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
    addiu   $sp, $sp, -24

    # Salva o endereço de retorno
    sw      $ra, 20($sp)

    # Salva o endereço do bloco
    sw      $s0, 16($sp)

    # Salva o número do apartamento
    sw      $s1, 12($sp)

    # Salva a quantidade de veículos
    sw      $s2, 8($sp)

    # Salva o índice do veículo atual
    sw      $s3, 4($sp)

    # Guarda o número do apartamento
    move    $s1, $a0

    # Procura o bloco do apartamento
    jal     dados_obter_ap

    # Encerra caso o apartamento seja inválido
    bne     $v0, $zero, consulta_listar_automoveis_finalizar

    # Guarda o endereço do bloco encontrado
    move    $s0, $v1

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o início do título
    la      $a0, texto_consulta_automoveis

    # Exibe o início do título
    syscall

    # Seleciona o serviço de impressão de inteiro
    li      $v0, 1

    # Passa o número do apartamento
    move    $a0, $s1

    # Exibe o número do apartamento
    syscall

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o final do título
    la      $a0, texto_fim_titulo

    # Finaliza o título
    syscall

    # Lê a quantidade de veículos cadastrados
    lw      $s2, OFFSET_AP_QTD_AUTOS($s0)

    # Verifica se não há veículos cadastrados
    beq     $s2, $zero, consulta_automoveis_vazia

    # Exibe o texto que identifica o tipo do veículo
    li      $v0, 4
    la      $a0, texto_tipo
    syscall

    # Lê o tipo armazenado no cabeçalho
    lw      $t0, OFFSET_AP_TIPO_AUTO($s0)

    # Carrega o código correspondente ao carro
    li      $t1, TIPO_AUTO_CARRO

    # Direciona para a impressão de carro quando os códigos forem iguais
    beq     $t0, $t1, consulta_imprimir_tipo_carro

    # Caso contrário, utiliza o texto correspondente à moto
    li      $v0, 4
    la      $a0, texto_moto
    syscall

    # Exibe uma quebra após o tipo
    li      $v0, 4
    la      $a0, texto_quebra
    syscall

    # Começa a listagem pelo primeiro veículo
    li      $s3, 0

    # Continua no laço principal dos veículos
    j       consulta_listar_automoveis_loop


consulta_imprimir_tipo_carro:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o texto carro
    la      $a0, texto_carro

    # Exibe o tipo do veículo
    syscall

    # Exibe uma quebra após o tipo
    li      $v0, 4
    la      $a0, texto_quebra
    syscall

    # Começa a listagem pelo primeiro veículo
    li      $s3, 0


consulta_listar_automoveis_loop:

    # Verifica se todos os veículos já foram exibidos
    bge     $s3, $s2, consulta_listar_automoveis_sucesso

    # Exibe o marcador do registro atual
    li      $v0, 4
    la      $a0, texto_item
    syscall

    # Carrega o tamanho de um registro de veículo
    li      $t0, TAM_REGISTRO_AUTO

    # Calcula o deslocamento do veículo atual
    mul     $t1, $s3, $t0

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS

    # Calcula o endereço do registro atual
    addu    $t2, $t2, $t1

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Passa o endereço do modelo para impressão
    move    $a0, $t2

    # Exibe o modelo
    syscall

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o texto da placa
    la      $a0, texto_placa

    # Exibe o separador da placa
    syscall

    # Avança até o campo da placa no registro
    addiu   $a0, $t2, TAM_MODELO

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Exibe a placa cadastrada
    syscall

    # Exibe uma quebra de linha
    li      $v0, 4
    la      $a0, texto_quebra
    syscall

    # Avança para o próximo veículo
    addiu   $s3, $s3, 1

    # Continua a listagem
    j       consulta_listar_automoveis_loop


consulta_automoveis_vazia:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de lista vazia
    la      $a0, texto_sem_automoveis

    # Informa que não existem veículos cadastrados
    syscall


consulta_listar_automoveis_sucesso:

    # Define o retorno de sucesso
    li      $v0, OK


consulta_listar_automoveis_finalizar:

    # Restaura o índice do veículo
    lw      $s3, 4($sp)

    # Restaura a quantidade de veículos
    lw      $s2, 8($sp)

    # Restaura o número do apartamento
    lw      $s1, 12($sp)

    # Restaura o endereço do bloco
    lw      $s0, 16($sp)

    # Restaura o endereço de retorno
    lw      $ra, 20($sp)

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 24

    # Retorna ao módulo chamador
    jr      $ra


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
    addiu   $sp, $sp, -24

    # Salva o endereço de retorno
    sw      $ra, 20($sp)

    # Salva o ponteiro do bloco atual
    sw      $s0, 16($sp)

    # Salva o endereço do nome procurado
    sw      $s1, 12($sp)

    # Salva o índice do apartamento atual
    sw      $s2, 8($sp)

    # Salva o índice do morador atual
    sw      $s3, 4($sp)

    # Salva a quantidade de moradores do bloco
    sw      $s4, 0($sp)

    # Garante que o segundo retorno seja zero quando não houver resultado
    move    $v1, $zero

    # Guarda o endereço do nome procurado
    move    $s1, $a0

    # Começa pelo primeiro apartamento
    li      $s2, 0

    # Carrega o início da tabela de apartamentos
    la      $s0, apartamentos


consulta_buscar_morador_apartamento:

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS

    # Encerra quando todos os blocos forem examinados
    bge     $s2, $t0, consulta_morador_nao_encontrado

    # Lê a quantidade de moradores do bloco atual
    lw      $s4, OFFSET_AP_QTD_MORADORES($s0)

    # Inicia a busca pelo primeiro morador
    li      $s3, 0


consulta_buscar_morador_loop:

    # Verifica se todos os moradores do bloco foram examinados
    bge     $s3, $s4, consulta_proximo_apartamento_morador

    # Carrega o tamanho de um registro de morador
    li      $t0, TAM_REGISTRO_MORADOR

    # Calcula o deslocamento do morador atual
    mul     $t1, $s3, $t0

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES

    # Calcula o endereço do nome armazenado
    addu    $a0, $t2, $t1

    # Recupera o endereço do nome procurado
    move    $a1, $s1

    # Informa o tamanho máximo da comparação
    li      $a2, TAM_NOME

    # Compara o nome armazenado com o nome procurado
    jal     cadastro_strings_iguais

    # Continua a busca quando os nomes forem diferentes
    beq     $v0, $zero, consulta_proximo_morador

    # Lê o número do apartamento onde o nome foi encontrado
    lw      $v1, OFFSET_AP_NUMERO($s0)

    # Define o retorno de sucesso
    li      $v0, OK

    # Finaliza a busca
    j       consulta_buscar_morador_finalizar


consulta_proximo_morador:

    # Avança para o próximo morador do bloco
    addiu   $s3, $s3, 1

    # Continua a busca no mesmo apartamento
    j       consulta_buscar_morador_loop


consulta_proximo_apartamento_morador:

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP

    # Avança para o próximo índice de apartamento
    addiu   $s2, $s2, 1

    # Continua a busca nos blocos restantes
    j       consulta_buscar_morador_apartamento


consulta_morador_nao_encontrado:

    # Informa que nenhum morador correspondeu ao nome
    li      $v0, MORADOR_NAO_ENCONTRADO


consulta_buscar_morador_finalizar:

    # Restaura a quantidade de moradores
    lw      $s4, 0($sp)

    # Restaura o índice do morador
    lw      $s3, 4($sp)

    # Restaura o índice do apartamento
    lw      $s2, 8($sp)

    # Restaura o endereço do nome
    lw      $s1, 12($sp)

    # Restaura o ponteiro do bloco
    lw      $s0, 16($sp)

    # Restaura o endereço de retorno
    lw      $ra, 20($sp)

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 24

    # Retorna ao módulo chamador
    jr      $ra


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
    addiu   $sp, $sp, -24

    # Salva o endereço de retorno
    sw      $ra, 20($sp)

    # Salva o ponteiro do bloco atual
    sw      $s0, 16($sp)

    # Salva o endereço da placa procurada
    sw      $s1, 12($sp)

    # Salva o índice do apartamento atual
    sw      $s2, 8($sp)

    # Salva o índice do veículo atual
    sw      $s3, 4($sp)

    # Salva a quantidade de veículos do bloco
    sw      $s4, 0($sp)

    # Garante que o segundo retorno seja zero quando não houver resultado
    move    $v1, $zero

    # Guarda o endereço da placa procurada
    move    $s1, $a0

    # Começa pelo primeiro apartamento
    li      $s2, 0

    # Carrega o início da tabela de apartamentos
    la      $s0, apartamentos


consulta_buscar_auto_apartamento:

    # Carrega a quantidade total de apartamentos
    li      $t0, TOTAL_APARTAMENTOS

    # Encerra quando todos os blocos forem examinados
    bge     $s2, $t0, consulta_auto_nao_encontrado

    # Lê a quantidade de veículos do bloco atual
    lw      $s4, OFFSET_AP_QTD_AUTOS($s0)

    # Inicia a busca pelo primeiro veículo
    li      $s3, 0


consulta_buscar_auto_loop:

    # Verifica se todos os veículos do bloco foram examinados
    bge     $s3, $s4, consulta_proximo_apartamento_auto

    # Carrega o tamanho de um registro de veículo
    li      $t0, TAM_REGISTRO_AUTO

    # Calcula o deslocamento do veículo atual
    mul     $t1, $s3, $t0

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS

    # Calcula o endereço do registro atual
    addu    $t2, $t2, $t1

    # Avança até o campo da placa
    addiu   $a0, $t2, TAM_MODELO

    # Recupera o endereço da placa procurada
    move    $a1, $s1

    # Informa o tamanho máximo da comparação
    li      $a2, TAM_PLACA

    # Compara a placa armazenada com a placa procurada
    jal     cadastro_strings_iguais

    # Continua a busca quando as placas forem diferentes
    beq     $v0, $zero, consulta_proximo_auto

    # Lê o número do apartamento onde a placa foi encontrada
    lw      $v1, OFFSET_AP_NUMERO($s0)

    # Define o retorno de sucesso
    li      $v0, OK

    # Finaliza a busca
    j       consulta_buscar_auto_finalizar


consulta_proximo_auto:

    # Avança para o próximo veículo
    addiu   $s3, $s3, 1

    # Continua a busca no mesmo apartamento
    j       consulta_buscar_auto_loop


consulta_proximo_apartamento_auto:

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP

    # Avança para o próximo índice de apartamento
    addiu   $s2, $s2, 1

    # Continua a busca nos blocos restantes
    j       consulta_buscar_auto_apartamento


consulta_auto_nao_encontrado:

    # Informa que nenhuma placa correspondeu à busca
    li      $v0, AUTO_NAO_ENCONTRADO


consulta_buscar_auto_finalizar:

    # Restaura a quantidade de veículos
    lw      $s4, 0($sp)

    # Restaura o índice do veículo
    lw      $s3, 4($sp)

    # Restaura o índice do apartamento
    lw      $s2, 8($sp)

    # Restaura o endereço da placa
    lw      $s1, 12($sp)

    # Restaura o ponteiro do bloco
    lw      $s0, 16($sp)

    # Restaura o endereço de retorno
    lw      $ra, 20($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24

    # Retorna ao módulo chamador
    jr      $ra


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
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno da chamada
    sw      $ra, 12($sp)

    # Salva o registrador para o número do AP ou endereço de bloco
    sw      $s0, 8($sp)

    # Salva o registrador que guarda a flag --all
    sw      $s1, 4($sp)

    # Salva o contador de iteração
    sw      $s2, 0($sp)

    # Copia o número do AP recebido
    move    $s0, $a0

    # Copia a flag indicativa da opção --all
    move    $s1, $a1

    # Desvia caso a flag solicite listar todos os apartamentos
    bne     $s1, $zero, consulta_info_ap_todos

    # Busca o endereço do bloco do apartamento especificado
    move    $a0, $s0
    jal     dados_obter_ap

    # Retorna erro caso o apartamento seja inválido
    bne     $v0, OK, consulta_info_ap_finalizar

    # Imprime os detalhes formatados do apartamento localizado em $v1
    move    $a0, $v1
    jal     consulta_imprimir_detalhes_ap

    # Define retorno de sucesso
    li      $v0, OK

    # Encerra o processamento individual
    j       consulta_info_ap_finalizar


consulta_info_ap_todos:

    # Carrega o início da tabela de apartamentos
    la      $s0, apartamentos

    # Inicia o índice de controle em zero
    li      $s2, 0


consulta_info_ap_todos_loop:

    # Carrega a quantidade total de 24 apartamentos
    li      $t0, TOTAL_APARTAMENTOS

    # Encerra quando todos os blocos tiverem sido impressos
    bge     $s2, $t0, consulta_info_ap_todos_sucesso

    # Imprime os detalhes do apartamento apontado por $s0
    move    $a0, $s0
    jal     consulta_imprimir_detalhes_ap

    # Avança para o próximo bloco de apartamento
    addiu   $s0, $s0, TAM_BLOCO_AP

    # Incrementa o índice do loop
    addiu   $s2, $s2, 1

    # Continua para o próximo apartamento
    j       consulta_info_ap_todos_loop


consulta_info_ap_todos_sucesso:

    # Define retorno de sucesso
    li      $v0, OK


consulta_info_ap_finalizar:

    # Restaura o contador de iteração
    lw      $s2, 0($sp)

    # Restaura a flag da opção --all
    lw      $s1, 4($sp)

    # Restaura o registrador $s0
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno
    lw      $ra, 12($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16

    # Retorna ao módulo chamador
    jr      $ra


# ------------------------------------------------------------
# consulta_imprimir_detalhes_ap()
#
# Renderiza a estrutura textual de um único apartamento
# Entrada:
#   $a0 = endereço base do bloco do apartamento
# ------------------------------------------------------------

consulta_imprimir_detalhes_ap:

    # Reserva espaço para o endereço de retorno e registradores salvos
    addiu   $sp, $sp, -24

    # Salva o endereço de retorno da sub-rotina
    sw      $ra, 20($sp)

    # Salva o ponteiro do bloco do apartamento
    sw      $s0, 16($sp)

    # Salva a quantidade de moradores
    sw      $s1, 12($sp)

    # Salva o índice de iteração
    sw      $s2, 8($sp)

    # Salva o ponteiro do item atual
    sw      $s3, 4($sp)

    # Salva registrador auxiliar para contadores
    sw      $s4, 0($sp)

    # Guarda o endereço base do bloco
    move    $s0, $a0

    # Imprime o rótulo "AP: " via camada de I/O
    la      $a0, texto_info_ap_rotulo
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime o número do apartamento armazenado no cabeçalho via I/O
    lw      $a0, OFFSET_AP_NUMERO($s0)
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Lê a quantidade de moradores cadastrados
    lw      $s1, OFFSET_AP_QTD_MORADORES($s0)

    # Se a quantidade for maior que zero, desvia para listar moradores
    bnez    $s1, consulta_detalhes_nao_vazio

    # Apartamento vazio: imprime "Apartamento vazio\n" via I/O
    la      $a0, texto_info_ap_vazio
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Encerra a impressão deste apartamento
    j       consulta_detalhes_finalizar


consulta_detalhes_nao_vazio:

    # Imprime o título "Moradores:\n" via camada de I/O
    la      $a0, texto_info_ap_moradores
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Inicia o índice de moradores em zero
    li      $s2, 0

    # Carrega o endereço do primeiro morador
    addiu   $s3, $s0, OFFSET_AP_MORADORES


consulta_detalhes_moradores_loop:

    # Verifica se já listou todos os moradores cadastrados
    bge     $s2, $s1, consulta_detalhes_veiculos

    # Imprime o nome do morador atual via camada de I/O
    move    $a0, $s3
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Avança para o próximo registro de morador
    addiu   $s3, $s3, TAM_REGISTRO_MORADOR

    # Incrementa o contador de moradores
    addiu   $s2, $s2, 1

    # Continua o loop de moradores
    j       consulta_detalhes_moradores_loop


consulta_detalhes_veiculos:

    # Lê a quantidade de veículos cadastrados
    lw      $s2, OFFSET_AP_QTD_AUTOS($s0)

    # Se não houver veículos cadastrados, encerra
    beqz    $s2, consulta_detalhes_finalizar

    # Lê o tipo de veículo do apartamento
    lw      $s3, OFFSET_AP_TIPO_AUTO($s0)

    # Compara se o tipo cadastrado é carro
    li      $t0, TIPO_AUTO_CARRO
    # Se for carro, desvia para impressao de carro
    beq     $s3, $t0, consulta_detalhes_carro

    # Compara se o tipo cadastrado é moto
    li      $t0, TIPO_AUTO_MOTO
    # Se for moto, desvia para impressao de moto
    beq     $s3, $t0, consulta_detalhes_moto

    # Caso seja desconhecido, encerra
    j       consulta_detalhes_finalizar


consulta_detalhes_carro:

    # Imprime o título "Carro:\n" via camada de I/O
    la      $a0, texto_info_ap_carro
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime o modelo do carro via camada de I/O
    addiu   $a0, $s0, OFFSET_AP_AUTOS
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime o separador " / " via camada de I/O
    la      $a0, texto_info_ap_separador
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime a placa do carro via camada de I/O
    addiu   $a0, $s0, OFFSET_AP_AUTOS
    # Avanca o ponteiro para o campo da placa do automovel
    addiu   $a0, $a0, TAM_MODELO
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Encerra os detalhes do apartamento
    j       consulta_detalhes_finalizar


consulta_detalhes_moto:

    # Imprime o título "Moto:\n" via camada de I/O
    la      $a0, texto_info_ap_moto
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Inicia o índice de motos em zero
    li      $s3, 0

    # Carrega o endereço do primeiro registro de veículo
    addiu   $s4, $s0, OFFSET_AP_AUTOS


consulta_detalhes_moto_loop:

    # Verifica se já listou todas as motos cadastradas
    bge     $s3, $s2, consulta_detalhes_finalizar

    # Imprime o modelo da moto via camada de I/O
    move    $a0, $s4
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime o separador " / " via camada de I/O
    la      $a0, texto_info_ap_separador
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime a placa da moto via camada de I/O
    addiu   $a0, $s4, TAM_MODELO
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime quebra de linha via I/O
    la      $a0, texto_quebra
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Avança para o próximo registro de veículo
    addiu   $s4, $s4, TAM_REGISTRO_AUTO

    # Incrementa o contador de motos impressas
    addiu   $s3, $s3, 1

    # Continua o loop de motos
    j       consulta_detalhes_moto_loop


consulta_detalhes_finalizar:

    # Restaura o registrador $s4
    lw      $s4, 0($sp)

    # Restaura o ponteiro de item $s3
    lw      $s3, 4($sp)

    # Restaura o contador $s2
    lw      $s2, 8($sp)

    # Restaura a quantidade de moradores $s1
    lw      $s1, 12($sp)

    # Restaura o ponteiro do bloco $s0
    lw      $s0, 16($sp)

    # Restaura o endereço de retorno
    lw      $ra, 20($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24

    # Retorna à rotina chamadora
    jr      $ra


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
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno
    sw      $ra, 12($sp)

    # Salva o contador de não vazios
    sw      $s0, 8($sp)

    # Salva o contador de vazios
    sw      $s1, 4($sp)

    # Salva o registrador de percentual
    sw      $s2, 0($sp)

    # Inicializa o contador de não vazios com zero
    li      $s0, 0

    # Inicializa o contador de vazios com zero
    li      $s1, 0

    # Carrega o início da tabela de apartamentos
    la      $t0, apartamentos

    # Inicializa o índice do loop com zero
    li      $t1, 0


consulta_info_geral_loop:

    # Carrega a quantidade total de apartamentos
    li      $t2, TOTAL_APARTAMENTOS

    # Conclui a varredura ao atingir os 24 apartamentos
    bge     $t1, $t2, consulta_info_geral_calculo

    # Lê a quantidade de moradores do apartamento atual
    lw      $t3, OFFSET_AP_QTD_MORADORES($t0)

    # Se a quantidade for maior que zero, é classificado como não vazio
    bgtz    $t3, consulta_info_geral_ocupado

    # Caso contrário, incrementa a contagem de vazios
    addiu   $s1, $s1, 1

    # Desvia para o próximo apartamento
    j       consulta_info_geral_proximo


consulta_info_geral_ocupado:

    # Incrementa a contagem de apartamentos não vazios
    addiu   $s0, $s0, 1


consulta_info_geral_proximo:

    # Avança para o próximo bloco de memória
    addiu   $t0, $t0, TAM_BLOCO_AP

    # Incrementa o índice de controle
    addiu   $t1, $t1, 1

    # Continua o loop
    j       consulta_info_geral_loop


consulta_info_geral_calculo:

    # Multiplica a quantidade de não vazios por cem
    li      $t4, 100
    # Multiplica quantidade de apartamentos ocupados por cem
    mul     $t5, $s0, $t4

    # Divide pelo total de 24 apartamentos para obter a porcentagem inteira
    li      $t6, TOTAL_APARTAMENTOS
    # Divide pelo total de 24 apartamentos para calcular percentual
    divu    $t5, $t6

    # Obtém o percentual inteiro calculado
    mflo    $s2

    # Imprime o texto "Nao vazios: " via camada de I/O
    la      $a0, texto_info_geral_nao_vazios
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime a quantidade absoluta de não vazios via I/O
    move    $a0, $s0
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int

    # Imprime o caractere de abertura " (" via camada de I/O
    la      $a0, texto_info_geral_espaco
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime o percentual de não vazios via I/O
    move    $a0, $s2
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int

    # Imprime o sufixo "%)\n" via camada de I/O
    la      $a0, texto_info_geral_porcento
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Multiplica a quantidade de vazios por cem
    mul     $t5, $s1, $t4

    # Divide por 24 para obter a porcentagem de vazios
    divu    $t5, $t6

    # Obtém o percentual inteiro de vazios
    mflo    $s2

    # Imprime o texto "Vazios: " via camada de I/O
    la      $a0, texto_info_geral_vazios
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime a quantidade absoluta de vazios via I/O
    move    $a0, $s1
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int

    # Imprime o caractere de abertura " (" via camada de I/O
    la      $a0, texto_info_geral_espaco
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Imprime o percentual de vazios via I/O
    move    $a0, $s2
    # Chama impressao de inteiro via camada de I/O
    jal     shell_io_imprimir_int

    # Imprime o sufixo "%)\n" via camada de I/O
    la      $a0, texto_info_geral_porcento
    # Chama impressao de string via camada de I/O
    jal     shell_io_imprimir_string

    # Define o retorno de sucesso
    li      $v0, OK

    # Restaura o registrador de percentual
    lw      $s2, 0($sp)

    # Restaura o contador de vazios
    lw      $s1, 4($sp)

    # Restaura o contador de não vazios
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno
    lw      $ra, 12($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16

    # Retorna ao módulo chamador
    jr      $ra