; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $57B0-$57B3.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:57B0-57B3", ROMX[$57B0], BANK[$2E]
ResidualROM2E_57B0::
	db $FE, $00, $FF, $2F
ASSERT @ == $57B4
