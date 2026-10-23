# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Integrante 3
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

# Inclui o driver de hardware de Keyboard e Display MMIO
.include "mmio.asm"

# Inclui o menu e a comunicação com o usuário
.include "shell.asm"



# ------------------------------------------------------------
# main()
#
# Inicializa o estado do sistema, tenta carregar os dados,
# executa o terminal, salva as alterações e encerra o programa
# ------------------------------------------------------------

main:

    # Garante alinhamento inicial da pilha em 8 bytes no MARS (que inicia em 0x7fffeffc)
    li      $t0, -8
    and     $sp, $sp, $t0

    # Reserva espaço para salvar o endereço de retorno (alinhado em 8 bytes)
    addiu   $sp, $sp, -8

    # Salva o endereço de retorno da rotina principal
    sw      $ra, 4($sp)

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

    # Executa o loop do terminal até o encerramento
    jal     shell_executar

    # Fecha qualquer recurso restante da persistência
    jal     persist_encerrar

    # Restaura o endereço de retorno salvo no início
    lw      $ra, 4($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 8

    # Seleciona a chamada de sistema de encerramento
    li      $v0, 10

    # Encerra o programa de forma limpa
    syscall