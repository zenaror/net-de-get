# Net de Get — instruções para agentes

Este repositório reúne a análise MBC6 e o disassembly incremental do Net de Get. Por orientação de Rafael, enquanto não houver trabalho de suporte MBC6 no mGBA, avance o disassembly seguindo a organização do pret e do Mobile Trainer, sem tradução. A reconstrução completa ainda não está concluída.

- A ROM original é somente referência, fica fora do Git e nunca pode ser modificada. O hash está em `roms.sha256`.
- Não grave a ROM original, saves reais, dados pessoais, credenciais ou respostas de servidor neste repositório.
- Use `CONFIRMED`, `PROBABLE` e `HYPOTHESIS`, com evidência explícita. Uma interpretação estática sem trace natural não é `CONFIRMED`.
- MBC6 usa janelas independentes de 8 KiB; não confunda seletores do mapper com bancos físicos de 16 KiB das ferramentas.
- A organização do disassembly pode avançar além das rotinas MBC6. Implementação Mobile Adapter/REON e tradução permanecem fora do escopo. Preserve os bytes japoneses originais.
- Commit e push somente quando Rafael pedir nesta conversa.
- Ao terminar, atualize a OMM no escopo `mgba` e deixe handoff com fatos, limites e próximos passos.
