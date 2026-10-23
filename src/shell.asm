# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Erik Vinicius Gomes de Lima
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores (UFRPE - 2026.2)
# Professor: Prof. Vítor A Coutinho
# Arquivo: shell.asm
# Descrição: terminal interativo (REPL), parser de delimitador ' --' e despacho dos comandos
# ============================================================
# ------------------------------------------------------------
# ÁREA DE DADOS DO MÓDULO
# ------------------------------------------------------------

.data  # Seleciona a seção de dados estáticos.

# Banner do terminal com as iniciais do grupo (Requisito R5)
shell_banner:                   .asciiz "KJP-shell>> "  # Define em shell_banner uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Buffer de leitura da linha digitada pelo usuário (Requisito R4)
shell_buffer_linha:             .space 256  # Reserva 256 bytes para armazenamento.

# Buffer que armazena o primeiro token (nome do comando extraído)
shell_cmd_token:                .space 32  # Reserva 32 bytes para armazenamento.

# Ponteiros para os argumentos extraídos pelo parser após " --"
shell_arg1_ptr:                 .word 0  # Declara palavra(s) inicializada(s) com 0.
shell_arg2_ptr:                 .word 0  # Declara palavra(s) inicializada(s) com 0.
shell_arg3_ptr:                 .word 0  # Declara palavra(s) inicializada(s) com 0.
shell_arg4_ptr:                 .word 0  # Declara palavra(s) inicializada(s) com 0.

# Literais dos 10 comandos oficiais do sistema
cmd_addMorador:                 .asciiz "addMorador"  # Define em cmd_addMorador uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_rmvMorador:                 .asciiz "rmvMorador"  # Define em cmd_rmvMorador uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_addAuto:                    .asciiz "addAuto"  # Define em cmd_addAuto uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_rmvAuto:                    .asciiz "rmvAuto"  # Define em cmd_rmvAuto uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_limparAp:                   .asciiz "limparAp"  # Define em cmd_limparAp uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_infoAp:                     .asciiz "infoAp"  # Define em cmd_infoAp uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_infoGeral:                  .asciiz "infoGeral"  # Define em cmd_infoGeral uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_salvar:                     .asciiz "salvar"  # Define em cmd_salvar uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_recarregar:                 .asciiz "recarregar"  # Define em cmd_recarregar uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_formatar:                   .asciiz "formatar"  # Define em cmd_formatar uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Comandos de encerramento amigável do terminal
cmd_sair:                       .asciiz "sair"  # Define em cmd_sair uma string terminada em nulo usada pelas mensagens/dados do módulo.
cmd_exit:                       .asciiz "exit"  # Define em cmd_exit uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Palavra-chave para a opção --all no comando infoAp
str_all:                        .asciiz "all"  # Define em str_all uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Modo de operação de I/O (0 = console padrão MARS com syscalls, 1 = Keyboard e Display MMIO)
shell_modo_mmio:                .word 0  # Declara palavra(s) inicializada(s) com 0.

# Palavra-chave do comando para alternar modo MMIO em tempo de execução
cmd_mmio:                       .asciiz "mmio"  # Define em cmd_mmio uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Mensagens de transição do modo MMIO
msg_mmio_ativado:               .asciiz "[MMIO] Modo Keyboard e Display MMIO ativado!\n[MMIO] Conecte a ferramenta em Tools -> Keyboard and Display MMIO Simulator.\n"  # Define em msg_mmio_ativado uma string terminada em nulo usada pelas mensagens/dados do módulo.
msg_mmio_desativado:            .asciiz "[MMIO] Modo MMIO desativado. Retornando ao console padrao.\n"  # Define em msg_mmio_desativado uma string terminada em nulo usada pelas mensagens/dados do módulo.

# Mensagens padronizadas de erro e validação exigidas no projeto
msg_cmd_invalido:               .asciiz "Comando invalido\n"  # Define em msg_cmd_invalido uma string terminada em nulo usada pelas mensagens/dados do módulo.
msg_ap_invalido:                .asciiz "Falha: AP invalido\n"  # Define em msg_ap_invalido uma string terminada em nulo usada pelas mensagens/dados do módulo.
msg_limite_moradores:           .asciiz "Falha: AP com numero max de moradores\n"  # Define em msg_limite_moradores uma string terminada em nulo usada pelas mensagens/dados do módulo.
msg_morador_nao_encontrado:     .asciiz "Falha: morador nao encontrado\n"  # Define em msg_morador_nao_encontrado uma string terminada em nulo usada pelas mensagens/dados do módulo.
msg_tipo_invalido:              .asciiz "Falha: tipo invalido\n"  # Define em msg_tipo_invalido uma string terminada em nulo usada pelas mensagens/dados do módulo.
msg_limite_autos:               .asciiz "Falha: AP com numero max de automóveis\n"  # Define em msg_limite_autos uma string terminada em nulo usada pelas mensagens/dados do módulo.
msg_auto_nao_encontrado:        .asciiz "Falha: automóvel nao encontrado\n"  # Define em msg_auto_nao_encontrado uma string terminada em nulo usada pelas mensagens/dados do módulo.


# ------------------------------------------------------------
# ROTINAS PÚBLICAS
# ------------------------------------------------------------

# Torna a rotina de inicialização acessível ao módulo principal
.globl shell_inicializar  # Exporta shell_inicializar para uso como símbolo global.

# Torna a rotina de execução acessível ao módulo principal
.globl shell_executar  # Exporta shell_executar para uso como símbolo global.

# Torna a rotina de encerramento acessível ao módulo principal
.globl shell_encerrar  # Exporta shell_encerrar para uso como símbolo global.

# Torna a flag de modo MMIO acessível externamente
.globl shell_modo_mmio  # Exporta shell_modo_mmio para uso como símbolo global.

# Rotinas da camada de abstração de I/O (Syscall vs MMIO)
.globl shell_io_imprimir_string  # Exporta shell_io_imprimir_string para uso como símbolo global.
.globl shell_io_ler_linha  # Exporta shell_io_ler_linha para uso como símbolo global.
.globl shell_io_imprimir_int  # Exporta shell_io_imprimir_int para uso como símbolo global.
.globl shell_io_imprimir_char  # Exporta shell_io_imprimir_char para uso como símbolo global.


# Seleciona a seção de instruções
.text  # Seleciona a seção de instruções executáveis.


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
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Retorna para o chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


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
    addiu   $sp, $sp, -16  # Reserva espaço de pilha ajustando $sp em -16 bytes.

    # Salva o endereço de retorno da sub-rotina
    sw $ra, 12($sp)  # Armazena palavra de $ra na posição de memória 12($sp).

    # Salva $s0 para preservar estado de ponteiros
    sw $s0, 8($sp)  # Armazena palavra de $s0 na posição de memória 8($sp).

    # Salva $s1 para controle de argumentos
    sw $s1, 4($sp)  # Armazena palavra de $s1 na posição de memória 4($sp).

    # Salva $s2 para controle auxiliar
    sw $s2, 0($sp)  # Armazena palavra de $s2 na posição de memória 0($sp).


