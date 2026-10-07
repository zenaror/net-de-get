; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $697E-$697E.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:697E-697E", ROMX[$697E], BANK[$2D]
ResidualROM2D_697E::
	db $2F
ASSERT @ == $697F
