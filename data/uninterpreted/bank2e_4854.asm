; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $4854-$4857.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:4854-4857", ROMX[$4854], BANK[$2E]
ResidualROM2E_4854::
	db $FE, $00, $FF, $2F
ASSERT @ == $4858
