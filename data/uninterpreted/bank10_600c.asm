; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $10, address $600C-$6038.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 10:600C-6038", ROMX[$600C], BANK[$10]
ResidualROM10_600C::
	db $00, $00, $00, $00, $E0, $07, $00, $00, $01, $00, $83, $05, $00, $00, $01, $7F
	db $80, $03, $67, $00, $07, $00, $E0, $07, $00, $83, $01, $00, $80, $02, $07, $00
	db $05, $71, $00, $04, $67, $00, $07, $00, $E0, $07, $00, $80, $03
ASSERT @ == $6039
