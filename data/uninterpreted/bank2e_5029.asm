; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $5029-$502C.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:5029-502C", ROMX[$5029], BANK[$2E]
ResidualROM2E_5029::
	db $FE, $00, $FF, $2F
ASSERT @ == $502D
