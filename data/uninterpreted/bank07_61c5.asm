; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $61C5-$6305.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:61C5-6305", ROMX[$61C5], BANK[$07]
ResidualROM07_61C5::
	db $FA, $B8, $C1, $B7, $C0, $FA, $72, $C7, $FE, $00, $28, $1F, $FE, $63, $20, $15
	db $FA, $20, $C2, $B7, $20, $15, $FA, $20, $C2, $B7, $28, $02, $18, $0D, $3E, $00
	db $EA, $72, $C7, $18, $06, $CD, $F1, $41, $CD, $8A, $43, $C9, $F0, $98, $E6, $10
	db $28, $15, $3E, $83, $CD, $4F, $02, $FA, $66, $C7, $3C, $FE, $0F, $38, $02, $3E
	db $00, $EA, $66, $C7, $CD, $3F, $43, $F0, $98, $E6, $20, $28, $16, $3E, $83, $CD
	db $4F, $02, $FA, $66, $C7, $3D, $FE, $FF, $C2, $22, $42, $3E, $0E, $EA, $66, $C7
	db $CD, $3F, $43, $F0, $98, $E6, $80, $28, $18, $3E, $82, $CD, $4F, $02, $FA, $67
	db $C7, $3C, $CD, $1A, $43, $FE, $05, $38, $02, $3E, $00, $EA, $67, $C7, $CD, $06
	db $43, $F0, $98, $E6, $40, $28, $18, $3E, $82, $CD, $4F, $02, $FA, $67, $C7, $3D
	db $FE, $FF, $20, $05, $3E, $04, $CD, $1A, $43, $EA, $67, $C7, $CD, $06, $43, $F0
	db $97, $E6, $02, $28, $0B, $3E, $85, $CD, $4F, $02, $CD, $1F, $45, $C3, $05, $43
	db $F0, $97, $E6, $01, $CA, $DD, $42, $FA, $67, $C7, $FE, $04, $DA, $D3, $42, $FA
	db $66, $C7, $FE, $01, $20, $0A, $3E, $84, $CD, $4F, $02, $CD, $5D, $45, $18, $70
	db $FE, $06, $38, $6C, $E6, $08, $0F, $0F, $0F, $EA, $64, $C7, $EE, $01, $C6, $84
	db $CD, $4F, $02, $FA, $64, $C7, $B7, $28, $18, $21, $4E, $C7, $7E, $B7, $28, $0A
	db $2B, $23, $7E, $FE, $10, $28, $FA, $B7, $20, $07, $3E, $85, $CD, $4F, $02, $18
	db $3F, $CD, $55, $02, $3E, $63, $EA, $72, $C7, $CD, $AA, $47, $18, $32, $3E, $84
	db $CD, $4F, $02, $CD, $F0, $43, $18, $28, $F0, $97, $E6, $08, $28, $14, $3E, $84
	db $CD, $4F, $02, $3E, $0B, $EA, $66, $C7, $3E, $04, $EA, $67, $C7, $CD, $06, $43
	db $18, $0E, $F0, $97, $E6, $04, $28, $08, $3E, $84, $CD, $4F, $02, $CD, $5D, $45
	db $C9
ASSERT @ == $6306
