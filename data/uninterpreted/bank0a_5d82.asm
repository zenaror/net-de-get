; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $5D82-$5FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:5D82-5FFF", ROMX[$5D82], BANK[$0A]
ResidualROM0A_5D82::
	db $73, $73, $73, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	ds $26E, $00
ASSERT @ == $6000
