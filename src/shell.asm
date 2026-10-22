# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Integrante 3
# Atividade: 1VA
# Disciplina: Arquitetura e Organização de Computadores
# Semestre: 2026.2
# Arquivo: shell.asm
# Descrição: terminal interativo (REPL), banner customizado,
#            parser de opções com delimitador " --" e
#            despachante dos 10 comandos oficiais do sistema
# ============================================================


# ------------------------------------------------------------
# ÁREA DE DADOS DO MÓDULO
# ------------------------------------------------------------

.data

# Banner do terminal com as iniciais do grupo (Requisito R5)
shell_banner:                   .asciiz "KJP-shell>> "

# Buffer de leitura da linha digitada pelo usuário (Requisito R4)
shell_buffer_linha:             .space 256

# Buffer que armazena o primeiro token (nome do comando extraído)
shell_cmd_token:                .space 32

# Ponteiros para os argumentos extraídos pelo parser após " --"
shell_arg1_ptr:                 .word 0
shell_arg2_ptr:                 .word 0
shell_arg3_ptr:                 .word 0
shell_arg4_ptr:                 .word 0

# Literais dos 10 comandos oficiais do sistema
cmd_addMorador:                 .asciiz "addMorador"
cmd_rmvMorador:                 .asciiz "rmvMorador"
cmd_addAuto:                    .asciiz "addAuto"
cmd_rmvAuto:                    .asciiz "rmvAuto"
cmd_limparAp:                   .asciiz "limparAp"
cmd_infoAp:                     .asciiz "infoAp"
cmd_infoGeral:                  .asciiz "infoGeral"
cmd_salvar:                     .asciiz "salvar"
cmd_recarregar:                 .asciiz "recarregar"
cmd_formatar:                   .asciiz "formatar"

# Comandos de encerramento amigável do terminal
cmd_sair:                       .asciiz "sair"
cmd_exit:                       .asciiz "exit"

# Palavra-chave para a opção --all no comando infoAp
str_all:                        .asciiz "all"

# Mensagens padronizadas de erro e validação exigidas no projeto
msg_cmd_invalido:               .asciiz "Comando invalido\n"
msg_ap_invalido:                .asciiz "Falha: AP invalido\n"
msg_limite_moradores:           .asciiz "Falha: AP com numero max de moradores\n"
msg_morador_nao_encontrado:     .asciiz "Falha: morador nao encontrado\n"
msg_tipo_invalido:              .asciiz "Falha: tipo invalido\n"
msg_limite_autos:               .asciiz "Falha: AP com numero max de automóveis\n"
msg_auto_nao_encontrado:        .asciiz "Falha: automóvel nao encontrado\n"


# ------------------------------------------------------------
# ROTINAS PÚBLICAS
# ------------------------------------------------------------

# Torna a rotina de inicialização acessível ao módulo principal
.globl shell_inicializar

# Torna a rotina de execução acessível ao módulo principal
.globl shell_executar

# Torna a rotina de encerramento acessível ao módulo principal
.globl shell_encerrar


# Seleciona a seção de instruções
.text


# ------------------------------------------------------------
# shell_inicializar()
#
# Prepara o estado inicial do terminal antes do loop
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

shell_inicializar:

    # Retorna código de sucesso
    li      $v0, OK

    # Retorna para o chamador
    jr      $ra


# ------------------------------------------------------------
# shell_executar()
#
# Loop principal do terminal (REPL): exibe banner, lê linha,
# analisa comando e despacha para as rotinas de negócio
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

shell_executar:

    # Reserva espaço na pilha para salvar registradores preservados
    addiu   $sp, $sp, -16

    # Salva o endereço de retorno da sub-rotina
    sw      $ra, 12($sp)

    # Salva $s0 para preservar estado de ponteiros
    sw      $s0, 8($sp)

    # Salva $s1 para controle de argumentos
    sw      $s1, 4($sp)

    # Salva $s2 para controle auxiliar
    sw      $s2, 0($sp)


