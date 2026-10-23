# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Erik Vinicius Gomes de Lima
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores (UFRPE - 2026.2)
# Professor: Prof. Vítor A Coutinho
# Arquivo: main.asm
# Descrição: ponto de entrada, bootstrap do sistema, inicializacao e encerramento
# ============================================================
# Inclui as constantes e os contratos compartilhados
.include "contratos.asm"  # Inclui o módulo/arquivo "contratos.asm" nesta montagem.


# Seleciona a seção de instruções
.text  # Seleciona a seção de instruções executáveis.

# Declara main como símbolo global do programa
.globl main  # Exporta main para uso como símbolo global.

# Garante o salto para main quando o MARS iniciar no primeiro endereço
j       main  # Desvia a execução incondicionalmente para main.


# ------------------------------------------------------------
# INCLUSÃO DOS MÓDULOS
# ------------------------------------------------------------

# Inclui a tabela de apartamentos e suas rotinas
.include "dados.asm"  # Inclui o módulo/arquivo "dados.asm" nesta montagem.

# Inclui os comandos de cadastro de moradores e veículos
.include "comandos_cadastro.asm"  # Inclui o módulo/arquivo "comandos_cadastro.asm" nesta montagem.

# Inclui as rotinas de consulta e busca
.include "comandos_consulta.asm"  # Inclui o módulo/arquivo "comandos_consulta.asm" nesta montagem.

# Inclui as operações de leitura e gravação em arquivo
.include "persistencia.asm"  # Inclui o módulo/arquivo "persistencia.asm" nesta montagem.

# Inclui o driver de hardware de Keyboard e Display MMIO
.include "mmio.asm"  # Inclui o módulo/arquivo "mmio.asm" nesta montagem.

# Inclui o menu e a comunicação com o usuário
.include "shell.asm"  # Inclui o módulo/arquivo "shell.asm" nesta montagem.



# ------------------------------------------------------------
# main()
#
# Inicializa o estado do sistema, tenta carregar os dados,
# executa o terminal, salva as alterações e encerra o programa
# ------------------------------------------------------------

main:

    # Garante alinhamento inicial da pilha em 8 bytes no MARS (que inicia em 0x7fffeffc)
    li      $t0, -8  # Carrega o valor imediato -8 no registrador $t0.
    and     $sp, $sp, $t0  # Aplica a operação lógica AND entre $sp e $t0, gravando o resultado em $sp.

    # Reserva espaço para salvar o endereço de retorno (alinhado em 8 bytes)
    addiu   $sp, $sp, -8  # Reserva espaço de pilha ajustando $sp em -8 bytes.

    # Salva o endereço de retorno da rotina principal
    sw $ra, 4($sp)  # Armazena palavra de $ra na posição de memória 4($sp).

    # Inicializa os 24 blocos de apartamentos
    jal     dados_inicializar  # Chama a rotina dados_inicializar e salva o endereço de retorno em $ra.

    # Inicializa o descritor da persistência
    jal     persist_inicializar  # Chama a rotina persist_inicializar e salva o endereço de retorno em $ra.

    # Tenta carregar o estado salvo no arquivo
    jal     persist_carregar  # Chama a rotina persist_carregar e salva o endereço de retorno em $ra.

    # Continua normalmente quando o carregamento foi bem sucedido
    beq     $v0, $zero, main_inicializar_shell  # Se $v0 e $zero forem iguais, desvia para main_inicializar_shell.

    # Se o arquivo não existir ou estiver inválido, começa com memória limpa
    jal     dados_inicializar  # Chama a rotina dados_inicializar e salva o endereço de retorno em $ra.


main_inicializar_shell:

    # Exibe a apresentação inicial do sistema
    jal     shell_inicializar  # Chama a rotina shell_inicializar e salva o endereço de retorno em $ra.

    # Executa o loop do terminal até o encerramento
    jal     shell_executar  # Chama a rotina shell_executar e salva o endereço de retorno em $ra.

    # Fecha qualquer recurso restante da persistência
    jal     persist_encerrar  # Chama a rotina persist_encerrar e salva o endereço de retorno em $ra.

    # Restaura o endereço de retorno salvo no início
    lw $ra, 4($sp)  # Carrega palavra da posição 4($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 8  # Libera espaço de pilha ajustando $sp em 8 bytes.

    # Seleciona a chamada de sistema de encerramento
    li      $v0, 10  # Seleciona em $v0 o serviço MARS de encerrar o programa.

    # Encerra o programa de forma limpa
    syscall  # Executa o serviço MARS selecionado em $v0 usando os argumentos configurados.