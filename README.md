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

A montagem contém **1048576 bytes em 451 seções**, todos comparados byte a byte com a referência externa. Os 247 trechos analisados somam 38232 bytes; os demais 1010344 bytes estão explicitamente não interpretados. O comparador exige as fronteiras e símbolos de todas as seções, além da igualdade da imagem inteira. Cobertura binária de 100% não significa interpretação semântica de 100%.

## Ciclos com validação

O trabalho segue o ciclo do Mobile Trainer: medir a próxima frente, extrair uma unidade coerente, conferir em cópia privada, repetir os checks no fonte final, publicar o checkpoint e atualizar a OMM. A continuidade não depende de o Operador escolher cada próximo trecho.

```sh
make verify REFERENCE_ROM="/caminho/externo/Net de Get - Minigame @ 100 (Japan).gbc"
```

Esse alvo executa montagem, `sym-check`, `test` e `compare`. `make private-check REFERENCE_ROM="/caminho/externo/ROM.gbc"` repete o ciclo em cópia privada, compara a imagem com a árvore atual e exige a preservação de todos os símbolos de endereço do HEAD publicado. O manifesto `config/excerpts.tsv` fixa banco físico RGBDS, início, fim inclusivo e símbolo de entrada de cada seção. Os 24 testes do verificador incluem falhas deliberadas: seções ausentes/extras/movidas, símbolos ausentes/movidos/duplicados, sobreposição, bytes alterados e imagens truncadas. São testes sintéticos da ferramenta, sem evidência de execução natural do jogo.

As novas rotinas cobrem ROM0 `$254E-$25CA` (dispatcher, 125 bytes) e `$3E00-$3ED7` (reconstrução da lista e cópia de template, 216 bytes). Seus nomes descritivos permanecem `PROBABLE`. O dispatcher restaura o seletor A salvo e impõe tipo ROM; a varredura pula o setor reservado `$70`, percorre seletores até `$80` e chama o checksum `$38B0`, agora extraído em `home/minigame_checksum.asm`. O ponteiro inicial HL da lista vem do chamador; nenhuma capacidade universal do destino foi demonstrada.

O intervalo do template usado por `$3EAE` está extraído em `data/local_list_template.asm`: 112 bytes, delimitados pela leitura estática. Isso não demonstra a extensão completa do objeto ou a semântica de cada campo. Nenhum texto japonês é traduzido.

A rotina de checksum `$38B0-$391B` preserva o atalho para o valor armazenado `$B33B`. Seu contador de páginas é calculado em 8 bits com `SWAP` e `RLCA`; não foi substituído por uma multiplicação ampliada. A equivalência dos bytes não demonstra que qualquer quantidade de blocos seja tratada como uma soma completa de payload. A interpretação permanece `PROBABLE`.

## Plano e pendências

Objetivo binário autorizado pelo Operador: uma ROM montável a partir do fonte RGBDS, idêntica byte a byte à referência original de 1 MiB. Esse critério foi atingido com a base completa de fontes, usando a referência externa somente para verificação. O trabalho semântico continua sobre os intervalos não interpretados, preservando os bytes japoneses e os níveis de evidência. Este README é o plano canônico; as notas de pesquisa contêm a análise e a OMM aponta para o estado verificado.

| Fase | Estado | Critério de conclusão | Dependências |
| --- | --- | --- | --- |
| Estrutura e validação parcial | Implementada | montagem, manifesto, símbolos, testes negativos, comparação e cópia privada passando | RGBDS, Python, referência externa |
| Lista e despacho local | Em andamento | extrair chamadores e dependências com fronteiras justificadas e bytes equivalentes | helpers, tabela, template e checksum já extraídos |
| Menus e representação dos dados | Em andamento | ligar consumidores aos intervalos; nomes semânticos só com evidência suficiente | mapa das rotinas e seleção de janela |
| Expansão para outros domínios | Em andamento | escolher unidades por consumidores conhecidos e eliminar lacunas progressivamente | avanço das fases anteriores |
| Reconstrução binária completa | Concluída | montagem independente da referência; cobertura explícita dos 1048576 bytes; `make verify-full` passando e SHA-256 igual a `roms.sha256` | manifesto integral de seções, incluindo intervalos explicitamente não interpretados |

### Trabalho a fazer

1. Seguir os callees da inicialização A `$16:$4000`, agora extraída até `$41E9` em `engine/startup/bank_a16.asm`, os callees dos dez estados já extraídos da tabela `$03A8` e a manutenção de VBlank `$2242`; fechar os callees ainda numéricos dos menus, incluindo as dependências dos quatro handlers A `$12:$4175/$41A2/$41D2/$4202` e da inicialização já extraídos, em especial `$459F` e a integração natural dos três fluxos de input/ação já extraídos, a integração natural dos tails de texto já extraídos `$5C2F/$5C55` e os consumidores/recursos de `InitializeA12TileFrames`, preservando fronteiras e símbolos.
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

Não há decisão do Operador ou bloqueio externo necessário para a próxima unidade. Hardware não validado é um limite da evidência, sem impedir o disassembly estático. Tradução e implementação REON/Mobile Adapter ficam fora do trabalho atual.

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


### Setup A `$0F`, contagem da lista e limpeza de callbacks

`engine/startup/bank_a0f_setup.asm` recebe o prefixo publicado `$409C-$40B1` e extrai `$40B2-$4140/$4141-$415B` (170 bytes adicionais). `bank_a0f_list_count.asm` extrai `$44AE-$44D6` (41 bytes) e `data/bank_b5a_a1e_header.asm` extrai o cabeçalho B `$5A:$6000-$600B` (12 bytes). São 223 bytes novos. `PrepareA0FDisplayTablePrefix`, `ResidualROM07_60B2` e `ResidualROM2D_4000` permanecem nos endereços publicados. O setup passa a ter alias `InitializeA0FDisplay`; os objetos ficam no fonte de dados. B `$5A` usa a metade física inferior `$2D:$4000-$5FFF` mapeada em `$6000-$7FFF`, e o cabeçalho preserva seis words numéricas, sem afirmar extensão das tabelas/streams.

A confiança é `PROBABLE`. A continuação instala stub JP para `$47CD` e callback `$47CE`, zera o outro callback e deixa seu stub vazio com `$D9`. Depois de EI, limpa 19 bytes em `$C766-$C778`, inicializa `$C772=1` e separa `$C765` zero dos demais valores. Zero define `$C76A=0`, `$C775/$C776=$94/$95`, `$C76F=8`, `$C76E=4` e ponteiro `$4E20`; não zero define 2, `$98/$99`, `$10`, 0 e ponteiro `$52EC`, respectivamente. Guarda o ponteiro em `$C773/$C774`.

A chamada `$44AE` foi inicialmente tratada como recurso pendente; medir seu corpo mostrou uma contagem da lista em `$C74E`, independente do ponteiro anterior em HL. Zera `$C76C/$C76D`, lê até zero, incrementa `$C76C` para cada entrada e `$C76D` quando o byte é `$FE/$FF`. Os contadores são de oito bits; não se afirma um tamanho universal da lista nem segurança sem terminador. Depois, o setup carrega HL `$6000`/DE `$005A` e chama o carregador de cabeçalho A `$1E`, que copia 12 bytes reais de B `$5A` e restaura B. `$4141` desabilita interrupções, limpa os quatro destinos de callback/stub, executa EI e retorna.

512 prefixos conhecidos (todos os 256 valores de `$C765`, VBK 0/1 e WRAM inicial 3/7) param antes da contagem, conferindo 19 campos, guards, ponteiro, callbacks, stubs, VBK 0, WRAM efetivo 1 e IME ativo. Quatro limpezas completas preservam os operandos antigos dos stubs vazios. Outros 68 calls verificam comprimentos 0–16 com bytes 1/`$FD/$FE/$FF`, e 96 inicializações completas combinam quatro valores de modo, três comprimentos, quatro classes de byte e dois pares anteriores de B. Conferem contagens, campos de modo, os 12 campos reais de cabeçalho, HL `$600C` e oito bytes efetivamente remapeados após restaurar B. São 848 novos asserts, somando 1.905.513; o privado preserva os 1.294 símbolos publicados em `c2c5cd6`. Montagem integral e negativos reais passam.

A inicialização completa é verificada em entrada forçada com lista sintética delimitada e cabeçalho real. Não houve IRQ natural, execução dos callbacks instalados, stream de áudio ou interpretação completa dos recursos `$4E20/$52EC`. IME ativo é efeito de EI, sem preservação do estado anterior. Uso natural da lista, menu e temporização continuam pendentes.


### Graphics e tilemap originais A `$0F`

`engine/startup/bank_a0f_graphics.asm` extrai `$415C-$41C4` (105 bytes), preservando `ResidualROM07_615C` como alias. O thunk `$0198` para cópia de VRAM também é extraído (3 bytes). `data/bank_a0f_display_graphics.asm` extrai 1.764 bytes de recursos medidos: graphics `$47E0-$4E1F` (1.600 bytes), mapas alternativos `$4E68-$4EB7/$4EB8-$4F07` (80 bytes cada) e células de dois bytes `$4F08-$4F0B`. São 1.872 bytes adicionais. Os símbolos residuais anteriores permanecem; gaps em torno dos recursos, incluindo `$4E20-$4E67`, continuam sem interpretação.

A confiança é `PROBABLE`. A rotina copia os graphics para `$8800-$8E3F` pelo plano de VRAM inicialmente selecionado, sem selecionar VBK antes da cópia. `$C765` zero usa o mapa `$4E68` e célula `$4F08`; os demais valores usam `$4EB8/$4F0A`. Seleciona VBK 0, copia 20×2 células por plano para `$9800`, com stride 32 e fonte sequencial dos dois planos. Depois repete 120 vezes uma cópia 1×1 da mesma célula de dois bytes, em destinos consecutivos `$983C-$98B3`. As células originais são tile/atributo `$88/$00` ou `$E0/$07`. VBK termina em 0, independentemente do plano que recebeu os graphics. Não houve tradução ou atribuição de significado visual aos bytes japoneses.

A fixture executa 512 calls com LCD desligado (todos os 256 valores de modo, VBK inicial 0/1) e oito com LCD ativo (modos 0/1/`$80/$FF`, ambos os VBKs), cada um com limite finito de 2.000.000 passos. Confere todos os 8.192 bytes dos dois planos: graphics no plano inicial, as 40 células e atributos do mapa selecionado, as 120 células repetidas e todos os bytes restantes intactos. Também confere VBK final 0, modo preservado e contador final A=120. São 1.040 novos asserts, somando 1.906.553; o privado preserva os 1.308 símbolos publicados em `2ed84f1`. Montagem integral e negativos reais passam. São chamadas forçadas com resources de ROM real; não confirmam tela natural, paletas, OAM DMA, IRQ ou temporização física.


### Ajuste de coluna na última linha A `$0F`

`engine/startup/bank_a0f_selection.asm` extrai `$431A-$433E/$433F-$4389` (112 bytes), em posições físicas `$07:$631A-$6389`. `ResidualROM07_631A` permanece como alias no endereço publicado. A primeira rotina recebe a linha em A; para A menor que 4 preserva `$C766`, e nos demais casos escolhe coluna 1/6/11 conforme a coluna anterior seja menor que 5, menor que 10 ou maior. Preserva AF pelo push/pop original. A segunda lê a linha de `$C767`; abaixo de 4 preserva a coluna, e nas demais linhas remapeia exatamente 0/7→11, 2/10→6 e 5/12→1, mantendo as outras colunas. A interpretação continua `PROBABLE`, sem afirmar o domínio natural admissível da seleção.

A fixture executa todas as 65.536 combinações de linha/coluna por rotina, conferindo resultado e guards; a primeira também confere A e os 16 padrões válidos dos flags. São 131.072 calls completos, 262.144 novos asserts e total de 2.168.697. O privado preserva os 1.322 símbolos publicados em `1b9ad32`; montagem integral e negativos reais passam. O primeiro manifesto ainda continha a fronteira residual antiga e foi rejeitado por sobreposição; a entrada foi substituída pelas duas fronteiras medidas. O compilador também rejeitou o acesso incorreto ao union de flags da fixture, corrigido para `f.packed`. Os bytes originais não foram alterados.

Os consumidores de `$C773/$C774` foram localizados estaticamente em `$406A/$47AF`: passam o ponteiro a `$0177/$017A` com A=4. A extensão integral dos recursos `$4E20/$52EC` continua pendente dos consumidores residentes, sem inferir o tamanho pela proximidade de dados já extraídos. Os calls acima são sintéticos, sem execução natural do menu ou IRQ.


### Componentes de cor e deltas residentes

`home/color_components.asm` extrai `$08FB-$0924/$0925-$096E/$096F-$0994` (154 bytes). O residual `$07E7-$08FA` conserva `ResidualROM00_07E7`; os preparadores e o escalador continuam sem extração. A interpretação é `PROBABLE`: `$08FB` lê words de dois bytes, separa três componentes de cinco bits, ignora o bit 15 e grava cada componente multiplicado por 2.048 em uma word. `$0925` produz `(31-componente)*64`. Ambos usam o contador C com loop posterior: C=0 executa 256 cores, não zero. Consomem dois bytes e produzem seis por cor.

`$096F` força C=64 e lê os bytes altos de três words por cor, partindo de HL no primeiro byte alto. Ignora os bytes baixos. Recompõe dois bytes com as rotações/máscaras originais: vermelho `>>3`, verde RLCA duas vezes e azul RRCA uma vez. O bit 15 do destino fica zero. Não há restrição de entrada nesses helpers; as rotações de bytes altos arbitrários são mantidas, sem substituir por clamp ou aritmética ampliada.

A fixture verifica todas as 65.536 words por expansor, os 256 contadores de cada expansor (inclusive o wrap de C=0) e 256 padrões dos 384 bytes usados pelo empacotador fixo. Confere cada byte produzido, avanço de HL/DE, C final e guards. São 131.840 calls completos e 263.680 novos asserts, somando 2.432.377. O privado preserva os 1.333 símbolos publicados em `0daff8d`; montagem integral e negativos reais passam. Entrada é WRAM sintética, sem paleta visível ou trace natural.

Os preparadores originais `$07E7/$0805` chamam os expansores com C=64; a leitura estática de `$4E20` alcança `$4E9F`, sobrepondo `$4E68-$4E9F` do tilemap já extraído. Essa sobreposição é preservada e não prova um objeto independente de 128 bytes nem o domínio natural do recurso. Falta verificar os preparadores completos, o escalador `$088D` e o consumidor por ticks antes de atribuir significado visual ou temporização.


### Preparação e ticks das transições de cor

`home/color_transition.asm` extrai `$07E7-$08F1` (267 bytes); `data/color_transition_counts.asm` preserva o prefixo de nove bytes `$08F2-$08FA`. Três thunks `$0177/$017A/$017D` são extraídos (9 bytes), mantendo `ResidualROM00_0177`; `ResidualROM00_07E7` passa a alias do primeiro preparador. São 285 bytes adicionais. O prefixo possui valores `$20,$10,$08,$04,$02,$01,$20,$40,$80`; não se afirma um limite validado para o parâmetro. A montagem rejeitou a primeira tentativa porque o fonte literal antigo de `$0177` ainda duplicava o alias; ele foi substituído pelo trecho medido e o residual `$0180-$018B`.

