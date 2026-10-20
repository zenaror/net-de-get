; HYPOTHESIS classification: uninterpreted trailing bytes, not asserted data/code.
; Byte preservation is checked; padding-like zero bytes remain unclassified.
; Physical bank $09, address $5FED-$5FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:5FED-5FFF", ROMX[$5FED], BANK[$09]
ResidualROM09_5FED::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00
ASSERT @ == $6000