shell_loop_prompt:

    # Carrega o banner oficial do terminal "<iniciais>-shell>> "
    la      $a0, shell_banner  # Carrega em $a0 o endereço shell_banner para passá-lo como argumento.

    # Exibe o banner no console ou display MMIO via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Passa o endereço do buffer de entrada da linha
    la      $a0, shell_buffer_linha  # Carrega em $a0 o endereço shell_buffer_linha para passá-lo como argumento.

    # Define o tamanho máximo de leitura (256 bytes)
    li      $a1, 256  # Carrega o valor imediato 256 no registrador $a1.

    # Lê a linha digitada pelo usuário via camada de I/O (Syscall ou MMIO)
    jal     shell_io_ler_linha  # Chama a rotina shell_io_ler_linha e salva o endereço de retorno em $ra.

    # Sanitiza a linha lida removendo \n ou \r
    jal     shell_sanitizar_linha  # Chama a rotina shell_sanitizar_linha e salva o endereço de retorno em $ra.

    # Faz o parsing da linha isolando o comando e as opções
    jal     shell_parser  # Chama a rotina shell_parser e salva o endereço de retorno em $ra.

    # Se nenhum comando foi digitado (linha em branco), repete o prompt
    la      $t0, shell_cmd_token  # Obtém o endereço de shell_cmd_token e o coloca em $t0.

    # Lê o primeiro byte do comando extraído
    lbu $t1, 0($t0)  # Carrega byte sem sinal da posição 0($t0) para $t1.

    # Volta para o início do loop caso o comando seja vazio
    beqz    $t1, shell_loop_prompt

    # Despacha o comando para a rotina correspondente
    jal     shell_despachar_comando  # Chama a rotina shell_despachar_comando e salva o endereço de retorno em $ra.

    # Se a rotina de despacho retornar -1 em $v0, o usuário pediu para sair
    li      $t0, -1  # Carrega o valor imediato -1 no registrador $t0.

    # Desvia para encerramento caso retorno seja -1
    beq     $v0, $t0, shell_sair_loop  # Se $v0 e $t0 forem iguais, desvia para shell_sair_loop.

    # Continua no loop principal aguardando o próximo comando
    j       shell_loop_prompt  # Desvia a execução incondicionalmente para shell_loop_prompt.


shell_sair_loop:

    # Restaura o registrador $s2
    lw $s2, 0($sp)  # Carrega palavra da posição 0($sp) para $s2.

    # Restaura o registrador $s1
    lw $s1, 4($sp)  # Carrega palavra da posição 4($sp) para $s1.

    # Restaura o registrador $s0
    lw $s0, 8($sp)  # Carrega palavra da posição 8($sp) para $s0.

    # Restaura o endereço de retorno original
    lw $ra, 12($sp)  # Carrega palavra da posição 12($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 16  # Libera espaço de pilha ajustando $sp em 16 bytes.

    # Define retorno de sucesso
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Retorna ao módulo principal
    jr      $ra  # Retorna ao endereço guardado em $ra.


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
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Retorna ao chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


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
    la      $t0, shell_buffer_linha  # Obtém o endereço de shell_buffer_linha e o coloca em $t0.


shell_sanitizar_loop:

    # Lê um byte do buffer de entrada
    lbu $t1, 0($t0)  # Carrega byte sem sinal da posição 0($t0) para $t1.

    # Termina se encontrar o fim da string
    beqz    $t1, shell_sanitizar_fim

    # Código ASCII do salto de linha (\n = 10)
    li      $t2, 10  # Carrega o valor imediato 10 no registrador $t2.

    # Se for \n, substitui por zero
    beq     $t1, $t2, shell_sanitizar_trocar  # Se $t1 e $t2 forem iguais, desvia para shell_sanitizar_trocar.

    # Código ASCII do retorno de carro (\r = 13)
    li      $t2, 13  # Carrega o valor imediato 13 no registrador $t2.

    # Se for \r, substitui por zero
    beq     $t1, $t2, shell_sanitizar_trocar  # Se $t1 e $t2 forem iguais, desvia para shell_sanitizar_trocar.

    # Avança para o próximo byte
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.

    # Continua a varredura
    j       shell_sanitizar_loop  # Desvia a execução incondicionalmente para shell_sanitizar_loop.


shell_sanitizar_trocar:

    # Grava o terminador nulo no lugar da quebra de linha
    sb $zero, 0($t0)  # Armazena byte de $zero na posição de memória 0($t0).


shell_sanitizar_fim:

    # Retorna da sanitização
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# shell_parser()
#
# Decompõe a linha lida no nome do comando e em opções separadas
# pelo delimitador estrito " --" (espaço e dois hífens)
# ------------------------------------------------------------

shell_parser:

    # Zera o buffer do nome do comando
    la      $t0, shell_cmd_token  # Obtém o endereço de shell_cmd_token e o coloca em $t0.

    # Escreve terminador nulo na primeira posição
    sb $zero, 0($t0)  # Armazena byte de $zero na posição de memória 0($t0).

    # Zera os ponteiros dos argumentos
    sw      $zero, shell_arg1_ptr  # Armazena palavra de $zero na posição de memória shell_arg1_ptr.
    # Zera o ponteiro do segundo argumento
    sw      $zero, shell_arg2_ptr  # Armazena palavra de $zero na posição de memória shell_arg2_ptr.
    # Zera o ponteiro do terceiro argumento
    sw      $zero, shell_arg3_ptr  # Armazena palavra de $zero na posição de memória shell_arg3_ptr.
    # Zera o ponteiro do quarto argumento
    sw      $zero, shell_arg4_ptr  # Armazena palavra de $zero na posição de memória shell_arg4_ptr.

    # Inicia a leitura do buffer de linha
    la      $t0, shell_buffer_linha  # Obtém o endereço de shell_buffer_linha e o coloca em $t0.


# Pula espaços em branco iniciais (trim)
shell_parser_pula_espacos_inicio:

    # Lê um byte do início da linha
    lbu $t1, 0($t0)  # Carrega byte sem sinal da posição 0($t0) para $t1.

    # Termina se a linha for vazia
    beqz    $t1, shell_parser_fim

    # Código ASCII do espaço em branco
    li      $t2, 32  # Carrega o valor imediato 32 no registrador $t2.

    # Se não for espaço, encontrou o início do comando
    bne     $t1, $t2, shell_parser_extrai_comando  # Se $t1 e $t2 forem diferentes, desvia para shell_parser_extrai_comando.

    # Avança ponteiro sobre o espaço em branco
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.

    # Continua pulando espaços iniciais
    j       shell_parser_pula_espacos_inicio  # Desvia a execução incondicionalmente para shell_parser_pula_espacos_inicio.


# Copia os caracteres do comando até encontrar espaço ou fim de linha
shell_parser_extrai_comando:

    # Ponteiro de destino em shell_cmd_token
    la      $t3, shell_cmd_token  # Obtém o endereço de shell_cmd_token e o coloca em $t3.

    # Limite máximo de caracteres para o nome do comando (31 bytes)
    li      $t4, 31  # Carrega o valor imediato 31 no registrador $t4.


