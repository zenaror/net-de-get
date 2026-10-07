; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $6612-$662D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:6612-662D", ROMX[$6612], BANK[$10]
ResidualROM10_6612::
	db $00, $70, $00, $70, $00, $70, $00, $70, $00, $70, $00, $70, $00, $70, $00, $70
	db $00, $70, $00, $70, $00, $70, $00, $70, $00, $70, $00, $70
ASSERT @ == $662E
