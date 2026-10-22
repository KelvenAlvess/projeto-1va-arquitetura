# Descrição: menu principal, leitura de entradas e comunicação
#            entre o usuário e os módulos do sistema



# ------------------------------------------------------------
# ÁREA DE DADOS DO MÓDULO
# ------------------------------------------------------------

.data

# Mensagem exibida ao iniciar o sistema
texto_abertura: .asciiz "\n=== Sistema do Condominio MIPS ===\n"

# Menu principal apresentado ao usuário
texto_menu: .asciiz "\nEscolha uma opcao\n1 - Listar apartamentos\n2 - Listar moradores\n3 - Listar automoveis\n4 - Buscar morador\n5 - Buscar automovel\n6 - Adicionar morador\n7 - Remover morador\n8 - Adicionar automovel\n9 - Remover automovel\n0 - Sair\nOpcao: "

# Mensagem exibida quando o usuário encerra o sistema
texto_encerramento: .asciiz "\nSistema encerrado\n"

# Mensagem usada para opções inexistentes
texto_opcao_invalida: .asciiz "Opcao invalida\n"

# Mensagem usada antes da leitura de um apartamento
texto_pergunta_apartamento: .asciiz "Numero do apartamento: "

# Mensagem usada antes da leitura do nome
texto_pergunta_nome: .asciiz "Nome do morador: "

# Mensagem usada antes da leitura do tipo de automóvel
texto_pergunta_tipo: .asciiz "Tipo do automovel\n1 - Carro\n2 - Moto\nTipo: "

# Mensagem usada antes da leitura do modelo
texto_pergunta_modelo: .asciiz "Modelo do automovel: "

# Mensagem usada antes da leitura da placa
texto_pergunta_placa: .asciiz "Placa do automovel: "

# Mensagem exibida quando uma busca encontra um apartamento
texto_ap_encontrado: .asciiz "Apartamento encontrado: "

# Mensagem exibida após uma operação bem sucedida
texto_operacao_ok: .asciiz "Operacao concluida\n"

# Mensagem genérica para falhas não classificadas
texto_erro_generico: .asciiz "Nao foi possivel concluir a operacao\n"

# Mensagem para apartamento inválido
texto_erro_ap: .asciiz "Apartamento invalido\n"

# Mensagem para morador não encontrado
texto_erro_morador: .asciiz "Morador nao encontrado\n"

# Mensagem para automóvel não encontrado
texto_erro_auto: .asciiz "Automovel nao encontrado\n"

# Mensagem para tipo inválido
texto_erro_tipo: .asciiz "Tipo de automovel invalido\n"

# Mensagem para limite de moradores
texto_erro_limite_moradores: .asciiz "Limite de moradores atingido\n"

# Mensagem para limite de automóveis
texto_erro_limite_autos: .asciiz "Limite de automoveis atingido\n"

# Mensagem para entrada inválida
texto_erro_entrada: .asciiz "Entrada invalida\n"

# Buffer usado para nomes de moradores
shell_buffer_nome: .space TAM_NOME

# Buffer usado para modelos de automóveis
shell_buffer_modelo: .space TAM_MODELO

# Buffer usado para placas de automóveis
shell_buffer_placa: .space TAM_PLACA


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
# Exibe a apresentação inicial do sistema
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

shell_inicializar:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem inicial
    la      $a0, texto_abertura

    # Exibe a mensagem inicial no terminal
    syscall

    # Retorna o código de sucesso
    li      $v0, OK

    # Retorna ao módulo principal
    jr      $ra


# ------------------------------------------------------------
# shell_executar()
#
# Mantém o menu em execução até o usuário escolher sair
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

shell_executar:

    # Reserva espaço para salvar o endereço de retorno
    addiu   $sp, $sp, -4

    # Salva o endereço de retorno da rotina
    sw      $ra, 0($sp)


