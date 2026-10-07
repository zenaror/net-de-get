; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $4962-$4AC8.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:4962-4AC8", ROMX[$4962], BANK[$09]
ResidualROM09_4962::
	db $3E, $01, $CD, $B8, $4C, $3E, $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $21
	db $00, $68, $CD, $93, $50, $3E, $07, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01
	db $CD, $B8, $4C, $3E, $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $FA, $A4, $C5
	db $FE, $03, $D2, $9F, $49, $21, $55, $68, $CD, $93, $50, $18, $06, $21, $74, $68
	db $CD, $93, $50, $3E, $05, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8
	db $4C, $3E, $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $21, $00, $68, $CD, $93
	db $50, $3E, $08, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8, $4C, $3E
	db $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $FA, $A4, $C5, $FE, $02, $D2, $EB
	db $49, $21, $37, $68, $CD, $93, $50, $18, $06, $21, $46, $68, $CD, $93, $50, $3E
	db $03, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8, $4C, $3E, $00, $EA
	db $13, $C2, $3E, $02, $EA, $00, $C6, $21, $CE, $6A, $CD, $93, $50, $3E, $06, $EA
	db $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8, $4C, $3E, $00, $EA, $13, $C2
	db $3E, $02, $EA, $00, $C6, $21, $A8, $6A, $CD, $93, $50, $3E, $04, $EA, $CF, $C5
	db $CD, $FD, $4C, $C9, $3E, $61, $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $CD, $DF
	db $50, $CD, $E5, $51, $CD, $54, $4D, $CD, $65, $4E, $21, $03, $72, $CD, $FE, $4D
	db $21, $EE, $78, $CD, $88, $51, $21, $CC, $C5, $34, $FA, $3A, $C7, $A7, $28, $03
	db $34, $34, $34, $C9, $3E, $63, $EA, $1C, $C2, $3E, $00, $EA, $1D, $C2, $CD, $54
	db $4D, $CD, $65, $4E, $21, $EF, $6D, $CD, $FE, $4D, $21, $CC, $C5, $34, $FA, $3A
	db $C7, $A7, $28, $03, $34, $34, $34, $C9, $3E, $65, $EA, $1C, $C2, $3E, $00, $EA
	db $1D, $C2, $CD, $54, $4D, $CD, $65, $4E, $21, $DC, $6D, $CD, $FE, $4D, $21, $CC
	db $C5, $34, $FA, $3A, $C7, $A7, $28, $03, $34, $34, $34, $C9, $3E, $66, $EA, $1C
	db $C2, $3E, $00, $EA, $1D, $C2, $CD, $54, $4D, $CD, $65, $4E, $21, $84, $6A, $CD
	db $FE, $4D, $21, $CC, $C5, $34, $C9
ASSERT @ == $4AC9
