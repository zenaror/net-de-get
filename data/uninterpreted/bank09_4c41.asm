; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $4C41-$4FFE.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:4C41-4FFE", ROMX[$4C41], BANK[$09]
ResidualROM09_4C41::
	db $21, $20, $99, $06, $14, $E5, $CD, $E6, $4B, $E1, $7B, $E6, $7F, $20, $33, $11
	db $20, $00, $7E, $FE, $A5, $28, $0A, $FE, $A6, $28, $11, $FE, $A7, $28, $18, $18
	db $21, $3E, $A6, $77, $E5, $19, $3E, $A9, $77, $E1, $18, $16, $3E, $A7, $77, $E5
	db $19, $3E, $AA, $77, $E1, $18, $0B, $3E, $A5, $77, $E5, $19, $3E, $A8, $77, $E1
	db $18, $00, $23, $05, $20, $BF, $C9, $EA, $C4, $C5, $11, $14, $53, $CD, $E3, $01
	db $FA, $C4, $C5, $11, $14, $53, $CD, $E6, $01, $FA, $C4, $C5, $EA, $A5, $C5, $3E
	db $00, $EA, $C2, $C1, $C9, $F0, $41, $E6, $02, $20, $FA, $F0, $40, $F6, $60, $E0
	db $40, $3E, $9A, $CD, $4F, $02, $C9, $F0, $41, $E6, $02, $20, $FA, $F0, $40, $E6
	db $9F, $E0, $40, $01, $00, $00, $3E, $14, $67, $3E, $08, $6F, $11, $00, $D0, $3E
	db $07, $F6, $80, $CD, $94, $02, $C9, $FA, $A5, $C5, $EA, $C4, $C5, $11, $14, $53
	db $CD, $E3, $01, $01, $00, $00, $FA, $A8, $C1, $3C, $3C, $67, $FA, $A9, $C1, $87
	db $3C, $3C, $6F, $11, $00, $D0, $3E, $07, $CD, $94, $02, $C9, $AF, $EA, $CC, $C5
	db $EA, $CE, $C5, $CD, $26, $4D, $CD, $82, $4D, $C9, $AF, $EA, $E5, $C5, $EA, $E7
	db $C5, $EA, $E6, $C5, $EA, $E4, $C5, $AF, $EA, $CC, $C5, $EA, $CE, $C5, $CD, $26
	db $4D, $CD, $82, $4D, $C9, $FA, $A8, $C5, $21, $3C, $4D, $87, $5F, $16, $00, $19
	db $5E, $23, $56, $21, $3B, $4D, $E5, $6B, $62, $E9, $C9, $44, $4D, $48, $4D, $4C
	db $4D, $50, $4D, $21, $BD, $6B, $C9, $21, $D0, $6A, $C9, $21, $E5, $6A, $C9, $21
	db $3D, $6A, $C9, $FA, $CB, $C5, $47, $FA, $CC, $C5, $90, $DA, $EA, $4E, $AF, $EA
	db $CC, $C5, $FA, $CD, $C5, $47, $FA, $CE, $C5, $3C, $B8, $20, $0A, $FA, $D1, $C5
	db $EA, $CF, $C5, $CD, $FD, $4C, $C9, $EA, $CE, $C5, $CD, $26, $4D, $CD, $82, $4D
	db $C9, $F0, $AD, $E0, $9D, $F0, $AE, $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0
	db $AD, $FA, $1D, $C2, $EA, $00, $38, $E0, $AE, $FA, $CF, $C5, $87, $5F, $16, $00
	db $19, $2A, $66, $6F, $2A, $EA, $CD, $C5, $E5, $D1, $FA, $CE, $C5, $67, $2E, $04
	db $CD, $FF, $5C, $19, $7E, $FE, $FF, $20, $03, $CD, $AF, $4F, $7E, $FE, $FE, $20
	db $03, $CD, $C8, $50, $2A, $EA, $D0, $C5, $2A, $EA, $D7, $C5, $2A, $EA, $D8, $C5
	db $2A, $EA, $CB, $C5, $7E, $FE, $FF, $20, $04, $2A, $2A, $2A, $2A, $7E, $FE, $FE
	db $20, $04, $2A, $2A, $2A, $2A, $2A, $EA, $D1, $C5, $2A, $EA, $D9, $C5, $2A, $EA
	db $DA, $C5, $2A, $EA, $FD, $C5, $CD, $7A, $4E, $CD, $A3, $4E, $C9, $F0, $AD, $E0
	db $9D, $F0, $AE, $E0, $9E, $FA, $1C, $C2, $EA, $FF, $37, $E0, $AD, $FA, $1D, $C2
	db $EA, $00, $38, $E0, $AE, $FA, $C7, $C1, $EA, $F5, $C5, $B7, $C8, $FA, $D0, $C5
	db $87, $5F, $16, $00, $19, $2A, $66, $6F, $E5, $FA, $C7, $C1, $47, $3E, $28, $90
	db $26, $04, $6F, $CD, $FF, $5C, $11, $00, $C0, $19, $E5, $D1, $E1, $2A, $47, $FA
	db $F5, $C5, $3D, $EA, $F5, $C5, $2A, $4F, $FA, $D6, $C5, $81, $C6, $10, $12, $1C
	db $2A, $4F, $FA, $D5, $C5, $81, $C6, $08, $12, $1C, $2A, $12, $1C, $2A, $12, $1C
	db $05, $20, $DC, $C9, $3E, $00, $47, $FA, $D7, $C5, $90, $EA, $D5, $C5, $3E, $00
	db $47, $FA, $D8, $C5, $90, $EA, $D6, $C5, $C9, $3E, $C9, $47, $FA, $D7, $C5, $90
	db $EA, $D7, $C5, $3E, $D0, $47, $FA, $D8, $C5, $90, $EA, $D8, $C5, $3E, $C9, $47
	db $FA, $D9, $C5, $90, $EA, $D9, $C5, $3E, $D0, $47, $FA, $DA, $C5, $90, $EA, $DA
	db $C5, $C9, $FA, $D9, $C5, $47, $FA, $D7, $C5, $B8, $D2, $BB, $4E, $FA, $D7, $C5
	db $47, $FA, $D9, $C5, $90, $EA, $DD, $C5, $18, $0B, $FA, $D9, $C5, $47, $FA, $D7
	db $C5, $90, $EA, $DD, $C5, $FA, $DA, $C5, $47, $FA, $D8, $C5, $B8, $D2, $DE, $4E
	db $FA, $D8, $C5, $47, $FA, $DA, $C5, $90, $EA, $DE, $C5, $18, $0B, $FA, $DA, $C5
	db $47, $FA, $D8, $C5, $90, $EA, $DE, $C5, $C9, $FA, $D7, $C5, $47, $FA, $D9, $C5
	db $90, $4F, $FA, $D8, $C5, $47, $FA, $DA, $C5, $90, $B1, $C8, $CD, $6A, $4F, $FA
	db $D7, $C5, $47, $FA, $D9, $C5, $B8, $28, $1E, $B8, $D2, $1B, $4F, $FA, $DB, $C5
	db $47, $FA, $D7, $C5, $90, $EA, $D7, $C5, $18, $0D, $FA, $DB, $C5, $47, $FA, $D7
	db $C5, $80, $EA, $D7, $C5, $18, $00, $FA, $D8, $C5, $47, $FA, $DA, $C5, $B8, $28
	db $1C, $B8, $D2, $43, $4F, $FA, $DC, $C5, $47, $FA, $D8, $C5, $90, $EA, $D8, $C5
	db $18, $0B, $FA, $DC, $C5, $47, $FA, $D8, $C5, $80, $EA, $D8, $C5, $C9, $C5, $6F
	db $26, $00, $B9, $DA, $68, $4F, $06, $08, $29, $7C, $B9, $38, $03, $91, $67, $2C
	db $05, $20, $F5, $44, $4D, $61, $68, $C1, $C9, $AF, $EA, $DF, $C5, $FA, $CC, $C5
	db $47, $FA, $CB, $C5, $4F, $FA, $DF, $C5, $67, $FA, $DD, $C5, $84, $CD, $4F, $4F
	db $7C, $EA, $DB, $C5, $7D, $EA, $DF, $C5, $05, $20, $E6, $AF, $EA, $E0, $C5, $FA
	db $CC, $C5, $47, $FA, $CB, $C5, $4F, $FA, $E0, $C5, $67, $FA, $DE, $C5, $84, $CD
	db $4F, $4F, $7C, $EA, $DC, $C5, $7D, $EA, $E0, $C5, $05, $20, $E6, $C9, $2A, $2A
	db $2A, $EA, $F8, $C5, $2A, $EA, $F7, $C5, $E5, $FA, $F7, $C5, $67, $FA, $F8, $C5
	db $6F, $2A, $EA, $F9, $C5, $2A, $EA, $FA, $C5, $2A, $EA, $E2, $C5, $2A, $EA, $E3
	db $C5, $2A, $EA, $E6, $C5, $2A, $EA, $E4, $C5, $2A, $EA, $E8, $C5, $7C, $EA, $F7
	db $C5, $EA, $FB, $C5, $7D, $EA, $F8, $C5, $EA, $FC, $C5, $CD, $FF, $4F, $FA, $CE
	db $C5, $3C, $EA, $CE, $C5, $AF, $EA, $E5, $C5, $EA, $E7, $C5, $E1, $C9
ASSERT @ == $4FFF
