# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Integrante 3
# Atividade: 1VA (Bônus MMIO +1.0 Ponto)
# Disciplina: Arquitetura e Organização de Computadores
# Semestre: 2026.2
# Arquivo: mmio.asm
# Descrição: driver de baixo nível para Memory-Mapped I/O
#            (Keyboard MMIO e Display MMIO) no simulador MARS
# ============================================================


# ------------------------------------------------------------
# CONSTANTES DE HARDWARE MAPEADO EM MEMÓRIA (MMIO)
# ------------------------------------------------------------

# Registrador de Controle do Teclado (bit 0 = 1 quando tecla foi pressionada)
.eqv MMIO_RECEIVER_CTRL         0xFFFF0000

# Registrador de Dados do Teclado (bits 0-7 = código ASCII lido)
.eqv MMIO_RECEIVER_DATA         0xFFFF0004

# Registrador de Controle do Display (bit 0 = 1 quando tela está pronta)
.eqv MMIO_TRANSMITTER_CTRL      0xFFFF0008

# Registrador de Dados do Display (bits 0-7 = código ASCII a exibir)
.eqv MMIO_TRANSMITTER_DATA      0xFFFF000C


# ------------------------------------------------------------
# ROTINAS PÚBLICAS DO MÓDULO MMIO
# ------------------------------------------------------------

.globl mmio_escrever_char
.globl mmio_ler_char
.globl mmio_imprimir_string
.globl mmio_imprimir_int
.globl mmio_ler_linha


# Seleciona a seção de instruções
.text


# ------------------------------------------------------------
# mmio_escrever_char()
#
# Envia um único byte ASCII para exibição no Display MMIO
# Entrada:
#   $a0 = caractere ASCII a ser transmitido
# ------------------------------------------------------------

mmio_escrever_char:

    # Carrega a metade superior do endereço de controle de MMIO (0xFFFF)
    lui     $t0, 0xFFFF


mmio_escrever_char_wait:

    # Lê o registrador Transmitter Control em 0xFFFF0008
    lw      $t1, 0x0008($t0)

    # Isola o bit 0 (Ready bit)
    andi    $t1, $t1, 0x0001

    # Aguarda em espera ocupada (polling) enquanto o display estiver ocupado
    beqz    $t1, mmio_escrever_char_wait

    # Display pronto: grava o caractere no Transmitter Data em 0xFFFF000C
    sw      $a0, 0x000C($t0)

    # Retorna à rotina chamadora
    jr      $ra


# ------------------------------------------------------------
# mmio_ler_char()
#
# Aguarda o usuário pressionar uma tecla no Keyboard MMIO
# Retorno:
#   $v0 = byte ASCII da tecla capturada
# ------------------------------------------------------------

mmio_ler_char:

    # Carrega a metade superior do endereço de controle de MMIO (0xFFFF)
    lui     $t0, 0xFFFF


mmio_ler_char_wait:

    # Lê o registrador Receiver Control em 0xFFFF0000
    lw      $t1, 0x0000($t0)

    # Isola o bit 0 (Ready bit)
    andi    $t1, $t1, 0x0001

    # Aguarda em espera ocupada (polling) até que uma tecla seja digitada
    beqz    $t1, mmio_ler_char_wait

    # Tecla disponível: lê o byte ASCII em Receiver Data em 0xFFFF0004
    lw      $v0, 0x0004($t0)

    # Retorna com o caractere em $v0
    jr      $ra


# ------------------------------------------------------------
# mmio_imprimir_string()
#
# Imprime uma cadeia de caracteres terminada em '\0' no Display MMIO
# Entrada:
#   $a0 = endereço da string na memória
# ------------------------------------------------------------

mmio_imprimir_string:

    # Reserva espaço na pilha para retorno e registradores salvos (16 bytes, múltiplo de 8)
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno
    sw      $ra, 12($sp)

    # Salva o registrador $s0
    sw      $s0, 8($sp)

    # Guarda o ponteiro da string
    move    $s0, $a0


mmio_imprimir_string_loop:

    # Lê o byte atual da string
    lbu     $a0, 0($s0)

    # Se encontrar o terminador nulo, encerra a impressão
    beqz    $a0, mmio_imprimir_string_fim

    # Transmite o caractere atual para o Display MMIO
    jal     mmio_escrever_char

    # Avança para o próximo byte da string
    addiu   $s0, $s0, 1

    # Continua o loop de impressão
    j       mmio_imprimir_string_loop


