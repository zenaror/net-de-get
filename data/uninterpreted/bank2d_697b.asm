; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $697B-$697E.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:697B-697E", ROMX[$697B], BANK[$2D]
ResidualROM2D_697B::
	db $FE, $00, $FF, $2F
ASSERT @ == $697F