shell_parser_copia_cmd_loop:

    # Lê o byte atual da linha
    lbu $t1, 0($t0)  # Carrega byte sem sinal da posição 0($t0) para $t1.

    # Fim da string encerra extração do comando
    beqz    $t1, shell_parser_cmd_fechar

    # Espaço em branco encerra o nome do comando
    li      $t2, 32  # Carrega o valor imediato 32 no registrador $t2.
    # Encerra se encontrar espaco em branco
    beq     $t1, $t2, shell_parser_cmd_fechar  # Se $t1 e $t2 forem iguais, desvia para shell_parser_cmd_fechar.

    # Se o limite do buffer for atingido, encerra
    blez    $t4, shell_parser_cmd_fechar  # Se $t4 for menor ou igual a zero, desvia para shell_parser_cmd_fechar.

    # Salva o caractere no buffer do comando
    sb $t1, 0($t3)  # Armazena byte de $t1 na posição de memória 0($t3).

    # Avança ponteiro de destino
    addiu   $t3, $t3, 1  # Soma $t3 e 1, gravando o resultado em $t3.

    # Avança ponteiro de origem
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.

    # Decrementa o limite restante
    addiu   $t4, $t4, -1  # Soma $t4 e -1, gravando o resultado em $t4.

    # Continua copiando caracteres do comando
    j       shell_parser_copia_cmd_loop  # Desvia a execução incondicionalmente para shell_parser_copia_cmd_loop.


shell_parser_cmd_fechar:

    # Adiciona terminador nulo ao nome do comando
    sb $zero, 0($t3)  # Armazena byte de $zero na posição de memória 0($t3).


# Varredura do restante da linha em busca de opções iniciadas por " --"
shell_parser_varre_opcoes:

    # Contador de opções encontradas (1 a 4)
    li      $t5, 1  # Carrega o valor imediato 1 no registrador $t5.


shell_parser_busca_delimitador:

    # Lê o byte atual
    lbu $t1, 0($t0)  # Carrega byte sem sinal da posição 0($t0) para $t1.

    # Se for terminador nulo, encerra o parser
    beqz    $t1, shell_parser_fim

    # Lê o byte seguinte (+1)
    lbu $t2, 1($t0)  # Carrega byte sem sinal da posição 1($t0) para $t2.

    # Termina se o byte seguinte for nulo
    beqz    $t2, shell_parser_fim

    # Lê o terceiro byte (+2)
    lbu $t3, 2($t0)  # Carrega byte sem sinal da posição 2($t0) para $t3.

    # Termina se o terceiro byte for nulo
    beqz    $t3, shell_parser_fim

    # Verifica se o primeiro byte é espaço (0x20)
    li      $t4, 32  # Carrega o valor imediato 32 no registrador $t4.
    # Se o primeiro hifen nao coincidir, avanca busca
    bne     $t1, $t4, shell_parser_avanca_busca  # Se $t1 e $t4 forem diferentes, desvia para shell_parser_avanca_busca.

    # Verifica se o segundo byte é hífen (0x2D = 45)
    li      $t4, 45  # Carrega o valor imediato 45 no registrador $t4.
    # Se o segundo hifen nao coincidir, avanca busca
    bne     $t2, $t4, shell_parser_avanca_busca  # Se $t2 e $t4 forem diferentes, desvia para shell_parser_avanca_busca.

    # Verifica se o terceiro byte é hífen (0x2D = 45)
    bne     $t3, $t4, shell_parser_avanca_busca  # Se $t3 e $t4 forem diferentes, desvia para shell_parser_avanca_busca.

    # Encontrou o delimitador estrito " --"!
    # Coloca terminador nulo na posição do espaço para fechar a opção anterior
    sb $zero, 0($t0)  # Armazena byte de $zero na posição de memória 0($t0).

    # O valor da nova opção começa após os dois hífens (ponteiro + 3)
    addiu   $t6, $t0, 3  # Soma $t0 e 3, gravando o resultado em $t6.

    # Salva o ponteiro na variável de argumento correspondente ao contador
    li      $t7, 1  # Carrega o valor imediato 1 no registrador $t7.
    # Se for o primeiro argumento, desvia para salvar ponteiro 1
    beq     $t5, $t7, shell_parser_salva_arg1  # Se $t5 e $t7 forem iguais, desvia para shell_parser_salva_arg1.

    # Carrega indice 2 para comparacao de argumento
    li      $t7, 2  # Carrega o valor imediato 2 no registrador $t7.
    # Se for o segundo argumento, desvia para salvar ponteiro 2
    beq     $t5, $t7, shell_parser_salva_arg2  # Se $t5 e $t7 forem iguais, desvia para shell_parser_salva_arg2.

    # Carrega indice 3 para comparacao de argumento
    li      $t7, 3  # Carrega o valor imediato 3 no registrador $t7.
    # Se for o terceiro argumento, desvia para salvar ponteiro 3
    beq     $t5, $t7, shell_parser_salva_arg3  # Se $t5 e $t7 forem iguais, desvia para shell_parser_salva_arg3.

    # Carrega indice 4 para comparacao de argumento
    li      $t7, 4  # Carrega o valor imediato 4 no registrador $t7.
    # Se for o quarto argumento, desvia para salvar ponteiro 4
    beq     $t5, $t7, shell_parser_salva_arg4  # Se $t5 e $t7 forem iguais, desvia para shell_parser_salva_arg4.

    # Mais de 4 argumentos: ignora os adicionais
    j       shell_parser_avanca_delimitador  # Desvia a execução incondicionalmente para shell_parser_avanca_delimitador.


shell_parser_salva_arg1:
    # Salva o endereco do argumento 1 na memoria
    sw      $t6, shell_arg1_ptr  # Armazena palavra de $t6 na posição de memória shell_arg1_ptr.
    # Avanca alem do delimitador para buscar proximas opcoes
    j       shell_parser_avanca_delimitador  # Desvia a execução incondicionalmente para shell_parser_avanca_delimitador.

shell_parser_salva_arg2:
    # Salva o endereco do argumento 2 na memoria
    sw      $t6, shell_arg2_ptr  # Armazena palavra de $t6 na posição de memória shell_arg2_ptr.
    # Avanca alem do delimitador para buscar proximas opcoes
    j       shell_parser_avanca_delimitador  # Desvia a execução incondicionalmente para shell_parser_avanca_delimitador.

shell_parser_salva_arg3:
    # Salva o endereco do argumento 3 na memoria
    sw      $t6, shell_arg3_ptr  # Armazena palavra de $t6 na posição de memória shell_arg3_ptr.
    # Avanca alem do delimitador para buscar proximas opcoes
    j       shell_parser_avanca_delimitador  # Desvia a execução incondicionalmente para shell_parser_avanca_delimitador.

