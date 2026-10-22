
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

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -12

    # Salva o endereço de retorno da rotina
    sw      $ra, 8($sp)

    # Salva o registrador usado como ponteiro de memória
    sw      $s0, 4($sp)

    # Salva o registrador usado como contador de apartamentos
    sw      $s1, 0($sp)

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
    lw      $s1, 0($sp)

    # Restaura o ponteiro dos blocos
    lw      $s0, 4($sp)

    # Restaura o endereço de retorno
    lw      $ra, 8($sp)

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 12

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

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -20

    # Salva o endereço de retorno
    sw      $ra, 16($sp)

    # Salva o endereço do bloco do apartamento
    sw      $s0, 12($sp)

    # Salva o número do apartamento recebido
    sw      $s1, 8($sp)

    # Salva a quantidade de moradores
    sw      $s2, 4($sp)

    # Salva o índice do morador atual
    sw      $s3, 0($sp)

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
    lw      $s3, 0($sp)

    # Restaura a quantidade de moradores
    lw      $s2, 4($sp)

    # Restaura o número do apartamento
    lw      $s1, 8($sp)

    # Restaura o endereço do bloco
    lw      $s0, 12($sp)

    # Restaura o endereço de retorno
    lw      $ra, 16($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 20

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

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -20

    # Salva o endereço de retorno
    sw      $ra, 16($sp)

    # Salva o endereço do bloco
    sw      $s0, 12($sp)

    # Salva o número do apartamento
    sw      $s1, 8($sp)

    # Salva a quantidade de veículos
    sw      $s2, 4($sp)

    # Salva o índice do veículo atual
    sw      $s3, 0($sp)

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
    lw      $s3, 0($sp)

    # Restaura a quantidade de veículos
    lw      $s2, 4($sp)

    # Restaura o número do apartamento
    lw      $s1, 8($sp)

    # Restaura o endereço do bloco
    lw      $s0, 12($sp)

    # Restaura o endereço de retorno
    lw      $ra, 16($sp)

    # Libera o espaço usado na pilha
    addiu   $sp, $sp, 20

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