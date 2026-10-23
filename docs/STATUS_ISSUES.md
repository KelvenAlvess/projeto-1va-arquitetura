# Auditoria e Status Final das Issues — Projeto 1VA Condomínio MIPS

Este documento consolida o fechamento oficial e a conformidade técnica das **32 issues** do repositório (7 Macro-Issues / Marcos e 25 Subtarefas Técnicas) em relação ao código-fonte final (`src/`), aos scripts de automação (`scripts/`) e aos critérios da disciplina (Prof. Vítor A Coutinho - UFRPE 2026.2).

---

## 📊 Resumo Executivo Final

- **Total de Issues:** 32 (100% CONCLUÍDAS E VERIFICADAS)
- **Status Geral:** Sistema homologado no simulador **MARS 4.5**, com 5 baterias de testes de regressão automatizadas, auditoria de 45/45 procedimentos conformes com a ABI MIPS O32, documentação integral no `README.md` e conformidade rigorosa com a Instrução 5 (cabeçalhos institucionais e 100% de comentários linha a linha).
- **Recurso Bônus (+1.0 Ponto):** Driver bare-metal de Keyboard e Display MMIO (`src/mmio.asm`) totalmente funcional e integrado ao shell.

---

## 📋 Tabela Oficial de Rastreabilidade das 32 Issues

