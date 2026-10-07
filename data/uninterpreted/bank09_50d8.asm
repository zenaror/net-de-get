; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $09, address $50D8-$5187.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 09:50D8-5187", ROMX[$50D8], BANK[$09]
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
ASSERT @ == $5188
