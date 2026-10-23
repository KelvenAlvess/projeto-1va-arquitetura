# ============================================================
# Grupo: Kelven Alves, João Pedro Araújo e Erik Vinicius Gomes de Lima
# Atividade: Projeto 01 - 1VA
# Disciplina: Arquitetura e Organização de Computadores (UFRPE - 2026.2)
# Professor: Prof. Vítor A Coutinho
# Arquivo: contratos.asm
# Descrição: constantes, limites do dominio, convencoes compartilhadas e codigos de retorno
# ============================================================
.eqv OK                         0   # Operação concluída corretamente
.eqv AP_INVALIDO                1   # Número de apartamento inexistente
.eqv MORADOR_NAO_ENCONTRADO     2   # Morador procurado não foi localizado
.eqv AUTO_NAO_ENCONTRADO        3   # Automóvel procurado não foi localizado
.eqv TIPO_INVALIDO              4   # Tipo informado não corresponde a carro ou moto
.eqv LIMITE_MORADORES_ATINGIDO  5   # O apartamento já possui seis moradores
.eqv LIMITE_AUTOS_ATINGIDO      6   # O limite de veículos do apartamento foi atingido
.eqv ENTRADA_INVALIDA           7   # Dado recebido não passou pela validação
.eqv ERRO_ARQUIVO               8   # Falha durante uma operação de arquivo

# ------------------------------------------------------------
# ORGANIZAÇÃO DOS APARTAMENTOS
# ------------------------------------------------------------

.eqv TOTAL_ANDARES               12  # O condomínio possui doze andares.
.eqv APS_POR_ANDAR                2  # Cada andar possui dois apartamentos.
.eqv TOTAL_APARTAMENTOS          24  # Quantidade total de apartamentos.

.eqv PRIMEIRO_ANDAR               1  # Menor andar permitido no cadastro.
.eqv ULTIMO_ANDAR                12  # Maior andar permitido no cadastro.

.eqv PRIMEIRO_AP_POR_ANDAR        1  # Primeiro apartamento de cada andar.
.eqv SEGUNDO_AP_POR_ANDAR          2  # Segundo apartamento de cada andar.

# ------------------------------------------------------------
# LIMITES DO DOMÍNIO
# ------------------------------------------------------------

.eqv LIMITE_MORADORES              6  # Cada apartamento comporta até seis moradores.

.eqv LIMITE_AUTOMOVEIS             3  # Capacidade máxima reservada para veículos.
.eqv LIMITE_CARROS                 1  # Um apartamento pode ter no máximo um carro.
.eqv LIMITE_MOTOS                   3  # Um apartamento pode ter até três motos.

# ------------------------------------------------------------
# TIPOS DE AUTOMÓVEL
# ------------------------------------------------------------

.eqv TIPO_AUTO_NENHUM              0  # O apartamento não possui veículos.
.eqv TIPO_AUTO_CARRO               1  # Identifica um automóvel do tipo carro.
.eqv TIPO_AUTO_MOTO                2  # Identifica um automóvel do tipo moto.

# ------------------------------------------------------------
# TAMANHO DOS CAMPOS DE TEXTO
#
# Os valores incluem o byte reservado para o terminador '\0'.
# ------------------------------------------------------------

.eqv TAM_NOME                     64  # Espaço reservado para o nome do morador.
.eqv TAM_MODELO                   32  # Espaço reservado para o modelo do veículo.
.eqv TAM_PLACA                     8  # Espaço reservado para uma placa de sete caracteres.


# Tamanho do cabeçalho de cada apartamento
.eqv TAM_CABECALHO_AP             16  # Define a constante simbólica TAM_CABECALHO_AP             16.

# Cada registro de morador ocupa o espaço reservado para um nome
.eqv TAM_REGISTRO_MORADOR         64  # Define a constante simbólica TAM_REGISTRO_MORADOR         64.

# Cada registro possui modelo e placa
.eqv TAM_REGISTRO_AUTO            40  # Define a constante simbólica TAM_REGISTRO_AUTO            40.

