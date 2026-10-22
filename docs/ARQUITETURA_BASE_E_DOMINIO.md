# Documentação Técnica: Base do Sistema, Memória e Domínio

**Projeto:** Sistema de Gerenciamento de Condomínio em Assembly MIPS (MARS)  
**Disciplina:** Arquitetura e Organização de Computadores (UFRPE 2026.2)  
**Módulos Documentados:** `contratos.asm`, `dados.asm`, `comandos_cadastro.asm`, `persistencia.asm` e `main.asm`  

---

## 📌 1. Visão Geral da Arquitetura do Sistema

O sistema foi concebido de forma modular e desacoplada, utilizando inclusões diretas via `.include` a partir de `main.asm`. Nenhuma camada manipula a memória das outras de forma arbitrária: toda a interação ocorre através de sub-rotinas públicas e convenções estritas da ABI MIPS.

```text
                                FLUXO DE CONTROLE
┌────────────────────────────────────────────────────────────────────────┐
│                        src/main.asm (Bootstrap)                        │
└───────┬────────────────────────────────┬───────────────────────┬───────┘
        │                                │                       │
        ▼                                ▼                       ▼
┌───────────────────────┐ ┌──────────────────────────┐ ┌─────────────────┐
│   src/dados.asm       │ │ src/shell.asm            │ │ src/persistencia│
│ • 12.480 bytes RAM    │ │ • Loop REPL              │ │ • Arquivo disco │
│ • 24 APs fixos        │ │ • Parser " --"           │ │ • condominio.dat│
│ • Mapeamento indexado │ │ • Despachante            │ │ • Syscalls I/O  │
└───────┬───────────────┘ └──────────────────────────┘ └─────────────────┘
        │
        ▼
┌───────────────────────┐
│ src/comandos_cadastro │
│ • addMorador / rmv    │
│ • addAuto / rmvAuto   │
│ • Cascata e limites   │
└───────────────────────┘
```

---

## 🗄️ 2. Estrutura de Memória dos 24 Apartamentos (`dados.asm` e `contratos.asm`)

### A. Dimensões Globais
O condomínio é composto por **12 andares**, com exatamente **2 apartamentos por andar** (total de 24 apartamentos).
- **Início na Memória:** Label `apartamentos` na seção `.data`.
- **Alinhamento:** `.align 2` (alinhado em palavra de 4 bytes).
- **Tamanho Total:** $24 \times 520\text{ bytes} = \mathbf{12.480\text{ bytes}}$.

### B. Layout Interno do Bloco de um Apartamento (520 Bytes)
Cada apartamento possui um registro de tamanho fixo para permitir acesso determinístico sem overhead de alocação dinâmica:

| Deslocamento (Offset) | Campo | Tamanho | Descrição |
| :--- | :--- | :--- | :--- |
| `0` (`OFFSET_AP_NUMERO`) | Número do AP | 4 bytes (Word) | Número identificador oficial (ex: `101`, `1102`). |
| `4` (`OFFSET_AP_QTD_MORADORES`) | Qtd. Moradores | 4 bytes (Word) | Total de moradores cadastrados ($0$ a $6$). |
| `8` (`OFFSET_AP_TIPO_AUTO`) | Tipo de Veículo | 4 bytes (Word) | `0` = Nenhum, `1` = Carro, `2` = Moto. |
| `12` (`OFFSET_AP_QTD_AUTOS`) | Qtd. Veículos | 4 bytes (Word) | Total de veículos cadastrados ($0$ a $3$). |
| `16` (`OFFSET_AP_MORADORES`) | Área de Moradores | 384 bytes | Até 6 nomes de 64 bytes cada ($6 \times 64 = 384$). |
| `400` (`OFFSET_AP_AUTOS`) | Área de Veículos | 120 bytes | Até 3 veículos de 40 bytes cada ($3 \times 40 = 120$). |
| **Total** | **Bloco do AP** | **520 bytes** | $16\text{ (cabeçalho)} + 384 + 120 = 520\text{ bytes}$. |

> **Registro de Cada Veículo (40 bytes):**
> - `0..31` (32 bytes): Modelo do automóvel terminado em `\0`.
> - `32..39` (8 bytes): Placa do automóvel (ex: `ABC1234\0`).

---

## 📐 3. Algoritmo de Mapeamento Matemático (`dados_obter_ap`)

Para obter o endereço de memória de qualquer apartamento (como `1102`) em tempo constante $\mathcal{O}(1)$, sem necessidade de buscas lineares:

1. **Separação por Divisão Inteira:**
   Divide-se o número do AP por 100 (`divu $a0, 100`):
   - **Andar:** obtido no registrador `LO` (`mflo`).
   - **Posição (Sufixo):** obtido no registrador `HI` (`mfhi`).
2. **Validação de Limites:**
   - O andar deve satisfazer: $1 \le \text{andar} \le 12$.
   - O sufixo deve ser estritamente $1$ ou $2$ (primeiro ou segundo AP do andar).
   - Se fora da regra, retorna imediatamente com `$v0 = \text{AP\_INVALIDO}`.
3. **Conversão para Índice Sequencial ($0$ a $23$):**
   $$\text{Índice} = (\text{andar} - 1) \times 2 + (\text{posição} - 1)$$
   *Exemplo para o AP 1102:*  
   $\text{andar} = 11$, $\text{posição} = 2$.  
   $\text{Índice} = (11 - 1) \times 2 + (2 - 1) = (10 \times 2) + 1 = \mathbf{21}$.
