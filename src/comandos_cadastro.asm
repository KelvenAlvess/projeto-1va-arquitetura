# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Erik Vinicius Gomes de Lima
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores (UFRPE - 2026.2)
# Professor: Prof. Vítor A Coutinho
# Arquivo: comandos_cadastro.asm
# Descrição: regras de negocio de cadastro e remocao de moradores, veiculos e cascata compulsoria
# ============================================================
.globl cadastro_adicionar_morador  # Exporta cadastro_adicionar_morador para uso como símbolo global.
.globl cadastro_remover_morador  # Exporta cadastro_remover_morador para uso como símbolo global.
.globl cadastro_adicionar_auto  # Exporta cadastro_adicionar_auto para uso como símbolo global.
.globl cadastro_remover_auto  # Exporta cadastro_remover_auto para uso como símbolo global.
.globl cadastro_limpar_ap  # Exporta cadastro_limpar_ap para uso como símbolo global.



# Seleciona a seção de instruções
.text  # Seleciona a seção de instruções executáveis.


# ------------------------------------------------------------
# cadastro_adicionar_morador()
#
# Entrada:
#   $a0 = número do apartamento
#   $a1 = endereço do nome do morador
#
# Retorno:
#   $v0 = OK, AP_INVALIDO ou LIMITE_MORADORES_ATINGIDO
# ------------------------------------------------------------

cadastro_adicionar_morador:

    # Reserva espaço para o endereço de retorno e os registradores salvos (24 bytes, múltiplo de 8)
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno antes de chamar outra função
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva os registradores preservados utilizados nesta rotina
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Guarda o endereço do nome para utilizá-lo depois da busca
    move    $s1, $a1  # Copia o valor de $a1 para $s1.

    # Procura o bloco correspondente ao apartamento informado
    jal     dados_obter_ap  # Chama a rotina dados_obter_ap e salva o endereço de retorno em $ra.

    # Se o apartamento não existe, encerra com o erro retornado
    bne     $v0, OK, cadastro_adicionar_morador_finalizar  # Se $v0 e OK forem diferentes, desvia para cadastro_adicionar_morador_finalizar.

    # Guarda o endereço do bloco localizado
    move    $s0, $v1  # Copia o valor de $v1 para $s0.

    # Lê a quantidade atual de moradores do apartamento
    lw $s2, OFFSET_AP_QTD_MORADORES($s0)  # Carrega palavra da posição OFFSET_AP_QTD_MORADORES($s0) para $s2.

    # Compara a quantidade atual com o limite permitido
    li      $t0, LIMITE_MORADORES  # Carrega o valor imediato LIMITE_MORADORES no registrador $t0.
    bge     $s2, $t0, cadastro_limite_moradores  # Se $s2 e $t0 forem maior ou igual a, desvia para cadastro_limite_moradores.

    # Carrega o tamanho de um registro de morador
    li      $t0, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $t0.

    # Calcula o deslocamento do próximo registro disponível
    mul     $t1, $s2, $t0  # Multiplica $s2 por $t0 e grava o produto em $t1.

    # Começa no início da área de moradores do apartamento
    addiu   $t2, $s0, OFFSET_AP_MORADORES  # Soma $s0 e OFFSET_AP_MORADORES, gravando o resultado em $t2.

    # Soma o deslocamento e encontra o destino do novo nome
    addu    $t2, $t2, $t1  # Soma $t2 e $t1, gravando o resultado em $t2.

    # Passa o endereço de destino para a rotina de cópia
    move    $a0, $t2  # Copia o valor de $t2 para $a0.

    # Passa o endereço do nome recebido para a rotina de cópia
    move    $a1, $s1  # Copia o valor de $s1 para $a1.

    # Informa que o campo possui espaço para TAM_NOME bytes
    li      $a2, TAM_NOME  # Carrega o valor imediato TAM_NOME no registrador $a2.

    # Copia o nome para o bloco do apartamento
    jal     cadastro_copiar_string  # Chama a rotina cadastro_copiar_string e salva o endereço de retorno em $ra.

    # Atualiza a quantidade de moradores cadastrados
    addiu   $s2, $s2, 1  # Soma $s2 e 1, gravando o resultado em $s2.

    # Salva a nova quantidade no cabeçalho do apartamento
    sw $s2, OFFSET_AP_QTD_MORADORES($s0)  # Armazena palavra de $s2 na posição de memória OFFSET_AP_QTD_MORADORES($s0).

    # Informa que o cadastro foi concluído
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Encerra a rotina de cadastro.
    j       cadastro_adicionar_morador_finalizar  # Desvia a execução incondicionalmente para cadastro_adicionar_morador_finalizar.


cadastro_limite_moradores:

    # Informa que não há espaço para outro morador
    li      $v0, LIMITE_MORADORES_ATINGIDO  # Carrega o valor imediato LIMITE_MORADORES_ATINGIDO no registrador $v0.


