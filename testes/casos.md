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
| **CT-012** | R1, R2, R6, cmd_1 a 7 | Bateria exaustiva de regras de domínio, limites, cascata e integridade | Exercitar lotação de 6 moradores compostos, 7º rejeitado, exclusividade carro/moto, 3 motos, tipo inválido, remoção inexistente, purga compulsória de veículos e não-corrupção dos demais 23 APs |

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

### CT-012 — Bateria Exaustiva de Regras de Domínio e Limites
- **Arquivos:** `src/testes/teste_dominio_regras.txt`, `testes/entradas/teste_dominio_regras.txt`, `testes/esperados/saida_teste_dominio_regras.txt`
- **Comando de Execução:** `powershell -File scripts/executar_testes.ps1 -Teste dominio`
- **Entrada e Sequência Validada:**
  1. **Isolamento e Sentinelas:** Inicializa com `formatar`, valida `infoGeral` (24 vazios, 100%), cadastra sentinelas em AP 101 (morador + carro) e AP 1202 (morador).
  2. **Lotação Máxima (6) com Nomes Compostos:** Cadastra 6 moradores no AP 201 (`Carlos Eduardo Silva`, `Maria Fernanda Oliveira`, `Joao Pedro Santos`, `Ana Paula Souza`, `Lucas Gabriel Pereira`, `Beatriz Helena Lima`).
  3. **Tentativa do 7º Morador:** `addMorador --201 --Setimo Morador Excedente` retorna `Falha: AP com numero max de moradores`.
  4. **Remoção de Morador Inexistente:** `rmvMorador --201 --Morador Fantasma Inexistente` retorna `Falha: morador nao encontrado`.
  5. **Regras de Carro e Incompatibilidade:**
     - Cadastra carro `Toyota Corolla / ABC1234` no AP 201 com sucesso.
     - Tenta cadastrar 2º carro: retorna `Falha: AP com numero max de automóveis`.
     - Tenta cadastrar moto: retorna `Falha: AP com numero max de automóveis`.
  6. **Tipo Inválido:** `addAuto --201 --x --Veiculo Invalido --INV0000` retorna `Falha: tipo invalido`.
  7. **Remoção de Veículo Inexistente:** `rmvAuto --201 --PLK9999` retorna `Falha: automóvel nao encontrado`.
  8. **Regras de Motos e Capacidade (AP 301):**
     - Cadastra 3 motos (`MOT1001`, `MOT1002`, `MOT1003`) com sucesso.
     - Tenta cadastrar 4ª moto: retorna `Falha: AP com numero max de automóveis`.
     - Tenta cadastrar carro onde há motos: retorna `Falha: AP com numero max de automóveis`.
     - Remove moto `MOT1002`: sucesso comprovado via `infoAp --301`.
  9. **Esvaziamento Compulsório de Veículos:**
     - Remove 5 moradores do AP 201 (permanece 1 morador e o carro).
     - Remove o último morador (`Beatriz Helena Lima`).
     - `infoAp --201` comprova status `Apartamento vazio`.
     - `rmvAuto --201 --ABC1234` retorna `Falha: automóvel nao encontrado`, provando a purga compulsória de veículos.
  10. **Preservação dos Demais Apartamentos:**
      - Verifica AP 101, AP 1202 e AP 301 totalmente íntegros.
      - Limpa os apartamentos e valida com `infoGeral` o retorno para 24 vazios (100%).