4. **Cálculo do Ponteiro Efetivo:**
   $$\text{Endereço Base} = \text{apartamentos} + (\text{Índice} \times 520)$$
   O resultado é retornado diretamente em `$v1`.

### Preservação do Número na Limpeza (`dados_limpar_ap`)
Ao executar o comando de limpeza de apartamento, o bloco de 520 bytes é zerado, mas o número do apartamento (`$a0`) é preservado na pilha e regravado no campo `OFFSET_AP_NUMERO`, mantendo a integridade cadastral da unidade.

---

## 🛡️ 4. Regras de Negócio e Cadastro (`comandos_cadastro.asm`)

### A. Cadastro de Moradores (`cadastro_adicionar_morador`)
- Lê o contador `OFFSET_AP_QTD_MORADORES`.
- Se o contador já for $\ge 6$, rejeita a operação com o código `LIMITE_MORADORES_ATINGIDO` (resultando em `Falha: AP com numero max de moradores`).
- Havendo espaço, calcula a posição de gravação:
  $$\text{Destino} = \text{bloco} + 16 + (\text{qtd} \times 64)$$
- Copia a string do nome byte a byte, incrementa o contador e retorna `OK`.

### B. Remoção de Morador e Efeito Cascata (`cadastro_remover_morador`)
- Realiza busca sequencial comparando o nome pesquisado com os nomes armazenados.
- Ao encontrar, remove o registro e **desloca todos os moradores seguintes uma posição à esquerda**, evitando lacunas na lista interna.
- O último slot vago é limpo com bytes nulos via `cadastro_zerar_bytes`.
- **Regra de Esvaziamento Compulsório (R2 / cmd_2):**  
  Se a quantidade restante de moradores atingir zero (`$s2 == 0`):
  1. `OFFSET_AP_TIPO_AUTO` é resetado para `0`.
  2. `OFFSET_AP_QTD_AUTOS` é resetado para `0`.
  3. A área inteira de veículos (120 bytes) é limpa com zeros, garantindo que nenhum veículo permaneça vinculado a um apartamento desabitado.

### C. Cadastro de Veículos e Regras de Garagem (`cadastro_adicionar_auto`)
- **Validação de Tipo:** Aceita apenas `'c'` (carro = 1) ou `'m'` (moto = 2).
- **Regra de Exclusividade:** Se o apartamento já possui veículos, o tipo recebido deve ser idêntico ao já cadastrado (`OFFSET_AP_TIPO_AUTO`). É terminantemente proibido cadastrar carro e moto simultaneamente.
- **Limites de Capacidade:**
  - Carro: Máximo de 1 unidade (`LIMITE_CARROS = 1`).
  - Moto: Máximo de 3 unidades (`LIMITE_MOTOS = 3`).
- Ultrapassar a capacidade ou tentar misturar tipos resulta em `LIMITE_AUTOS_ATINGIDO` (gerando `Falha: AP com numero max de automóveis`).

---

## 💾 5. Persistência e Ciclo de Vida em Disco (`persistencia.asm` e `main.asm`)

O sistema persiste a totalidade dos dados cadastrais em um único arquivo binário determinístico: `condominio.dat`.

### A. Syscalls Utilizadas
- `syscall 13` (*Open File*):
  - Modo Leitura: flags = `0`
  - Modo Escrita/Criação: flags = `1`
- `syscall 14` (*Read File*): Lê até 12.480 bytes do descritor para o buffer `apartamentos`.
- `syscall 15` (*Write File*): Escreve os 12.480 bytes da RAM para o descritor aberto.
- `syscall 16` (*Close File*): Fecha o descritor ativo.

### B. Operações do Ciclo de Vida
1. **Restauração Automática no Startup (`persist_carregar`):**
   Invocado durante o bootstrap em `main.asm`. Se o arquivo `condominio.dat` não existir (primeira execução), o descritor retornado é negativo; a rotina trata o erro de forma graciosa, inicializa a memória vazia e entrega o controle ao terminal sem travar.
2. **Comando `salvar` (`persist_salvar`):**
   Abre o arquivo em modo de escrita, descarrega a tabela de 12.480 bytes e fecha o descritor.
3. **Comando `recarregar` (`persist_recarregar`):**
   Descarta qualquer mutação feita em memória na sessão atual relendo o estado salvo no disco.
4. **Comando `formatar` (`persist_formatar`):**
   Limpa todos os 24 apartamentos na memória volátil chamando `dados_inicializar`.
   *Regra Estrita:* Não salva em disco automaticamente. A alteração só se torna permanente se o usuário executar explicitamente o comando `salvar`.

---

## ✅ 6. Resumo das Convenções de Registradores (ABI MIPS)

- **Parâmetros:** Recebidos em `$a0`, `$a1`, `$a2`, `$a3`.
- **Retornos:** Código numérico de status em `$v0`; ponteiro ou valor secundário em `$v1`.
- **Registradores Preservados (`$s0-$s7`, `$sp`, `$ra`):** Toda sub-rotina que invoca outra via `jal` ou utiliza registradores `$s` salva os valores originais na pilha (`$sp`) no prólogo e restaura rigorosamente todos no epílogo antes do `jr $ra`.