cadastro_adicionar_morador_finalizar:

    # Restaura os registradores preservados pela rotina
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno original
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_remover_morador()
#
# Entrada:
#   $a0 = número do apartamento
#   $a1 = endereço do nome procurado
#
# Retorno:
#   $v0 = OK, AP_INVALIDO ou MORADOR_NAO_ENCONTRADO
# ------------------------------------------------------------

cadastro_remover_morador:

    # Reserva espaço para o endereço de retorno e os registradores salvos (24 bytes, múltiplo de 8)
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno da rotina
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva os registradores preservados que serão utilizados
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Guarda o endereço do nome que será pesquisado
    move    $s1, $a1  # Copia o valor de $a1 para $s1.

    # Procura o bloco do apartamento informado
    jal     dados_obter_ap  # Chama a rotina dados_obter_ap e salva o endereço de retorno em $ra.

    # Encerra se o apartamento informado for inválido
    bne     $v0, OK, cadastro_remover_morador_finalizar  # Se $v0 e OK forem diferentes, desvia para cadastro_remover_morador_finalizar.

    # Guarda o endereço do bloco encontrado.
    move    $s0, $v1  # Copia o valor de $v1 para $s0.

    # Lê a quantidade atual de moradores
    lw $s2, OFFSET_AP_QTD_MORADORES($s0)  # Carrega palavra da posição OFFSET_AP_QTD_MORADORES($s0) para $s2.

    # Começa a busca pelo primeiro registro
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.


cadastro_buscar_morador:

    # Se o índice alcançar a quantidade, o nome não foi encontrado
    bge     $s3, $s2, cadastro_morador_nao_encontrado  # Se $s3 e $s2 forem maior ou igual a, desvia para cadastro_morador_nao_encontrado.

    # Carrega o tamanho de um registro de morador
    li      $t0, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $t0.

    # Calcula o deslocamento do registro atual
    mul     $t1, $s3, $t0  # Multiplica $s3 por $t0 e grava o produto em $t1.

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES  # Soma $s0 e OFFSET_AP_MORADORES, gravando o resultado em $t2.

    # Calcula o endereço do nome atual
    addu    $t2, $t2, $t1  # Soma $t2 e $t1, gravando o resultado em $t2.

    # Passa o nome armazenado para a comparação
    move    $a0, $t2  # Copia o valor de $t2 para $a0.

    # Passa o nome procurado para a comparação
    move    $a1, $s1  # Copia o valor de $s1 para $a1.

    # Informa o tamanho máximo dos nomes
    li      $a2, TAM_NOME  # Carrega o valor imediato TAM_NOME no registrador $a2.

    # Compara os dois nomes
    jal     cadastro_strings_iguais  # Chama a rotina cadastro_strings_iguais e salva o endereço de retorno em $ra.

    # Continua a busca se os nomes forem diferentes
    beq     $v0, $zero, cadastro_proximo_morador  # Se $v0 e $zero forem iguais, desvia para cadastro_proximo_morador.

    # O índice atual identifica o morador que será removido
    j       cadastro_deslocar_moradores  # Desvia a execução incondicionalmente para cadastro_deslocar_moradores.


cadastro_proximo_morador:

    # Avança para o próximo registro de morador
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua procurando dentro da área de moradores
    j       cadastro_buscar_morador  # Desvia a execução incondicionalmente para cadastro_buscar_morador.


cadastro_deslocar_moradores:

    # Verifica se existem registros depois do removido
    addiu   $t0, $s3, 1  # Soma $s3 e 1, gravando o resultado em $t0.
    bge     $t0, $s2, cadastro_limpar_ultimo_morador  # Se $t0 e $s2 forem maior ou igual a, desvia para cadastro_limpar_ultimo_morador.

    # Carrega o tamanho de cada registro de morador
    li      $t1, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $t1.

    # Calcula o deslocamento do registro que será substituído
    mul     $t2, $s3, $t1  # Multiplica $s3 por $t1 e grava o produto em $t2.

    # Calcula o deslocamento do registro seguinte
    addiu   $t3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $t3.
    mul     $t3, $t3, $t1  # Multiplica $t3 por $t1 e grava o produto em $t3.

    # Obtém o início da área de moradores
    addiu   $t4, $s0, OFFSET_AP_MORADORES  # Soma $s0 e OFFSET_AP_MORADORES, gravando o resultado em $t4.

    # Calcula o endereço do destino da cópia
    addu    $a0, $t4, $t2  # Soma $t4 e $t2, gravando o resultado em $a0.

    # Calcula o endereço do registro seguinte
    addu    $a1, $t4, $t3  # Soma $t4 e $t3, gravando o resultado em $a1.

    # Informa que será copiado um registro inteiro
    li      $a2, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $a2.

    # Move o próximo morador para a posição atual
    jal     cadastro_copiar_bytes  # Chama a rotina cadastro_copiar_bytes e salva o endereço de retorno em $ra.

    # Avança para a próxima posição que ainda precisa ser deslocada
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua deslocando os registros restantes
    j       cadastro_deslocar_moradores  # Desvia a execução incondicionalmente para cadastro_deslocar_moradores.


