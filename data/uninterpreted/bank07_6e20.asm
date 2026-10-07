; HYPOTHESIS classification: uninterpreted original bytes, not asserted data/code.
; Byte preservation is checked; this source needs later consumer/flow analysis.
; Physical bank $07, address $6E20-$6E67.
; Literal source only; building does not read the external reference ROM.
SECTION "Uninterpreted 07:6E20-6E67", ROMX[$6E20], BANK[$07]
ResidualROM07_6E20::
	db $00, $00, $AD, $35, $D2, $7E, $FF, $7F, $1F, $00, $0D, $21, $B5, $56, $FF, $7F
	db $00, $7C, $8C, $3D, $B5, $56, $FF, $7F, $74, $7F, $00, $30, $47, $7E, $FF, $7F
	db $00, $00, $4A, $29, $B5, $56, $FF, $7F, $00, $00, $4A, $29, $B5, $56, $FF, $7F
	db $43, $01, $89, $1A, $F1, $3B, $FF, $7F, $43, $01, $89, $1A, $F1, $3B, $FF, $7F
	db $1F, $7C, $00, $00, $FF, $03, $1F, $00
ASSERT @ == $6E68
