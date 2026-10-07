; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $11AA-$12BE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:11AA-12BE", ROM0[$11AA]
ResidualROM00_11AA::
	db $21, $00, $C0, $01, $A0, $00, $AF, $22, $0B, $79, $B0, $20, $F9, $21, $C4, $C1
	db $7E, $B7, $CA, $B8, $12, $36, $00, $47, $F3, $FA, $C6, $C1, $FE, $60, $30, $14
	db $FA, $1C, $C2, $EA, $FF, $27, $EA, $13, $C1, $FA, $1D, $C2, $EA, $00, $28, $EA
	db $14, $C1, $18, $12, $FA, $1C, $C2, $EA, $FF, $37, $EA, $15, $C1, $FA, $1D, $C2
	db $EA, $00, $38, $EA, $16, $C1, $3E, $28, $EA, $C7, $C1, $21, $CA, $C1, $11, $00
	db $C0, $C5, $E5, $D5, $2A, $EA, $C8, $C1, $2A, $EA, $C9, $C1, $2A, $FE, $FF, $20
	db $2E, $D1, $7E, $F5, $FA, $C7, $C1, $B7, $28, $16, $3D, $EA, $C7, $C1, $FA, $C9
	db $C1, $12, $13, $FA, $C8, $C1, $12, $13, $F1, $12, $13, $FA, $B7, $C1, $12, $13
	db $E1, $C1, $D5, $11, $04, $00, $19, $D1, $05, $C2, $FB, $11, $C3, $8E, $12, $E5
	db $87, $5F, $16, $00, $FA, $C5, $C1, $6F, $FA, $C6, $C1, $67, $19, $5E, $23, $56
	db $E1, $7E, $87, $62, $6B, $5F, $16, $00, $19, $5E, $23, $56, $62, $6B, $D1, $2A
	db $47, $A7, $28, $24, $FA, $C7, $C1, $B7, $28, $1B, $3D, $EA, $C7, $C1, $7E, $4F
	db $23, $FA, $C9, $C1, $81, $12, $13, $4E, $23, $FA, $C8, $C1, $81, $12, $13, $2A
	db $12, $13, $2A, $12, $13, $05, $20, $DC, $E1, $C1, $D5, $11, $04, $00, $19, $D1
	db $05, $C2, $FB, $11, $FA, $C6, $C1, $FE, $60, $30, $12, $F0, $AB, $EA, $FF, $27
	db $EA, $13, $C1, $F0, $AC, $EA, $00, $28, $EA, $14, $C1, $18, $10, $F0, $AD, $EA
	db $FF, $37, $EA, $15, $C1, $F0, $AE, $EA, $00, $38, $EA, $16, $C1, $FB, $C9, $F3
	db $CD, $BF, $12, $FB, $C9
ASSERT @ == $12BF
