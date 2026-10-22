# Constantes e convenções compartilhadas pelo projeto.
# Este arquivo não deve conter código executável.

.eqv STATUS_OK             0
.eqv STATUS_ERRO           1
.eqv STATUS_NAO_ENCONTRADO 2
.eqv STATUS_CAPACIDADE     3
.eqv STATUS_ENTRADA        4

.eqv MAX_UNIDADES          64
.eqv MAX_MORADORES         256
.eqv TAM_NOME              64
.eqv TAM_LINHA             128
.eqv TAM_CAMPO             32

# Syscalls usados pelo projeto no MARS.
.eqv SYS_PRINT_INT         1
.eqv SYS_PRINT_STRING      4
.eqv SYS_READ_INT          5
.eqv SYS_READ_STRING       8
.eqv SYS_SBRK              9
.eqv SYS_EXIT              10
.eqv SYS_OPEN              13
.eqv SYS_READ              14
.eqv SYS_WRITE             15
.eqv SYS_CLOSE             16
.eqv SYS_EXIT2             17

