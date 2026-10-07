; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $0A, address $5B8C-$5BC5.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 0A:5B8C-5BC5", ROMX[$5B8C], BANK[$0A]
ResidualROM0A_5B8C::
	db $F3, $3E, $15, $E0, $AD, $EA, $FF, $37, $EA, $15, $C1, $AF, $E0, $AE, $EA, $00
	db $38, $EA, $16, $C1, $FB, $21, $4E, $C7, $06, $08, $AF, $B6, $20, $15, $05, $20
	db $FA, $FA, $01, $D0, $CB, $37, $C6, $D4, $5F, $3E, $71, $CE, $00, $57, $CD, $3E
	db $4C, $18, $06, $11, $4E, $C7, $CD, $3E, $4C, $C9
ASSERT @ == $5BC6
