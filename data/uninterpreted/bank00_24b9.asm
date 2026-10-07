; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $00, address $24B9-$254D.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 00:24B9-254D", ROM0[$24B9]
ResidualROM00_24B9::
	db $F5, $E5, $CD, $62, $13, $E1, $F1, $47, $7C, $FE, $60, $30, $3E, $F0, $AB, $EA
	db $6D, $C6, $F0, $AC, $EA, $6E, $C6, $78, $F3, $EA, $FF, $27, $E0, $AB, $EA, $13
	db $C1, $3E, $08, $EA, $00, $28, $E0, $AC, $EA, $14, $C1, $FB, $11, $EA, $24, $D5
	db $E9, $FA, $6D, $C6, $E0, $AB, $F3, $EA, $FF, $27, $EA, $13, $C1, $FA, $6E, $C6
	db $E0, $AC, $EA, $00, $28, $EA, $14, $C1, $FB, $18, $46, $F0, $AD, $EA, $6D, $C6
	db $F0, $AE, $EA, $6E, $C6, $FA, $6D, $C6, $E0, $AB, $FA, $6E, $C6, $E0, $AC, $78
	db $F3, $EA, $FF, $37, $E0, $AD, $EA, $15, $C1, $3E, $08, $EA, $00, $38, $E0, $AE
	db $EA, $16, $C1, $FB, $11, $32, $25, $D5, $E9, $FA, $6D, $C6, $E0, $AD, $F3, $EA
	db $FF, $37, $EA, $15, $C1, $FA, $6E, $C6, $E0, $AE, $EA, $00, $38, $EA, $16, $C1
	db $FB, $CD, $59, $13, $C9
ASSERT @ == $254E
