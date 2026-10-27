# Sistema de Gerenciamento de Condomínio — Assembly MIPS

[![MARS 4.5](https://img.shields.io/badge/Simulator-MARS%204.5-blue.svg)](https://courses.missouristate.edu/kenvollmar/mars/)
[![Architecture](https://img.shields.io/badge/Architecture-MIPS32%20O32-orange.svg)](#)
[![Status](https://img.shields.io/badge/Status-100%25%20Concluído-brightgreen.svg)](#)

Projeto prático da 1ª Verificação de Aprendizagem (1VA) da disciplina de **Arquitetura e Organização de Computadores** da Universidade Federal Rural de Pernambuco (UFRPE - 2026.2), ministrada pelo **Prof. Vítor A Coutinho**.

O sistema consiste em um simulador completo de administração de condomínio residencial (12 andares, 24 apartamentos) implementado em Assembly MIPS puro para execução no simulador **MARS 4.5**, integrando interpretador de comandos (REPL), regras de negócio de domínio, persistência binária em disco e driver de hardware bare-metal via **Memory-Mapped I/O (MMIO)**.

---

## 👥 Equipe e Atribuições

O projeto foi concebido e implementado de forma colaborativa e modular pelos integrantes do grupo:

| Integrante | Módulo Principal | Arquivos e Responsabilidades |
| :--- | :--- | :--- |
| **Kelven Alves** (Pessoa 1) | **Módulo 1 — Domínio** | `src/dados.asm`, `src/comandos_cadastro.asm`<br/>• Tabela de 12.480 bytes dos 24 apartamentos e algoritmo indexado $\mathcal{O}(1)$.<br/>• Regras de moradores (1 a 6) e veículos (carro vs moto).<br/>• Efeito cascata: exclusão compulsória de veículos ao remover último morador. |
| **João Pedro Araújo** (Pessoa 2) | **Módulo 2 — Terminal & Consultas** | `src/shell.asm`, `src/comandos_consulta.asm`, `src/mmio.asm`<br/>• Loop interativo REPL com banner oficial `KJP-shell>> `.<br/>• Parser in-place com suporte a delimitador de opções estrito (`" --"`).<br/>• Consultas `infoAp` (individual e `--all`) e panorama `infoGeral` com porcentagens.<br/>• **Bônus MMIO (+1.0 ponto)**: driver de teclado e display direto em hardware. |
| **Erik Vinicius Gomes de Lima** (Pessoa 3) | **Módulo 3 — Persistência & Qualidade** | `src/persistencia.asm`, `scripts/`, `testes/`<br/>• Gerenciamento binário de `condominio.dat` via syscalls MARS (abertura, leitura, escrita).<br/>• Ciclo de persistência: boot automático frio, `salvar`, `recarregar` e `formatar`.<br/>• Auditoria estrutural e linter de convenções ABI MIPS O32 (`auditar_registradores.ps1`).<br/>• Automação de 5 suítes de testes de regressão isoladas (`executar_testes.ps1`). |

---

## 📁 Estrutura do Repositório

```text
projeto-1va-arquitetura/
├── README.md                           # Documentação oficial do projeto
├── .gitignore                          # Regras de exclusão Git (artefatos e temporários)
├── src/                                # Código-fonte Assembly MIPS (8 módulos ativos)
│   ├── main.asm                        # Ponto de entrada, bootstrap e includes
│   ├── contratos.asm                   # Constantes, limites e códigos de retorno compartilhados
│   ├── dados.asm                       # Tabela de memória de 12.480 bytes e indexação matemática
│   ├── comandos_cadastro.asm           # Regras de negócio de moradores, veículos e cascata
│   ├── comandos_consulta.asm           # Formatação de consultas infoAp e panorama infoGeral
│   ├── persistencia.asm                # Syscalls de disco (abertura, leitura, escrita)
│   ├── shell.asm                       # Interpretador de comandos (REPL) e parser " --"
│   ├── mmio.asm                        # Driver de Keyboard e Display MMIO (Bônus +1.0)
│   └── testes/                         # Roteiros oficiais de teste e gabaritos esperados
│       ├── teste_dominio_regras.txt    # Suíte de regras de domínio (Issue #27 / CT-012)
│       ├── teste_terminal_consultas.txt# Suíte de terminal e consultas (Issue #28 / CT-013)
│       ├── teste_persistencia_ciclo.txt# Suíte do ciclo de persistência (Issue #29 / CT-014)
│       └── *.txt (gabaritos de saída)  # Saídas textuais esperadas oficiais
├── testes/                             # Catálogo de testes e suítes do pipeline
│   ├── casos.md                        # Matriz completa de rastreabilidade (CT-001 a CT-014)
│   ├── entradas/                       # Scripts de entrada (.txt) para o runner automatizado
│   └── esperados/                      # Gabaritos de referência para validação byte a byte
├── scripts/                            # Automações de testes e auditoria em PowerShell
│   ├── executar_testes.ps1             # Runner automatizado isolado das 5 baterias de teste
│   └── auditar_registradores.ps1       # Linter estático estrutural de ABI MIPS O32
└── docs/                               # Documentações técnicas e auditorias
    ├── ARQUITETURA_BASE_E_DOMINIO.md   # Especificação técnica detalhada de memória e algoritmos
    └── STATUS_ISSUES.md                # Relatório executivo de status das 32 issues do projeto
```

---

## 🚀 Guia de Execução no MARS 4.5

### 1. Execução Interativa via Simulador Gráfico (GUI)

1. Baixe o simulador [MARS 4.5](https://courses.missouristate.edu/kenvollmar/mars/) (`Mars4_5.jar`).
2. Abra o MARS:
   ```cmd
   java -jar Mars4_5.jar
   ```
3. No menu **Settings**:
   - Certifique-se de que **Memory Configuration** está em **Default** (memória padrão).
   - **IMPORTANTE:** Deixe a opção **Assemble all files in directory** **DESMARCADA**. O projeto utiliza `main.asm` como agregador modular através de diretivas `.include`.
4. Abra o arquivo agregador: **File > Open** $\rightarrow$ `src/main.asm`.
5. Monte o programa: **Run > Assemble** (ou atalho `F3`).
6. Execute o programa: **Run > Go** (ou atalho `F5`).
7. O terminal exibirá o prompt oficial:
   ```text
   KJP-shell>> 
   ```
   Agora você pode digitar qualquer um dos 10 comandos oficiais do sistema!

---

### 2. Execução Automatizada da Bateria de Testes (PowerShell)

O repositório conta com um runner automatizado que executa os testes no MARS 4.5 em ambiente estritamente isolado (fazendo backup de arquivos pré-existentes, rodando com codificação UTF-8 e comparando a saída com os gabaritos esperados byte a byte):

```powershell
# Executa todas as 5 baterias de teste oficiais:
powershell -ExecutionPolicy Bypass -File scripts/executar_testes.ps1 -Teste todos

# Ou execute uma suíte específica:
powershell -ExecutionPolicy Bypass -File scripts/executar_testes.ps1 -Teste geral
powershell -ExecutionPolicy Bypass -File scripts/executar_testes.ps1 -Teste stress
powershell -ExecutionPolicy Bypass -File scripts/executar_testes.ps1 -Teste dominio
powershell -ExecutionPolicy Bypass -File scripts/executar_testes.ps1 -Teste terminal
powershell -ExecutionPolicy Bypass -File scripts/executar_testes.ps1 -Teste persistencia
```

---

### 3. Auditoria Estática de Convenções ABI MIPS O32

Para verificar a integridade estrutural das 45 sub-rotinas do projeto (alinhamento de pilha em 8 bytes, simetria de frames `$sp`, preservação de `$ra` e registradores salvos `$s0`-`$s7`):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/auditar_registradores.ps1
```

---

## 📖 Manual dos 10 Comandos Oficiais do Shell

Todos os comandos devem ser digitados respeitando o delimitador oficial **espaço seguido de dois hífens** (`" --"`):

| # | Comando | Sintaxe Completa | Descrição e Regras | Exemplo de Uso |
| :-: | :--- | :--- | :--- | :--- |
| **1** | `addMorador` | `addMorador --<ap> --<nome>` | Adiciona um morador ao apartamento informado. Limite de até 6 moradores por AP. O 7º é rejeitado com `Falha: AP com numero max de moradores`. | `addMorador --101 --Maria Antonieta` |
| **2** | `rmvMorador` | `rmvMorador --<ap> --<nome>` | Remove o morador pelo nome exato. **Regra de Esvaziamento Compulsório:** Ao remover o último morador do AP, todos os seus veículos são compulsoriamente apagados. Se não existir, retorna `Falha: morador nao encontrado`. | `rmvMorador --101 --Maria Antonieta` |
| **3** | `addAuto` | `addAuto --<ap> --<tipo> --<modelo> --<placa>` | Adiciona um veículo. Tipos válidos: `c` (carro) ou `m` (moto). Limite: **1 carro** OU **até 3 motos**. Proibido misturar tipos (`Falha: AP com numero max de automóveis`). Tipo inválido retorna `Falha: tipo invalido`. | `addAuto --101 --c --Honda Civic --ABC1234` |
| **4** | `rmvAuto` | `rmvAuto --<ap> --<placa>` | Remove o veículo identificado pela placa. Se a placa não estiver cadastrada no AP, retorna `Falha: automóvel nao encontrado`. | `rmvAuto --101 --ABC1234` |
| **5** | `limparAp` | `limparAp --<ap>` | Remove todos os moradores e veículos do apartamento, mantendo o número da unidade preservado no cabeçalho. | `limparAp --101` |
| **6** | `infoAp` | `infoAp --<ap\|all>` | Exibe os dados do apartamento. Se vazio: 2 linhas (`AP: <num>` e `Apartamento vazio`). Se ocupado: exibe moradores e veículos. Se `--all`: lista os 24 apartamentos em ordem crescente (101 a 1202). | `infoAp --101`<br/>`infoAp --all` |
| **7** | `infoGeral` | `infoGeral` | Exibe o panorama geral do condomínio com a contagem exata e a porcentagem inteira de apartamentos ocupados e vazios. | `infoGeral` |
| **8** | `salvar` | `salvar` | Persiste a totalidade da memória do condomínio (12.480 bytes) no arquivo binário em disco `condominio.dat`. | `salvar` |
| **9** | `recarregar` | `recarregar` | Descarta quaisquer alterações feitas na sessão de memória e restaura o estado previamente gravado em disco no arquivo `condominio.dat`. | `recarregar` |
| **10** | `formatar` | `formatar` | Zera todos os moradores e veículos dos 24 apartamentos na memória RAM. **Regra:** Não altera o disco a menos que um comando `salvar` seja executado em seguida. | `formatar` |

> **Comandos de Saída:** Para encerrar o terminal e salvar os recursos de persistência, digite `sair` ou `exit`.

---

## 🎮 Bônus: Keyboard e Display MMIO (+1.0 Ponto)

O sistema implementa drivers de baixo nível em `src/mmio.asm` integrados ao shell (`src/shell.asm`), operando diretamente sobre os registradores de **Memory-Mapped I/O** do MIPS, sem utilizar syscalls de I/O padrão do MARS:

- `0xFFFF0000` (**Receiver Control**): Polling do bit 0 (*Ready bit* - teclado com caractere disponível).
- `0xFFFF0004` (**Receiver Data**): Leitura do byte ASCII digitado pelo usuário.
- `0xFFFF0008` (**Transmitter Control**): Polling do bit 0 (*Ready bit* - display pronto para receber).
- `0xFFFF000C` (**Transmitter Data**): Envio do byte ASCII a ser desenhado no display.

### Como Testar no Simulador MARS:
1. Abra `src/main.asm` no MARS e monte o programa (**Run > Assemble**).
2. Acesse o menu **Tools > Keyboard and Display MMIO Simulator**.
3. Na janela do simulador, clique no botão **Connect to MIPS** (canto inferior esquerdo).
4. Inicie a execução com **Run > Go** (ou `F5`).
5. No prompt do console MARS padrão, digite `mmio` e pressione Enter.
6. O sistema exibirá a confirmação de ativação do modo MMIO:
   ```text
   [MMIO] Modo Keyboard e Display MMIO ativado!
   [MMIO] Conecte a ferramenta em Tools -> Keyboard and Display MMIO Simulator.
   ```
7. A partir deste momento, clique na área cinza inferior (**Keyboard**) do simulador MMIO e digite seus comandos.
8. Visualize o banner `KJP-shell>> ` e as respostas no display superior (**Display**), incluindo suporte completo a **Backspace visual** (apaga o caractere do buffer e da tela)!
9. Para retornar ao console padrão, digite `mmio` novamente a qualquer momento.

---

## 💾 Formato Físico do Arquivo em Disco (`condominio.dat`)

O condomínio é estruturado em uma tabela contínua de exatamente **12.480 bytes** ($24\text{ apartamentos} \times 520\text{ bytes}$), gravada e lida via chamadas de sistema do MARS (`syscall 13` - Open, `syscall 14` - Read, `syscall 15` - Write, `syscall 16` - Close).

### Layout do Bloco de um Apartamento (520 Bytes):

| Deslocamento (Offset) | Campo | Tamanho | Descrição |
| :---: | :--- | :---: | :--- |
| `0` | `OFFSET_AP_NUMERO` | 4 bytes (Word) | Número identificador do apartamento (ex: `101`, `1202`). |
| `4` | `OFFSET_AP_QTD_MORADORES` | 4 bytes (Word) | Quantidade de moradores cadastrados (0 a 6). |
| `8` | `OFFSET_AP_TIPO_AUTO` | 4 bytes (Word) | Tipo do veículo: `0` (nenhum), `1` (carro), `2` (moto). |
| `12` | `OFFSET_AP_QTD_AUTOS` | 4 bytes (Word) | Quantidade de veículos cadastrados (0 a 3). |
| `16` | `OFFSET_AP_MORADORES` | 384 bytes | Até 6 slots de nomes (64 bytes cada, terminados em `\0`). |
| `400` | `OFFSET_AP_AUTOS` | 120 bytes | Até 3 slots de veículos (40 bytes cada: 32B modelo + 8B placa). |
| **Total** | **Bloco do AP** | **520 bytes** | $16\text{ (cabeçalho)} + 384 + 120 = 520\text{ bytes}$. |

---

## 🏛️ Arquitetura de Software e Convenções MIPS ABI O32

1. **Mapeamento Matemático $\mathcal{O}(1)$ (`dados_obter_ap`):**
   O endereço base de qualquer apartamento é obtido sem buscas lineares por meio da fórmula:
   $$\text{andar} = \text{AP} / 100, \quad \text{posição} = \text{AP} \pmod{100}$$
   $$\text{índice} = (\text{andar} - 1) \times 2 + (\text{posição} - 1)$$
   $$\text{endereço} = \text{apartamentos} + (\text{índice} \times 520)$$
2. **Convenção de Chamada e Frames:**
   - Pilha alinhada universalmente em múltiplos de 8 bytes (`addiu $sp, $sp, -N`).
   - Argumentos passados estritamente via `$a0`-`$a3` e retornos em `$v0`-`$v1`.
   - Registradores callee-saved (`$s0`-`$s7`, `$ra`) protegidos com simetria estrita de pilha.
3. **Instrução 5:**
   - 100% dos arquivos fonte possuem cabeçalho institucional obrigatório e todas as linhas de código Assembly comentadas individualmente.
