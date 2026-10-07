# Net de Get — disassembly e montagem idêntica

Este repositório reúne o disassembly incremental de **Net de Get: Minigame @ 100** e a análise MBC6 usada no suporte do mGBA. A organização segue [pret/pokecrystal](https://github.com/pret/pokecrystal) e o projeto local Mobile Trainer, sem tradução.

A montagem RGBDS produz `build/net-de-get.gbc`, com os 1048576 bytes e SHA-256 idênticos à referência. `make` usa somente os fontes e o hash registrado; a ROM original externa não é necessária para montar. O disassembly semântico permanece em andamento: 1013918 bytes ainda estão marcados como não interpretados, sem atribuir função ou tipo a eles. Nenhuma ROM binária é versionada. Os trechos analisados mantêm limites de evidência explícitos. A reconstrução das rotinas originais de todos os domínios integra o objetivo binário; novas funcionalidades Mobile Adapter/REON permanecem fora do escopo.

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

A montagem contém **1048576 bytes em 436 seções**, todos comparados byte a byte com a referência externa. Os 236 trechos analisados somam 36137 bytes; os demais 1012439 bytes estão explicitamente não interpretados. O comparador exige as fronteiras e símbolos de todas as seções, além da igualdade da imagem inteira. Cobertura binária de 100% não significa interpretação semântica de 100%.

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
| Reconstrução binária completa | Concluída | montagem independente da referência; cobertura explícita dos 1048576 bytes; `make verify-full` passando e SHA-256 igual a `roms.sha256` | 436 seções, incluindo intervalos explicitamente não interpretados |

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

`fixtures/local-storage/` executa helpers originais em pontos de entrada forçados, com memória sintética e sem carregar saves. Os **26.630 asserts** cobrem ponteiros, preservação de registradores, nomes iguais/diferentes, diretório livre/com correspondência/cheio, checksums e comparação de palavras. A referência não é alterada. Esses probes não simulam uma abertura natural completa e não promovem a confiança das interpretações.

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


### Handler do slot 4 em A $1E

`engine/startup/bank_a1e_slot4.asm` extrai `$4B90-$4D22` (403 bytes). O intervalo `$4A10-$4B8F` permanece não interpretado, com seu símbolo preservado, e o residual seguinte começa em `$4D23`. O slot usa `$CF40/$CF41`; todos os opcodes abaixo de `$90` seguem o corpo `$4CF1`, sem o retorno antecipado abaixo de `$80` dos slots inferiores. `$B1` modifica bits 0/4 de `$CF89`; `$C0` lê registros de três bytes pela base `$CF94/$CF95`, com índice mascarado mais um. `$FF` chega a três helpers externos, ainda numéricos.

A confiança é `PROBABLE`. 256 despachos param antes dos corpos/chamadas; 19 streams `$B0`, todos os 256 parâmetros `$B1/$C0`, quatro `$FE` e um tick até `$B0` adicionam 1.328 asserts. `$FE` lê `$CF4C` mas grava o decremento em `$CF0C`: a escrita cruzada é preservada, sem atribuir intenção ou corrigir o original. Contador 1 mantém os dois campos e segue o stream atual; zero segue o ponteiro salvo. Não há execução dos helpers `$FF`, demais corpos, fluxo natural ou áudio correto. A cópia privada preservou os 884 símbolos publicados em `f995835`, com ROM inteira idêntica e negativos reais passando.


### Handler do slot 5 em A $1E

`engine/startup/bank_a1e_slot5.asm` extrai `$4D23-$4EA9` (391 bytes), preservando `ResidualROM0F_4D23`; a chamada pelo tick agora é simbólica. O stream usa `$CF50/$CF51`. `$B1` modifica bits 1/5 de `$CF89`; `$C0` lê registros de dois bytes via `$CF96/$CF97`, com índice mascarado mais um. `$FE` grava seu decremento no próprio `$CF5C`, mantendo `$CF0C` intacto: essa diferença em relação ao slot 4 foi medida e preservada. Os helpers `$FF:$51C7/$5202/$527A` continuam externos.

A confiança é `PROBABLE`. 256 despachos parados, 19 durações `$B0`, todos os 256 parâmetros `$B1/$C0`, quatro contadores `$FE` e um tick até `$B0` adicionam 1.328 asserts. Contador 1 segue o stream atual sem gravar zero; os demais seguem o ponteiro salvo. Não há execução dos helpers `$FF`, demais corpos, fluxo natural ou áudio correto. A cópia privada preservou os 909 símbolos publicados em `ed80d01`, com ROM inteira idêntica e negativos reais passando.


### Handler do slot 6 em A $1E

`engine/startup/bank_a1e_slot6.asm` extrai `$4EAA-$502C` (387 bytes), preservando `ResidualROM0F_4EAA`; o tick usa a chamada simbólica. O stream fica em `$CF60/$CF61`. `$B1` modifica bits 2/6 de `$CF89`; `$C0` lê um ponteiro via `$CF98/$CF99` com índice mascarado, copia 16 bytes para wave RAM e não grava o índice em `$CF67`. Essa diferença em relação ao slot 2 foi preservada. `$FE` usa seu próprio `$CF6C`; `$FF` chama `$51C7/$522D/$526C`, ainda externos.

A confiança é `PROBABLE`. 256 despachos parados, 19 durações `$B0`, todos os 256 parâmetros `$B1/$C0`, quatro contadores `$FE` e um tick até `$B0` adicionam 1.328 asserts. A cópia usa tabela/ondas WRAM sintéticas e canal desabilitado; `$CF67` e `$CF0C` permanecem intactos nos respectivos probes. Não há execução dos helpers `$FF`, demais corpos, wave RAM com canal ativo, fluxo natural ou áudio correto. A cópia privada preservou os 934 símbolos publicados em `e8097ab`; imagem inteira idêntica e negativos reais passam.


### Handler do slot 7 e término dos slots superiores

`engine/startup/bank_a1e_slot7.asm` extrai `$502D-$5295` (617 bytes), preservando `ResidualROM0F_502D`: o último handler do tick e os helpers `$FF` dos quatro slots superiores. As oito chamadas do tick e as cadeias `$FF` superiores agora usam símbolos. O slot 7 usa `$CF70/$CF71`; `$B1` modifica bits 3/7 de `$CF89`, `$C0` grava o parâmetro cru em `$CF77`, `$B0` retorna como desconhecido e `$E0/$E1` operam sobre `$CF72/$CF7E/$CF7F` e `$FF22`. A tabela numérica `$4B08` permanece não interpretada. Os helpers limpam 16 bytes, executam escritas de restauração/reset e removem os bits correspondentes de `$CF89`; a ordem original de bytes/registros permanece intacta.

A confiança é `PROBABLE`. 256 despachos parados, 19 durações via `$C0`, todos os 256 parâmetros `$B1/$C0`, quatro `$FE`, um tick até `$C0`, 4.096 streams `$E0/$E1` (oito bases e todos os parâmetros) e quatro cadeias `$FF` superiores completas adicionam 9.528 asserts. `$E0/$E1` verificam a expressão original, incluindo wrap e OR, sem atribuir correção musical aos valores. As cadeias `$FF` verificam a limpeza exata, preservação dos demais campos e máscara final de `$CF89`; não demonstram restauração audível correta. A cópia privada preservou os 961 símbolos publicados em `1783bae`, com ROM inteira idêntica e negativos reais passando. Todos os handlers estão extraídos; os demais corpos, tabelas, fluxos naturais e temporização continuam pendentes.


### Instalação dos streams em A $1E

`engine/startup/bank_a1e_streams_4003.asm` e `bank_a1e_streams_40b8.asm` extraem `$4003-$406D` e `$40B8-$42B0` (612 bytes), preservando os aliases residuais. As entradas `$4003/$4006/$4009` chegam à instalação inferior, superior e inicialização. A instalação inferior salva os 64 bytes dos slots inferiores, lê deslocamentos de stream relativos ao cabeçalho e instala até quatro slots; `$CF80 = $FF` restaura o backup, sendo reservado em vez de índice 127. A superior lê canais 1–4 de um registro e ponteiros separados, limpa o slot escolhido e ativa seus bits em `$CF89`. Ambas exigem bit 7 da solicitação e consomem o primeiro byte do stream como contador mais um. Não se infere validade de contagens ou registros arbitrários.

A confiança é `PROBABLE`. 508 casos inferiores (127 índices × contagens 1–4), 512 superiores (128 índices × quatro canais), 256 solicitações inativas, inicialização literal, limpeza de 128 bytes, leitura de palavra, restauração `$FF` e uma cadeia instalação→ticks→quatro handlers adicionam 2.564 asserts. A inicialização lê 12 bytes de `$5000`, dentro do código do slot 6; a sobreposição permanece original, sem interpretar essa fonte como uma tabela válida no fluxo natural. Todos os registros e streams dos probes são WRAM sintética. A cópia privada preservou os 991 símbolos publicados em `33f43ea`; imagem inteira e negativos reais passam. Não há lançamento natural, proteção universal de índices/contagens ou prova de áudio correto.


### Carregador e solicitações residentes de A $1E

`home/bank_a1e_setup_21d7.asm` e `_22a7.asm` extraem `$21D7-$2241` e `$22A7-$23E3` (424 bytes), com os cinco thunks residentes agora simbólicos e os aliases preservados. O carregador seleciona B pelo par E/D, lê 12 bytes por HL nos campos `$CF92/$CF93`, `$CF90/$CF91` e `$CF94-$CF9B`, e restaura B via `$FFAD/$FFAE`. Essa é uma fonte concreta de ponteiros além da inicialização literal sobreposta em A `$1E`. Os wrappers solicitam streams inferiores/superiores ou ambos com um tick, selecionando B e A `$1E` antes das chamadas e restaurando os pares de HRAM e campos de acompanhamento. Preservam AF/BC/DE/HL; mantêm `DI/EI` originais, sem garantia sobre o estado anterior de IME.

A confiança é `PROBABLE`. Três fontes B, 16 solicitações inferiores, oito superiores com duas configurações anteriores de mapper, uma solicitação combinada seguida do tick residente e o pedido de contagem global adicionam 60 asserts. Conferem bytes efetivamente mapeados, registradores e campos dos streams; a cadeia combinada chega aos handlers `$B0` inferior e superior. Os registros/streams são sintéticos, não um lançamento natural; temporização de IRQ, validade universal dos objetos e áudio correto continuam sem prova. O privado preservou os 1.019 símbolos publicados em `d02dcb7`; imagem inteira e negativos reais passam.


### Cabeçalhos B e registros originais do índice 1

`data/bank_b21_a1e_header.asm`, `bank_b5b_a1e_header.asm` e `bank_b5c_a1e_header.asm` extraem três cabeçalhos de 12 bytes e os respectivos registros inferiores do índice 1 de 10 bytes (66 bytes). Os consumidores são os estados residentes que carregam B `$21/$5B/$5C:$6000` e solicitam `$81`. Os seis campos de cabeçalho permanecem palavras numéricas; os registros têm contagem quatro, um byte preservado sem significado atribuído e quatro deslocamentos relativos big endian. Os streams e tabelas ao redor continuam não interpretados. B `$5C` usa a metade física `$2E:$4000-$5FFF`, mapeada em `$6000-$7FFF`; `$21/$5B` usam metades físicas superiores. Todos os aliases residuais de início permanecem no mesmo endereço.

A confiança é `PROBABLE`. Quinze novos asserts verificam os três registros, carregam os cabeçalhos reais pelo thunk residente e executam a solicitação inferior `$81`, conferindo os quatro ponteiros e contadores derivados dos bytes originais. São entradas forçadas com dados de ROM, sem execução dos comandos desses streams ou lançamento natural do menu. O gate detectou e rejeitou uma localização física incorreta de `$5C`, corrigida antes da publicação. O privado preservou os 1.024 símbolos publicados em `8ed52c9`; ROM inteira idêntica e negativos reais passam.


### Prefixos dos primeiros streams originais

Os três fontes de cabeçalho agora incluem os dois primeiros ponteiros da tabela inferior e os quatro prefixos do registro 1, até o primeiro contador positivo: 146 bytes adicionais. B `$21` cobre `$6638-$6641/$6913-$691C/$6BA8-$6BB1/$6D2F-$6D3A`; B `$5B` cobre `$65DE-$65EA/$697F-$698B/$6CC4-$6CD0/$6EBD-$6EC9`; B `$5C` cobre `$6638-$6641/$6858-$6861/$702D-$7036/$77B4-$77BD`. Os símbolos de registros e ponteiros usam as posições físicas corretas; o ajuste `$2000` expressa a janela B do seletor par `$5C`. Os aliases residuais publicados continuam no mesmo endereço. Os gaps e a continuação dos streams permanecem não interpretados.

A confiança é `PROBABLE`. Seis novos asserts executam um tick residente após o carregamento/solicitação dos três cabeçalhos reais e conferem os 12 ponteiros finais e contadores. O primeiro contador instalado é 1; comandos com contador zero encadeiam até a fronteira medida. Os contadores finais são `$0B/$0B/$24/$18`, `$1B/$0E/$1D/$02` e `$3B/$07/$05/$01`, respectivamente. São entradas forçadas com ROM real, sem menu natural, extensão completa dos streams, temporização ou áudio correto. O privado preservou os 1.036 símbolos publicados em `ce7fda6`; imagem inteira e negativos reais passam.

### Registros originais selecionados por `$C0`

`data/bank_b21_c0_records.asm`, `bank_b5b_c0_records.asm` e `bank_b5c_c0_records.asm` extraem 69 bytes: um registro de três bytes para o slot 0, um de dois para o slot 1, um ponteiro e 16 bytes de wave para o slot 2, em cada banco. As leituras de `$44C6/$4682` usam `(índice & $1F) + 1` com stride 3/2; `$4825` usa o índice mascarado diretamente e copia 16 bytes pelo ponteiro. Os registros selecionados são B `$21:$6039/$6053/$6069 → $60BB`, B `$5B:$6024/$6043/$6065 → $609B` e B `$5C:$6024/$6041/$606D → $60DB`. O fonte físico B `$5C` usa endereços menos `$2000`; o ponteiro mantém o ajuste explícito. Os gaps permanecem não interpretados, sem afirmar o tamanho integral das tabelas.

A confiança é `PROBABLE`. Nove novos asserts verificam os campos dos slots 0/1 e o índice do slot 2 após o primeiro tick forçado, e uma entrada `$4825` independente copia os 16 bytes reais com o canal wave desabilitado. A fixture soma 26.639 asserts, sem comprovar áudio natural ou acesso wave durante reprodução. A cópia privada preserva os 1.066 símbolos publicados em `5d1415a`; comparação integral e negativos reais passam.

### Continuações lineares dos 12 streams originais

Os três fontes `bank_b21_a1e_header.asm`, `bank_b5b_a1e_header.asm` e `bank_b5c_a1e_header.asm` refinam mais 11.667 bytes, desde o contador já verificado até antes do primeiro `$FE`. Os corpos são B `$21:$6642-$690E/$691D-$6BA3/$6BB2-$6D2A/$6D3B-$6FFB`, B `$5B:$65EB-$697A/$698C-$6CBF/$6CD1-$6EB8/$6ECA-$7254` e B `$5C:$6642-$6853/$6862-$7028/$7037-$77AF/$77BE-$7E39`. Cada linha preserva um comando e sua duração, sem traduzir ou alterar os bytes. Os aliases residuais anteriores são mantidos. Essa extração linear parou antes de `$FE`; as primeiras arestas e seus fallbacks são refinados na seção seguinte.

A confiança é `PROBABLE`. Um modelo limitado de framing e contadores, independente das instruções SM83, mede 3.996 eventos com contador não zero e confere a execução de 2.433/3.899/3.838 ticks residentes (10.170 no total). A fixture desabilita cada slot após carregar seu último evento, antes de entrar em `$FE`. B `$21` slot 2 para em `$6D29`: o tail `$80,$00` até `$6D2A` é interpretado estaticamente, pois executá-lo encadearia diretamente ao loop. Uma primeira validação rejeitou a suposição de que toda fronteira estática era um ponto de parada com contador positivo; o contrato passou a distinguir os dois limites.

Os contadores longos preservam a divisão original dos bits e o retorno a `$FF` após decrementar o byte alto, sem substituí-los por um contador comum de 16 bits. Quatro casos de framing verificam entrada válida e rejeitam opcode desconhecido e durações truncadas. A fixture soma 51.006 asserts; a cópia privada preservou os 1.090 símbolos de `eeb564f`. Imagem inteira e negativos reais passam. Os ticks são entradas residentes forçadas: não demonstram IRQ natural, extensão completa dos loops, temporização musical ou correção audível.

### Primeiras arestas `$FE` e saídas `$FF` dos streams originais

Os três fontes de streams extraem mais 36 bytes: `$FE,$00,$FF` ao final de cada um dos 12 corpos lineares. `$2F`, após o `$FF`, permanece não interpretado. Os ponteiros `$FD` e contadores originais são conferidos no estado deixado pela execução anterior; todos os 12 contadores são zero. Em B `$21`, os ponteiros salvos são `$663E/$6919/$6BAE/$6D35` e o retorno carrega eventos até `$6642/$691D/$6BB2/$6D3B`. Em B `$5B`, são `$65E7/$6988/$6CCD/$6EC6`, retornando até `$65EB/$698C/$6CD1/$6ECA`. Em B `$5C`, são `$6669/$6901/$7126/$788A`, retornando até `$666D/$6905/$712D/$788E`: os retornos saltam uma introdução já coberta pelo corpo linear.

A confiança é `PROBABLE`. Entradas forçadas nos quatro handlers, com estado original preservado, verificam os 12 retornos, contadores e ponteiros salvos. B `$21` slot 2 executa também o tail `$80,$00` antes do `$FE`. Outros 12 casos impõem contador 1 e ponteiro na aresta: `$FE` então lê o contador `$00`, encadeia até `$FF` e limpa exatamente os 16 bytes do slot, mantendo os guards. Esse fallback é artificial; o estado original com contador zero não demonstra uma saída natural. Os 60 novos asserts elevam a fixture a 51.066; a cópia privada preservou os 1.114 símbolos de `5008cb7`. ROM inteira e negativos reais passam, sem evidência de IRQ/menu natural, repetição musical completa ou correção audível.

### Callback de status e helpers de menu A `$16`

`engine/startup/bank_a16_menu.asm` extrai `$41EA-$4226` e `$4AF0-$4B90` (222 bytes): callback de status, inicialização de campos e callbacks, preenchimento dos dois planos de background e limpeza de callbacks. Os chamadores em `bank_a16.asm` agora usam os símbolos publicados dessas entradas. O alias `ResidualROM0B_41EA` e os demais endereços são preservados; nessa unidade os gaps `$4312-$4AEF` e `$4B91-$5FFF` permaneceram não interpretados; a seção seguinte refina o callback instalado e seu helper.

A confiança é `PROBABLE`. `$4B36` preenche os 1.024 bytes em `$9800-$9BFF` com `$80` no plano 0 e `$00` no plano 1, deixando VBK 1, BC 0 e HL `$9C00`; suas esperas verificam STAT bit 1 e o código alterna DI/EI. `$4B78` zera os callbacks HRAM, instala `$D9` nos dois stubs, zera `$C219/$C21A` pelo thunk `$01DA` e limpa `$C1C2`. A inicialização `$4AF0` limpa cinco campos, define `$C5A3=1`, chama recursos ainda pendentes e instala callback `$4B91` em uma cauda medida. O callback `$41EA` separa A zero (BC `$02A3`, DE `$3ED8` antes da abertura) de A não zero (A `$0D`, DE `$4F5A` antes da chamada de apresentação).

Os 23 novos asserts executam quatro fills completos com LCD desligado, dois clears completos, duas caudas independentes de instalação e sete prefixos parados antes de recursos externos. Os fills conferem ambos os planos e guards; os stubs vazios mantêm os operandos antigos. A fixture soma 51.089 asserts; a cópia privada preservou os 1.150 símbolos de `9d82a44`. ROM inteira e negativos reais passam. Não há execução completa da inicialização/callback de status, menu natural, garantia de acesso com LCD ativo ou preservação do estado anterior de IME.

### Atualização do menu A `$16` e retângulo de dois planos

`engine/startup/bank_a16_refresh.asm` extrai `$4391-$440B` e `$4B91-$4BC9`; `data/bank_a16_menu_overlay.asm` extrai `$4ECA-$4ED1`. São 188 bytes adicionais. `InitializeA16MenuDisplay` agora aponta para `RefreshA16MenuDisplay`; o alias `ResidualROM0B_4B91` permanece. `$4391` recebe origem da tela em BC, dimensões em HL e fonte em DE; `$C63A` seleciona banco WRAM pelos três bits baixos e base `$9800/$9C00` pelo bit 7. A cópia avança a fonte sequencialmente pelos dois planos, mantém stride de 32 células no destino e restaura o banco WRAM salvo. VBK é forçado para 0 antes de salvá-lo e termina em 0; não preserva o plano original do chamador.

A confiança é `PROBABLE`. Com `$C5A9` não zero, o callback define `$C63A=7`, copia 14×6 células de `$D000` do banco 7 e aplica quatro células de overlay em `$9A2F-$9A32`: `$81-$84` no plano 0 e zeros no plano 1. Depois zera `$C5A9`. O caminho comum chama `$FF80` e a atualização pendente de paletas. Os 24 novos asserts executam oito callbacks completos (pedidos 0/1/80/FF, bancos iniciais 1/3) e quatro cópias diretas com bancos 3/7, origem (3,2), tamanho 4×2 e ambas as bases. Conferem todos os bytes dos mapas, guards, ordem de origem, banco WRAM e VBK. O LCD está desligado, `$FF80` contém um RET sintético temporário e não há paleta pendente; não é execução natural de DMA/menu/paletas. A fixture soma 51.113 asserts; o privado preserva os 1.161 símbolos de `00fce5d`. ROM inteira e negativos reais passam. Nessa unidade os gaps `$4312-$4390/$440C-$4AEF/$4BCA-$4EC9/$4ED2-$5FFF` permaneceram não interpretados; o dispatcher de campos é refinado abaixo.

### Dispatcher de campos A `$16` e formatação numérica original

`engine/startup/bank_a16_fields.asm` extrai `$4BCA-$4C86` (dispatcher, oito ponteiros e oito handlers); `home/a16_numeric_tiles.asm` extrai os thunks `$015C/$0162` e os corpos `$06A6-$06DE/$0722-$0746`. São 289 bytes. Os aliases `ResidualROM00_015C`, `ResidualROM00_06A6` e `ResidualROM0B_4BCA` permanecem. O dispatcher dobra A em 8 bits, lê o ponteiro em `$4BDD + ((2*A) & $FF)` e empilha retorno `$4BDC`; não há verificação de índice. Os oito ponteiros extraídos constituem um prefixo medido, sem demonstrar validade dos demais índices.

A confiança é `PROBABLE`. Seis handlers leem bytes de `$C73D/$C73E/$C73F/$C84B/$C84C/$C84D`; dois leem words de `$C747/$C745`. Escrevem os bytes numéricos originais em `$C655`, terminam com zero e chamam `$01E9`. O formato de byte gera dois bytes: para 0–99, tens zero usa `$10`, demais dígitos usam `$20 + dígito`; acima de 99, mantém `$4E,$47`. O formato de word divide por 100, usa somente o byte baixo do quociente e formata quociente/resto; depois substitui marcadores iniciais e internos conforme a lógica literal. Zero resulta em quatro `$10`; 25.600 tem o mesmo resultado, pelo wrap do quociente. Não houve tradução nem normalização desse comportamento.

Os 1.836 novos asserts conferem 256 despachos parados antes do JP, 1.536 prefixos de byte (todos os valores nos seis handlers), 36 prefixos de word (18 valores por handler) e oito entradas pela tabela. Os casos param antes da apresentação `$01E9`, verificam bytes, terminador, guards e retorno empilhado; não executam destinos desconhecidos de índices fora do prefixo. A fixture soma 52.949 asserts; o privado preserva os 1.173 símbolos de `e38df3f`. ROM inteira e negativos reais passam. A apresentação natural e o significado dos campos permanecem sem confirmação.

### Helpers aritméticos de largura fixa

`home/fixed_width_arithmetic.asm` extrai `$2012-$2069` (88 bytes): produto de bytes com resultado baixo, produto de bytes em HL, produto de words com resultado baixo e duas divisões. Os cinco thunks `$022B-$0237` e os formatadores numéricos usam os novos símbolos; `ResidualROM00_2012` permanece. O restante `$206A-$21D6` continua não interpretado.

A confiança é `PROBABLE`. Os produtos de byte retornam A baixo ou HL completo e devolvem C após oito rotações; o produto de words retorna `(DE*BC)&$FFFF`, deixa DE/A zero e mantém BC. A divisão de byte retorna H=resto/L=quociente; divisor zero retorna H=dividendo/L=`$FF`. A divisão de word executa 16 rodadas com resto intermediário de oito bits e devolve H=resto/L=byte baixo do quociente. Esse algoritmo não equivale a uma divisão ampliada para todos os divisores: 256 ÷ 255 retorna H/L zero, por overflow do resto; divisor zero retorna H=byte baixo do dividendo/L=`$FF`. A formatação por divisor 100 mantém seu quociente truncado original.

A fixture verifica todos os 65.536 pares de bytes nas três operações correspondentes, todos os 65.536 valores de DE com BC `$FFFF`, 324 pares representativos de words, todos os dividendos de word para divisores 0/100/255 e 126 casos de fronteira para divisores 1/2/10/127/128/129/254. O modelo de word reproduz as 16 rodadas e o overflow; não usa divisão de host como substituto. São 918.404 novos asserts, elevando o total a 971.353. O privado preservou os 1.200 símbolos publicados em `57113d1`; ROM inteira e negativos reais passam. Os domínios completos citados são sintéticos; não demonstram admissibilidade ou uso natural de todos esses operandos pelo jogo.


### Fila de apresentação e estados residentes

`home/queued_tile_text.asm` extrai `$27AA-$28BD` (276 bytes): setter, dispatcher, prefixo de cinco ponteiros e cinco handlers. Os thunks `$01E9/$01EC` usam os novos símbolos. O residual `$261C-$27A9` preserva seu alias; `$28BE-$2DC2` permanece não interpretado. O setter guarda HL em `$C1AB/$C1AC`, define estado 1 em `$C1B8` e zera `$C1B3/$C1B4`. O dispatcher usa `DispatchReturnTable`, dobra o índice em oito bits e não verifica limites; os cinco ponteiros são um prefixo medido.

A confiança é `PROBABLE`. O estado 0 retorna; o estado 3 zera o estado. O estado 2 zera o estado quando o byte apontado e `$C1B9` são zero; os demais caminhos chamam `$2DD0`. O prefixo do estado 1 usa `$C1BA`, bit 0 de `$FF96` e contador `$C1BB`: zero ou bit pressionado limpa o contador e chega a `$2E15`; caso contrário incrementa com wrap e compara com 4 para valor 1, ou 10 para os demais valores não zero. As caudas dos estados 2/4 usam bit 0 de `$FF97`, com chamadas externas ainda pendentes. Esses nomes não comprovam apresentação natural ou significado completo dos controles.

Os 3.221 novos asserts conferem quatro ponteiros pelo setter residente, 256 despachos parados antes do salto, três caminhos completos conhecidos, 2.048 prefixos de atraso, todas as 256 máscaras em cada cauda de entrada dos estados 2/4, três prefixos não terminados e duas caudas independentes. Param antes dos callees de renderização, polling e helper desconhecidos; não os substituem por stubs. A fixture soma 974.574 asserts. O privado preservou os 1.216 símbolos publicados em `9537816`; montagem integral, comparação byte a byte e negativos reais passam. Renderização, entrada natural, temporização e estados 1/4 completos permanecem pendentes.


### Consumidor de controles e produtor da fila de display

`home/queued_text_consumer.asm` extrai `$118F-$11A9` e `$2DD0-$2F1B` (359 bytes). Os thunks `$0207-$0213`, as duas entradas residentes para `$118F` e os estados anteriores usam símbolos. `ResidualROM00_1186` permanece no gap `$1186-$118E`; `ResidualROM00_2DD0` é alias do produtor do cursor. Os próximos residuais começam em `$11AA/$2F1C`. A interpretação é `PROBABLE`, com chamadas estáticas e probes sintéticos, sem trace natural.

`$118F` aceita somente contagens de `$C1C4` menores que 16, incrementa a contagem e grava E,D,C,B em `$C1CA + 4*contagem`; valores 16–255 não escrevem registros. `$2DE7` calcula DE com máscaras, SWAP e operações de oito bits sobre `$C1A5/$C1A6/$C1A8/$C1A9`; seus overflows são preservados. `$2DD0` usa esse DE, C=`$FF` e B=`$7E + (($FF8B>>3)&1)` e encadeia à fila. A interpretação como cursor não confirma temporização visual nem o consumidor posterior da fila.

`$2E15` consome um byte pelo ponteiro `$C1AB/$C1AC`. Zero define estado 3 quando `$C1B9` é zero; caso contrário decrementa o contador e restaura `$C1AD/$C1AE`. Controle 1 chama a progressão de linha; 2 lê um operando para `$C1BF`; 3 lê operando para `$FF9D`, salva o ponteiro de repetição, incrementa `$C1B9` e chama opcionalmente o ponteiro `$C1C0/$C1C1`; 4 chama `$2D53`, ainda pendente; `$0F` define estado 4. Os demais bytes calculam BC e chegam ao renderer `$2F1C`; `$FE/$FF` mantêm o carry original, decrementam C e marcam `$C1BE`. A extensão dos glyphs e a interpretação dos controles no texto japonês não foram afirmadas.

A progressão de coluna incrementa `$C1BC` e compara a coluna anterior com `$C1A8-1`, ambos em oito bits; a cauda pode cair na progressão de linha. Linha com coluna zero retorna sem avançar; caso contrário zera a coluna, soma 2 a `$C1BD` e define estado 2 apenas quando a nova linha é igual a `2*$C1A9` em oito bits. Comparações e wraps não foram substituídos por geometria ampliada.

Os 75.733 novos asserts conferem todos os 256 valores de contagem da fila, 4.096 combinações de coordenadas, 512 chamadas completas do cursor, todos os 256 contadores de término e operandos do controle 2, 512 controles 3 com callback nulo ou RET original forçado, 25.600 progressões de coluna, 5.120 controles de linha, 2.000 prefixos de glyph parados antes do renderer, controle `$0F`, controle 4 parado, 256 estados 4 completos e um estado 1 completo terminado. A fixture soma 1.050.307 asserts. O callback RET é uma entrada original artificial, sem comprovar callback natural. O privado preserva os 1.231 símbolos publicados em `a38147b`; imagem inteira e negativos reais passam. Permanecem pendentes renderer, helper `$2D53`, consumidores da fila, callbacks naturais, LCD/IRQ e apresentação japonesa completa.


### Renderer original, HDMA e endereçamento de tilemap

`home/queued_glyph_renderer.asm` extrai `$2F1C-$3030` (277 bytes): renderer, helper de offset e prefixo de 32 words com offsets de linha 0–31. `ResidualROM00_2F1C` permanece como alias; o próximo residual começa em `$3031`. O thunk `$0216` e o consumidor anterior usam o renderer simbólico, que referencia os helpers aritméticos existentes. A confiança semântica permanece `PROBABLE`.

O renderer desabilita interrupções, salva VBK, seleciona A `$02` e configura fonte HDMA `$3F00 + 16*glyph`, destino `$96B0 - 16*$C1C2` e ID de tile `$6B-$C1C2`, preservando aritmética original. O helper dobra C em oito bits, lê uma word em `$2FF1 + ((2*C)&$FF)` e soma B; o prefixo de 32 linhas não constitui uma checagem de limites. Soma a base `$C1B5/$C1B6`, grava o ID no plano 0 e o atributo lido de `$C1B0+$C1BF` no plano 1, com esperas STAT originais. Na transferência o código está em VBK 1; escreve `$80` em HDMA5, incrementa `$C1C2`, restaura o par A salvo em `$FFAB/$FFAC` e VBK e executa EI. Não garante preservação do estado anterior de IME.

Os 196.680 novos asserts verificam todos os 65.536 pares linha/coluna no helper, 65.536 prefixos renderer (todos os glyphs e contadores) e 36 chamadas completas com LCD ativo. Os prefixos param antes do helper de tilemap/disparo e conferem valores brutos dos registradores HDMA, registradores CPU e seleção de janela. A fixture inicialmente presumiu máscara no readback de HDMA3; a comparação foi corrigida para o byte bruto preservado pelo core, distinguindo-o do destino efetivo da transferência. Os completos usam glyphs 0/15/16/127/254/255, contadores 0/1/106 e VBK inicial 0/1; conferem todos os 8.192 bytes dos dois planos, 16 bytes de glyph da fonte realmente mapeada, tile/atributo, ausência de transferência pendente, contador e restauração do mapper/VBK.

A fixture soma 1.246.987 asserts; o privado preserva os 1.248 símbolos publicados em `248d658`. Imagem integral e negativos reais passam. LCD ativo nos probes é uma condição sintética controlada, não um menu natural, prova de temporização física ou confirmação do significado visual japonês. Os demais índices, bases, estilos e contadores não recebem garantia de admissibilidade natural. O consumidor da fila `$11AA` e o helper `$2D53` continuam pendentes.


### Preenchimento original do retângulo de texto

`home/queued_text_fill.asm` extrai `$2D53-$2DC2` (112 bytes). O residual `$28BE-$2D52` mantém seu símbolo; o thunk `$0201`, o controle 4 e o estado 2 usam `FillQueuedTextRectangle`, com o helper de offset já simbólico. A interpretação é `PROBABLE`, sustentada por chamadas estáticas e probes sintéticos.

O helper salva VBK, seleciona o plano 0, escolhe tile `$70` quando `$C1AA=1` ou `$79` nos demais casos e zera `$C1BC/$C1BD`. A origem usa B=`$C1A4`, C=`$C1A7-1`, o helper `$2FE0` e a base `$C1B5/$C1B6`. Preenche largura `$C1A8` e contagem de linhas `(2*$C1A9)&$FF`, gravando tile no plano 0 e atributo `$C1A3` no plano 1, com stride 32, esperas STAT e DI/EI originais. Restaura VBK ao retornar; EI não preserva o estado anterior de IME.

Dimensões byte zero não representam retângulo vazio: largura zero decrementa por 256 colunas; contagem de linhas zero decrementa por 256 linhas, inclusive alturas 0/128. Os probes executam somente combinações cujo destino inteiro fica em VRAM. O caso de 32×256 excedeu o limite padrão de 100.000 passos da fixture; os casos maiores passaram com limite específico de 2.000.000 passos. Esse limite finito é separado do padrão mantido para os outros calls, sem afirmar admissibilidade natural dessas dimensões.

Os 184 novos asserts cobrem 56 chamadas completas com LCD desligado (larguras 1/4/32/0, alturas 1/2/0/128 dentro do limite de VRAM, dois tiles e VBK 0/1) e 36 chamadas diretas, pelo controle 4 ou pelo estado 2, com LCD desligado/ativo. As últimas usam origem (3,2), tamanho 4×4, três valores de `$C1AA` e os dois VBKs. Conferem todos os 8.192 bytes de ambos os planos, regiões sobrepostas da largura zero, guards, campos, HL/BC finais nos casos diretos e transições dos chamadores. A fixture soma 1.247.171 asserts; o privado preserva os 1.257 símbolos publicados em `a27c33d`. Imagem integral e negativos reais passam. São entradas forçadas; significado de tela, geometria natural, IRQ e timing físico continuam sem confirmação. O consumidor da fila `$11AA` permanece pendente.


### Consumidor da fila e construção do shadow de display

`home/queued_display_shadow.asm` extrai `$11AA-$12B8` (271 bytes), preservando `ResidualROM00_11AA` como alias. O thunk `$0261` agora usa `BuildQueuedDisplayShadow`; o wrapper separado `$12B9-$12BE` permanece não interpretado. A confiança é `PROBABLE`, sem lançamento natural ou transferência OAM neste probe.

O consumidor zera os 160 bytes de `$C000-$C09F`. Contagem zero retorna; com fila ativa zera `$C1C4`, seleciona A quando o byte alto `$C1C6` do ponteiro de tabela é menor que `$60`, ou B nos demais casos, usando `$C21C/$C21D`. Define capacidade 40 em `$C1C7` e consome registros em `$C1CA`. Registro com terceiro byte `$FF` escreve D,E,quarto-byte,`$C1B7` no shadow. Os demais registros usam dois níveis de ponteiros: terceiro byte dobrado na tabela `$C1C5/$C1C6`, depois quarto byte dobrado na tabela apontada. O objeto contém contagem e registros de quatro bytes; soma offsets aos dois primeiros bytes da solicitação com wrap e preserva tile/atributo. A expansão não grava além das 40 entradas; restaura o par de mapper A ou B salvo em HRAM e executa EI, sem restaurar IME anterior.

A fixture executa 544 casos diretos (contagens 0–16, 16 padrões e ambos os caminhos A/B) e 512 objetos expandidos (todos os 256 bytes de contagem e dois padrões), conferindo todos os 160 bytes, guarda posterior, ordem dos campos, wrap e bytes efetivamente remapeados após restauração. As duas tabelas e os objetos expandidos são WRAM sintética; não provam validade dos objetos originais. O primeiro ensaio rejeitou um thunk incorreto na fixture, corrigido para `$0261` antes da validação final.

Um prefixo artificial expande 40 entradas e depois solicita um registro direto `$FF`. Ele para em `$122A` com capacidade zero e SP `$CFF8`, antes dos pops: o branch do caminho direto pula o `pop af` que existe no caminho com espaço, mantendo o AF empilhado. Isso documenta uma discrepância de pilha nesse estado forçado, sem executar o retorno corrompido ou afirmar que o menu natural o produz. A expansão comum com objetos maiores que 40 é verificada separadamente até retorno completo. Não houve correção dos bytes originais.

Os 2.113 novos asserts elevam a fixture a 1.249.284; o privado preserva os 1.262 símbolos publicados em `a9cfe26`. Montagem integral e negativos reais passam. Continuam pendentes objetos/tabelas reais, consumidores naturais da fila e DMA do shadow; equivalência binária e esses casos sintéticos não confirmam sprites visíveis nem o estado artificial como falha natural.


### Ponteiro de tabela e dois objetos originais A `$0F`

`home/display_object_table.asm` extrai o setter `$1186-$118E` (9 bytes), preservando seu alias; `$0258` usa o nome simbólico. `data/bank_a0f_display_objects.asm` extrai o prefixo de setup A `$0F:$409C-$40B1`, o primeiro ponteiro em `$5288`, dois ponteiros de variante em `$529E` e os objetos `$52A2-$52C2/$52C3-$52EB`: 102 bytes adicionais. A metade superior física `$07:$6000-$7FFF` aparece em A `$0F:$4000-$5FFF`; os ponteiros usam explicitamente símbolos físicos menos `$2000`. O alias residual `$07:$6000` permanece. Gaps e o tamanho integral das tabelas continuam não interpretados.

O setter guarda HL em `$C1C5/$C1C6`. O prefixo original desabilita interrupções, seleciona VBK 0/WRAM 0, define `$C21C=$0F/$C21D=0` e chama `$0258` com HL `$5288`; o probe para antes da continuação `$40B2`, sem afirmar inicialização completa. O primeiro ponteiro chega a `$529E`; variantes 0/1 apontam para objetos com contagem 8/10, cada peça formada pelos quatro bytes consumidos pelo shadow. Os objetos são extraídos até `1 + 4*contagem`, sem estender essa fronteira às tabelas vizinhas.

A confiança permanece `PROBABLE`. Quatro chamadas do setter conferem guards e registradores; um prefixo original verifica os campos; três checks conferem ponteiros/contagens mapeados. A expansão dos dois objetos originais executa todas as 65.536 combinações X/Y por variante, verificando todos os 160 bytes do shadow, zeros finais, guarda, capacidade e restauração de A. São 262.156 novos asserts, somando 1.511.440; o privado preserva os 1.277 símbolos publicados em `83e67d1`. Montagem integral e negativos reais passam. Os dados dos objetos são ROM real, mas os índices 0/1 e as posições são entradas forçadas; não provam uso natural, significado visual, fronteiras integrais das tabelas ou OAM DMA.


### Seleção de variante e produtor de posição A `$0F`

`engine/startup/bank_a0f_position.asm` extrai A `$0F:$4306-$4319/$438A-$43BE` (73 bytes), em posições físicas `$07:$6306-$6319/$638A-$63BE`. O alias residual `$07:$60B2` permanece; os gaps `$60B2-$6305/$631A-$6389/$63BF-$7287` continuam não interpretados. A montagem primeiro rejeitou JR com alvo ajustado por `$2000`; os branches relativos usam os labels físicos, enquanto ponteiros absolutos de janela mantêm seu ajuste explícito. Os bytes finais são originais.

A interpretação é `PROBABLE`. O seletor define `$C76B=0` para `$C767<4`, ou 1 nos demais casos. O produtor lê `$C766`, soma 1 quando o valor é pelo menos 5, compara o resultado com `$0B` e soma mais 1 quando necessário; ambas as somas são de oito bits. Executa três RLCA e soma `$10`, guardando X em `$C768`. Para Y, lê `$C767`, executa quatro RLCA e soma `$50`, guardando em `$C769`. Enfileira DE=X/Y, C=0 e B=`$C76B` pelo thunk `$025E`; isso liga estaticamente o primeiro índice da tabela às duas variantes originais. As rotações mantêm os bits que voltam pelo wrap, sem substituí-las por multiplicações ampliadas.

A fixture encadeia seletor → produtor → objetos originais → shadow para todos os 65.536 pares `$C766/$C767`, conferindo variante, posição, quatro bytes de fila, todos os 160 bytes finais, guarda, capacidade e campos do mapper restaurado. Quatro chamadas adicionais verificam contagens de fila 0/15/16/255: a posição é atualizada mesmo quando a fila rejeita o registro; os bytes de fila e guards permanecem conforme a capacidade original. São 393.225 novos asserts, somando 1.904.665. O privado preserva os 1.286 símbolos publicados em `33dbe88`; montagem integral e negativos reais passam. Esse é um encadeamento forçado de componentes originais, sem execução natural do menu, prova de domínio geométrico admissível ou transferência OAM.
