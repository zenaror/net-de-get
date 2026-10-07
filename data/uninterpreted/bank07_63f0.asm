; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $63F0-$6495.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:63F0-6495", ROMX[$63F0], BANK[$07]
ResidualROM07_63F0::
	db $21, $4E, $C7, $7D, $C6, $00, $6F, $7C, $CE, $00, $67, $FA, $6C, $C7, $85, $6F
	db $3E, $00, $8C, $67, $E5, $FA, $6A, $C7, $CD, $BF, $43, $FA, $66, $C7, $FE, $05
	db $38, $02, $C6, $01, $FE, $0B, $38, $02, $C6, $01, $85, $6F, $3E, $00, $8C, $67
	db $FA, $67, $C7, $47, $07, $07, $07, $07, $4F, $78, $07, $81, $85, $6F, $3E, $00
	db $8C, $67, $FA, $65, $C7, $B7, $28, $12, $FA, $6A, $C7, $E6, $01, $28, $0B, $FA
	db $67, $C7, $FE, $03, $38, $04, $3E, $10, $18, $01, $7E, $E1, $5F, $FE, $FE, $30
	db $0A, $CD, $96, $44, $FE, $00, $28, $3D, $7B, $18, $2C, $2B, $2B, $7E, $FE, $FE
	db $30, $33, $23, $4E, $06, $00, $CD, $D7, $44, $FE, $01, $28, $0A, $4E, $06, $40
	db $CD, $D7, $44, $FE, $00, $28, $1E, $7E, $23, $77, $2B, $7B, $77, $23, $FA, $6D
	db $C7, $3C, $EA, $6D, $C7, $18, $01, $77, $23, $36, $00, $FA, $6C, $C7, $3C, $EA
	db $6C, $C7, $CD, $A0, $45, $C9
ASSERT @ == $6496
