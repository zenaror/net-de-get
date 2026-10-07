; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $63BF-$64AD.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:63BF-64AD", ROMX[$63BF], BANK[$07]
ResidualROM07_63BF::
	db $F5, $FA, $65, $C7, $E6, $01, $FE, $01, $20, $07, $F1, $E6, $01, $C6, $02, $18
	db $01, $F1, $FE, $00, $20, $05, $21, $34, $53, $18, $15, $FE, $01, $20, $05, $21
	db $7C, $53, $18, $0C, $FE, $02, $20, $05, $21, $C4, $53, $18, $03, $21, $0C, $54
	db $C9, $21, $4E, $C7, $7D, $C6, $00, $6F, $7C, $CE, $00, $67, $FA, $6C, $C7, $85
	db $6F, $3E, $00, $8C, $67, $E5, $FA, $6A, $C7, $CD, $BF, $43, $FA, $66, $C7, $FE
	db $05, $38, $02, $C6, $01, $FE, $0B, $38, $02, $C6, $01, $85, $6F, $3E, $00, $8C
	db $67, $FA, $67, $C7, $47, $07, $07, $07, $07, $4F, $78, $07, $81, $85, $6F, $3E
	db $00, $8C, $67, $FA, $65, $C7, $B7, $28, $12, $FA, $6A, $C7, $E6, $01, $28, $0B
	db $FA, $67, $C7, $FE, $03, $38, $04, $3E, $10, $18, $01, $7E, $E1, $5F, $FE, $FE
	db $30, $0A, $CD, $96, $44, $FE, $00, $28, $3D, $7B, $18, $2C, $2B, $2B, $7E, $FE
	db $FE, $30, $33, $23, $4E, $06, $00, $CD, $D7, $44, $FE, $01, $28, $0A, $4E, $06
	db $40, $CD, $D7, $44, $FE, $00, $28, $1E, $7E, $23, $77, $2B, $7B, $77, $23, $FA
	db $6D, $C7, $3C, $EA, $6D, $C7, $18, $01, $77, $23, $36, $00, $FA, $6C, $C7, $3C
	db $EA, $6C, $C7, $CD, $A0, $45, $C9, $FA, $6D, $C7, $47, $FA, $6C, $C7, $90, $47
	db $FA, $6F, $C7, $4F, $78, $B9, $38, $04, $3E, $00, $18, $02, $3E, $01, $C9
ASSERT @ == $64AE
