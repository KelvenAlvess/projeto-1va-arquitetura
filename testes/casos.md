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
| **CT-013** | R4, R5, R6, cmd_1, 3, 5, 6, 7 | Validação de terminal, delimitador ` --` e consultas escalonadas | Exercitar comandos inválidos, nomes compostos com espaços, `infoAp` vazio/ocupado/`--all` e `infoGeral` em 5 níveis de ocupação (0%, 25%, 50%, 75%, 100%) |
| **CT-014** | R3, cmd_8, 9, 10 | Ciclo completo de persistência multi-processo com reinicializações frias | Boot a frio sem arquivo, gravação permanente com `salvar`, restauração automática em novo processo, descarte com `recarregar`, volatilidade de `formatar` na RAM e purga com `formatar` + `salvar` |

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
  10. **Preservação e Comprovação Individual dos Demais 23 Apartamentos:**
      - Executa `infoAp --all` logo após as operações no AP 201: valida que os sentinelas (AP 101, AP 301, AP 1202) e o AP 201 estão nos estados exatos esperados, e comprova individualmente que todos os outros 20 apartamentos permanecem inalterados e vazios.
      - Limpa os apartamentos remanescentes (`limparAp` em 101, 301 e 1202).
      - Executa `infoGeral` confirmando 0 não vazios (0%) e 24 vazios (100%).
      - Executa `infoAp --all` final comprovando que todos os 24 apartamentos estão no estado `Apartamento vazio`.

### CT-013 — Validação de Terminal, Delimitador e Ocupação Escalonada
- **Arquivos:** `src/testes/teste_terminal_consultas.txt`, `testes/entradas/teste_terminal_consultas.txt`, `testes/esperados/saida_teste_terminal_consultas.txt`
- **Comando de Execução:** `powershell -File scripts/executar_testes.ps1 -Teste terminal`
- **Roteiro e Critérios:**
  1. **Comandos Desconhecidos e Erro de Sintaxe:** `sair_invalido`, `ajuda`, `info`, `teste --101`, `addMorador` sem opções produzem rigorosamente `Comando invalido`.
  2. **Delimitador `" --"` e Nomes Compostos com Espaços:** `addMorador --101 --Maria Antonieta de Albuquerque` e `addAuto --101 --c --Chevrolet Onix Plus Sedan --ABC1D23`.
  3. **Formatação Condicional de `infoAp`:**
     - Vazio: `infoAp --102` produz 2 linhas exatas do PDF (`AP: 102` e `Apartamento vazio`).
     - Ocupado: `infoAp --101` exibe seções `AP: 101`, `Moradores:` e `Carro:` sem seções de moto.
  4. **Cálculo Percentual de `infoGeral` em 5 Níveis de Ocupação:**
     - 0%: `Nao vazios: 0 (0%)`, `Vazios: 24 (100%)`.
     - 25%: AP 101 já ocupado + 5 novos APs (102, 201, 202, 301, 302) = 6 ocupados $\rightarrow$ `Nao vazios: 6 (25%)`, `Vazios: 18 (75%)`.
     - 50%: +6 APs (401, 402, 501, 502, 601, 602) = 12 ocupados $\rightarrow$ `Nao vazios: 12 (50%)`, `Vazios: 12 (50%)`.
     - 75%: +6 APs (701, 702, 801, 802, 901, 902) = 18 ocupados $\rightarrow$ `Nao vazios: 18 (75%)`, `Vazios: 6 (25%)`.
     - 100%: +6 APs (1001, 1002, 1101, 1102, 1201, 1202) = 24 ocupados $\rightarrow$ `Nao vazios: 24 (100%)`, `Vazios: 0 (0%)`.
  5. **Varredura Completa `infoAp --all`:** Exibe ordenadamente todos os 24 apartamentos com seus moradores.
  6. **Reset e Encerramento:** `formatar` retorna a 0% e `sair` finaliza.

### CT-014 — Ciclo Completo de Persistência Multi-Processo
- **Arquivos:** `src/testes/teste_persistencia_ciclo.txt`, `testes/entradas/teste_persistencia_ciclo.txt`, `testes/esperados/saida_teste_persistencia_ciclo.txt`
- **Comando de Execução:** `powershell -File scripts/executar_testes.ps1 -Teste persistencia`
- **Fases Executadas com Múltiplas Instâncias do MARS 4.5:**
  1. **Fase 1 (Boot Limpo sem Arquivo):** Inicia sem `condominio.dat`; `infoGeral` comprova inicialização vazia; cadastra dados no AP 101 e AP 201; executa `salvar` e encerra com `sair`.
  2. **Fase 2 (Boot Frio e Descarte Volátil):** Nova instância do MARS; `infoAp --101` e `infoAp --201` comprovam restauração automática; adiciona morador volátil no AP 301; executa `recarregar` comprovando descarte de alterações não salvas; executa `formatar` (RAM vazia); encerra com `sair` sem salvar.
  3. **Fase 3 (Comprovação de Integridade em Disco):** Nova instância do MARS; `infoAp --101` e `infoAp --201` comprovam que o `formatar` da Fase 2 foi estritamente volátil na RAM e NÃO apagou o disco; executa `formatar` seguido de `salvar` e `sair`.
  4. **Fase 4 (Comprovação de Purga em Disco):** Nova instância do MARS; `infoGeral` e `infoAp --all` comprovam que todos os 24 apartamentos estão vazios após a gravação explícita da limpeza.
