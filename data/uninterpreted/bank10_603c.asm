; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $603C-$6052.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:603C-6052", ROMX[$603C], BANK[$10]
ResidualROM10_603C::
	db $00, $83, $01, $00, $00, $E0, $02, $80, $02, $40, $01, $00, $03, $80, $05, $00
	db $03, $40, $07, $00, $03, $E0, $01
ASSERT @ == $6053
