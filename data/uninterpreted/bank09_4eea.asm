; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $4EEA-$4FFE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:4EEA-4FFE", ROMX[$4EEA], BANK[$09]
ResidualROM09_4EEA::
	db $FA, $D7, $C5, $47, $FA, $D9, $C5, $90, $4F, $FA, $D8, $C5, $47, $FA, $DA, $C5
	db $90, $B1, $C8, $CD, $6A, $4F, $FA, $D7, $C5, $47, $FA, $D9, $C5, $B8, $28, $1E
	db $B8, $D2, $1B, $4F, $FA, $DB, $C5, $47, $FA, $D7, $C5, $90, $EA, $D7, $C5, $18
	db $0D, $FA, $DB, $C5, $47, $FA, $D7, $C5, $80, $EA, $D7, $C5, $18, $00, $FA, $D8
	db $C5, $47, $FA, $DA, $C5, $B8, $28, $1C, $B8, $D2, $43, $4F, $FA, $DC, $C5, $47
	db $FA, $D8, $C5, $90, $EA, $D8, $C5, $18, $0B, $FA, $DC, $C5, $47, $FA, $D8, $C5
	db $80, $EA, $D8, $C5, $C9, $C5, $6F, $26, $00, $B9, $DA, $68, $4F, $06, $08, $29
	db $7C, $B9, $38, $03, $91, $67, $2C, $05, $20, $F5, $44, $4D, $61, $68, $C1, $C9
	db $AF, $EA, $DF, $C5, $FA, $CC, $C5, $47, $FA, $CB, $C5, $4F, $FA, $DF, $C5, $67
	db $FA, $DD, $C5, $84, $CD, $4F, $4F, $7C, $EA, $DB, $C5, $7D, $EA, $DF, $C5, $05
	db $20, $E6, $AF, $EA, $E0, $C5, $FA, $CC, $C5, $47, $FA, $CB, $C5, $4F, $FA, $E0
	db $C5, $67, $FA, $DE, $C5, $84, $CD, $4F, $4F, $7C, $EA, $DC, $C5, $7D, $EA, $E0
	db $C5, $05, $20, $E6, $C9, $2A, $2A, $2A, $EA, $F8, $C5, $2A, $EA, $F7, $C5, $E5
	db $FA, $F7, $C5, $67, $FA, $F8, $C5, $6F, $2A, $EA, $F9, $C5, $2A, $EA, $FA, $C5
	db $2A, $EA, $E2, $C5, $2A, $EA, $E3, $C5, $2A, $EA, $E6, $C5, $2A, $EA, $E4, $C5
	db $2A, $EA, $E8, $C5, $7C, $EA, $F7, $C5, $EA, $FB, $C5, $7D, $EA, $F8, $C5, $EA
	db $FC, $C5, $CD, $FF, $4F, $FA, $CE, $C5, $3C, $EA, $CE, $C5, $AF, $EA, $E5, $C5
	db $EA, $E7, $C5, $E1, $C9
ASSERT @ == $4FFF