shell_parser_salva_arg4:
    # Salva o endereco do argumento 4 na memoria
    sw      $t6, shell_arg4_ptr  # Armazena palavra de $t6 na posição de memória shell_arg4_ptr.
    # Avanca alem do delimitador para buscar proximas opcoes
    j       shell_parser_avanca_delimitador  # Desvia a execução incondicionalmente para shell_parser_avanca_delimitador.


shell_parser_avanca_delimitador:

    # Incrementa a quantidade de opções encontradas
    addiu   $t5, $t5, 1  # Soma $t5 e 1, gravando o resultado em $t5.

    # Salta o delimitador (3 bytes: espaço e dois hífens)
    addiu   $t0, $t0, 3  # Soma $t0 e 3, gravando o resultado em $t0.

    # Continua procurando os próximos delimitadores
    j       shell_parser_busca_delimitador  # Desvia a execução incondicionalmente para shell_parser_busca_delimitador.


shell_parser_avanca_busca:

    # Avança um byte na linha
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.

    # Continua a busca
    j       shell_parser_busca_delimitador  # Desvia a execução incondicionalmente para shell_parser_busca_delimitador.


shell_parser_fim:

    # Retorna da rotina de parsing
    jr      $ra  # Retorna ao endereço guardado em $ra.


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

    # Reserva espaço na pilha para retorno e registradores salvos (16 bytes, múltiplo de 8)
    addiu   $sp, $sp, -16  # Reserva espaço de pilha ajustando $sp em -16 bytes.

    # Salva o endereço de retorno da sub-rotina
    sw $ra, 12($sp)  # Armazena palavra de $ra na posição de memória 12($sp).

    # Salva $s0 para preservar o contexto do chamador
    sw $s0, 8($sp)  # Armazena palavra de $s0 na posição de memória 8($sp).

    # Salva $s1 para preservar o contexto do chamador
    sw $s1, 4($sp)  # Armazena palavra de $s1 na posição de memória 4($sp).

    # 1. Comando addMorador
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'addMorador' para comparacao
    la      $a1, cmd_addMorador  # Carrega em $a1 o endereço cmd_addMorador para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_addMorador
    bnez    $v0, shell_tratar_addMorador

    # 2. Comando rmvMorador
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'rmvMorador' para comparacao
    la      $a1, cmd_rmvMorador  # Carrega em $a1 o endereço cmd_rmvMorador para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_rmvMorador
    bnez    $v0, shell_tratar_rmvMorador

    # 3. Comando addAuto
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'addAuto' para comparacao
    la      $a1, cmd_addAuto  # Carrega em $a1 o endereço cmd_addAuto para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_addAuto
    bnez    $v0, shell_tratar_addAuto

    # 4. Comando rmvAuto
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'rmvAuto' para comparacao
    la      $a1, cmd_rmvAuto  # Carrega em $a1 o endereço cmd_rmvAuto para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_rmvAuto
    bnez    $v0, shell_tratar_rmvAuto

    # 5. Comando limparAp
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'limparAp' para comparacao
    la      $a1, cmd_limparAp  # Carrega em $a1 o endereço cmd_limparAp para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_limparAp
    bnez    $v0, shell_tratar_limparAp

    # 6. Comando infoAp
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'infoAp' para comparacao
    la      $a1, cmd_infoAp  # Carrega em $a1 o endereço cmd_infoAp para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_infoAp
    bnez    $v0, shell_tratar_infoAp

    # 7. Comando infoGeral
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'infoGeral' para comparacao
    la      $a1, cmd_infoGeral  # Carrega em $a1 o endereço cmd_infoGeral para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_infoGeral
    bnez    $v0, shell_tratar_infoGeral

    # 8. Comando salvar
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'salvar' para comparacao
    la      $a1, cmd_salvar  # Carrega em $a1 o endereço cmd_salvar para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_salvar
    bnez    $v0, shell_tratar_salvar

    # 9. Comando recarregar
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'recarregar' para comparacao
    la      $a1, cmd_recarregar  # Carrega em $a1 o endereço cmd_recarregar para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_recarregar
    bnez    $v0, shell_tratar_recarregar

    # 10. Comando formatar
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'formatar' para comparacao
    la      $a1, cmd_formatar  # Carrega em $a1 o endereço cmd_formatar para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_formatar
    bnez    $v0, shell_tratar_formatar

    # 11. Comando mmio (Alterna entre Console Syscall e Display MMIO - Bônus +1.0)
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'mmio' para comparacao
    la      $a1, cmd_mmio  # Carrega em $a1 o endereço cmd_mmio para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_mmio
    bnez    $v0, shell_tratar_mmio

    # 12. Comando de saída (sair ou exit)
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'sair' para comparacao
    la      $a1, cmd_sair  # Carrega em $a1 o endereço cmd_sair para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_sair
    bnez    $v0, shell_tratar_sair

    # Carrega o token do comando extraido pelo parser
    la      $a0, shell_cmd_token  # Carrega em $a0 o endereço shell_cmd_token para passá-lo como argumento.
    # Carrega o literal do comando 'exit' para comparacao
    la      $a1, cmd_exit  # Carrega em $a1 o endereço cmd_exit para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se for o comando correspondente, desvia para shell_tratar_sair
    bnez    $v0, shell_tratar_sair

    # Comando não reconhecido: exibe estritamente "Comando invalido\n" via I/O
    la      $a0, msg_cmd_invalido  # Carrega em $a0 o endereço msg_cmd_invalido para passá-lo como argumento.
    # Imprime mensagem textual via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.

    # Define retorno normal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# ------------------------------------------------------------
# MANIPULADORES ESPECÍFICOS DOS 10 COMANDOS
# ------------------------------------------------------------

# --- cmd_1: addMorador --<ap> --<nome> ---
shell_tratar_addMorador:

    # Verifica se ambos os argumentos foram fornecidos
    lw      $t0, shell_arg1_ptr  # Carrega palavra da posição shell_arg1_ptr para $t0.
    # Valida presenca do argumento obrigatorio
    beqz    $t0, shell_erro_cmd_invalido
    # Carrega o ponteiro do segundo argumento
    lw      $t1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $t1.
    # Valida presenca do argumento obrigatorio
    beqz    $t1, shell_erro_cmd_invalido

    # Converte o número do AP de string para inteiro
    move    $a0, $t0  # Copia o valor de $t0 para $a0.
    # Converte a string do argumento para numero inteiro
    jal     shell_atoi  # Chama a rotina shell_atoi e salva o endereço de retorno em $ra.

    # Se a conversão falhou, AP é inválido
    beqz    $v1, shell_erro_ap_invalido

    # Passa o número do AP convertido em $a0
    move    $a0, $v0  # Copia o valor de $v0 para $a0.

    # Passa o ponteiro do nome em $a1
    lw      $a1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $a1.

    # Invoca o cadastro do morador no domínio
    jal     cadastro_adicionar_morador  # Chama a rotina cadastro_adicionar_morador e salva o endereço de retorno em $ra.

    # Avalia o retorno de status da operação
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Avalia o codigo de retorno e exibe erro se houver falha
    jal     shell_imprimir_erro_retorno  # Chama a rotina shell_imprimir_erro_retorno e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_2: rmvMorador --<ap> --<nome> ---
