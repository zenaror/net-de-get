; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0F, address $40B8-$42B0.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0F:40B8-42B0", ROMX[$40B8], BANK[$0F]
ResidualROM0F_40B8::
	db $3E, $FF, $EA, $88, $CF, $C9, $3E, $11, $5F, $FA, $89, $CF, $E6, $EE, $B3, $EA
	db $89, $CF, $C9, $3E, $22, $5F, $FA, $89, $CF, $E6, $DD, $B3, $EA, $89, $CF, $C9
	db $3E, $44, $5F, $FA, $89, $CF, $E6, $BB, $B3, $EA, $89, $CF, $C9, $3E, $88, $5F
	db $FA, $89, $CF, $E6, $77, $B3, $EA, $89, $CF, $C9, $CD, $6E, $40, $CD, $B8, $40
	db $AF, $EA, $80, $CF, $21, $A0, $CF, $11, $00, $CF, $06, $40, $2A, $12, $13, $05
	db $20, $FA, $CD, $2D, $52, $C9, $FA, $80, $CF, $CB, $7F, $C8, $FE, $FF, $CA, $F2
	db $40, $E6, $7F, $47, $AF, $EA, $80, $CF, $C5, $CD, $0C, $40, $CD, $6E, $40, $CD
	db $82, $40, $CD, $B8, $40, $C1, $04, $11, $90, $CF, $1A, $6F, $13, $1A, $67, $2A
	db $5F, $2A, $57, $05, $20, $F9, $62, $6B, $2A, $47, $C5, $23, $2A, $57, $2A, $5F
	db $E5, $2B, $2B, $2B, $2B, $19, $44, $4D, $21, $00, $CF, $0A, $03, $71, $23, $70
	db $3C, $EA, $04, $CF, $E1, $C1, $05, $28, $66, $C5, $2A, $57, $2A, $5F, $E5, $2B
	db $2B, $2B, $2B, $2B, $2B, $19, $44, $4D, $21, $10, $CF, $0A, $03, $71, $23, $70
	db $3C, $EA, $14, $CF, $E1, $C1, $05, $28, $46, $C5, $2A, $57, $2A, $5F, $E5, $2B
	db $2B, $2B, $2B, $2B, $2B, $2B, $2B, $19, $44, $4D, $21, $20, $CF, $0A, $03, $71
	db $23, $70, $3C, $EA, $24, $CF, $E1, $C1, $05, $28, $24, $C5, $2A, $57, $2A, $5F
	db $E5, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $19, $44, $4D, $21, $30
	db $CF, $0A, $03, $71, $23, $70, $3C, $EA, $34, $CF, $E1, $C1, $05, $28, $00, $C9
	db $FA, $82, $CF, $CB, $7F, $C8, $E6, $7F, $47, $AF, $EA, $82, $CF, $04, $11, $92
	db $CF, $1A, $6F, $13, $1A, $67, $2A, $5F, $2A, $57, $05, $20, $F9, $62, $6B, $01
	db $05, $00, $09, $1A, $13, $FE, $01, $CA, $05, $42, $FE, $02, $CA, $30, $42, $FE
	db $03, $CA, $59, $42, $FE, $04, $CA, $80, $42, $FE, $00, $C8, $C9, $AF, $E0, $10
	db $E0, $12, $3E, $80, $E0, $14, $E5, $21, $40, $CF, $CD, $A9, $42, $E1, $2A, $4F
	db $2A, $47, $E5, $21, $40, $CF, $0A, $03, $71, $23, $70, $3C, $EA, $44, $CF, $E1
	db $D5, $CD, $BE, $40, $D1, $C3, $EB, $41, $AF, $E0, $17, $3E, $80, $E0, $19, $E5
	db $21, $50, $CF, $CD, $A9, $42, $E1, $2A, $4F, $2A, $47, $E5, $21, $50, $CF, $0A
	db $03, $71, $23, $70, $3C, $EA, $54, $CF, $E1, $D5, $CD, $CB, $40, $D1, $C3, $EB
	db $41, $AF, $E0, $1A, $E0, $1C, $E5, $21, $60, $CF, $CD, $A9, $42, $E1, $2A, $4F
	db $2A, $47, $E5, $21, $60, $CF, $0A, $03, $71, $23, $70, $3C, $EA, $64, $CF, $E1
	db $D5, $CD, $D8, $40, $D1, $C3, $EB, $41, $AF, $E0, $21, $3E, $80, $E0, $23, $E5
	db $21, $70, $CF, $CD, $A9, $42, $E1, $2A, $4F, $2A, $47, $E5, $21, $70, $CF, $0A
	db $03, $71, $23, $70, $3C, $EA, $74, $CF, $E1, $D5, $CD, $E5, $40, $D1, $C3, $EB
	db $41, $06, $10, $AF, $22, $05, $20, $FC, $C9
ASSERT @ == $42B1