A confiança é `PROBABLE`. O primeiro preparador expande 64 cores para deltas, inicializa 192 words do acumulador em `$F800` e define `$C21F`; o segundo expande as cores no acumulador, deriva deltas da distância dos componentes até 31 e define `$C220`. Ambos chamam o escalador. Parâmetro 2 mantém os deltas e retorna 32; 0/1 fazem shifts lógicos à direita de 2/1 bits; os demais fazem `(parâmetro-2)` shifts à esquerda com wrap de 16 bits. O contador retornado é lido do endereço calculado original; parâmetros altos alcançam bytes de código além do prefixo. Os testes preservam esses reads, sem declarar esses parâmetros válidos para o menu.

O tick prioriza `$C220` não zero: decrementa e soma os 192 deltas ao acumulador. Só quando ele está zero considera `$C21F`, decrementando e subtraindo. As operações preservam carry/borrow entre os dois bytes da word e fazem wrap de 16 bits. Após um caminho ativo, empacota 64 cores em `$C222-$C2A1` e marca `$C221=1`. Com ambos os contadores zero preserva os buffers e a flag. O tick não realiza upload de paleta por si só.

A fixture confere 256 parâmetros do escalador, 1.024 preparações completas com os recursos reais `$4E20/$52EC`, 768 ticks (contadores 0–255, caminhos separados e prioridade com ambos ativos) e quatro cadeias de preparação com parâmetro 4 e oito ticks completos. Confere todos os bytes de deltas/acumulador/cores empacotadas, contadores, flags e guards pertinentes. São 2.116 calls completos, 4.232 novos asserts e total de 2.436.609. O privado preserva os 1.339 símbolos publicados em `0cc664c`; montagem integral e negativos reais passam. Escalador e preparadores usam limite finito de 1.000.000 passos para os parâmetros extremos. As quatro cadeias também chamam o upload publicado `$018C` após cada tick com LCD desligado: conferem todos os 64 bytes BG e 64 OBJ, flag zerada e AF/BC/HL preservados. O encadeamento usa bytes reais da ROM e confirma a leitura sobreposta `$4E20-$4E9F`; continua sendo execução forçada, sem tela natural, VBlank, upload com LCD ativo, temporização ou validação física.


### Dispatcher e navegação de entrada A `$0F`

`engine/startup/bank_a0f_input.asm` extrai `$41C5-$41F0/$41F1-$4305` (321 bytes), preservando `ResidualROM07_61C5`. Branches relativos usam labels físicos; chamadas e jumps absolutos para A `$0F` usam o ajuste explícito `$2000`. A interpretação é `PROBABLE`. `$C1B8` não zero bloqueia a entrada. `$C772=0` retorna; `$63` só é zerado quando `$C220=0`, preservando a segunda leitura redundante original. Os demais estados executam o handler e o produtor de posição publicado.

O handler processa os quatro bits altos de `$FF98` em ordem `$10,$20,$80,$40`: direita, esquerda, avanço e recuo de linha. Colunas usam wrap e remapeamento da última linha; avanço de linha chama o snap antes da comparação com 5, enquanto recuo só chama o snap quando o decremento produz `$FF`. Essa assimetria e as entradas fora do domínio normal são preservadas. Cada direção chama o request superior A `$1E` com `$83/$82`; o teste usa uma tabela WRAM sintética com registro vazio terminado em zero, mantendo o código original do wrapper, sem sons reais ou substituição de instruções.

Os bits de `$FF97` são priorizados `$02`, depois `$01`, depois `$08`, depois `$04`. Os dois primeiros encaminham para `$451F/$43F0/$455D` conforme posição. No ramo de colunas pelo menos 6 da última linha, `$C764` recebe `(coluna & 8)>>3`; quando ele é 1, a lista `$C74E` vazia ou formada apenas por `$10` até zero rejeita a ação. Uma entrada diferente de `$10` e zero permite prosseguir. O caminho aceito inicia o countdown residente, define `$C772=$63` e chama `$47AA`. Não se afirma tamanho universal ou segurança de uma lista sem terminador. `$08` reposiciona para coluna 11/linha 4 e seleciona variante; `$04` encaminha para `$455D`.

A fixture verifica todos os 65.536 pares `$C1B8/$C772` sem botões, todos os 256 valores de `$C220` no estado `$63`, e 73.728 chamadas completas de navegação (16 combinações direcionais, cada eixo 0–255 e nove fronteiras do outro eixo). Usa fila cheia para conferir que campos de posição mudam sem escrever além da capacidade. Outros 6.912 prefixos cobrem todos os bytes de botões, nove posições e três listas sintéticas delimitadas; param na entrada dos callees pendentes ou retornam quando não há chamada. Conferem destino, SP, posição, escolha, estado, variante e countdown. São 139.520 calls completos, 6.912 prefixos, 292.864 novos asserts e total de 2.729.473. O privado preserva os 1.361 símbolos do commit `f8a4750`, validado localmente enquanto um erro interno transitório do GitHub atrasava a publicação. Montagem integral, CPU privado e negativos reais passam. Os retornos de `$451F/$43F0/$455D/$47AA`, o loop natural do menu, IRQ e áudio permanecem pendentes; prefixos não são provas desses retornos.


### Helpers de ação: recurso, recuo da lista e indicadores

`engine/startup/bank_a0f_action_helpers.asm` extrai `$43BF-$43EF` (49 bytes), `$451F-$455C` (62) e `$4628-$468A` (99): 210 bytes adicionais. `ResidualROM07_63BF` permanece no primeiro helper e `ResidualROM07_64D7` no residual inicial anterior às ações. A confiança continua `PROBABLE`. O seletor preserva os bytes apontados: quando o bit 0 de `$C765` está ativo, transforma A em `2+(A&1)`; caso contrário usa A original. Valores 0/1/2 apontam para `$5334/$537C/$53C4`, e os demais para `$540C`. Os objetos apontados permanecem sem extensão afirmada.

O recuo `$451F` retorna quando `$C76C=0`. Nos demais casos decrementa esse contador, escreve zero em `$C74E+contador` e examina o byte anterior. Se for `$FE/$FF`, zera também esse byte e decrementa `$C76C/$C76D` com wrap de oito bits. Chama então o redesenho `$45A0`, ainda pendente. A fixture calcula as mutações sobre um snapshot da memória, incluindo a aliasagem entre destinos e contadores em valores forçados altos. Com contagem 1, o byte anterior está em `$C74D`; marcadores artificiais nesse guard podem causar underflow. Isso preserva o contrato literal, sem afirmar ocorrência natural ou segurança de contadores fora do domínio do menu.

O desenho `$4628` copia três pares de tiles/atributos para `$9A02/$9A08/$9A0E`. O primeiro usa `$C775/$C776` de entrada, os demais usam `$8E/$8F` e `$90/$91`. Os atributos são `$C777/$C778` nas três cópias. Seleciona VBK 0 e termina com VBK 0, deixando `$C775/$C776=$90/$91`; os atributos e guards permanecem. Não se atribui significado visual aos tiles.

A fixture executa todos os 65.536 pares de modo/entrada do seletor, 3.072 prefixos de recuo (todos os contadores, quatro classes do byte anterior e três contagens auxiliares), 128 chamadas completas do dispatcher com bit `$02` e lista vazia, e 520 desenhos completos (512 com LCD desligado e oito com LCD ativo). Os prefixos param antes do redesenho ou retornam com contador zero; os desenhos conferem todos os 8.192 bytes de ambos os planos de VRAM. São 138.512 novos asserts, somando 2.867.985. Os calls completos de recuo só cobrem lista vazia; redesenho de lista não vazia, recursos selecionados, loop natural, áudio e temporização física continuam pendentes. O privado preserva os 1.383 símbolos publicados em `1a492b9`; montagem integral e negativos reais passam.


### Configuração por registro e consumidor bloqueante de texto

`home/indexed_text_setup.asm` extrai `$2753-$2798` (70 bytes), `$2799-$27A9` (17) e `$28BE-$28E2` (37); `data/bank_a0f_text_records.asm` extrai os quatro registros alcançados em `$5268-$5287` (32 bytes). São 156 bytes adicionais. `ResidualROM00_28BE` permanece como alias; os residuais iniciais `$261C/$6F0C` mantêm seus endereços. Os thunks `$01E3/$01E6/$01EF` passam a usar os símbolos nomeados. O prefixo de dados preserva os oito bytes por registro; os três bytes finais não recebem semântica afirmada nem se declara o tamanho de uma tabela maior.

A confiança é `PROBABLE`. A configuração calcula `DE + 8*A` em 16 bits e lê cinco campos. Guarda a primeira coordenada somada a 1 em `$C1A4`, a segunda somada a 2 em `$C1A7`, width em `$C1A8`, height em `$C1A9` (C como fallback quando o campo é zero) e kind em `$C1AA`. O endereço em `$C1A5/$C1A6` soma as coordenadas originais ao lookup residente e à base `$C1B5/$C1B6`, com wrap de 16 bits. Retorna esse endereço em HL/DE, A como byte alto, B como byte alto da base e C como fallback original; flags vêm do OR do campo kind. Não há clamp nem validação geométrica neste helper.

A preparação `$2799` chama a configuração e encaminha kind não zero para `$2BFE`, extraído e verificado na unidade seguinte; kind zero preenche o retângulo com o helper já publicado. O primeiro ensaio rejeitou uma expectativa incorreta de origem: o preenchimento usa `$C1A4` sem decremento e `$C1A7-1`, portanto começa uma coluna e uma linha após as coordenadas cruas do registro. A fixture foi corrigida; a ROM original não foi alterada. Os registros 1/2 executam o preenchimento completo; registros 0/3 param antes do helper de kind não zero.

O consumidor `$28BE` instala B/C como posição local, HL como ponteiro, força estado 1 e chama `$2E15` repetidamente até estado 3; então zera o estado. Não usa o dispatcher temporizado nem espera input ao ver control `$0F` quando há terminador adiante. A terminação dos streams sintéticos usados é comprovada pelos retornos finitos; isso não garante término de streams arbitrários, callbacks não nulos ou dados sem terminador.

A fixture cobre 65.536 pares de coordenadas em registros WRAM com todos os índices de byte exercitados, 256 fallbacks de height zero, 48 configurações dos quatro registros originais, 64 preparações completas com LCD desligado/ativo, 16 prefixos de kind não zero, 256 contadores de repetição com control zero e 256 streams compostos (`2,1,3,$A5,1,$0F,0`) com callback nulo. Outras 72 cadeias usam registro original → glifo 16/127/253 → terminador, três contadores de glyph e ambos os VBKs, com LCD ativo. Conferem todos os 8.192 bytes dos dois planos, os 16 bytes originais de fonte transferidos por HDMA, contador, ponteiro, estado final zero e restauração real de A. São 66.560 calls completos e 16 prefixos, 133.080 novos asserts e total de 3.001.065. O privado preserva os 1.397 símbolos publicados em `8b45116`; montagem integral e negativos reais passam. As cadeias permanecem forçadas, sem menu natural, paletas visíveis, IRQ, callbacks naturais ou temporização física.


### Moldura e preparação completa de regiões de texto

`home/queued_text_frame.asm` extrai `$2BFE-$2D45`: 193 instruções, 328 bytes, sem callees externos. O thunk `$01FB` e a preparação `$2799` chamam `DrawQueuedTextFrame`. O residual `$28E3` permanece no endereço publicado; o trecho `$2D46-$2D52` continua sem interpretação. A cobertura passa a 472 seções: 268 analisadas (39.798 bytes) e 204 residuais (1.008.778 bytes).

A interpretação é `PROBABLE`, sustentada pela leitura do fonte e por chamadas forçadas no core mGBA `431041ac6`, sem trace natural. A rotina recebe HL como origem externa, usa tile base `$6C` quando kind é 1 e `$75` nos demais casos, escreve tiles no plano 0 e o atributo `$C1A3` no plano 1. As nove posições de tile representam esquerda/meio/direita das linhas superior, internas e inferior. O interior também é preenchido. Cada célula conserva os waits de STAT e a sequência DI/EI; o VBK inicial é restaurado, mas o IME inicial não é preservado.

Width é o número de células internas; zero percorre 256 células. As linhas internas são `2*height` com wrap de byte e laço após decremento: resultado zero percorre 256 linhas. O stride é 32 e não há clipping; larguras grandes sobrepõem linhas, por isso o modelo da fixture aplica as escritas na ordem original. Alturas 0/128 não cabem integralmente na VRAM a partir de `$8000`: oito probes limitados param em `$2C79`, HL=`$A000`, C=1, antes de escrever a última linha interna fora da VRAM. Verificam a linha superior e as 255 linhas internas anteriores, sem executar os acessos seguintes.

São 1.600 chamadas completas: 1.024 cobrindo todos os 256 kinds, ambos os VBKs e LCD desligado/ativo; 512 cobrindo todas as larguras com height 1 e LCD desligado; 64 preparações completas dos registros originais 0/3, com ambos os VBKs, LCD desligado/ativo, quatro atributos e dois fallbacks. Os retornos conferem AF/BC/DE/HL, campos e guards; o resultado verifica os 8.192 bytes de cada plano, inclusive células intocadas. Os oito prefixos de altura extrema conferem fronteira, stack, contador e VRAM. Acrescentam 3.216 asserts ao total de 3.004.281. Não se afirmam domínio geométrico natural, menu exibido, IRQ natural ou temporização física.


### Dependências de contagem e marcação do redesenho A0F

`engine/startup/bank_a0f_list_helpers.asm` extrai `$4496-$44AD` (24 bytes) e `$474C-$47A9` (94) da janela A `$0F`, endereços físicos `$07:$6496/$674C`. São 118 bytes adicionais. Os símbolos residuais `$63F0/$668B` ficam nos endereços publicados; `$67AA-$67DF` permanece sem interpretação. A cobertura chega a 475 seções: 270 analisadas (39.916 bytes) e 205 residuais (1.008.660 bytes).

`IsA0FNonMarkerCountBelowCapacity` retorna A=1 quando `(($C76C-$C76D)&255) < $C76F`, A=0 caso contrário; B guarda a diferença, C a capacidade e flags preservam a comparação. A subtração não tem saturação. A fixture percorre todos os 65.536 pares de bytes de contagem/marcadores, usando a capacidade igual aos marcadores; essa escolha também percorre todos os pares diferença/capacidade. Não equivale a enumerar os 16.777.216 trios independentes. Verifica AF/BC, DE/HL preservados e ausência de alteração nos campos.

`DrawA0FMarkedTextRow` zera posição local e delay, calcula `HL = ($9800 + 32*(($C1A7-1)&255) + $C1A4 + $C770)&65535` pela multiplicação residente original e escreve `$C771` células consecutivas: tile `$88` no plano 0 e atributo `$07` no plano 1. Contagem zero percorre 256 células. Os waits de STAT e DI/EI permanecem; VBK inicial é restaurado. Não há clipping nem preservação do IME inicial.