shell_loop:

    # Exibe o menu principal
    jal     shell_exibir_menu

    # Seleciona o serviço de leitura de inteiro
    li      $v0, 5

    # Lê a opção digitada pelo usuário
    syscall

    # Guarda a opção em um registrador temporário
    move    $t0, $v0

    # A opção zero encerra o menu
    beq     $t0, $zero, shell_sair

    # Compara a opção com o comando de listagem de apartamentos
    li      $t1, 1
    beq     $t0, $t1, shell_opcao_listar_apartamentos

    # Compara a opção com o comando de listagem de moradores
    li      $t1, 2
    beq     $t0, $t1, shell_opcao_listar_moradores

    # Compara a opção com o comando de listagem de automóveis
    li      $t1, 3
    beq     $t0, $t1, shell_opcao_listar_automoveis

    # Compara a opção com o comando de busca de morador
    li      $t1, 4
    beq     $t0, $t1, shell_opcao_buscar_morador

    # Compara a opção com o comando de busca de automóvel
    li      $t1, 5
    beq     $t0, $t1, shell_opcao_buscar_auto

    # Compara a opção com o comando de cadastro de morador
    li      $t1, 6
    beq     $t0, $t1, shell_opcao_adicionar_morador

    # Compara a opção com o comando de remoção de morador
    li      $t1, 7
    beq     $t0, $t1, shell_opcao_remover_morador

    # Compara a opção com o comando de cadastro de automóvel
    li      $t1, 8
    beq     $t0, $t1, shell_opcao_adicionar_auto

    # Compara a opção com o comando de remoção de automóvel
    li      $t1, 9
    beq     $t0, $t1, shell_opcao_remover_auto

    # Qualquer outro número é considerado inválido
    j       shell_opcao_invalida


shell_opcao_listar_apartamentos:

    # Lista todos os apartamentos
    jal     consulta_listar_apartamentos

    # Exibe o resultado da operação
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_listar_moradores:

    # Solicita o número do apartamento
    jal     shell_ler_apartamento

    # Guarda o apartamento informado
    move    $a0, $v0

    # Lista os moradores do apartamento
    jal     consulta_listar_moradores

    # Exibe o resultado da consulta
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_listar_automoveis:

    # Solicita o número do apartamento
    jal     shell_ler_apartamento

    # Guarda o apartamento informado
    move    $a0, $v0

    # Lista os automóveis do apartamento
    jal     consulta_listar_automoveis

    # Exibe o resultado da consulta
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_buscar_morador:

    # Lê o nome que será pesquisado
    jal     shell_ler_nome

    # Passa o endereço do nome para a consulta
    move    $a0, $v0

    # Procura o morador em todos os apartamentos
    jal     consulta_buscar_morador

    # Guarda o apartamento retornado pela consulta
    move    $t0, $v1

    # Continua para a mensagem de erro quando a busca falhar
    bne     $v0, $zero, shell_busca_morador_erro

    # Exibe o texto que antecede o resultado
    li      $v0, 4
    la      $a0, texto_ap_encontrado
    syscall

    # Exibe o número do apartamento encontrado
    li      $v0, 1
    move    $a0, $t0
    syscall

    # Exibe uma quebra de linha
    li      $v0, 4
    la      $a0, texto_quebra
    syscall

    # Retorna ao menu
    j       shell_loop


shell_busca_morador_erro:

    # Exibe o código de erro da busca
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_buscar_auto:

    # Lê a placa que será pesquisada
    jal     shell_ler_placa

    # Passa o endereço da placa para a consulta
    move    $a0, $v0

    # Procura a placa em todos os apartamentos
    jal     consulta_buscar_auto

    # Guarda o apartamento retornado pela consulta
    move    $t0, $v1

    # Continua para a mensagem de erro quando a busca falhar
    bne     $v0, $zero, shell_busca_auto_erro

    # Exibe o texto que antecede o resultado
    li      $v0, 4
    la      $a0, texto_ap_encontrado
    syscall

    # Exibe o número do apartamento encontrado
    li      $v0, 1
    move    $a0, $t0
    syscall

    # Exibe uma quebra de linha
    li      $v0, 4
    la      $a0, texto_quebra
    syscall

    # Retorna ao menu
    j       shell_loop


