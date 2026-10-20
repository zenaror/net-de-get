; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $44D2-$459E.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:44D2-459E", ROMX[$44D2], BANK[$09]
ResidualROM09_44D2::
	db $3E, $65
	db $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $FA, $A4, $C5, $21, $F2, $44, $87, $5F
	db $16, $00, $19, $5E, $23, $56, $21, $F1, $44, $E5, $6B, $62
	db $E9, $C9, $00, $45, $01, $45, $0E, $45, $18, $45, $3A, $45, $44, $45, $4E, $45
	db $C9, $21, $93, $68, $CD, $93, $50, $21, $AE, $68, $CD, $93, $50, $C9, $CD, $01
	db $45, $21, $C7, $68, $CD, $93, $50, $C9, $CD, $0E, $45, $21, $22, $69, $CD, $93
	db $50, $21, $4D, $69, $CD, $93, $50, $21, $5C, $69, $CD, $93, $50, $21, $81, $69
	db $CD, $93, $50, $21, $B0, $69, $CD, $93, $50, $C9, $CD, $18, $45, $21, $C3, $69
	db $CD, $93, $50, $C9, $CD, $3A, $45, $21, $6A, $6A, $CD, $93, $50, $C9, $CD, $44
	db $45, $21, $99, $6A, $CD, $93, $50, $21, $BF, $6A, $CD, $93, $50, $C9, $3E, $66
	db $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $21, $41, $69, $CD, $93, $50, $FA, $06
	db $C7, $21, $84, $45, $87, $5F, $16, $00, $19, $5E, $23, $56, $21, $83, $45, $E5
	db $6B, $62, $E9, $C9, $8A, $45, $91, $45, $98, $45, $21, $68, $69, $CD, $93, $50
	db $C9, $21, $AF, $69, $CD, $93, $50, $C9, $21, $F6, $69, $CD, $93, $50, $C9
ASSERT @ == $459F
