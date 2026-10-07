; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $4D82-$4FFE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:4D82-4FFE", ROMX[$4D82], BANK[$09]
ResidualROM09_4D82::
	db $F0, $AD, $E0, $9D, $F0, $AE, $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0, $AD
	db $FA, $1D, $C2, $EA, $00, $38, $E0, $AE, $FA, $CF, $C5, $87, $5F, $16, $00, $19
	db $2A, $66, $6F, $2A, $EA, $CD, $C5, $E5, $D1, $FA, $CE, $C5, $67, $2E, $04, $CD
	db $FF, $5C, $19, $7E, $FE, $FF, $20, $03, $CD, $AF, $4F, $7E, $FE, $FE, $20, $03
	db $CD, $C8, $50, $2A, $EA, $D0, $C5, $2A, $EA, $D7, $C5, $2A, $EA, $D8, $C5, $2A
	db $EA, $CB, $C5, $7E, $FE, $FF, $20, $04, $2A, $2A, $2A, $2A, $7E, $FE, $FE, $20
	db $04, $2A, $2A, $2A, $2A, $2A, $EA, $D1, $C5, $2A, $EA, $D9, $C5, $2A, $EA, $DA
	db $C5, $2A, $EA, $FD, $C5, $CD, $7A, $4E, $CD, $A3, $4E, $C9, $F0, $AD, $E0, $9D
	db $F0, $AE, $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0, $AD, $FA, $1D, $C2, $EA
	db $00, $38, $E0, $AE, $FA, $C7, $C1, $EA, $F5, $C5, $B7, $C8, $FA, $D0, $C5, $87
	db $5F, $16, $00, $19, $2A, $66, $6F, $E5, $FA, $C7, $C1, $47, $3E, $28, $90, $26
	db $04, $6F, $CD, $FF, $5C, $11, $00, $C0, $19, $E5, $D1, $E1, $2A, $47, $FA, $F5
	db $C5, $3D, $EA, $F5, $C5, $2A, $4F, $FA, $D6, $C5, $81, $C6, $10, $12, $1C, $2A
	db $4F, $FA, $D5, $C5, $81, $C6, $08, $12, $1C, $2A, $12, $1C, $2A, $12, $1C, $05
	db $20, $DC, $C9, $3E, $00, $47, $FA, $D7, $C5, $90, $EA, $D5, $C5, $3E, $00, $47
	db $FA, $D8, $C5, $90, $EA, $D6, $C5, $C9, $3E, $C9, $47, $FA, $D7, $C5, $90, $EA
	db $D7, $C5, $3E, $D0, $47, $FA, $D8, $C5, $90, $EA, $D8, $C5, $3E, $C9, $47, $FA
	db $D9, $C5, $90, $EA, $D9, $C5, $3E, $D0, $47, $FA, $DA, $C5, $90, $EA, $DA, $C5
	db $C9, $FA, $D9, $C5, $47, $FA, $D7, $C5, $B8, $D2, $BB, $4E, $FA, $D7, $C5, $47
	db $FA, $D9, $C5, $90, $EA, $DD, $C5, $18, $0B, $FA, $D9, $C5, $47, $FA, $D7, $C5
	db $90, $EA, $DD, $C5, $FA, $DA, $C5, $47, $FA, $D8, $C5, $B8, $D2, $DE, $4E, $FA
	db $D8, $C5, $47, $FA, $DA, $C5, $90, $EA, $DE, $C5, $18, $0B, $FA, $DA, $C5, $47
	db $FA, $D8, $C5, $90, $EA, $DE, $C5, $C9, $FA, $D7, $C5, $47, $FA, $D9, $C5, $90
	db $4F, $FA, $D8, $C5, $47, $FA, $DA, $C5, $90, $B1, $C8, $CD, $6A, $4F, $FA, $D7
	db $C5, $47, $FA, $D9, $C5, $B8, $28, $1E, $B8, $D2, $1B, $4F, $FA, $DB, $C5, $47
	db $FA, $D7, $C5, $90, $EA, $D7, $C5, $18, $0D, $FA, $DB, $C5, $47, $FA, $D7, $C5
	db $80, $EA, $D7, $C5, $18, $00, $FA, $D8, $C5, $47, $FA, $DA, $C5, $B8, $28, $1C
	db $B8, $D2, $43, $4F, $FA, $DC, $C5, $47, $FA, $D8, $C5, $90, $EA, $D8, $C5, $18
	db $0B, $FA, $DC, $C5, $47, $FA, $D8, $C5, $80, $EA, $D8, $C5, $C9, $C5, $6F, $26
	db $00, $B9, $DA, $68, $4F, $06, $08, $29, $7C, $B9, $38, $03, $91, $67, $2C, $05
	db $20, $F5, $44, $4D, $61, $68, $C1, $C9, $AF, $EA, $DF, $C5, $FA, $CC, $C5, $47
	db $FA, $CB, $C5, $4F, $FA, $DF, $C5, $67, $FA, $DD, $C5, $84, $CD, $4F, $4F, $7C
	db $EA, $DB, $C5, $7D, $EA, $DF, $C5, $05, $20, $E6, $AF, $EA, $E0, $C5, $FA, $CC
	db $C5, $47, $FA, $CB, $C5, $4F, $FA, $E0, $C5, $67, $FA, $DE, $C5, $84, $CD, $4F
	db $4F, $7C, $EA, $DC, $C5, $7D, $EA, $E0, $C5, $05, $20, $E6, $C9, $2A, $2A, $2A
	db $EA, $F8, $C5, $2A, $EA, $F7, $C5, $E5, $FA, $F7, $C5, $67, $FA, $F8, $C5, $6F
	db $2A, $EA, $F9, $C5, $2A, $EA, $FA, $C5, $2A, $EA, $E2, $C5, $2A, $EA, $E3, $C5
	db $2A, $EA, $E6, $C5, $2A, $EA, $E4, $C5, $2A, $EA, $E8, $C5, $7C, $EA, $F7, $C5
	db $EA, $FB, $C5, $7D, $EA, $F8, $C5, $EA, $FC, $C5, $CD, $FF, $4F, $FA, $CE, $C5
	db $3C, $EA, $CE, $C5, $AF, $EA, $E5, $C5, $EA, $E7, $C5, $E1, $C9
ASSERT @ == $4FFF
