# Net de Get — MBC6 research

Este repositório separado guarda evidências do comportamento de MBC6 que ajudam a completar o suporte no mGBA. O escopo atual é deliberadamente pequeno: identificação da ROM hospedeira e análise estática do despacho ROM/flash necessário para validar o mapper.

Não é uma reconstrução RGBDS byte a byte, não implementa Mobile Adapter/REON e não contém a ROM comercial. Uma reconstrução integral poderá ser considerada em uma etapa futura.

- Identificação e checksums: [`docs/ROM_INFO.md`](docs/ROM_INFO.md)
- Evidências do MBC6 no host: [`docs/research/mbc6-host.md`](docs/research/mbc6-host.md)
- Hash da ROM externa: [`roms.sha256`](roms.sha256)
- Ferramentas e ambiente: [`INSTALL.md`](INSTALL.md)