shell_tratar_rmvMorador:

    # Verifica se ambos os argumentos foram fornecidos
    lw      $t0, shell_arg1_ptr  # Carrega palavra da posição shell_arg1_ptr para $t0.
    # Valida presenca do argumento obrigatorio
    beqz    $t0, shell_erro_cmd_invalido
    # Carrega o ponteiro do segundo argumento
    lw      $t1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $t1.
    # Valida presenca do argumento obrigatorio
    beqz    $t1, shell_erro_cmd_invalido

    # Converte o número do AP
    move    $a0, $t0  # Copia o valor de $t0 para $a0.
    # Converte a string do argumento para numero inteiro
    jal     shell_atoi  # Chama a rotina shell_atoi e salva o endereço de retorno em $ra.
    # Se a conversao numerica falhou, acusa AP invalido
    beqz    $v1, shell_erro_ap_invalido

    # Passa o AP em $a0 e o nome procurado em $a1
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Passa o segundo argumento como parametro em $a1
    lw      $a1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $a1.

    # Invoca a remoção do morador
    jal     cadastro_remover_morador  # Chama a rotina cadastro_remover_morador e salva o endereço de retorno em $ra.

    # Avalia o status de retorno
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Avalia o codigo de retorno e exibe erro se houver falha
    jal     shell_imprimir_erro_retorno  # Chama a rotina shell_imprimir_erro_retorno e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_3: addAuto --<ap> --<tipo> --<modelo> --<placa> ---
shell_tratar_addAuto:

    # Valida se os 4 argumentos foram preenchidos
    lw      $t0, shell_arg1_ptr  # Carrega palavra da posição shell_arg1_ptr para $t0.
    # Valida presenca do argumento obrigatorio
    beqz    $t0, shell_erro_cmd_invalido
    # Carrega o ponteiro do segundo argumento
    lw      $t1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $t1.
    # Valida presenca do argumento obrigatorio
    beqz    $t1, shell_erro_cmd_invalido
    # Carrega o ponteiro do terceiro argumento
    lw      $t2, shell_arg3_ptr  # Carrega palavra da posição shell_arg3_ptr para $t2.
    # Valida presenca do argumento obrigatorio
    beqz    $t2, shell_erro_cmd_invalido
    # Carrega o ponteiro do quarto argumento
    lw      $t3, shell_arg4_ptr  # Carrega palavra da posição shell_arg4_ptr para $t3.
    # Valida presenca do argumento obrigatorio
    beqz    $t3, shell_erro_cmd_invalido

    # Converte o número do AP
    move    $a0, $t0  # Copia o valor de $t0 para $a0.
    # Converte a string do argumento para numero inteiro
    jal     shell_atoi  # Chama a rotina shell_atoi e salva o endereço de retorno em $ra.
    # Se a conversao numerica falhou, acusa AP invalido
    beqz    $v1, shell_erro_ap_invalido
    move    $s0, $v0            # guarda o AP convertido

    # Valida o tipo: lê o primeiro caractere da string em arg2
    lw      $t1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $t1.
    # Le o primeiro caractere do tipo de veiculo
    lbu $t2, 0($t1)  # Carrega byte sem sinal da posição 0($t1) para $t2.

    # Compara se é 'c' (ASCII 99)
    li      $t3, 99  # Carrega o valor imediato 99 no registrador $t3.
    # Se for 'c', classifica como carro
    beq     $t2, $t3, shell_addAuto_tipo_carro  # Se $t2 e $t3 forem iguais, desvia para shell_addAuto_tipo_carro.

    # Compara se é 'm' (ASCII 109)
    li      $t3, 109  # Carrega o valor imediato 109 no registrador $t3.
    # Se for 'm', classifica como moto
    beq     $t2, $t3, shell_addAuto_tipo_moto  # Se $t2 e $t3 forem iguais, desvia para shell_addAuto_tipo_moto.

    # Tipo inválido: exibe mensagem de erro via camada de I/O
    la      $a0, msg_tipo_invalido  # Carrega em $a0 o endereço msg_tipo_invalido para passá-lo como argumento.
    # Imprime mensagem textual via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.
    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.

shell_addAuto_tipo_carro:
    li      $s1, 1              # 1 = carro
    # Desvia para preparar a chamada de adicao de veiculo
    j       shell_addAuto_chama  # Desvia a execução incondicionalmente para shell_addAuto_chama.

shell_addAuto_tipo_moto:
    li      $s1, 2              # 2 = moto

shell_addAuto_chama:
    # Argumentos da chamada
    move    $a0, $s0            # $a0 = número do AP
    move    $a1, $s1            # $a1 = tipo (1 ou 2)
    lw      $a2, shell_arg3_ptr # $a2 = modelo
    lw      $a3, shell_arg4_ptr # $a3 = placa
    # Chama a sub-rotina de cadastro de automovel
    jal     cadastro_adicionar_auto  # Chama a rotina cadastro_adicionar_auto e salva o endereço de retorno em $ra.

    # Avalia o retorno
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Avalia o codigo de retorno e exibe erro se houver falha
    jal     shell_imprimir_erro_retorno  # Chama a rotina shell_imprimir_erro_retorno e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_4: rmvAuto --<ap> --<placa> ---
shell_tratar_rmvAuto:

    # Valida argumentos
    lw      $t0, shell_arg1_ptr  # Carrega palavra da posição shell_arg1_ptr para $t0.
    # Valida presenca do argumento obrigatorio
    beqz    $t0, shell_erro_cmd_invalido
    # Carrega o ponteiro do segundo argumento
    lw      $t1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $t1.
    # Valida presenca do argumento obrigatorio
    beqz    $t1, shell_erro_cmd_invalido

    # Converte número do AP
    move    $a0, $t0  # Copia o valor de $t0 para $a0.
    # Converte a string do argumento para numero inteiro
    jal     shell_atoi  # Chama a rotina shell_atoi e salva o endereço de retorno em $ra.
    # Se a conversao numerica falhou, acusa AP invalido
    beqz    $v1, shell_erro_ap_invalido

    # Prepara chamada
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Passa o segundo argumento como parametro em $a1
    lw      $a1, shell_arg2_ptr  # Carrega palavra da posição shell_arg2_ptr para $a1.
    # Chama a sub-rotina de remocao de automovel
    jal     cadastro_remover_auto  # Chama a rotina cadastro_remover_auto e salva o endereço de retorno em $ra.

    # Avalia o retorno
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Avalia o codigo de retorno e exibe erro se houver falha
    jal     shell_imprimir_erro_retorno  # Chama a rotina shell_imprimir_erro_retorno e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_5: limparAp --<ap> ---
