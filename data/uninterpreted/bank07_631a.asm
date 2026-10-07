; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $631A-$6389.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:631A-6389", ROMX[$631A], BANK[$07]
ResidualROM07_631A::
	db $F5, $FE, $04, $38, $1E, $FA, $66, $C7, $FE, $05, $30, $07, $3E, $01, $EA, $66
	db $C7, $18, $10, $FE, $0A, $30, $07, $3E, $06, $EA, $66, $C7, $18, $05, $3E, $0B
	db $EA, $66, $C7, $F1, $C9, $FA, $67, $C7, $FE, $04, $38, $43, $FA, $66, $C7, $FE
	db $00, $20, $07, $3E, $0B, $EA, $66, $C7, $18, $35, $FE, $02, $20, $07, $3E, $06
	db $EA, $66, $C7, $18, $2A, $FE, $05, $20, $07, $3E, $01, $EA, $66, $C7, $18, $1F
	db $FE, $07, $20, $07, $3E, $0B, $EA, $66, $C7, $18, $14, $FE, $0A, $20, $07, $3E
	db $06, $EA, $66, $C7, $18, $09, $FE, $0C, $20, $05, $3E, $01, $EA, $66, $C7, $C9
ASSERT @ == $638A
