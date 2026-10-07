; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $67AA-$67DF.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:67AA-67DF", ROMX[$67AA], BANK[$07]
ResidualROM07_67AA::
	db $3E, $00, $EA, $B8, $C1, $FA, $73, $C7, $6F, $FA, $74, $C7, $67, $3E, $04, $CD
	db $7A, $01, $CD, $7D, $01, $CD, $D5, $47, $FA, $20, $C2, $4F, $FA, $86, $CF, $B1
	db $20, $F0, $C9, $C9, $CD, $80, $FF, $CD, $8C, $01, $C9, $76, $00, $F0, $8A, $A7
	db $28, $FB, $AF, $E0, $8A, $C9
ASSERT @ == $67E0