cadastro_limpar_ultimo_morador:

    # Calcula o índice do último morador antes da remoção
    addiu   $t0, $s2, -1  # Soma $s2 e -1, gravando o resultado em $t0.

    # Carrega o tamanho de um registro de morador
    li      $t1, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $t1.

    # Calcula o deslocamento do último registro
    mul     $t0, $t0, $t1  # Multiplica $t0 por $t1 e grava o produto em $t0.

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES  # Soma $s0 e OFFSET_AP_MORADORES, gravando o resultado em $t2.

    # Calcula o endereço do registro que será apagado
    addu    $a0, $t2, $t0  # Soma $t2 e $t0, gravando o resultado em $a0.

    # Informa o tamanho do registro que será zerado
    li      $a1, TAM_REGISTRO_MORADOR  # Carrega o valor imediato TAM_REGISTRO_MORADOR no registrador $a1.

    # Limpa o espaço que ficou sobrando no final da lista
    jal     cadastro_zerar_bytes  # Chama a rotina cadastro_zerar_bytes e salva o endereço de retorno em $ra.

    # Reduz a quantidade registrada no cabeçalho
    addiu   $s2, $s2, -1  # Soma $s2 e -1, gravando o resultado em $s2.

    # Salva a nova quantidade de moradores
    sw $s2, OFFSET_AP_QTD_MORADORES($s0)  # Armazena palavra de $s2 na posição de memória OFFSET_AP_QTD_MORADORES($s0).

    # Se ainda restarem moradores, mantém os veículos
    bgtz    $s2, cadastro_remover_morador_ok  # Se $s2 for maior que zero, desvia para cadastro_remover_morador_ok.

    # Se o apartamento ficou vazio (0 moradores), exclui todos os veículos automaticamente (R2/cmd_2)
    sw $zero, OFFSET_AP_TIPO_AUTO($s0)  # Armazena palavra de $zero na posição de memória OFFSET_AP_TIPO_AUTO($s0).
    sw $zero, OFFSET_AP_QTD_AUTOS($s0)  # Armazena palavra de $zero na posição de memória OFFSET_AP_QTD_AUTOS($s0).

    # Carrega o endereço da área reservada aos veículos
    addiu   $a0, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $a0.

    # Carrega o tamanho total da área de veículos (3 veículos x 40 bytes = 120 bytes)
    li      $a1, 120  # Carrega o valor imediato 120 no registrador $a1.

    # Zera os registros de automóveis do apartamento
    jal     cadastro_zerar_bytes  # Chama a rotina cadastro_zerar_bytes e salva o endereço de retorno em $ra.

cadastro_remover_morador_ok:

    # Informa que a remoção foi concluída
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Finaliza a rotina
    j       cadastro_remover_morador_finalizar  # Desvia a execução incondicionalmente para cadastro_remover_morador_finalizar.



cadastro_morador_nao_encontrado:

    # Informa que o nome não estava cadastrado no apartamento
    li      $v0, MORADOR_NAO_ENCONTRADO  # Carrega o valor imediato MORADOR_NAO_ENCONTRADO no registrador $v0.


cadastro_remover_morador_finalizar:

    # Restaura os registradores preservados
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno original
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço utilizado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_adicionar_auto()
#
# Entrada:
#   $a0 = número do apartamento
#   $a1 = tipo do veículo
#   $a2 = endereço do modelo
#   $a3 = endereço da placa
#
# Retorno:
#   $v0 = OK, AP_INVALIDO, TIPO_INVALIDO ou
#         LIMITE_AUTOS_ATINGIDO
# ------------------------------------------------------------

cadastro_adicionar_auto:

    # Reserva espaço para o endereço de retorno e quatro registradores salvos (24 bytes, múltiplo de 8)
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva o bloco, o tipo e os endereços dos textos recebidos
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Guarda o tipo do veículo para uso após a busca
    move    $s1, $a1  # Copia o valor de $a1 para $s1.

    # Guarda o endereço do modelo
    move    $s2, $a2  # Copia o valor de $a2 para $s2.

    # Guarda o endereço da placa
    move    $s3, $a3  # Copia o valor de $a3 para $s3.

    # Verifica se o tipo informado é carro ou moto
    beq     $s1, TIPO_AUTO_CARRO, cadastro_tipo_auto_valido  # Se $s1 e TIPO_AUTO_CARRO forem iguais, desvia para cadastro_tipo_auto_valido.
    beq     $s1, TIPO_AUTO_MOTO, cadastro_tipo_auto_valido  # Se $s1 e TIPO_AUTO_MOTO forem iguais, desvia para cadastro_tipo_auto_valido.

    # Rejeita qualquer tipo diferente de carro ou moto
    li      $v0, TIPO_INVALIDO  # Carrega o valor imediato TIPO_INVALIDO no registrador $v0.
    j       cadastro_adicionar_auto_finalizar  # Desvia a execução incondicionalmente para cadastro_adicionar_auto_finalizar.


