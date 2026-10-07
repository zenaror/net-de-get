; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0F, address $4EAA-$5FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0F:4EAA-5FFF", ROMX[$4EAA], BANK[$0F]
ResidualROM0F_4EAA::
	db $FA, $60, $CF, $4F, $FA, $61, $CF, $47, $0A, $03, $FE, $90, $DA, $26, $50, $FE
	db $A0, $DA, $9F, $4F, $FE, $B0, $CA, $32, $4F, $FE, $B1, $CA, $14, $4F, $FE, $C0
	db $CA, $78, $4F, $FE, $E0, $CA, $3A, $4F, $FE, $FD, $CA, $EC, $4E, $FE, $FE, $CA
	db $FC, $4E, $21, $60, $CF, $FE, $FF, $C0, $CD, $C7, $51, $CD, $2D, $52, $CD, $6C
	db $52, $C9, $0A, $03, $EA, $6C, $CF, $78, $EA, $6B, $CF, $79, $EA, $6A, $CF, $C3
	db $FF, $4F, $FA, $6C, $CF, $B7, $28, $07, $3D, $CA, $FF, $4F, $EA, $6C, $CF, $FA
	db $6B, $CF, $47, $FA, $6A, $CF, $4F, $C3, $FF, $4F, $0A, $03, $21, $89, $CF, $FE
	db $40, $38, $08, $28, $0C, $CB, $D6, $CB, $B6, $18, $0A, $CB, $96, $CB, $F6, $18
	db $04, $CB, $D6, $CB, $F6, $C3, $FF, $4F, $0A, $03, $EA, $6D, $CF, $C3, $FF, $4F
	db $0A, $03, $D6, $40, $38, $0D, $5F, $16, $00, $FA, $6D, $CF, $3D, $28, $15, $CB
	db $3B, $18, $F9, $2F, $5F, $16, $FF, $FA, $6D, $CF, $3D, $28, $04, $CB, $3B, $18
	db $F9, $7B, $2F, $5F, $FA, $62, $CF, $6F, $FA, $63, $CF, $67, $19, $7B, $EA, $6E
	db $CF, $7A, $EA, $6F, $CF, $7D, $E0, $1D, $7C, $E0, $1E, $C3, $FF, $4F, $0A, $E6
	db $1F, $03, $F5, $11, $98, $CF, $1A, $6F, $13, $1A, $67, $F1, $5F, $16, $00, $19
	db $19, $2A, $5F, $7E, $57, $21, $30, $FF, $C5, $06, $10, $1A, $22, $13, $05, $20
	db $FA, $C1, $C3, $FF, $4F, $E6, $0F, $CB, $37, $FE, $C0, $38, $07, $3E, $20, $EA
	db $66, $CF, $18, $10, $FE, $80, $38, $07, $3E, $40, $EA, $66, $CF, $18, $05, $3E
	db $60, $EA, $66, $CF, $0A, $3C, $21, $0E, $4A, $5F, $16, $00, $19, $19, $7E, $EA
	db $62, $CF, $23, $7E, $EA, $63, $CF, $FA, $6E, $CF, $5F, $FA, $6F, $CF, $57, $FA
	db $62, $CF, $6F, $FA, $63, $CF, $67, $19, $AF, $E0, $1A, $7C, $E6, $7F, $E0, $1E
	db $FA, $66, $CF, $E0, $1C, $AF, $E0, $1B, $7D, $E0, $1D, $3E, $80, $E0, $1A, $7C
	db $F6, $80, $E0, $1E, $03, $0A, $03, $B7, $CA, $B2, $4E, $CB, $7F, $28, $11, $E6
	db $7F, $57, $0A, $03, $5F, $CB, $3A, $30, $02, $CB, $FB, $7A, $EA, $65, $CF, $7B
	db $EA, $64, $CF, $79, $EA, $60, $CF, $78, $EA, $61, $CF, $C9, $AF, $E0, $1A, $E0
	db $1C, $18, $D2, $FA, $70, $CF, $4F, $FA, $71, $CF, $47, $0A, $03, $FE, $90, $DA
	db $77, $51, $FE, $A0, $DA, $FB, $50, $FE, $B1, $CA, $D5, $50, $FE, $E0, $CA, $6F
	db $50, $FE, $E1, $CA, $95, $50, $FE, $C0, $CA, $F3, $50, $FE, $FD, $CA, $AD, $50
	db $FE, $FE, $CA, $BD, $50, $21, $70, $CF, $FE, $FF, $C0, $CD, $C7, $51, $CD, $56
	db $52, $CD, $5E, $52, $C9, $0A, $03, $EA, $7E, $CF, $5F, $FA, $72, $CF, $CB, $3F
	db $CB, $3F, $CB, $3F, $CB, $3F, $83, $CB, $27, $CB, $27, $CB, $27, $CB, $27, $5F
	db $FA, $72, $CF, $E6, $07, $B3, $E0, $22, $C3, $50, $51, $0A, $03, $EA, $7F, $CF
	db $5F, $FA, $72, $CF, $E6, $07, $83, $5F, $FA, $72, $CF, $E6, $F0, $B3, $E0, $22
	db $C3, $50, $51, $0A, $03, $EA, $7C, $CF, $78, $EA, $7B, $CF, $79, $EA, $7A, $CF
	db $C3, $50, $51, $FA, $7C, $CF, $B7, $28, $07, $3D, $CA, $50, $51, $EA, $7C, $CF
	db $FA, $7B, $CF, $47, $FA, $7A, $CF, $4F, $C3, $50, $51, $0A, $03, $21, $89, $CF
	db $FE, $40, $38, $08, $28, $0C, $CB, $DE, $CB, $BE, $18, $0A, $CB, $9E, $CB, $FE
	db $18, $04, $CB, $DE, $CB, $FE, $C3, $50, $51, $0A, $03, $EA, $77, $CF, $C3, $50
	db $51, $E6, $0F, $CB, $37, $EA, $76, $CF, $21, $08, $4B, $0A, $5F, $16, $00, $19
	db $7E, $EA, $72, $CF, $FA, $7E, $CF, $5F, $FA, $72, $CF, $CB, $3F, $CB, $3F, $CB
	db $3F, $CB, $3F, $83, $CB, $27, $CB, $27, $CB, $27, $CB, $27, $5F, $FA, $72, $CF
	db $E6, $07, $B3, $EA, $72, $CF, $FA, $7F, $CF, $5F, $FA, $72, $CF, $E6, $07, $83
	db $5F, $FA, $72, $CF, $E6, $F0, $B3, $E0, $22, $FA, $76, $CF, $E0, $21, $AF, $E0
	db $20, $3E, $80, $E0, $23, $03, $0A, $03, $B7, $CA, $35, $50, $CB, $7F, $28, $11
	db $E6, $7F, $57, $0A, $03, $5F, $CB, $3A, $30, $02, $CB, $FB, $7A, $EA, $75, $CF
	db $7B, $EA, $74, $CF, $79, $EA, $70, $CF, $78, $EA, $71, $CF, $C9, $FA, $7E, $CF
	db $5F, $FA, $72, $CF, $CB, $3F, $CB, $3F, $CB, $3F, $CB, $3F, $83, $CB, $27, $CB
	db $27, $CB, $27, $CB, $27, $5F, $FA, $72, $CF, $E6, $07, $B3, $EA, $72, $CF, $FA
	db $7F, $CF, $5F, $FA, $72, $CF, $E6, $07, $83, $5F, $FA, $72, $CF, $E6, $F0, $B3
	db $E0, $22, $FA, $77, $CF, $B7, $20, $05, $3E, $08, $EA, $76, $CF, $5F, $FA, $76
	db $CF, $B3, $E0, $21, $FA, $73, $CF, $F6, $80, $E0, $23, $18, $89, $06, $10, $3E
	db $00, $22, $05, $20, $FC, $C9, $AF, $E0, $10, $E0, $12, $3E, $80, $E0, $14, $FA
	db $0E, $CF, $5F, $FA, $0F, $CF, $57, $FA, $02, $CF, $6F, $FA, $03, $CF, $67, $19
	db $FA, $07, $CF, $E0, $10, $7D, $E0, $13, $FA, $08, $CF, $E0, $11, $FA, $06, $CF
	db $E0, $12, $7C, $E6, $07, $E0, $14, $C9, $AF, $E0, $17, $3E, $80, $E0, $19, $FA
	db $1E, $CF, $5F, $FA, $1F, $CF, $57, $FA, $12, $CF, $6F, $FA, $13, $CF, $67, $19
	db $7C, $E0, $18, $FA, $17, $CF, $E0, $16, $FA, $16, $CF, $E0, $17, $7D, $E6, $07
	db $E0, $19, $C9, $AF, $E0, $1A, $E0, $1C, $E0, $1E, $FA, $27, $CF, $F5, $11, $98
	db $CF, $1A, $6F, $13, $1A, $67, $F1, $5F, $16, $00, $19, $19, $2A, $5F, $7E, $57
	db $21, $30, $FF, $06, $10, $1A, $22, $13, $05, $20, $FA, $C9, $AF, $E0, $21, $3E
	db $80, $E0, $23, $C9, $AF, $E6, $88, $5F, $FA, $89, $CF, $E6, $77, $B3, $EA, $89
	db $CF, $C9, $AF, $E6, $44, $5F, $FA, $89, $CF, $E6, $BB, $B3, $EA, $89, $CF, $C9
	db $AF, $E6, $22, $5F, $FA, $89, $CF, $E6, $DD, $B3, $EA, $89, $CF, $C9, $AF, $E6
	db $11, $5F, $FA, $89, $CF, $E6, $EE, $B3, $EA, $89, $CF, $C9, $00, $00, $00, $00
	ds $D66, $00
ASSERT @ == $6000
