; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $08, address $6000-$7FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 08:6000-7FFF", ROMX[$6000], BANK[$08]
ResidualROM08_6000::
	ds $2000, $00
ASSERT @ == $8000
