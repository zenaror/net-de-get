# Net de Get — instruções para agentes

Este repositório reúne apenas a análise necessária para validar e completar o suporte MBC6 no mGBA. A reconstrução completa da ROM fica fora do escopo atual.

- A ROM original é somente referência, fica fora do Git e nunca pode ser modificada. O hash está em `roms.sha256`.
- Não grave a ROM original, saves reais, dados pessoais, credenciais ou respostas de servidor neste repositório.
- Use `CONFIRMED`, `PROBABLE` e `HYPOTHESIS`, com evidência explícita. Uma interpretação estática sem trace natural não é `CONFIRMED`.
- MBC6 usa janelas independentes de 8 KiB; não confunda seletores do mapper com bancos físicos de 16 KiB das ferramentas.
- Mobile Adapter/REON e reconstrução total da ROM permanecem fora do escopo até nova orientação de Rafael.
- Commit e push somente quando Rafael pedir nesta conversa.
- Ao terminar, atualize a OMM no escopo `mgba` e deixe handoff com fatos, limites e próximos passos.
