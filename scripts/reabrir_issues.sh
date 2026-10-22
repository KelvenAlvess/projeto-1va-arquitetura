#!/bin/bash
# Script para reabrir no GitHub as issues que foram fechadas prematuramente
# Requer: gh autenticado (rode 'gh auth login' antes se necessário)

REPO="KelvenAlvess/projeto-1va-arquitetura"

ISSUES_PARA_REABRIR=(
    16 # [Shell] Loop principal com banner
    17 # [Shell] Parser com delimitador " --"
    18 # [Consultas] infoAp e flag --all
    19 # [Consultas] infoGeral com porcentagens
    20 # [Shell] Bônus MMIO
    24 # [Integração] Conexão Parser -> Comandos
    25 # [Integração] Conexão main -> persistência
    26 # [Integração] Auditoria de registradores MIPS
    27 # [Testes] Roteiro e bateria de testes de domínio
    28 # [Testes] Roteiro de testes de terminal e consultas
    29 # [Testes] Roteiro de testes de persistência
    30 # [Entrega] Auditoria Instrução 5 (100% comentários)
    31 # [Entrega] README com manual dos 10 comandos
    32 # [Entrega] Auditoria final de build e congelamento
)

echo "=== Verificando autenticação do GitHub CLI (gh) ==="
if ! gh auth status >/dev/null 2>&1; then
    echo "Erro: GitHub CLI não está autenticado."
    echo "Por favor, execute: gh auth login"
    exit 1
fi

echo "=== Reabrindo issues pendentes no repositório $REPO ==="
for num in "${ISSUES_PARA_REABRIR[@]}"; do
    echo "Reabrindo issue #$num..."
    gh issue reopen "$num" -R "$REPO"
done

echo "=== Concluído! Todas as tarefas pendentes foram reabertas no GitHub. ==="
