; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $6000-$609B.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:6000-609B", ROMX[$6000], BANK[$07]
ResidualROM07_6000::
	db $CD, $9C, $40, $CD, $5C, $41, $3E, $81, $CD, $4C, $02, $3E, $01, $CD, $D4, $01
	db $21, $60, $4F, $FA, $65, $C7, $B7, $28, $0E, $21, $E0, $50, $FA, $4E, $C7, $B7
	db $20, $05, $3E, $03, $EA, $65, $C7, $3E, $0F, $EA, $1C, $C2, $3E, $00, $EA, $1D
	db $C2, $CD, $E0, $01, $3E, $00, $0E, $00, $11, $68, $52, $CD, $E6, $01, $FA, $65
	db $C7, $E6, $01, $3C, $0E, $00, $11, $68, $52, $CD, $E6, $01, $FA, $65, $C7, $E6
	db $01, $B7, $28, $0B, $3E, $02, $3C, $0E, $00, $11, $68, $52, $CD, $E6, $01, $3E
	db $00, $CD, $8B, $46, $CD, $A0, $45, $CD, $28, $46, $FA, $73, $C7, $6F, $FA, $74
	db $C7, $67, $3E, $04, $CD, $77, $01, $CD, $79, $02, $CD, $EC, $01, $CD, $61, $02
	db $CD, $7D, $01, $CD, $C5, $41, $FA, $72, $C7, $FE, $00, $20, $0A, $CD, $61, $02
	db $CD, $41, $41, $FA, $64, $C7, $C9, $CD, $D5, $47, $18, $DB
ASSERT @ == $609C