Há 65.536 prefixos com todos os pares de coordenadas e offsets/contagens derivados, parando em `$4788` antes da primeira escrita, inclusive quando o endereço sairia da VRAM. Conferem endereço, stack/AF salvo, campos e a ausência de escritas nos dois planos. Outras 1.024 chamadas completas cobrem todos os bytes de contagem, ambos os VBKs e LCD desligado/ativo em endereços escolhidos dentro da VRAM; conferem retorno, registradores, guards e cada um dos 8.192 bytes de ambos os planos. São 66.560 calls completos e 65.536 prefixos, 264.193 novos asserts, total 3.268.474. A interpretação permanece `PROBABLE`: os testes são sintéticos, sem domínio natural de contadores/coordenadas, menu exibido ou temporização física. O chamador `$45A0-$4627` é extraído na unidade seguinte.


### Redesenho completo da lista A0F e recuo com lista não vazia

`engine/startup/bank_a0f_list_redraw.asm` extrai `$45A0-$4627`: 136 bytes, 74 instruções, com os callees publicados nomeados. `data/bank_a0f_list_cells.asm` preserva os quatro bytes alcançados em `$4F5C-$4F5F`, pares tile/atributo `$89/$00` e `$8A/$00`, sem afirmar a extensão de uma tabela maior. O recuo `$451F` chama `RedrawA0FListText` simbolicamente. `ResidualROM07_655D` e `ResidualROM07_6F0C` mantêm os endereços publicados. A cobertura chega a 478 seções: 272 analisadas (40.056 bytes), 206 residuais (1.008.520 bytes).

A rotina força o contador de fonte `$C1C2` para 70, configura o registro 1 ou 2 segundo o bit 0 de `$C765` e consome o stream `$C74E` pelo renderizador bloqueante original. Em seguida zera o contador de fonte e calcula a diferença de contagem/marcadores. Quando essa diferença está abaixo de `$C76F`, copia a primeira célula para `$9882 + diferença + $C76E`, marca uma célula da linha de texto anterior usando `$C770= diferença/$C771=1` e copia as células seguintes até a capacidade. Mantém o `ld a,a` original. A interpretação é `PROBABLE`, baseada no fonte e em execução sintética; não há validação da coerência entre metadados e stream neste helper.

O modelo da fixture compõe na ordem original os payloads de fonte, tiles/atributos dos glifos e células acrescentadas. As 512 chamadas com stream vazio exercitam todos os bytes de modo, ambos os VBKs, contagens/capacidades/offsets derivados e LCD desligado. Outras 216 chamadas com LCD ativo usam modos 0/1/2/255, ambos os VBKs, comprimentos 0/1/8, três classes de metadados e três offsets. Incluem metadados inconsistentes e subtração com wrap. Dezesseis cadeias usam `$FE` ou `$FF` seguido de glifo 16 e terminador; conferem a primeira renderização uma linha acima sem avanço de coluna e a renderização seguinte na linha normal, com os payloads originais alcançados. Outras 16 chamadas completas de recuo/dispatcher removem o último glifo de uma lista não vazia e executam o redesenho inteiro.

São 760 calls completos e 1.520 novos asserts, total 3.269.994. Conferem todos os 8.192 bytes de ambos os planos, campos de contagem, posição, ponteiro, estado, VBK e, quando há glifos, HDMA e restauração real da janela A. Callbacks são nulos e a geometria é escolhida dentro da VRAM. As provas não estabelecem menu natural, domínio universal de streams/metadados, callbacks naturais, áudio ou temporização física.


### Grade de recursos japoneses e troca de modo A0F

`engine/startup/bank_a0f_resource_grid.asm` extrai `$455D-$459F` (67 bytes) e `$468B-$474B` (193), preservando como aliases os símbolos residuais publicados. `data/bank_a0f_grid_footer.asm` extrai dois mapas de 20 colunas e dois planos, `$4F0C-$4F5B` (80 bytes), mantendo `ResidualROM07_6F0C`. `data/bank_a0f_grid_streams.asm` extrai `$5334-$5465` (306 bytes): quatro blocos de 12 streams de seis bytes, o stream alternativo de 15 glifos `$10` e três terminadores alcançados. São 646 bytes adicionais; não se afirma a extensão de uma tabela maior. Os bytes japoneses não recebem tradução. Cobertura: 480 seções, 276 analisadas (40.702 bytes) e 204 residuais (1.007.874 bytes).

A confiança permanece `PROBABLE`. `DrawA0FResourceGrid` configura o registro 0, marca duas células com offsets `$30/$70` para entrada menor que 2 e `$10/$50` nos demais casos, copia o mapa escolhido por `$C765` zero/não zero e faz quatro linhas de três chamadas bloqueantes, colunas 0/6/12 e linhas 0/2/4/6. O seletor usa o bit 0 de `$C765`; a condição de mapa/stream alternativo usa o byte zero/não zero. O rodapé força VBK zero, que permanece no retorno.

O primeiro modelo sintético foi rejeitado no caso 10: supunha três repetições do stream alternativo na última linha. D é salvo uma vez por linha, mas é alterado pelo renderizador de glifos dentro das chamadas de coluna. O primeiro stream alternativo deixa D como byte alto do offset de linha (1 neste domínio), portanto as duas chamadas seguintes continuam em `$5464/$5465`, consumindo terminadores vazios; o ponteiro final é `$5466`. O modelo foi corrigido para acompanhar D e o ponteiro entre chamadas, e o intervalo extraído inclui esses dois bytes adicionais. Nenhum byte original foi alterado; não se afirma defeito natural.

`CycleA0FResourceMode` incrementa `$C76A` com wrap de byte e força zero somente quando o resultado é 4. Redesenha a grade, passa pelo seletor e atualiza o indicador de três pares já publicado. Não transforma parâmetros arbitrários em módulo 4. O dispatcher passa a chamar esse símbolo.

A fixture executa 32 grades completas (entradas 0/1/2/255, modos globais 0/1/2/255 e ambos os VBKs), 1.024 trocas completas (todos os bytes anteriores de `$C76A`, modo global 0/1 e ambos os VBKs) e 16 cadeias completas pelo dispatcher. Todas usam LCD ativo, callbacks nulos, fonte original, contador/ponteiro e modelo independente de escritas em ordem. Conferem os 8.192 bytes de cada plano, payloads/fontes e sobreposições, HDMA, restauração real da janela A, estado/posição e indicador. São 1.072 calls completos, 2.144 novos asserts e total 3.272.138. Menus naturais, paletas visíveis, domínio natural dos bytes altos, IRQ/áudio e temporização física continuam abertos.


### Inserção de itens selecionados e compatibilidade de marcadores A0F

`engine/startup/bank_a0f_list_insert.asm` extrai `$43F0-$4495` (166 bytes) e `$44D7-$451E` (72): 238 bytes adicionais. Os símbolos `ResidualROM07_63F0/64D7` permanecem como aliases nos endereços publicados. O dispatcher chama `InsertA0FSelectedListGlyph` simbolicamente. A cobertura mantém 480 seções, agora 278 analisadas (40.940 bytes) e 202 residuais (1.007.636 bytes).

A interpretação é `PROBABLE`. O classificador lê B como offset, C como valor e E como marcador; usa constantes `$85/$96/$8A/$9A/$9F/$A4` somadas a B com wrap de byte. E=`$FF` segue somente o intervalo final; os demais bytes permitem as comparações anteriores. Retorna A=0/1, preserva BC/E/HL, deixa D como último limiar e flags da última comparação. Nenhum nome de caractere ou domínio natural é atribuído a essas faixas.

A inserção escolhe o byte dos recursos publicados por modo e coordenadas. A coluna pula os dois terminadores entre grupos com incrementos condicionais e wrap; a linha combina duas rotações de byte. Quando `$C765` não é zero, `$C76A` é ímpar e a linha é pelo menos 3, usa glifo `$10`. O destino é `$C74E + $C76C`. Glifo abaixo de `$FE` requer diferença de contagem/marcadores abaixo da capacidade; caso contrário retorna sem redesenhar. Para `$FE/$FF`, consulta o byte duas posições antes do destino, rejeita se ele já é marcador, depois classifica o byte anterior com offset 0 e, se necessário, `$40`. Quando aceita, insere o marcador antes desse byte, incrementa a contagem auxiliar e acrescenta terminador. Todo item aceito incrementa a contagem total e executa o redesenho original.

A fixture percorre 131.072 pares B/C com E=0/255, cobrindo ambas as classes de E, mais 4.096 combinações de todos os bytes de E com quatro offsets e quatro valores. Confere AF/BC/DE/HL. Outros 65.536 prefixos cobrem todos os pares de coordenadas, modo/contagem derivados e ambas as classes de seleção global, parando em `$444B` antes de alterar a lista. Leem os bytes realmente mapeados quando parâmetros altos ultrapassam os recursos medidos; isso não aumenta a extensão afirmada das tabelas. Conferem ponteiro de origem, byte selecionado, destino salvo no stack e VRAM inteira intocada.

Há 3.840 calls completos por modo 0..3, global 0/1/2/255, 15 colunas, quatro linhas, duas capacidades e ambos os VBKs, mais 16 calls completos pelo dispatcher. O modelo independente verifica lista posterior, aceitação/rejeição, marcadores e metadados, fonte original/HDMA, estado, ponteiro, janela A e todos os 8.192 bytes de cada plano, incluindo sobreposições do redesenho. Outros 16 calls completos rejeitam a inserção quando o byte duas posições antes já é `$FE/$FF`, com LCD desligado/ativo e ambos os VBKs, sem redesenho. Quatro prefixos artificiais de lista com comprimento 0/1 e marcadores `$FE/$FF` param em `$445D`, antes de ler `$C74C/$C74D`; não executam o restante nem estabelecem defeito natural. São 139.040 calls completos, 65.540 prefixos e 409.161 novos asserts, total 3.681.299. Streams são curtos, callbacks nulos e geometria escolhida; menus naturais, contagens altas em execução completa, IRQ/áudio e temporização física continuam abertos.


### Callbacks, fade e espera por frame A0F

`engine/startup/bank_a0f_frame_callbacks.asm` extrai `$47AA-$47DF` (54 bytes), preservando `ResidualROM07_67AA`. Setup e dispatcher usam os símbolos publicados. Cobertura: 480 seções, 279 analisadas (40.994 bytes) e 201 residuais (1.007.582 bytes). A interpretação permanece `PROBABLE`, sustentada pelo fluxo estático e execução sintética delimitada.

`FadeAndWaitA0FPalette` limpa `$C1B8`, lê o ponteiro `$C773/$C774`, inicia a transição de adição com modo 4 e repete tick/espera até `$C220 OR $CF86` ser zero. `A0FNoopInterruptCallback` somente retorna. `A0FOAMAndPaletteCallback` executa o DMA original instalado em HRAM e o uploader de paletas pendentes. `WaitA0FFrameFlag` executa HALT/NOP mesmo quando `$FF8A` já é não zero; após despertar, espera o byte não zero, limpa-o e retorna.

A fixture cobre 4.096 retornos do callback vazio (todos os valores de A e 16 flags), instala os dez bytes do DMA pela rotina original `$09EB`, executa 512 callbacks completos (todos os bytes dirty e ambos os VBKs, LCD desligado) e compara OAM, paletas, registradores e toda a VRAM. O DMA copia `$C000-$C09F`. Um modelo inicial que mascarava o bit 15 da paleta foi rejeitado; o readback do core mantém os bytes brutos. Isso descreve a fixture no mGBA, não visibilidade de cores em hardware.

Outras 256 esperas completas cobrem todos os bytes iniciais de `$FF8A`, incluindo despertar com zero e continuar no spin até a fixture fornecer 1. O wake é agendado na fila de eventos antes do HALT; a callback observa o CPU parado e injeta IE/IF com IME desativado. Tentar fornecer o wake somente após recuperar o controle pelo stepping bloqueava a fixture na espera interna de eventos; o produtor agendado corrige esse contrato de teste, sem modificar o core ou a ROM.

Há 1.024 fades completos com ponteiros originais `$4E20/$52EC`, todos os bytes de `$CF86` e ambos os VBKs. A fixture confere cada espera, oito ticks, acumuladores/deltas de 192 componentes, 64 cores finais `$7FFF`, dirty e guards; mantém as paletas de hardware intactas porque não executa IRQ/uploader nessa cadeia. Para `$CF86` não zero, força duas esperas extras e então libera o byte. Isso não prova progresso natural de áudio nem extensão de um objeto de paleta em `$4E20` (a leitura de 128 bytes cruza o recurso `$4E68`). São 5.888 calls semânticos completos, mais o instalador DMA, e 20.987 novos asserts, total 3.702.286. IRQ/frame produtor natural, áudio, menus e temporização física continuam abertos.


### Entrada e saída completas do display A0F

`engine/startup/bank_a0f_entry.asm` extrai `$4000-$409B` (156 bytes), mantendo `ResidualROM07_6000`. Liga setup, gráficos, grade, lista, indicador, transições, input e cleanup pelos símbolos publicados. O prefixo de registros de texto também é referenciado simbolicamente. Cobertura: 480 seções, 280 analisadas (41.150 bytes) e 200 residuais (1.007.426 bytes). Confiança `PROBABLE`; não é uma execução natural do menu.

A entrada inicializa o display e os gráficos, solicita stream inferior `$81`, prepara a configuração de texto com A=1 e escolhe fonte `$4F60` quando o modo global é zero, `$50E0` nos demais casos. Se o modo é não zero e a lista está vazia, muda `$C765` para 3 depois de escolher a fonte. A chamada `$01E0` copia 288 bytes para `$96C0` e mais 160 para `$8760` no plano 1. A leitura consecutiva de 448 bytes em `$50E0` cruza os registros/objetos já publicados; isso não estabelece uma fonte independente ou extensão exclusiva desses objetos. Prepara registros 0 e `1 + (modo & 1)`; modo ímpar também prepara 3. Desenha grade/lista/indicador e inicia a subtração de cores.

O loop chama polling de input/contador, despacho de texto, expansão de objetos, tick de cor e input A0F. Estado zero expande objetos mais uma vez, limpa callbacks e retorna `$C764`. Estados não zero esperam frame, inclusive `$63` após o fade de saída: o encerramento acontece somente na iteração seguinte. Os endereços de retorno `$47C2/$409A` distinguem a espera interna do fade daquela do loop.

A fixture executa 32 entradas completas: modos 0/1/2/255, ambos os VBKs iniciais, saída 0 com lista vazia/um glifo, saída 1 com um glifo e rejeição de saída 1 com lista vazia seguida de saída 0. Usa `setKeys` e polling original; na rejeição, solta A por uma iteração e pressiona novamente. Confere fonte copiada, ordem de registros, estado no início do loop, lista preservada, retorno/stack, callbacks limpos, contador de iterações, restauração real de ambas as janelas, HDMA e dirty. O LCD está ativo para as esperas STAT/HDMA; a snapshot da fonte desliga e religa o LCD explicitamente. Wakes e liberação de `$CF86` são produtores da fixture, com IME desativado durante cada wake; não se afirma IRQ/áudio natural.

