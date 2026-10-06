# Net de Get — MBC6 research

Este repositório separado guarda evidências do comportamento de MBC6 que ajudam a completar o suporte no mGBA. O escopo atual é deliberadamente pequeno: identificação da ROM hospedeira, análise do despacho ROM/flash e testes locais reproduzíveis necessários para validar o mapper.

Não é uma reconstrução completa RGBDS nem implementa Mobile Adapter/REON, e não contém a ROM comercial. Inclui fragmentos RGBDS estáticos das rotinas MBC6 já decodificadas; cada fragmento está marcado com seus limites de evidência.

- Identificação e checksums: [`docs/ROM_INFO.md`](docs/ROM_INFO.md)
- Evidências do MBC6 no host: [`docs/research/mbc6-host.md`](docs/research/mbc6-host.md)
- Fragmentos RGBDS parciais: [`src/rom0/mbc6_helpers.asm`](src/rom0/mbc6_helpers.asm)
- Disassembly organizado por domínio: [`src/engine/`](src/engine/) e [`src/data/`](src/data/) (trechos parciais, com níveis de evidência anotados)
- Fixture de controles, entrada natural, saída e reabertura: [`fixtures/input-tester/README.md`](fixtures/input-tester/README.md)
- Produtor da ROM → flash → persistência, com entrada sintética explícita: [`fixtures/host-writer/README.md`](fixtures/host-writer/README.md)
- Equivalência dos trechos: `python3 tools/check_excerpts.py ORIGINAL_ROM` (compara só as seções reconstruídas, sem copiar a ROM).
- Hash da ROM externa: [`roms.sha256`](roms.sha256)
- Ferramentas e ambiente: [`INSTALL.md`](INSTALL.md)
