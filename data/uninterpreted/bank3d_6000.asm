; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $3D, address $6000-$7FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 3D:6000-7FFF", ROMX[$6000], BANK[$3D]
ResidualROM3D_6000::
	ds $2000, $00
ASSERT @ == $8000
