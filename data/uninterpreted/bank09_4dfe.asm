; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $4DFE-$4E79.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:4DFE-4E79", ROMX[$4DFE], BANK[$09]
ResidualROM09_4DFE::
	db $F0, $AD, $E0, $9D, $F0, $AE, $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0, $AD
	db $FA, $1D, $C2, $EA, $00, $38, $E0, $AE, $FA, $C7, $C1, $EA, $F5, $C5, $B7, $C8
	db $FA, $D0, $C5, $87, $5F, $16, $00, $19, $2A, $66, $6F, $E5, $FA, $C7, $C1, $47
	db $3E, $28, $90, $26, $04, $6F, $CD, $FF, $5C, $11, $00, $C0, $19, $E5, $D1, $E1
	db $2A, $47, $FA, $F5, $C5, $3D, $EA, $F5, $C5, $2A, $4F, $FA, $D6, $C5, $81, $C6
	db $10, $12, $1C, $2A, $4F, $FA, $D5, $C5, $81, $C6, $08, $12, $1C, $2A, $12, $1C
	db $2A, $12, $1C, $05, $20, $DC, $C9, $3E, $00, $47, $FA, $D7, $C5, $90, $EA, $D5
	db $C5, $3E, $00, $47, $FA, $D8, $C5, $90, $EA, $D6, $C5, $C9
ASSERT @ == $4E7A