cadastro_tipo_auto_valido:

    # Procura o bloco correspondente ao apartamento
    jal     dados_obter_ap  # Chama a rotina dados_obter_ap e salva o endereço de retorno em $ra.

    # Encerra se o apartamento não for válido
    bne     $v0, OK, cadastro_adicionar_auto_finalizar  # Se $v0 e OK forem diferentes, desvia para cadastro_adicionar_auto_finalizar.

    # Guarda o endereço do bloco localizado
    move    $s0, $v1  # Copia o valor de $v1 para $s0.

    # Lê a quantidade atual de veículos cadastrados
    lw $t0, OFFSET_AP_QTD_AUTOS($s0)  # Carrega palavra da posição OFFSET_AP_QTD_AUTOS($s0) para $t0.

    # Se já houver veículo, o tipo deve ser mantido
    beq     $t0, $zero, cadastro_primeiro_auto  # Se $t0 e $zero forem iguais, desvia para cadastro_primeiro_auto.

    # Lê o tipo que já está registrado no apartamento
    lw $t1, OFFSET_AP_TIPO_AUTO($s0)  # Carrega palavra da posição OFFSET_AP_TIPO_AUTO($s0) para $t1.

    # Não permite misturar carros e motos no mesmo apartamento
    bne     $t1, $s1, cadastro_tipo_incompativel  # Se $t1 e $s1 forem diferentes, desvia para cadastro_tipo_incompativel.


cadastro_validar_limite_auto:

    # Verifica se o veículo é um carro
    beq     $s1, TIPO_AUTO_CARRO, cadastro_validar_limite_carro  # Se $s1 e TIPO_AUTO_CARRO forem iguais, desvia para cadastro_validar_limite_carro.

    # Para motos, o limite permitido é três unidades
    li      $t1, LIMITE_MOTOS  # Carrega o valor imediato LIMITE_MOTOS no registrador $t1.
    bge     $t0, $t1, cadastro_limite_auto  # Se $t0 e $t1 forem maior ou igual a, desvia para cadastro_limite_auto.

    # Continua para o armazenamento do veículo
    j       cadastro_gravar_auto  # Desvia a execução incondicionalmente para cadastro_gravar_auto.


cadastro_validar_limite_carro:

    # Para carros, o limite permitido é uma unidade
    li      $t1, LIMITE_CARROS  # Carrega o valor imediato LIMITE_CARROS no registrador $t1.
    bge     $t0, $t1, cadastro_limite_auto  # Se $t0 e $t1 forem maior ou igual a, desvia para cadastro_limite_auto.

    # Continua para o armazenamento do veículo
    j       cadastro_gravar_auto  # Desvia a execução incondicionalmente para cadastro_gravar_auto.


cadastro_primeiro_auto:

    # Registra o tipo do primeiro veículo do apartamento
    sw $s1, OFFSET_AP_TIPO_AUTO($s0)  # Armazena palavra de $s1 na posição de memória OFFSET_AP_TIPO_AUTO($s0).

    # Continua para validar o limite correspondente ao tipo
    j       cadastro_validar_limite_auto  # Desvia a execução incondicionalmente para cadastro_validar_limite_auto.


cadastro_gravar_auto:

    # Carrega o tamanho de um registro de veículo
    li      $t1, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $t1.

    # Calcula o deslocamento do próximo registro disponível
    mul     $t2, $t0, $t1  # Multiplica $t0 por $t1 e grava o produto em $t2.

    # Obtém o início da área de veículos do apartamento
    addiu   $t3, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $t3.

    # Calcula o endereço do registro que receberá os dados
    addu    $t3, $t3, $t2  # Soma $t3 e $t2, gravando o resultado em $t3.

    # Usa o início do registro como destino do modelo
    move    $a0, $t3  # Copia o valor de $t3 para $a0.

    # Usa o endereço salvo do modelo como origem da cópia
    move    $a1, $s2  # Copia o valor de $s2 para $a1.

    # Informa o tamanho disponível para o modelo
    li      $a2, TAM_MODELO  # Carrega o valor imediato TAM_MODELO no registrador $a2.

    # Copia o modelo para o registro do veículo
    jal     cadastro_copiar_string  # Chama a rotina cadastro_copiar_string e salva o endereço de retorno em $ra.

    # Avança até a área da placa dentro do mesmo registro
    addiu   $a0, $t3, TAM_MODELO  # Soma $t3 e TAM_MODELO, gravando o resultado em $a0.

    # Usa o endereço salvo da placa como origem da cópia
    move    $a1, $s3  # Copia o valor de $s3 para $a1.

    # Informa o tamanho disponível para a placa
    li      $a2, TAM_PLACA  # Carrega o valor imediato TAM_PLACA no registrador $a2.

    # Copia a placa para o registro do veículo
    jal     cadastro_copiar_string  # Chama a rotina cadastro_copiar_string e salva o endereço de retorno em $ra.

    # Lê novamente a quantidade atual de veículos
    lw $t0, OFFSET_AP_QTD_AUTOS($s0)  # Carrega palavra da posição OFFSET_AP_QTD_AUTOS($s0) para $t0.

    # Incrementa a quantidade após o novo cadastro
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.

    # Salva a nova quantidade no cabeçalho
    sw $t0, OFFSET_AP_QTD_AUTOS($s0)  # Armazena palavra de $t0 na posição de memória OFFSET_AP_QTD_AUTOS($s0).

    # Retorna sucesso ao módulo chamador
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Finaliza a rotina de cadastro
    j       cadastro_adicionar_auto_finalizar  # Desvia a execução incondicionalmente para cadastro_adicionar_auto_finalizar.


