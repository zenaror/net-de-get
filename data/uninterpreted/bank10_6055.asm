; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $6055-$6068.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:6055-6068", ROMX[$6055], BANK[$10]
ResidualROM10_6055::
	db $40, $01, $00, $03, $40, $01, $00, $01, $40, $01, $00, $03, $7B, $60, $8B, $60
	db $9B, $60, $AB, $60
ASSERT @ == $6069
