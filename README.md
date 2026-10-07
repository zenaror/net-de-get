# Net de Get — disassembly e montagem idêntica

Este repositório reúne o disassembly incremental de **Net de Get: Minigame @ 100** e a análise MBC6 usada no suporte do mGBA. A organização segue [pret/pokecrystal](https://github.com/pret/pokecrystal) e o projeto local Mobile Trainer, sem tradução.

A montagem RGBDS produz `build/net-de-get.gbc`, com os 1048576 bytes e SHA-256 idênticos à referência. `make` usa somente os fontes e o hash registrado; a ROM original externa não é necessária para montar. O disassembly semântico permanece em andamento: 1029523 bytes ainda estão marcados como não interpretados, sem atribuir função ou tipo a eles. Nenhuma ROM binária é versionada. Os trechos analisados mantêm limites de evidência explícitos. A reconstrução das rotinas originais de todos os domínios integra o objetivo binário; novas funcionalidades Mobile Adapter/REON permanecem fora do escopo.

- Identificação e checksums: [`docs/ROM_INFO.md`](docs/ROM_INFO.md)
- Evidências do MBC6 no host: [`docs/research/mbc6-host.md`](docs/research/mbc6-host.md)
- Fragmentos RGBDS parciais: [`home/mbc6.asm`](home/mbc6.asm)
- Disassembly organizado por domínio: [`engine/`](engine/) e [`data/`](data/) (trechos parciais, com níveis de evidência anotados)
- Fixture de controles, entrada natural, saída e reabertura: [`fixtures/input-tester/README.md`](fixtures/input-tester/README.md)
- Produtor da ROM → flash → persistência, com entrada sintética explícita: [`fixtures/host-writer/README.md`](fixtures/host-writer/README.md)
- Montagem independente: `make`; comparação integral: `make verify-full REFERENCE_ROM="/caminho/externo/ROM.gbc"`.
- Hash da ROM externa: [`roms.sha256`](roms.sha256)
- Ferramentas e ambiente: [`INSTALL.md`](INSTALL.md)

## Organização e montagem

- `home/`: rotinas ROM0 residentes, incluindo os helpers MBC6.
- `engine/`: seleção, catálogo e menus; `engine/menus/local_titles.asm` cobre a lista de títulos em A `$14:$4D43-$4E27`.
- `data/`: tabelas extraídas; nenhum título japonês foi traduzido.
- `constants/` e `ram/`: valores e endereços simbólicos, carregados por `includes.asm`. Os nomes de campos seguem o nível de evidência de cada trecho.

`make` monta e liga todos os fontes, valida cobertura explícita, tamanho e SHA-256, e produz `build/net-de-get.gbc`. O arquivo interno `build/excerpts.gb` é mantido para compatibilidade com os verificadores; agora contém a mesma imagem completa. Não há lacunas preenchidas a partir da referência ou pelo linker. Os arquivos de mapa e símbolos continuam em `build/excerpts.map` e `build/excerpts.sym`.

`data/uninterpreted/` contém 165 intervalos residuais, delimitados por banco físico e páginas nativas de 8 KiB. São fontes literais `db` e runs constantes `ds` com tamanho explícito. A classificação permanece `HYPOTHESIS`: os bytes estão preservados, mas esses intervalos ainda podem misturar código, gráficos, texto e outras tabelas. A base montável permite refiná-los mantendo a igualdade integral.

Para comparar explicitamente cada seção com a ROM original externa:

```sh
make compare REFERENCE_ROM="/caminho/externo/Net de Get - Minigame @ 100 (Japan).gbc"
```

O layout RGBDS usa bancos físicos de 16 KiB. A rotina de títulos ocupa o início do banco físico `$0A`, mas executa com o seletor MBC6 A `$14` de 8 KiB. O seletor não é um identificador de banco RGBDS.

A rotina nova preserva o uso duplo de `$C5C5`: primeiro guarda o seletor B, depois recebe o Index do jogo, que é usado no final. Não foi corrigida a lógica da ROM. A cópia do título limita a leitura a `$18` bytes e termina a string; a semântica dos nomes permanece `PROBABLE`. As observações naturais específicas estão em [minigame-maintenance.md](docs/research/minigame-maintenance.md).

### Trechos seguintes

A tabela em `data/builtin_game_selectors.asm` ocupa ROM0 `$3CD8-$3CE7`: 16 seletores nativos, com `$FF` na última entrada. O papel dessa última entrada ainda não foi estabelecido.

`home/flash_read_control.asm` cobre ROM0 `$1359-$138C`, incluindo os controles de leitura, as escritas em `$1000` e os helpers de flags de software. A lista de títulos usa os símbolos exportados dessas rotinas e da tabela, em vez de equates que repetem seus endereços. A interpretação estática dos nomes é `PROBABLE`.

A montagem contém **1048576 bytes em 283 seções**, todos comparados byte a byte com a referência externa. Os 118 trechos analisados somam 19053 bytes; os demais 1029523 bytes estão explicitamente não interpretados. O comparador exige as fronteiras e símbolos de todas as seções, além da igualdade da imagem inteira. Cobertura binária de 100% não significa interpretação semântica de 100%.

## Ciclos com validação

O trabalho segue o ciclo do Mobile Trainer: medir a próxima frente, extrair uma unidade coerente, conferir em cópia privada, repetir os checks no fonte final, publicar o checkpoint e atualizar a OMM. A continuidade não depende de Rafael escolher cada próximo trecho.

```sh
make verify REFERENCE_ROM="/caminho/externo/Net de Get - Minigame @ 100 (Japan).gbc"
```

Esse alvo executa montagem, `sym-check`, `test` e `compare`. `make private-check REFERENCE_ROM="/caminho/externo/ROM.gbc"` repete o ciclo em cópia privada, compara a imagem com a árvore atual e exige a preservação de todos os símbolos de endereço do HEAD publicado. O manifesto `config/excerpts.tsv` fixa banco físico RGBDS, início, fim inclusivo e símbolo de entrada de cada seção. Os 24 testes do verificador incluem falhas deliberadas: seções ausentes/extras/movidas, símbolos ausentes/movidos/duplicados, sobreposição, bytes alterados e imagens truncadas. São testes sintéticos da ferramenta, sem evidência de execução natural do jogo.

As novas rotinas cobrem ROM0 `$254E-$25CA` (dispatcher, 125 bytes) e `$3E00-$3ED7` (reconstrução da lista e cópia de template, 216 bytes). Seus nomes descritivos permanecem `PROBABLE`. O dispatcher restaura o seletor A salvo e impõe tipo ROM; a varredura pula o setor reservado `$70`, percorre seletores até `$80` e chama o checksum `$38B0`, agora extraído em `home/minigame_checksum.asm`. O ponteiro inicial HL da lista vem do chamador; nenhuma capacidade universal do destino foi demonstrada.

O intervalo do template usado por `$3EAE` está extraído em `data/local_list_template.asm`: 112 bytes, delimitados pela leitura estática. Isso não demonstra a extensão completa do objeto ou a semântica de cada campo. Nenhum texto japonês é traduzido.

A rotina de checksum `$38B0-$391B` preserva o atalho para o valor armazenado `$B33B`. Seu contador de páginas é calculado em 8 bits com `SWAP` e `RLCA`; não foi substituído por uma multiplicação ampliada. A equivalência dos bytes não demonstra que qualquer quantidade de blocos seja tratada como uma soma completa de payload. A interpretação permanece `PROBABLE`.

## Plano e pendências

Objetivo binário autorizado por Rafael: uma ROM montável a partir do fonte RGBDS, idêntica byte a byte à referência original de 1 MiB. Esse critério foi atingido com a base completa de fontes, usando a referência externa somente para verificação. O trabalho semântico continua sobre os intervalos não interpretados, preservando os bytes japoneses e os níveis de evidência. Este README é o plano canônico; as notas de pesquisa contêm a análise e a OMM aponta para o estado verificado.

| Fase | Estado | Critério de conclusão | Dependências |
| --- | --- | --- | --- |
| Estrutura e validação parcial | Implementada | montagem, manifesto, símbolos, testes negativos, comparação e cópia privada passando | RGBDS, Python, referência externa |
| Lista e despacho local | Em andamento | extrair chamadores e dependências com fronteiras justificadas e bytes equivalentes | helpers, tabela, template e checksum já extraídos |
| Menus e representação dos dados | Em andamento | ligar consumidores aos intervalos; nomes semânticos só com evidência suficiente | mapa das rotinas e seleção de janela |
| Expansão para outros domínios | Em andamento | escolher unidades por consumidores conhecidos e eliminar lacunas progressivamente | avanço das fases anteriores |
| Reconstrução binária completa | Concluída | montagem independente da referência; cobertura explícita dos 1048576 bytes; `make verify-full` passando e SHA-256 igual a `roms.sha256` | 283 seções, incluindo intervalos explicitamente não interpretados |

### Trabalho a fazer

1. Seguir os callees da inicialização A `$16:$4000`, agora extraída até `$41E9` em `engine/startup/bank_a16.asm`, os callees dos dez estados já extraídos da tabela `$03A8` e a manutenção de VBlank `$2242`; fechar os callees ainda numéricos dos menus, preservando fronteiras e símbolos.
2. Inventariar consumidores do template `$71D4`, distinguindo a leitura observada estaticamente da extensão total do objeto.
3. Seguir a construção do menu e documentar campos e nomes sem traduzir textos.
4. Refinar os intervalos `ResidualROM` por consumidores e fluxo, preservando seus símbolos de início quando extraídos; `make coverage` informa o volume ainda não interpretado.
5. Em cada unidade: medir, extrair, conferir `verify` e `private-check`, publicar arquivos explícitos, repetir os checks em clone remoto e atualizar a OMM.

### Critério de reconstrução completa

```sh
make coverage
make verify-full REFERENCE_ROM="/caminho/externo/ROM.gbc"
```

`coverage` informa cobertura binária e bytes explicitamente não interpretados; enumera lacunas caso sejam introduzidas. `verify-full` exige todos os gates parciais, cobertura integral pelo manifesto, tamanho de 1048576 bytes e igualdade de todos os bytes. A montagem usa somente fontes/ativos do projeto; a ROM original não preenche lacunas. O padding do linker não conta como fonte, mesmo quando seus bytes coincidem com a referência. O gate integral passa na base atual e rejeita qualquer nova lacuna, mudança de tamanho ou alteração de byte. O hash final esperado é `9fb1e6e4a637796b8624bd2de6c9abaa9e758546b620cb5dc8441b07c288bc63`.

O critério de ROM idêntica é distinto da conclusão de todos os nomes e interpretações semânticas: igualdade binária não promove hipóteses a `CONFIRMED`. Os oito testes do gate integral verificam cobertura, lacunas, padding coincidente, sobreposição, tamanho, bytes alterados e transição entre bancos físicos. Cinco testes adicionais verificam o bootstrap literal, a divisão de páginas e a ausência de includes da referência. `make full-negative-check` monta duas cópias descartáveis: uma com byte alterado e outra sem uma página zerada. Ambas são rejeitadas; a segunda ainda tem o hash original por coincidência do padding, demonstrando por que hash sozinho não substitui cobertura de fonte.

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

`fixtures/local-storage/` executa helpers originais em pontos de entrada forçados, com memória sintética e sem carregar saves. Os **10.473 asserts** cobrem ponteiros, preservação de registradores, nomes iguais/diferentes, diretório livre/com correspondência/cheio, checksums e comparação de palavras. A referência não é alterada. Esses probes não simulam uma abertura natural completa e não promovem a confiança das interpretações.

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

`engine/menus/local_pending_draw.asm` cobre A `$14:$5A08-$5B25`. Após dois callbacks, percorre dez descriptors de seis bytes em `$D028`: destino (2), largura, altura e origem (2). Consome o destino com `$FFFF`, copia em linhas de 32 bytes e zera `$D021` ao terminar. O flag `$80` usa só o plano atual; os demais flags ativos podem alternar planos, dependendo do plano inicial. Os testes da fila entram em `$5A0E`, após os callbacks, com LCD desligado. Uma fixture integrada adicional entra em `$5A08` com a rotina DMA original instalada e paletas inativas; a preparação natural permanece sem trace.

A inicialização aponta para largura 1, altura 9 e origem `$4224`: `data/local_menu_column.asm` extrai somente `$4224-$422C`. Probes cobrem oito larguras positivas em dois modos, fila inativa, a coluna original no plano 1 e a cauda `$D309` (6×10 bytes por plano) a partir dos planos 0/1. Todos preservam o padding esperado. Larguras/alturas zero, limites arbitrários e execução natural permanecem sem evidência.

### Paletas pendentes e DMA de OAM

`home/palette_updates.asm` reconstrói `$018C/$0995-$09EA`: se `$C221` estiver ativo, zera o flag e envia 64 bytes de background e 64 de objetos a partir de `$C222`, preservando AF/BC/HL. `home/oam_dma.asm` reconstrói o instalador `$09EB-$09F8` e o template executável `$09F9-$0A02`, copiado para `$FF80`. O template dispara DMA a partir de `$C000` e mantém seu laço de espera original.

Os probes com LCD desligado cobrem paletas inativas/ativas, cópia exata dos dez bytes para HRAM, DMA dos 160 bytes de OAM e uma entrada completa em `$5A08` com esses callbacks. Isso é execução sintética no core, sem prova de timing em hardware ou atualização natural do menu.

### Intervalos gráficos da inicialização

`data/local_menu_tiles.asm` cobre os intervalos lidos na inicialização: A `$14:$5C0A-$5C19` (16 bytes), A `$14:$5CE2-$5D81` (160 bytes) e B `$15:$6002-$7801` (6 KiB). O intervalo de B inclui o template já emitido em `$71D4-$7243`; os dados novos ocupam somente os segmentos antes/depois dele. A leitura auxiliar de 32 bytes em `$71B4` usa o mesmo segmento. O banco físico RGBDS continua `$0A` para as duas janelas.

Quatro probes reproduzem as cópias desses intervalos reais no core, com registradores/memória forçados e LCD desligado. Conferem todos os bytes, o sentinel após o destino, registradores e restauração dos seletores. Isso não executa o estado 0 inteiro nem demonstra a aparência natural ou a extensão completa de cada objeto gráfico.

### Buffer de OAM e soma de headers de flash

`engine/menus/local_housekeeping.asm` cobre `$5B26-$5B30`, que limpa 160 bytes em `$C000`, e `$5B31-$5B8B`, que percorre pares da lista até `$FF`. A varredura pula índices menores que `$10`, seleciona B como flash, exige `$6044=$FF`, aceita `$6005≤$10` e acumula esse byte em oito bits para `$D005`. Desativa as leituras de flash ao terminar, mas não restaura o seletor/tipo B visitado. A unidade semântica dessa contagem permanece `PROBABLE`.

Os probes incluem lista vazia, índice embutido, contagens válidas 3/16, contagem 17 rejeitada, marcador inválido e duplicatas sintéticas para reproduzir wrap 272→16. Os headers são preparados somente no backing descartável do core e restaurados; nenhum comando de programação/erase ou save real é usado. O clear de OAM confere os 160 bytes e um sentinel posterior.

### Registro do consumidor e stubs de interrupção

`engine/menus/local_runtime_init.asm` cobre `$5BC6-$5BE9`: zera estado/flags da fila, configura outros campos e registra o consumidor `$5A08` via `$0150`. Os callees `$45FF/$481B` agora usam símbolos dos helpers extraídos; uma fixture executa a inicialização completa com `SYS1` sintético corretamente dimensionado. `home/runtime_callbacks.asm` reconstrói os thunks `$0150-$015B` e os setters `$0661-$0698`. Dois setters gravam DE nos ponteiros `$FF8E/$FF92`; os outros escrevem `JP DE` nos stubs `$C67F/$C682`, ou `RETI` para DE zero, preservando AF e os dois bytes de operandos no caminho zero.

Fixtures forçadas cobrem cinco valores de DE em ambos os ponteiros e ambos os stubs, verificando bytes e registradores. Elas não executam o destino ou uma interrupção natural e não validam a admissibilidade dos endereços de teste. A semântica dos nomes permanece `PROBABLE`.

### Carregamento de SYS1 e inicialização das paletas

`engine/menus/local_load.asm` cobre `$45FF-$4619`, copiando `$02A3` bytes de `SYS1` para `$D064-$D306` e fechando o registro. Não foi inserida validação de HL ou capacidade. `engine/menus/local_palette_init.asm` cobre `$481B-$487D`, enviando o mesmo conjunto de oito bytes para os oito índices de paleta de background e de objetos. O intervalo lido `$487E-$4885` está em `data/local_menu_white_palette.asm`; bytes idênticos seguintes não foram incluídos sem consumidor demonstrado.

Os thunks `$0171/$0174` e seus corpos `$0799-$07E6` estão em `home/palette_entries.asm`. Cada chamada lê oito bytes, avança HL, incrementa A e modifica C para `$80`. Probes cobrem os índices 0–7, o envio completo das paletas, `SYS1` novo/existente com tamanho correto e a entrada completa de `$5BC6`. Não demonstram segurança para registros curtos ou corrompidos, abertura natural ou timing com LCD ligado.

### Indicadores da lista em OAM

`engine/menus/local_list_indicators.asm` cobre `$461A-$4655`. Zera primeiro o byte Y de duas entradas no buffer de OAM (`$C070/$C074`), usa o bit `$10` de `$D006` para suprimir a atualização e preenche os quatro bytes das entradas conforme `$D002` e `$D003`. A comparação inferior calcula `offset + 5` em oito bits, sem ampliação.

Quarenta fixtures verificam as duas entradas e sentinels adjacentes, combinando o bit de pisca, offsets 0/1/251/252/255 e contagens 0/5/6/255. Os offsets altos demonstram só a mecânica de wrap; não estabelecem estados admissíveis ou indicadores naturais. A interpretação permanece `PROBABLE`.

### Produtor dos indicadores de held input

`engine/menus/local_held_indicators.asm` cobre `$478D-$4812`. Compara o byte inteiro de held input (`$FF96`) com `$D015`; se forem iguais, retorna sem alterar a fila. Quando diferem, escreve descriptors de uma célula em `$D046/$D04C` para os bits `$10/$20` anteriores/atuais, com prioridade para `$10` quando ambos estão ativos. Atualiza `$D021` e guarda o novo byte em `$D015`. Os oito bytes em `$4813-$481A` estão em `data/local_held_indicators.asm`, sem tradução.

Trinta e seis combinações sintéticas conferem os descriptors, flags, caminho sem mudança e sentinels. Quatro transições encadeiam o produtor com o corpo do consumidor `$5A0E`, verificando ambos os planos de VRAM e o consumo dos flags. Os callbacks são pulados nesses quatro casos. Não há trace natural ou prova de admissibilidade de combinações como `$FF`; a interpretação permanece `PROBABLE`.

### Timer de texto e cursores

`engine/menus/local_text_step.asm` cobre `$4656-$46C0`: testa/decrementa `$D016`, lê a origem em `$D017/$D018`, copia tokens para `$D32A` e chama o sink `$01EF` nos caminhos de saída. Mantém os tokens `$FE/$FF`, o contador de linha `$D01A` e as atualizações de `$D019`. Sete fixtures cobrem timer inativo/maior que um e strings vazias em modos não zero, sem executar o sink. O buffer não tem limite universal demonstrado.

`engine/menus/local_cursors.asm` cobre `$488E-$48AA`, `$48AB-$48D6` e `$48DA-$493F`; `data/local_cursor_offsets.asm` separa os três bytes `$48D7-$48D9`. O helper ROM0 `$2DC3-$2DCF`, em `home/local_cursor_jitter.asm`, calcula um deslocamento de oito bits a partir de `$FF8B`. Probes cobrem os 256 valores desse byte, 20 entradas de cursor de lista, 16 de remoção e 20 de movimento, com sentinels de OAM. Os índices 0/1/2 e o caminho `$FF` da tabela são fixtures delimitadas, sem garantia de índices arbitrários ou visualização natural.

### Entrada da lista e busca de pares

`engine/menus/local_list_input.asm` cobre `$4940-$4C3D`, com branches e chamadas preservados. Dezesseis combinações de bits não tratados retornam sem alterar os campos testados; os caminhos que chamam rotinas ainda externas têm somente equivalência estática neste passe. `engine/menus/local_list_lookup.asm` cobre `$4CDA-$4CEF`: percorre pares em `$D1E6`, busca o enésimo byte de categoria igual a C e encerra no marcador `$FF`. Os quatro probes cobrem duas correspondências, exaustão e o wrap do índice B `$FF` numa lista sintética de 256 pares. Não há prova de capacidade natural dessa lista. As interpretações continuam `PROBABLE`.

### Preparação de descrição, ações e gravação de nomes

`engine/menus/local_description.asm` cobre `$46C1-$478C`: procura o item na lista, lê bytes desde `$6024` em ROM/flash até zero para `$D30A`, configura o timer/campos de texto e restaura seletor/tipo B. Essa cópia não tem limite universal demonstrado. Os callees de texto ainda numéricos impedem atribuir novo resultado de execução completa a esse helper; a evidência deste passe é estática.

`engine/menus/local_action_input.asm` cobre `$4C6F-$4CD9`; dezesseis fixtures com bits não tratados retornam sem alterar os campos testados. `engine/menus/local_box_name.asm` cobre `$4C3E-$4C6E`, abrindo SYS1, calculando o destino com `SWAP` em oito bits, copiando até zero ou 16 bytes e fechando o registro. Quinze fixtures combinam índices 0/1/6/16/255 e comprimentos 0/3/16 num registro sintético de 675 bytes; conferem todos os bytes restantes. O fechamento desabilita SRAM; o harness a habilita novamente somente para inspecionar sua memória descartável. Não há garantia de capacidade de registros arbitrários ou admissibilidade natural dos índices extremos.

### Vetores, entrada e cabeçalho

`home/vectors.asm` cobre `$0000-$0103`, incluindo os destinos literais de RST/interrupções, os stubs JP em WRAM e a entrada `$0100`. As regiões reservadas zeradas são declaradas com tamanho explícito e comparadas; não são lacunas preenchidas pelo linker. `data/cartridge_header.asm` cobre `$0104-$014F`, preservando logo, título, código do jogo, flags e checksums originais. `rgbfix` não é aplicado à imagem; os checksums originais são preservados. Isso fecha os primeiros 336 bytes da ROM sem confirmar uma sequência natural de boot neste passe.

### Base completa e proveniência

A base montável preserva todos os 385 símbolos de endereço do checkpoint `574a20a`. O bootstrap `tools/bootstrap_remaining.py` foi executado em diretório privado, gerou somente os intervalos restantes e manteve a referência externa intacta. O fonte resultante foi importado como base de trabalho; o bootstrap recusa regenerar dentro do projeto ou substituir uma base já importada. A manutenção passa a ser dos arquivos publicados, com comparação integral a cada mudança. Os arquivos não interpretados não são evidência de comportamento natural ou de completude da análise.

### Boot, RST e callbacks refinados

`home/startup.asm` extrai `$02B8-$03A7`, incluindo o prefixo de limpeza de memória, a seleção A `$16` e o loop de despacho principal. A tabela lida em `$03A8-$03BB` está em `data/main_state_pointers.asm`; dez destinos literais são preservados. O despacho duplica A em oito bits e não valida universalmente o índice. Quatro fixtures forçam A=`$11/0/$80/$FF`, param antes da chamada em `$0373` e conferem HRAM, banco fixo e os sete bancos WRAM, os stubs `RETI`, SP e flags/seletores registrados. Não executam a inicialização A `$16:$4000` ou o loop principal naturalmente.

`home/interrupt_dispatch.asm` extrai `$05F5-$0660` e `$0699-$06A5`. `$05F5` consome um endereço de retorno, usa A duplicado em oito bits como offset numa tabela de palavras e salta ao destino lido. O nome antigo `ResetVector` foi mantido como alias; `$0000` passa a ter também o nome `RST00Vector`. A entrada real do cartucho continua em `$0100`, com salto para `$02B8`.

Probes cobrem os 256 índices do dispatcher, callbacks nulos/WRAM em três slots com restauração dos registradores, o retorno sem callback e VBlank até a entrada `$069E`, antes da manutenção `$2242`. Estes últimos conferem o flag `$FF8A` e os registradores salvos na pilha, sem executar a manutenção ou demonstrar uma interrupção natural. Os símbolos antigos de intervalos refinados continuam no mesmo endereço; a ROM completa mantém o hash original.


### Inicialização na janela A $16

`engine/startup/bank_a16.asm` extrai `$4000-$41E9` do banco físico `$0B` (490 bytes), preservando `ResidualROM0B_4000` como alias. A chamada do boot usa `InitializeBankA16`; o teste de `$FF9C` encaminha o valor zero para `$416C`. O caminho anterior pode retornar em `$416B`; o caminho `$416C` termina em um loop de espera `$41DE-$41E9`. Os bytes seguintes, inclusive o destino numérico `$41EA`, continuam não interpretados.

A interpretação é `PROBABLE`, baseada no fluxo estático. Quatro probes `SYNTHETIC` entram diretamente em `$416C`, com LCD desligado, variam o seletor B anterior e param em `$419D` antes do helper de som `$0252`. Conferem seletor B `$1F`/tipo ROM, bytes da janela mapeada, preservação de BC/DE/HL/SP, paletas, scroll, janela e rotas de som. Não executam a inicialização inteira, os loops com HALT ou o boot natural. A montagem inteira continua idêntica; 571 símbolos publicados de `dd6004a` foram preservados na cópia privada.


### Primeiros estados principais e tabelas internas

`home/main_states.asm` cobre ROM0 `$03BC-$04A5` (234 bytes), separando instruções e três tabelas consumidas pelo código: palavras `$0407-$040C`, ponteiros `$041D-$0422` e ponteiros de resultado `$046E-$047B`. A tabela principal agora usa os símbolos dos estados 0, 1 e 2. O alias `ResidualROM00_03BC` permanece no mesmo endereço; `$04A6-$051D` continua não interpretado.

A confiança é `PROBABLE`: as chamadas externas e os campos mantêm endereços numéricos quando sua semântica não está estabelecida. O dispatcher principal em `$0391` duplica o índice em oito bits e lê um destino sem proteção universal de limites. 256 probes forçados param antes de `JP HL` em `$03A5`, conferindo destino, retorno empilhado e registradores. Sete handlers `$047C-$04A5` retornam após escrever `$C623` com os valores 3/4/5/1/2/7/6; 14 asserts verificam esses retornos e a preservação de BC/DE/HL. Não foi executado o fluxo natural dos estados ou seus callees. A cópia privada preservou os 591 símbolos publicados em `e48a89c`.


### Destinos restantes dos estados principais

`home/main_states_remaining.asm` refina `$04A6-$051D` e `$0564-$05C7` (220 bytes), incluindo o estado 3, suas palavras/ponteiros internos e os estados 4 a 9. Todos os dez destinos da tabela `$03A8` agora são simbólicos. O estado 3 pode entrar em `$0521`, após a chamada inicial do trecho existente `$051E`; `LocalMinigameSelectionBody` é um alias que preserva também o símbolo local publicado `LocalMinigameSelectionGate.clearBuffer`. Os aliases residuais `$04A6` e `$0564` permanecem; o sufixo `$05C8-$05D9` continua não interpretado.

Os nomes permanecem `PROBABLE`. 256 probes entram diretamente na cauda `$058A`, após a chamada externa: `$C623 = 7` é preservado, os demais valores viram 2. Outros probes verificam quatro caudas de retorno e os argumentos dos cinco prefixos antes de `$0264`. O estado 9 seleciona A `$16`/ROM antes de `$44AA`; sua cauda separada descarta o retorno empilhado e salta para `$02B8` com A=`$11`. Nenhum probe executa esses callees externos ou demonstra um reinício natural. São 527 asserts sintéticos adicionais; a equivalência integral continua separada da interpretação semântica.


### Interface residente e dispatcher de callbacks bancados

`home/resident_jumps.asm` refina `$01BC-$02B7`: 84 slots de `JP` (252 bytes), com rótulos neutros `ResidentJumpXXXX`. Os consumidores extraídos usam esses símbolos; os destinos conhecidos usam nomes existentes, e os demais permanecem numéricos. O alias `ResidualROM00_01BC` mantém seu endereço. Um slot montado e testado não demonstra que todo destino seja um fluxo natural admissível.

`home/banked_callback_dispatch.asm` cobre `$23E4-$24B8` (213 bytes), incluindo o retorno isolado `$24B8`. O dispatcher calcula `3*A` em oito bits e lê seletor e endereço a partir de `$05C8`; B zero escolhe a janela A, B não zero a janela B. As fontes novas de dados cobrem `$05C8-$05D9` e `$05E0-$05F4`, preservando os aliases residuais e a seção já publicada `$05DA-$05DF`. O layout contíguo tem 15 registros de três bytes; isso não demonstra proteção de índice ou admissibilidade de todos os registros em ambas as janelas.

A confiança permanece `PROBABLE`. 84 probes param nos destinos dos thunks antes de executá-los. Para cada janela, 256 índices param antes de `JP HL` no dispatcher: conferem o wrap de oito bits, o destino, o retorno empilhado e as flags/seletores salvos. A restauração é executada em uma entrada forçada separada, sem executar o destino. O estado anterior usa tipo flash `$08` para verificar sua restauração; índices fora da tabela podem gerar diagnósticos de seletor flash inválido durante a ordem original de escritas. Os probes não provam execução de callbacks, capacidade universal das pilhas internas ou acesso flash válido desses índices. A cópia privada preservou os 629 símbolos publicados em `a1fb3c7`.


### Wrappers da janela A $16

`home/bank_a16_calls.asm` extrai `$1663-$16B0` e `$1783-$17B2` (126 bytes): quatro wrappers usados pelos thunks `$0282/$0285/$0288/$028B` e dois helpers. Os wrappers guardam seletor/tipo A em `$C641/$C643/$C645/$C647`, selecionam A `$16`/ROM, chamam `$4227/$424D/$42CB/$42EF` e restauram a configuração. Esses destinos permanecem numéricos. O helper avança DE em um byte e preserva BC/HL; três wrappers preservam AF na restauração, enquanto `$1663` não o salva. O alias `ResidualROM00_1663` permanece.

A confiança é `PROBABLE`. Oito pares explícitos de seletor/tipo testam os helpers; quatro probes param nos wrappers antes da chamada externa, e quatro caudas são executadas em entradas forçadas independentes. Não há execução natural dos destinos, garantia de restauração de interrupções ou validação de hardware. Os 44 novos asserts sintéticos passam; a cópia privada preservou os 721 símbolos publicados em `19532c1`. Os intervalos adjacentes `$16B1-$1782` e `$17B3-$1FFF` continuam não interpretados.


### Corpos dos wrappers e registro SYS0

`engine/startup/sys0_record.asm` extrai A `$16:$4227-$4311` (235 bytes): os quatro destinos dos wrappers, agora simbólicos. O identificador de quatro bytes em ROM0 `$17B3-$17B6` está em `data/sys0_record_name.asm`, preservando `ResidualROM00_17B3`; o restante a partir de `$17B7` continua não interpretado. `home/copy_bytes.asm` extrai `$2613-$261B`, laço original de cópia HL→DE que não testa BC antes da primeira cópia. O comprimento zero não representa uma cópia vazia.

A interpretação é `PROBABLE`. O fixture prepara um registro existente `SYS0` de 50 bytes em SRAM sintética e executa os wrappers completos `$1689/$169D`, incluindo abertura, cópia, fechamento/checksum e restauração da janela. Verifica payload, resultado A zero, configuração A restaurada e checksum atualizado. Não cobre criação de `SYS0`, os caminhos de inicialização `$424D`, registro menor ou menu natural. Cinco comprimentos positivos verificam a cópia e seus limites; 16 novos asserts passaram, preservando os 729 símbolos publicados em `e0cbd96` na cópia privada.


### Chamada bancada no retorno de VBlank

`home/vblank_mapper.asm` extrai `$2242-$22A6` (101 bytes), consumido por `$069E` e pelo thunk `$0249`. Seleciona B a partir de `$C663/$C664`, A `$1E`/ROM e chama `$4000`. Após a chamada, `$C672` zero restaura os pares de `$FFAB-$FFAE` e atualiza `$C113-$C116`; não zero restaura os pares de `$CB81-$CB84` sem atualizar esses campos. A ordem e a diferença permanecem originais.

A confiança é `PROBABLE`. Três probes (`$C672 = 0/1/$FF`) param antes da chamada A `$1E:$4000`; as caudas são entradas forçadas separadas. Conferem bytes mapeados, registradores e diferenças dos campos de acompanhamento. São nove novos asserts, sem executar o destino A `$1E`, interrupções naturais ou temporização de VBlank. O privado preservou os 745 símbolos publicados em `fabf3fb`.


### Corpo de atualização em A $1E

`engine/startup/bank_a1e_tick.asm` extrai a entrada `$4000-$4002` e o corpo `$42B1-$43CA` em A `$1E` (285 bytes, banco físico `$0F`). O chamador residente agora usa `NativeA1EEntry`. O corpo examina oito slots espaçados em `$10` bytes em `$CF00-$CF7F`: quando o byte `+1` está ativo, decrementa `+4`; se ele chega a zero, decrementa `+5` não zero e recarrega `+4 = $FF`, ou chama um handler externo. As chamadas externas e os campos continuam com limites explícitos de interpretação.

A confiança é `PROBABLE`. 64 casos completos do corpo mantêm os caminhos globais inativos e verificam um slot de cada vez, com contadores 0/1/2/$FF e resíduos 1/$FF. Oito probes param antes dos handlers. 56 casos verificam a expressão de máscara que escreve `$FF25`, e um caso totalmente inativo preserva o registrador. São 250 novos asserts sintéticos; não demonstram um VBlank natural, execução dos handlers, fluxo global `$CF86` ativo ou áudio correto. A cópia privada preservou os 748 símbolos publicados em `61fca2a`.


### Caminho global de A $1E

`engine/startup/bank_a1e_global.asm` extrai `$406E-$40B7` (74 bytes). O primeiro helper zera `$CF00-$CF3F` e `$CF86/$CF87/$CF8A`, preservando os quatro slots superiores e os demais campos. O segundo condiciona escritas nos registradores de áudio às flags `$CF41/$CF51/$CF61/$CF71`. O corpo principal usa os dois símbolos no caminho global; os handlers dos slots permanecem externos.

A interpretação é `PROBABLE`. O fixture verifica a limpeza exata, 32 combinações de flags superiores com valores ativos 1/$FF e 32 execuções completas do tick global com períodos 1/$FF, contadores 0/1/2/$FF e fases 0/14/15/$FF. A fase incrementada para `$0F` chama os dois helpers e limpa os campos indicados. São 130 novos asserts; não há prova de áudio audível correto, fluxo natural ou execução dos handlers. O privado preservou os 770 símbolos publicados em `c690a56`.


### Handler do slot 0 em A $1E

`engine/startup/bank_a1e_slot0.asm` extrai `$43CB-$45A0` (470 bytes): o helper que reduz um valor pela fase global com piso zero e o handler do slot 0, agora chamado simbolicamente pelo tick. O handler lê um stream pelo ponteiro `$CF00/$CF01`; nomes de comandos e campos permanecem neutros. O destino `$4A07` e a tabela `$4A0E` continuam numéricos e não interpretados.

A confiança é `PROBABLE`. Os probes param nos destinos do despacho para os 256 opcodes e executam casos sintéticos completos de `$B0/$B1/$FD/$FE`, contadores curtos/estendidos e redução pela fase. O contador curto preserva `$CF05`; o estendido deriva os dois bytes pela expressão original. Em `$FE`, contador 1 segue a posição atual sem gravar zero; contador zero volta ao ponteiro salvo. Um caso executa o tick até o handler `$B0`. São 578 novos asserts, sem playback natural, todos os comandos completos, limites universais de stream ou áudio correto. O privado preservou os 778 símbolos publicados em `4a90144`.


### Handler do slot 1 em A $1E

`engine/startup/bank_a1e_slot1.asm` extrai `$45A1-$4751` (433 bytes), preservando `ResidualROM0F_45A1` e tornando simbólica a chamada pelo tick. O restante começa em `$4752`. Este handler usa `$CF10/$CF11` como ponteiro: `$B1` modifica os bits 1 e 5 de `$CF88` e o campo `$CF19`; `$C0` usa registros de dois bytes pela base `$CF96/$CF97`. Esses campos e o stride diferem do slot 0; não se presume equivalência dos demais comandos.

A confiança é `PROBABLE`. 256 despachos param antes dos corpos; 19 streams `$B0`, todos os 256 parâmetros `$B1`, todos os 256 parâmetros `$C0` com tabela WRAM sintética e um tick até `$B0` adicionam 1.320 asserts. Contadores curtos preservam `$CF15`; o slot 1 preserva o sentinela `$CF04` do slot 0. Não há execução natural, todos os corpos de comandos, limites universais de stream/tabela ou prova de áudio correto. A cópia privada preservou os 807 símbolos publicados em `bdc6663`; a ROM inteira continua idêntica.


### Handler do slot 2 em A $1E

`engine/startup/bank_a1e_slot2.asm` extrai `$4752-$48EB` (410 bytes), preservando `ResidualROM0F_4752`; a chamada pelo tick agora é simbólica. O ponteiro do stream fica em `$CF20/$CF21`. `$B1` modifica os bits 2 e 6 de `$CF88`, sem o campo adicional do slot 1. `$C0` guarda o índice mascarado em `$CF27`, lê um ponteiro de dois bytes pela base `$CF98/$CF99` e copia 16 bytes para `$FF30-$FF3F`. A indexação usa `2*(parâmetro & 31)`, sem o incremento do slot 1.

A interpretação é `PROBABLE`. 256 despachos param antes dos corpos; 19 streams `$B0`, todos os 256 parâmetros `$B1`, todos os 256 parâmetros `$C0` com tabela/ondas WRAM sintéticas e canal desabilitado, e um tick até `$B0` adicionam 1.320 asserts. O contador curto preserva `$CF25` e o sentinela `$CF14` permanece intacto. Não há prova dos demais corpos, tabelas/streams arbitrários, comportamento de wave RAM com canal ativo, áudio audível ou fluxo natural. Os 834 símbolos publicados em `69f2a73` permanecem no mesmo endereço na cópia privada; imagem inteira e negativos reais passam.


### Handler do slot 3 e limpeza compartilhada em A $1E

`engine/startup/bank_a1e_slot3.asm` extrai `$48EC-$4A0F` (292 bytes), preservando `ResidualROM0F_48EC`. O slot 3 usa `$CF30/$CF31`, aceita `$B1/$C0/$FD/$FE/$FF` e os ranges `$80-$9F`; `$B0/$E0` retornam sem executar os corpos presentes nos slots anteriores. `$B1` modifica bits 3/7 de `$CF88` e `$CF39`. `$C0` apenas consome o parâmetro antes de ler o contador. O comando `$FF` dos quatro slots inferiores chega ao helper `$4A07`, que limpa 16 bytes por HL; todos esses consumidores agora usam o símbolo compartilhado.

A confiança é `PROBABLE`. 256 despachos parados, 19 contadores curtos/estendidos via `$C0`, todos os 256 parâmetros `$B1` e `$C0`, um tick até `$C0` e quatro streams `$FF` completos adicionam 1.328 asserts. A limpeza dos quatro slots mantém os demais 112 bytes de `$CF00-$CF7F`. Os probes não cobrem os demais corpos, fluxo natural ou áudio correto. A base numérica `$4A0E` das leituras de palavras nos slots anteriores sobrepõe o operando do `JR` e o `RET` de `$4A0F`: bytes `$FC/$C9`. Essa sobreposição foi preservada; extensão e uso natural do objeto continuam desconhecidos. A cópia privada preservou os 862 símbolos publicados em `2526dfb`, com imagem inteira idêntica e negativos reais passando.
