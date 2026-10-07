; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0F, address $4003-$42B0.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0F:4003-42B0", ROMX[$4003], BANK[$0F]
ResidualROM0F_4003::
	db $C3, $0E, $41, $C3, $C8, $41, $C3, $1B, $40, $21, $00, $CF, $11, $A0, $CF, $06
	db $40, $2A, $12, $13, $05, $20, $FA, $C9, $21, $00, $50, $2A, $EA, $92, $CF, $2A
	db $EA, $93, $CF, $2A, $EA, $90, $CF, $2A, $EA, $91, $CF, $2A, $EA, $94, $CF, $2A
	db $EA, $95, $CF, $2A, $EA, $96, $CF, $2A, $EA, $97, $CF, $2A, $EA, $98, $CF, $2A
	db $EA, $99, $CF, $2A, $EA, $9A, $CF, $2A, $EA, $9B, $CF, $3E, $FF, $EA, $84, $CF
	db $EA, $88, $CF, $AF, $EA, $89, $CF, $C9, $1A, $6F, $13, $1A, $67, $13, $C9, $21
	db $00, $CF, $06, $80, $3E, $00, $22, $05, $20, $FC, $C9, $21, $00, $CF, $06, $40
	db $AF, $22, $05, $20, $FC, $EA, $86, $CF, $EA, $87, $CF, $EA, $8A, $CF, $C9, $FA
	db $41, $CF, $B7, $20, $0A, $AF, $E0, $10, $AF, $E0, $12, $3E, $80, $E0, $14, $FA
	db $51, $CF, $B7, $20, $07, $AF, $E0, $17, $3E, $80, $E0, $19, $FA, $61, $CF, $B7
	db $20, $05, $AF, $E0, $1A, $E0, $1C, $FA, $71, $CF, $B7, $20, $07, $AF, $E0, $21
	db $3E, $80, $E0, $23, $C9, $3E, $FF, $EA, $88, $CF, $C9, $3E, $11, $5F, $FA, $89
	db $CF, $E6, $EE, $B3, $EA, $89, $CF, $C9, $3E, $22, $5F, $FA, $89, $CF, $E6, $DD
	db $B3, $EA, $89, $CF, $C9, $3E, $44, $5F, $FA, $89, $CF, $E6, $BB, $B3, $EA, $89
	db $CF, $C9, $3E, $88, $5F, $FA, $89, $CF, $E6, $77, $B3, $EA, $89, $CF, $C9, $CD
	db $6E, $40, $CD, $B8, $40, $AF, $EA, $80, $CF, $21, $A0, $CF, $11, $00, $CF, $06
	db $40, $2A, $12, $13, $05, $20, $FA, $CD, $2D, $52, $C9, $FA, $80, $CF, $CB, $7F
	db $C8, $FE, $FF, $CA, $F2, $40, $E6, $7F, $47, $AF, $EA, $80, $CF, $C5, $CD, $0C
	db $40, $CD, $6E, $40, $CD, $82, $40, $CD, $B8, $40, $C1, $04, $11, $90, $CF, $1A
	db $6F, $13, $1A, $67, $2A, $5F, $2A, $57, $05, $20, $F9, $62, $6B, $2A, $47, $C5
	db $23, $2A, $57, $2A, $5F, $E5, $2B, $2B, $2B, $2B, $19, $44, $4D, $21, $00, $CF
	db $0A, $03, $71, $23, $70, $3C, $EA, $04, $CF, $E1, $C1, $05, $28, $66, $C5, $2A
	db $57, $2A, $5F, $E5, $2B, $2B, $2B, $2B, $2B, $2B, $19, $44, $4D, $21, $10, $CF
	db $0A, $03, $71, $23, $70, $3C, $EA, $14, $CF, $E1, $C1, $05, $28, $46, $C5, $2A
	db $57, $2A, $5F, $E5, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $19, $44, $4D, $21
	db $20, $CF, $0A, $03, $71, $23, $70, $3C, $EA, $24, $CF, $E1, $C1, $05, $28, $24
	db $C5, $2A, $57, $2A, $5F, $E5, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B
	db $19, $44, $4D, $21, $30, $CF, $0A, $03, $71, $23, $70, $3C, $EA, $34, $CF, $E1
	db $C1, $05, $28, $00, $C9, $FA, $82, $CF, $CB, $7F, $C8, $E6, $7F, $47, $AF, $EA
	db $82, $CF, $04, $11, $92, $CF, $1A, $6F, $13, $1A, $67, $2A, $5F, $2A, $57, $05
	db $20, $F9, $62, $6B, $01, $05, $00, $09, $1A, $13, $FE, $01, $CA, $05, $42, $FE
	db $02, $CA, $30, $42, $FE, $03, $CA, $59, $42, $FE, $04, $CA, $80, $42, $FE, $00
	db $C8, $C9, $AF, $E0, $10, $E0, $12, $3E, $80, $E0, $14, $E5, $21, $40, $CF, $CD
	db $A9, $42, $E1, $2A, $4F, $2A, $47, $E5, $21, $40, $CF, $0A, $03, $71, $23, $70
	db $3C, $EA, $44, $CF, $E1, $D5, $CD, $BE, $40, $D1, $C3, $EB, $41, $AF, $E0, $17
	db $3E, $80, $E0, $19, $E5, $21, $50, $CF, $CD, $A9, $42, $E1, $2A, $4F, $2A, $47
	db $E5, $21, $50, $CF, $0A, $03, $71, $23, $70, $3C, $EA, $54, $CF, $E1, $D5, $CD
	db $CB, $40, $D1, $C3, $EB, $41, $AF, $E0, $1A, $E0, $1C, $E5, $21, $60, $CF, $CD
	db $A9, $42, $E1, $2A, $4F, $2A, $47, $E5, $21, $60, $CF, $0A, $03, $71, $23, $70
	db $3C, $EA, $64, $CF, $E1, $D5, $CD, $D8, $40, $D1, $C3, $EB, $41, $AF, $E0, $21
	db $3E, $80, $E0, $23, $E5, $21, $70, $CF, $CD, $A9, $42, $E1, $2A, $4F, $2A, $47
	db $E5, $21, $70, $CF, $0A, $03, $71, $23, $70, $3C, $EA, $74, $CF, $E1, $D5, $CD
	db $E5, $40, $D1, $C3, $EB, $41, $06, $10, $AF, $22, $05, $20, $FC, $C9
ASSERT @ == $42B1