shell_busca_auto_erro:

    # Exibe o código de erro da busca
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_adicionar_morador:

    # Lê o apartamento do novo morador
    jal     shell_ler_apartamento

    # Guarda o número do apartamento na pilha
    addiu   $sp, $sp, -4
    sw      $v0, 0($sp)

    # Lê o nome do novo morador
    jal     shell_ler_nome

    # Move o endereço do nome para $a1
    move    $a1, $v0

    # Recupera o número do apartamento
    lw      $a0, 0($sp)

    # Libera o espaço temporário usado na pilha
    addiu   $sp, $sp, 4

    # Cadastra o novo morador
    jal     cadastro_adicionar_morador

    # Exibe o resultado do cadastro
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_remover_morador:

    # Lê o apartamento do morador que será removido
    jal     shell_ler_apartamento

    # Guarda o número do apartamento na pilha
    addiu   $sp, $sp, -4
    sw      $v0, 0($sp)

    # Lê o nome do morador
    jal     shell_ler_nome

    # Move o endereço do nome para $a1
    move    $a1, $v0

    # Recupera o número do apartamento
    lw      $a0, 0($sp)

    # Libera o espaço temporário usado na pilha
    addiu   $sp, $sp, 4

    # Remove o morador do apartamento
    jal     cadastro_remover_morador

    # Exibe o resultado da remoção
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_adicionar_auto:

    # Lê o apartamento do veículo
    jal     shell_ler_apartamento

    # Guarda o apartamento na pilha
    addiu   $sp, $sp, -4
    sw      $v0, 0($sp)

    # Lê o tipo do veículo
    jal     shell_ler_tipo

    # Guarda o tipo na pilha
    addiu   $sp, $sp, -4
    sw      $v0, 0($sp)

    # Lê o modelo do veículo
    jal     shell_ler_modelo

    # Guarda o endereço do modelo na pilha
    addiu   $sp, $sp, -4
    sw      $v0, 0($sp)

    # Lê a placa do veículo
    jal     shell_ler_placa

    # Guarda o endereço da placa em $a3
    move    $a3, $v0

    # Recupera o endereço do modelo em $a2
    lw      $a2, 0($sp)

    # Remove o endereço do modelo da pilha
    addiu   $sp, $sp, 4

    # Recupera o tipo em $a1
    lw      $a1, 0($sp)

    # Remove o tipo da pilha
    addiu   $sp, $sp, 4

    # Recupera o apartamento em $a0
    lw      $a0, 0($sp)

    # Remove o apartamento da pilha
    addiu   $sp, $sp, 4

    # Cadastra o veículo
    jal     cadastro_adicionar_auto

    # Exibe o resultado do cadastro
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_remover_auto:

    # Lê o apartamento do veículo
    jal     shell_ler_apartamento

    # Guarda o apartamento temporariamente
    addiu   $sp, $sp, -4
    sw      $v0, 0($sp)

    # Lê a placa do veículo
    jal     shell_ler_placa

    # Move o endereço da placa para $a1
    move    $a1, $v0

    # Recupera o apartamento em $a0
    lw      $a0, 0($sp)

    # Libera o espaço temporário da pilha
    addiu   $sp, $sp, 4

    # Remove o veículo cadastrado
    jal     cadastro_remover_auto

    # Exibe o resultado da remoção
    move    $a0, $v0
    jal     shell_exibir_status

    # Retorna ao menu
    j       shell_loop


shell_opcao_invalida:

    # Exibe o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de opção inválida
    la      $a0, texto_opcao_invalida

    # Exibe a mensagem
    syscall

    # Volta ao menu principal
    j       shell_loop


