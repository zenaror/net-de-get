; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $4612-$462D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:4612-462D", ROMX[$4612], BANK[$2E]
ResidualROM2E_4612::
	db $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E
	db $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E, $3E, $7E
ASSERT @ == $462E