shell_tratar_limparAp:

    # Valida argumento do AP
    lw      $t0, shell_arg1_ptr  # Carrega palavra da posição shell_arg1_ptr para $t0.
    # Valida presenca do argumento obrigatorio
    beqz    $t0, shell_erro_cmd_invalido

    # Converte o número do AP
    move    $a0, $t0  # Copia o valor de $t0 para $a0.
    # Converte a string do argumento para numero inteiro
    jal     shell_atoi  # Chama a rotina shell_atoi e salva o endereço de retorno em $ra.
    # Se a conversao numerica falhou, acusa AP invalido
    beqz    $v1, shell_erro_ap_invalido

    # Invoca limpeza completa do AP
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Chama a sub-rotina de limpeza completa do apartamento
    jal     cadastro_limpar_ap  # Chama a rotina cadastro_limpar_ap e salva o endereço de retorno em $ra.

    # Avalia o retorno
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Avalia o codigo de retorno e exibe erro se houver falha
    jal     shell_imprimir_erro_retorno  # Chama a rotina shell_imprimir_erro_retorno e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_6: infoAp --<ap|all> ---
shell_tratar_infoAp:

    # Valida existência de argumento
    lw      $t0, shell_arg1_ptr  # Carrega palavra da posição shell_arg1_ptr para $t0.
    # Valida presenca do argumento obrigatorio
    beqz    $t0, shell_erro_cmd_invalido

    # Compara se o argumento é exatamente "all"
    move    $a0, $t0  # Copia o valor de $t0 para $a0.
    # Carrega o literal da opcao 'all'
    la      $a1, str_all  # Carrega em $a1 o endereço str_all para passá-lo como argumento.
    # Compara o comando digitado com o literal esperado
    jal     shell_strcmp  # Chama a rotina shell_strcmp e salva o endereço de retorno em $ra.
    # Se a opcao 'all' foi informada, desvia para listar todos os apartamentos
    bnez    $v0, shell_infoAp_executa_all

    # Não é "all", converte para número de apartamento
    lw      $a0, shell_arg1_ptr  # Carrega palavra da posição shell_arg1_ptr para $a0.
    # Converte a string do argumento para numero inteiro
    jal     shell_atoi  # Chama a rotina shell_atoi e salva o endereço de retorno em $ra.
    # Se a conversao numerica falhou, acusa AP invalido
    beqz    $v1, shell_erro_ap_invalido

    # Consulta apartamento individual ($a1 = 0)
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Define flag 0 para consulta individual do apartamento
    li      $a1, 0  # Carrega o valor imediato 0 no registrador $a1.
    # Executa a consulta detalhada do(s) apartamento(s)
    jal     consulta_info_ap  # Chama a rotina consulta_info_ap e salva o endereço de retorno em $ra.

    # Avalia se o AP era inválido
    move    $a0, $v0  # Copia o valor de $v0 para $a0.
    # Avalia o codigo de retorno e exibe erro se houver falha
    jal     shell_imprimir_erro_retorno  # Chama a rotina shell_imprimir_erro_retorno e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.

shell_infoAp_executa_all:
    # Consulta todos os apartamentos ($a1 = 1)
    li      $a0, 0  # Carrega o valor imediato 0 no registrador $a0.
    # Define flag 1 para consulta geral de todos os apartamentos
    li      $a1, 1  # Carrega o valor imediato 1 no registrador $a1.
    # Executa a consulta detalhada do(s) apartamento(s)
    jal     consulta_info_ap  # Chama a rotina consulta_info_ap e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_7: infoGeral ---
shell_tratar_infoGeral:

    # Invoca a exibição do panorama geral
    jal     consulta_info_geral  # Chama a rotina consulta_info_geral e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_8: salvar ---
shell_tratar_salvar:

    # Invoca a gravação em disco
    jal     persist_salvar  # Chama a rotina persist_salvar e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_9: recarregar ---
shell_tratar_recarregar:

    # Invoca a releitura do arquivo em disco
    jal     persist_recarregar  # Chama a rotina persist_recarregar e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_10: formatar ---
shell_tratar_formatar:

    # Zera as informações em memória volátil sem tocar no disco
    jal     persist_formatar  # Chama a rotina persist_formatar e salva o endereço de retorno em $ra.

    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- cmd_mmio: mmio (Bônus MMIO +1.0 Ponto) ---
shell_tratar_mmio:

    # Lê o valor atual da flag de modo MMIO
    lw      $t0, shell_modo_mmio  # Carrega palavra da posição shell_modo_mmio para $t0.

    # Inverte o valor da flag (0 vira 1, 1 vira 0)
    xori    $t0, $t0, 1  # Aplica a operação lógica XORI entre $t0 e 1, gravando o resultado em $t0.

    # Atualiza a flag na memória
    sw      $t0, shell_modo_mmio  # Armazena palavra de $t0 na posição de memória shell_modo_mmio.

    # Se a flag foi para zero, informa desativação
    beqz    $t0, shell_tratar_mmio_desativou

    # Informa ativação no console padrão do MARS
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    # Carrega mensagem de notificacao do modo MMIO ativado
    la      $a0, msg_mmio_ativado  # Carrega em $a0 o endereço msg_mmio_ativado para passá-lo como argumento.
    # Executa a chamada de sistema do simulador
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Informa ativação também no Display MMIO
    la      $a0, msg_mmio_ativado  # Carrega em $a0 o endereço msg_mmio_ativado para passá-lo como argumento.
    # Imprime notificacao no display MMIO
    jal     mmio_imprimir_string  # Chama a rotina mmio_imprimir_string e salva o endereço de retorno em $ra.

    # Define retorno normal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.

shell_tratar_mmio_desativou:

    # Informa desativação no console padrão
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.
    # Carrega mensagem de notificacao do modo MMIO desativado
    la      $a0, msg_mmio_desativado  # Carrega em $a0 o endereço msg_mmio_desativado para passá-lo como argumento.
    # Executa a chamada de sistema do simulador
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Define retorno normal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# --- Encerramento ---
shell_tratar_sair:

    # Retorna -1 para quebrar o loop do terminal
    li      $v0, -1  # Carrega o valor imediato -1 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


# Tratadores de atalho para erros de sintaxe
shell_erro_cmd_invalido:
    # Carrega mensagem de comando invalido
    la      $a0, msg_cmd_invalido  # Carrega em $a0 o endereço msg_cmd_invalido para passá-lo como argumento.
    # Imprime mensagem textual via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.
    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.

shell_erro_ap_invalido:
    # Carrega mensagem de apartamento invalido
    la      $a0, msg_ap_invalido  # Carrega em $a0 o endereço msg_ap_invalido para passá-lo como argumento.
    # Imprime mensagem textual via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.
    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Desvia para o encerramento do despachante
    j       shell_despacho_fim  # Desvia a execução incondicionalmente para shell_despacho_fim.


