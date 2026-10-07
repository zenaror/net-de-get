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