O modelo inicial com LCD desligado parou na espera STAT `$2F9E`; o teste foi corrigido para satisfazer a precondição do renderizador. Também foram corrigidas as suposições de que `$0279` apenas incrementaria o contador e de que todo HALT com estado `$63` pertenceria ao fade: o polling sobrescreve flags injetados, e há uma espera adicional no loop. Nenhuma instrução original foi alterada.

Na cadeia escolhida, a adição do fade tem prioridade sobre o contador de subtração ainda pendente. Depois dos oito ticks de adição, o loop aplica mais um tick de subtração antes de encerrar. Os testes conferem os 192 acumuladores/deltas e as 64 cores resultantes, com contador de subtração final 6 (saída imediata) ou 4 (rejeição/soltar/pressionar). As paletas de hardware permanecem intactas porque não se executa o uploader por IRQ. São 32 calls completos mais o instalador DMA, 789 novos asserts e total 3.703.075. A cadeia é sintética e usa listas curtas; menus naturais, domínio universal dos parâmetros, visibilidade das cores, IRQ/áudio e temporização física permanecem abertos.


### Polling, edge e repetição do joypad residente

`home/joypad_poll.asm` extrai `$261C-$2684` (105 bytes), preservando `ResidualROM00_261C`. Os thunks `$0279/$027C` passam a usar símbolos. O restante `$2685-$2752` permanece literal em `data/uninterpreted/bank00_2685.asm`. Cobertura: 481 seções, 281 analisadas (41.255 bytes) e 200 residuais (1.007.321 bytes). A confiança semântica é `PROBABLE`, com modelo independente e execução sintética do polling original.

`TickCounterAndPollJoypad` incrementa `$FF8B` com wrap e cai em `PollJoypadState`. O polling seleciona direções/botões em `$FF00`, preserva as leituras repetidas originais e combina os bits na ordem A/B/Select/Start/Right/Left/Up/Down. Calcula `$FF97 = (anterior XOR atual) AND atual`, guarda atual em `$FF96` e deseleciona o joypad. O estado de repetição usa `atual AND $F3`, excluindo Select/Start: quando difere de `$FF99`, zera `$FF9A`, atualiza `$FF99`, copia edge para `$FF98` e deixa `$FF9B`/A=1. Quando coincide, incrementa `$FF9A`, aplica máscara `$9F` e substitui zero por `$80`. Bit 7 ativo e dois bits baixos zero geram `$FF98 = edge OR estado mascarado`, `$FF9B`/A=0; os demais casos usam somente edge e marcador 1. Isso conta chamadas, sem provar uma duração física em frames.

A fixture define explicitamente `allowOpposingDirections` como falso/verdadeiro e restaura a política anterior depois do grupo. Com falso, o mGBA suprime os pares opostos; com verdadeiro, o modelo inclui os bytes brutos. Essa diferença é política do core usado nos probes, não evidência de controles físicos. Em cada política, percorre todos os 65.536 pares de teclas/estado anterior com estado de repetição diferente, todos os 65.536 pares de teclas/estado anterior de repetição (campos restantes derivados) e todos os 65.536 pares de teclas/contador com estado de repetição igual. São domínios separados, não o produto cartesiano de todos os campos independentes.

Há ainda 256 chamadas por política cobrindo todos os valores anteriores do contador de ticks e 256 traces por política de 96 chamadas: 48 mantendo um padrão, 16 soltas e 32 com A invertido. Os traces encadeiam o estado esperado independente, usam `setKeys` e executam o polling original. Verificam AF/BC/DE/HL, todos os bytes de estado/edge/repeat/marcador, wraps, guards e deselect `$FF00`; ambos os planos inteiros de VRAM permanecem `$A5` ao fim do grupo. São 442.880 calls completos e 885.761 novos asserts, total 4.588.836, além dos 24 testes dos verificadores. Não há IRQ natural, menu, debounce físico ou temporização de hardware comprovados por esses probes.


### Seletores e configuração residente de texto/fontes

`home/minigame_selector.asm` extrai `$2685-$269B` (23 bytes), preservando `ResidualROM00_2685`. `home/text_configuration.asm` extrai `$269C-$2752` (183 bytes): inicialização de plano (128), três setters de word (21) e cópia de fontes (34). Os seis thunks residentes passam a usar símbolos. São 206 bytes adicionais; cobertura de 482 seções, 283 analisadas (41.461 bytes) e 199 residuais (1.007.115 bytes). Confiança `PROBABLE`, com chamadas sintéticas completas.

`ResolveMinigameSelector` usa a tabela publicada `BuiltinGameWindowBSelectors` para índices menores que `$10`, retornando D=0/E=selector; os demais retornam D=`$08`/E=`índice-$10`. Não seleciona uma janela nem valida se o índice cabe na flash física. O item nativo `$0F` continua retornando `$FF`, com finalidade natural aberta. A tabela contém seletores MBC6 de 8 KiB, não números de bancos RGBDS.

`InitializeQueuedTextPlane` guarda A bruto em `$C1AF`, zera os cinco bytes de contagem/estado `$C1C2/$C1C0/$C1C1/$C219/$C21A`, estabelece origem `$9800` e deriva atributos 7/0/1/2/0 com bit 3 adicional quando A é não zero. VBK usa somente o bit 0 de A. Copia 32 bytes do `$4EE0` atualmente mapeado para `$97E0`, zera `$C1BF` e restaura VBK. O helper ignora `$C21C` nessa cópia simples. Não valida domínio natural de A. `SetQueuedTextControlCallback`, `StoreQueuedTextWordC219` e `StoreQueuedTextPointer` armazenam DE little endian em `$C1C0/$C219/$C1AB`, deixando HL no byte alto; o consumidor de controle 3 já publicado consulta `$C1C0` e faz `jp hl` quando não zero. O papel de `$C219` continua descrito pelo endereço, sem inventar significado.

`LoadQueuedTextFontTiles` seleciona o plano de `$C1AF`, chama o corpo de cópia com troca de janela para 288 bytes em `$96C0` e mais 160 em `$8760`, e restaura VBK. O caminho escolhe janela A/B pela faixa do ponteiro, usa `$C21C/$C21D` e restaura a configuração anterior. A leitura de 448 bytes nos recursos A0F já observados cruza outros objetos publicados; não estabelece extensão exclusiva de uma fonte.

Os probes cobrem 4.096 resoluções (todos os índices e 16 flags), 196.608 setters (todos os 65.536 words para cada campo), 2.048 inicializações (todos os bytes de A, ambos os VBKs, LCD desligado/ativo e duas janelas A atuais) e 3.072 cópias de fontes (todos os bytes do plano, ambos os VBKs, LCD desligado/ativo e dois recursos na janela A mais um na B). Na inicialização, `$C21C` é deliberadamente diferente da janela atual. Na cópia com mapper, os seletores anteriores diferem dos recursos e os mirrors são inicializados explicitamente. Conferem AF/BC/DE/HL, campos/guards, bytes reais de ambas as janelas restauradas e todos os 8.192 bytes de cada plano de VRAM em cada chamada de inicialização/cópia. Os setters usam A/flags derivados do word, sem afirmar todo o produto cartesiano de registradores.

São 205.824 calls completos, 411.648 novos asserts e total 5.000.484, mais 24 testes dos verificadores. As cópias deixam IME ativo por suas sequências DI/EI originais; isso não é restauração da IME anterior. Fontes na flash, extensões arbitrárias de recursos, callbacks naturais, menus, conteúdo japonês/visibilidade e temporização física continuam sem prova por estes testes. Nenhum texto foi traduzido e nenhum byte original foi alterado.


### Troca de velocidade CGB residente — `$25CB-$2612`

`home/speed_switch.asm` extrai 72 bytes em `SwitchToDoubleSpeed` e `SwitchToNormalSpeed`, preservando `ResidualROM00_25CB` e os thunks `$0270/$0273`. O manifesto mantém 482 seções: 284 analisadas (41.533 bytes), 198 residuais (1.007.043 bytes). Confiança `PROBABLE`: fluxo original KEY1/STOP e chamadas completas sintéticas, sem trace natural ou prova de temporização física.

O caminho de troca prepara KEY1, salva IE, desabilita IE, deseleciona JOYP, executa STOP, espera o bit 7 esperado, zera JOYP/IF e restaura AF/IE. Se já estiver na velocidade desejada, retorna após BIT sem escrever esses campos. BC/DE/HL permanecem intactos; o A final da troca é IE salvo e as flags são as do BIT inicial, incluindo carry preservado.

A fixture executa 16.384 chamadas verificadas cobrindo velocidades inicial/final, todos os 256 bytes de IE e todas as 16 combinações de flags. Outras 16.385 chamadas originais estabelecem a velocidade inicial e encerram o grupo, sem editar campos internos de velocidade. Os 49.153 novos asserts elevam o total a 5.049.637; verificam retorno limitado, SP, velocidade/multiplicador reais do core, KEY1, IE/IF/JOYP, registradores, guarda WRAM e IME desabilitado. LCD, timer e serial ficam desabilitados; não há alegação de corrida de IRQ, temporização de hardware ou execução natural.


### Despacho de callback na flash — `$24B9-$254D`

`home/flash_callback.asm` extrai 149 bytes em `DispatchFlashCallback`, com thunks e tails nomeados e `ResidualROM00_24B9` preservado. A cobertura mantém 482 seções: 285 analisadas (41.682 bytes), 197 residuais (1.006.894 bytes). Confiança `PROBABLE`, com fluxo estático e alvos RET sintéticos na flash descartável; nenhuma execução natural de callback foi comprovada.

O dispatcher preserva AF/HL durante `EnableFlashReads`, escolhe A/B por H menor ou maior/igual a `$60`, salva selector/type em `$C66D/$C66E`, seleciona flash (`$08`), empilha `$24EA` ou `$2532` e faz `jp hl`. Após o RET do alvo, restaura a janela e chama `DisableFlashReads`. O caminho B também copia os valores salvos de B para os mirrors de A em HRAM, sem alterar A física nem seus mirrors WRAM; essa assimetria original é preservada. O scratch é compartilhado com o dispatcher de minigames, sem evidência de segurança para aninhamento.

A fixture executa 65.536 chamadas completas com quatro endereços (`$4100/$5FFF/$6000/$6100`), todos os 128 seletores válidos de flash, quatro combinações prévias de tipos A/B, duas condições de flag/leitura e 16 flags. Os seletores prévios são fixos e distintos: A `$16`/B `$0F` para ROM e A 3/B 5 para flash. Alvos RET temporários ficam somente no backing descartável em memória; todos os bytes, incluindo metadados extras, são restaurados e comparados. Conferem estado na entrada real do alvo, endereço de retorno, SP, registradores, scratch/guards, mirrors, bytes físicos restaurados de ambas as janelas, IME e controles de flash.

Dois prefixes negativos demonstram o pré-requisito: com bit 0 de `$CEE9` ativo e leituras desabilitadas, `EnableFlashReads` retorna sem habilitá-las e o alvo lê `$FF`. A fixture para antes de executá-lo; uma chamada separada de cleanup não conta como conclusão desse callback. Os 131.078 novos asserts elevam o total a 5.180.715. A expectativa independente de half-borrow no CP de H=`$5F` foi corrigida no oracle, sem mudar o fonte original. Callbacks reais, alvos arbitrários, sobreposição de scratch, corrida de IRQ e execução física continuam sem prova.


### Inicialização dos campos de seleção — `$28E3-$2944`

`home/selection_fields.asm` extrai 98 bytes em `InitializeSelectionFieldsC20A`; `ResidualROM00_28E3` permanece como alias. O restante `$2945-$2BFD` continua explícito em `data/uninterpreted/bank00_2945.asm`. A cobertura passa a 483 seções: 286 analisadas (41.780 bytes), 197 residuais (1.006.796 bytes). Confiança `PROBABLE`, com campos nomeados por endereço e consumidores estáticos no fluxo adjacente de joypad; a ativação/desenho do menu ainda não foi extraída nesta unidade.

O ponteiro HL é guardado em `$C20A/B`, sem ser dereferenciado aqui, e B/C/D/E em `$C20D-$C210`. O helper publicado `DivideByteByByte` calcula `(q1,r1)=D/E` e `(q2,r2)=q1/C`; divisor zero retorna quotient `$FF` e remainder igual ao dividendo. `$C217=(q2+(r2!=0)) mod 256`. `$C211=C` se r2 for zero, ou `(r2+(r1!=0)) mod 256` caso contrário; uma terceira divisão condicional recupera r1. Não substituí essa ordem de truncamento por uma fórmula genérica de teto. Zera `$C212/$C213/$C214/$C21B`, grava `$FF` em `$C215/$C216` e preserva `$C20C/$C218/$C219/$C21A`. Ao final AF=`$FF80`, B=0, C=E quando r2 não zero (senão C original), D=q1, E intacto e HL=`$C217`.

A fixture cobre 987.136 chamadas completas: todos os pares D/E para sete valores de C, todos os pares C/D para sete valores de E (`0/1/2/3/7/16/255`), todos os 65.536 ponteiros HL e todos os bytes de B com 16 flags em um caso aritmético fixo. Nos dois eixos aritméticos, as flags são derivadas dos inputs; não se afirma o produto cartesiano completo C/D/E/flags. Compara todos os campos/guards, retorno limitado e registradores contra modelo independente. São 2.961.408 novos asserts, total 8.142.123. Divisor zero e wrap são contratos sintéticos, sem comprovar parâmetros naturais válidos, conteúdo do ponteiro ou dimensão visual do menu.


### Ativação e desenho da seleção — `$2945-$294D`, `$30BC-$3189`

`home/selection_draw.asm` extrai 215 bytes: 9 de `ActivateSelectionText` e 206 de `DrawSelectionText`. Preserva `ResidualROM00_2945` e `ResidualROM00_3031`; os restos `$294E-$2BFD` e `$318A-$38AF` continuam literais. São 486 seções: 288 analisadas (41.995 bytes), 198 residuais (1.006.581 bytes). Confiança `PROBABLE`, com fluxo estático e textos sintéticos, sem trace natural do menu.

O desenho salva AF/BC/DE/HL, chama o preenchimento já publicado, calcula o skip de entradas por multiplicações de byte dos campos `$C212/$C20E/$C210` e percorre registros terminados em zero. Se o byte anterior ao terminador é `$02`, continua a varredura do mesmo skip. O loop chama `RenderQueuedTextBlocking` e preserva a limpeza original: término normal restaura `$C1BD=0`, enquanto abort antecipado deixa a contagem restante. A ativação guarda 1 em `$C213` e chama o mesmo corpo; A final é 1, flags e BC/DE/HL preservados.

Os 1.512 calls com textos vazios cobrem linhas/colunas 1–3, páginas 0–2, sete valores de limite (`0/1/2/3/5/9/16`), ambos os VBKs, entrada direta/ativação e flags `$10/$F0`. O modelo independente inclui o primeiro limite `(página+1)*linha relativa`, o índice seguinte e o wrap de limite±1, sem afirmar todas as combinações de dimensões/overflow. Conferem retorno, registradores, campos, ponteiro/guards e todos os bytes dos dois planos de VRAM; apenas o retângulo exato é preenchido.

