; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $4CF0-$4D42.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:4CF0-4D42", ROMX[$4CF0], BANK[$0A]
ResidualROM0A_4CF0::
	db $FA, $C3, $C5, $FE, $10, $30, $04, $AF, $EA, $C4, $C5, $F0, $AD, $EA, $C5, $C5
	db $F0, $AE, $EA, $C6, $C5, $F3, $FA, $C3, $C5, $D6, $10, $E0, $AD, $EA, $FF, $37
	db $EA, $15, $C1, $3E, $08, $E0, $AE, $EA, $00, $38, $EA, $16, $C1, $FB, $CD, $62
	db $13, $FA, $05, $60, $EA, $C4, $C5, $CD, $59, $13, $F3, $FA, $C5, $C5, $E0, $AD
	db $EA, $FF, $37, $EA, $15, $C1, $FA, $C6, $C5, $E0, $AE, $EA, $00, $38, $EA, $16
	db $C1, $FB, $C9
ASSERT @ == $4D43
