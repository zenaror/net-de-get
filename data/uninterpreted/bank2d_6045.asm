; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $2D, address $6045-$6064.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 2D:6045-6064", ROMX[$6045], BANK[$2D]
ResidualROM2D_6045::
	db $40, $01, $00, $03, $80, $05, $00, $03, $40, $07, $00, $03, $E0, $01, $83, $05
	db $40, $01, $00, $03, $40, $01, $00, $01, $40, $01, $00, $03, $7B, $60, $8B, $60
ASSERT @ == $6065