Outras 24 chamadas com LCD ativo executam glifos `$10/$7F/$FD`, ambos os pares `$C1AF`/VBK 0 ou 1, as duas entradas e corpus simples ou com continuação `$02,$00` saltada. Os 16 bytes da fonte são capturados da janela A selector 2; a janela anterior A `$0F` é restaurada. Conferem o upload real em `$96B0`, tile `$6B` em `$9841`, atributo `$23`, campos e ambos os planos inteiros. O renderer original deixa VBK=1 após escrever o atributo e inicia HDMA nesse plano, mesmo com `$C1AF=0`. Corrigi duas expectativas no oracle — primeiro limite e plano do upload — sem alterar os bytes originais ou reduzir a comparação. São 1.536 chamadas e 4.608 novos asserts, total 8.146.731. Dimensões zero, overflow amplo, corpus sem terminador, menus naturais, interpretação japonesa e temporização física continuam sem prova.


### Entrada, cursores e notificação de seleção — `$294E-$2BFD`

`home/selection_input.asm` extrai 688 bytes em cinco seções: controle de entrada, tabela de três words, indicadores de página/notificação e cursores dos modos 0/2. Preserva `ResidualROM00_294E` e nomeia o thunk `$01F8`. São 490 seções: 293 analisadas (42.683 bytes), 197 residuais (1.005.893 bytes). Confiança `PROBABLE`: fluxo original e execução completa sintética, sem trace natural do menu.

A prioridade em `$FF98` é cima (`$40`), baixo (`$80`), esquerda (`$20`), direita (`$10`); confirmação pelo bit 0 de `$FF97` ocorre somente sem direção selecionada. Mudanças verticais podem chamar o redraw original; confirmação grava o índice combinado com wrap de byte em `$C214` e zera `$C213`. `$C215` guarda a página anterior ao movimento. Os cursores escrevem descritores de quatro bytes, respeitando a capacidade 16. Indicadores de página piscam pelo bit 4 de `$FF8B`; seu retorno antecipado pode adiar a atualização de `$C216` e o callback de `$C219/$C21A`. O modo 2 usa o jitter de frame já publicado. A tabela contém `$2B50/$0000/$2BB9`; o dispatcher não valida o índice nem trata `$0000` como retorno vazio.

Os probes encadeiam 297.984 chamadas completas do controle: oito estados limitados com todos os bytes de repeat, frames/capacidades selecionados; todos os 256 frames em dois estados; todos os 65.536 pares `$FF98/$FF97` em um estado e ambos os modos; todos os pares de página/linha para confirmação com parâmetros fixos. O modelo independente confere campos, prioridade, redraw, pedido de som, callback executado, mapper/guards e todos os 64 bytes da fila. Os pedidos de som percorrem o código original A1E com um header WRAM descartável sem canais; não comprovam áudio/SFX reais. O redraw e o corpo de callback da fixture também são executados, sem bypass de instruções.

Outras 8.192 chamadas verificam a guarda inativa para todo A/flags e dois presets de teclas; 256 prefixes percorrem a seleção real da tabela, parando em `$0600`, antes de `jp hl`. O índice dobrado sofre wrap de byte; modos 1 e 129 apontam para `$0000`, sem alegação de validade natural. São 306.176 calls completos e 256 prefixes, 910.848 novos asserts e total 9.057.579. A equivalência detectou uma referência inicial ao corpo do som em vez do thunk `$024F`; o fonte final usa `ResidentJump024F`, preservando bytes. A expectativa de flags do dispatcher foi corrigida para considerar `add hl,de`. Um encerramento do processo foi localizado em `reset`: o checkout mGBA avançou para `3bae8be` e alterou o layout de `mCore`, enquanto a biblioteca permaneceu em `431041ac6`. O runner agora compara os headers com o commit da biblioteca antes de compilar e reporta status/artefatos em falhas. Os testes usam uma cópia privada do fonte em `431041ac6`; mudanças apenas documentais são aceitas se os headers coincidirem. Os prefixes param antes de `jp hl` para não executar alvos inválidos; modos 0/2 são executados integralmente nos demais casos. Geometria do cursor é fixa nesses probes; dimensões/estados arbitrários, callbacks reais, IRQs, áudio natural, interpretação japonesa e hardware continuam sem prova.


### Chamador A `$12` da seleção — `$4000-$4156`

`engine/menus/a12_selection.asm` extrai 343 bytes em seis seções: entrada/loop, inicialização, cleanup, dispatcher, tabela de três words e retorno vazio. A janela MBC6 A `$12` corresponde à metade inferior do banco físico `$09`; `ResidualROM09_4000` permanece no endereço publicado. São 496 seções: 299 analisadas (43.026 bytes) e 197 residuais (1.005.550 bytes). Confiança `PROBABLE`, com fluxo original e probes sintéticos, sem execução natural do menu.

A entrada chama a inicialização, que seleciona WRAM 2, limpa os 64 bytes `$C5A3-$C5E2`, grava `$FF` em `$C5C3` e configura `$C218=2` antes da chamada SYS0. O restante da inicialização está extraído por fluxo estático: carrega/grava SYS0, chama recursos ainda numéricos, configura a região de texto e instala callbacks. O loop liga os thunks publicados de polling, texto e input; `$C5A9` fica zero durante o despacho e volta a 1 antes de `$017D`. O dispatcher duplica o byte `$C5A3` sem validar o índice e usa a tabela `$4156/$4157/$421D`, empilhando `$414F` como retorno. Estado 0 retorna vazio; o wrap também faz 128 selecionar o mesmo alvo, sem alegação de validade natural.

Depois de HALT, o loop espera `$FF8A` não zero, consome esse flag e testa `$C5A3`: zero segue para cleanup, qualquer outro byte repete o loop. O cleanup percorre a gravação original dos 50 bytes SYS0, desabilita a origem LYC pelo helper `$0168`, zera ponteiros de callback e instala `RETI` nos dois stubs. Os operandos anteriores dos stubs vazios permanecem intactos.

Os 32.768 prefixes de inicialização cobrem todos os 256 padrões, oito valores iniciais de SVBK e 16 flags, entrando no chamador real `$4000` e parando antes da chamada `$404C`; conferem 64 bytes, guards, modo, WRAM, stack e registradores. Os 4.096 prefixes de dispatcher cobrem todos os estados e flags e param antes de `jp hl`; 32 deles executam o alvo vazio e os dois retornos. Outras 4.096 caudas executam HALT com wake agendado que não produz `$FF8A`, observam quatro iterações sem flag e depois fornecem `$80` explicitamente, conferindo a bifurcação por todos os estados/flags. O wake e o flag são produtores da fixture, sem ISR natural.

As 4.096 chamadas completas de saída/cleanup usam somente um registro SYS0 sintético em SRAM descartável: todos os 256 padrões de payload e 16 flags. Conferem os 50 bytes e seu checksum, guard, retorno, callbacks/stubs, mapper das duas janelas e SRAM desabilitada. Não carregam saves de disco. São 135.200 novos asserts, total 9.192.779, além dos 24 testes do verificador. A expectativa inicial das flags de espera/cleanup foi corrigida para considerar H ativo em `AND A`, sem mudar a ROM. A inicialização completa, os handlers `$4157/$421D`, o callback `$4239` e a origem natural de `$FF8A` ainda precisam ser seguidos; os prefixes não executam alvos arbitrários. IRQs/áudio naturais, interpretação japonesa e hardware continuam sem prova.


### Variantes, saída e callbacks A `$12` — `$4157-$4250`

`engine/menus/a12_selection_handlers.asm` extrai 250 bytes em dez seções, mantendo `ResidualROM09_4157` no endereço original. A tabela de quatro words foi separada do código; o chamador publicado passa a usar os nomes dos handlers e callbacks. São 506 seções: 309 analisadas (43.276 bytes) e 197 residuais (1.005.300 bytes). Confiança `PROBABLE`, com análise estática e execução sintética; não é um trace natural do menu.

O handler `$4157` lê `$C5A8`, duplica o índice em oito bits e despacha pela tabela `$416D`, empilhando `$416C`. Os quatro alvos medidos são `$4175/$41A2/$41D2/$4202`; gravam respectivamente `$61/$63/$65/$66` em `$C21C` e zero em `$C21D` antes de chamar `$5051`. As variantes 0–2 incrementam `$C5E5` uma vez ou quatro vezes, conforme `$C73A` seja zero ou não; a variante 3 incrementa uma vez. Os callees posteriores permanecem numéricos e sem execução completa nesta unidade.

`FinishA12SelectionWhenIdle` (`$421D-$422E`) testa o OR de `$C220` e `$CF86`: somente zero limpa `$C5A3`. `$422F` é o retorno vazio do stub; `$4230-$4238` grava WX=`$A7`, WY=0. `UpdateA12SelectionDMAAndPalettes` (`$4239-$4250`) chama a rotina HRAM original de DMA apenas se `$C5A9` não zero, zera SCX/SCY, grava WX=7/WY=0 e chama o upload de paletas já publicado. O corpo não produz `$FF8A`; sua origem natural permanece fora destes testes.

Os 4.096 prefixes cobrem todos os bytes de variante e as 16 flags, parando antes de `jp hl`; não executam destinos arbitrários. Outros 16.384 prefixes percorrem os dois dispatchers reais, as quatro variantes, todos os bytes prévios de `$C21D` e as 16 flags, até a entrada `$5051`, antes de executar o callee. Conferem seletores, guards e os três retornos empilhados. As 262.144 caudas forçadas depois dos callees anteriores cobrem todos os pares contador/opção nas quatro variantes, até a próxima chamada: incremento 1/4, wrap, flags de INC/AND, registradores e guards. As flags iniciais dessas caudas derivam do byte de opção; não é seu produto cartesiano completo.

As 1.048.576 chamadas completas da saída cobrem todos os pares de fade/ocupação e as 16 flags. Outras 8.192 chamadas conferem retorno vazio e posicionamento da janela para todo AF. As 2.560 chamadas completas do callback, com LCD desligado e DMA HRAM instalada pelo código original, cobrem todos os bytes de `$C5A9` com dirty=0/1/255 e todos os bytes dirty com `$C5A9`=0/1, em ambos os VBKs. Conferem 160 bytes de OAM, fonte/guards, todas as paletas, ambos os planos inteiros de VRAM intactos, registradores, scroll/janela e preservação de `$FF8A`. As duas condições de DMA/paletas são independentes no corpo observado.

São 2.705.410 novos asserts, total 11.898.189, além dos 24 testes do verificador. A preparação permanece sintética, sem saves de disco, IRQ natural, prova de timing físico ou interpretação dos textos japoneses. Os handlers não foram executados integralmente através de todos os seus callees; seletores/tamanhos dos recursos e estados naturais ainda precisam ser seguidos.


### Frames de tilemap A `$12` — `$4FFF-$50C7/$5CFF-$5D10`

`engine/menus/a12_tile_frames.asm` extrai 219 bytes em quatro seções: cópia de frame (82), controle do tick (66), configuração por registro (53) e multiplicação local dos bytes H/L (18). As variantes publicadas passam a chamar `TickA12TileFrame` por símbolo. `ResidualROM09_4251` permanece no endereço anterior; os gaps seguem literais. São 512 seções: 313 analisadas (43.495 bytes), 199 residuais (1.005.081 bytes). Confiança `PROBABLE`, com fluxo original e execução sintética, sem trace natural de animação/menu.

A cópia usa `$C5F9/$C5FA` como coordenadas, calcula destino `$9800+x+32*y`, lê a origem big endian em `$C5F7/$C5F8` e dimensões `$C5E2/$C5E3`, depois chama a cópia bancada dos dois planos já publicada. A multiplicação local preserva A/BC/DE e retorna H×L em HL. A chamada seguinte substitui H por 2 e conserva somente L do produto: o avanço da origem é `2*((largura*altura)&255)`, enquanto a transferência percorre os dois planos completos. Área 256 avança zero; áreas 289/279 avançam 66/46 bytes, sem normalizar o comportamento original.

O tick retorna se `$C5E4` zero ou se `$C5E5` menor que esse limiar. Ao atingir o limiar, limpa o contador e incrementa `$C5E7` com wrap de byte; a comparação com `$C5E6` determina cópia, fim ou loop. O fim sem loop zera `$C5E4`; loop não zero restaura a origem de `$C5FB/$C5FC`, zera o índice e copia. O setup consome sete bytes em HL: x, y, largura, altura, contagem, limiar e loop; salva a origem após o cabeçalho como origem atual/de reinício, copia e limpa contador/índice. O consumidor estático `$4C11-$4C40`, chamado pela variante 1, inclui chamadas do setup com HL=`$6A96/$6AB1` após guards; os respectivos registros e o helper `$4BE6` ainda não foram extraídos nem executados como cadeia completa.

As 98.304 chamadas completas da multiplicação cobrem todos os 65.536 valores HL com AF derivado e oito valores HL selecionados com todo AF. Os 1.249.280 casos do tick incluem todos os pares limiar/contador com 16 flags, todos os pares contagem/índice com loop=0/1/255 e flags derivadas, e todos os bytes de loop com 16 flags em um fechamento fixo. São 526.608 retornos completos e 722.672 prefixes até a chamada real de cópia, sem executar essa transferência nesses casos. O modelo independente confere flags de CP/SUB, wrap, campos, guards e origem/retorno empilhado.

Outras 240 chamadas completas executam cópia direta, tick normal, tick com loop e setup WRAM. Seis dimensões (`1×1/2×3/3×2/16×16/17×17/31×9`) cobrem área pequena, wrap e produto acima de 255. Usam recursos ROM reais via A/B e payloads WRAM sintéticos, ambos os VBKs e LCD desligado/ligado. Conferem registradores, campos, restauração dos dois mapeamentos e todos os bytes dos dois planos de VRAM, além dos guards da fonte WRAM. A transferência continua exata quando o avanço calculado é menor que os bytes consumidos.

São 2.695.888 novos asserts, total 14.594.077, além dos 24 testes do verificador. Dimensões zero, todas as geometrias/fontes possíveis, IRQs naturais, ritmo físico de frames e interpretação japonesa continuam sem prova. A ROM original e recursos ROM não são alterados; os registros usados na preparação são somente memória descartável.


### Estado e disparo de frames A `$12` — `$4BDD-$4C40`

`engine/menus/a12_random_frames.asm` extrai 100 bytes: setter de estado (9), passo de recorrência (43) e consumidor da variante 1 (48). Os chamadores já publicados usam os nomes; `ResidualROM09_4251` permanece no endereço original. São 516 seções: 316 analisadas (43.595 bytes) e 200 residuais (1.004.981 bytes). Confiança `PROBABLE`: fluxo e execução sintética, sem trace natural de aleatoriedade/menu.

