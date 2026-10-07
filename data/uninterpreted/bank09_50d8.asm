; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $50D8-$5313.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:50D8-5313", ROMX[$50D8], BANK[$09]
ResidualROM09_50D8::
	db $21, $E0, $6E, $CD, $17, $51, $C9, $FA, $CB, $C5, $47, $FA, $CC, $C5, $90, $DA
	db $6A, $52, $FA, $CD, $C5, $47, $FA, $CE, $C5, $3C, $B8, $20, $11, $3D, $F5, $AF
	db $EA, $CE, $C5, $21, $E0, $6E, $CD, $17, $51, $F1, $EA, $CE, $C5, $C9, $EA, $CE
	db $C5, $21, $E0, $6E, $CD, $17, $51, $FA, $CE, $C5, $3D, $EA, $CE, $C5, $C9, $F0
	db $AD, $E0, $9D, $F0, $AE, $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0, $AD, $FA
	db $1D, $C2, $EA, $00, $38, $E0, $AE, $FA, $CF, $C5, $87, $5F, $16, $00, $19, $2A
	db $66, $6F, $2A, $E5, $D1, $FA, $CE, $C5, $67, $2E, $04, $CD, $FF, $5C, $19, $7E
	db $FE, $FF, $20, $04, $2A, $2A, $2A, $2A, $7E, $FE, $FE, $20, $04, $2A, $2A, $2A
	db $2A, $2A, $EA, $F6, $C5, $2A, $EA, $EB, $C5, $2A, $EA, $EC, $C5, $2A, $7E, $FE
	db $FF, $20, $04, $2A, $2A, $2A, $2A, $7E, $FE, $FE, $20, $04, $2A, $2A, $2A, $2A
	db $2A, $2A, $EA, $ED, $C5, $2A, $EA, $EE, $C5, $CD, $FA, $51, $CD, $23, $52, $C9
	db $F0, $AD, $E0, $9D, $F0, $AE, $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0, $AD
	db $FA, $1D, $C2, $EA, $00, $38, $E0, $AE, $FA, $F5, $C5, $B7, $C8, $FA, $F6, $C5
	db $87, $5F, $16, $00, $19, $2A, $66, $6F, $E5, $FA, $F5, $C5, $47, $3E, $28, $90
	db $26, $04, $6F, $CD, $FF, $5C, $11, $00, $C0, $19, $E5, $D1, $E1, $2A, $47, $2A
	db $4F, $FA, $EA, $C5, $81, $C6, $10, $12, $1C, $2A, $4F, $FA, $E9, $C5, $81, $C6
	db $08, $12, $1C, $2A, $12, $1C, $2A, $12, $1C, $05, $20, $E3, $C9, $3E, $00, $47
	db $FA, $EB, $C5, $90, $EA, $E9, $C5, $3E, $00, $47, $FA, $EC, $C5, $90, $EA, $EA
	db $C5, $C9, $3E, $C9, $47, $FA, $EB, $C5, $90, $EA, $EB, $C5, $3E, $D0, $47, $FA
	db $EC, $C5, $90, $EA, $EC, $C5, $3E, $C9, $47, $FA, $ED, $C5, $90, $EA, $ED, $C5
	db $3E, $D0, $47, $FA, $EE, $C5, $90, $EA, $EE, $C5, $C9, $FA, $ED, $C5, $47, $FA
	db $EB, $C5, $B8, $D2, $3B, $52, $FA, $EB, $C5, $47, $FA, $ED, $C5, $90, $EA, $F1
	db $C5, $18, $0B, $FA, $ED, $C5, $47, $FA, $EB, $C5, $90, $EA, $F1, $C5, $FA, $EE
	db $C5, $47, $FA, $EC, $C5, $B8, $D2, $5E, $52, $FA, $EC, $C5, $47, $FA, $EE, $C5
	db $90, $EA, $F2, $C5, $18, $0B, $FA, $EE, $C5, $47, $FA, $EC, $C5, $90, $EA, $F2
	db $C5, $C9, $FA, $EB, $C5, $47, $FA, $ED, $C5, $90, $4F, $FA, $EC, $C5, $47, $FA
	db $EE, $C5, $90, $B1, $C8, $CD, $CF, $52, $FA, $EB, $C5, $47, $FA, $ED, $C5, $B8
	db $28, $1E, $B8, $D2, $9B, $52, $FA, $EF, $C5, $47, $FA, $EB, $C5, $90, $EA, $EB
	db $C5, $18, $0D, $FA, $EF, $C5, $47, $FA, $EB, $C5, $80, $EA, $EB, $C5, $18, $00
	db $FA, $EC, $C5, $47, $FA, $EE, $C5, $B8, $28, $1C, $B8, $D2, $C3, $52, $FA, $F0
	db $C5, $47, $FA, $EC, $C5, $90, $EA, $EC, $C5, $18, $0B, $FA, $F0, $C5, $47, $FA
	db $EC, $C5, $80, $EA, $EC, $C5, $C9, $AF, $EA, $F3, $C5, $FA, $CC, $C5, $47, $FA
	db $CB, $C5, $4F, $FA, $F3, $C5, $67, $FA, $F1, $C5, $84, $CD, $4F, $4F, $7C, $EA
	db $EF, $C5, $7D, $EA, $F3, $C5, $05, $20, $E6, $AF, $EA, $F4, $C5, $FA, $CC, $C5
	db $47, $FA, $CB, $C5, $4F, $FA, $F4, $C5, $67, $FA, $F2, $C5, $84, $CD, $4F, $4F
	db $7C, $EA, $F0, $C5, $7D, $EA, $F4, $C5, $05, $20, $E6, $C9
ASSERT @ == $5314
