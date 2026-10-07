; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $3F, address $4000-$5FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 3F:4000-5FFF", ROMX[$4000], BANK[$3F]
ResidualROM3F_4000::
	ds $2000, $00
ASSERT @ == $6000