O setter grava HL em `$C5D2/$C5D3`, conserva flags/BC/DE/HL e termina com A=H. O passo aplica `(17*estado+$5C93)&65535`: grava o estado novo, retorna D=byte baixo e E=byte alto, conserva BC e deixa HL com o produto intermediário antes da constante. A termina com o byte alto novo e as flags do ADC final. O consumidor só avança se `$C5A4=6`, `$C5CF=1` e `$C5E4=0`. Após um passo, E=0 escolhe HL=`$6A96`; caso contrário, um segundo passo com E&15=0 escolhe `$6AB1`; os demais retornam sem setup.

A seleção `$C21C=$63` não escreve o mapper antes de o setup ler seus sete bytes. Os testes preparam explicitamente B `$63` para a cadeia positiva e B `$05` para o controle negativo, parando antes de executar o setup no banco errado. Os dois cabeçalhos em B `$63` são `07 0A 02 01 05 08 00` e `05 0B 03 01 04 08 00`; a interpretação como registros completos de 27/31 bytes permanece condicionada ao mapeamento. Esses bytes ainda ficam na fonte literal, sem simbolizar os ponteiros numéricos como se a origem natural B `$63` estivesse comprovada.

As 196.608 chamadas completas de setter/passo cobrem todos os 65.536 estados com AF derivado, mais oito estados selecionados com todo AF, para ambas as entradas. Os 1.048.576 casos do consumidor cobrem todos os estados e as 16 flags: 979.184 retornos completos sem disparo, 69.392 prefixes à entrada real do setup. O modelo independente confere recorrência, número de passos, flags, registradores, guards e retorno empilhado. Outras 12.288 chamadas cobrem todos os bytes das três guards, com 16 flags e as demais guards fixas; não é seu produto cartesiano completo.

Quatro controles de mapeamento demonstram os cabeçalhos esperados somente em B `$63`, embora `$C21C` seja igual nos dois bancos. Os 24 casos integrados usam dois estados de cada resultado, ambos os VBKs e LCD desligado/ligado. Executam o consumidor, o setup e todos os frames dos dois recursos ROM: cinco frames de 2×1 tiles ou quatro de 3×1, seguidos do tick terminal sem cópia extra. Conferem os dois planos inteiros de VRAM em cada frame, campos/registradores, mapper e término; os contadores são produzidos explicitamente pela fixture, sem provar o ritmo natural.

São 2.515.196 novos asserts, total 17.109.273, mais os 24 testes do verificador. Foram corrigidas expectativas do oracle sobre A final do setter e o limite do tilemap `$9800`; os bytes originais não foram alterados. Mapeamento natural antes do cabeçalho, distribuição/uso natural do gerador, IRQs, geometria universal, interpretação japonesa e hardware continuam sem prova.

### Ciclo de pares de tiles A `$12` — `$4C41-$4C87`

`engine/menus/a12_tile_cycle.asm` extrai 71 bytes, conserva o alias `ResidualROM09_4C41` e liga o chamador da variante 2 ao nome `CycleA12Variant2TilePairs`. São 517 seções: 317 analisadas (43.666 bytes) e 200 residuais (1.004.910 bytes). Interpretação `PROBABLE` por fluxo e probes sintéticos, sem trace natural.

O helper percorre 20 colunas em `$9920-$9933`, avançando a recorrência uma vez por coluna. Se o byte alto novo & `$7F` for zero, testa o tile superior: `$A5/$A6/$A7` viram `$A6/$A7/$A5`, gravando `$A9/$AA/$A8` na posição +32. Outros bytes ficam intactos. Não seleciona VBK nem espera acesso ao LCD; a execução sintética com LCD desligado não comprova acesso irrestrito com LCD ligado.

As 75.776 chamadas completas cobrem todos os 65.536 estados com flags/tiles derivados e VBK alternado, mais 20 estados escolhidos para disparar em cada coluna, com todos os 256 bytes superiores e ambos os VBKs. O oracle independente confere os 20 passos, os 40 bytes das duas linhas, registradores/flags, guards WRAM e VBK. Em 280 casos confere também os dois planos inteiros de VRAM. São 303.404 novos asserts, total 17.412.677, além dos 24 testes do verificador. A máscara do readback de VBK foi corrigida no oracle; os bytes originais não mudaram. Ritmo natural, significado visual, IRQs e hardware permanecem sem prova.

### Região de texto e janela A `$12` — `$4C88-$4CFC`

`engine/menus/a12_text_regions.asm` extrai quatro helpers (117 bytes); `data/menus/a12_text_regions.asm` preserva quatro registros de oito bytes em `$5314-$5333` (32 bytes). Os aliases publicados permanecem no endereço original. São 523 seções: 322 analisadas (43.815 bytes) e 201 residuais (1.004.761 bytes). Interpretação `PROBABLE`, com fluxo e execução sintética, sem trace natural.

A preparação salva A em `$C5C4`, passa o mesmo índice/tabela aos thunks reais `$01E3/$01E6`, grava o índice em `$C5A5` e limpa `$C1C2`. Cada registro fornece x/y/largura/altura/tipo de moldura; os três bytes finais continuam literais, sem finalidade atribuída. Não há clamp de índice. A exibição espera STAT bit 1 limpo, ativa bits 5/6 de LCDC e chega ao thunk de áudio `$024F` com A=`$9A`. A ocultação limpa esses bits e passa A=`$87`, BC=0, HL=`$1408`, DE=`$D000` a `$0294`. O helper da região corrente configura o registro `$C5A5` e passa A=7, BC=0, HL=(largura+2,2×altura+2), DE=`$D000` ao mesmo wrapper.

O wrapper residente `$16D6` seleciona temporariamente A `$16`, chama a cópia de retângulo já publicada e restaura o mapper. Copia WRAM 7 para dois planos; o bit alto de A escolhe `$9C00` na ocultação e `$9800` na região corrente. O fonte precisa estar preparado: não foi observado zeramento implícito.

Os 16.384 prefixes cobrem ambos os helpers indexados com todos os índices/16 flags, parando em `$01E3` antes de consumir registros arbitrários, e ambos os controles com todos os valores LCDC/16 flags, parando no thunk de áudio/cópia. As 84 chamadas completas incluem 64 preparações (quatro registros, dois VBKs, LCD desligado/ligado e quatro atributos) e 20 cópias (retângulo fixo 20×8 e quatro dimensões dos registros, dois VBKs e LCD desligado/ligado). Conferem os dois planos inteiros, campos/guards, registradores/flags da preparação e bytes/guard da fonte, WRAM e mapper das cópias. São 32.936 novos asserts, total 17.445.613, além dos 24 testes do verificador. Produção natural do fonte, índices/dimensões arbitrários, áudio completo nesta unidade, interpretação japonesa e hardware continuam sem prova.

### Reset, seleção e tick de recursos A `$12` — `$4CFD-$4D81`

`engine/menus/a12_resource_control.asm` extrai 133 bytes em nove seções: dois resets, dispatcher, tabela de quatro words, quatro setters HL e tick. `ResidualROM09_4CFD` permanece como alias; o residual seguinte começa em `$4D82`. São 532 seções: 331 analisadas (43.948 bytes) e 201 residuais (1.004.628 bytes). Interpretação `PROBABLE` por fluxo e probes sintéticos, sem trace natural.

O reset limpa `$C5CC/$C5CE`; a entrada estendida também limpa `$C5E4/$C5E5/$C5E6/$C5E7`. Ambas selecionam a tabela e chamam o leitor `$4D82`. O dispatcher dobra `$C5A8` com wrap, empilha retorno `$4D3B` e salta para o word selecionado. Os índices 128–131 são aliases de 0–3, sem validar os demais. Os quatro setters devolvem HL=`$6BBD/$6AD0/$6AE5/$6A3D`; o banco B efetivo desses recursos continua a conferir no leitor, não foi inferido do endereço.

O tick subtrai o limiar `$C5CB` do contador `$C5CC`. Abaixo dele, segue para `$4EEA`. Caso contrário, limpa o contador e incrementa `$C5CE` com wrap. Se o novo valor for igual à contagem `$C5CD`, copia a fase `$C5D1` para `$C5CF` e chama reset; caso contrário, grava o índice e seleciona a tabela. Os dois avanços chegam ao leitor `$4D82`, com retornos/nesting distintos.

Os 1.122.304 prefixes incluem todos os índices/16 flags do dispatcher (4.096), ambos os resets/oito aliases/todos os bytes de fase com flags derivadas (4.096), todos os pares limiar/contador/16 flags com índice/contagem fixos (1.048.576), e todos os pares contagem/índice com fase de transição `$A5` e flags derivadas (65.536). Conferem registradores/flags, pilha original, campos e guards; não executam os corpos de movimento/leitor. O corpus do tick cobre 522.240 saídas para movimento e, nos pares de contagem/índice, 256 resets por igualdade e 65.280 avanços normais, incluindo wrap 255→0. As 192 chamadas completas cobrem os quatro setters e os oito aliases do dispatcher com 16 flags. São 2.244.992 novos asserts, total 19.690.605, além dos 24 testes do verificador. Produção/ritmo natural do contador, recursos/mapeamento, validade de seletores arbitrários, significado japonês e hardware continuam sem prova.

### Leitor mapeado e coordenadas A `$12` — `$4D82-$4DFD`, `$4E7A-$4EE9`

`engine/menus/a12_resource_reader.asm` extrai 236 bytes em três seções e conserva `ResidualROM09_4D82` como alias. O controle de recursos já publicado chama o nome do leitor. São 536 seções: 334 analisadas (44.184 bytes) e 202 residuais (1.004.392 bytes). Interpretação `PROBABLE` por fluxo e execução sintética, sem trace natural.

O leitor salva `$FFAD/$FFAE` em `$FF9D/$FF9E`, seleciona B com `$C21C/$C21D` e atualiza `$FFAD/$FFAE`. Usa fase `$C5CF` dobrada com wrap para buscar um ponteiro; lê a contagem e calcula `índice×4` em 16 bits. `$FF/$FE` iniciais chamam os efeitos ainda numéricos `$4FAF/$50C8`. O registro comum preenche `$C5D0/$C5D7/$C5D8/$C5CB`; a leitura antecipada pode pular um registro `$FF` e depois um `$FE`, preenchendo `$C5D1/$C5D9/$C5DA/$C5FD`. As coordenadas subtraem `$C9/$D0` com wrap de byte; as distâncias são diferenças absolutas entre bytes resultantes sem sinal, sem clipping.

As 1.118.208 chamadas completas cobrem 4.096 tuples de offsets com todos os bytes por campo/16 flags, 1.048.576 pares de distâncias/16 flags (Y é o par X invertido, não produto cartesiano de quatro coordenadas) e 65.536 leitores com todas as fases/índices, flags derivadas e tabela/registros WRAM sintéticos. Há 16.384 casos de cada leitura antecipada: comum, `$FF`, `$FE` e `$FF+$FE`. Conferem registradores/flags, ponteiros, campos/guards e mapeamento. Os 36.864 prefixes incluem sete seletores ROM com todas as fases/16 flags até a leitura do ponteiro (28.672), conferindo assinaturas independentes de quatro bytes em `$6000`, e ambos os marcadores iniciais com todos os índices/16 flags até os efeitos reais (8.192), sem executar seus corpos. Os dois planos inteiros de VRAM ficam intactos no corpus do leitor comum/prefixes.

No retorno comum, B permanece solicitado; `$FF9D/$FF9E` conservam 5/0, `$FFAD/$FFAE` ficam `$63`/0 e `$C115/$C116` continuam 5/0 nas fixtures. Não são um único espelho universal nem uma restauração automática. São 2.441.217 novos asserts, total 22.131.822, além dos 24 testes do verificador. Os probes usam modo ROM=0; flash, tabelas naturais, ritmo/produção, efeitos especiais completos, todos os seletores/janelas inteiras e hardware permanecem sem prova.

### Efeitos `$FF/$FE` A `$12` — `$4FAF-$4FFE`, `$50C8-$50D7`

`engine/menus/a12_resource_effects.asm` extrai 96 bytes (80 de tiles, 16 de áudio). O leitor usa seus nomes; `ResidualROM09_50C8` permanece no endereço original. São 538 seções: 336 analisadas (44.280 bytes) e 202 residuais (1.004.296 bytes). Interpretação `PROBABLE`, por fluxo e execução sintética, sem trace natural.

O efeito `$FF` lê um ponteiro little endian dos bytes 2/3 do marcador, consome sete campos de cabeçalho e chama a cópia original de tiles. Incrementa `$C5CE`, limpa `$C5E5/$C5E7` e restaura HL para marcador+4, não para o fim do payload. O avanço do payload continua `2×((largura×altura)&255)`, inclusive quando a área é 256 ou maior. O efeito `$FE` passa o byte 1 ao thunk original `$024F`, executa o instalador de streams superiores, consome os dois bytes restantes e incrementa `$C5CE`, com carry preservado nas flags de INC.

Os 4.096 prefixes cobrem todos os requests/16 flags até `$024F`. As 69.680 chamadas completas incluem 65.536 pares request/índice de áudio com flags derivadas e programa sintético de um canal, 4.096 cópias 1×1 com todos os índices/16 flags e 24 cópias de seis geometrias com ambos os VBKs/LCD desligado ou ligado. Outras 24 integrações, incluídas nesse total, executam `$FF`, `$FE` e `$FF+$FE` dentro do leitor, com índice 0/255, ambos os VBKs e estados do LCD. Modelos independentes conferem campos, registradores/flags, fonte/guards e os dois planos inteiros nas geometrias/integrações. Requests sem bit 7 não instalam stream; os demais usam a tabela WRAM preparada, sem provar uma tabela natural ou todos os programas.

Após efeitos reais, `$C115` acompanha B corrente, em vez de permanecer no valor antigo observado no leitor comum; a cópia usa `$FF9D` para largura. BC/DE do leitor integrado refletem a cópia real, sem preservação inventada. São 147.600 novos asserts, total 22.279.422, além dos 24 testes do verificador. Cabeçalhos/payload/programas são sintéticos em WRAM; geometrias arbitrárias, recursos naturais, waveform/ritmo, flash e hardware continuam sem prova.

### Controlador de modo de texto A `$12` — `$4B70-$4BDC`

`engine/menus/a12_text_mode.asm` extrai 109 bytes e liga os quatro handlers publicados ao nome `UpdateA12TextModeController`. `ResidualROM09_4251` conserva seu endereço no prefixo literal encurtado. São 539 seções: 337 analisadas (44.389 bytes) e 202 residuais (1.004.187 bytes). Interpretação `PROBABLE`, sem trace natural.

`$C601=0` retorna; modos não zero/não `$FF` exigem `$C5CF=1`, gravam fase 2 e chamam reset. Depois, modo 1 segue para `$5C2F`; modo 2 grava `$C73A=1`, prepara registro de texto 0, exibe janela, enfileira ponteiro `$5695` e grava modo `$FF`; demais retornam. O modo `$FF` pode limpar `$C1C2` pelo bit 0 de `$FF97` antes de testar busy `$C1B8`. Quando livre, chama ocultação/cópia, grava fase 1, reseta recursos e limpa `$C601`; pending `$C73B` não zero chama `$5C55` e depois é limpo.