# ------------------------------------------------------------
# OFFSETS DO BLOCO DE APARTAMENTO
#
# Cada bloco possui 520 bytes e reúne o cabeçalho, os moradores
# e o espaço reservado para os automóveis.
# São 520 bytes porque estamos considerando o pior caso de um bloco:
# Cabeçalho: 4 campos × 4 bytes = 16 bytes
# Moradores: 6 × 64 bytes  = 384 bytes
# Veículos: 3 × 40 bytes = 120 bytes
# Total: 16 + 384 + 120 = 520
# ------------------------------------------------------------

.eqv OFFSET_AP_NUMERO              0  # Guarda o número do apartamento.
.eqv OFFSET_AP_QTD_MORADORES       4  # Guarda quantos moradores estão cadastrados.
.eqv OFFSET_AP_TIPO_AUTO            8  # Guarda se os veículos são carros ou motos.
.eqv OFFSET_AP_QTD_AUTOS           12  # Guarda a quantidade de veículos cadastrados.
.eqv OFFSET_AP_MORADORES           16  # Início da área reservada aos moradores.
.eqv OFFSET_AP_AUTOS              400  # Início da área reservada aos veículos.

.eqv TAM_BLOCO_AP                 520  # Tamanho total de um bloco de apartamento.

# ------------------------------------------------------------
# CONVENÇÕES DE REGISTRADORES
# ------------------------------------------------------------

# Os argumentos das funções devem ser recebidos nos registradores abaixo.
# $a0-$a3                  # Registradores usados para receber argumentos.

# O resultado principal deve ser colocado no registrador abaixo.
# $v0                      # Código de retorno ou resultado principal.

# Um segundo resultado pode ser retornado neste registrador.
# $v1                      # Resultado complementar, quando necessário.

# Estes registradores podem ser alterados por qualquer função chamada.
# $t0-$t9                  # Registradores temporários.

# Estes registradores devem ser preservados durante as chamadas.
# $s0-$s7                  # Registradores usados para estado permanente.
# $sp                      # Ponteiro da pilha, sempre restaurado pela função.
# $ra                      # Endereço de retorno, salvo quando houver chamadas internas.

# Uma função que modificar $s0-$s7 deve salvar os valores originais na pilha.
# O valor de $sp antes e depois da função deve permanecer o mesmo.


# ------------------------------------------------------------
# ASSINATURAS PÚBLICAS — MÓDULO DADOS
# ------------------------------------------------------------

# dados_inicializar()
# Prepara os 24 blocos de apartamento antes do início do programa.
# Retorna OK em $v0 quando a memória estiver pronta.

# dados_obter_ap()
# Recebe em $a0 o número do apartamento desejado.
# Retorna o status em $v0 e o endereço do bloco em $v1.

# dados_limpar_ap()
# Recebe em $a0 o número do apartamento que será zerado.
# Retorna OK ou AP_INVALIDO em $v0.


# ------------------------------------------------------------
# ASSINATURAS PÚBLICAS — MÓDULO CADASTRO
# ------------------------------------------------------------

# cadastro_adicionar_morador()
# Recebe o apartamento em $a0 e o endereço do nome em $a1.
# Retorna OK, AP_INVALIDO ou LIMITE_MORADORES_ATINGIDO em $v0.

# cadastro_remover_morador()
# Recebe o apartamento em $a0 e o endereço do nome em $a1.
# Retorna OK, AP_INVALIDO ou MORADOR_NAO_ENCONTRADO em $v0.

# cadastro_adicionar_auto()
# Recebe apartamento, tipo, modelo e placa em $a0, $a1, $a2 e $a3.
# Retorna OK, AP_INVALIDO, TIPO_INVALIDO ou LIMITE_AUTOS_ATINGIDO.

# cadastro_remover_auto()
# Recebe o apartamento em $a0 e o endereço da placa em $a1.
# Retorna OK, AP_INVALIDO ou AUTO_NAO_ENCONTRADO em $v0.

