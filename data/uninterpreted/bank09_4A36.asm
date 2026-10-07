; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $4A36-$4AC8.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:4A36-4AC8", ROMX[$4A36], BANK[$09]
ResidualROM09_4A36::
	db $3E, $61, $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $CD, $DF, $50, $CD, $E5, $51
	db $CD, $54, $4D, $CD, $65, $4E, $21, $03, $72, $CD, $FE, $4D, $21, $EE, $78, $CD
	db $88, $51, $21, $CC, $C5, $34, $FA, $3A, $C7, $A7, $28, $03, $34, $34, $34, $C9
	db $3E, $63, $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $CD, $54, $4D, $CD, $65, $4E
	db $21, $EF, $6D, $CD, $FE, $4D, $21, $CC, $C5, $34, $FA, $3A, $C7, $A7, $28, $03
	db $34, $34, $34, $C9, $3E, $65, $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $CD, $54
	db $4D, $CD, $65, $4E, $21, $DC, $6D, $CD, $FE, $4D, $21, $CC, $C5, $34, $FA, $3A
	db $C7, $A7, $28, $03, $34, $34, $34, $C9, $3E, $66, $EA, $1C, $C2, $3E, $00, $EA
	db $1D, $C2, $CD, $54, $4D, $CD, $65, $4E, $21, $84, $6A, $CD, $FE, $4D, $21, $CC
	db $C5, $34, $C9
ASSERT @ == $4AC9
