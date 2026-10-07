; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $05E0-$0660.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:05E0-0660", ROM0[$05E0]
ResidualROM00_05E0::
	db $14, $00, $40, $12, $00, $40, $13, $00, $40, $10, $B8, $56, $0F, $00, $40, $71
	db $00, $40, $76, $00, $40, $87, $E1, $5F, $16, $00, $19, $5E, $23, $56, $D5, $E1
	db $E9, $F5, $C5, $D5, $E5, $3E, $01, $E0, $8A, $21, $8E, $FF, $5E, $23, $56, $62
	db $6B, $7D, $B4, $CA, $9E, $06, $11, $9E, $06, $D5, $E9, $F5, $C5, $D5, $E5, $21
	db $92, $FF, $5E, $23, $56, $62, $6B, $7D, $B4, $28, $6E, $11, $99, $06, $D5, $E9
	db $F5, $C5, $D5, $E5, $21, $8C, $FF, $5E, $23, $56, $62, $6B, $7D, $B4, $28, $59
	db $11, $99, $06, $D5, $E9, $F5, $C5, $D5, $E5, $21, $90, $FF, $5E, $23, $56, $62
	db $6B, $7D, $B4, $28, $44, $11, $99, $06, $D5, $E9, $F5, $C5, $D5, $E5, $C3, $99
	db $06
ASSERT @ == $0661
