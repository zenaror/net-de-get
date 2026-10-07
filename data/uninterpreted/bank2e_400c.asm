; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2E, address $400C-$4023.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2E:400C-4023", ROMX[$400C], BANK[$2E]
ResidualROM2E_400C::
	db $00, $00, $00, $00, $E0, $07, $00, $00, $01, $00, $83, $05, $00, $00, $01, $7F
	db $80, $03, $67, $00, $07, $00, $E0, $07
ASSERT @ == $4024
