; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $6F0C-$7267.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:6F0C-7267", ROMX[$6F0C], BANK[$07]
ResidualROM07_6F0C::
	db $8B, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C
	db $8C, $8C, $8C, $8D, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
	db $07, $07, $07, $07, $07, $07, $07, $07, $E1, $E2, $E2, $E2, $E2, $E2, $E2, $E2
	db $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E2, $E3, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $89, $00, $8A, $00, $FF, $FF, $FF, $FF, $FF, $FE, $C3, $C1, $C7, $C3, $CF, $C7
	db $DF, $CF, $FF, $DF, $FF, $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $87, $07, $C7, $87, $E7, $C3
	db $F7, $E3, $FF, $F1, $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF
	db $FF, $BF, $FF, $BF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9
	db $FD, $F9, $FD, $F9, $FF, $DF, $DF, $CF, $CF, $C7, $C7, $C3, $C3, $C1, $FF, $E0
	db $FE, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	db $00, $00, $FF, $FF, $FF, $F1, $F7, $E3, $E7, $C3, $C7, $83, $87, $03, $FF, $03
	db $7F, $7F, $FF, $FF, $00, $FF, $00, $FF, $01, $FE, $03, $C1, $07, $C3, $0F, $C7
	db $1F, $CF, $3F, $DF, $00, $FF, $00, $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $80, $07, $C0, $87, $E4, $C3
	db $F4, $E3, $FE, $F1, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF
	db $7F, $BF, $7F, $BF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9
	db $FC, $F9, $FC, $F9, $3F, $DF, $1F, $CF, $0F, $C7, $07, $C3, $03, $C1, $1F, $E0
	db $00, $FE, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	db $00, $00, $00, $FF, $FE, $F1, $F4, $E3, $E4, $C3, $C4, $83, $84, $03, $FC, $03
	db $00, $7F, $00, $FF, $3C, $00, $24, $18, $E7, $18, $D3, $2C, $CB, $34, $E7, $18
	db $24, $18, $3C, $00, $66, $00, $F9, $06, $E1, $1E, $5A, $24, $5A, $24, $87, $78
	db $9F, $60, $66, $00, $7E, $00, $E7, $24, $DF, $5E, $FF, $3C, $BD, $42, $A1, $7E
	db $E3, $3C, $7E, $00, $00, $00, $00, $00, $00, $00, $7E, $00, $E7, $24, $DF, $5E
	db $FF, $3C, $7E, $00, $00, $00, $00, $00, $7E, $00, $7E, $00, $3C, $00, $3C, $00
	db $18, $00, $18, $00, $18, $00, $18, $00, $3C, $00, $3C, $00, $7E, $00, $7E, $00
	db $00, $00, $00, $00, $00, $FF, $00, $FF, $01, $FE, $03, $C1, $07, $C3, $0F, $C7
	db $1F, $CF, $3F, $DF, $00, $FF, $00, $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $80, $07, $C0, $87, $E4, $C3
	db $F4, $E3, $FE, $F1, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF
	db $7F, $BF, $7F, $BF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9
	db $FC, $F9, $FC, $F9, $3F, $DF, $1F, $CF, $0F, $C7, $07, $C3, $03, $C1, $1F, $E0
	db $00, $FE, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	db $00, $00, $00, $FF, $FE, $F1, $F4, $E3, $E4, $C3, $C4, $83, $84, $03, $FC, $03
	db $00, $7F, $00, $FF, $00, $FF, $00, $FF, $05, $FA, $00, $C0, $1F, $DF, $1F, $DF
	db $5F, $9F, $1F, $DF, $00, $FF, $00, $FF, $FF, $00, $00, $00, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $00, $FF, $00, $FF, $40, $BF, $00, $07, $F0, $F7, $F4, $F3
	db $F4, $F3, $F6, $F1, $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F
	db $5F, $9F, $5F, $9F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1
	db $F6, $F1, $F6, $F1, $1F, $DF, $5F, $9F, $1F, $DF, $1F, $DF, $00, $C0, $1F, $E0
	db $05, $FA, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $FF, $00
	db $FF, $00, $00, $FF, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $06, $01, $FE, $01
	db $FE, $01, $00, $FF, $3C, $00, $24, $18, $E7, $18, $D3, $2C, $CB, $34, $E7, $18
	db $24, $18, $3C, $00, $66, $00, $F9, $06, $E1, $1E, $5A, $24, $5A, $24, $87, $78
	db $9F, $60, $66, $00, $7E, $00, $E7, $24, $DF, $5E, $FF, $3C, $BD, $42, $A1, $7E
	db $E3, $3C, $7E, $00, $00, $00, $00, $00, $00, $00, $7E, $00, $E7, $24, $DF, $5E
	db $FF, $3C, $7E, $00, $00, $00, $00, $00, $7E, $00, $7E, $00, $3C, $00, $3C, $00
	db $18, $00, $18, $00, $18, $00, $18, $00, $3C, $00, $3C, $00, $7E, $00, $7E, $00
	db $00, $00, $00, $00, $1F, $7C, $00, $00, $FF, $03, $1F, $00
ASSERT @ == $7268
