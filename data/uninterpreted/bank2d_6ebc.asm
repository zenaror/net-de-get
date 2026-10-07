; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $6EBC-$6EBC.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:6EBC-6EBC", ROMX[$6EBC], BANK[$2D]
ResidualROM2D_6EBC::
	db $2F
ASSERT @ == $6EBD
