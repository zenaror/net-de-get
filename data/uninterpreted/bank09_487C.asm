; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $487C-$493F.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:487C-493F", ROMX[$487C], BANK[$09]
ResidualROM09_487C::
	db $3E, $01, $CD, $B8, $4C, $3E, $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $21
	db $66, $68, $CD, $93, $50, $3E, $07, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01
	db $CD, $B8, $4C, $3E, $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $21, $CB, $68
	db $CD, $93, $50, $3E, $05, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8
	db $4C, $3E, $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $21, $66, $68, $CD, $93
	db $50, $3E, $08, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8, $4C, $3E
	db $00, $EA, $13, $C2, $3E, $02, $EA, $00, $C6, $FA, $A4, $C5, $FE, $06, $D2, $F5
	db $48, $21, $9D, $68, $CD, $93, $50, $18, $06, $21, $B4, $68, $CD, $93, $50, $3E
	db $03, $EA, $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8, $4C, $3E, $00, $EA
	db $13, $C2, $3E, $02, $EA, $00, $C6, $21, $7F, $6A, $CD, $93, $50, $3E, $04, $EA
	db $CF, $C5, $CD, $FD, $4C, $C9, $3E, $01, $CD, $B8, $4C, $3E, $00, $EA, $13, $C2
	db $3E, $02, $EA, $00, $C6, $21, $51, $6A, $CD, $93, $50, $3E, $06, $EA, $CF, $C5
	db $CD, $FD, $4C, $C9
ASSERT @ == $4940
