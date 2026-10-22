# Descrição: cadastro e remoção de moradores e automóveis


# Torna públicas as rotinas utilizadas pelos demais módulos
.globl cadastro_adicionar_morador
.globl cadastro_remover_morador
.globl cadastro_adicionar_auto
.globl cadastro_remover_auto
.globl cadastro_limpar_ap



# Seleciona a seção de instruções
.text


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

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -20

    # Salva o endereço de retorno antes de chamar outra função
    sw      $ra, 16($sp)

    # Salva os registradores preservados utilizados nesta rotina
    sw      $s0, 12($sp)
    sw      $s1, 8($sp)
    sw      $s2, 4($sp)
    sw      $s3, 0($sp)

    # Guarda o endereço do nome para utilizá-lo depois da busca
    move    $s1, $a1

    # Procura o bloco correspondente ao apartamento informado
    jal     dados_obter_ap

    # Se o apartamento não existe, encerra com o erro retornado
    bne     $v0, OK, cadastro_adicionar_morador_finalizar

    # Guarda o endereço do bloco localizado
    move    $s0, $v1

    # Lê a quantidade atual de moradores do apartamento
    lw      $s2, OFFSET_AP_QTD_MORADORES($s0)

    # Compara a quantidade atual com o limite permitido
    li      $t0, LIMITE_MORADORES
    bge     $s2, $t0, cadastro_limite_moradores

    # Carrega o tamanho de um registro de morador
    li      $t0, TAM_REGISTRO_MORADOR

    # Calcula o deslocamento do próximo registro disponível
    mul     $t1, $s2, $t0

    # Começa no início da área de moradores do apartamento
    addiu   $t2, $s0, OFFSET_AP_MORADORES

    # Soma o deslocamento e encontra o destino do novo nome
    addu    $t2, $t2, $t1

    # Passa o endereço de destino para a rotina de cópia
    move    $a0, $t2

    # Passa o endereço do nome recebido para a rotina de cópia
    move    $a1, $s1

    # Informa que o campo possui espaço para TAM_NOME bytes
    li      $a2, TAM_NOME

    # Copia o nome para o bloco do apartamento
    jal     cadastro_copiar_string

    # Atualiza a quantidade de moradores cadastrados
    addiu   $s2, $s2, 1

    # Salva a nova quantidade no cabeçalho do apartamento
    sw      $s2, OFFSET_AP_QTD_MORADORES($s0)

    # Informa que o cadastro foi concluído
    li      $v0, OK

    # Encerra a rotina de cadastro.
    j       cadastro_adicionar_morador_finalizar


cadastro_limite_moradores:

    # Informa que não há espaço para outro morador
    li      $v0, LIMITE_MORADORES_ATINGIDO


