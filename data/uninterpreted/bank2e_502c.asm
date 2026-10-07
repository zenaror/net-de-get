; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $502C-$502C.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:502C-502C", ROMX[$502C], BANK[$2E]
ResidualROM2E_502C::
	db $2F
ASSERT @ == $502D
