# Catálogo de Casos de Teste — Sistema do Condomínio MIPS

Este documento detalha o conjunto oficial de casos de teste para validação no simulador **MARS**, cobrindo o funcionamento do interpretador de comandos (shell), as regras de negócio de moradores e veículos, a exclusão em cascata e o ciclo de persistência.

---

## 📋 Matriz de Rastreabilidade de Testes

| Caso de Teste | Requisito / Comando | Objetivo | Resultado Esperado |
| :--- | :--- | :--- | :--- |
| **CT-001** | R4, R5, R7 | Validação do banner e comando inexistente | Exibir `Comando invalido` sem quebrar o loop |
| **CT-002** | R1, cmd_1 | Inclusão de moradores até o limite máximo (6) | Aceitar até 6 nomes; o 7º deve falhar com `Falha: AP com numero max de moradores` |
| **CT-003** | R1, cmd_1 | Validação de número de apartamento inválido | Exibir `Falha: AP invalido` para AP fora de 101..1202 |
| **CT-004** | R2, cmd_3 | Regra de exclusividade de veículos (carro vs moto) | Cadastrar 1 carro; tentar cadastrar moto deve retornar `Falha: AP com numero max de automóveis` |
| **CT-005** | R2, cmd_3 | Capacidade de motos (até limite) e tipo inválido | Aceitar motos e rejeitar tipo com `Falha: tipo invalido` |
| **CT-006** | R2, cmd_2 | Efeito cascata da remoção do último morador | Ao remover o morador que zera o AP, os veículos são apagados compulsoriamente |
| **CT-007** | cmd_4 | Remoção de veículo por placa | Remover veículo cadastrado com sucesso; placa inexistente retorna `Falha: automóvel nao encontrado` |
| **CT-008** | cmd_5 | Limpeza completa com `limparAp` | Zera moradores e veículos, mantendo o número do AP |
| **CT-009** | cmd_6, R6 | Consultas `infoAp` e flag `--all` | Layout condicional: AP vazio exibe `Apartamento vazio`; ocupado exibe moradores e veículos |
| **CT-010** | cmd_7, R6 | Panorama geral com `infoGeral` | Total de 24 apartamentos e porcentagens exatas |
| **CT-011** | R3, cmd_8, 9, 10 | Ciclo de vida de persistência em disco | `salvar` grava em disco; `formatar` zera apenas RAM; `recarregar` restaura arquivo anterior |

---

## 🧪 Detalhamento dos Cenários

### CT-001 — Prompt e Comando Inválido
- **Entrada:** `ajuda` / `teste --101`
- **Saída Esperada:**
  ```text
  Comando invalido
  ```

### CT-002 — Limite de Moradores
- **Entrada:**
  ```text
  addMorador --201 --Morador Um
  addMorador --201 --Morador Dois
  addMorador --201 --Morador Tres
  addMorador --201 --Morador Quatro
  addMorador --201 --Morador Cinco
  addMorador --201 --Morador Seis
  addMorador --201 --Morador Sete
  ```
- **Saída Esperada:**
  Primeiros 6 aceitos silenciosamente; na 7ª tentativa:
  ```text
  Falha: AP com numero max de moradores
  ```

### CT-004 — Incompatibilidade Carro vs Moto
- **Entrada:**
  ```text
  addMorador --301 --Morador Carro
  addAuto --301 --c --Fiat Uno --ABC1234
  addAuto --301 --m --Yamaha --XYZ9999
  ```
- **Saída Esperada:**
  ```text
  Falha: AP com numero max de automóveis
  ```

### CT-006 — Remoção do Último Morador e Cascata de Veículos
- **Entrada:**
  ```text
  addMorador --401 --Morador Unico
  addAuto --401 --c --Gol --GOL1000
  infoAp --401
  rmvMorador --401 --Morador Unico
  infoAp --401
  ```
- **Saída Esperada:**
  Primeiro `infoAp`: exibe Moradores (Morador Unico) e Carro (Gol / GOL1000).  
  Após `rmvMorador`: o segundo `infoAp` deve exibir estritamente:
  ```text
  AP: 401
  Apartamento vazio
  ```

### CT-011 — Ciclo de Persistência
- **Entrada:**
  1. Cadastrar AP 501 com morador.
  2. Executar `salvar`.
  3. Executar `formatar` (memória zerada).
  4. Executar `infoAp --501` (mostra `Apartamento vazio`).
  5. Executar `recarregar`.
  6. Executar `infoAp --501` (morador reaparece).