cadastro_adicionar_morador_finalizar:

    # Restaura os registradores preservados pela rotina
    lw      $s3, 0($sp)
    lw      $s2, 4($sp)
    lw      $s1, 8($sp)
    lw      $s0, 12($sp)

    # Restaura o endereço de retorno original
    lw      $ra, 16($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 20

    # Retorna ao módulo chamador
    jr      $ra


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

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -20

    # Salva o endereço de retorno da rotina
    sw      $ra, 16($sp)

    # Salva os registradores preservados que serão utilizados
    sw      $s0, 12($sp)
    sw      $s1, 8($sp)
    sw      $s2, 4($sp)
    sw      $s3, 0($sp)

    # Guarda o endereço do nome que será pesquisado
    move    $s1, $a1

    # Procura o bloco do apartamento informado
    jal     dados_obter_ap

    # Encerra se o apartamento informado for inválido
    bne     $v0, OK, cadastro_remover_morador_finalizar

    # Guarda o endereço do bloco encontrado.
    move    $s0, $v1

    # Lê a quantidade atual de moradores
    lw      $s2, OFFSET_AP_QTD_MORADORES($s0)

    # Começa a busca pelo primeiro registro
    li      $s3, 0


cadastro_buscar_morador:

    # Se o índice alcançar a quantidade, o nome não foi encontrado
    bge     $s3, $s2, cadastro_morador_nao_encontrado

    # Carrega o tamanho de um registro de morador
    li      $t0, TAM_REGISTRO_MORADOR

    # Calcula o deslocamento do registro atual
    mul     $t1, $s3, $t0

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES

    # Calcula o endereço do nome atual
    addu    $t2, $t2, $t1

    # Passa o nome armazenado para a comparação
    move    $a0, $t2

    # Passa o nome procurado para a comparação
    move    $a1, $s1

    # Informa o tamanho máximo dos nomes
    li      $a2, TAM_NOME

    # Compara os dois nomes
    jal     cadastro_strings_iguais

    # Continua a busca se os nomes forem diferentes
    beq     $v0, $zero, cadastro_proximo_morador

    # O índice atual identifica o morador que será removido
    j       cadastro_deslocar_moradores


cadastro_proximo_morador:

    # Avança para o próximo registro de morador
    addiu   $s3, $s3, 1

    # Continua procurando dentro da área de moradores
    j       cadastro_buscar_morador


cadastro_deslocar_moradores:

    # Verifica se existem registros depois do removido
    addiu   $t0, $s3, 1
    bge     $t0, $s2, cadastro_limpar_ultimo_morador

    # Carrega o tamanho de cada registro de morador
    li      $t1, TAM_REGISTRO_MORADOR

    # Calcula o deslocamento do registro que será substituído
    mul     $t2, $s3, $t1

    # Calcula o deslocamento do registro seguinte
    addiu   $t3, $s3, 1
    mul     $t3, $t3, $t1

    # Obtém o início da área de moradores
    addiu   $t4, $s0, OFFSET_AP_MORADORES

    # Calcula o endereço do destino da cópia
    addu    $a0, $t4, $t2

    # Calcula o endereço do registro seguinte
    addu    $a1, $t4, $t3

    # Informa que será copiado um registro inteiro
    li      $a2, TAM_REGISTRO_MORADOR

    # Move o próximo morador para a posição atual
    jal     cadastro_copiar_bytes

    # Avança para a próxima posição que ainda precisa ser deslocada
    addiu   $s3, $s3, 1

    # Continua deslocando os registros restantes
    j       cadastro_deslocar_moradores


cadastro_limpar_ultimo_morador:

    # Calcula o índice do último morador antes da remoção
    addiu   $t0, $s2, -1

    # Carrega o tamanho de um registro de morador
    li      $t1, TAM_REGISTRO_MORADOR

    # Calcula o deslocamento do último registro
    mul     $t0, $t0, $t1

    # Obtém o início da área de moradores
    addiu   $t2, $s0, OFFSET_AP_MORADORES

    # Calcula o endereço do registro que será apagado
    addu    $a0, $t2, $t0

    # Informa o tamanho do registro que será zerado
    li      $a1, TAM_REGISTRO_MORADOR

    # Limpa o espaço que ficou sobrando no final da lista
    jal     cadastro_zerar_bytes

    # Reduz a quantidade registrada no cabeçalho
    addiu   $s2, $s2, -1

    # Salva a nova quantidade de moradores
    sw      $s2, OFFSET_AP_QTD_MORADORES($s0)

    # Se ainda restarem moradores, mantém os veículos
    bgtz    $s2, cadastro_remover_morador_ok

    # Se o apartamento ficou vazio (0 moradores), exclui todos os veículos automaticamente (R2/cmd_2)
    sw      $zero, OFFSET_AP_TIPO_AUTO($s0)
    sw      $zero, OFFSET_AP_QTD_AUTOS($s0)

    # Carrega o endereço da área reservada aos veículos
    addiu   $a0, $s0, OFFSET_AP_AUTOS

    # Carrega o tamanho total da área de veículos (3 veículos x 40 bytes = 120 bytes)
    li      $a1, 120

    # Zera os registros de automóveis do apartamento
    jal     cadastro_zerar_bytes

cadastro_remover_morador_ok:

    # Informa que a remoção foi concluída
    li      $v0, OK

    # Finaliza a rotina
    j       cadastro_remover_morador_finalizar



cadastro_morador_nao_encontrado:

    # Informa que o nome não estava cadastrado no apartamento
    li      $v0, MORADOR_NAO_ENCONTRADO


cadastro_remover_morador_finalizar:

    # Restaura os registradores preservados
    lw      $s3, 0($sp)
    lw      $s2, 4($sp)
    lw      $s1, 8($sp)
    lw      $s0, 12($sp)

    # Restaura o endereço de retorno original
    lw      $ra, 16($sp)

    # Libera o espaço utilizado na pilha
    addiu   $sp, $sp, 20

    # Retorna ao módulo chamador
    jr      $ra


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

    # Reserva espaço para o endereço de retorno e quatro registradores salvos
    addiu   $sp, $sp, -20

    # Salva o endereço de retorno
    sw      $ra, 16($sp)

    # Salva o bloco, o tipo e os endereços dos textos recebidos
    sw      $s0, 12($sp)
    sw      $s1, 8($sp)
    sw      $s2, 4($sp)
    sw      $s3, 0($sp)

    # Guarda o tipo do veículo para uso após a busca
    move    $s1, $a1

    # Guarda o endereço do modelo
    move    $s2, $a2

    # Guarda o endereço da placa
    move    $s3, $a3

    # Verifica se o tipo informado é carro ou moto
    beq     $s1, TIPO_AUTO_CARRO, cadastro_tipo_auto_valido
    beq     $s1, TIPO_AUTO_MOTO, cadastro_tipo_auto_valido

    # Rejeita qualquer tipo diferente de carro ou moto
    li      $v0, TIPO_INVALIDO
    j       cadastro_adicionar_auto_finalizar


cadastro_tipo_auto_valido:

    # Procura o bloco correspondente ao apartamento
    move    $a1, $s1
    jal     dados_obter_ap

    # Encerra se o apartamento não for válido
    bne     $v0, OK, cadastro_adicionar_auto_finalizar

    # Guarda o endereço do bloco localizado
    move    $s0, $v1

    # Lê a quantidade atual de veículos cadastrados
    lw      $t0, OFFSET_AP_QTD_AUTOS($s0)

    # Se já houver veículo, o tipo deve ser mantido
    beq     $t0, $zero, cadastro_primeiro_auto

    # Lê o tipo que já está registrado no apartamento
    lw      $t1, OFFSET_AP_TIPO_AUTO($s0)

    # Não permite misturar carros e motos no mesmo apartamento
    bne     $t1, $s1, cadastro_tipo_incompativel


cadastro_validar_limite_auto:

    # Verifica se o veículo é um carro
    beq     $s1, TIPO_AUTO_CARRO, cadastro_validar_limite_carro

    # Para motos, o limite permitido é três unidades
    li      $t1, LIMITE_MOTOS
    bge     $t0, $t1, cadastro_limite_auto

    # Continua para o armazenamento do veículo
    j       cadastro_gravar_auto


cadastro_validar_limite_carro:

    # Para carros, o limite permitido é uma unidade
    li      $t1, LIMITE_CARROS
    bge     $t0, $t1, cadastro_limite_auto

    # Continua para o armazenamento do veículo
    j       cadastro_gravar_auto


cadastro_primeiro_auto:

    # Registra o tipo do primeiro veículo do apartamento
    sw      $s1, OFFSET_AP_TIPO_AUTO($s0)

    # Continua para validar o limite correspondente ao tipo
    j       cadastro_validar_limite_auto


cadastro_gravar_auto:

    # Carrega o tamanho de um registro de veículo
    li      $t1, TAM_REGISTRO_AUTO

    # Calcula o deslocamento do próximo registro disponível
    mul     $t2, $t0, $t1

    # Obtém o início da área de veículos do apartamento
    addiu   $t3, $s0, OFFSET_AP_AUTOS

    # Calcula o endereço do registro que receberá os dados
    addu    $t3, $t3, $t2

    # Usa o início do registro como destino do modelo
    move    $a0, $t3

    # Usa o endereço salvo do modelo como origem da cópia
    move    $a1, $s2

    # Informa o tamanho disponível para o modelo
    li      $a2, TAM_MODELO

    # Copia o modelo para o registro do veículo
    jal     cadastro_copiar_string

    # Avança até a área da placa dentro do mesmo registro
    addiu   $a0, $t3, TAM_MODELO

    # Usa o endereço salvo da placa como origem da cópia
    move    $a1, $s3

    # Informa o tamanho disponível para a placa
    li      $a2, TAM_PLACA

    # Copia a placa para o registro do veículo
    jal     cadastro_copiar_string

    # Lê novamente a quantidade atual de veículos
    lw      $t0, OFFSET_AP_QTD_AUTOS($s0)

    # Incrementa a quantidade após o novo cadastro
    addiu   $t0, $t0, 1

    # Salva a nova quantidade no cabeçalho
    sw      $t0, OFFSET_AP_QTD_AUTOS($s0)

    # Retorna sucesso ao módulo chamador
    li      $v0, OK

    # Finaliza a rotina de cadastro
    j       cadastro_adicionar_auto_finalizar


cadastro_tipo_incompativel:

    # Impede a mistura de carros e motos no mesmo apartamento
    li      $v0, TIPO_INVALIDO

    # Encerra a rotina sem modificar os dados
    j       cadastro_adicionar_auto_finalizar


cadastro_limite_auto:

    # Informa que o limite do tipo de veículo foi atingido
    li      $v0, LIMITE_AUTOS_ATINGIDO


cadastro_adicionar_auto_finalizar:

    # Restaura os registradores preservados
    lw      $s3, 0($sp)
    lw      $s2, 4($sp)
    lw      $s1, 8($sp)
    lw      $s0, 12($sp)

    # Restaura o endereço de retorno
    lw      $ra, 16($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 20

    # Retorna ao módulo chamador
    jr      $ra


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

    # Reserva espaço para o endereço de retorno e os registradores salvos
    addiu   $sp, $sp, -20

    # Salva o endereço de retorno
    sw      $ra, 16($sp)

    # Salva os registradores preservados utilizados na busca
    sw      $s0, 12($sp)
    sw      $s1, 8($sp)
    sw      $s2, 4($sp)
    sw      $s3, 0($sp)

    # Guarda o endereço da placa procurada
    move    $s1, $a1

    # Procura o bloco do apartamento informado
    jal     dados_obter_ap

    # Encerra se o apartamento for inválido
    bne     $v0, OK, cadastro_remover_auto_finalizar

    # Guarda o endereço do bloco localizado
    move    $s0, $v1

    # Lê a quantidade atual de veículos cadastrados
    lw      $s2, OFFSET_AP_QTD_AUTOS($s0)

    # Começa a busca pelo primeiro veículo
    li      $s3, 0


cadastro_buscar_auto:

    # Se o índice alcançar a quantidade, a placa não foi encontrada
    bge     $s3, $s2, cadastro_auto_nao_encontrado

    # Carrega o tamanho de um registro de veículo
    li      $t0, TAM_REGISTRO_AUTO

    # Calcula o deslocamento do registro atual
    mul     $t1, $s3, $t0

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS

    # Calcula o endereço do registro atual
    addu    $t2, $t2, $t1

    # Avança até a placa dentro do registro
    addiu   $t2, $t2, TAM_MODELO

    # Passa a placa armazenada para a comparação
    move    $a0, $t2

    # Passa a placa procurada para a comparação
    move    $a1, $s1

    # Informa o tamanho máximo das placas
    li      $a2, TAM_PLACA

    # Compara a placa armazenada com a placa procurada
    jal     cadastro_strings_iguais

    # Continua a busca se as placas forem diferentes
    beq     $v0, $zero, cadastro_proximo_auto

    # A posição atual corresponde ao veículo que será removido
    j       cadastro_deslocar_autos


cadastro_proximo_auto:

    # Avança para o próximo veículo
    addiu   $s3, $s3, 1

    # Continua procurando dentro da lista de veículos
    j       cadastro_buscar_auto


cadastro_deslocar_autos:

    # Verifica se há veículos depois daquele que será removido
    addiu   $t0, $s3, 1
    bge     $t0, $s2, cadastro_limpar_ultimo_auto

    # Carrega o tamanho de um registro de veículo
    li      $t1, TAM_REGISTRO_AUTO

    # Calcula o deslocamento do registro de destino
    mul     $t2, $s3, $t1

    # Calcula o deslocamento do registro seguinte
    addiu   $t3, $s3, 1
    mul     $t3, $t3, $t1

    # Obtém o início da área de veículos
    addiu   $t4, $s0, OFFSET_AP_AUTOS

    # Calcula o endereço de destino da cópia
    addu    $a0, $t4, $t2

    # Calcula o endereço do registro seguinte
    addu    $a1, $t4, $t3

    # Informa que será copiado um registro completo
    li      $a2, TAM_REGISTRO_AUTO

    # Move o próximo veículo para a posição atual
    jal     cadastro_copiar_bytes

    # Avança para a posição que ainda precisa ser deslocada
    addiu   $s3, $s3, 1

    # Continua deslocando os registros restantes
    j       cadastro_deslocar_autos


cadastro_limpar_ultimo_auto:

    # Calcula o índice do último veículo antes da remoção
    addiu   $t0, $s2, -1

    # Carrega o tamanho de um registro de veículo
    li      $t1, TAM_REGISTRO_AUTO

    # Calcula o deslocamento do último registro
    mul     $t0, $t0, $t1

    # Obtém o início da área de veículos
    addiu   $t2, $s0, OFFSET_AP_AUTOS

    # Calcula o endereço do registro que será apagado
    addu    $a0, $t2, $t0

    # Informa o tamanho do registro que será zerado
    li      $a1, TAM_REGISTRO_AUTO

    # Limpa o espaço que ficou sobrando
    jal     cadastro_zerar_bytes

    # Reduz a quantidade de veículos no cabeçalho
    addiu   $s2, $s2, -1

    # Salva a quantidade atualizada
    sw      $s2, OFFSET_AP_QTD_AUTOS($s0)

    # Se não restar veículo, remove também o tipo registrado
    bne     $s2, $zero, cadastro_remover_auto_ok

    # Marca o apartamento como sem veículos
    sw      $zero, OFFSET_AP_TIPO_AUTO($s0)


cadastro_remover_auto_ok:

    # Informa que a remoção foi realizada
    li      $v0, OK

    # Finaliza a rotina
    j       cadastro_remover_auto_finalizar


cadastro_auto_nao_encontrado:

    # Informa que a placa procurada não foi encontrada
    li      $v0, AUTO_NAO_ENCONTRADO


cadastro_remover_auto_finalizar:

    # Restaura os registradores preservados
    lw      $s3, 0($sp)
    lw      $s2, 4($sp)
    lw      $s1, 8($sp)
    lw      $s0, 12($sp)

    # Restaura o endereço de retorno
    lw      $ra, 16($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 20

    # Retorna ao módulo chamador
    jr      $ra


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
    li      $t0, 0


cadastro_copiar_string_loop:

    # Para antes de ultrapassar o tamanho máximo do campo
    bge     $t0, $a2, cadastro_copiar_string_terminar

    # Lê um byte da string de origem
    lbu     $t1, 0($a1)

    # Grava o byte na posição atual do destino
    sb      $t1, 0($a0)

    # Avança um byte na origem
    addiu   $a1, $a1, 1

    # Avança um byte no destino
    addiu   $a0, $a0, 1

    # Conta o byte que acabou de ser copiado
    addiu   $t0, $t0, 1

    # Encerra quando o terminador da string for copiado
    beq     $t1, $zero, cadastro_copiar_string_finalizar

    # Continua copiando os bytes restantes
    j       cadastro_copiar_string_loop


cadastro_copiar_string_terminar:

    # Garante que o campo termine com '\0' mesmo se a origem for longa
    addiu   $a0, $a0, -1

    # Grava o terminador na última posição disponível
    sb      $zero, 0($a0)


cadastro_copiar_string_finalizar:

    # Retorna sem alterar os registradores preservados
    jr      $ra


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
    move    $t0, $a2


cadastro_copiar_bytes_loop:

    # Termina quando todos os bytes forem copiados
    beq     $t0, $zero, cadastro_copiar_bytes_finalizar

    # Lê um byte da origem
    lbu     $t1, 0($a1)

    # Grava o byte no destino
    sb      $t1, 0($a0)

    # Avança na origem
    addiu   $a1, $a1, 1

    # Avança no destino
    addiu   $a0, $a0, 1

    # Reduz a quantidade de bytes restantes
    addiu   $t0, $t0, -1

    # Continua a cópia
    j       cadastro_copiar_bytes_loop


cadastro_copiar_bytes_finalizar:

    # Retorna para a rotina que solicitou a cópia
    jr      $ra


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
    move    $t0, $a1


cadastro_zerar_bytes_loop:

    # Termina quando toda a região estiver zerada
    beq     $t0, $zero, cadastro_zerar_bytes_finalizar

    # Grava zero na posição atual
    sb      $zero, 0($a0)

    # Avança para o próximo byte
    addiu   $a0, $a0, 1

    # Reduz a quantidade restante
    addiu   $t0, $t0, -1

    # Continua zerando a região
    j       cadastro_zerar_bytes_loop


cadastro_zerar_bytes_finalizar:

    # Retorna para a rotina que solicitou a limpeza
    jr      $ra


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
    li      $t0, 0


cadastro_strings_iguais_loop:

    # Se o limite for atingido, considera os campos iguais
    bge     $t0, $a2, cadastro_strings_iguais_sim

    # Lê um byte da primeira string
    lbu     $t1, 0($a0)

    # Lê o byte correspondente da segunda string
    lbu     $t2, 0($a1)

    # Strings diferentes retornam imediatamente
    bne     $t1, $t2, cadastro_strings_iguais_nao

    # Dois terminadores iguais indicam que as strings terminaram juntas
    beq     $t1, $zero, cadastro_strings_iguais_sim

    # Avança na primeira string
    addiu   $a0, $a0, 1

    # Avança na segunda string
    addiu   $a1, $a1, 1

    # Atualiza a quantidade de bytes comparados
    addiu   $t0, $t0, 1

    # Continua comparando os próximos bytes
    j       cadastro_strings_iguais_loop


cadastro_strings_iguais_sim:

    # Retorna um para indicar que os campos são iguais
    li      $v0, 1

    # Retorna ao módulo chamador
    jr      $ra


cadastro_strings_iguais_nao:

    # Retorna zero para indicar que os campos são diferentes
    li      $v0, 0

    # Retorna ao módulo chamador
    jr      $ra


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

    # Reserva espaço para o endereço de retorno
    addiu   $sp, $sp, -4

    # Salva o endereço de retorno da chamada
    sw      $ra, 0($sp)

    # Invoca a rotina de limpeza completa do bloco mantendo o número
    jal     dados_limpar_ap

    # Restaura o endereço de retorno
    lw      $ra, 0($sp)

    # Libera o espaço reservado na pilha
    addiu   $sp, $sp, 4

    # Retorna o código de status resultante em $v0
    jr      $ra