cadastro_tipo_incompativel:

    # Impede a mistura de carros e motos retornando limite atingido (Issue #14/CT-004)
    li      $v0, LIMITE_AUTOS_ATINGIDO  # Carrega o valor imediato LIMITE_AUTOS_ATINGIDO no registrador $v0.

    # Encerra a rotina sem modificar os dados
    j       cadastro_adicionar_auto_finalizar  # Desvia a execução incondicionalmente para cadastro_adicionar_auto_finalizar.


cadastro_limite_auto:

    # Informa que o limite do tipo de veículo foi atingido
    li      $v0, LIMITE_AUTOS_ATINGIDO  # Carrega o valor imediato LIMITE_AUTOS_ATINGIDO no registrador $v0.


cadastro_adicionar_auto_finalizar:

    # Restaura os registradores preservados
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_remover_auto()
#
# Entrada:
#   $a0 = número do apartamento
#   $a1 = endereço da placa procurada
#
# Retorno:
#   $v0 = OK, AP_INVALIDO ou AUTO_NAO_ENCONTRADO
# ------------------------------------------------------------

cadastro_remover_auto:

    # Reserva espaço para o endereço de retorno e os registradores salvos (24 bytes, múltiplo de 8)
    addiu   $sp, $sp, -24  # Reserva espaço de pilha ajustando $sp em -24 bytes.

    # Salva o endereço de retorno
    sw $ra, 20($sp)  # Armazena palavra de $ra na posição de memória 20($sp).

    # Salva os registradores preservados utilizados na busca
    sw $s0, 16($sp)  # Armazena palavra de $s0 na posição de memória 16($sp).
    sw $s1, 12($sp)  # Armazena palavra de $s1 na posição de memória 12($sp).
    sw $s2, 8($sp)  # Armazena palavra de $s2 na posição de memória 8($sp).
    sw $s3, 4($sp)  # Armazena palavra de $s3 na posição de memória 4($sp).

    # Guarda o endereço da placa procurada
    move    $s1, $a1  # Copia o valor de $a1 para $s1.

    # Procura o bloco do apartamento informado
    jal     dados_obter_ap  # Chama a rotina dados_obter_ap e salva o endereço de retorno em $ra.

    # Encerra se o apartamento for inválido
    bne     $v0, OK, cadastro_remover_auto_finalizar  # Se $v0 e OK forem diferentes, desvia para cadastro_remover_auto_finalizar.

    # Guarda o endereço do bloco localizado
    move    $s0, $v1  # Copia o valor de $v1 para $s0.

    # Lê a quantidade atual de veículos cadastrados
    lw $s2, OFFSET_AP_QTD_AUTOS($s0)  # Carrega palavra da posição OFFSET_AP_QTD_AUTOS($s0) para $s2.

    # Começa a busca pelo primeiro veículo
    li      $s3, 0  # Carrega o valor imediato 0 no registrador $s3.


cadastro_buscar_auto:

    # Se o índice alcançar a quantidade, a placa não foi encontrada
    bge     $s3, $s2, cadastro_auto_nao_encontrado  # Se $s3 e $s2 forem maior ou igual a, desvia para cadastro_auto_nao_encontrado.

    # Carrega o tamanho de um registro de veículo
    li      $t0, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $t0.

    # Calcula o deslocamento do registro atual
    mul     $t1, $s3, $t0  # Multiplica $s3 por $t0 e grava o produto em $t1.

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $t2.

    # Calcula o endereço do registro atual
    addu    $t2, $t2, $t1  # Soma $t2 e $t1, gravando o resultado em $t2.

    # Avança até a placa dentro do registro
    addiu   $t2, $t2, TAM_MODELO  # Soma $t2 e TAM_MODELO, gravando o resultado em $t2.

    # Passa a placa armazenada para a comparação
    move    $a0, $t2  # Copia o valor de $t2 para $a0.

    # Passa a placa procurada para a comparação
    move    $a1, $s1  # Copia o valor de $s1 para $a1.

    # Informa o tamanho máximo das placas
    li      $a2, TAM_PLACA  # Carrega o valor imediato TAM_PLACA no registrador $a2.

    # Compara a placa armazenada com a placa procurada
    jal     cadastro_strings_iguais  # Chama a rotina cadastro_strings_iguais e salva o endereço de retorno em $ra.

    # Continua a busca se as placas forem diferentes
    beq     $v0, $zero, cadastro_proximo_auto  # Se $v0 e $zero forem iguais, desvia para cadastro_proximo_auto.

    # A posição atual corresponde ao veículo que será removido
    j       cadastro_deslocar_autos  # Desvia a execução incondicionalmente para cadastro_deslocar_autos.


