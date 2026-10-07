; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $655D-$659F.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:655D-659F", ROMX[$655D], BANK[$07]
ResidualROM07_655D::
	db $FA, $6A, $C7, $3C, $FE, $04, $20, $02, $3E, $00, $7F, $EA, $6A, $C7, $CD, $8B
	db $46, $FA, $6A, $C7, $CD, $BF, $43, $06, $94, $FE, $01, $20, $04, $06, $96, $18
	db $16, $FE, $02, $20, $04, $06, $98, $18, $0E, $FE, $03, $20, $0A, $06, $92, $FA
	db $65, $C7, $B7, $28, $02, $06, $96, $78, $EA, $75, $C7, $3C, $EA, $76, $C7, $CD
	db $28, $46, $C9
ASSERT @ == $65A0
