; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $51FA-$5313.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:51FA-5313", ROMX[$51FA], BANK[$09]
ResidualROM09_51FA::
	db $3E, $C9, $47, $FA, $EB, $C5, $90, $EA, $EB, $C5, $3E, $D0, $47, $FA, $EC, $C5
	db $90, $EA, $EC, $C5, $3E, $C9, $47, $FA, $ED, $C5, $90, $EA, $ED, $C5, $3E, $D0
	db $47, $FA, $EE, $C5, $90, $EA, $EE, $C5, $C9, $FA, $ED, $C5, $47, $FA, $EB, $C5
	db $B8, $D2, $3B, $52, $FA, $EB, $C5, $47, $FA, $ED, $C5, $90, $EA, $F1, $C5, $18
	db $0B, $FA, $ED, $C5, $47, $FA, $EB, $C5, $90, $EA, $F1, $C5, $FA, $EE, $C5, $47
	db $FA, $EC, $C5, $B8, $D2, $5E, $52, $FA, $EC, $C5, $47, $FA, $EE, $C5, $90, $EA
	db $F2, $C5, $18, $0B, $FA, $EE, $C5, $47, $FA, $EC, $C5, $90, $EA, $F2, $C5, $C9
	db $FA, $EB, $C5, $47, $FA, $ED, $C5, $90, $4F, $FA, $EC, $C5, $47, $FA, $EE, $C5
	db $90, $B1, $C8, $CD, $CF, $52, $FA, $EB, $C5, $47, $FA, $ED, $C5, $B8, $28, $1E
	db $B8, $D2, $9B, $52, $FA, $EF, $C5, $47, $FA, $EB, $C5, $90, $EA, $EB, $C5, $18
	db $0D, $FA, $EF, $C5, $47, $FA, $EB, $C5, $80, $EA, $EB, $C5, $18, $00, $FA, $EC
	db $C5, $47, $FA, $EE, $C5, $B8, $28, $1C, $B8, $D2, $C3, $52, $FA, $F0, $C5, $47
	db $FA, $EC, $C5, $90, $EA, $EC, $C5, $18, $0B, $FA, $F0, $C5, $47, $FA, $EC, $C5
	db $80, $EA, $EC, $C5, $C9, $AF, $EA, $F3, $C5, $FA, $CC, $C5, $47, $FA, $CB, $C5
	db $4F, $FA, $F3, $C5, $67, $FA, $F1, $C5, $84, $CD, $4F, $4F, $7C, $EA, $EF, $C5
	db $7D, $EA, $F3, $C5, $05, $20, $E6, $AF, $EA, $F4, $C5, $FA, $CC, $C5, $47, $FA
	db $CB, $C5, $4F, $FA, $F4, $C5, $67, $FA, $F2, $C5, $84, $CD, $4F, $4F, $7C, $EA
	db $F0, $C5, $7D, $EA, $F4, $C5, $05, $20, $E6, $C9
ASSERT @ == $5314