cadastro_proximo_auto:

    # Avança para o próximo veículo
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua procurando dentro da lista de veículos
    j       cadastro_buscar_auto  # Desvia a execução incondicionalmente para cadastro_buscar_auto.


cadastro_deslocar_autos:

    # Verifica se há veículos depois daquele que será removido
    addiu   $t0, $s3, 1  # Soma $s3 e 1, gravando o resultado em $t0.
    bge     $t0, $s2, cadastro_limpar_ultimo_auto  # Se $t0 e $s2 forem maior ou igual a, desvia para cadastro_limpar_ultimo_auto.

    # Carrega o tamanho de um registro de veículo
    li      $t1, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $t1.

    # Calcula o deslocamento do registro de destino
    mul     $t2, $s3, $t1  # Multiplica $s3 por $t1 e grava o produto em $t2.

    # Calcula o deslocamento do registro seguinte
    addiu   $t3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $t3.
    mul     $t3, $t3, $t1  # Multiplica $t3 por $t1 e grava o produto em $t3.

    # Obtém o início da área de veículos
    addiu   $t4, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $t4.

    # Calcula o endereço de destino da cópia
    addu    $a0, $t4, $t2  # Soma $t4 e $t2, gravando o resultado em $a0.

    # Calcula o endereço do registro seguinte
    addu    $a1, $t4, $t3  # Soma $t4 e $t3, gravando o resultado em $a1.

    # Informa que será copiado um registro completo
    li      $a2, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $a2.

    # Move o próximo veículo para a posição atual
    jal     cadastro_copiar_bytes  # Chama a rotina cadastro_copiar_bytes e salva o endereço de retorno em $ra.

    # Avança para a posição que ainda precisa ser deslocada
    addiu   $s3, $s3, 1  # Soma $s3 e 1, gravando o resultado em $s3.

    # Continua deslocando os registros restantes
    j       cadastro_deslocar_autos  # Desvia a execução incondicionalmente para cadastro_deslocar_autos.


cadastro_limpar_ultimo_auto:

    # Calcula o índice do último veículo antes da remoção
    addiu   $t0, $s2, -1  # Soma $s2 e -1, gravando o resultado em $t0.

    # Carrega o tamanho de um registro de veículo
    li      $t1, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $t1.

    # Calcula o deslocamento do último registro
    mul     $t0, $t0, $t1  # Multiplica $t0 por $t1 e grava o produto em $t0.

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS  # Soma $s0 e OFFSET_AP_AUTOS, gravando o resultado em $t2.

    # Calcula o endereço do registro que será apagado
    addu    $a0, $t2, $t0  # Soma $t2 e $t0, gravando o resultado em $a0.

    # Informa o tamanho do registro que será zerado
    li      $a1, TAM_REGISTRO_AUTO  # Carrega o valor imediato TAM_REGISTRO_AUTO no registrador $a1.

    # Limpa o espaço que ficou sobrando
    jal     cadastro_zerar_bytes  # Chama a rotina cadastro_zerar_bytes e salva o endereço de retorno em $ra.

    # Reduz a quantidade de veículos no cabeçalho
    addiu   $s2, $s2, -1  # Soma $s2 e -1, gravando o resultado em $s2.

    # Salva a quantidade atualizada
    sw $s2, OFFSET_AP_QTD_AUTOS($s0)  # Armazena palavra de $s2 na posição de memória OFFSET_AP_QTD_AUTOS($s0).

    # Se não restar veículo, remove também o tipo registrado
    bne     $s2, $zero, cadastro_remover_auto_ok  # Se $s2 e $zero forem diferentes, desvia para cadastro_remover_auto_ok.

    # Marca o apartamento como sem veículos
    sw $zero, OFFSET_AP_TIPO_AUTO($s0)  # Armazena palavra de $zero na posição de memória OFFSET_AP_TIPO_AUTO($s0).


cadastro_remover_auto_ok:

    # Informa que a remoção foi realizada
    li      $v0, OK  # Carrega o valor imediato OK no registrador $v0.

    # Finaliza a rotina
    j       cadastro_remover_auto_finalizar  # Desvia a execução incondicionalmente para cadastro_remover_auto_finalizar.