shell_despacho_fim:

    # Restaura o registrador preservado $s1
    lw $s1, 4($sp)  # Carrega palavra da posição 4($sp) para $s1.

    # Restaura o registrador preservado $s0
    lw $s0, 8($sp)  # Carrega palavra da posição 8($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 12($sp)  # Carrega palavra da posição 12($sp) para $ra.

    # Libera espaço da pilha
    addiu   $sp, $sp, 16  # Libera espaço de pilha ajustando $sp em 16 bytes.

    # Retorna
    jr      $ra  # Retorna ao endereço guardado em $ra.


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

    # Guarda o primeiro endereco recebido
    move    $t0, $a0  # Copia o valor de $a0 para $t0.
    # Guarda o segundo endereco recebido
    move    $t1, $a1  # Copia o valor de $a1 para $t1.


shell_strcmp_loop:

    # Lê um byte da primeira string
    lbu $t2, 0($t0)  # Carrega byte sem sinal da posição 0($t0) para $t2.

    # Lê o byte correspondente da segunda string
    lbu $t3, 0($t1)  # Carrega byte sem sinal da posição 0($t1) para $t3.

    # Se forem diferentes, strings não coincidem
    bne     $t2, $t3, shell_strcmp_diferentes  # Se $t2 e $t3 forem diferentes, desvia para shell_strcmp_diferentes.

    # Se ambos são zero, as duas strings terminaram juntas
    beqz    $t2, shell_strcmp_iguais

    # Avança para o próximo caractere
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.
    # Avanca ponteiro da segunda string
    addiu   $t1, $t1, 1  # Soma $t1 e 1, gravando o resultado em $t1.

    # Continua a comparação
    j       shell_strcmp_loop  # Desvia a execução incondicionalmente para shell_strcmp_loop.


shell_strcmp_iguais:
    # Retorna 1 indicando strings identicas
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.
    # Retorna para a sub-rotina chamadora
    jr      $ra  # Retorna ao endereço guardado em $ra.


shell_strcmp_diferentes:
    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Retorna para a sub-rotina chamadora
    jr      $ra  # Retorna ao endereço guardado em $ra.


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

    # Le o byte atual da string
    lbu $t1, 0($t0)  # Carrega byte sem sinal da posição 0($t0) para $t1.

    # Fim da string
    beqz    $t1, shell_atoi_fim

    # Verifica se caractere é menor que '0' (ASCII 48)
    li      $t2, 48  # Carrega o valor imediato 48 no registrador $t2.
    # Caractere antes de '0' na tabela ASCII e invalido
    blt     $t1, $t2, shell_atoi_invalido  # Se $t1 e $t2 forem menor que, desvia para shell_atoi_invalido.

    # Verifica se caractere é maior que '9' (ASCII 57)
    li      $t2, 57  # Carrega o valor imediato 57 no registrador $t2.
    # Caractere depois de '9' na tabela ASCII e invalido
    bgt     $t1, $t2, shell_atoi_invalido  # Se $t1 e $t2 forem maior que, desvia para shell_atoi_invalido.

    # Converte o caractere ASCII para dígito numérico subtraindo 48
    addiu   $t3, $t1, -48  # Soma $t1 e -48, gravando o resultado em $t3.

    # Multiplica o acumulado atual por 10
    li      $t4, 10  # Carrega o valor imediato 10 no registrador $t4.
    # Multiplica valor acumulado pela base decimal 10
    mul     $v0, $v0, $t4  # Multiplica $v0 por $t4 e grava o produto em $v0.


    # Soma o novo dígito ao acumulado
    addu    $v0, $v0, $t3  # Soma $v0 e $t3, gravando o resultado em $v0.

    # Marca que pelo menos um dígito válido foi processado
    li      $v1, 1  # Carrega o valor imediato 1 no registrador $v1.

    # Avança ponteiro
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.
    # Continua loop de conversao de digitos
    j       shell_atoi_loop  # Desvia a execução incondicionalmente para shell_atoi_loop.


shell_atoi_invalido:
    # Define retorno de continuacao do terminal
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.
    # Marca flag de validade como 0 (erro de conversao)
    li      $v1, 0  # Carrega o valor imediato 0 no registrador $v1.
    # Retorna para a sub-rotina chamadora
    jr      $ra  # Retorna ao endereço guardado em $ra.


shell_atoi_fim:
    # Retorna para a sub-rotina chamadora
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# shell_imprimir_erro_retorno()
#
# Avalia o código retornado em $a0 e imprime a mensagem literal
# correspondente caso haja erro (se $a0 == OK, não imprime nada)
# ------------------------------------------------------------

shell_imprimir_erro_retorno:

    # Sucesso não gera mensagem no terminal
    beq     $a0, OK, shell_erro_msg_fim  # Se $a0 e OK forem iguais, desvia para shell_erro_msg_fim.

    # Reserva espaço na pilha alinhado em 8 bytes
    addiu   $sp, $sp, -8  # Reserva espaço de pilha ajustando $sp em -8 bytes.

    # Salva o endereço de retorno
    sw $ra, 4($sp)  # Armazena palavra de $ra na posição de memória 4($sp).

    # Código AP_INVALIDO
    li      $t0, AP_INVALIDO  # Carrega o valor imediato AP_INVALIDO no registrador $t0.
    # Se o erro for ap, desvia para exibir a mensagem
    beq     $a0, $t0, shell_erro_msg_ap  # Se $a0 e $t0 forem iguais, desvia para shell_erro_msg_ap.

    # Código MORADOR_NAO_ENCONTRADO
    li      $t0, MORADOR_NAO_ENCONTRADO  # Carrega o valor imediato MORADOR_NAO_ENCONTRADO no registrador $t0.
    # Se o erro for morador, desvia para exibir a mensagem
    beq     $a0, $t0, shell_erro_msg_morador  # Se $a0 e $t0 forem iguais, desvia para shell_erro_msg_morador.

    # Código AUTO_NAO_ENCONTRADO
    li      $t0, AUTO_NAO_ENCONTRADO  # Carrega o valor imediato AUTO_NAO_ENCONTRADO no registrador $t0.
    # Se o erro for auto, desvia para exibir a mensagem
    beq     $a0, $t0, shell_erro_msg_auto  # Se $a0 e $t0 forem iguais, desvia para shell_erro_msg_auto.

    # Código TIPO_INVALIDO
    li      $t0, TIPO_INVALIDO  # Carrega o valor imediato TIPO_INVALIDO no registrador $t0.
    # Se o erro for tipo, desvia para exibir a mensagem
    beq     $a0, $t0, shell_erro_msg_tipo  # Se $a0 e $t0 forem iguais, desvia para shell_erro_msg_tipo.

    # Código LIMITE_MORADORES_ATINGIDO
    li      $t0, LIMITE_MORADORES_ATINGIDO  # Carrega o valor imediato LIMITE_MORADORES_ATINGIDO no registrador $t0.
    # Se o erro for lim_moradores, desvia para exibir a mensagem
    beq     $a0, $t0, shell_erro_msg_lim_moradores  # Se $a0 e $t0 forem iguais, desvia para shell_erro_msg_lim_moradores.

    # Código LIMITE_AUTOS_ATINGIDO
    li      $t0, LIMITE_AUTOS_ATINGIDO  # Carrega o valor imediato LIMITE_AUTOS_ATINGIDO no registrador $t0.
    # Se o erro for lim_autos, desvia para exibir a mensagem
    beq     $a0, $t0, shell_erro_msg_lim_autos  # Se $a0 e $t0 forem iguais, desvia para shell_erro_msg_lim_autos.

    # Erro genérico de comando inválido
    la      $a0, msg_cmd_invalido  # Carrega em $a0 o endereço msg_cmd_invalido para passá-lo como argumento.
    # Imprime mensagem textual via camada de I/O
    jal     shell_io_imprimir_string  # Chama a rotina shell_io_imprimir_string e salva o endereço de retorno em $ra.
    # Desvia para finalizar e restaurar registradores
    j       shell_erro_msg_retorna  # Desvia a execução incondicionalmente para shell_erro_msg_retorna.

