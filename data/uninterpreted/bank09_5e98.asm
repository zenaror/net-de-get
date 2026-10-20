; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $5E98-$5F42.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:5E98-5F42", ROMX[$5E98], BANK[$09]
ResidualROM09_5E98::
	db $3E, $00, $E0, $4F, $11, $00, $9C, $01, $00, $04, $CD, $5C, $5D, $3E, $01, $E0
	db $4F, $11, $00, $9C, $01, $00, $04, $CD, $5C, $5D, $3E, $00, $E0, $4F, $C9, $3E
	db $01, $E0, $4F, $11, $00, $98, $0E, $9C, $CD, $C8, $5E, $3E, $00, $E0, $4F, $C9
	db $7E, $E6, $80, $28, $1A, $2A, $E6, $7F, $47, $F3, $F0, $41, $E6, $02, $20, $FA
	db $7E, $12, $FB, $F0, $41, $E6, $02, $20, $F0, $13, $05, $20, $EC, $18, $11, $F3
	db $F0, $41, $E6, $02, $20, $FA, $7E, $12, $FB, $F0, $41, $E6, $02, $20, $F0, $13
	db $23, $7A, $B9, $20, $CB, $C9, $7E, $F5, $23, $7E, $47, $F1, $F5, $B8, $20, $19
	db $23, $2A, $47, $F3, $F0, $41, $E6, $02, $20, $FA, $7E, $12, $FB, $F0, $41, $E6
	db $02, $20, $F0, $13, $05, $20, $EC, $18, $11, $F3, $F0, $41, $E6, $02, $20, $FA
	db $7E, $12, $FB, $F0, $41, $E6, $02, $20, $F0, $13, $23, $7A, $B9, $20, $CA, $F1
	db $C9, $11, $00, $80, $01, $00, $18, $CD, $5C, $5D, $C9
ASSERT @ == $5F43
