# Auditoria e Status Real das Issues — Projeto 1VA Condomínio MIPS

Este documento confronta o status no GitHub das 32 issues cadastradas no repositório com o **status real do código-fonte** (`src/`) e as especificações oficiais do projeto (Prof. Vítor Coutinho - UFRPE 2026.2).

---

## 📊 Resumo Executivo

- **Total de Issues:** 32 (7 Macro-Issues / Marcos e 25 Subtarefas Técnicas)
- **Problema Detectado:** As subtarefas #8 a #32 foram criadas e marcadas como `closed` em lote pelo Kelven sem que o código correspondente estivesse finalizado ou integrado.
- **Situação Real:**
  - O código inicial (`c53da50`) entregou uma fundação modular com menu numérico antigo (`1 - Listar...`).
  - O formato exigido pelo professor é um **terminal de linha de comando (REPL)** com banner `<iniciais>-shell>> ` e opções `--<param>`.
  - As rotinas de domínio (`dados.asm`, `comandos_cadastro.asm`) e persistência (`persistencia.asm`) já possuem base sólida, tendo acabado de receber correções de cascata de remoção e manutenção do número de AP.
  - O módulo de Shell e Consultas (`shell.asm` e `comandos_consulta.asm`) precisa ser alinhado ao formato de comandos e formatação textual exigida (`infoAp` e `infoGeral`).

---

## 📋 Tabela Detalhada das Issues

| # | Título | Módulo / Responsável | Status GitHub | Status Real |
|---|---|---|---|---|
| **#1** | [Fundação / Base] Estrutura inicial do projeto, main.asm e contratos.asm | Conjunto | `CLOSED` | **Concluída com ajustes** |
| **#2** | [Módulo 1 - Domínio] Estrutura dos 24 apartamentos e comandos de cadastro | Pessoa 1 | `OPEN` | **Em Andamento (85%)** |
| **#3** | [Módulo 2 - Terminal & Consultas] Shell interativo, parser e comandos de consulta | Pessoa 2 | `OPEN` | **Pendente / Desviado (20%)** |
| **#4** | [Módulo 3 - Persistência] Gerenciamento de estado em disco e operações de arquivo | Pessoa 3 | `OPEN` | **Em Andamento (90%)** |
| **#5** | [Módulo 4 - Integração] Conexão ponta a ponta entre Shell, Domínio e Persistência | Conjunto | `OPEN` | **Pendente** |
| **#6** | [Módulo 4 - Qualidade & Testes] Bateria de testes de regras de negócio e persistência | Pessoa 3 | `OPEN` | **Pendente (10%)** |
| **#7** | [Módulo 4 - Entrega] Revisão final de código, conformidade com a Instrução 5 e README | Conjunto | `OPEN` | **Pendente** |
| **#8** | [Fundação] Setup da estrutura de diretórios, .gitignore e esqueletos dos módulos .asm | Conjunto | `CLOSED` | **Concluída** |
| **#9** | [Fundação] Especificação de contratos, constantes de erro e layout de memória | Conjunto | `CLOSED` | **Concluída** |
| **#10** | [Fundação] Implementação do main.asm minimalista com bootstrap e inicialização | Conjunto | `CLOSED` | **Concluída (Ajustada)** |
| **#11** | [Domínio] Implementação da memória dos 24 apartamentos e validação de AP | Pessoa 1 | `CLOSED` | **Concluída** |
| **#12** | [Domínio] Implementação do comando addMorador e controle de lotação (até 6) | Pessoa 1 | `CLOSED` | **Concluída** |
| **#13** | [Domínio] Implementação de rmvMorador e regra de exclusão em cascata de veículos | Pessoa 1 | `CLOSED` | **Corrigida (Cascata OK)** |
| **#14** | [Domínio] Implementação de addAuto com regras de concorrência e capacidade | Pessoa 1 | `CLOSED` | **Concluída** |
| **#15** | [Domínio] Implementação dos comandos rmvAuto e limparAp | Pessoa 1 | `CLOSED` | **Corrigida (limparAp OK)** |
| **#16** | [Shell] Loop principal do terminal com banner padronizado e leitura de linha | Pessoa 2 | `OPEN` | **Pendente de implementação** |
| **#17** | [Shell] Parser de linha de comando com suporte a delimitador de opções (" --") | Pessoa 2 | `OPEN` | **Pendente de implementação** |
| **#18** | [Consultas] Implementação de infoAp com formatação condicional e flag --all | Pessoa 2 | `OPEN` | **Pendente de implementação** |
| **#19** | [Consultas] Implementação de infoGeral com contagem e percentual de APs | Pessoa 2 | `OPEN` | **Pendente de implementação** |
| **#20** | [Shell] (Bônus MMIO) Módulo opcional de I/O via Keyboard MMIO e Display MMIO | Pessoa 2 | `OPEN` | **Pendente de implementação** |
| **#21** | [Persistência] Estrutura do arquivo de dados e syscalls no MARS | Pessoa 3 | `CLOSED` | **Concluída** |
| **#22** | [Persistência] Implementação de persist_carregar com inicialização automática | Pessoa 3 | `CLOSED` | **Concluída** |
| **#23** | [Persistência] Implementação de persist_salvar, persist_recarregar e formatar | Pessoa 3 | `CLOSED` | **Corrigida (recarregar/formatar OK)** |
| **#24** | [Integração] Conexão entre Parser do Shell e Comandos de Cadastro/Consulta | Conjunto | `OPEN` | **Pendente de implementação** |
| **#25** | [Integração] Conexão entre main.asm, persist_carregar e persistência | Conjunto | `OPEN` | **Parcial (Ajustado no main.asm)** |
| **#26** | [Integração] Auditoria e validação de preservação de registradores ($s0-$s7, $sp, $ra) | Conjunto | `OPEN` | **Pendente de auditoria** |
| **#27** | [Testes] Roteiro e bateria de testes para regras de moradores e veículos | Pessoa 3 | `OPEN` | **Pendente de implementação** |
| **#28** | [Testes] Roteiro e testes para terminal, delimitador " --" e infoAp/infoGeral | Pessoa 3 | `OPEN` | **Pendente de implementação** |
| **#29** | [Testes] Roteiro e validação do ciclo de vida de persistência | Pessoa 3 | `OPEN` | **Pendente de implementação** |
| **#30** | [Entrega] Auditoria da Instrução 5 (cabeçalhos e comentários linha a linha) | Conjunto | `OPEN` | **Em Andamento (100% nas correções)** |
| **#31** | [Entrega] Elaboração do README.md com manual dos 10 comandos | Conjunto | `OPEN` | **Pendente de atualização** |
| **#32** | [Entrega] Auditoria final de build limpo no MARS e congelamento | Conjunto | `OPEN` | **Pendente** |

---

## 🛠️ Status da Reabertura

Todas as 14 tarefas que haviam sido fechadas prematuramente foram reabertas com sucesso no repositório GitHub através do script `scripts/reabrir_issues.sh`. O repositório agora reflete com precisão o backlog pendente da equipe.