Os 2.097.152 casos na entrada inteira cobrem todos os pares modo/fase/16 flags (busy=1, edge=0) e todos os pares edge/busy/16 flags (modo=`$FF`). São 2.088.992 retornos completos pelas guards e 8.160 prefixes nos primeiros callees reais: 4.064 resets e 4.096 ocultações. Conferem flags, campos/guards, registradores e pilha original.

Outros 12.288 casos começam explicitamente em trechos após callees não executados: todos os modos/flags em `$4B88`, fases anteriores/flags em `$4BC2` e pending/flags em `$4BCA`. Param nos calls/tails reais ou concluem retornos locais. As 4.096 chamadas em `$4BD7` cobrem todo AF e preservação das flags. São evidências locais, sem substituir calls/returns nem provar uma cadeia completa do controlador. São 4.227.072 novos asserts, total 26.506.494, além dos 24 testes do verificador. Corrigiu-se N omitido na expectativa de `CP` igual (flags `$C0`, não `$80`), sem mudar bytes originais. Integração completa com `$5C2F/$5C55`, trace natural de modos/texto/input, significado japonês, IRQ/ritmo e hardware continuam sem prova.


### Pending text e ações A12 (2026-10-07)

`engine/menus/a12_pending.asm` extrai 208 bytes em cinco seções `$5C2F-$5CFE`; `data/menus/a12_pending.asm` extrai os 126 bytes da tabela `$56AD-$572A`. O alias `ResidualROM09_5334` permanece no endereço publicado; os outros bytes seguem explícitos. São 546 seções: 343 analisadas (44.723 bytes), 203 residuais (1.003.853 bytes). Interpretação `PROBABLE`, sem trace natural.

O tail de texto prepara o registro 0, exibe a janela e enfileira a palavra em offset 4 do registro de seis bytes, gravando `$C601=$FF`. O dispatcher lê offset 3: zero retorna; valores 1/2/3 acionam handlers com recursos de cor `$53B2/$5432/$54B2`, modo 4 e incremento de `$C5A3`. A ação 3 preserva `$C706`, grava três campos `$C708-$C70A=6` e `$C214=5`; as ações 1/2 gravam apenas seu campo correspondente, `$C706=1/2` e `$C214=4`. Todas limpam `$C738/$C213/$C1C4`.

O scanner forçado em `$5BEB` verifica os 21 registros e termina no primeiro `$FF` em `$572B`; os três bytes `$FF` seguintes não foram interpretados como parte do terminador. Os dois tails usam `(C73B-1)&255`, sem clamp. Zero produz índice 255, fora da tabela medida; os probes de índices arbitrários demonstram aritmética e leitura local, sem afirmar validade natural desses índices.

Os probes acrescentam 44.224 asserts, total 26.550.718: 4.096 entradas forçadas do scanner, 4.096 prefixos do dispatcher antes da leitura, 4.096 sufixos de mensagem com queue real, 288 chamadas completas de ação zero, 12.288 chamadas completas das três ações e 1.344 chamadas completas de texto (21 registros, 16 flags, ambos VBK/LCD). A comparação das duas planes inteiras de VRAM detecta escritas fora do frame; a expansão de 192 componentes e deltas de cor é comparada por modelo independente. Nenhum retorno de callee é injetado. Os sufixos não executam preparação/exibição; as chamadas completas de texto as executam com ambiente de áudio sintético já documentado. Não há prova de interpretação/exibição natural das strings, integração completa do controlador, tradução, hardware ou timing/IRQ.


### Scanner de pending A12 — `$5BDA-$5C2E` (2026-10-07)

`engine/menus/a12_pending_scanner.asm` extrai 85 bytes e nomeia o callee da inicialização em `$4054` como `UpdateA12PendingRecord`. O alias `ResidualROM09_572B` permanece no endereço publicado. São 547 seções: 344 analisadas (44.808 bytes) e 203 residuais (1.003.768 bytes). Interpretação `PROBABLE`, sustentada por fluxo estático e execução sintética da rotina inteira, sem trace natural.

A rotina copia `$C706` para `$C5A8`, lê `$C708+C706` para `$C5A4` e procura `$C705` no primeiro byte de cada registro. Se não encontra, retorna no primeiro `$FF`, preservando progress/pending. Se encontra, incrementa `$C705`, grava o índice baseado em 1 em `$C73B`, copia o terceiro byte do registro para `$C708+variante` e `$C5A4`; quando o segundo byte é 1, seleciona `$C5A8=3` e limpa `$C738`. Os dois outros campos da tabela continuam literais, sem nomenclatura semântica adicional. Não há clamp da variante.

Os 4.096 prefixos de entrada cobrem todas as variantes/16 flags até `$5BEB`, conferindo leitura e aritmética sem afirmar validade natural. As 16.384 chamadas completas cobrem quatro variantes, todos os 256 valores de `$C705` e 16 flags, com valores anteriores variados nos quatro campos: 1.344 matches e 15.040 retornos sem match. Conferem todos os campos alterados, guards, registradores, flags e retorno original. São 36.864 novos asserts, total 26.587.582, além dos 24 testes do verificador. Não se executa a inicialização inteira nem se confirma o significado japonês dos registros, a seleção natural, hardware ou ritmo/IRQ.


### Dispatcher de comandos A12 — `$4AC9-$4B6F` (2026-10-07)

`engine/menus/a12_resource_commands.asm` extrai 167 bytes e liga os quatro handlers ao nome `DispatchA12ResourceCommand`. `ResidualROM09_4251` conserva seu endereço. São 548 seções: 345 analisadas (44.975 bytes), 203 residuais (1.003.601 bytes). Interpretação `PROBABLE`, por fluxo e execução sintética, sem trace natural.

O dispatcher lê `$C5FD`, sem limpar o comando. Zero e valores não reconhecidos retornam; `$F0` grava `$C738=1`. `$F1/$F2/$F3` gravam `$C214=0/1/2`, com `$F1` também limpando `$C624`. `$F4/$F5/$F6` chamam o countdown real `$0255`, gravam `$C214=4` e `$C706=1/2/0`. `$F7` grava `$C214=6`, `$FE` grava 4. Esses oito comandos limpam `$C213/$C1C4`, calculam `$53B2+128*C5A8`, iniciam transição de cor em modo 4 e incrementam `$C5A3`. Não há clamp da variante nem inferência de que recursos arbitrários sejam paletas naturalmente válidas.

Os probes incluem 16.384 chamadas completas (quatro variantes, todos os 256 comandos e 16 flags) e 8.192 chamadas completas adicionais dos oito comandos de transição com todos os estados `$C5A3`. Conferem campos/guards, countdown, retorno, registradores, flags e os 192 componentes/deltas de cor por modelo independente. Outros 4.096 sufixos forçados em `$4B4C` cobrem todas as variantes/flags até o call real `$017A`, sem executar a transição nesses índices arbitrários. Não há retorno de callee injetado. São 53.248 novos asserts, total 26.640.830, além dos 24 testes do verificador. A integração natural com o leitor de recursos/handlers, significado japonês, validade natural dos recursos, IRQ/ritmo e hardware permanecem sem prova.


### Input e subdispatchers A12 — `$470F` (2026-10-07)

`engine/menus/a12_input_mode.asm` extrai 145 bytes de código: `$470F-$475D` e os três subdispatchers `$4764-$4779/$485A-$486F/$4940-$4955`. `data/menus/a12_input_mode.asm` preserva 42 bytes de tabelas: três alvos em `$475E-$4763` e seis alvos por variante em `$477A-$4785/$4870-$487B/$4956-$4961`. Os corpos de ação continuam residuais. `ResidualROM09_4251` conserva seu endereço. São 559 seções: 353 analisadas (45.162 bytes), 206 residuais (1.003.414 bytes). Interpretação `PROBABLE`, sem trace natural.

`UpdateA12InputMode` exige `$C600=1`. O bit 0 de `$FF97` tem prioridade e solicita áudio `$9D`; depois limpa input, copia `$C214` para `$C732` e despacha por `$C5A8`. Sem bit 0, o bit 1 solicita áudio `$9E`, oculta/copia a janela e limpa `$C213/$FF97/$C600`. Sem os dois bits retorna. Os subdispatchers selecionam a ação por `$C214`. Todos os seletores dobram o índice em byte com wrap, sem clamp; variante 3 não é uma quarta entrada medida da tabela inicial. Os retornos originais são empilhados antes dos jumps.

As 1.048.576 entradas completas cobrem todos os pares modo/input e 16 flags: 1.045.504 retornos pelas guards e 3.072 prefixes no primeiro call real de áudio. Outros 16.384 prefixes conferem todos os índices/flags até os jumps reais nos quatro dispatchers; os 16.384 retornos isolados preservam AF/registradores. As 12.288 confirmações executam áudio real e param antes de despachar os três alvos, cobrindo todos os valores anteriores de `$C214` e 16 flags, inclusive bit 0 com bit 1 simultâneo. As 4.096 chamadas completas de cancelamento cobrem os 64 bytes de input com bit 1 sem bit 0, 16 flags, ambos VBK/LCD; comparam as duas planes inteiras de VRAM, os bytes sintéticos de origem, guards e estado após áudio/ocultação/cópia reais. Os tables de áudio e a imagem copiada são sintéticos, não saves.

São 2.166.784 novos asserts, total 28.807.614, além dos 24 testes do verificador. Não há retorno de callee injetado. O caminho de confirmação para antes dos corpos de variante/ação, e os índices arbitrários param antes de consumir os alvos. A integração natural dos handlers/ações, significado japonês, validade natural dos índices, IRQ/ritmo e hardware continuam sem prova.


### Corpos de ação A12 — 18 alvos (2026-10-07)

`engine/menus/a12_input_actions.asm` extrai 620 bytes em 18 seções: `$4786-$4859`, `$487C-$493F`, `$4962-$4A35`. Os aliases `ResidualROM09_4786/487C/4962` permanecem em seus endereços, e as três tabelas publicadas agora usam nomes de ação. `$4A36-$4AC8` continua residual. São 575 seções: 371 analisadas (45.782 bytes), 204 residuais (1.002.794 bytes). Interpretação `PROBABLE`, sem trace natural.

Todos os corpos ocultam/copiam a janela, limpam `$C213`, gravam `$C600=2`, configuram tiles com `$5093`, escolhem fase e chamam o reset real `$4CFD`. As ações 0/1 usam o mesmo header, com fases 7/8. As ações 2/3 podem escolher header por limiares de `$C5A4`, com fases 3/5. As ações 4/5 usam fases 4/6 nas variantes 0/1, mas 6/4 na variante 2. Headers e sequências são lidos da ROM original nas janelas B `$61/$63/$65`; os dados japoneses permanecem intactos.

| Variante | Ação 0/1 | Ação 2 | Ação 3 | Ação 4 | Ação 5 |
| --- | --- | --- | --- | --- | --- |
| 0 | `$6895` | `<3: $68EF`, demais `$6939` | `<6: $69AC`, demais `$69CB` | `$6B74` | `$6B9E` |
| 1 | `$6866` | `<6: $689D`, demais `$68B4` | `$68CB` | `$6A7F` | `$6A51` |
| 2 | `$6800` | `<2: $6837`, demais `$6846` | `<3: $6855`, demais `$6874` | `$6ACE` | `$6AA8` |

As 4.608 chamadas diretas cobrem todos os 256 valores de `$C5A4` nos 18 corpos, com flags variadas. As 576 cadeias completas desde `$470F` cobrem todos os alvos, valores 0/1/2/3/5/6/7/255, ambos VBK/LCD e flags variadas; usam áudio real com tabelas sintéticas e comparam as duas planes inteiras de VRAM contra a composição da janela copiada e dos tiles originais. A origem WRAM7 é sintética e seus 320 bytes/guard são preservados. Headers, ponteiros/avanço de payload, registros de recursos, normalização/distâncias, fases, counters, registradores e guards são comparados por modelos independentes. Os primeiros registros de reset são ordinários; o lookahead mantém o skip real de markers sem promover isso a efeito executado. Nenhum retorno de callee é injetado.

São 21.312 novos asserts, total 28.828.926, além dos 24 testes do verificador. A integração sintética percorre os corpos antes pendentes, mas não demonstra input natural, significado japonês, hardware ou ritmo/IRQ. O caminho de confirmação com índices arbitrários continua limitado pelas tabelas medidas; os índices fora delas não são tratados como naturalmente válidos.


### Wrappers de recursos e emissores A12 (2026-10-07)

`engine/menus/a12_resource_wrappers.asm` extrai 385 bytes em oito seções: quatro wrappers `$4A36-$4AC8`, emissor principal `$4DFE-$4E64`, cópia de posição `$4E65-$4E79`, emissor secundário `$5188-$51E4` e cópia secundária `$51E5-$51F9`. Os aliases `ResidualROM09_4A36/4DFE/50D8` conservam seus endereços. São 582 seções: 379 analisadas (46.167 bytes), 203 residuais (1.002.409 bytes). Interpretação `PROBABLE`, sem trace natural.

Os wrappers gravam pedidos B `$61/$63/$65/$66` em `$C21C`, com `$C21D=0`; isso não troca a janela por si só. Os três primeiros incrementam `$C5CC` em 1 ou 4 conforme `$C73A` zero/não zero; o quarto incrementa em 1. Os ticks `$50DF/$4D54` e outros callees continuam como dependências de integração completa. Os 16.384 probes de entrada param no primeiro call real, cobrindo todas as flags e valores anteriores do byte alto do pedido. Os 196.608 sufixos dos três primeiros cobrem todos os pares counter/acceleração com flags variadas; os 4.096 do quarto cobrem cada counter/flag. São trechos após callees não executados, sem retorno injetado.

As duas cópias de posição gravam `$C5D7/D8 → C5D5/D6` e `$C5EB/EC → C5E9/EA`; 131.072 chamadas completas cobrem todos os pares de coordenadas, com flags variadas. Os emissores trocam B pelo pedido, gravam os mirrors HRAM e backup `$FF9D/9E`, sem atualizar por si os mirrors WRAM `$C115/116`. O principal copia a disponibilidade `$C1C7` para `$C5F5` e a decrementa por registro; o secundário usa `$C5F5` sem decrementá-lo. Ambos retornam quando disponibilidade é zero, indexam tabela por offset dobrado de byte e usam origem `$C000+4*((40-disponibilidade)&255)`. Cada registro escreve Y+16, X+8, tile e atributo, com coordenadas de byte. Os quatro increments de E não propagam carry para D. Count zero equivale a 256 iterações, sem clamp de count/capacidade.

As 4.096 chamadas completas de emissores cobrem todos os bytes de count com disponibilidades 0/1/40/255, e todas as disponibilidades com counts 0/1/3/255, índices e coordenadas variados. O modelo compara toda a área `$C000-$C3FF`, registradores, flags, pointers, disponibilidade e origem sintética. Nos estados adversariais, escritas fora dos 40 slots podem alcançar outros campos WRAM; o modelo também verifica essas sobrescritas, sem atribuir validade natural aos estados. Corrigiu-se o fixture: a inicialização da área havia sobrescrito pedidos/mirrors, e o oracle inicialmente presumiu mirrors WRAM intactos mesmo quando o destino sintético os alcançava. Nenhum byte original foi alterado.

