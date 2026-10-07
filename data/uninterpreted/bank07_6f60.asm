; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $6F60-$7267.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:6F60-7267", ROMX[$6F60], BANK[$07]
ResidualROM07_6F60::
	db $FF, $FF, $FF, $FF, $FF, $FE, $C3, $C1, $C7, $C3, $CF, $C7, $DF, $CF, $FF, $DF
	db $FF, $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $87, $07, $C7, $87, $E7, $C3, $F7, $E3, $FF, $F1
	db $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF, $BF
	ds $10, $FF
	db $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9, $FD, $F9
	db $FF, $DF, $DF, $CF, $CF, $C7, $C7, $C3, $C3, $C1, $FF, $E0, $FE, $FE, $FF, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF, $FF
	db $FF, $F1, $F7, $E3, $E7, $C3, $C7, $83, $87, $03, $FF, $03, $7F, $7F, $FF, $FF
	db $00, $FF, $00, $FF, $01, $FE, $03, $C1, $07, $C3, $0F, $C7, $1F, $CF, $3F, $DF
	db $00, $FF, $00, $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $00, $FF, $00, $FF, $00, $FF, $80, $07, $C0, $87, $E4, $C3, $F4, $E3, $FE, $F1
	db $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF
	ds $10, $FF
	db $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9
	db $3F, $DF, $1F, $CF, $0F, $C7, $07, $C3, $03, $C1, $1F, $E0, $00, $FE, $00, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF
	db $FE, $F1, $F4, $E3, $E4, $C3, $C4, $83, $84, $03, $FC, $03, $00, $7F, $00, $FF
	db $3C, $00, $24, $18, $E7, $18, $D3, $2C, $CB, $34, $E7, $18, $24, $18, $3C, $00
	db $66, $00, $F9, $06, $E1, $1E, $5A, $24, $5A, $24, $87, $78, $9F, $60, $66, $00
	db $7E, $00, $E7, $24, $DF, $5E, $FF, $3C, $BD, $42, $A1, $7E, $E3, $3C, $7E, $00
	db $00, $00, $00, $00, $00, $00, $7E, $00, $E7, $24, $DF, $5E, $FF, $3C, $7E, $00
	db $00, $00, $00, $00, $7E, $00, $7E, $00, $3C, $00, $3C, $00, $18, $00, $18, $00
	db $18, $00, $18, $00, $3C, $00, $3C, $00, $7E, $00, $7E, $00, $00, $00, $00, $00
	db $00, $FF, $00, $FF, $01, $FE, $03, $C1, $07, $C3, $0F, $C7, $1F, $CF, $3F, $DF
	db $00, $FF, $00, $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $00, $FF, $00, $FF, $00, $FF, $80, $07, $C0, $87, $E4, $C3, $F4, $E3, $FE, $F1
	db $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF, $7F, $BF
	ds $10, $FF
	db $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9, $FC, $F9
	db $3F, $DF, $1F, $CF, $0F, $C7, $07, $C3, $03, $C1, $1F, $E0, $00, $FE, $00, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF
	db $FE, $F1, $F4, $E3, $E4, $C3, $C4, $83, $84, $03, $FC, $03, $00, $7F, $00, $FF
	db $00, $FF, $00, $FF, $05, $FA, $00, $C0, $1F, $DF, $1F, $DF, $5F, $9F, $1F, $DF
	db $00, $FF, $00, $FF, $FF, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $00, $FF, $00, $FF, $40, $BF, $00, $07, $F0, $F7, $F4, $F3, $F4, $F3, $F6, $F1
	db $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F, $5F, $9F
	ds $10, $FF
	db $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1
	db $1F, $DF, $5F, $9F, $1F, $DF, $1F, $DF, $00, $C0, $1F, $E0, $05, $FA, $00, $FF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $FF, $00, $FF, $00, $00, $FF
	db $F6, $F1, $F6, $F1, $F6, $F1, $F6, $F1, $06, $01, $FE, $01, $FE, $01, $00, $FF
	db $3C, $00, $24, $18, $E7, $18, $D3, $2C, $CB, $34, $E7, $18, $24, $18, $3C, $00
	db $66, $00, $F9, $06, $E1, $1E, $5A, $24, $5A, $24, $87, $78, $9F, $60, $66, $00
	db $7E, $00, $E7, $24, $DF, $5E, $FF, $3C, $BD, $42, $A1, $7E, $E3, $3C, $7E, $00
	db $00, $00, $00, $00, $00, $00, $7E, $00, $E7, $24, $DF, $5E, $FF, $3C, $7E, $00
	db $00, $00, $00, $00, $7E, $00, $7E, $00, $3C, $00, $3C, $00, $18, $00, $18, $00
	db $18, $00, $18, $00, $3C, $00, $3C, $00, $7E, $00, $7E, $00, $00, $00, $00, $00
	db $1F, $7C, $00, $00, $FF, $03, $1F, $00
ASSERT @ == $7268
