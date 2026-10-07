; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $668B-$674B.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:668B-674B", ROMX[$668B], BANK[$07]
ResidualROM07_668B::
	db $F5, $3E, $00, $0E, $00, $11, $68, $52, $CD, $E3, $01, $F1, $F5, $06, $00, $FE
	db $02, $30, $06, $06, $30, $0E, $70, $18, $04, $06, $10, $0E, $50, $3E, $01, $EA
	db $71, $C7, $C5, $78, $EA, $70, $C7, $CD, $4C, $47, $C1, $79, $EA, $70, $C7, $CD
	db $4C, $47, $FA, $65, $C7, $B7, $28, $1C, $0E, $00, $06, $00, $CD, $19, $02, $01
	db $E0, $99, $09, $E5, $AF, $E0, $4F, $21, $0C, $4F, $D1, $06, $14, $0E, $01, $CD
	db $A4, $01, $18, $1A, $0E, $00, $06, $00, $CD, $19, $02, $01, $E0, $99, $09, $E5
	db $AF, $E0, $4F, $21, $34, $4F, $D1, $06, $14, $0E, $01, $CD, $A4, $01, $F1, $CD
	db $BF, $43, $0E, $00, $16, $00, $3E, $00, $EA, $C2, $C1, $06, $00, $D5, $C5, $FA
	db $65, $C7, $B7, $28, $14, $FA, $6A, $C7, $E6, $01, $28, $0D, $7A, $FE, $03, $38
	db $08, $21, $54, $54, $CD, $EF, $01, $18, $03, $CD, $EF, $01, $C1, $78, $C6, $06
	db $47, $FE, $12, $30, $09, $FA, $C2, $C1, $3C, $EA, $C2, $C1, $18, $D0, $79, $C6
	db $02, $4F, $D1, $14, $7A, $FE, $04, $30, $02, $18, $C0, $3E, $00, $EA, $C2, $C1
	db $C9
ASSERT @ == $674C