shell_sair:

    # Executa a mensagem de encerramento
    jal     shell_encerrar

    # Define o retorno de sucesso
    li      $v0, OK

    # Restaura o endereço de retorno de shell_executar
    lw      $ra, 0($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 4

    # Retorna ao módulo principal
    jr      $ra


# ------------------------------------------------------------
# shell_encerrar()
#
# Exibe a mensagem final do sistema
#
# Retorno:
#   $v0 = OK
# ------------------------------------------------------------

shell_encerrar:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de encerramento
    la      $a0, texto_encerramento

    # Exibe a mensagem final
    syscall

    # Retorna sucesso
    li      $v0, OK

    # Retorna ao módulo chamador
    jr      $ra


# ------------------------------------------------------------
# shell_exibir_menu()
#
# Exibe o menu principal do sistema
# ------------------------------------------------------------

shell_exibir_menu:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega o menu principal
    la      $a0, texto_menu

    # Exibe o menu
    syscall

    # Retorna ao loop principal
    jr      $ra


# ------------------------------------------------------------
# shell_ler_apartamento()
#
# Lê um número de apartamento
#
# Saída:
#   $v0 = número informado
# ------------------------------------------------------------

shell_ler_apartamento:

    # Exibe o texto da pergunta
    li      $v0, 4
    la      $a0, texto_pergunta_apartamento
    syscall

    # Seleciona o serviço de leitura de inteiro
    li      $v0, 5

    # Lê o número informado
    syscall

    # Retorna mantendo o número em $v0
    jr      $ra


# ------------------------------------------------------------
# shell_ler_nome()
#
# Lê e prepara um nome de morador
#
# Saída:
#   $v0 = endereço do buffer do nome
# ------------------------------------------------------------

shell_ler_nome:

    # Reserva espaço para salvar o retorno da rotina
    addiu   $sp, $sp, -4

    # Salva o retorno recebido do módulo chamador
    sw      $ra, 0($sp)

    # Exibe a pergunta do nome
    li      $v0, 4
    la      $a0, texto_pergunta_nome
    syscall

    # Carrega o endereço do buffer
    la      $a0, shell_buffer_nome

    # Informa o tamanho máximo do buffer
    li      $a1, TAM_NOME

    # Seleciona a leitura de string
    li      $v0, 8
    syscall

    # Remove a quebra de linha do texto lido
    la      $a0, shell_buffer_nome
    jal     shell_remover_quebra

    # Retorna o endereço do buffer em $v0
    la      $v0, shell_buffer_nome

    # Restaura o retorno original
    lw      $ra, 0($sp)

    # Libera o espaço da pilha
    addiu   $sp, $sp, 4

    # Volta para a rotina chamadora
    jr      $ra


# ------------------------------------------------------------
# shell_ler_tipo()
#
# Lê o tipo do automóvel
#
# Saída:
#   $v0 = código do tipo
# ------------------------------------------------------------

shell_ler_tipo:

    # Exibe o texto da pergunta
    li      $v0, 4
    la      $a0, texto_pergunta_tipo
    syscall

    # Seleciona o serviço de leitura de inteiro
    li      $v0, 5

    # Lê o tipo informado
    syscall

    # Retorna o tipo em $v0
    jr      $ra


# ------------------------------------------------------------
# shell_ler_modelo()
#
# Lê e prepara o modelo do automóvel
#
# Saída:
#   $v0 = endereço do buffer do modelo
# ------------------------------------------------------------

shell_ler_modelo:

    # Reserva espaço para salvar o retorno da rotina
    addiu   $sp, $sp, -4

    # Salva o retorno recebido do módulo chamador
    sw      $ra, 0($sp)

    # Exibe a pergunta do modelo
    li      $v0, 4
    la      $a0, texto_pergunta_modelo
    syscall

    # Carrega o endereço do buffer
    la      $a0, shell_buffer_modelo

    # Informa o tamanho máximo do buffer
    li      $a1, TAM_MODELO

    # Seleciona a leitura de string
    li      $v0, 8
    syscall

    # Remove a quebra de linha do texto lido
    la      $a0, shell_buffer_modelo
    jal     shell_remover_quebra

    # Retorna o endereço do buffer em $v0
    la      $v0, shell_buffer_modelo

    # Restaura o retorno original
    lw      $ra, 0($sp)

    # Libera o espaço da pilha
    addiu   $sp, $sp, 4

    # Volta para a rotina chamadora
    jr      $ra


# ------------------------------------------------------------
# shell_ler_placa()
#
# Lê e prepara a placa do automóvel
#
# Saída:
#   $v0 = endereço do buffer da placa
# ------------------------------------------------------------

shell_ler_placa:

    # Reserva espaço para salvar o retorno da rotina
    addiu   $sp, $sp, -4

    # Salva o retorno recebido do módulo chamador
    sw      $ra, 0($sp)

    # Exibe a pergunta da placa
    li      $v0, 4
    la      $a0, texto_pergunta_placa
    syscall

    # Carrega o endereço do buffer
    la      $a0, shell_buffer_placa

    # Informa o tamanho máximo do buffer
    li      $a1, TAM_PLACA

    # Seleciona a leitura de string
    li      $v0, 8
    syscall

    # Remove a quebra de linha do texto lido
    la      $a0, shell_buffer_placa
    jal     shell_remover_quebra

    # Retorna o endereço do buffer em $v0
    la      $v0, shell_buffer_placa

    # Restaura o retorno original
    lw      $ra, 0($sp)

    # Libera o espaço da pilha
    addiu   $sp, $sp, 4

    # Volta para a rotina chamadora
    jr      $ra


# ------------------------------------------------------------
# shell_remover_quebra()
#
# Substitui o caractere de nova linha por '\0'
#
# Entrada:
#   $a0 = endereço do buffer
# ------------------------------------------------------------

shell_remover_quebra:

    # Copia o endereço inicial para o registrador de percurso
    move    $t0, $a0


shell_remover_quebra_loop:

    # Lê o byte atual do buffer
    lbu     $t1, 0($t0)

    # Encerra quando alcançar o terminador da string
    beq     $t1, $zero, shell_remover_quebra_finalizar

    # Carrega o código ASCII da quebra de linha
    li      $t2, 10

    # Substitui a quebra de linha por terminador
    beq     $t1, $t2, shell_substituir_quebra

    # Avança para o próximo byte
    addiu   $t0, $t0, 1

    # Continua percorrendo o buffer
    j       shell_remover_quebra_loop


shell_substituir_quebra:

    # Substitui a quebra de linha por zero
    sb      $zero, 0($t0)


shell_remover_quebra_finalizar:

    # Retorna ao módulo chamador
    jr      $ra


# ------------------------------------------------------------
# shell_exibir_status()
#
# Entrada:
#   $a0 = código de retorno da operação
# ------------------------------------------------------------

shell_exibir_status:

    # Copia o status para um registrador temporário
    move    $t0, $a0

    # O código zero representa sucesso
    beq     $t0, $zero, shell_status_ok

    # Carrega o código de apartamento inválido
    li      $t1, AP_INVALIDO

    # Verifica se o status indica apartamento inválido
    beq     $t0, $t1, shell_status_ap_invalido

    # Carrega o código de morador não encontrado
    li      $t1, MORADOR_NAO_ENCONTRADO

    # Verifica se o status indica morador ausente
    beq     $t0, $t1, shell_status_morador

    # Carrega o código de automóvel não encontrado
    li      $t1, AUTO_NAO_ENCONTRADO

    # Verifica se o status indica automóvel ausente
    beq     $t0, $t1, shell_status_auto

    # Carrega o código de tipo inválido
    li      $t1, TIPO_INVALIDO

    # Verifica se o status indica tipo inválido
    beq     $t0, $t1, shell_status_tipo

    # Carrega o código de limite de moradores
    li      $t1, LIMITE_MORADORES_ATINGIDO

    # Verifica se o limite de moradores foi atingido
    beq     $t0, $t1, shell_status_limite_moradores

    # Carrega o código de limite de automóveis
    li      $t1, LIMITE_AUTOS_ATINGIDO

    # Verifica se o limite de veículos foi atingido
    beq     $t0, $t1, shell_status_limite_autos

    # Carrega o código de entrada inválida
    li      $t1, ENTRADA_INVALIDA

    # Verifica se a entrada foi considerada inválida
    beq     $t0, $t1, shell_status_entrada

    # Usa a mensagem genérica para códigos desconhecidos
    j       shell_status_generico


shell_status_ok:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de sucesso
    la      $a0, texto_operacao_ok

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_ap_invalido:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de apartamento inválido
    la      $a0, texto_erro_ap

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_morador:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de morador não encontrado
    la      $a0, texto_erro_morador

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_auto:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de automóvel não encontrado
    la      $a0, texto_erro_auto

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_tipo:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de tipo inválido
    la      $a0, texto_erro_tipo

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_limite_moradores:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de limite de moradores
    la      $a0, texto_erro_limite_moradores

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_limite_autos:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de limite de automóveis
    la      $a0, texto_erro_limite_autos

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_entrada:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem de entrada inválida
    la      $a0, texto_erro_entrada

    # Exibe a mensagem
    syscall

    # Retorna ao chamador
    jr      $ra


shell_status_generico:

    # Seleciona o serviço de impressão de string
    li      $v0, 4

    # Carrega a mensagem genérica de erro
    la      $a0, texto_erro_generico

    # Exibe a mensagem
    syscall

    # Retorna ao módulo chamador
    jr      $ra