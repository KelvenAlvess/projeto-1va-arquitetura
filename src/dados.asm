#  Descrição: reserva e manutenção dos blocos de memória dos
#  apartamentos do condomínio.

# Inclui a área de dados deste módulo
.data

# Alinha o início da tabela em endereço múltiplo de quatro bytes
.align 2

# Reserva 24 blocos de 520 bytes, um bloco para cada apartamento
apartamentos: .space 12480

# Torna as rotinas deste arquivo visíveis para os outros módulos
.globl dados_inicializar
.globl dados_obter_ap
.globl dados_limpar_ap

# Retorna para a seção de instruções do programa
.text

# ------------------------------------------------------------
# dados_inicializar()
#
# Inicializa todos os blocos de apartamentos
# Cada bloco é zerado e recebe o número correspondente:
# 101, 102, 201, 202, ..., 1201, 1202
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

dados_inicializar:

    # $t0 aponta para o próximo bloco que será inicializado
    la      $t0, apartamentos

    # $t1 guarda o andar que está sendo processado
    li      $t1, PRIMEIRO_ANDAR

    # $t2 guarda a posição do apartamento dentro do andar
    # O valor zero representa o primeiro apartamento
    li      $t2, 0
    
    
    
    dados_loop_apartamento:

    # $t3 recebe o início do bloco atual.
    move    $t3, $t0

    # $t4 controla quantos bytes ainda precisam ser zerados.
    li      $t4, TAM_BLOCO_AP
    
    
    
    dados_loop_limpeza:

    # Zera quatro bytes do bloco atual.
    sw      $zero, 0($t3)

    # Avança para a próxima palavra de quatro bytes.
    addiu   $t3, $t3, 4

    # Reduz em quatro bytes o espaço que ainda falta limpar.
    addiu   $t4, $t4, -4

    # Continua limpando enquanto ainda houver bytes pendentes.
    bgtz    $t4, dados_loop_limpeza


    # Multiplica o andar por cem para formar a parte inicial do número.
    li      $t5, 100
    mul     $t6, $t1, $t5

    # Converte a posição interna zero ou um para o sufixo 1 ou 2.
    addiu   $t7, $t2, 1

    # Soma o sufixo ao andar para obter o número do apartamento.
    addu    $t6, $t6, $t7

    # Armazena o número no início do cabeçalho do bloco.
    sw      $t6, OFFSET_AP_NUMERO($t0)

    # Avança o ponteiro para o próximo bloco de apartamento.
    addiu   $t0, $t0, TAM_BLOCO_AP

    # Avança para a próxima posição do andar atual.
    addiu   $t2, $t2, 1

    # Se ainda houver uma segunda posição, continua no mesmo andar.
    blt     $t2, APS_POR_ANDAR, dados_loop_apartamento

    # Reinicia a posição para começar o próximo andar.
    li      $t2, 0

    # Avança para o próximo andar.
    addiu   $t1, $t1, 1

    # Continua enquanto o último andar ainda não tiver sido ultrapassado.
    ble     $t1, ULTIMO_ANDAR, dados_loop_apartamento

    # Informa que a inicialização terminou com sucesso.
    li      $v0, OK

    # Retorna para a função que chamou a inicialização.
    jr      $ra



# ------------------------------------------------------------
# dados_obter_ap()
#
# Recebe um número de apartamento e calcula o endereço do seu bloco.
#
# Entrada:
#   $a0 = número do apartamento
#
# Saída:
#   $v0 = OK ou AP_INVALIDO
#   $v1 = endereço do bloco, quando o apartamento for válido
# ------------------------------------------------------------