shell_loop_prompt:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o banner oficial do terminal "<iniciais>-shell>> "
    la      $a0, shell_banner

    # Exibe o banner na tela
    syscall

    # Seleciona o serviço de leitura de string
    li      $v0, 8

    # Passa o endereço do buffer de entrada da linha
    la      $a0, shell_buffer_linha

    # Define o tamanho máximo de leitura (256 bytes)
    li      $a1, 256

    # Lê a linha digitada pelo usuário até o Enter (\n)
    syscall

    # Sanitiza a linha lida removendo \n ou \r
    jal     shell_sanitizar_linha

    # Faz o parsing da linha isolando o comando e as opções
    jal     shell_parser

    # Se nenhum comando foi digitado (linha em branco), repete o prompt
    la      $t0, shell_cmd_token

    # Lê o primeiro byte do comando extraído
    lbu     $t1, 0($t0)

    # Volta para o início do loop caso o comando seja vazio
    beqz    $t1, shell_loop_prompt

    # Despacha o comando para a rotina correspondente
    jal     shell_despachar_comando

    # Se a rotina de despacho retornar -1 em $v0, o usuário pediu para sair
    li      $t0, -1

    # Desvia para encerramento caso retorno seja -1
    beq     $v0, $t0, shell_sair_loop

    # Continua no loop principal aguardando o próximo comando
    j       shell_loop_prompt


