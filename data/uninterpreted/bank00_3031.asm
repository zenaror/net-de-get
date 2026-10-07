; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $3031-$30BB.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:3031-30BB", ROM0[$3031]
ResidualROM00_3031::
	db $F3, $F0, $4F, $E6, $01, $F5, $FA, $AF, $C1, $E0, $4F, $FA, $0D, $C2, $87, $4F
	db $FA, $0E, $C2, $CD, $23, $20, $06, $00, $FA, $12, $C2, $4F, $54, $5D, $CD, $35
	db $20, $29, $29, $29, $29, $54, $5D, $FA, $0A, $C2, $6F, $FA, $0B, $C2, $67, $19
	db $7C, $E0, $51, $7D, $E6, $F0, $E0, $52, $FA, $1C, $C2, $EA, $FF, $27, $EA, $13
	db $C1, $FA, $1D, $C2, $EA, $00, $28, $EA, $14, $C1, $11, $00, $88, $7A, $E0, $53
	db $7B, $E0, $54, $FA, $0D, $C2, $87, $4F, $FA, $0E, $C2, $CD, $12, $20, $3D, $4F
	db $F0, $44, $B7, $20, $FB, $F0, $41, $E6, $03, $20, $FA, $79, $F6, $80, $E0, $55
	db $0C, $F0, $44, $91, $20, $FB, $F0, $AB, $EA, $FF, $27, $EA, $13, $C1, $F0, $AC
	db $EA, $00, $28, $EA, $14, $C1, $F1, $E0, $4F, $FB, $C9
ASSERT @ == $30BC
