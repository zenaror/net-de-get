; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0D, address $6000-$7FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0D:6000-7FFF", ROMX[$6000], BANK[$0D]
ResidualROM0D_6000::
	ds $2000, $00
ASSERT @ == $8000
