; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $455E-$459E.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:455E-459E", ROMX[$455E], BANK[$09]
ResidualROM09_455E::
	db $3E, $66
	db $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $21, $41, $69, $CD, $93, $50, $FA, $06
	db $C7, $21, $84, $45, $87, $5F, $16, $00, $19, $5E, $23, $56, $21, $83, $45, $E5
	db $6B, $62, $E9, $C9, $8A, $45, $91, $45, $98, $45, $21, $68, $69, $CD, $93, $50
	db $C9, $21, $AF, $69, $CD, $93, $50, $C9, $21, $F6, $69, $CD, $93, $50, $C9
ASSERT @ == $459F
