; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $6CC3-$6CC3.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:6CC3-6CC3", ROMX[$6CC3], BANK[$2D]
ResidualROM2D_6CC3::
	db $2F
ASSERT @ == $6CC4