dados_obter_ap:

    # Assume endereço nulo até que o apartamento seja validado
    move    $v1, $zero

    # Divide o número por cem para separar andar e posição
    li      $t2, 100
    divu    $a0, $t2

    # Obtém o número do andar na parte inteira da divisão
    mflo    $t0

    # Obtém o número do apartamento dentro do andar no resto da divisão
    mfhi    $t1

    # Rejeita números pertencentes a andares menores que o primeiro
    blt     $t0, PRIMEIRO_ANDAR, dados_ap_invalido

    # Rejeita números pertencentes a andares maiores que o último
    bgt     $t0, ULTIMO_ANDAR, dados_ap_invalido

    # Aceita apenas o sufixo correspondente ao primeiro apartamento
    beq     $t1, PRIMEIRO_AP_POR_ANDAR, dados_posicao_valida

    # Aceita também o sufixo correspondente ao segundo apartamento
    beq     $t1, SEGUNDO_AP_POR_ANDAR, dados_posicao_valida

    # Qualquer outro sufixo representa um apartamento inválido
    j       dados_ap_invalido
    
    
    
    dados_posicao_valida:

    # Converte o andar para um índice começando em zero
    addiu   $t0, $t0, -1

    # Converte a posição do apartamento para um índice começando em zero
    addiu   $t1, $t1, -1

    # Multiplica o índice do andar por dois apartamentos
    sll     $t0, $t0, 1

    # Soma a posição para obter o índice geral entre zero e 23
    addu    $t0, $t0, $t1

    # Carrega o tamanho de cada bloco em um registrador
    li      $t2, TAM_BLOCO_AP

    # Converte o índice do apartamento em deslocamento de memória
    mul     $t0, $t0, $t2

    # Obtém o endereço inicial da tabela de apartamentos
    la      $t2, apartamentos

    # Soma o deslocamento e encontra o bloco solicitado
    addu    $v1, $t2, $t0

    # Informa que o apartamento foi encontrado
    li      $v0, OK

    # Retorna ao módulo que fez a consulta
    jr      $ra


dados_ap_invalido:

    # Informa que o número recebido não corresponde a um apartamento válido
    li      $v0, AP_INVALIDO

    # Mantém $v1 igual a zero para indicar que não há bloco válido
    jr      $ra


# ------------------------------------------------------------
# dados_limpar_ap()
#
# Zera completamente o bloco de um apartamento existente
#
# Entrada:
#   $a0 = número do apartamento
#
# Retorno:
#   $v0 = OK ou AP_INVALIDO
# ------------------------------------------------------------



dados_limpar_ap:

    # Reserva espaço para o endereço de retorno e registradores preservados (16 bytes, múltiplo de 8)
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno da função
    sw      $ra, 12($sp)

    # Salva $s0 para guardar o número do apartamento
    sw      $s0, 8($sp)

    # Salva $s1 para guardar o endereço base do bloco
    sw      $s1, 4($sp)

    # Guarda o número do apartamento recebido em $a0
    move    $s0, $a0

    # Procura o endereço do apartamento informado
    jal     dados_obter_ap

    # Se a busca falhar, preserva o código de erro e encerra
    bne     $v0, OK, dados_limpar_finalizar

    # Guarda o endereço base do bloco do apartamento localizado
    move    $s1, $v1

    # Copia para $t0 o endereço inicial de varredura
    move    $t0, $v1

    # Define a quantidade total de bytes que será zerada
    li      $t1, TAM_BLOCO_AP




dados_loop_limpar_bloco:

    # Zera uma palavra do bloco
    sw      $zero, 0($t0)

    # Avança quatro bytes dentro do bloco
    addiu   $t0, $t0, 4

    # Atualiza a quantidade de bytes restantes
    addiu   $t1, $t1, -4

    # Continua até que todo o bloco tenha sido zerado
    bgtz    $t1, dados_loop_limpar_bloco

    # Restaura o número do apartamento no cabeçalho do bloco limpo
    sw      $s0, OFFSET_AP_NUMERO($s1)

    # Define o retorno de sucesso da operação
    li      $v0, OK




dados_limpar_finalizar:

    # Restaura o registrador preservado $s1
    lw      $s1, 4($sp)

    # Restaura o registrador preservado $s0
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno original
    lw      $ra, 12($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16

    # Retorna para o módulo chamador
    jr      $ra