shell_erro_msg_ap:
    la      $a0, msg_ap_invalido            # Carrega mensagem "Falha: AP invalido"
    jal     shell_io_imprimir_string        # Imprime erro via camada de I/O
    j       shell_erro_msg_retorna          # Desvia para restauração de pilha

shell_erro_msg_morador:
    la      $a0, msg_morador_nao_encontrado # Carrega mensagem "Falha: morador nao encontrado"
    jal     shell_io_imprimir_string        # Imprime erro via camada de I/O
    j       shell_erro_msg_retorna          # Desvia para restauração de pilha

shell_erro_msg_auto:
    la      $a0, msg_auto_nao_encontrado    # Carrega mensagem "Falha: automóvel nao encontrado"
    jal     shell_io_imprimir_string        # Imprime erro via camada de I/O
    j       shell_erro_msg_retorna          # Desvia para restauração de pilha

shell_erro_msg_tipo:
    la      $a0, msg_tipo_invalido          # Carrega mensagem "Falha: tipo invalido"
    jal     shell_io_imprimir_string        # Imprime erro via camada de I/O
    j       shell_erro_msg_retorna          # Desvia para restauração de pilha

shell_erro_msg_lim_moradores:
    la      $a0, msg_limite_moradores       # Carrega mensagem de limite de moradores
    jal     shell_io_imprimir_string        # Imprime erro via camada de I/O
    j       shell_erro_msg_retorna          # Desvia para restauração de pilha

shell_erro_msg_lim_autos:
    la      $a0, msg_limite_autos           # Carrega mensagem de limite de veículos
    jal     shell_io_imprimir_string        # Imprime erro via camada de I/O
    j       shell_erro_msg_retorna          # Desvia para restauração de pilha

shell_erro_msg_retorna:
    lw $ra, 4($sp)                     # Carrega palavra da posição 4($sp) para $ra.
    addiu   $sp, $sp, 8                     # Libera espaço alocado na pilha
    jr      $ra                             # Retorna ao despachante

shell_erro_msg_fim:
    jr      $ra                             # Retorna sem imprimir nada (operação OK)


# ============================================================
# CAMADA DE ABSTRAÇÃO DE I/O (DUAL-MODE: SYSCALL VS. MMIO)
# ============================================================

# ------------------------------------------------------------
# shell_io_imprimir_string()
#
# Imprime string terminada em '\0' no console ou Display MMIO
# Entrada:
#   $a0 = endereço da string na memória
# ------------------------------------------------------------

shell_io_imprimir_string:

    # Lê o estado da flag de modo MMIO
    lw      $t0, shell_modo_mmio  # Carrega palavra da posição shell_modo_mmio para $t0.

    # Se MMIO estiver ativo, desvia para a rotina de hardware
    bnez    $t0, shell_io_imp_str_mmio

    # Modo padrão MARS: serviço 4 de impressão de string
    li      $v0, 4  # Seleciona em $v0 o serviço MARS de imprimir string.

    # Executa a chamada de sistema do console padrão
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Retorna ao chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.

shell_io_imp_str_mmio:

    # Desvia diretamente para o driver de exibição MMIO
    j       mmio_imprimir_string  # Desvia a execução incondicionalmente para mmio_imprimir_string.


# ------------------------------------------------------------
# shell_io_ler_linha()
#
# Lê uma linha de texto do teclado padrão ou Keyboard MMIO
# Entrada:
#   $a0 = endereço de destino do buffer
#   $a1 = tamanho máximo do buffer (bytes)
# ------------------------------------------------------------

shell_io_ler_linha:

    # Lê o estado da flag de modo MMIO
    lw      $t0, shell_modo_mmio  # Carrega palavra da posição shell_modo_mmio para $t0.

    # Se MMIO estiver ativo, desvia para a rotina de hardware
    bnez    $t0, shell_io_ler_linha_mmio

    # Modo padrão MARS: serviço 8 de leitura de string
    li      $v0, 8  # Seleciona em $v0 o serviço MARS de ler string.

    # Executa a chamada de sistema do console padrão
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Retorna ao chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.

shell_io_ler_linha_mmio:

    # Desvia diretamente para o driver de leitura do teclado MMIO
    j       mmio_ler_linha  # Desvia a execução incondicionalmente para mmio_ler_linha.


# ------------------------------------------------------------
# shell_io_imprimir_int()
#
# Imprime um número inteiro decimal no console ou Display MMIO
# Entrada:
#   $a0 = valor inteiro a exibir
# ------------------------------------------------------------

shell_io_imprimir_int:

    # Lê o estado da flag de modo MMIO
    lw      $t0, shell_modo_mmio  # Carrega palavra da posição shell_modo_mmio para $t0.

    # Se MMIO estiver ativo, desvia para a rotina de hardware
    bnez    $t0, shell_io_imp_int_mmio

    # Modo padrão MARS: serviço 1 de impressão de inteiro
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.

    # Executa a chamada de sistema do console padrão
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Retorna ao chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.

shell_io_imp_int_mmio:

    # Desvia diretamente para o conversor e driver MMIO
    j       mmio_imprimir_int  # Desvia a execução incondicionalmente para mmio_imprimir_int.


# ------------------------------------------------------------
# shell_io_imprimir_char()
#
# Imprime um único caractere ASCII no console ou Display MMIO
# Entrada:
#   $a0 = caractere ASCII
# ------------------------------------------------------------

shell_io_imprimir_char:

    # Lê o estado da flag de modo MMIO
    lw      $t0, shell_modo_mmio  # Carrega palavra da posição shell_modo_mmio para $t0.

    # Se MMIO estiver ativo, desvia para a rotina de hardware
    bnez    $t0, shell_io_imp_char_mmio

    # Modo padrão MARS: serviço 11 de impressão de caractere
    li      $v0, 11  # Seleciona em $v0 o serviço MARS de imprimir caractere.

    # Executa a chamada de sistema do console padrão
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.

    # Retorna ao chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.

shell_io_imp_char_mmio:

    # Desvia diretamente para o driver de envio de caractere MMIO
    j       mmio_escrever_char  # Desvia a execução incondicionalmente para mmio_escrever_char.