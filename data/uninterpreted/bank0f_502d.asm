; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0F, address $502D-$5FFF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0F:502D-5FFF", ROMX[$502D], BANK[$0F]
ResidualROM0F_502D::
	db $FA, $70, $CF, $4F, $FA, $71, $CF, $47, $0A, $03, $FE, $90, $DA, $77, $51, $FE
	db $A0, $DA, $FB, $50, $FE, $B1, $CA, $D5, $50, $FE, $E0, $CA, $6F, $50, $FE, $E1
	db $CA, $95, $50, $FE, $C0, $CA, $F3, $50, $FE, $FD, $CA, $AD, $50, $FE, $FE, $CA
	db $BD, $50, $21, $70, $CF, $FE, $FF, $C0, $CD, $C7, $51, $CD, $56, $52, $CD, $5E
	db $52, $C9, $0A, $03, $EA, $7E, $CF, $5F, $FA, $72, $CF, $CB, $3F, $CB, $3F, $CB
	db $3F, $CB, $3F, $83, $CB, $27, $CB, $27, $CB, $27, $CB, $27, $5F, $FA, $72, $CF
	db $E6, $07, $B3, $E0, $22, $C3, $50, $51, $0A, $03, $EA, $7F, $CF, $5F, $FA, $72
	db $CF, $E6, $07, $83, $5F, $FA, $72, $CF, $E6, $F0, $B3, $E0, $22, $C3, $50, $51
	db $0A, $03, $EA, $7C, $CF, $78, $EA, $7B, $CF, $79, $EA, $7A, $CF, $C3, $50, $51
	db $FA, $7C, $CF, $B7, $28, $07, $3D, $CA, $50, $51, $EA, $7C, $CF, $FA, $7B, $CF
	db $47, $FA, $7A, $CF, $4F, $C3, $50, $51, $0A, $03, $21, $89, $CF, $FE, $40, $38
	db $08, $28, $0C, $CB, $DE, $CB, $BE, $18, $0A, $CB, $9E, $CB, $FE, $18, $04, $CB
	db $DE, $CB, $FE, $C3, $50, $51, $0A, $03, $EA, $77, $CF, $C3, $50, $51, $E6, $0F
	db $CB, $37, $EA, $76, $CF, $21, $08, $4B, $0A, $5F, $16, $00, $19, $7E, $EA, $72
	db $CF, $FA, $7E, $CF, $5F, $FA, $72, $CF, $CB, $3F, $CB, $3F, $CB, $3F, $CB, $3F
	db $83, $CB, $27, $CB, $27, $CB, $27, $CB, $27, $5F, $FA, $72, $CF, $E6, $07, $B3
	db $EA, $72, $CF, $FA, $7F, $CF, $5F, $FA, $72, $CF, $E6, $07, $83, $5F, $FA, $72
	db $CF, $E6, $F0, $B3, $E0, $22, $FA, $76, $CF, $E0, $21, $AF, $E0, $20, $3E, $80
	db $E0, $23, $03, $0A, $03, $B7, $CA, $35, $50, $CB, $7F, $28, $11, $E6, $7F, $57
	db $0A, $03, $5F, $CB, $3A, $30, $02, $CB, $FB, $7A, $EA, $75, $CF, $7B, $EA, $74
	db $CF, $79, $EA, $70, $CF, $78, $EA, $71, $CF, $C9, $FA, $7E, $CF, $5F, $FA, $72
	db $CF, $CB, $3F, $CB, $3F, $CB, $3F, $CB, $3F, $83, $CB, $27, $CB, $27, $CB, $27
	db $CB, $27, $5F, $FA, $72, $CF, $E6, $07, $B3, $EA, $72, $CF, $FA, $7F, $CF, $5F
	db $FA, $72, $CF, $E6, $07, $83, $5F, $FA, $72, $CF, $E6, $F0, $B3, $E0, $22, $FA
	db $77, $CF, $B7, $20, $05, $3E, $08, $EA, $76, $CF, $5F, $FA, $76, $CF, $B3, $E0
	db $21, $FA, $73, $CF, $F6, $80, $E0, $23, $18, $89, $06, $10, $3E, $00, $22, $05
	db $20, $FC, $C9, $AF, $E0, $10, $E0, $12, $3E, $80, $E0, $14, $FA, $0E, $CF, $5F
	db $FA, $0F, $CF, $57, $FA, $02, $CF, $6F, $FA, $03, $CF, $67, $19, $FA, $07, $CF
	db $E0, $10, $7D, $E0, $13, $FA, $08, $CF, $E0, $11, $FA, $06, $CF, $E0, $12, $7C
	db $E6, $07, $E0, $14, $C9, $AF, $E0, $17, $3E, $80, $E0, $19, $FA, $1E, $CF, $5F
	db $FA, $1F, $CF, $57, $FA, $12, $CF, $6F, $FA, $13, $CF, $67, $19, $7C, $E0, $18
	db $FA, $17, $CF, $E0, $16, $FA, $16, $CF, $E0, $17, $7D, $E6, $07, $E0, $19, $C9
	db $AF, $E0, $1A, $E0, $1C, $E0, $1E, $FA, $27, $CF, $F5, $11, $98, $CF, $1A, $6F
	db $13, $1A, $67, $F1, $5F, $16, $00, $19, $19, $2A, $5F, $7E, $57, $21, $30, $FF
	db $06, $10, $1A, $22, $13, $05, $20, $FA, $C9, $AF, $E0, $21, $3E, $80, $E0, $23
	db $C9, $AF, $E6, $88, $5F, $FA, $89, $CF, $E6, $77, $B3, $EA, $89, $CF, $C9, $AF
	db $E6, $44, $5F, $FA, $89, $CF, $E6, $BB, $B3, $EA, $89, $CF, $C9, $AF, $E6, $22
	db $5F, $FA, $89, $CF, $E6, $DD, $B3, $EA, $89, $CF, $C9, $AF, $E6, $11, $5F, $FA
	db $89, $CF, $E6, $EE, $B3, $EA, $89, $CF, $C9, $00, $00, $00, $00, $00, $00, $00
	ds $D63, $00
ASSERT @ == $6000
