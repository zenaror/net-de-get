; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $655D-$6627.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:655D-6627", ROMX[$655D], BANK[$07]
ResidualROM07_655D::
	db $FA, $6A, $C7, $3C, $FE, $04, $20, $02, $3E, $00, $7F, $EA, $6A, $C7, $CD, $8B
	db $46, $FA, $6A, $C7, $CD, $BF, $43, $06, $94, $FE, $01, $20, $04, $06, $96, $18
	db $16, $FE, $02, $20, $04, $06, $98, $18, $0E, $FE, $03, $20, $0A, $06, $92, $FA
	db $65, $C7, $B7, $28, $02, $06, $96, $78, $EA, $75, $C7, $3C, $EA, $76, $C7, $CD
	db $28, $46, $C9, $3E, $46, $EA, $C2, $C1, $FA, $65, $C7, $E6, $01, $3C, $0E, $00
	db $11, $68, $52, $CD, $E3, $01, $06, $00, $0E, $00, $21, $4E, $C7, $CD, $EF, $01
	db $3E, $00, $EA, $C2, $C1, $CD, $96, $44, $FE, $00, $CA, $27, $46, $21, $82, $98
	db $78, $F5, $85, $6F, $3E, $00, $8C, $67, $FA, $6E, $C7, $85, $6F, $3E, $00, $8C
	db $67, $54, $5D, $21, $5C, $4F, $01, $01, $01, $CD, $A4, $01, $F1, $F5, $7F, $EA
	db $70, $C7, $3E, $01, $EA, $71, $C7, $CD, $4C, $47, $FA, $6F, $C7, $47, $F1, $3C
	db $B8, $30, $27, $F5, $21, $82, $98, $85, $6F, $3E, $00, $8C, $67, $FA, $6E, $C7
	db $85, $6F, $3E, $00, $8C, $67, $54, $5D, $21, $5E, $4F, $01, $01, $01, $CD, $A4
	db $01, $FA, $6F, $C7, $47, $F1, $3C, $B8, $38, $D9, $C9
ASSERT @ == $6628
