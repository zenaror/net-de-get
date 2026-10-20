; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $5D74-$5E1C.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:5D74-5E1C", ROMX[$5D74], BANK[$09]
ResidualROM09_5D74::
	db $2A, $12, $13, $0B, $78, $B1, $20, $F8, $C9, $AF, $21, $00, $C0, $0E, $28, $AF
	db $22, $22, $3E, $FF, $22, $AF, $22, $0D, $20, $F6, $C9, $3E, $01, $E0, $4F, $11
	db $00, $9C, $0E, $A0, $CD, $C8, $5E, $3E, $00, $E0, $4F, $11, $00, $9C, $0E, $A0
	db $CD, $FE, $5E, $C9, $7C, $FE, $60, $30, $2C, $F0, $AB, $E0, $9D, $F0, $AC, $E0
	db $9E, $FA, $1C, $C2, $EA, $FF, $27, $E0, $AB, $FA, $1D, $C2, $EA, $00, $28, $E0
	db $AC, $CD, $04, $5E, $F0, $9D, $E0, $AB, $EA, $FF, $27, $F0, $9E, $E0, $AC, $7F
	db $EA, $00, $28, $18, $2A, $F0, $AD, $E0, $9D, $F0, $AE, $E0, $9E, $FA, $1C, $C2
	db $EA, $FF, $37, $E0, $AD, $FA, $1D, $C2, $EA, $00, $38, $E0, $AE, $CD, $04, $5E
	db $F0, $9D, $E0, $AD, $EA, $FF, $37, $F0, $9E, $E0, $AE, $7F, $EA, $00, $38, $C9
	db $3E, $01, $E0, $4F, $11, $00, $98, $0E, $9C, $CD, $C8, $5E, $3E, $00, $E0, $4F
	db $11, $00, $98, $0E, $9C, $CD, $FE, $5E, $C9
ASSERT @ == $5E1D
