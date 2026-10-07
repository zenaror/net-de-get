; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $600C-$6023.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:600C-6023", ROMX[$600C], BANK[$2D]
ResidualROM2D_600C::
	db $00, $00, $00, $00, $E0, $07, $00, $00, $01, $00, $83, $05, $00, $00, $01, $7F
	db $80, $03, $67, $00, $07, $00, $E0, $07
ASSERT @ == $6024
