# ============================================================
# Grupo: Pessoa 1, Pessoa 2 e Pessoa 3
# Atividade: 1VA
# Disciplina: Arquitetura e Organização de Computadores
# Semestre: 2026.2
# Arquivo: main.asm
# Descrição: ponto de entrada, inicialização dos módulos,
#            execução do terminal e encerramento do sistema
# ============================================================


# Inclui as constantes e os contratos compartilhados
.include "contratos.asm"


# Seleciona a seção de instruções
.text

# Declara main como símbolo global do programa
.globl main

# Garante o salto para main quando o MARS iniciar no primeiro endereço
j       main


# ------------------------------------------------------------
# INCLUSÃO DOS MÓDULOS
# ------------------------------------------------------------

# Inclui a tabela de apartamentos e suas rotinas
.include "dados.asm"

# Inclui os comandos de cadastro de moradores e veículos
.include "comandos_cadastro.asm"

# Inclui as rotinas de consulta e busca
.include "comandos_consulta.asm"

# Inclui as operações de leitura e gravação em arquivo
.include "persistencia.asm"

# Inclui o menu e a comunicação com o usuário
.include "shell.asm"


# ------------------------------------------------------------
# main()
#
# Inicializa o estado do sistema, tenta carregar os dados,
# executa o terminal, salva as alterações e encerra o programa
# ------------------------------------------------------------

main:

    # Reserva espaço para salvar o endereço de retorno
    addiu   $sp, $sp, -4

    # Salva o endereço de retorno da rotina principal
    sw      $ra, 0($sp)

    # Inicializa os 24 blocos de apartamentos
    jal     dados_inicializar

    # Inicializa o descritor da persistência
    jal     persist_inicializar

    # Tenta carregar o estado salvo no arquivo
    jal     persist_carregar

    # Continua normalmente quando o carregamento foi bem sucedido
    beq     $v0, $zero, main_inicializar_shell

    # Se o arquivo não existir ou estiver inválido, começa com memória limpa
    jal     dados_inicializar


main_inicializar_shell:

    # Exibe a apresentação inicial do sistema
    jal     shell_inicializar

    # Executa o menu até o usuário escolher sair
    jal     shell_executar

    # Salva em disco o estado atualizado durante a execução
    jal     persist_salvar

    # Fecha qualquer recurso restante da persistência
    jal     persist_encerrar

    # Restaura o endereço de retorno salvo no início
    lw      $ra, 0($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 4

    # Seleciona a chamada de sistema de encerramento
    li      $v0, 10

    # Encerra o programa de forma limpa
    syscall