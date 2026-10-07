; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $4C88-$4FFE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:4C88-4FFE", ROMX[$4C88], BANK[$09]
ResidualROM09_4C88::
	db $EA, $C4, $C5, $11, $14, $53, $CD, $E3, $01, $FA, $C4, $C5, $11, $14, $53, $CD
	db $E6, $01, $FA, $C4, $C5, $EA, $A5, $C5, $3E, $00, $EA, $C2, $C1, $C9, $F0, $41
	db $E6, $02, $20, $FA, $F0, $40, $F6, $60, $E0, $40, $3E, $9A, $CD, $4F, $02, $C9
	db $F0, $41, $E6, $02, $20, $FA, $F0, $40, $E6, $9F, $E0, $40, $01, $00, $00, $3E
	db $14, $67, $3E, $08, $6F, $11, $00, $D0, $3E, $07, $F6, $80, $CD, $94, $02, $C9
	db $FA, $A5, $C5, $EA, $C4, $C5, $11, $14, $53, $CD, $E3, $01, $01, $00, $00, $FA
	db $A8, $C1, $3C, $3C, $67, $FA, $A9, $C1, $87, $3C, $3C, $6F, $11, $00, $D0, $3E
	db $07, $CD, $94, $02, $C9, $AF, $EA, $CC, $C5, $EA, $CE, $C5, $CD, $26, $4D, $CD
	db $82, $4D, $C9, $AF, $EA, $E5, $C5, $EA, $E7, $C5, $EA, $E6, $C5, $EA, $E4, $C5
	db $AF, $EA, $CC, $C5, $EA, $CE, $C5, $CD, $26, $4D, $CD, $82, $4D, $C9, $FA, $A8
	db $C5, $21, $3C, $4D, $87, $5F, $16, $00, $19, $5E, $23, $56, $21, $3B, $4D, $E5
	db $6B, $62, $E9, $C9, $44, $4D, $48, $4D, $4C, $4D, $50, $4D, $21, $BD, $6B, $C9
	db $21, $D0, $6A, $C9, $21, $E5, $6A, $C9, $21, $3D, $6A, $C9, $FA, $CB, $C5, $47
	db $FA, $CC, $C5, $90, $DA, $EA, $4E, $AF, $EA, $CC, $C5, $FA, $CD, $C5, $47, $FA
	db $CE, $C5, $3C, $B8, $20, $0A, $FA, $D1, $C5, $EA, $CF, $C5, $CD, $FD, $4C, $C9
	db $EA, $CE, $C5, $CD, $26, $4D, $CD, $82, $4D, $C9, $F0, $AD, $E0, $9D, $F0, $AE
	db $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0, $AD, $FA, $1D, $C2, $EA, $00, $38
	db $E0, $AE, $FA, $CF, $C5, $87, $5F, $16, $00, $19, $2A, $66, $6F, $2A, $EA, $CD
	db $C5, $E5, $D1, $FA, $CE, $C5, $67, $2E, $04, $CD, $FF, $5C, $19, $7E, $FE, $FF
	db $20, $03, $CD, $AF, $4F, $7E, $FE, $FE, $20, $03, $CD, $C8, $50, $2A, $EA, $D0
	db $C5, $2A, $EA, $D7, $C5, $2A, $EA, $D8, $C5, $2A, $EA, $CB, $C5, $7E, $FE, $FF
	db $20, $04, $2A, $2A, $2A, $2A, $7E, $FE, $FE, $20, $04, $2A, $2A, $2A, $2A, $2A
	db $EA, $D1, $C5, $2A, $EA, $D9, $C5, $2A, $EA, $DA, $C5, $2A, $EA, $FD, $C5, $CD
	db $7A, $4E, $CD, $A3, $4E, $C9, $F0, $AD, $E0, $9D, $F0, $AE, $E0, $9E, $FA, $1C
	db $C2, $EA, $FF, $37, $E0, $AD, $FA, $1D, $C2, $EA, $00, $38, $E0, $AE, $FA, $C7
	db $C1, $EA, $F5, $C5, $B7, $C8, $FA, $D0, $C5, $87, $5F, $16, $00, $19, $2A, $66
	db $6F, $E5, $FA, $C7, $C1, $47, $3E, $28, $90, $26, $04, $6F, $CD, $FF, $5C, $11
	db $00, $C0, $19, $E5, $D1, $E1, $2A, $47, $FA, $F5, $C5, $3D, $EA, $F5, $C5, $2A
	db $4F, $FA, $D6, $C5, $81, $C6, $10, $12, $1C, $2A, $4F, $FA, $D5, $C5, $81, $C6
	db $08, $12, $1C, $2A, $12, $1C, $2A, $12, $1C, $05, $20, $DC, $C9, $3E, $00, $47
	db $FA, $D7, $C5, $90, $EA, $D5, $C5, $3E, $00, $47, $FA, $D8, $C5, $90, $EA, $D6
	db $C5, $C9, $3E, $C9, $47, $FA, $D7, $C5, $90, $EA, $D7, $C5, $3E, $D0, $47, $FA
	db $D8, $C5, $90, $EA, $D8, $C5, $3E, $C9, $47, $FA, $D9, $C5, $90, $EA, $D9, $C5
	db $3E, $D0, $47, $FA, $DA, $C5, $90, $EA, $DA, $C5, $C9, $FA, $D9, $C5, $47, $FA
	db $D7, $C5, $B8, $D2, $BB, $4E, $FA, $D7, $C5, $47, $FA, $D9, $C5, $90, $EA, $DD
	db $C5, $18, $0B, $FA, $D9, $C5, $47, $FA, $D7, $C5, $90, $EA, $DD, $C5, $FA, $DA
	db $C5, $47, $FA, $D8, $C5, $B8, $D2, $DE, $4E, $FA, $D8, $C5, $47, $FA, $DA, $C5
	db $90, $EA, $DE, $C5, $18, $0B, $FA, $DA, $C5, $47, $FA, $D8, $C5, $90, $EA, $DE
	db $C5, $C9, $FA, $D7, $C5, $47, $FA, $D9, $C5, $90, $4F, $FA, $D8, $C5, $47, $FA
	db $DA, $C5, $90, $B1, $C8, $CD, $6A, $4F, $FA, $D7, $C5, $47, $FA, $D9, $C5, $B8
	db $28, $1E, $B8, $D2, $1B, $4F, $FA, $DB, $C5, $47, $FA, $D7, $C5, $90, $EA, $D7
	db $C5, $18, $0D, $FA, $DB, $C5, $47, $FA, $D7, $C5, $80, $EA, $D7, $C5, $18, $00
	db $FA, $D8, $C5, $47, $FA, $DA, $C5, $B8, $28, $1C, $B8, $D2, $43, $4F, $FA, $DC
	db $C5, $47, $FA, $D8, $C5, $90, $EA, $D8, $C5, $18, $0B, $FA, $DC, $C5, $47, $FA
	db $D8, $C5, $80, $EA, $D8, $C5, $C9, $C5, $6F, $26, $00, $B9, $DA, $68, $4F, $06
	db $08, $29, $7C, $B9, $38, $03, $91, $67, $2C, $05, $20, $F5, $44, $4D, $61, $68
	db $C1, $C9, $AF, $EA, $DF, $C5, $FA, $CC, $C5, $47, $FA, $CB, $C5, $4F, $FA, $DF
	db $C5, $67, $FA, $DD, $C5, $84, $CD, $4F, $4F, $7C, $EA, $DB, $C5, $7D, $EA, $DF
	db $C5, $05, $20, $E6, $AF, $EA, $E0, $C5, $FA, $CC, $C5, $47, $FA, $CB, $C5, $4F
	db $FA, $E0, $C5, $67, $FA, $DE, $C5, $84, $CD, $4F, $4F, $7C, $EA, $DC, $C5, $7D
	db $EA, $E0, $C5, $05, $20, $E6, $C9, $2A, $2A, $2A, $EA, $F8, $C5, $2A, $EA, $F7
	db $C5, $E5, $FA, $F7, $C5, $67, $FA, $F8, $C5, $6F, $2A, $EA, $F9, $C5, $2A, $EA
	db $FA, $C5, $2A, $EA, $E2, $C5, $2A, $EA, $E3, $C5, $2A, $EA, $E6, $C5, $2A, $EA
	db $E4, $C5, $2A, $EA, $E8, $C5, $7C, $EA, $F7, $C5, $EA, $FB, $C5, $7D, $EA, $F8
	db $C5, $EA, $FC, $C5, $CD, $FF, $4F, $FA, $CE, $C5, $3C, $EA, $CE, $C5, $AF, $EA
	db $E5, $C5, $EA, $E7, $C5, $E1, $C9
ASSERT @ == $4FFF
