; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $1186-$12BE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:1186-12BE", ROM0[$1186]
ResidualROM00_1186::
	db $7D, $EA, $C5, $C1, $7C, $EA, $C6, $C1, $C9, $21, $C4, $C1, $7E, $FE, $10, $D0
	db $34, $D5, $87, $87, $5F, $16, $00, $21, $CA, $C1, $19, $D1, $73, $23, $72, $23
	db $71, $23, $70, $C9, $21, $00, $C0, $01, $A0, $00, $AF, $22, $0B, $79, $B0, $20
	db $F9, $21, $C4, $C1, $7E, $B7, $CA, $B8, $12, $36, $00, $47, $F3, $FA, $C6, $C1
	db $FE, $60, $30, $14, $FA, $1C, $C2, $EA, $FF, $27, $EA, $13, $C1, $FA, $1D, $C2
	db $EA, $00, $28, $EA, $14, $C1, $18, $12, $FA, $1C, $C2, $EA, $FF, $37, $EA, $15
	db $C1, $FA, $1D, $C2, $EA, $00, $38, $EA, $16, $C1, $3E, $28, $EA, $C7, $C1, $21
	db $CA, $C1, $11, $00, $C0, $C5, $E5, $D5, $2A, $EA, $C8, $C1, $2A, $EA, $C9, $C1
	db $2A, $FE, $FF, $20, $2E, $D1, $7E, $F5, $FA, $C7, $C1, $B7, $28, $16, $3D, $EA
	db $C7, $C1, $FA, $C9, $C1, $12, $13, $FA, $C8, $C1, $12, $13, $F1, $12, $13, $FA
	db $B7, $C1, $12, $13, $E1, $C1, $D5, $11, $04, $00, $19, $D1, $05, $C2, $FB, $11
	db $C3, $8E, $12, $E5, $87, $5F, $16, $00, $FA, $C5, $C1, $6F, $FA, $C6, $C1, $67
	db $19, $5E, $23, $56, $E1, $7E, $87, $62, $6B, $5F, $16, $00, $19, $5E, $23, $56
	db $62, $6B, $D1, $2A, $47, $A7, $28, $24, $FA, $C7, $C1, $B7, $28, $1B, $3D, $EA
	db $C7, $C1, $7E, $4F, $23, $FA, $C9, $C1, $81, $12, $13, $4E, $23, $FA, $C8, $C1
	db $81, $12, $13, $2A, $12, $13, $2A, $12, $13, $05, $20, $DC, $E1, $C1, $D5, $11
	db $04, $00, $19, $D1, $05, $C2, $FB, $11, $FA, $C6, $C1, $FE, $60, $30, $12, $F0
	db $AB, $EA, $FF, $27, $EA, $13, $C1, $F0, $AC, $EA, $00, $28, $EA, $14, $C1, $18
	db $10, $F0, $AD, $EA, $FF, $37, $EA, $15, $C1, $F0, $AE, $EA, $00, $38, $EA, $16
	db $C1, $FB, $C9, $F3, $CD, $BF, $12, $FB, $C9
ASSERT @ == $12BF
