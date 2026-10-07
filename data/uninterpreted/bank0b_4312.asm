; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0B, address $4312-$4390.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0B:4312-4390", ROMX[$4312], BANK[$0B]
ResidualROM0B_4312::
	db $F0, $70, $E6, $07, $F5, $D5, $E5, $C5, $3E, $20, $CD, $2E, $02, $C1, $48, $06
	db $00, $09, $01, $00, $98, $FA, $3A, $C6, $CB, $7F, $28, $03, $01, $00, $9C, $09
	db $FA, $3A, $C6, $E6, $07, $7F, $E0, $70, $3E, $00, $E0, $4F, $D1, $7A, $EA, $3B
	db $C6, $7B, $EA, $3C, $C6, $7A, $47, $7B, $4F, $D1, $E5, $F0, $41, $E6, $02, $20
	db $FA, $7E, $12, $F0, $41, $E6, $02, $20, $F2, $23, $13, $05, $20, $ED, $E1, $D5
	db $11, $20, $00, $19, $D1, $FA, $3B, $C6, $47, $0D, $20, $DE, $21, $00, $98, $FA
	db $3A, $C6, $CB, $7F, $28, $03, $21, $00, $9C, $FA, $3B, $C6, $47, $FA, $3C, $C6
	db $4F, $F0, $4F, $EE, $01, $E0, $4F, $E6, $01, $20, $BF, $F1, $E0, $70, $C9
ASSERT @ == $4391