# cadastro_limpar_ap()
# Recebe o apartamento em $a0 e zera seus moradores e veículos.
# Retorna OK ou AP_INVALIDO em $v0.



# ------------------------------------------------------------
# ASSINATURAS PÚBLICAS — MÓDULO CONSULTAS
# ------------------------------------------------------------

# consulta_listar_apartamentos()
# Não recebe argumentos e percorre os 24 apartamentos.
# Retorna OK em $v0 após concluir a listagem.

# consulta_listar_moradores()
# Recebe em $a0 o número do apartamento consultado.
# Retorna OK ou AP_INVALIDO em $v0.

# consulta_listar_automoveis()
# Recebe em $a0 o número do apartamento consultado.
# Retorna OK ou AP_INVALIDO em $v0.

# consulta_buscar_morador()
# Recebe em $a0 o endereço do nome que será pesquisado.
# Retorna OK ou MORADOR_NAO_ENCONTRADO em $v0.

# consulta_buscar_auto()
# Recebe em $a0 o endereço da placa que será pesquisada.
# Retorna OK ou AUTO_NAO_ENCONTRADO em $v0.


# ------------------------------------------------------------
# ASSINATURAS PÚBLICAS — MÓDULO SHELL
# ------------------------------------------------------------

# shell_inicializar()
# Exibe a apresentação e prepara o estado inicial do terminal.
# Retorna OK em $v0 quando a inicialização terminar.

# shell_executar()
# Mantém o loop de leitura e execução dos comandos do usuário.
# Retorna OK em $v0 quando o usuário solicitar a saída.

# shell_encerrar()
# Exibe a mensagem final e encerra a interação com o usuário.
# Retorna OK em $v0.


# ------------------------------------------------------------
# ASSINATURAS PÚBLICAS — MÓDULO PERSISTÊNCIA
# ------------------------------------------------------------

# persist_inicializar()
# Prepara o arquivo ou os recursos usados pela persistência.
# Retorna OK ou ERRO_ARQUIVO em $v0.

# persist_carregar()
# Lê o estado salvo e preenche os blocos de apartamentos.
# Retorna OK ou ERRO_ARQUIVO em $v0.

# persist_salvar()
# Grava em disco o estado atual dos 24 apartamentos.
# Retorna OK ou ERRO_ARQUIVO em $v0.

# persist_encerrar()
# Fecha arquivos abertos e libera os recursos da persistência.
# Retorna OK em $v0.

# persist_recarregar()
# Recarrega os dados do arquivo sobrescrevendo a memória.
# Retorna OK ou ERRO_ARQUIVO em $v0.

# persist_formatar()
# Zera todos os apartamentos em memória sem alterar o arquivo em disco.
# Retorna OK em $v0.


# ------------------------------------------------------------
# ASSINATURAS PÚBLICAS — MÓDULO MMIO (BÔNUS +1.0 PONTO)
# ------------------------------------------------------------

# mmio_escrever_char()
# Transmite um único byte ASCII para o registrador Transmitter Data (0xFFFF000C).
# Recebe em $a0 o caractere ASCII a ser exibido.

# mmio_ler_char()
# Aguarda tecla em Receiver Control (0xFFFF0000) e lê de Receiver Data (0xFFFF0004).
# Retorna em $v0 o byte ASCII da tecla lida.

# mmio_imprimir_string()
# Imprime cadeia terminada em '\0' no Display MMIO via mmio_escrever_char.
# Recebe em $a0 o endereço da string na memória.

# mmio_imprimir_int()
# Converte número inteiro para formato decimal e imprime no Display MMIO.
# Recebe em $a0 o valor inteiro.

# mmio_ler_linha()
# Lê linha do Keyboard MMIO com eco visual e suporte a backspace ('\b' ' ' '\b').
# Recebe em $a0 o endereço do buffer e em $a1 a capacidade máxima em bytes.