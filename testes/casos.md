# Casos de teste

Os testes serão executados manualmente no MARS nesta primeira etapa. Cada caso deve registrar:

- objetivo;
- entrada digitada ou arquivo usado;
- saída observada;
- saída esperada;
- resultado (`OK` ou `FALHA`).

## CT-001 — Inicialização

- Objetivo: verificar se o programa monta e inicia.
- Entrada: nenhuma.
- Esperado: exibir `=== Condominio MIPS ===` e encerrar sem exceção.

## CT-002 — Opção inválida

- Objetivo: verificar a validação do menu.
- Entrada: será definida quando o menu for implementado.
- Esperado: exibir uma mensagem de opção inválida e continuar executando.

## CT-003 — Cadastro válido

- Objetivo: cadastrar uma unidade e consultar o registro.
- Entrada: será definida após o layout dos registros.
- Esperado: cadastro persistido em memória e exibido na consulta.

## CT-004 — Capacidade máxima

- Objetivo: garantir que o limite de unidades/moradores seja respeitado.
- Entrada: tentar inserir um registro após atingir o limite.
- Esperado: retornar `STATUS_CAPACIDADE` sem sobrescrever memória.