São 688.128 novos asserts, total 29.517.054, além dos 24 testes do verificador. Os emitters usam tabelas/registros sintéticos; a montagem continua idêntica. Integração completa dos wrappers/ticks, fluxo natural de OAM/capacidade, significado japonês, IRQ/ritmo e hardware continuam sem prova.


### Movimento e divisão A12 (2026-10-07)

`engine/menus/a12_resource_movement.asm` extrai 197 bytes em três seções: movimento `$4EEA-$4F4E`, divisão `$4F4F-$4F69` e cálculo de passos `$4F6A-$4FAE`. `ResidualROM09_4EEA` permanece no endereço original. Cobertura: 584 seções, 382 analisadas (46.364 bytes), 202 residuais (1.002.212 bytes). Interpretação `PROBABLE`, sustentada por fonte e execução sintética, sem trace natural.

A divisão retorna quociente em H e resto em L, preservando BC/DE. Divisor zero produz quociente 255 e resto igual ao dividendo. O cálculo de passos zera os restos e repete, por eixo, a divisão da soma de distância e resto anterior, com soma em byte; counter zero executa 256 iterações. Os últimos quocientes ficam em `$C5DB/DC`, e os restos em `$C5DF/E0`. O movimento retorna imediatamente quando ambas as coordenadas já coincidem; nos demais casos calcula passos e soma/subtrai conforme comparação unsigned da coordenada com o alvo, com wrap e sem clamp ao alvo.

Os probes executam 1.048.576 divisões completas (todos os pares dividendo/divisor e 16 flags), 131.072 cálculos de passos (todos os pares distância/divisor com counter 1 e todos os pares counter/divisor com distâncias variadas), 196.608 movimentos em três famílias cobrindo todos os pares coordenada/alvo, e 3.072 cadeias completas dos wrappers de variantes 1/2/3. Estas últimas percorrem tick pelo ramo de movimento, cópia de posição, emissor com disponibilidade zero e incremento final, com counters 0–3, divisor 7 e todos os bytes de aceleração. Comparam registradores/flags, campos, guards e mapping contra modelos independentes; não injetam retorno de callee. Acrescentam 2.758.656 asserts, total 32.275.710, além dos 24 testes do verificador.

As cadeias completas cobrem somente esse ramo e disponibilidade zero; não demonstram todos os caminhos dos wrappers, variante 0, emissão integrada com recursos, fluxo natural, significado japonês, IRQ/ritmo ou hardware. A ROM original e seus bytes japoneses permanecem intactos.


### Recursos secundários A12 (2026-10-07)

`engine/menus/a12_secondary_resource.asm` extrai 458 bytes em sete seções: load `$50D8-$50DE`, tick `$50DF-$5116`, leitor `$5117-$5187`, normalização `$51FA-$5222`, distâncias `$5223-$5269`, movimento `$526A-$52CE` e passos `$52CF-$5313`. Os aliases `ResidualROM09_50D8/51FA` permanecem nos endereços originais; o wrapper da variante 0 usa o tick nomeado. Cobertura: 589 seções, 389 analisadas (46.822 bytes), 200 residuais (1.001.754 bytes). Interpretação `PROBABLE`, sem trace natural.

O load passa a tabela original `$6EE0` ao leitor sem resetar campos. No tick, counter menor que threshold despacha ao movimento; caso contrário, o frame seguinte igual ao count provoca leitura do frame zero e posterior restauração do frame anterior via AF empilhado. Nos demais casos grava o frame incrementado, lê e depois decrementa o campo. O counter não é zerado nesse tick. O leitor troca a janela B conforme o pedido, sem atualizar os mirrors WRAM; indexa a tabela com offset dobrado em byte, descarta o primeiro byte do objeto e calcula endereço de registro por `4*frame`. Em cada uma das duas posições pode saltar primeiro um registro FF e depois um FE, sem loop geral de markers nem efeitos associados. Grava índice `$C5F6`, coordenadas atuais `$C5EB/EC` e alvo `$C5ED/EE`; não altera count, threshold ou counter. Depois aplica offsets de byte X−201/Y−208 e calcula distâncias unsigned `$C5F1/F2`. Movimento/passos repetem a aritmética do conjunto principal sobre campos secundários, chamando a mesma divisão; divisor e counter zero mantêm seus comportamentos originais.

Os probes cobrem 4.096 normalizações, 1.048.576 cálculos de distâncias, 131.072 cálculos de passos, 196.608 movimentos, 65.536 leitores completos com tabelas/registros sintéticos, 131.072 prefixes de tick até o leitor/movimento real, 4.096 prefixes de load e 8.192 sufixos explicitamente isolados do tick. Comparam registradores/flags, stack original nas fronteiras, coordenadas, distâncias, campos preservados e mapping. Os sufixos não executam o leitor e não são tratados como integração completa. Corrigiu-se o modelo inicial de tick para representar a gravação do frame incrementado antes do call; o fonte original permaneceu intacto.

Outras 1.024 chamadas completas da variante 0 percorrem os dois ticks pelo ramo de movimento, ambas as cópias de posição, os dois emissores com disponibilidade zero e o incremento final, com counters 0–3, divisor 7 e todos os bytes de aceleração, sem retorno de callee injetado. Acrescentam-se 3.205.248 asserts, total 35.480.958, além dos 24 testes do verificador. Os registros do leitor são sintéticos; o load/tick no caminho de leitura usa prefixes/sufixos delimitados. Integração completa com os recursos originais e emissão não vazia, validade natural de índices/markers, fluxo natural, significado japonês, IRQ/ritmo e hardware permanecem sem prova.


### Dados originais e integração secundária A12 (2026-10-07)

`data/menus/a12_variant0_secondary_resources.asm` refina 803 bytes: tabela de nove ponteiros `$6EE0-$6EF1` e nove objetos contíguos `$6EF2-$7202` na janela B `$61` (banco físico RGBDS `$30`). Cada objeto ocupa um byte inicial e `count+1` registros de quatro bytes; os counts medidos são 24/73/14/15/14/11/12/11/11. O leitor secundário descarta esse byte inicial, portanto a extensão medida não demonstra como o produtor escolhe `$C5CD`. Os ponteiros do load/tick usam agora o símbolo da tabela. `ResidualROM30_6000` permanece em seu endereço; somente os dois spans restantes foram emitidos como literais residuais. Cobertura: 600 seções, 399 analisadas (47.625 bytes), 201 residuais (1.000.951 bytes). Layout e interpretação `PROBABLE`; igualdade binária é `CONFIRMED` pelos gates.

O modelo independente usa ponteiros/counts medidos e bytes originais do buffer ROM, aplicando saltos FF depois FE, offsets e distâncias; compara registradores/flags, frame restaurado, guards, mapping e os 803 bytes imutáveis. São 2.960 loads completos e 2.960 ticks completos com os counts medidos, cobrindo cada frame e 16 flags nos nove objetos; outros 47.360 ticks cobrem todos os bytes de count para cada frame medido, com flags variadas. Nenhum retorno de callee é injetado. Os 53.280 calls executam leitura real, normalização/distâncias e os dois ramos de leitura do tick. A comparação do frame/count não restringe o leitor à extensão do objeto: 2.295 casos de count adversarial lêem além do objeto medido, em bytes adjacentes ainda dentro da janela ROM. Nenhum caso com count medido cruza seu objeto. Isso não prova corrupção ou validade natural dos estados adversariais.

São 159.849 novos asserts (incluindo nove contratos de ponteiro/count/fronteira), total 35.640.807, além dos 24 testes do verificador. Esta unidade fecha a integração sintética de load/tick secundário com recursos originais nos caminhos descritos; ainda não demonstra fluxo natural, produtor do count, índices fora das nove entradas, integração com emissão não vazia, significado japonês, IRQ/ritmo ou hardware. Os bytes japoneses e a ROM original permanecem intactos.


### Recursos principais e pares A12 originais (2026-10-07)

`data/menus/a12_variant0_primary_resources.asm` refina 803 bytes: tabela de nove ponteiros `$6BBD-$6BCE` e objetos contíguos `$6BCF-$6EDF`, na janela B `$61` (RGBDS `$30`). O seletor da variante 0 usa o símbolo da tabela. Os counts e extensões `1+4*(count+1)` correspondem aos nove objetos secundários já medidos. `ResidualROM30_6000` conserva seu endereço; apenas seu restante `$6000-$6BBC` foi reemitido como literal residual. Cobertura: 610 seções, 409 analisadas (48.428 bytes), 201 residuais (1.000.148 bytes). Layout e interpretação `PROBABLE`, sem trace natural; equivalência binária `CONFIRMED` pelos gates.

O leitor principal grava em `$C5CD` o byte inicial do objeto, grava em `$C5CB` o quarto byte do registro atual e preserva `$C5CC` nas leituras ordinárias. O reset principal zera counter/frame antes de ler. O load secundário seguinte preserva esses campos e os resultados principais, produzindo um segundo conjunto de coordenadas/distâncias a partir do objeto secundário da mesma fase. A correspondência foi executada com bytes originais; não demonstra seleção natural das fases nem os produtores externos que solicitam esses caminhos.

São 36.864 cadeias reset principal → load secundário: nove fases, todos os bytes anteriores de counter/frame (frame anterior permutado por `37*counter`) e 16 flags. Outras 44.032 cadeias leitor principal → load secundário cobrem os 172 registros atuais ordinários e todos os bytes de counter, com flags variadas. Os 13 registros atuais FF/FE ficam fora dessas cadeias e pendentes para integração dos efeitos; markers no lookahead são saltados pelos leitores reais. Cada chamada percorre os callees reais, sem retorno injetado. Modelos independentes comparam registradores/flags, ponteiros, count/threshold/counter/frame, campos principais/secundários, guards, mapping/backups e os 1.606 bytes originais imutáveis. Corrigiu-se um acesso do fixture à tabela secundária que omitia o offset da janela; o erro foi detectado no primeiro contrato, sem mudança do fonte original.

São 404.489 novos asserts, total 36.045.296, além dos 24 testes do verificador. Esta unidade liga o count principal aos pares originais no caminho sintético descrito. Permanecem sem prova a integração desses 13 efeitos atuais com os recursos originais, emissão não vazia, fluxo natural, significado japonês, IRQ/ritmo e hardware. Os bytes japoneses e a referência externa permanecem intactos.


### Efeitos originais FF/FE A12 (2026-10-07)

`data/menus/a12_variant0_effect_tiles.asm` refina 177 bytes nos recursos `$6800-$6836`, `$6837-$686D` e `$6A0F-$6A51`, janela B `$61` (RGBDS `$30`). Os três FF da tabela principal referenciam seus símbolos. Cada recurso contém header de sete bytes e duas frames de duas planes, com geometrias 1×12, 1×12 e 3×5. As fronteiras correspondem a `7+2*largura*altura*2`; esta integração copia a primeira frame, sem atribuir execução à segunda. `ResidualROM30_6000` permanece no endereço, e somente os spans restantes foram reemitidos. Cobertura: 615 seções, 412 analisadas (48.605 bytes), 203 residuais (999.971 bytes). Layout/interpretação `PROBABLE`; igualdade binária `CONFIRMED` pelos gates.

Os probes agora executam os 13 registros atuais de efeito originais: três FF e dez FE, com pedidos `$82/$83`. Os dois FF da fase 0 são seguidos por FE, e o FF da fase 5 é seguido por registro ordinário. Os callees reais instalam/copiam os tiles, solicitam áudio e incrementam frame antes de consumir o registro ordinário seguinte; o load secundário usa o frame já avançado. São 13.312 cadeias leitor principal → load secundário, cobrindo todos os bytes de counter, flags variadas e ambos VBK/LCD. Não há retorno de callee injetado.

Os mirrors B são preparados coerentemente como `$61`, para que o copier consuma o payload original. Modelos independentes comparam registradores/flags, ponteiros, campos/guards de ambos os leitores, header/estado de tile, mapping/backups, todos os 1.606 bytes dos pares e os 177 bytes de tile imutáveis. A comparação das duas planes inteiras de VRAM usa destino calculado do header e payload original; nos casos apenas FE, toda VRAM permanece igual. O áudio usa programa sintético de um canal compartilhado pelos seletores, e seus campos/slots são conferidos: isso executa o caminho de instalação, mas não identifica o conteúdo sonoro original nem discrimina sons entre `$82/$83`.

São 79.875 novos asserts, total 36.125.171, além dos 24 testes do verificador. Esta unidade fecha a integração sintética dos 13 efeitos atuais com os registros e primeiro payload de tile originais. Permanecem pendentes a execução das segundas frames originais, emissão de OAM com disponibilidade não zero, cadeia natural de menu/input, significado japonês, áudio original, IRQ/ritmo e hardware. Os bytes japoneses e a ROM externa permanecem intactos.


### Ciclo das duas frames originais de tiles A12 (2026-10-07)

Os probes percorrem agora o setup `$5093` e o tick `$5051` dos três recursos originais `$6800/$6837/$6A0F`, incluindo a segunda frame e os caminhos de parada/loop. Os dois primeiros recursos param após a segunda frame, zerando delay/frame sem apagar a imagem nem rebobinar o pointer final; chamadas seguintes retornam pela guard de delay zero. O terceiro mantém delay 16, rebobina o pointer e copia novamente a primeira frame no término. Interpretação `PROBABLE`, por fonte e execução sintética, sem fluxo natural.

São 9.216 cenários, com três estágios preparados por chamadas reais (primeira frame, segunda frame, término/parada ou loop), todos os bytes de counter, flags variadas e ambos VBK/LCD. Cada cenário chama o setup original, prepara seu estágio com zero/um/dois ticks reais e executa o tick sob teste: 27.648 calls completos, sem retorno de callee injetado. Somente o counter de delay é controlado pelo fixture; os estados de frame/pointer são produzidos pelos callees reais. Isso não demonstra ritmo natural.

Após cada call, modelos independentes comparam registradores/flags, header, counter/frame/delay, pointer atual/base, guards, mapping/backups, VBK, IME com interrupções desabilitadas na entrada pelo fixture e os 177 bytes originais imutáveis. As duas planes inteiras de VRAM são comparadas com o payload original da frame esperada, preservando todo o restante. Corrigiu-se a expectativa do scratch `$FF9D`: o copier termina com a largura, não com X do header; o primeiro contrato detectou o erro e o fonte original permaneceu intacto.

São 82.944 novos asserts, total 36.208.115, além dos 24 testes do verificador. Nenhum span adicional foi extraído: a cobertura continua em 615 seções, 412 analisadas (48.605 bytes) e 203 residuais (999.971 bytes), com a ROM inteira idêntica. Esta unidade fecha a execução sintética das duas frames e parada/loop originais desses três recursos. Emissão OAM com disponibilidade não zero, cadeia natural de menu/input, significado japonês, áudio original, IRQ/ritmo e hardware continuam pendentes.
