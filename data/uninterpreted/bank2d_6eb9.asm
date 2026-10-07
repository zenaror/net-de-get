; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $6EB9-$6EBC.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:6EB9-6EBC", ROMX[$6EB9], BANK[$2D]
ResidualROM2D_6EB9::
	db $FE, $00, $FF, $2F
ASSERT @ == $6EBD
