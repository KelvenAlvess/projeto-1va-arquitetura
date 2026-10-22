# Rotinas de cadastro.

.text

# cadastro_inicializar()
# Prepara as estruturas de cadastro. Retorno: $v0 = STATUS_OK.
cadastro_inicializar:
    li      $v0, STATUS_OK
    jr      $ra

# cadastro_adicionar_unidade()
# TODO: validar entrada e inserir uma unidade.
# Retorno atual: STATUS_OK (stub).
cadastro_adicionar_unidade:
    li      $v0, STATUS_OK
    jr      $ra

# cadastro_adicionar_morador()
# TODO: validar entrada e inserir um morador.
# Retorno atual: STATUS_OK (stub).
cadastro_adicionar_morador:
    li      $v0, STATUS_OK
    jr      $ra