mmio_imprimir_string_fim:

    # Restaura o registrador $s0
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno
    lw      $ra, 12($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16

    # Retorna ao chamador
    jr      $ra


# ------------------------------------------------------------
# mmio_imprimir_int()
#
# Converte um valor inteiro em representação decimal e imprime no MMIO
# Entrada:
#   $a0 = valor inteiro a ser impresso
# ------------------------------------------------------------

mmio_imprimir_int:

    # Reserva espaço na pilha para retorno e registradores preservados (32 bytes, múltiplo de 8)
    addiu   $sp, $sp, -32

    # Salva o endereço de retorno
    sw      $ra, 28($sp)

    # Salva o valor original
    sw      $s0, 24($sp)

    # Salva o contador de dígitos
    sw      $s1, 20($sp)

    # Salva o divisor base 10
    sw      $s2, 16($sp)

    # Guarda o valor inteiro recebido
    move    $s0, $a0

    # Trata especificamente o caso do número zero
    bnez    $s0, mmio_int_nao_zero

    # Carrega código ASCII do dígito '0'
    li      $a0, 48

    # Envia o caractere '0' para o Display MMIO
    jal     mmio_escrever_char

    # Salta para a finalização da rotina
    j       mmio_int_fim


mmio_int_nao_zero:

    # Se o número for negativo, imprime o sinal '-' e inverte
    bgez    $s0, mmio_int_positivo

    # Carrega código ASCII do sinal de menos '-'
    li      $a0, 45

    # Envia o sinal negativo para o Display MMIO
    jal     mmio_escrever_char

    # Converte o valor para positivo
    negu    $s0, $s0


mmio_int_positivo:

    # Inicializa a contagem de dígitos gerados no buffer local
    li      $s1, 0

    # Carrega a constante decimal 10 para divisões sucessivas
    li      $s2, 10


mmio_int_loop_div:

    # Encerra a divisão quando o valor chegar a zero
    beqz    $s0, mmio_int_loop_print

    # Divide o valor atual por 10
    divu    $s0, $s2

    # Quociente substitui o valor acumulado
    mflo    $s0

    # Resto da divisão representa o dígito decimal mais à direita (0 a 9)
    mfhi    $t0

    # Converte o dígito para o código ASCII correspondente (+48)
    addiu   $t0, $t0, 48

    # Armazena o dígito no buffer local alocado no frame (sem alterar $sp)
    addu    $t1, $sp, $s1
    sb      $t0, 0($t1)

    # Incrementa a quantidade de dígitos gerados
    addiu   $s1, $s1, 1

    # Continua extraindo os dígitos restantes
    j       mmio_int_loop_div


mmio_int_loop_print:

    # Encerra quando todos os dígitos do buffer forem impressos
    blez    $s1, mmio_int_fim

    # Decrementa o índice para ler o próximo dígito na ordem correta
    addiu   $s1, $s1, -1

    # Obtém o caractere do buffer local
    addu    $t1, $sp, $s1
    lb      $a0, 0($t1)

    # Envia o dígito para o Display MMIO com $sp estritamente fixo e alinhado
    jal     mmio_escrever_char

    # Continua imprimindo os dígitos restantes
    j       mmio_int_loop_print


mmio_int_fim:

    # Restaura o registrador $s2
    lw      $s2, 16($sp)

    # Restaura o registrador $s1
    lw      $s1, 20($sp)

    # Restaura o registrador $s0
    lw      $s0, 24($sp)

    # Restaura o endereço de retorno
    lw      $ra, 28($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 32

    # Retorna ao chamador
    jr      $ra


# ------------------------------------------------------------
# mmio_ler_linha()
#
# Lê uma linha digitada no Keyboard MMIO, ecoa os caracteres no
# Display MMIO, processa Backspace visual e finaliza em '\n'
# Entrada:
#   $a0 = endereço de memória do buffer de destino
#   $a1 = tamanho máximo do buffer (bytes)
# ------------------------------------------------------------

mmio_ler_linha:

    # Reserva espaço na pilha para retorno e registradores salvos
    addiu   $sp, $sp, -24

    # Salva o endereço de retorno
    sw      $ra, 20($sp)

    # Salva o ponteiro base do buffer
    sw      $s0, 16($sp)

    # Salva o tamanho máximo
    sw      $s1, 12($sp)

    # Salva a contagem de caracteres lidos
    sw      $s2, 8($sp)

    # Salva o limite de segurança
    sw      $s3, 4($sp)

    # Guarda o endereço base do buffer de destino
    move    $s0, $a0

    # Guarda o tamanho máximo informado
    move    $s1, $a1

    # Inicializa o contador de caracteres lidos com zero
    li      $s2, 0

    # Reserva 1 byte de segurança para o terminador nulo '\0'
    addiu   $s3, $s1, -1


mmio_ler_linha_loop:

    # Aguarda e lê uma tecla digitada no Keyboard MMIO
    jal     mmio_ler_char

    # Guarda o caractere lido em registrador temporário
    move    $t0, $v0

    # Carrega código ASCII do salto de linha (\n = 10)
    li      $t1, 10

    # Se a tecla for Enter (\n), finaliza a leitura
    beq     $t0, $t1, mmio_ler_linha_enter

    # Carrega código ASCII do retorno de carro (\r = 13)
    li      $t1, 13

    # Se a tecla for Enter (\r), finaliza a leitura
    beq     $t0, $t1, mmio_ler_linha_enter

    # Carrega código ASCII do Backspace (8)
    li      $t1, 8

    # Se a tecla for Backspace, trata remoção de caractere
    beq     $t0, $t1, mmio_ler_linha_backspace

    # Carrega código ASCII do Delete/Backspace (127)
    li      $t1, 127

    # Se a tecla for Delete, trata remoção de caractere
    beq     $t0, $t1, mmio_ler_linha_backspace

    # Verifica se o limite máximo do buffer foi atingido
    bge     $s2, $s3, mmio_ler_linha_loop

    # Calcula endereço da posição atual no buffer
    addu    $t2, $s0, $s2

    # Armazena o byte lido na posição correspondente do buffer
    sb      $t0, 0($t2)

    # Incrementa a contagem de caracteres lidos
    addiu   $s2, $s2, 1

    # Prepara o caractere para exibição visual
    move    $a0, $t0

    # Ecoa o caractere visualmente no Display MMIO
    jal     mmio_escrever_char

    # Continua aguardando os próximos caracteres
    j       mmio_ler_linha_loop


mmio_ler_linha_backspace:

    # Se o buffer já estiver vazio, não há o que apagar
    blez    $s2, mmio_ler_linha_loop

    # Decrementa o contador de caracteres válidos
    addiu   $s2, $s2, -1

    # Carrega código ASCII de retrocesso (\b = 8)
    li      $a0, 8

    # Envia o retrocesso para recuar o cursor uma coluna à esquerda
    jal     mmio_escrever_char

    # Carrega código ASCII de espaço em branco (' ' = 32)
    li      $a0, 32

    # Envia espaço para apagar o caractere desenhado
    jal     mmio_escrever_char

    # Carrega código ASCII de retrocesso (\b = 8)
    li      $a0, 8

    # Envia o retrocesso para posicionar o cursor no espaço apagado
    jal     mmio_escrever_char

    # Retorna ao loop aguardando nova digitação
    j       mmio_ler_linha_loop


mmio_ler_linha_enter:

    # Carrega código ASCII do salto de linha (\n = 10)
    li      $a0, 10

    # Ecoa a quebra de linha visual no Display MMIO
    jal     mmio_escrever_char

    # Calcula o endereço final da string lida
    addu    $t2, $s0, $s2

    # Adiciona o terminador nulo '\0' no final da string lida
    sb      $zero, 0($t2)

    # Restaura o registrador $s3
    lw      $s3, 4($sp)

    # Restaura o registrador $s2
    lw      $s2, 8($sp)

    # Restaura o registrador $s1
    lw      $s1, 12($sp)

    # Restaura o registrador $s0
    lw      $s0, 16($sp)

    # Restaura o endereço de retorno
    lw      $ra, 20($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24

    # Retorna ao chamador
    jr      $ra
