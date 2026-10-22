# Condomínio MIPS

Projeto em Assembly MIPS para execução no [MARS](https://courses.missouristate.edu/kenvollmar/mars/).

## Estrutura

```text
condominio-mips/
├── README.md
├── .gitignore
├── src/
│   ├── main.asm          # ponto de entrada e includes
│   ├── contratos.inc     # constantes, limites e convenções compartilhadas
│   ├── dados.asm         # estado global e buffers do sistema
│   ├── cadastro.asm      # inclusão e alteração de moradores/unidades
│   ├── shell.asm         # menu e interação com o usuário
│   ├── consulta.asm      # buscas e listagens
│   └── persistencia.asm  # leitura e gravação em arquivo
├── testes/
│   ├── casos.md          # catálogo dos cenários manuais
│   ├── entradas/         # arquivos de entrada dos testes
│   └── esperados/        # saídas esperadas dos testes
└── docs/                 # decisões, layout de memória e documentação
```

## Executando no MARS

1. Abra `src/main.asm` no MARS.
2. Deixe **Assemble all files in directory** desmarcado. Este projeto usa `main.asm` como arquivo agregador por meio de `.include`.
3. Monte o programa com **Run > Assemble**.
4. Execute com **Run > Go**.
5. Para testar persistência, execute a partir da pasta raiz do projeto ou ajuste o caminho dos arquivos em `contratos.inc`.

O ponto de entrada é `main`. Os outros arquivos são incluídos por `main.asm`; abra e monte esse arquivo, não um módulo isolado. A opção de montar todos os arquivos simultaneamente não deve ser usada junto com esses `.include`.

## Convenções do projeto

- Use `$s0-$s7` apenas para estado que precisa sobreviver a chamadas; uma rotina que os alterar deve salvá-los e restaurá-los.
- Use `$t0-$t9` para temporários.
- Rotinas retornam em `$v0` e, quando necessário, usam `$v1` para um segundo resultado.
- Toda rotina deve documentar argumentos, retorno e registradores modificados.
- Prefira constantes em `contratos.inc` a números mágicos espalhados pelo código.
- Reserve os buffers em `dados.asm`; não aloque memória global dentro de rotinas de negócio.
- Uma rotina deve fazer uma tarefa clara: entrada/saída, regra de negócio, consulta ou persistência.

## Próximos marcos

1. Definir o modelo de dados: campos de uma unidade, morador, contrato e taxas.
2. Definir os códigos de retorno das rotinas em `contratos.inc`.
3. Implementar o menu básico em `shell.asm`.
4. Implementar cadastro em memória e validá-lo com testes sem arquivo.
5. Implementar consultas e listagens.
6. Adicionar persistência em arquivo e testar caminhos de sucesso e erro.

## 🌟 Bônus: Keyboard e Display MMIO (+1.0 Ponto)

O sistema conta com drivers de baixo nível em `src/mmio.asm` integrados ao terminal `src/shell.asm` e às consultas `src/comandos_consulta.asm`, operando diretamente sobre os registradores de hardware mapeado em memória (Memory-Mapped I/O):
- `0xFFFF0000`: Receiver Control (polling do bit 0 / Ready)
- `0xFFFF0004`: Receiver Data (byte ASCII lido do teclado)
- `0xFFFF0008`: Transmitter Control (polling do bit 0 / Ready)
- `0xFFFF000C`: Transmitter Data (byte ASCII enviado ao display)

### Como Testar no Simulador MARS:
1. Abra `src/main.asm` no MARS e monte o programa (**Run > Assemble**).
2. Acesse o menu **Tools > Keyboard and Display MMIO Simulator**.
3. Na janela do simulador, clique no botão **Connect to MIPS** (canto inferior esquerdo).
4. Inicie a execução com **Run > Go**.
5. No prompt do console, digite `mmio` e pressione Enter para ativar o modo MMIO.
6. A partir desse instante, digite os comandos na área cinza inferior (*Keyboard*) e visualize o banner `KJP-shell>> ` e todas as saídas no display superior (*Display*), incluindo suporte completo a **Backspace** visual!

