# Auditoria e Status Real das Issues — Projeto 1VA Condomínio MIPS

Este documento confronta o status no GitHub das 32 issues cadastradas no repositório com o **status real do código-fonte** (`src/`) e as especificações oficiais do projeto (Prof. Vítor Coutinho - UFRPE 2026.2).

---

## 📊 Resumo Executivo

- **Total de Issues:** 32 (7 Macro-Issues / Marcos e 25 Subtarefas Técnicas)
- **Situação Real:**
  - **Pessoa 1 (Kelven Alves):** Módulo 1 de Domínio (`dados.asm`, `comandos_cadastro.asm`) concluído e corrigido (#2, #11 a #15 `CLOSED`).
  - **Pessoa 2 (João Pedro Araújo):** Módulo 2 de Shell, Consultas e Bônus MMIO (`shell.asm`, `comandos_consulta.asm`, `mmio.asm`) concluído via PR #34 (#3, #16 a #20, #24, #25 `CLOSED`).
  - **Persistência & Integração:** Persistência em disco (`persistencia.asm`) e integração ponta a ponta (`main.asm`) concluídas (#4 e #5 `CLOSED`).
  - **Pessoa 3 (Erik):** Backlog restante exclusivo de Testes, Auditoria de Registradores, Instrução 5 e Congelamento de Entrega (#6, #7, #26 a #32 `OPEN`).

---

## 📋 Tabela Detalhada das Issues

| # | Título | Módulo / Responsável | Status GitHub | Status Real |
|---|---|---|---|---|
| **#1** | [Fundação / Base] Estrutura inicial do projeto, main.asm e contratos.asm | Conjunto | `CLOSED` | **Concluída com ajustes** |
| **#2** | [Módulo 1 - Domínio] Estrutura dos 24 apartamentos e comandos de cadastro | Kelven | `CLOSED` | **Concluída e Corrigida** |
| **#3** | [Módulo 2 - Terminal & Consultas] Shell interativo, parser e comandos de consulta | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#4** | [Módulo 3 - Persistência] Gerenciamento de estado em disco e operações de arquivo | Base | `CLOSED` | **Concluída e Integrada** |
| **#5** | [Módulo 4 - Integração] Conexão ponta a ponta entre Shell, Domínio e Persistência | Conjunto | `CLOSED` | **Concluída e Validada** |
| **#6** | [Módulo 4 - Qualidade & Testes] Bateria de testes de regras de negócio e persistência | Erik | `OPEN` | **Aguardando execução de testes** |
| **#7** | [Módulo 4 - Entrega] Revisão final de código, conformidade com a Instrução 5 e README | Erik / Conjunto | `OPEN` | **Aguardando congelamento final** |
| **#8** | [Fundação] Setup da estrutura de diretórios, .gitignore e esqueletos dos módulos .asm | Conjunto | `CLOSED` | **Concluída** |
| **#9** | [Fundação] Especificação de contratos, constantes de erro e layout de memória | Conjunto | `CLOSED` | **Concluída** |
| **#10** | [Fundação] Implementação do main.asm minimalista com bootstrap e inicialização | Conjunto | `CLOSED` | **Concluída** |
| **#11** | [Domínio] Implementação da memória dos 24 apartamentos e validação de AP | Kelven | `CLOSED` | **Concluída** |
| **#12** | [Domínio] Implementação do comando addMorador e controle de lotação (até 6) | Kelven | `CLOSED` | **Concluída** |
| **#13** | [Domínio] Implementação de rmvMorador e regra de exclusão em cascata de veículos | Kelven | `CLOSED` | **Concluída (Cascata OK)** |
| **#14** | [Domínio] Implementação de addAuto com regras de concorrência e capacidade | Kelven | `CLOSED` | **Concluída** |
| **#15** | [Domínio] Implementação dos comandos rmvAuto e limparAp | Kelven | `CLOSED` | **Concluída (limparAp OK)** |
| **#16** | [Shell] Loop principal do terminal com banner padronizado e leitura de linha | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#17** | [Shell] Parser de linha de comando com suporte a delimitador de opções (" --") | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#18** | [Consultas] Implementação de infoAp com formatação condicional e flag --all | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#19** | [Consultas] Implementação de infoGeral com contagem e percentual de APs | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#20** | [Shell] (Bônus MMIO) Módulo opcional de I/O via Keyboard MMIO e Display MMIO | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#21** | [Persistência] Estrutura do arquivo de dados e syscalls no MARS | Base | `CLOSED` | **Concluída** |
| **#22** | [Persistência] Implementação de persist_carregar com inicialização automática | Base | `CLOSED` | **Concluída** |
| **#23** | [Persistência] Implementação de persist_salvar, persist_recarregar e formatar | Base | `CLOSED` | **Concluída (recarregar/formatar OK)** |
| **#24** | [Integração] Conexão entre Parser do Shell e Comandos de Cadastro/Consulta | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#25** | [Integração] Conexão entre main.asm, persist_carregar e persistência | João Pedro | `CLOSED` | **Concluída (PR #34)** |
| **#26** | [Integração] Auditoria e validação de preservação de registradores ($s0-$s7, $sp, $ra) | Erik | `OPEN` | **Pendente de auditoria de testes** |
| **#27** | [Testes] Roteiro e bateria de testes para regras de moradores e veículos | Erik | `OPEN` | **Pendente de execução** |
| **#28** | [Testes] Roteiro e testes para terminal, delimitador " --" e infoAp/infoGeral | Erik | `OPEN` | **Pendente de execução** |
| **#29** | [Testes] Roteiro e validação do ciclo de vida de persistência | Erik | `OPEN` | **Pendente de execução** |
| **#30** | [Entrega] Auditoria da Instrução 5 (cabeçalhos e comentários linha a linha) | Erik / Conjunto | `OPEN` | **Pendente de revisão final** |
| **#31** | [Entrega] Elaboração do README.md com manual dos 10 comandos | Erik / Conjunto | `OPEN` | **Pendente de finalização** |
| **#32** | [Entrega] Auditoria final de build limpo no MARS e congelamento | Erik / Conjunto | `OPEN` | **Pendente de congelamento** |

---

## 🛠️ Status da Reabertura

Todas as 14 tarefas que haviam sido fechadas prematuramente foram reabertas com sucesso no repositório GitHub através do script `scripts/reabrir_issues.sh`. O repositório agora reflete com precisão o backlog pendente da equipe.