shell_sair_loop:

    # Restaura o registrador $s2
    lw      $s2, 0($sp)

    # Restaura o registrador $s1
    lw      $s1, 4($sp)

    # Restaura o registrador $s0
    lw      $s0, 8($sp)

    # Restaura o endereço de retorno original
    lw      $ra, 12($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16

    # Define retorno de sucesso
    li      $v0, OK

    # Retorna ao módulo principal
    jr      $ra


# ------------------------------------------------------------
# shell_encerrar()
#
# Finalização do terminal
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

shell_encerrar:

    # Define retorno de sucesso
    li      $v0, OK

    # Retorna ao chamador
    jr      $ra


# ============================================================
# SUB-ROTINAS DO PARSER DE LINHA DE COMANDO
# ============================================================

# ------------------------------------------------------------
# shell_sanitizar_linha()
#
# Substitui o caractere '\n' (0x0A) ou '\r' (0x0D) por '\0'
# ------------------------------------------------------------

shell_sanitizar_linha:

    # Carrega o início do buffer de entrada
    la      $t0, shell_buffer_linha


shell_sanitizar_loop:

    # Lê um byte do buffer de entrada
    lbu     $t1, 0($t0)

    # Termina se encontrar o fim da string
    beqz    $t1, shell_sanitizar_fim

    # Código ASCII do salto de linha (\n = 10)
    li      $t2, 10

    # Se for \n, substitui por zero
    beq     $t1, $t2, shell_sanitizar_trocar

    # Código ASCII do retorno de carro (\r = 13)
    li      $t2, 13

    # Se for \r, substitui por zero
    beq     $t1, $t2, shell_sanitizar_trocar

    # Avança para o próximo byte
    addiu   $t0, $t0, 1

    # Continua a varredura
    j       shell_sanitizar_loop


shell_sanitizar_trocar:

    # Grava o terminador nulo no lugar da quebra de linha
    sb      $zero, 0($t0)


shell_sanitizar_fim:

    # Retorna da sanitização
    jr      $ra


# ------------------------------------------------------------
# shell_parser()
#
# Decompõe a linha lida no nome do comando e em opções separadas
# pelo delimitador estrito " --" (espaço e dois hífens)
# ------------------------------------------------------------

shell_parser:

    # Zera o buffer do nome do comando
    la      $t0, shell_cmd_token

    # Escreve terminador nulo na primeira posição
    sb      $zero, 0($t0)

    # Zera os ponteiros dos argumentos
    sw      $zero, shell_arg1_ptr
    sw      $zero, shell_arg2_ptr
    sw      $zero, shell_arg3_ptr
    sw      $zero, shell_arg4_ptr

    # Inicia a leitura do buffer de linha
    la      $t0, shell_buffer_linha


# Pula espaços em branco iniciais (trim)
shell_parser_pula_espacos_inicio:

    # Lê um byte do início da linha
    lbu     $t1, 0($t0)

    # Termina se a linha for vazia
    beqz    $t1, shell_parser_fim

    # Código ASCII do espaço em branco
    li      $t2, 32

    # Se não for espaço, encontrou o início do comando
    bne     $t1, $t2, shell_parser_extrai_comando

    # Avança ponteiro sobre o espaço em branco
    addiu   $t0, $t0, 1

    # Continua pulando espaços iniciais
    j       shell_parser_pula_espacos_inicio


# Copia os caracteres do comando até encontrar espaço ou fim de linha
shell_parser_extrai_comando:

    # Ponteiro de destino em shell_cmd_token
    la      $t3, shell_cmd_token

    # Limite máximo de caracteres para o nome do comando (31 bytes)
    li      $t4, 31


shell_parser_copia_cmd_loop:

    # Lê o byte atual da linha
    lbu     $t1, 0($t0)

    # Fim da string encerra extração do comando
    beqz    $t1, shell_parser_cmd_fechar

    # Espaço em branco encerra o nome do comando
    li      $t2, 32
    beq     $t1, $t2, shell_parser_cmd_fechar

    # Se o limite do buffer for atingido, encerra
    blez    $t4, shell_parser_cmd_fechar

    # Salva o caractere no buffer do comando
    sb      $t1, 0($t3)

    # Avança ponteiro de destino
    addiu   $t3, $t3, 1

    # Avança ponteiro de origem
    addiu   $t0, $t0, 1

    # Decrementa o limite restante
    addiu   $t4, $t4, -1

    # Continua copiando caracteres do comando
    j       shell_parser_copia_cmd_loop


shell_parser_cmd_fechar:

    # Adiciona terminador nulo ao nome do comando
    sb      $zero, 0($t3)


# Varredura do restante da linha em busca de opções iniciadas por " --"
shell_parser_varre_opcoes:

    # Contador de opções encontradas (1 a 4)
    li      $t5, 1


shell_parser_busca_delimitador:

    # Lê o byte atual
    lbu     $t1, 0($t0)

    # Se for terminador nulo, encerra o parser
    beqz    $t1, shell_parser_fim

    # Lê o byte seguinte (+1)
    lbu     $t2, 1($t0)

    # Termina se o byte seguinte for nulo
    beqz    $t2, shell_parser_fim

    # Lê o terceiro byte (+2)
    lbu     $t3, 2($t0)

    # Termina se o terceiro byte for nulo
    beqz    $t3, shell_parser_fim

    # Verifica se o primeiro byte é espaço (0x20)
    li      $t4, 32
    bne     $t1, $t4, shell_parser_avanca_busca

    # Verifica se o segundo byte é hífen (0x2D = 45)
    li      $t4, 45
    bne     $t2, $t4, shell_parser_avanca_busca

    # Verifica se o terceiro byte é hífen (0x2D = 45)
    bne     $t3, $t4, shell_parser_avanca_busca

    # Encontrou o delimitador estrito " --"!
    # Coloca terminador nulo na posição do espaço para fechar a opção anterior
    sb      $zero, 0($t0)

    # O valor da nova opção começa após os dois hífens (ponteiro + 3)
    addiu   $t6, $t0, 3

    # Salva o ponteiro na variável de argumento correspondente ao contador
    li      $t7, 1
    beq     $t5, $t7, shell_parser_salva_arg1

    li      $t7, 2
    beq     $t5, $t7, shell_parser_salva_arg2

    li      $t7, 3
    beq     $t5, $t7, shell_parser_salva_arg3

    li      $t7, 4
    beq     $t5, $t7, shell_parser_salva_arg4

    # Mais de 4 argumentos: ignora os adicionais
    j       shell_parser_avanca_delimitador


shell_parser_salva_arg1:
    sw      $t6, shell_arg1_ptr
    j       shell_parser_avanca_delimitador

shell_parser_salva_arg2:
    sw      $t6, shell_arg2_ptr
    j       shell_parser_avanca_delimitador

shell_parser_salva_arg3:
    sw      $t6, shell_arg3_ptr
    j       shell_parser_avanca_delimitador

shell_parser_salva_arg4:
    sw      $t6, shell_arg4_ptr
    j       shell_parser_avanca_delimitador


shell_parser_avanca_delimitador:

    # Incrementa a quantidade de opções encontradas
    addiu   $t5, $t5, 1

    # Salta o delimitador (3 bytes: espaço e dois hífens)
    addiu   $t0, $t0, 3

    # Continua procurando os próximos delimitadores
    j       shell_parser_busca_delimitador


shell_parser_avanca_busca:

    # Avança um byte na linha
    addiu   $t0, $t0, 1

    # Continua a busca
    j       shell_parser_busca_delimitador


shell_parser_fim:

    # Retorna da rotina de parsing
    jr      $ra


# ============================================================
# SUB-ROTINAS DO DESPACHANTE DE COMANDOS (DISPATCHER)
# ============================================================

# ------------------------------------------------------------
# shell_despachar_comando()
#
# Identifica o comando em shell_cmd_token e o encaminha para
# o manipulador apropriado
#
# Retorno:
#   $v0 = 0 (continua) ou -1 (solicitação de encerramento)
# ------------------------------------------------------------

shell_despachar_comando:

    # Reserva espaço na pilha para chamada de sub-rotinas
    addiu   $sp, $sp, -4

    # Salva o endereço de retorno
    sw      $ra, 0($sp)

    # 1. Comando addMorador
    la      $a0, shell_cmd_token
    la      $a1, cmd_addMorador
    jal     shell_strcmp
    bnez    $v0, shell_tratar_addMorador

    # 2. Comando rmvMorador
    la      $a0, shell_cmd_token
    la      $a1, cmd_rmvMorador
    jal     shell_strcmp
    bnez    $v0, shell_tratar_rmvMorador

    # 3. Comando addAuto
    la      $a0, shell_cmd_token
    la      $a1, cmd_addAuto
    jal     shell_strcmp
    bnez    $v0, shell_tratar_addAuto

    # 4. Comando rmvAuto
    la      $a0, shell_cmd_token
    la      $a1, cmd_rmvAuto
    jal     shell_strcmp
    bnez    $v0, shell_tratar_rmvAuto

    # 5. Comando limparAp
    la      $a0, shell_cmd_token
    la      $a1, cmd_limparAp
    jal     shell_strcmp
    bnez    $v0, shell_tratar_limparAp

    # 6. Comando infoAp
    la      $a0, shell_cmd_token
    la      $a1, cmd_infoAp
    jal     shell_strcmp
    bnez    $v0, shell_tratar_infoAp

    # 7. Comando infoGeral
    la      $a0, shell_cmd_token
    la      $a1, cmd_infoGeral
    jal     shell_strcmp
    bnez    $v0, shell_tratar_infoGeral

    # 8. Comando salvar
    la      $a0, shell_cmd_token
    la      $a1, cmd_salvar
    jal     shell_strcmp
    bnez    $v0, shell_tratar_salvar

    # 9. Comando recarregar
    la      $a0, shell_cmd_token
    la      $a1, cmd_recarregar
    jal     shell_strcmp
    bnez    $v0, shell_tratar_recarregar

    # 10. Comando formatar
    la      $a0, shell_cmd_token
    la      $a1, cmd_formatar
    jal     shell_strcmp
    bnez    $v0, shell_tratar_formatar

    # 11. Comando de saída (sair ou exit)
    la      $a0, shell_cmd_token
    la      $a1, cmd_sair
    jal     shell_strcmp
    bnez    $v0, shell_tratar_sair

    la      $a0, shell_cmd_token
    la      $a1, cmd_exit
    jal     shell_strcmp
    bnez    $v0, shell_tratar_sair

    # Comando não reconhecido: exibe estritamente "Comando invalido\n"
    li      $v0, 4
    la      $a0, msg_cmd_invalido
    syscall

    # Define retorno normal
    li      $v0, 0
    j       shell_despacho_fim


# ------------------------------------------------------------
# MANIPULADORES ESPECÍFICOS DOS 10 COMANDOS
# ------------------------------------------------------------

# --- cmd_1: addMorador --<ap> --<nome> ---
shell_tratar_addMorador:

    # Verifica se ambos os argumentos foram fornecidos
    lw      $t0, shell_arg1_ptr
    beqz    $t0, shell_erro_cmd_invalido
    lw      $t1, shell_arg2_ptr
    beqz    $t1, shell_erro_cmd_invalido

    # Converte o número do AP de string para inteiro
    move    $a0, $t0
    jal     shell_atoi

    # Se a conversão falhou, AP é inválido
    beqz    $v1, shell_erro_ap_invalido

    # Passa o número do AP convertido em $a0
    move    $a0, $v0

    # Passa o ponteiro do nome em $a1
    lw      $a1, shell_arg2_ptr

    # Invoca o cadastro do morador no domínio
    jal     cadastro_adicionar_morador

    # Avalia o retorno de status da operação
    move    $a0, $v0
    jal     shell_imprimir_erro_retorno

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_2: rmvMorador --<ap> --<nome> ---
shell_tratar_rmvMorador:

    # Verifica se ambos os argumentos foram fornecidos
    lw      $t0, shell_arg1_ptr
    beqz    $t0, shell_erro_cmd_invalido
    lw      $t1, shell_arg2_ptr
    beqz    $t1, shell_erro_cmd_invalido

    # Converte o número do AP
    move    $a0, $t0
    jal     shell_atoi
    beqz    $v1, shell_erro_ap_invalido

    # Passa o AP em $a0 e o nome procurado em $a1
    move    $a0, $v0
    lw      $a1, shell_arg2_ptr

    # Invoca a remoção do morador
    jal     cadastro_remover_morador

    # Avalia o status de retorno
    move    $a0, $v0
    jal     shell_imprimir_erro_retorno

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_3: addAuto --<ap> --<tipo> --<modelo> --<placa> ---
shell_tratar_addAuto:

    # Valida se os 4 argumentos foram preenchidos
    lw      $t0, shell_arg1_ptr
    beqz    $t0, shell_erro_cmd_invalido
    lw      $t1, shell_arg2_ptr
    beqz    $t1, shell_erro_cmd_invalido
    lw      $t2, shell_arg3_ptr
    beqz    $t2, shell_erro_cmd_invalido
    lw      $t3, shell_arg4_ptr
    beqz    $t3, shell_erro_cmd_invalido

    # Converte o número do AP
    move    $a0, $t0
    jal     shell_atoi
    beqz    $v1, shell_erro_ap_invalido
    move    $s0, $v0            # guarda o AP convertido

    # Valida o tipo: lê o primeiro caractere da string em arg2
    lw      $t1, shell_arg2_ptr
    lbu     $t2, 0($t1)

    # Compara se é 'c' (ASCII 99)
    li      $t3, 99
    beq     $t2, $t3, shell_addAuto_tipo_carro

    # Compara se é 'm' (ASCII 109)
    li      $t3, 109
    beq     $t2, $t3, shell_addAuto_tipo_moto

    # Tipo inválido
    li      $v0, 4
    la      $a0, msg_tipo_invalido
    syscall
    li      $v0, 0
    j       shell_despacho_fim

shell_addAuto_tipo_carro:
    li      $s1, 1              # 1 = carro
    j       shell_addAuto_chama

shell_addAuto_tipo_moto:
    li      $s1, 2              # 2 = moto

shell_addAuto_chama:
    # Argumentos da chamada
    move    $a0, $s0            # $a0 = número do AP
    move    $a1, $s1            # $a1 = tipo (1 ou 2)
    lw      $a2, shell_arg3_ptr # $a2 = modelo
    lw      $a3, shell_arg4_ptr # $a3 = placa
    jal     cadastro_adicionar_auto

    # Avalia o retorno
    move    $a0, $v0
    jal     shell_imprimir_erro_retorno

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_4: rmvAuto --<ap> --<placa> ---
shell_tratar_rmvAuto:

    # Valida argumentos
    lw      $t0, shell_arg1_ptr
    beqz    $t0, shell_erro_cmd_invalido
    lw      $t1, shell_arg2_ptr
    beqz    $t1, shell_erro_cmd_invalido

    # Converte número do AP
    move    $a0, $t0
    jal     shell_atoi
    beqz    $v1, shell_erro_ap_invalido

    # Prepara chamada
    move    $a0, $v0
    lw      $a1, shell_arg2_ptr
    jal     cadastro_remover_auto

    # Avalia o retorno
    move    $a0, $v0
    jal     shell_imprimir_erro_retorno

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_5: limparAp --<ap> ---
shell_tratar_limparAp:

    # Valida argumento do AP
    lw      $t0, shell_arg1_ptr
    beqz    $t0, shell_erro_cmd_invalido

    # Converte o número do AP
    move    $a0, $t0
    jal     shell_atoi
    beqz    $v1, shell_erro_ap_invalido

    # Invoca limpeza completa do AP
    move    $a0, $v0
    jal     cadastro_limpar_ap

    # Avalia o retorno
    move    $a0, $v0
    jal     shell_imprimir_erro_retorno

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_6: infoAp --<ap|all> ---
shell_tratar_infoAp:

    # Valida existência de argumento
    lw      $t0, shell_arg1_ptr
    beqz    $t0, shell_erro_cmd_invalido

    # Compara se o argumento é exatamente "all"
    move    $a0, $t0
    la      $a1, str_all
    jal     shell_strcmp
    bnez    $v0, shell_infoAp_executa_all

    # Não é "all", converte para número de apartamento
    lw      $a0, shell_arg1_ptr
    jal     shell_atoi
    beqz    $v1, shell_erro_ap_invalido

    # Consulta apartamento individual ($a1 = 0)
    move    $a0, $v0
    li      $a1, 0
    jal     consulta_info_ap

    # Avalia se o AP era inválido
    move    $a0, $v0
    jal     shell_imprimir_erro_retorno

    li      $v0, 0
    j       shell_despacho_fim

shell_infoAp_executa_all:
    # Consulta todos os apartamentos ($a1 = 1)
    li      $a0, 0
    li      $a1, 1
    jal     consulta_info_ap

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_7: infoGeral ---
shell_tratar_infoGeral:

    # Invoca a exibição do panorama geral
    jal     consulta_info_geral

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_8: salvar ---
shell_tratar_salvar:

    # Invoca a gravação em disco
    jal     persist_salvar

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_9: recarregar ---
shell_tratar_recarregar:

    # Invoca a releitura do arquivo em disco
    jal     persist_recarregar

    li      $v0, 0
    j       shell_despacho_fim


# --- cmd_10: formatar ---
shell_tratar_formatar:

    # Zera as informações em memória volátil sem tocar no disco
    jal     persist_formatar

    li      $v0, 0
    j       shell_despacho_fim


# --- Encerramento ---
shell_tratar_sair:

    # Retorna -1 para quebrar o loop do terminal
    li      $v0, -1
    j       shell_despacho_fim


# Tratadores de atalho para erros de sintaxe
shell_erro_cmd_invalido:
    li      $v0, 4
    la      $a0, msg_cmd_invalido
    syscall
    li      $v0, 0
    j       shell_despacho_fim

shell_erro_ap_invalido:
    li      $v0, 4
    la      $a0, msg_ap_invalido
    syscall
    li      $v0, 0
    j       shell_despacho_fim


shell_despacho_fim:

    # Restaura o endereço de retorno
    lw      $ra, 0($sp)

    # Libera espaço da pilha
    addiu   $sp, $sp, 4

    # Retorna
    jr      $ra


# ============================================================
# SUB-ROTINAS DE SUPORTE (STRCMP, ATOI, MENSAGENS)
# ============================================================

# ------------------------------------------------------------
# shell_strcmp()
#
# Compara duas strings terminadas em '\0'
# Entrada:
#   $a0 = ponteiro da primeira string
#   $a1 = ponteiro da segunda string
# Retorno:
#   $v0 = 1 se forem exatamente iguais, 0 se forem diferentes
# ------------------------------------------------------------

shell_strcmp:

    move    $t0, $a0
    move    $t1, $a1


shell_strcmp_loop:

    # Lê um byte da primeira string
    lbu     $t2, 0($t0)

    # Lê o byte correspondente da segunda string
    lbu     $t3, 0($t1)

    # Se forem diferentes, strings não coincidem
    bne     $t2, $t3, shell_strcmp_diferentes

    # Se ambos são zero, as duas strings terminaram juntas
    beqz    $t2, shell_strcmp_iguais

    # Avança para o próximo caractere
    addiu   $t0, $t0, 1
    addiu   $t1, $t1, 1

    # Continua a comparação
    j       shell_strcmp_loop


shell_strcmp_iguais:
    li      $v0, 1
    jr      $ra


shell_strcmp_diferentes:
    li      $v0, 0
    jr      $ra


# ------------------------------------------------------------
# shell_atoi()
#
# Converte uma string de dígitos numéricos em valor inteiro
# Entrada:
#   $a0 = ponteiro para a string numérica
# Retorno:
#   $v0 = valor inteiro calculado
#   $v1 = flag de validade (1 = sucesso, 0 = falha de caractere)
# ------------------------------------------------------------

shell_atoi:

    li      $v0, 0              # resultado acumulado
    li      $v1, 0              # assume inválido inicialmente
    move    $t0, $a0            # ponteiro de leitura


shell_atoi_loop:

    lbu     $t1, 0($t0)

    # Fim da string
    beqz    $t1, shell_atoi_fim

    # Verifica se caractere é menor que '0' (ASCII 48)
    li      $t2, 48
    blt     $t1, $t2, shell_atoi_invalido

    # Verifica se caractere é maior que '9' (ASCII 57)
    li      $t2, 57
    bgt     $t1, $t2, shell_atoi_invalido

    # Converte o caractere ASCII para dígito numérico subtraindo 48
    addiu   $t3, $t1, -48

    # Multiplica o acumulado atual por 10
    li      $t4, 10
    mul     $v0, $v0, $t4


    # Soma o novo dígito ao acumulado
    addu    $v0, $v0, $t3

    # Marca que pelo menos um dígito válido foi processado
    li      $v1, 1

    # Avança ponteiro
    addiu   $t0, $t0, 1
    j       shell_atoi_loop


shell_atoi_invalido:
    li      $v0, 0
    li      $v1, 0
    jr      $ra


shell_atoi_fim:
    jr      $ra


# ------------------------------------------------------------
# shell_imprimir_erro_retorno()
#
# Avalia o código retornado em $a0 e imprime a mensagem literal
# correspondente caso haja erro (se $a0 == OK, não imprime nada)
# ------------------------------------------------------------

shell_imprimir_erro_retorno:

    # Sucesso não gera mensagem no terminal
    beq     $a0, OK, shell_erro_msg_fim

    # Código AP_INVALIDO
    li      $t0, AP_INVALIDO
    beq     $a0, $t0, shell_erro_msg_ap

    # Código MORADOR_NAO_ENCONTRADO
    li      $t0, MORADOR_NAO_ENCONTRADO
    beq     $a0, $t0, shell_erro_msg_morador

    # Código AUTO_NAO_ENCONTRADO
    li      $t0, AUTO_NAO_ENCONTRADO
    beq     $a0, $t0, shell_erro_msg_auto

    # Código TIPO_INVALIDO
    li      $t0, TIPO_INVALIDO
    beq     $a0, $t0, shell_erro_msg_tipo

    # Código LIMITE_MORADORES_ATINGIDO
    li      $t0, LIMITE_MORADORES_ATINGIDO
    beq     $a0, $t0, shell_erro_msg_lim_moradores

    # Código LIMITE_AUTOS_ATINGIDO
    li      $t0, LIMITE_AUTOS_ATINGIDO
    beq     $a0, $t0, shell_erro_msg_lim_autos

    # Erro genérico de entrada
    li      $v0, 4
    la      $a0, msg_cmd_invalido
    syscall
    jr      $ra

shell_erro_msg_ap:
    li      $v0, 4              # Seleciona chamada de impressão de string
    la      $a0, msg_ap_invalido # Carrega mensagem "Falha: AP invalido"
    syscall                     # Imprime mensagem de erro
    jr      $ra                 # Retorna ao despachante

shell_erro_msg_morador:
    li      $v0, 4              # Seleciona chamada de impressão de string
    la      $a0, msg_morador_nao_encontrado # Carrega mensagem "Falha: morador nao encontrado"
    syscall                     # Imprime mensagem de erro
    jr      $ra                 # Retorna ao despachante

shell_erro_msg_auto:
    li      $v0, 4              # Seleciona chamada de impressão de string
    la      $a0, msg_auto_nao_encontrado # Carrega mensagem "Falha: automóvel nao encontrado"
    syscall                     # Imprime mensagem de erro
    jr      $ra                 # Retorna ao despachante

shell_erro_msg_tipo:
    li      $v0, 4              # Seleciona chamada de impressão de string
    la      $a0, msg_tipo_invalido # Carrega mensagem "Falha: tipo invalido"
    syscall                     # Imprime mensagem de erro
    jr      $ra                 # Retorna ao despachante

shell_erro_msg_lim_moradores:
    li      $v0, 4              # Seleciona chamada de impressão de string
    la      $a0, msg_limite_moradores # Carrega mensagem de limite de moradores
    syscall                     # Imprime mensagem de erro
    jr      $ra                 # Retorna ao despachante

shell_erro_msg_lim_autos:
    li      $v0, 4              # Seleciona chamada de impressão de string
    la      $a0, msg_limite_autos # Carrega mensagem de limite de veículos
    syscall                     # Imprime mensagem de erro
    jr      $ra                 # Retorna ao despachante

shell_erro_msg_fim:
    jr      $ra                 # Retorna sem imprimir nada (operação bem-sucedida)