| # | Título | Módulo / Responsável | Status Final | Evidência de Conclusão |
|---|---|---|:---:|---|
| **#1** | [Fundação / Base] Estrutura inicial do projeto, main.asm e contratos.asm | Conjunto | **CONCLUÍDA** | `main.asm` agregador modular e `contratos.asm` com constantes |
| **#2** | [Módulo 1 - Domínio] Estrutura dos 24 apartamentos e comandos de cadastro | Pessoa 1 | **CONCLUÍDA** | `dados.asm` e `comandos_cadastro.asm` validados |
| **#3** | [Módulo 2 - Terminal & Consultas] Shell interativo, parser e comandos de consulta | Pessoa 2 | **CONCLUÍDA** | REPL `KJP-shell>> `, parser `" --"`, `infoAp` e `infoGeral` |
| **#4** | [Módulo 3 - Persistência] Gerenciamento de estado em disco e operações de arquivo | Pessoa 3 | **CONCLUÍDA** | I/O binário de 12.480 bytes em `condominio.dat` |
| **#5** | [Módulo 4 - Integração] Conexão ponta a ponta entre Shell, Domínio e Persistência | Conjunto | **CONCLUÍDA** | Fluxo integrado no bootstrap e despacho |
| **#6** | [Módulo 4 - Qualidade & Testes] Bateria de testes de regras, casos de borda e persistência | Pessoa 3 | **CONCLUÍDA** | 5 suítes automatizadas via `executar_testes.ps1` com 100% match |
| **#7** | [Módulo 4 - Entrega] Revisão final de código, conformidade com a Instrução 5 e README | Conjunto | **CONCLUÍDA** | Instrução 5 cumprida em 100% das linhas e README completo |
| **#8** | [Fundação] Setup da estrutura de diretórios, .gitignore e esqueletos dos módulos .asm | Conjunto | **CONCLUÍDA** | Estrutura limpa, padronizada e sem código morto |
| **#9** | [Fundação] Especificação de contratos, constantes de erro e layout de memória | Conjunto | **CONCLUÍDA** | `contratos.asm` e documentação de arquitetura |
| **#10** | [Fundação] Implementação do main.asm minimalista com bootstrap e inicialização | Conjunto | **CONCLUÍDA** | Alinhamento de pilha O32, boot automático e encerramento limpo |
| **#11** | [Domínio] Implementação da memória dos 24 apartamentos e validação de AP | Pessoa 1 | **CONCLUÍDA** | Mapeamento $\mathcal{O}(1)$ e validação estrita de 101 a 1202 |
| **#12** | [Domínio] Implementação do comando addMorador e controle de lotação (até 6) | Pessoa 1 | **CONCLUÍDA** | Testado até 6 nomes compostos e rejeição do 7º morador |
| **#13** | [Domínio] Implementação de rmvMorador e regra de exclusão em cascata de veículos | Pessoa 1 | **CONCLUÍDA** | Deslocamento de registros e purga compulsória de veículos |
| **#14** | [Domínio] Implementação de addAuto com regras de concorrência e capacidade | Pessoa 1 | **CONCLUÍDA** | 1 carro ou até 3 motos; rejeição estrita de mistura |
| **#15** | [Domínio] Implementação dos comandos rmvAuto e limparAp | Pessoa 1 | **CONCLUÍDA** | Remoção por placa e limpeza com preservação do número do AP |
| **#16** | [Shell] Loop principal do terminal com banner padronizado e leitura de linha | Pessoa 2 | **CONCLUÍDA** | Banner oficial `KJP-shell>> ` e suporte a syscall e MMIO |
| **#17** | [Shell] Parser de linha de comando com suporte a delimitador de opções (" --") | Pessoa 2 | **CONCLUÍDA** | Parser in-place até 4 opções preservando espaços internos |
| **#18** | [Consultas] Implementação de infoAp com formatação condicional e flag --all | Pessoa 2 | **CONCLUÍDA** | Formatação exata do PDF (vazio/ocupado) e ordenação 101 a 1202 |
| **#19** | [Consultas] Implementação de infoGeral com contagem e percentual de APs | Pessoa 2 | **CONCLUÍDA** | Testado e aprovado em 0%, 25%, 50%, 75% e 100% |
| **#20** | [Shell] (Bônus MMIO) Módulo opcional de I/O via Keyboard MMIO e Display MMIO | Pessoa 2 | **CONCLUÍDA** | `src/mmio.asm` bare-metal com polling e backspace visual |
| **#21** | [Persistência] Estrutura do arquivo de dados e syscalls no MARS | Pessoa 3 | **CONCLUÍDA** | Manipulação robusta de `condominio.dat` via syscalls 13, 14, 15, 16 |
| **#22** | [Persistência] Implementação de persist_carregar com inicialização automática | Pessoa 3 | **CONCLUÍDA** | Fallback gracioso quando arquivo ausente e carga automática |
| **#23** | [Persistência] Implementação de persist_salvar, persist_recarregar e formatar | Pessoa 3 | **CONCLUÍDA** | Descarte volátil, memória limpa e gravação definitiva |
| **#24** | [Integração] Conexão entre Parser do Shell e Comandos de Cadastro/Consulta | Conjunto | **CONCLUÍDA** | Despacho com mensagens literais exatas do professor |
| **#25** | [Integração] Conexão entre main.asm, persist_carregar e persistência | Conjunto | **CONCLUÍDA** | Bootstrap automático no startup |
| **#26** | [Integração] Auditoria e validação de preservação de registradores ($s0-$s7, $sp, $ra) | Conjunto | **CONCLUÍDA** | 45/45 procedimentos conformes em `auditar_registradores.ps1` |
| **#27** | [Testes] Roteiro e bateria de testes para regras de moradores, veículos e cascata | Pessoa 3 | **CONCLUÍDA** | CT-012 validado com 100% match (`teste_dominio_regras.txt`) |
| **#28** | [Testes] Roteiro e testes para terminal, delimitador " --" e infoAp/infoGeral | Pessoa 3 | **CONCLUÍDA** | CT-013 validado com 100% match (`teste_terminal_consultas.txt`) |
| **#29** | [Testes] Roteiro e validação do ciclo de vida de persistência | Pessoa 3 | **CONCLUÍDA** | CT-014 validado com 100% match em 4 fases (`teste_persistencia_ciclo.txt`) |
| **#30** | [Entrega] Auditoria da Instrução 5 (cabeçalhos e comentários linha a linha) | Conjunto | **CONCLUÍDA** | Cabeçalho institucional nos 8 arquivos e 100% de linhas comentadas |
| **#31** | [Entrega] Elaboração do README.md com manual dos 10 comandos | Conjunto | **CONCLUÍDA** | Manual completo, arquitetura, bônus MMIO e guia do MARS |
| **#32** | [Entrega] Auditoria final de build limpo no MARS e congelamento | Conjunto | **CONCLUÍDA** | Teste em clone limpo aprovado e congelamento para entrega |
