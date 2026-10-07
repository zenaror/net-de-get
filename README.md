# Net de Get — disassembly incremental

Este repositório reúne o disassembly incremental de **Net de Get: Minigame @ 100** e a análise MBC6 usada no suporte do mGBA. A organização segue [pret/pokecrystal](https://github.com/pret/pokecrystal) e o projeto local Mobile Trainer, sem tradução.

Ainda não é uma reconstrução completa RGBDS e não contém a ROM comercial. Os trechos publicados têm limites de evidência explícitos. Implementação Mobile Adapter/REON permanece fora do escopo.

- Identificação e checksums: [`docs/ROM_INFO.md`](docs/ROM_INFO.md)
- Evidências do MBC6 no host: [`docs/research/mbc6-host.md`](docs/research/mbc6-host.md)
- Fragmentos RGBDS parciais: [`home/mbc6.asm`](home/mbc6.asm)
- Disassembly organizado por domínio: [`engine/`](engine/) e [`data/`](data/) (trechos parciais, com níveis de evidência anotados)
- Fixture de controles, entrada natural, saída e reabertura: [`fixtures/input-tester/README.md`](fixtures/input-tester/README.md)
- Produtor da ROM → flash → persistência, com entrada sintética explícita: [`fixtures/host-writer/README.md`](fixtures/host-writer/README.md)
- Equivalência dos trechos: `python3 tools/check_excerpts.py ORIGINAL_ROM` (compara só as seções reconstruídas, sem copiar a ROM).
- Hash da ROM externa: [`roms.sha256`](roms.sha256)
- Ferramentas e ambiente: [`INSTALL.md`](INSTALL.md)

## Organização e montagem parcial

- `home/`: rotinas ROM0 residentes, incluindo os helpers MBC6.
- `engine/`: seleção, catálogo e menus; `engine/menus/local_titles.asm` cobre a lista de títulos em A `$14:$4D43-$4E27`.
- `data/`: tabelas extraídas; nenhum título japonês foi traduzido.
- `constants/` e `ram/`: valores e endereços simbólicos, carregados por `includes.asm`. Os nomes de campos seguem o nível de evidência de cada trecho.

`make` monta e liga somente os trechos publicados em `build/excerpts.gb`, com mapa e símbolos. Esse arquivo tem lacunas preenchidas com zero e **não é uma ROM reconstruída ou jogável**. Não use seu hash como hash do jogo.

Para comparar explicitamente cada seção com a ROM original externa:

```sh
make compare REFERENCE_ROM="/caminho/externo/Net de Get - Minigame @ 100 (Japan).gbc"
```

O layout RGBDS usa bancos físicos de 16 KiB. A rotina de títulos ocupa o início do banco físico `$0A`, mas executa com o seletor MBC6 A `$14` de 8 KiB. O seletor não é um identificador de banco RGBDS.

A rotina nova preserva o uso duplo de `$C5C5`: primeiro guarda o seletor B, depois recebe o Index do jogo, que é usado no final. Não foi corrigida a lógica da ROM. A cópia do título limita a leitura a `$18` bytes e termina a string; a semântica dos nomes permanece `PROBABLE`. As observações naturais específicas estão em [minigame-maintenance.md](docs/research/minigame-maintenance.md).

### Trechos seguintes

A tabela em `data/builtin_game_selectors.asm` ocupa ROM0 `$3CD8-$3CE7`: 16 seletores nativos, com `$FF` na última entrada. O papel dessa última entrada ainda não foi estabelecido.

`home/flash_read_control.asm` cobre ROM0 `$1359-$138C`, incluindo os controles de leitura, as escritas em `$1000` e os helpers de flags de software. A lista de títulos usa os símbolos exportados dessas rotinas e da tabela, em vez de equates que repetem seus endereços. A interpretação estática dos nomes é `PROBABLE`.

A montagem parcial contém agora **6056 bytes em 48 seções**, todos comparados byte a byte com a referência externa. O comparador liga os objetos juntos para resolver referências entre arquivos e compara apenas as seções emitidas, exigindo também as fronteiras e símbolos do manifesto.

## Ciclos com validação

O trabalho segue o ciclo do Mobile Trainer: medir a próxima frente, extrair uma unidade coerente, conferir em cópia privada, repetir os checks no fonte final, publicar o checkpoint e atualizar a OMM. A continuidade não depende de Rafael escolher cada próximo trecho.

```sh
make verify REFERENCE_ROM="/caminho/externo/Net de Get - Minigame @ 100 (Japan).gbc"
```

Esse alvo executa montagem, `sym-check`, `test` e `compare`. `make private-check REFERENCE_ROM="/caminho/externo/ROM.gbc"` repete o ciclo em cópia privada, compara a imagem com a árvore atual e exige a preservação de todos os símbolos de endereço do HEAD publicado. O manifesto `config/excerpts.tsv` fixa banco físico RGBDS, início, fim inclusivo e símbolo de entrada de cada seção. Os 11 testes do verificador incluem falhas deliberadas: seções ausentes/extras/movidas, símbolos ausentes/movidos/duplicados, sobreposição, bytes alterados e imagens truncadas. São testes sintéticos da ferramenta, sem evidência de execução natural do jogo.

As novas rotinas cobrem ROM0 `$254E-$25CA` (dispatcher, 125 bytes) e `$3E00-$3ED7` (reconstrução da lista e cópia de template, 216 bytes). Seus nomes descritivos permanecem `PROBABLE`. O dispatcher restaura o seletor A salvo e impõe tipo ROM; a varredura pula o setor reservado `$70`, percorre seletores até `$80` e chama o checksum `$38B0`, agora extraído em `home/minigame_checksum.asm`. O ponteiro inicial HL da lista vem do chamador; nenhuma capacidade universal do destino foi demonstrada.

O intervalo do template usado por `$3EAE` está extraído em `data/local_list_template.asm`: 112 bytes, delimitados pela leitura estática. Isso não demonstra a extensão completa do objeto ou a semântica de cada campo. Nenhum texto japonês é traduzido.

A rotina de checksum `$38B0-$391B` preserva o atalho para o valor armazenado `$B33B`. Seu contador de páginas é calculado em 8 bits com `SWAP` e `RLCA`; não foi substituído por uma multiplicação ampliada. A equivalência dos bytes não demonstra que qualquer quantidade de blocos seja tratada como uma soma completa de payload. A interpretação permanece `PROBABLE`.

## Plano e pendências

Objetivo: ampliar progressivamente o fonte RGBDS legível, preservando os bytes da ROM original, com critérios de evidência explícitos. Este README é o plano canônico; as notas de pesquisa contêm a análise e a OMM aponta para o estado verificado.

| Fase | Estado | Critério de conclusão | Dependências |
| --- | --- | --- | --- |
| Estrutura e validação parcial | Implementada | montagem, manifesto, símbolos, testes negativos, comparação e cópia privada passando | RGBDS, Python, referência externa |
| Lista e despacho local | Em andamento | extrair chamadores e dependências com fronteiras justificadas e bytes equivalentes | helpers, tabela, template e checksum já extraídos |
| Menus e representação dos dados | Em andamento | ligar consumidores aos intervalos; nomes semânticos só com evidência suficiente | mapa das rotinas e seleção de janela |
| Expansão para outros domínios | Posterior | escolher unidades por consumidores conhecidos e eliminar lacunas progressivamente | avanço das fases anteriores |

### Trabalho a fazer

1. Extrair os callbacks `$FF80`/`$018C` usados pelo consumidor da fila e seus chamadores; seguir dependências restantes dos seis estados e consumidores do armazenamento local.
2. Inventariar consumidores do template `$71D4`, distinguindo a leitura observada estaticamente da extensão total do objeto.
3. Seguir a construção do menu e documentar campos e nomes sem traduzir textos.
4. Em cada unidade: medir, extrair, conferir `verify` e `private-check`, publicar arquivos explícitos, repetir os checks em clone remoto e atualizar a OMM.

### Perguntas sem evidência suficiente

- Papel da última entrada `$FF` na tabela de seletores embutidos.
- Estrutura completa do template e capacidade do destino da lista para todos os chamadores.
- Semântica dos casos excepcionais do contador de páginas de checksum e do marcador `$B33B`.
- Caminhos de execução ainda sem trace natural; equivalência dos bytes não os confirma.

### Decisões e bloqueios

Não há decisão de Rafael ou bloqueio externo necessário para a próxima unidade. Hardware não validado é um limite da evidência, sem impedir o disassembly estático. Tradução e implementação REON/Mobile Adapter ficam fora do trabalho atual.

Documentação do Maker é mantida em inglês no repositório separado; a correção foi publicada em `zenaror/net-de-get-maker` no commit `01bfb97`. Maker permanece fora de `_RELEASES`.

O prefixo do menu está em `engine/menus/local_entry.asm`, A `$14:$4000-$4029`. Ele testa held Select e chama a reconstrução da lista. O loop e a saída `$402A-$406B` estão em `engine/menus/local_loop.asm`; o dispatcher `$406C-$407D` e a tabela `$407E-$4089` estão separados em código e dados. Os handlers dos estados 1, 2 e 3 (`$42CD-$4302`) estão em `engine/menus/local_state_handlers.asm`; o estado 0 (`$408A-$421D`) está em `engine/menus/local_state_init.asm`. Os estados 4 (`$4303-$43BF`) e 5 (`$43C0-$450E`) também estão extraídos; a tabela usa símbolos para seus seis destinos. O helper `$01B6` e suas dependências principais agora estão em `home/local_storage.asm`; a origem de HL foi determinada estaticamente nos caminhos de sucesso.

### Armazenamento local e probes de CPU

O menu passa `SYS1` e tamanho solicitado `$02A3` ao thunk `$01B6`, que salta para `$0CA5`. A busca usa uma tabela em `$A002` com passo de seis bytes e compara nomes de quatro bytes. Nos caminhos de sucesso, a abertura de registro existente devolve HL=`header + 9`; a criação devolve o início de dados após o header de nove bytes. O caminho existente não compara o comprimento armazenado com o tamanho solicitado: `$02A3` não é garantia universal de capacidade. Nomes e layout são `PROBABLE` sem novo trace natural.

`fixtures/local-storage/` executa helpers originais em pontos de entrada forçados, com memória sintética e sem carregar saves. Os **1.724 asserts** cobrem ponteiros, preservação de registradores, nomes iguais/diferentes, diretório livre/com correspondência/cheio, checksums e comparação de palavras. A referência não é alterada. Esses probes não simulam uma abertura natural completa e não promovem a confiança das interpretações.

```sh
make storage-probe REFERENCE_ROM="/caminho/externo/ROM.gbc" MGBA_SOURCE="/caminho/mgba" MGBA_BUILD="/caminho/build"
make private-storage-check REFERENCE_ROM="/caminho/externo/ROM.gbc" MGBA_SOURCE="/caminho/mgba" MGBA_BUILD="/caminho/build"
```

O runner compila com as definições e includes do build mGBA, verifica a identidade da biblioteca executada e confere o hash da ROM antes/depois. O segundo alvo repete os probes na cópia privada junto com os gates de montagem e bytes.

A recuperação do diretório `$108E-$113D` e a limpeza da janela SRAM `$113E-$114E` estão em `home/local_storage_recovery.asm`. Os probes incluem diretório vazio, um e dois registros válidos, checksum inválido no primeiro e no segundo registro, soma válida zero e preservação da outra janela durante a limpeza. A rotina mantém um prefixo válido ao encontrar um checksum inválido; uma soma zero encerra sem inserir aquele registro. Esses resultados são de fixtures sintéticas, sem confirmação natural ou garantia de recuperação para dados arbitrários.

### Dispatcher de estados do menu

A tabela contém seis destinos: `$408A`, `$42CD`, `$42E6`, `$42F9`, `$4303` e `$43C0`. O dispatcher lê `$D000`, aplica `RLCA`, lê um endereço e termina em `JP HL`. Os probes param antes de executar o destino e incluem os seis índices, além de `$06` e `$80` para reproduzir leitura fora da tabela e rotação de oito bits. Nenhuma proteção universal de índice ou admissibilidade natural dessas entradas foi demonstrada. A interpretação permanece `PROBABLE`.

Os três handlers preservam a ordem original de chamadas, com destinos externos ainda numéricos. No estado 1, `$C21F` não zero leva diretamente ao retorno: os 255 valores não zero passaram em fixtures forçadas, preservando BC/DE/HL e a entrada. O caminho zero e os handlers 2/3 foram comparados byte a byte, mas suas chamadas não foram executadas por esses probes. O significado de `$C21F` permanece sem nome semântico.

A inicialização do estado 0 preserva as chamadas e escritas originais, incluindo `$D000 = 1`, os caminhos condicionais em `$D004` e `$C703` e a chamada à rotina de títulos. O intervalo termina no `RET` em `$421D`; os dados seguintes ficam para uma análise própria de consumidores e extensões. Este passe tem equivalência estática, sem probe de execução completa da inicialização.

Os estados 4/5 preservam os intervalos até seus `RET`, sem incluir os dados seguintes. Três fixtures do estado 4 cobrem `$D01C=$FF`, `$D01C=1` e `$D01C=0` com soma dos índices igual a `$D003`; verificam retorno, transições para estados 1/2 ou manutenção de 4 e os campos salvos. Os demais caminhos e o estado 5 têm comparação estática. Seus consumidores de gráficos, armazenamento e flash continuam sendo frentes de análise; essa extração não demonstra segurança universal nem formatação natural.

### Cópia dos dois planos de tilemap

`home/tilemap_copy.asm` cobre o thunk `$01A4` e o corpo `$0B15-$0B5E`. O consumidor delimita quatro tabelas em `data/local_menu_tilemaps.asm`: `$426D/$4275` com oito bytes cada, `$427D/$450F` com 80 cada. A rotina lê `B×C` bytes consecutivos por plano e usa passo de 32 bytes entre linhas do destino. Os probes com LCD desligado verificam três dimensões, os dois planos, registradores, restauração de VBK e padding do destino. Não validam sincronismo com LCD ligado, dimensões arbitrárias ou aparência natural do menu. Nomes e interpretação permanecem `PROBABLE`.

### Wrappers gráficos e mapa completo do menu

`home/graphics_copy.asm` cobre a cópia linear `$0A50`, o wrapper com seleção de janela `$019E/$0A68`, a cópia retangular de um plano `$01A1/$0AE4` e o wrapper de dois planos `$01A7/$0B5F`. Os wrappers escolhem A se H < `$60`, B caso contrário, usam `$C21C/$C21D` e restauram os valores salvos de seletor/tipo. Essa seleção literal não garante que qualquer origem seja válida. A cópia de um plano esgota B e C e avança DE em linhas de 32 bytes; a de dois planos restaura BC/DE. Os opcodes redundantes permanecem.

A leitura 32×32×2 da inicialização delimita os 2.048 bytes de `data/local_menu_full_tilemap.asm` em A `$14:$5208-$5A07`. Probes adicionais com LCD desligado cobrem tamanhos lineares 1/17/32, retângulos 4×1/20×2/3×3 e os dois wrappers nas janelas A/B com tipo ROM. Conferem dados, padding, registradores e restauração do mapper. Não testam tipos flash, cruzamento de janela, contadores zero ou sincronismo natural.

### Fila de transferências do menu

`engine/menus/local_pending_draw.asm` cobre A `$14:$5A08-$5B25`. Após dois callbacks, percorre dez descriptors de seis bytes em `$D028`: destino (2), largura, altura e origem (2). Consome o destino com `$FFFF`, copia em linhas de 32 bytes e zera `$D021` ao terminar. O flag `$80` usa só o plano atual; os demais flags ativos podem alternar planos, dependendo do plano inicial. Os testes entram em `$5A0E`, após os callbacks, com LCD desligado. Não validam a preparação natural desses callbacks.

A inicialização aponta para largura 1, altura 9 e origem `$4224`: `data/local_menu_column.asm` extrai somente `$4224-$422C`. Probes cobrem oito larguras positivas em dois modos, fila inativa, a coluna original no plano 1 e a cauda `$D309` (6×10 bytes por plano) a partir dos planos 0/1. Todos preservam o padding esperado. Larguras/alturas zero, limites arbitrários e execução natural permanecem sem evidência.