cadastro_auto_nao_encontrado:

    # Informa que a placa procurada não foi encontrada
    li      $v0, AUTO_NAO_ENCONTRADO  # Carrega o valor imediato AUTO_NAO_ENCONTRADO no registrador $v0.


cadastro_remover_auto_finalizar:

    # Restaura os registradores preservados
    lw $s3, 4($sp)  # Carrega palavra da posição 4($sp) para $s3.
    lw $s2, 8($sp)  # Carrega palavra da posição 8($sp) para $s2.
    lw $s1, 12($sp)  # Carrega palavra da posição 12($sp) para $s1.
    lw $s0, 16($sp)  # Carrega palavra da posição 16($sp) para $s0.

    # Restaura o endereço de retorno
    lw $ra, 20($sp)  # Carrega palavra da posição 20($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 24  # Libera espaço de pilha ajustando $sp em 24 bytes.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_copiar_string()
#
# Copia uma string até encontrar '\0' ou atingir o limite
#
# Entrada:
#   $a0 = destino
#   $a1 = origem
#   $a2 = quantidade máxima de bytes
# ------------------------------------------------------------

cadastro_copiar_string:

    # Inicializa o contador de bytes copiados
    li      $t0, 0  # Carrega o valor imediato 0 no registrador $t0.


cadastro_copiar_string_loop:

    # Para antes de ultrapassar o tamanho máximo do campo
    bge     $t0, $a2, cadastro_copiar_string_terminar  # Se $t0 e $a2 forem maior ou igual a, desvia para cadastro_copiar_string_terminar.

    # Lê um byte da string de origem
    lbu $t1, 0($a1)  # Carrega byte sem sinal da posição 0($a1) para $t1.

    # Grava o byte na posição atual do destino
    sb $t1, 0($a0)  # Armazena byte de $t1 na posição de memória 0($a0).

    # Avança um byte na origem
    addiu   $a1, $a1, 1  # Soma $a1 e 1, gravando o resultado em $a1.

    # Avança um byte no destino
    addiu   $a0, $a0, 1  # Soma $a0 e 1, gravando o resultado em $a0.

    # Conta o byte que acabou de ser copiado
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.

    # Encerra quando o terminador da string for copiado
    beq     $t1, $zero, cadastro_copiar_string_finalizar  # Se $t1 e $zero forem iguais, desvia para cadastro_copiar_string_finalizar.

    # Continua copiando os bytes restantes
    j       cadastro_copiar_string_loop  # Desvia a execução incondicionalmente para cadastro_copiar_string_loop.


cadastro_copiar_string_terminar:

    # Garante que o campo termine com '\0' mesmo se a origem for longa
    addiu   $a0, $a0, -1  # Soma $a0 e -1, gravando o resultado em $a0.

    # Grava o terminador na última posição disponível
    sb $zero, 0($a0)  # Armazena byte de $zero na posição de memória 0($a0).


cadastro_copiar_string_finalizar:

    # Retorna sem alterar os registradores preservados
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_copiar_bytes()
#
# Copia uma quantidade fixa de bytes
#
# Entrada:
#   $a0 = destino
#   $a1 = origem
#   $a2 = quantidade de bytes
# ------------------------------------------------------------

cadastro_copiar_bytes:

    # Inicializa o contador de bytes restantes
    move    $t0, $a2  # Copia o valor de $a2 para $t0.


cadastro_copiar_bytes_loop:

    # Termina quando todos os bytes forem copiados
    beq     $t0, $zero, cadastro_copiar_bytes_finalizar  # Se $t0 e $zero forem iguais, desvia para cadastro_copiar_bytes_finalizar.

    # Lê um byte da origem
    lbu $t1, 0($a1)  # Carrega byte sem sinal da posição 0($a1) para $t1.

    # Grava o byte no destino
    sb $t1, 0($a0)  # Armazena byte de $t1 na posição de memória 0($a0).

    # Avança na origem
    addiu   $a1, $a1, 1  # Soma $a1 e 1, gravando o resultado em $a1.

    # Avança no destino
    addiu   $a0, $a0, 1  # Soma $a0 e 1, gravando o resultado em $a0.

    # Reduz a quantidade de bytes restantes
    addiu   $t0, $t0, -1  # Soma $t0 e -1, gravando o resultado em $t0.

    # Continua a cópia
    j       cadastro_copiar_bytes_loop  # Desvia a execução incondicionalmente para cadastro_copiar_bytes_loop.


cadastro_copiar_bytes_finalizar:

    # Retorna para a rotina que solicitou a cópia
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_zerar_bytes()
#
# Preenche uma região de memória com zeros
#
# Entrada:
#   $a0 = endereço inicial
#   $a1 = quantidade de bytes
# ------------------------------------------------------------

