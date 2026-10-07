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

A montagem parcial contém agora **837 bytes em 12 seções**, todos comparados byte a byte com a referência externa. O comparador liga os objetos juntos para resolver referências entre arquivos e compara apenas as seções emitidas, exigindo também as fronteiras e símbolos do manifesto.

## Ciclos com validação

O trabalho segue o ciclo do Mobile Trainer: medir a próxima frente, extrair uma unidade coerente, conferir em cópia privada, repetir os checks no fonte final, publicar o checkpoint e atualizar a OMM. A continuidade não depende de Rafael escolher cada próximo trecho.

```sh
make verify REFERENCE_ROM="/caminho/externo/Net de Get - Minigame @ 100 (Japan).gbc"
```

Esse alvo executa montagem, `sym-check`, `test` e `compare`. O manifesto `config/excerpts.tsv` fixa banco físico RGBDS, início, fim inclusivo e símbolo de entrada de cada seção. Os 11 testes do verificador incluem falhas deliberadas: seções ausentes/extras/movidas, símbolos ausentes/movidos/duplicados, sobreposição, bytes alterados e imagens truncadas. São testes sintéticos da ferramenta, sem evidência de execução natural do jogo.

As novas rotinas cobrem ROM0 `$254E-$25CA` (dispatcher, 125 bytes) e `$3E00-$3ED7` (reconstrução da lista e cópia de template, 216 bytes). Seus nomes descritivos permanecem `PROBABLE`. O dispatcher restaura o seletor A salvo e impõe tipo ROM; a varredura pula o setor reservado `$70`, percorre seletores até `$80` e mantém a chamada externa `$38B0` ainda sem reconstrução. O ponteiro inicial HL da lista vem do chamador; nenhuma capacidade universal do destino foi demonstrada.

Próximas frentes: resolver a chamada `$38B0`, extrair o template usado por `$3EAE` com sua fronteira estática, e seguir os chamadores do menu. Nenhum título japonês é traduzido.
