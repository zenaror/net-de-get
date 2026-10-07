# Net de Get — instruções para agentes

Este repositório reúne a análise MBC6 e o disassembly incremental do Net de Get. Por orientação de Rafael, enquanto não houver trabalho de suporte MBC6 no mGBA, avance o disassembly seguindo a organização do pret e do Mobile Trainer, sem tradução. A reconstrução completa ainda não está concluída.

- A ROM original é somente referência, fica fora do Git e nunca pode ser modificada. O hash está em `roms.sha256`.
- Não grave a ROM original, saves reais, dados pessoais, credenciais ou respostas de servidor neste repositório.
- Use `CONFIRMED`, `PROBABLE` e `HYPOTHESIS`, com evidência explícita. Uma interpretação estática sem trace natural não é `CONFIRMED`.
- MBC6 usa janelas independentes de 8 KiB; não confunda seletores do mapper com bancos físicos de 16 KiB das ferramentas.
- A organização do disassembly pode avançar além das rotinas MBC6. Implementação Mobile Adapter/REON e tradução permanecem fora do escopo. Preserve os bytes japoneses originais.
- Commit e push somente quando Rafael pedir nesta conversa.
- Ao terminar, atualize a OMM no escopo `mgba` e deixe handoff com fatos, limites e próximos passos.

## Ciclo de trabalho

- Encadeie frentes úteis de disassembly sem pedir a próxima etapa a Rafael. Meça as fronteiras, extraia um trecho coerente e repita a validação antes de publicar.
- Depois de alterar fontes, rode `make verify REFERENCE_ROM="/caminho/externo/ROM.gbc"`: montagem, manifesto de seções/símbolos, testes do verificador e equivalência byte a byte. Nunca trate a imagem parcial com padding como uma ROM completa.
- Mantenha `config/excerpts.tsv` com as fronteiras e símbolos de entrada esperados. Uma mudança deve preservar os endereços dos símbolos existentes.
- Rode `make private-check REFERENCE_ROM="/caminho/externo/ROM.gbc"` para verificar mudanças em cópia privada e repita os gates no fonte final. Testes negativos devem detectar defeitos que a checagem pretende impedir.
- Equivalência binária e execução natural são evidências diferentes: os testes sintéticos do verificador não promovem a interpretação de rotinas a `CONFIRMED`.
- A orientação de continuidade e testes foi autorizada por Rafael nesta conversa, seguindo o método do Mobile Trainer consultado na OMM.
- Não informe o chat mGBA enquanto ele não chamar, conforme orientação de Rafael. A atualização da OMM no escopo `mgba` continua valendo.