cadastro_zerar_bytes:

    # Copia a quantidade de bytes para o contador de controle
    move    $t0, $a1  # Copia o valor de $a1 para $t0.


cadastro_zerar_bytes_loop:

    # Termina quando toda a região estiver zerada
    beq     $t0, $zero, cadastro_zerar_bytes_finalizar  # Se $t0 e $zero forem iguais, desvia para cadastro_zerar_bytes_finalizar.

    # Grava zero na posição atual
    sb $zero, 0($a0)  # Armazena byte de $zero na posição de memória 0($a0).

    # Avança para o próximo byte
    addiu   $a0, $a0, 1  # Soma $a0 e 1, gravando o resultado em $a0.

    # Reduz a quantidade restante
    addiu   $t0, $t0, -1  # Soma $t0 e -1, gravando o resultado em $t0.

    # Continua zerando a região
    j       cadastro_zerar_bytes_loop  # Desvia a execução incondicionalmente para cadastro_zerar_bytes_loop.


cadastro_zerar_bytes_finalizar:

    # Retorna para a rotina que solicitou a limpeza
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_strings_iguais()
#
# Compara duas strings até encontrar '\0' ou atingir o limite
#
# Entrada:
#   $a0 = endereço da primeira string
#   $a1 = endereço da segunda string
#   $a2 = tamanho máximo da comparação
#
# Retorno:
#   $v0 = 1 se forem iguais
#   $v0 = 0 se forem diferentes
# ------------------------------------------------------------

cadastro_strings_iguais:

    # Inicializa o contador de bytes comparados
    li      $t0, 0  # Carrega o valor imediato 0 no registrador $t0.


cadastro_strings_iguais_loop:

    # Se o limite for atingido, considera os campos iguais
    bge     $t0, $a2, cadastro_strings_iguais_sim  # Se $t0 e $a2 forem maior ou igual a, desvia para cadastro_strings_iguais_sim.

    # Lê um byte da primeira string
    lbu $t1, 0($a0)  # Carrega byte sem sinal da posição 0($a0) para $t1.

    # Lê o byte correspondente da segunda string
    lbu $t2, 0($a1)  # Carrega byte sem sinal da posição 0($a1) para $t2.

    # Strings diferentes retornam imediatamente
    bne     $t1, $t2, cadastro_strings_iguais_nao  # Se $t1 e $t2 forem diferentes, desvia para cadastro_strings_iguais_nao.

    # Dois terminadores iguais indicam que as strings terminaram juntas
    beq     $t1, $zero, cadastro_strings_iguais_sim  # Se $t1 e $zero forem iguais, desvia para cadastro_strings_iguais_sim.

    # Avança na primeira string
    addiu   $a0, $a0, 1  # Soma $a0 e 1, gravando o resultado em $a0.

    # Avança na segunda string
    addiu   $a1, $a1, 1  # Soma $a1 e 1, gravando o resultado em $a1.

    # Atualiza a quantidade de bytes comparados
    addiu   $t0, $t0, 1  # Soma $t0 e 1, gravando o resultado em $t0.

    # Continua comparando os próximos bytes
    j       cadastro_strings_iguais_loop  # Desvia a execução incondicionalmente para cadastro_strings_iguais_loop.


cadastro_strings_iguais_sim:

    # Retorna um para indicar que os campos são iguais
    li      $v0, 1  # Seleciona em $v0 o serviço MARS de imprimir inteiro.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


cadastro_strings_iguais_nao:

    # Retorna zero para indicar que os campos são diferentes
    li      $v0, 0  # Carrega o valor imediato 0 no registrador $v0.

    # Retorna ao módulo chamador
    jr      $ra  # Retorna ao endereço guardado em $ra.


# ------------------------------------------------------------
# cadastro_limpar_ap()
#
# Exclui todos os moradores e automóveis do apartamento (cmd_5)
#
# Entrada:
#   $a0 = número do apartamento
#
# Retorno:
#   $v0 = OK ou AP_INVALIDO
# ------------------------------------------------------------

cadastro_limpar_ap:

    # Reserva espaço para o endereço de retorno (alinhado em 8 bytes)
    addiu   $sp, $sp, -8  # Reserva espaço de pilha ajustando $sp em -8 bytes.

    # Salva o endereço de retorno da chamada
    sw $ra, 4($sp)  # Armazena palavra de $ra na posição de memória 4($sp).

    # Invoca a rotina de limpeza completa do bloco mantendo o número
    jal     dados_limpar_ap  # Chama a rotina dados_limpar_ap e salva o endereço de retorno em $ra.

    # Restaura o endereço de retorno
    lw $ra, 4($sp)  # Carrega palavra da posição 4($sp) para $ra.

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 8  # Libera espaço de pilha ajustando $sp em 8 bytes.

    # Retorna o código de status resultante em $v0
    jr      $ra  # Retorna ao endereço guardado em $ra.